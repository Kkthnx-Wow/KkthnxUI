local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local next = _G.next
local string_gsub = _G.string.gsub
local unpack = _G.unpack

local GetBindingKey = _G.GetBindingKey
local hooksecurefunc = _G.hooksecurefunc

local function CallButtonFunctionByName(button, func, ...)
	if button and func and button[func] then
		button[func](button, ...)
	end
end

local function ResetNormalTexture(self, file)
	if not self.__normalTextureFile then
		return
	end

	if file == self.__normalTextureFile then
		return
	end

	self:SetNormalTexture(self.__normalTextureFile)
end

local function ResetTexture(self, file)
	if not self.__textureFile then
		return
	end

	if file == self.__textureFile then
		return
	end

	self:SetTexture(self.__textureFile)
end

local function ResetVertexColor(self, r, g, b, a)
	if not self.__vertexColor then
		return
	end

	local r2, g2, b2, a2 = unpack(self.__vertexColor)
	if not a2 then
		a2 = 1
	end

	if r ~= r2 or g ~= g2 or b ~= b2 or a ~= a2 then
		self:SetVertexColor(r2, g2, b2, a2)
	end
end

local function ApplyPoints(self, points)
	if not points then
		return
	end

	self:ClearAllPoints()
	for _, point in next, points do
		self:SetPoint(unpack(point))
	end
end

local function ApplyTexCoord(texture, texCoord)
	if texture.__lockdown or not texCoord then
		return
	end

	texture:SetTexCoord(unpack(texCoord))
end

local function ApplyVertexColor(texture, color)
	if not color then
		return
	end

	texture.__vertexColor = color
	texture:SetVertexColor(unpack(color))
	hooksecurefunc(texture, "SetVertexColor", ResetVertexColor)
end

local function ApplyAlpha(region, alpha)
	if not alpha then
		return
	end

	region:SetAlpha(alpha)
end

local function ApplyFont(fontString, font)
	if not font then
		return
	end

	fontString:SetFontObject(font)
end

local function ApplyHorizontalAlign(fontString, align)
	if not align then
		return
	end

	fontString:SetJustifyH(align)
end

local function ApplyVerticalAlign(fontString, align)
	if not align then
		return
	end

	fontString:SetJustifyV(align)
end

local function ApplyTexture(texture, file)
	if not file then
		return
	end

	texture.__textureFile = file
	texture:SetTexture(file)
	hooksecurefunc(texture, "SetTexture", ResetTexture)
end

local function ApplyNormalTexture(button, file)
	if not file then
		return
	end

	button.__normalTextureFile = file
	button:SetNormalTexture(file)
	hooksecurefunc(button, "SetNormalTexture", ResetNormalTexture)
end

local function SetupTexture(texture, cfg, func, button)
	if not texture or not cfg then
		return
	end

	ApplyTexCoord(texture, cfg.texCoord)
	ApplyPoints(texture, cfg.points)
	ApplyVertexColor(texture, cfg.color)
	ApplyAlpha(texture, cfg.alpha)

	if func == "SetTexture" then
		ApplyTexture(texture, cfg.file)
	elseif func == "SetNormalTexture" then
		ApplyNormalTexture(button, cfg.file)
	elseif cfg.file then
		CallButtonFunctionByName(button, func, cfg.file)
	end
end

local function SetupFontString(fontString, cfg)
	if not fontString or not cfg then
		return
	end

	ApplyPoints(fontString, cfg.points)
	ApplyFont(fontString, cfg.font)
	ApplyAlpha(fontString, cfg.alpha)
	ApplyHorizontalAlign(fontString, cfg.halign)
	ApplyVerticalAlign(fontString, cfg.valign)
end

local function SetupCooldown(cooldown, cfg)
	if not cooldown or not cfg then
		return
	end

	ApplyPoints(cooldown, cfg.points)
end

local keyButton = string_gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = string_gsub(KEY_NUMPAD1, "%d", "")
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
	{ CAPSLOCK_KEY_TEXT, "CL" },
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
	local hotkey = _G[self:GetName() .. "HotKey"]
	if hotkey and hotkey:IsShown() and not C["ActionBar"].Hotkey then
		hotkey:Hide()
		return
	end

	local text = hotkey:GetText()
	if not text then
		return
	end

	for _, value in pairs(replaces) do
		text = string_gsub(text, value[1], value[2])
	end

	if text == RANGE_INDICATOR then
		hotkey:SetText("")
	else
		hotkey:SetText(text)
	end
end

function Module:HookHotKey(button)
	Module.UpdateHotKey(button)
	if button.UpdateHotkeys then
		hooksecurefunc(button, "UpdateHotkeys", Module.UpdateHotKey)
	end
end

