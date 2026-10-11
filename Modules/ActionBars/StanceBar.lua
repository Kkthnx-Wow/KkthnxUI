--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/StanceBar.lua
	Purpose:
		The stance / shapeshift bar. Stances are not a LibActionButton type, so we
		reuse Blizzard's stance buttons: reparent them onto our own bar, skin them,
		and re-lay the row whenever the available forms change.

		The stock controller that normally refreshes these buttons is switched off
		with the rest of the stock bars (see DisableBlizzard.lua), and its bar is
		never shown, so nothing else tells the buttons how many forms there are or
		what each one looks like. This file does both: it shows only the buttons for
		forms that exist, and keeps each icon, active mark, usable tint and cooldown
		current from the form events.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("ActionBars")

local _G = _G
local ceil = math.ceil
local floor = math.floor
local InCombatLockdown = InCombatLockdown
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown

local NUM_STANCE_SLOTS = 10

-- Re-lay the visible stance buttons into our grid. Out of combat only, since it
-- moves protected buttons.
function Module:LayoutStanceBar()
	local bar = self.bars.StanceBar
	if not bar or InCombatLockdown() then
		return
	end
	local cfg = C.ActionBar.StanceBar
	local size, space, perRow = cfg.Size, cfg.Space, cfg.PerRow

	local shown = GetNumShapeshiftForms() or 0
	local rows = shown > 0 and ceil(shown / perRow) or 1
	local cols = shown > 0 and (shown < perRow and shown or perRow) or 1
	bar:SetSize(cols * size + (cols - 1) * space, rows * size + (rows - 1) * space)

	for i, button in ipairs(bar.buttons) do
		button:SetSize(size, size)
		local col = (i - 1) % perRow
		local row = floor((i - 1) / perRow)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", bar, "TOPLEFT", col * (size + space), -row * (size + space))
	end

	-- The footprint changes with the number of forms, so the mover follows it.
	local mover = bar.KKUI_Mover
	if mover then
		mover:SetSize(bar:GetWidth(), bar:GetHeight())
	end
end

-- Icon, active mark, tint and cooldown for each form. Plain texture and colour
-- calls only, so it is safe in combat. The cooldown goes straight to the cooldown
-- frame, which accepts the values even when the game hides them.
function Module:UpdateStanceState()
	local bar = self.bars and self.bars.StanceBar
	if not bar then
		return
	end
	local count = GetNumShapeshiftForms() or 0
	for index, button in ipairs(bar.buttons) do
		if index <= count then
			local texture, isActive, isCastable = GetShapeshiftFormInfo(index)
			button.icon:SetTexture(texture)
			button:SetChecked(isActive and true or false)
			if isCastable then
				button.icon:SetVertexColor(1, 1, 1)
			else
				button.icon:SetVertexColor(0.4, 0.4, 0.4)
			end
			if button.cooldown then
				local start, duration = GetShapeshiftFormCooldown(index)
				button.cooldown:SetCooldown(start or 0, duration or 0)
			end
		end
	end
end

-- Show a button for every form and hide the rest. The stock layout code decides
-- visibility from the statehidden attribute, so that is set as well, otherwise it
-- would put the spare buttons back. Protected frames, so out of combat only.
function Module:UpdateStanceButtons()
	local bar = self.bars and self.bars.StanceBar
	if not bar or InCombatLockdown() then
		return
	end
	local count = GetNumShapeshiftForms() or 0
	for index, button in ipairs(bar.buttons) do
		local wanted = index <= count
		button:SetAttribute("statehidden", (not wanted) or nil)
		button:SetShown(wanted)
	end
end

function Module:CreateStanceBar()
	local cfg = C.ActionBar.StanceBar
	if not cfg or not cfg.Enable then
		return
	end
	-- The bar is always built, even when the class has no forms yet. Druids,
	-- warriors, and the like learn forms as they level, and the count can read
	-- zero at login before it settles, so bailing here would leave them without
	-- a stance bar for the rest of the session. Visibility is driven live from
	-- the form count in UpdateStanceVisibility instead.

	local bar = CreateFrame("Frame", "KKUI_StanceBar", UIParent, "SecureHandlerStateTemplate")
	bar.key = "StanceBar"
	bar.buttons = {}

	for i = 1, NUM_STANCE_SLOTS do
		local button = _G["StanceButton" .. i]
		if button then
			button:SetParent(bar)
			self:StyleAuxButton(button)
			bar.buttons[i] = button
		end
	end

	self.bars.StanceBar = bar

	self:LayoutStanceBar()
	self:SetupFade(bar, cfg)

	-- Size first so the mover box matches, with a sane fallback when the class
	-- has no forms yet at login.
	local w = bar:GetWidth()
	local h = bar:GetHeight()
	if not w or w <= 0 then
		w, h = cfg.Size, cfg.Size
	end
	K.CreateMover(bar, "StanceBar", "Stance Bar", { "BOTTOM", UIParent, "BOTTOM", 0, 250 }, w, h)

	-- Forms change when a talent or spec does, and the buttons need telling what
	-- each form looks like whenever one is used.
	for _, event in ipairs({ "UPDATE_SHAPESHIFT_FORMS", "PLAYER_ENTERING_WORLD", "SPELLS_CHANGED" }) do
		self:RegisterEvent(event, function()
			Module:UpdateStanceVisibility(bar)
		end)
	end
	for _, event in ipairs({ "UPDATE_SHAPESHIFT_FORM", "UPDATE_SHAPESHIFT_USABLE", "UPDATE_SHAPESHIFT_COOLDOWN" }) do
		self:RegisterEvent(event, function()
			Module:UpdateStanceState()
		end)
	end

	self:UpdateStanceVisibility(bar)
	return bar
end

-- Show the bar only when the class actually has forms, and never over a pet
-- battle, vehicle, or override bar. Buttons and the visibility driver are
-- protected, so a change that arrives in combat waits for combat to end.
function Module:UpdateStanceVisibility(bar)
	bar = bar or (self.bars and self.bars.StanceBar)
	if not bar then
		return
	end
	if InCombatLockdown() then
		K.DeferCombat("StanceBar", function()
			Module:UpdateStanceVisibility()
		end)
		return
	end
	self:UpdateStanceButtons()
	self:LayoutStanceBar()
	self:UpdateStanceState()
	if (GetNumShapeshiftForms() or 0) > 0 then
		RegisterStateDriver(bar, "visibility", "[petbattle][vehicleui][overridebar] hide; show")
	else
		UnregisterStateDriver(bar, "visibility")
		bar:Hide()
	end
end
