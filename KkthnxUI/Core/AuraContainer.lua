--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/AuraContainer.lua
	Purpose:
		A thin wrapper over Blizzard's Midnight CustomAuraContainer intrinsic. On
		12.1 an addon can no longer read auras from tainted code (GetAuraSlots /
		GetAuraDataByIndex throw on secret auras, and updateInfo.isFullUpdate is a
		secret boolean). The supported path is this intrinsic frame: Blizzard
		creates and drives the aura buttons untainted, and we only style them
		through the initializeFrame callback.

		Every call into the intrinsic is guarded, so if the API shifts or the
		Blizzard addon is missing we degrade to no auras instead of erroring.

		K.CreateAuraContainer(parent, opts) where opts:
			point        - {anchor, rel, relPoint, x, y} for the container
			size         - button edge in pixels
			perRow       - wrap after this many icons
			spacing      - gap between icons
			anchorPoint  - flow start corner ("TOPRIGHT", ...)
			growthH      - "Right" | "Left"
			growthV      - "Down" | "Up"
			unit         - unit token to watch
			slots        - list of { key, filter (string), sortMethod, cancel }
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local CreateFrame = CreateFrame
local CreateColor = CreateColor
local pcall = pcall
local ipairs = ipairs
local unpack = unpack

-- Feature probe: the intrinsic and its enums only exist on the Midnight client.
local function Available()
	return CreateFrame and CustomAuraContainerAuraProcessingPolicy and AuraContainerSortMethod and AnchorUtil and AnchorUtil.FlowDirection
end

-- Make sure the Blizzard addon that defines the intrinsic template is loaded.
local function EnsureLoaded()
	if C_AddOns and C_AddOns.LoadAddOn and C_AddOns.IsAddOnLoaded and not C_AddOns.IsAddOnLoaded("Blizzard_AuraContainer") then
		pcall(C_AddOns.LoadAddOn, "Blizzard_AuraContainer")
	end
end

-- A compact duration formatter: bare seconds (no "s"), then "1m", "2h", "3d".
-- Built once, guarded, and reused for every button's duration text.
local durationFormatter
local function GetDurationFormatter()
	if durationFormatter ~= nil then
		return durationFormatter or nil
	end
	durationFormatter = false
	if C_StringUtil and C_StringUtil.CreateNumericRuleFormatter and Enum and Enum.NumericRuleFormatRounding then
		local up = Enum.NumericRuleFormatRounding.Up
		local down = Enum.NumericRuleFormatRounding.Down
		local f = C_StringUtil.CreateNumericRuleFormatter()
		local ok = pcall(f.SetBreakpoints, f, {
			{ threshold = 0, format = "%d", step = 1, rounding = up },
			{ threshold = 60, format = "%dm", step = 1, rounding = up, components = { { div = 60 } } },
			{ threshold = 61, format = "%dm", step = 1, rounding = down, components = { { div = 60 } } },
			{ threshold = 3600, format = "%dh", step = 1, rounding = down, components = { { div = 3600 } } },
			{ threshold = 86400, format = "%dd", step = 1, rounding = down, components = { { div = 86400 } } },
		})
		if ok then
			durationFormatter = f
		end
	end
	return durationFormatter or nil
end