function Module:UpdateEquipItemColor()
	if not self.KKUI_Border then
		return
	end

	if IsEquippedAction(self.action) then
		self.KKUI_Border:SetVertexColor(0, 0.7, 0.1)
	else
		if C["General"].ColorTextures then
			self.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		else
			self.KKUI_Border:SetVertexColor(1, 1, 1)
		end
	end
end

function Module:EquipItemColor(button)
	if not button.Update then
		return
	end
	hooksecurefunc(button, "Update", Module.UpdateEquipItemColor)
end

function Module:StyleActionButton(button, cfg)
	if not button then
		return
	end

	if button.__styled then
		return
	end

	local buttonName = button:GetName()
	local icon = _G[buttonName .. "Icon"]
	local flash = _G[buttonName .. "Flash"]
	local flyoutBorder = _G[buttonName .. "FlyoutBorder"]
	local flyoutBorderShadow = _G[buttonName .. "FlyoutBorderShadow"]
	local flyoutArrow = _G[buttonName .. "FlyoutArrow"]
	local hotkey = _G[buttonName .. "HotKey"]
	local count = _G[buttonName .. "Count"]
	local name = _G[buttonName .. "Name"]
	local border = _G[buttonName .. "Border"]
	local autoCastable = _G[buttonName .. "AutoCastable"]
	local NewActionTexture = button.NewActionTexture
	local cooldown = _G[buttonName .. "Cooldown"]
	local normalTexture = button:GetNormalTexture()
	local pushedTexture = button:GetPushedTexture()
	local highlightTexture = button:GetHighlightTexture()

	-- Normal buttons do not have a checked texture, but checkbuttons do and normal actionbuttons are checkbuttons
	local checkedTexture
	if button.GetCheckedTexture then
		checkedTexture = button:GetCheckedTexture()
	end

	-- Pet stuff
	local petShine = _G[buttonName .. "Shine"]
	if petShine then
		petShine:SetAllPoints()
	end

	-- Hide stuff
	local floatingBG = _G[buttonName .. "FloatingBG"]
	if floatingBG then
		floatingBG:Hide()
	end

	if NewActionTexture then
		NewActionTexture:SetTexture(nil)
	end

	if flyoutArrow then
		flyoutArrow:SetDrawLayer("OVERLAY", 5)
	end

	-- Backdrop
	button:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, 1, 1, 1)
	button:StyleButton()
	Module:EquipItemColor(button)

	-- Textures
	SetupTexture(icon, cfg.icon, "SetTexture", icon)
	SetupTexture(flash, cfg.flash, "SetTexture", flash)
	SetupTexture(flyoutBorder, cfg.flyoutBorder, "SetTexture", flyoutBorder)
	SetupTexture(flyoutBorderShadow, cfg.flyoutBorderShadow, "SetTexture", flyoutBorderShadow)
	SetupTexture(border, cfg.border, "SetTexture", border)
	SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
	SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
	SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
	if checkedTexture then
		SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)
	end

	-- Cooldown
	SetupCooldown(cooldown, cfg.cooldown)

	-- No clue why but blizzard created count and duration on background layer, need to fix that
	local overlay = CreateFrame("Frame", nil, button)
	overlay:SetAllPoints()

	if count then
		if C["ActionBar"].Count then
			count:SetParent(overlay)
			SetupFontString(count, cfg.count)
		else
			count:Hide()
		end
	end

	if hotkey then
		hotkey:SetParent(overlay)
		Module:HookHotKey(button)
		SetupFontString(hotkey, cfg.hotkey)
	end

	if name then
		if C["ActionBar"].Macro then
			name:SetParent(overlay)
			SetupFontString(name, cfg.name)
		else
			name:Hide()
		end
	end

	if autoCastable then
		autoCastable:SetTexCoord(0.217, 0.765, 0.217, 0.765)
		autoCastable:SetAllPoints()
		autoCastable:SetDrawLayer("OVERLAY", 5)
	end

	Module:RegisterButtonRange(button)

	button.__styled = true
end

function Module:StyleExtraActionButton(cfg)
	local button = ExtraActionButton1
	if button.__styled then
		return
	end

	local buttonName = button:GetName()
	local icon = _G[buttonName .. "Icon"]
	local hotkey = _G[buttonName .. "HotKey"]
	local count = _G[buttonName .. "Count"]
	local buttonstyle = button.style -- Artwork around the button
	local cooldown = _G[buttonName .. "Cooldown"]

	local normalTexture = button:GetNormalTexture()
	local pushedTexture = button:GetPushedTexture()
	local highlightTexture = button:GetHighlightTexture()
	local checkedTexture = button:GetCheckedTexture()

	-- Border
	button:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, 1, 1, 1)
	button:StyleButton()

	-- Textures
	SetupTexture(icon, cfg.icon, "SetTexture", icon)
	SetupTexture(buttonstyle, cfg.buttonstyle, "SetTexture", buttonstyle)
	SetupTexture(normalTexture, cfg.normalTexture, "SetNormalTexture", button)
	SetupTexture(pushedTexture, cfg.pushedTexture, "SetPushedTexture", button)
	SetupTexture(highlightTexture, cfg.highlightTexture, "SetHighlightTexture", button)
	SetupTexture(checkedTexture, cfg.checkedTexture, "SetCheckedTexture", button)

	-- Cooldown
	SetupCooldown(cooldown, cfg.cooldown)

	-- Hotkey & Count
	local overlay = CreateFrame("Frame", nil, button)
	overlay:SetAllPoints()

	local hotcountFont = K.UIFontOutline
	hotkey:SetParent(overlay)
	Module:HookHotKey(button)
	cfg.hotkey.font = hotcountFont
	SetupFontString(hotkey, cfg.hotkey)

	if C["ActionBar"].Count then
		count:SetParent(overlay)
		cfg.count.font = hotcountFont
		SetupFontString(count, cfg.count)
	else
		count:Hide()
	end

	Module:RegisterButtonRange(button)

	button.__styled = true
