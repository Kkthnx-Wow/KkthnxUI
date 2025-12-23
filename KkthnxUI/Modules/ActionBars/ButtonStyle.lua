local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

-- 1. Define Localized Globals (Cache them to avoid nil errors if WoW changes keys)
-- We use "or" to fallback to English if the Global is missing in a specific client version.
local L_BUTTON = _G.KEY_BUTTON3:gsub("3", "") or "Button"
local L_MOUSEWHEELUP = _G.KEY_MOUSEWHEELUP or "Mouse Wheel Up"
local L_MOUSEWHEELDN = _G.KEY_MOUSEWHEELDOWN or "Mouse Wheel Down"
local L_NUMPAD = _G.KEY_NUMPAD0:gsub("0", "") or "Num Pad"
local L_PAGEUP = _G.KEY_PAGEUP or "Page Up"
local L_PAGEDOWN = _G.KEY_PAGEDOWN or "Page Down"
local L_SPACE = _G.KEY_SPACE or "Space"
local L_INSERT = _G.KEY_INSERT or "Insert"
local L_HOME = _G.KEY_HOME or "Home"
local L_DELETE = _G.KEY_DELETE or "Delete"

-- 2. The Master Replacement Table
-- Ordered specifically: Modifiers first, then specific keys, then generic patterns.
local replacements = {
	-- >> Modifiers (Handle various casings and localized formats)
	{ "(CTRL%-)", "c" },
	{ "(Ctrl%-)", "c" },
	{ "(ALT%-)", "a" },
	{ "(Alt%-)", "a" },
	{ "(SHIFT%-)", "s" },
	{ "(Shift%-)", "s" },
	{ "(META%-)", "m" }, -- macOS Command Key
	{ "(Meta%-)", "m" },

	-- >> Mouse (Localized & English)
	{ L_MOUSEWHEELUP, "MU" },
	{ "MOUSEWHEELUP", "MU" },
	{ L_MOUSEWHEELDN, "MD" },
	{ "MOUSEWHEELDOWN", "MD" },
	{ L_BUTTON, "M" }, -- Localized "Button"
	{ "BUTTON", "M" }, -- English "BUTTON"

	-- >> Navigation & Editing (The missing items)
	{ L_PAGEUP, "PU" },
	{ "PAGEUP", "PU" },
	{ L_PAGEDOWN, "PD" },
	{ "PAGEDOWN", "PD" },
	{ L_HOME, "Hm" },
	{ "HOME", "Hm" },
	{ "END", "End" }, -- Usually same in Locales, but safe to keep
	{ L_INSERT, "Ins" },
	{ "INSERT", "Ins" },
	{ L_DELETE, "Del" },
	{ "DELETE", "Del" },
	{ "BACKSPACE", "BS" },
	{ "Backspace", "BS" },
	{ "TAB", "Tab" },
	{ "ESCAPE", "Esc" },

	-- >> Special Keys
	{ L_SPACE, "Sp" },
	{ "SPACE", "Sp" },
	{ "CAPSLOCK", "CL" },
	{ "Capslock", "CL" },
	{ "NUMLOCK", "NL" },
	{ "Num Lock", "NL" },

	-- >> Numpad Cleanup (Specific operators first, then generic)
	{ "NUMPADDIVIDE", "N/" },
	{ "NUMPADMULTIPLY", "N*" },
	{ "NUMPADPLUS", "N+" },
	{ "NUMPADMINUS", "N-" },
	{ L_NUMPAD, "N" }, -- Localized "Num Pad"
	{ "NUMPAD", "N" }, -- English "NUMPAD"
}

function Module:UpdateHotKey()
	local text = self:GetText()
	if not text then
		return
	end

	if text == RANGE_INDICATOR then
		text = ""
	else
		for _, value in pairs(replacements) do
			text = gsub(text, value[1], value[2])
		end
	end
	self:SetFormattedText("%s", text)
end

function Module:UpdateBarBorderColor(button)
	if not button.__bg then
		return
	end

	if button.Border:IsShown() then
		button.__bg.KKUI_Border:SetVertexColor(0, 0.7, 0.1)
	else
		K.SetBorderColor(button.__bg.KKUI_Border)
	end
