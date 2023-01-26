local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local keyButton = gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = gsub(KEY_NUMPAD1, "%d", "")

local replaces = {
	{ "(" .. keyButton .. ")", "M" },
	{ "(" .. keyNumpad .. ")", "N" },
	{ "(a%-)", "a" },
	{ "(c%-)", "c" },
	{ "(s%-)", "s" },
	{ KEY_BUTTON3, "M3" },
	{ KEY_MOUSEWHEELUP, "MU" },
	{ KEY_MOUSEWHEELDOWN, "MD" },
	{ KEY_SPACE, "Sp" },
	{ "CAPSLOCK", "CL" },
	{ "Capslock", "CL" },
	{ "BUTTON", "M" },
	{ "NUMPAD", "N" },
	{ "(ALT%-)", "a" },
	{ "(CTRL%-)", "c" },
	{ "(SHIFT%-)", "s" },
	{ "MOUSEWHEELUP", "MU" },
	{ "MOUSEWHEELDOWN", "MD" },
	{ "SPACE", "Sp" },
}

function Module:UpdateHotKey()
	local text = self:GetText()
	if not text then
		return
	end

	if text == RANGE_INDICATOR then
		text = ""
	else
		for _, value in pairs(replaces) do
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
		autoCastable:SetAllPoints()
	end

	if icon then
		icon:SetAllPoints()
		if not icon.__lockdown then
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		end
		button.__bg = CreateFrame("Frame", nil, button, "BackdropTemplate")
		button.__bg:SetAllPoints(button)
		button.__bg:SetFrameLevel(button:GetFrameLevel())
		button.__bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, 0.7, 0.7, 0.7)
	end
	if cooldown then
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
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
	--petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		Module:StyleActionButton(_G["PetActionButton" .. i])
	end
	--stancebar buttons
	for i = 1, 10 do
		Module:StyleActionButton(_G["StanceButton" .. i])
	end
	--leave vehicle
	Module:StyleActionButton(_G["KKUI_LeaveVehicleButton"])
	--extra action button
	Module:StyleActionButton(ExtraActionButton1)
	--spell flyout
	SpellFlyout.Background:SetAlpha(0)
	local numFlyouts = 1
	local function checkForFlyoutButtons()
		local button = _G["SpellFlyoutButton" .. numFlyouts]
		while button do
			Module:StyleActionButton(button)
			numFlyouts = numFlyouts + 1
			button = _G["SpellFlyoutButton" .. numFlyouts]
		end
	end
	SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
	SpellFlyout:HookScript("OnHide", checkForFlyoutButtons)
end
