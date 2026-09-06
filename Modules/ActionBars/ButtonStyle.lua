--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/ButtonStyle.lua
	Purpose:
		The LibActionButton config and per button styling. hideElements.border
		tells LAB to stop drawing the Blizzard art (normal texture, icon mask,
		slot background) on every state update, so only our border shows.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("ActionBars")

local _G = _G

-- Clean up the pushed, hover, and checked textures so a button's interaction
-- states read the same everywhere: a soft square glow, gold on press, and a
-- gold outline while checked (active stance, toggled-on pet ability). Shared by
-- the LAB buttons and the stock buttons we reuse so both look identical.
function Module:StyleInteractionTextures(button)
	local pushed = button.GetPushedTexture and button:GetPushedTexture()
	if pushed then
		pushed:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		pushed:SetDesaturated(true)
		pushed:SetVertexColor(0.965, 0.769, 0.259)
		pushed:SetAllPoints(button)
		pushed:SetBlendMode("ADD")
	end
	local highlight = button.GetHighlightTexture and button:GetHighlightTexture()
	if highlight then
		highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		highlight:SetAllPoints(button)
		highlight:SetBlendMode("ADD")
	end
	local checked = button.GetCheckedTexture and button:GetCheckedTexture()
	if checked then
		checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
		checked:SetAllPoints(button)
		checked:SetBlendMode("ADD")
	end
end

-- Pet autocast ring. Blizzard's overlay is a fixed 28px frame with corner art
-- that pokes past our border and does not track the button size. Stretch the
-- ants to the icon and drop the corners so only the spinning ring shows.
function Module:SkinAutoCast(button)
	local overlay = button.AutoCastOverlay
	if not overlay then
		return
	end
	overlay:SetAllPoints(button)
	if overlay.Corners then
		overlay.Corners:SetAlpha(0)
	end
	if overlay.Shine then
		overlay.Shine:ClearAllPoints()
		overlay.Shine:SetPoint("TOPLEFT", button, "TOPLEFT", -3, 3)
		overlay.Shine:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 3, -3)
	end
end

-- Skin a stock Blizzard button (stance, extra, zone) with our slot + border,
-- for buttons we reuse rather than build through LibActionButton.
function Module:StyleAuxButton(button)
	if not button or button.__auxStyled then
		return
	end
	button.__auxStyled = true

	local name = button:GetName()
	local icon = button.icon or (name and _G[name .. "Icon"])
	local normal = button.GetNormalTexture and button:GetNormalTexture()

	if normal then
		normal:SetAlpha(0)
	end
	if button.SetNormalTexture then
		button:SetNormalTexture(0)
	end
	local floating = name and _G[name .. "FloatingBG"]
	if floating then
		floating:Hide()
	end
	if button.Flash then
		button.Flash:SetTexture(nil)
	end

	-- Pet and stance buttons inherit the 12.0 ActionButtonTemplate, so they carry
	-- the same leftover slot art the main buttons do. Hide it under our slot.
	if button.SlotArt then
		button.SlotArt:SetAlpha(0)
	end
	if button.SlotBackground then
		button.SlotBackground:SetAlpha(0)
	end

	if icon then
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	end

	local slot = button:CreateTexture(nil, "BACKGROUND", nil, -8)
	slot:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
	slot:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	slot:SetAtlas("UI-HUD-ActionBar-IconFrame-Slot")

	local cooldown = button.cooldown or (name and _G[name .. "Cooldown"])
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		K.StyleCooldownSwipe(cooldown)
	end

	self:StyleInteractionTextures(button)
	self:SkinAutoCast(button)

	K.CreateBorder(button)

	local hotkey = button.HotKey or (name and _G[name .. "HotKey"])
	if hotkey then
		self:StyleHotKey({ HotKey = hotkey })
	end
end

-- Build the LAB button config for a specific bar. Text visibility is per-bar.
-- The font and grid are global. Rebuilt each call so live edits take effect.
function Module:GetButtonConfig(key)
	local db = C.ActionBar
	local bar = db[key] or db.Bar1
	local font = K.GetFont(db.Font)
	local size = db.FontSize
	local flag = db.FontFlag ~= "NONE" and db.FontFlag or ""
	return {
		-- Cast on key down when enabled, otherwise on release.
		clickOnDown = db.KeyDown ~= false,
		showGrid = db.ShowGrid,
		outOfRangeColoring = db.RangeColoring or "button",
		-- Out-of-range and out-of-mana tints, tunable from the options.
		colors = {
			range = db.RangeColor or { 0.8, 0.1, 0.1 },
			mana = db.ManaColor or { 0.5, 0.5, 1.0 },
		},
		-- Register with the assisted-combat manager so the one-button rotation
		-- assistant can glow the next suggested ability on our buttons. The
		-- highlight only works when actionButtonUI is on, so both are set together.
		actionButtonUI = true,
		assistedHighlight = true,
		hideElements = {
			border = true,
			borderIfEmpty = true,
			macro = not bar.MacroName,
			hotkey = not bar.HotKey,
			equipped = false,
		},
		text = {
			hotkey = { font = { font = font, size = size, flags = flag } },
			count = { font = { font = font, size = size, flags = flag } },
			macro = { font = { font = font, size = size - 2, flags = flag } },
		},
	}
end

-- Apply our border and anchor the icon and text on a single LAB button.
function Module:StyleButton(button)
	if button.__styled then
		return
	end
	button.__styled = true

	local icon = button.icon
	local count = button.Count
	local hotkey = button.HotKey
	local macro = button.Name

	-- Backstop for the leftover slot art from the 12.0 ActionButtonTemplate,
	-- which LAB does not touch even with hideElements.border.
	if button.SlotArt then
		button.SlotArt:SetAlpha(0)
	end
	if button.SlotBackground then
		button.SlotBackground:SetAlpha(0)
	end

	-- Blizzard slot atlas as the button background. The atlas has transparent
	-- padding, so we stretch it a couple pixels past every edge to make the
	-- opaque art reach the button edges (any overshoot tucks under the border).
	local slot = button:CreateTexture(nil, "BACKGROUND", nil, -8)
	slot:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
	slot:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	slot:SetAtlas("UI-HUD-ActionBar-IconFrame-Slot")
	button.KKUI_Slot = slot

	-- Crop the icon inside our border and keep it above the slot art.
	if icon then
		icon:SetDrawLayer("ARTWORK")
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	end

	-- Cooldown: crop to the icon and make sure the dark radial swipe draws. The
	-- retail LibActionButton path only calls SetCooldownFromDurationObject and
	-- never sets the swipe, so a fresh cooldown frame can come up with no swipe.
	local cooldown = button.cooldown
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		K.StyleCooldownSwipe(cooldown)
	end

	-- Loss-of-control cooldown gets the same swipe in a dark red, for the wipe while
	-- you are crowd controlled.
	K.StyleCooldownSwipe(button.lossOfControlCooldown, 0.35, 0, 0)

	-- Clean interaction-state textures: pushed and hover glow, checked outline.
	self:StyleInteractionTextures(button)

	K.CreateBorder(button)

	-- Shorten the hotkey text and keep it shortened on rebind.
	Module:StyleHotKey(button)

	-- Text placement. LAB owns the fonts (from GetButtonConfig), we anchor.
	if count then
		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	end
	if hotkey then
		hotkey:ClearAllPoints()
		hotkey:SetPoint("TOPRIGHT", button, "TOPRIGHT", -2, -2)
	end
	if macro then
		macro:ClearAllPoints()
		macro:SetPoint("BOTTOM", button, "BOTTOM", 0, 2)
	end
end