-- Build the per-button styling callback. The engine calls this once when it
-- creates a button, then drives the registered regions itself. Regions must be
-- created and given a font BEFORE they are registered, because each register
-- immediately runs the engine's display update, and an unstyled FontString
-- errors inside it.
local function MakeInitializer(opts)
	local size = opts.size or 26
	return function(button)
		-- Turn clicks off unless this slot wants cancel-on-click (player buffs),
		-- so aura icons never eat target-switch clicks on nameplates.
		if not opts.cancel then
			pcall(button.SetMouseClickEnabled, button, false)
		end

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

		local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
		cooldown:SetAllPoints(icon)
		cooldown:SetHideCountdownNumbers(true)
		K.StyleCooldownSwipe(cooldown)

		-- Text rides a frame above the cooldown, or the swipe draws over it.
		local textParent = CreateFrame("Frame", nil, button)
		textParent:SetAllPoints(button)
		textParent:SetFrameLevel(cooldown:GetFrameLevel() + 1)

		local count = textParent:CreateFontString(nil, "OVERLAY")
		K.SetFont(count, 12, "OUTLINE")
		count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)

		local duration = textParent:CreateFontString(nil, "OVERLAY")
		K.SetFont(duration, 12, "OUTLINE")
		-- Centred on the icon, not below it.
		duration:SetPoint("CENTER", button, "CENTER", 0, 0)

		-- Nameplate auras wear our soft shadow to match the plate; everything else
		-- gets the hard border.
		if opts.shadow and K.CreateShadow then
			K.CreateShadow(button, 3)
		else
			K.CreateBorder(button)
		end

		-- Dispel-type border: the engine shows and tints this only on debuffs the
		-- player can act on, coloured by dispel school, so purgeable auras stand
		-- out. It rides over our static border and Blizzard drives it, so it works
		-- even though we cannot read the aura's dispel type from tainted code.
		-- We cannot read an aura's dispel type from tainted code, but the engine can
		-- tint textures we register (PreserveAsset keeps the art, tints the vertex
		-- colour by dispel school).
		if opts.dispelBorder and button.AddDispelTypeTexture and Enum and Enum.CustomAuraButtonDispelTypeTextureStyle then
			local border = button.KKUI_Border
			if border then
				-- Bordered buttons: tint our own eight border segments. Untyped
				-- debuffs fall back to the normal border colour, not red.
				local segments = { border.TOPLEFT, border.TOPRIGHT, border.BOTTOMLEFT, border.BOTTOMRIGHT, border.TOP, border.BOTTOM, border.LEFT, border.RIGHT }
				local base = (C.General and C.General.BorderColor) or { 1, 1, 1 }
				local dispelOpts = {
					style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
					showWhenHarmful = true,
					showWithoutDispelType = true,
					customDispelColorMap = { None = CreateColor(base[1], base[2], base[3]) },
				}
				for i = 1, #segments do
					if segments[i] then
						pcall(button.AddDispelTypeTexture, button, segments[i], dispelOpts)
					end
				end
			else
				-- Shadow buttons (nameplates) keep their normal shadow; we only add a
				-- soft coloured glow the engine tints on top, and only for debuffs the
				-- player can dispel, so untyped debuffs are untouched.
				local glow = button:CreateTexture(nil, "OVERLAY")
				glow:SetTexture(C.Media and C.Media.Textures and C.Media.Textures.Glow)
				glow:SetPoint("TOPLEFT", button, "TOPLEFT", -4, 4)
				glow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 4, -4)
				pcall(button.AddDispelTypeTexture, button, glow, {
					style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
					showWhenHarmful = true,
					-- Some debuffs report an empty dispel type that maps to the red
					-- "None" colour. Make that transparent so only the real dispel
					-- schools (Magic/Curse/Poison/Disease) light the glow.
					customDispelColorMap = { None = CreateColor(0, 0, 0, 0) },
				})
			end
		end

		-- Size before registering so the flow layout has a rect. Guarded because
		-- writes to the button are denied while auras are secret (combat).
		pcall(button.SetSize, button, size, size)

		-- Register the regions with the engine.
		pcall(button.SetIcon, button, icon)
		pcall(button.SetDurationCooldown, button, cooldown)
		pcall(button.SetApplicationCount, button, count, {})
		local fmt = GetDurationFormatter()
		pcall(button.SetDurationText, button, duration, fmt and { textFormatter = fmt } or {})

		if opts.cancel then
			pcall(button.SetCancelAuraButtons, button, true)
		end
	end
end

-- Create and return a configured aura container, or nil if unsupported.
function K.CreateAuraContainer(parent, opts)
	if not Available() then
		return nil
	end
	EnsureLoaded()

	local ok, container = pcall(CreateFrame, "AuraContainer", nil, parent, "CustomAuraContainerTemplate")
	if not ok or not container then
		return nil
	end

	if opts.point then
		container:SetPoint(unpack(opts.point))
	end
	container:SetSize(1, 1)

	pcall(container.SetAuraProcessingPolicy, container, CustomAuraContainerAuraProcessingPolicy.ProcessAura, {})

	local FD = AnchorUtil.FlowDirection
	if container.SetFlowLayoutAnchorPoint and opts.anchorPoint then
		pcall(container.SetFlowLayoutAnchorPoint, container, opts.anchorPoint)
	end
	if container.SetFlowLayoutGrowthDirection then
		pcall(container.SetFlowLayoutGrowthDirection, container, FD[opts.growthH or "Right"], FD[opts.growthV or "Down"])
	end
	if container.SetFlowLayoutMaximumLineSize and opts.perRow then
		local step = (opts.size or 26) + (opts.spacing or 6)
		pcall(container.SetFlowLayoutMaximumLineSize, container, opts.perRow * step)
	end

	local init = MakeInitializer(opts)
	local size = opts.size or 26
	local spacing = opts.spacing or 6
	-- Groups (not slots): a slot shows a single preferred aura, a group shows many
	-- (up to maxFrameCount), which is what a buff or debuff row wants.
	for _, slot in ipairs(opts.slots or {}) do
		pcall(container.AddAuraGroup, container, slot.key, slot.filter, {
			maxFrameCount = slot.max or 40,
			sortMethod = slot.sortMethod or AuraContainerSortMethod.Default,
			sortDirection = AuraContainerSortDirection and AuraContainerSortDirection.Normal or nil,
			initializeFrame = init,
			candidateFilters = slot.candidateFilters,
			layout = {
				elementWidth = size,
				elementHeight = size,
				elementSpacing = spacing,
				lineSpacing = spacing,
			},
		})
	end

	-- Unit LAST: assigning it re-evaluates event registration, which is gated on
	-- the container already having slots.
	if opts.unit then
		pcall(container.SetUnit, container, opts.unit)
	end
	pcall(container.UpdateAllAuras, container)

	return container
end