end

function Module:StyleActionButton(button)
	if not button then
		return
	end

	if button.__styled then
		return
	end

	local buttonName = button:GetName()
	local icon = button.icon
	local cooldown = button.cooldown
	local hotkey = button.HotKey
	local count = button.Count
	local name = button.Name
	local flash = button.Flash
	local border = button.Border
	local normal = button.NormalTexture
	local normal2 = button:GetNormalTexture()
	local slotbg = button.SlotBackground
	local pushed = button.PushedTexture
	local checked = button.CheckedTexture
	local highlight = button.HighlightTexture
	local newActionTexture = button.NewActionTexture
	local spellHighlight = button.SpellHighlightTexture
	local iconMask = button.IconMask
	local petShine = _G[buttonName .. "Shine"]
	local autoCastable = button.AutoCastable

	if normal then
		normal:SetAlpha(0)
	end

	if normal2 then
		normal2:SetAlpha(0)
	end

	if flash then
		flash:SetTexture(nil)
	end

	if newActionTexture then
		newActionTexture:SetTexture(nil)
	end

	if border then
		border:SetTexture(nil)
	end

	if slotbg then
		slotbg:Hide()
	end

	if iconMask then
		iconMask:Hide()
	end

	if button.style then
		button.style:SetAlpha(0)
	end

	if petShine then
		petShine:SetAllPoints()
	end

	if autoCastable then
		autoCastable:SetTexCoord(0.217, 0.765, 0.217, 0.765)
		autoCastable:SetDrawLayer("OVERLAY", 3)
		autoCastable:SetAllPoints()
	end

	if icon then
		icon:SetAllPoints()
		if not icon.__lockdown then
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		end

		if not button.__bg then
			button.__bg = CreateFrame("Frame", nil, button, "BackdropTemplate")
			button.__bg:SetAllPoints(button)
			button.__bg:SetFrameLevel(button:GetFrameLevel())
			button.__bg:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, { 1, 1, 1 })
		end
	end

	if cooldown then
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	end

	if pushed then
		pushed:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		pushed:SetDesaturated(true)
		pushed:SetVertexColor(246 / 255, 196 / 255, 66 / 255)
		pushed:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -0)
		pushed:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -0, 0)
		pushed:SetBlendMode("ADD")
	end

	if checked then
		checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
		checked:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -0)
		checked:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -0, 0)
		checked:SetBlendMode("ADD")
	end

	if highlight then
		highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -0)
		highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -0, 0)
		highlight:SetBlendMode("ADD")
	end

	if spellHighlight then
		spellHighlight:SetAllPoints()
	end

	if hotkey then
		Module.UpdateHotKey(hotkey)
		hooksecurefunc(hotkey, "SetText", Module.UpdateHotKey)
	end

	button.__styled = true
end

function Module:ReskinBars()
	for i = 1, 8 do
		for j = 1, 12 do
			Module:StyleActionButton(_G["KKUI_ActionBar" .. i .. "Button" .. j])
		end
	end

	-- petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		Module:StyleActionButton(_G["PetActionButton" .. i])
	end

	-- stancebar buttons
	for i = 1, 10 do
		Module:StyleActionButton(_G["StanceButton" .. i])
	end

	-- leave vehicle
	Module:StyleActionButton(_G["KKUI_LeaveVehicleButton"])

	-- extra action button
	Module:StyleActionButton(ExtraActionButton1)

	-- spell flyout
	SpellFlyout.Background:SetAlpha(0)
	local numFlyouts = 1
	local function checkForFlyoutButtons()
		local button = _G["SpellFlyoutPopupButton" .. numFlyouts]
		while button do
			Module:StyleActionButton(button)
			numFlyouts = numFlyouts + 1
			button = _G["SpellFlyoutPopupButton" .. numFlyouts]
		end
	end
	SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
	SpellFlyout:HookScript("OnHide", checkForFlyoutButtons)
end