end

function Module:UpdateStanceHotKey()
	for i = 1, NUM_STANCE_SLOTS do
		_G["StanceButton" .. i .. "HotKey"]:SetText(GetBindingKey("SHAPESHIFTBUTTON" .. i))
		Module:HookHotKey(_G["StanceButton" .. i])
	end
end

function Module:StyleAllActionButtons(cfg)
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		Module:StyleActionButton(_G["ActionButton" .. i], cfg)
		Module:StyleActionButton(_G["MultiBarBottomLeftButton" .. i], cfg)
		Module:StyleActionButton(_G["MultiBarBottomRightButton" .. i], cfg)
		Module:StyleActionButton(_G["MultiBarRightButton" .. i], cfg)
		Module:StyleActionButton(_G["MultiBarLeftButton" .. i], cfg)
		Module:StyleActionButton(_G["KKUI_ActionBarXButton" .. i], cfg)
	end

	for i = 1, 6 do
		Module:StyleActionButton(_G["OverrideActionBarButton" .. i], cfg)
	end

	-- Petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		Module:StyleActionButton(_G["PetActionButton" .. i], cfg)
	end

	-- Stancebar buttons
	for i = 1, NUM_STANCE_SLOTS do
		Module:StyleActionButton(_G["StanceButton" .. i], cfg)
	end

	-- Possess buttons
	for i = 1, NUM_POSSESS_SLOTS do
		Module:StyleActionButton(_G["PossessButton" .. i], cfg)
	end

	-- Leave Vehicle
	Module:StyleActionButton(_G["KKUI_LeaveVehicleButton"], cfg)

	-- Extra action button
	Module:StyleExtraActionButton(cfg)

	-- Spell flyout
	SpellFlyoutBackgroundEnd:SetTexture(nil)
	SpellFlyoutHorizontalBackground:SetTexture(nil)
	SpellFlyoutVerticalBackground:SetTexture(nil)
	local function checkForFlyoutButtons()
		local i = 1
		local button = _G["SpellFlyoutButton" .. i]
		while button and button:IsShown() do
			Module:StyleActionButton(button, cfg)
			i = i + 1
			button = _G["SpellFlyoutButton" .. i]
		end
	end

	SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
end

function Module:CreateBarSkin()
	local cfgFont = K.UIFontOutline
	local cfg = {
		icon = {
			texCoord = K.TexCoords,
		},

		flyoutBorder = {
			file = "",
		},

		flyoutBorderShadow = {
			file = "",
		},

		border = {
			file = "",
		},

		normalTexture = {
			file = "",
		},

		-- flash = {
		-- 	file = "",
		-- },

		-- pushedTexture = {
		-- 	file = "",
		-- },

		-- checkedTexture = {
		-- 	file = "",
		-- },

		-- highlightTexture = {
		-- 	file = "",
		-- },

		-- cooldown = {
		-- 	points = {
		-- 		{ "TOPLEFT", 1, -1 },
		-- 		{ "BOTTOMRIGHT", -1, 1 },
		-- 	},
		-- },

		name = {
			font = cfgFont,
			points = {
				{ "BOTTOMLEFT", 0, 0 },
				{ "BOTTOMRIGHT", 0, 0 },
			},
		},

		hotkey = {
			font = cfgFont,
			points = {
				{ "TOPRIGHT", 0, -3 },
				{ "TOPLEFT", 0, -3 },
			},
		},

		count = {
			font = cfgFont,
			points = {
				{ "BOTTOMRIGHT", 2, 0 },
			},
		},

		buttonstyle = {
			file = "",
		},
	}

	Module:StyleAllActionButtons(cfg)

	-- Update hotkeys
	hooksecurefunc("PetActionButton_SetHotkeys", Module.UpdateHotKey)
	Module:UpdateStanceHotKey()
	K:RegisterEvent("UPDATE_BINDINGS", Module.UpdateStanceHotKey)
end
