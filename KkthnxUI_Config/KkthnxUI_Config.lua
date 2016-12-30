-- GUI for KkthnxUI (by Fernir, Shestak Tukz and Tohveli)

-- Lua API
local _G = _G
local format = string.format
local pairs = pairs
local print = print
local tinsert = tinsert
local tonumber = tonumber
local tostring = tostring
local tsort = table.sort
local type = type
local unpack = unpack

-- Wow API
local CreateFrame = CreateFrame
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local HideUIPanel = HideUIPanel
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local PlaySound = PlaySound
local ReloadUI = ReloadUI
local StaticPopup_Show = StaticPopup_Show
local UIParent = UIParent

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CreateUIConfig, SLASH_CONFIG1, SLASH_CONFIG2, SLASH_CONFIG3, SLASH_CONFIG4
-- GLOBALS: KkthnxUIConfigAll, UIConfigCover, KkthnxUIConfigPublic, KkthnxUIConfigPrivate, UIConfig
-- GLOBALS: KkthnxUIDataPerChar, KkthnxUI, UIConfigGroupSlider, Print, UIConfigMain, UISpecialFrames
-- GLOBALS: OpacitySliderFrame, Error, GameMenuFrame, GameMenuButtonLogout, GameMenuButtonAddons
-- GLOBALS: SLASH_CONFIG5, SLASH_RESETCONFIG1, UIConfigLocal, Aurora, KkthnxUIConfigAllCharacters
-- GLOBALS: UIConfigGroup, GameFontHighlight, OKAY, colorbuttonname, COLOR, DEFAULT, loaded, ColorPickerFrame

local locale = GetLocale()
local name = UnitName("player")
local realm = GetRealmName()

if (locale == "enGB") then locale = "enUS" end

Print = function(...) print("|cff3c9bedKkthnxUI_Config|r:", ...) end

local ALLOWED_GROUPS = {
	["General"] = 1,
	["ActionBar"] = 2,
	["Announcements"] = 3,
	["Auras"] = 4,
	["Automation"] = 5,
	["Bags"] = 6,
	["Blizzard"] = 7,
	["Chat"] = 8,
	["Cooldown"] = 9,
	["DataBars"] = 10,
	["DataText"] = 11,
	["Error"] = 12,
	["Filger"] = 13,
	["Loot"] = 14,
	["Minimap"] = 15,
	["Misc"] = 16,
	["Nameplates"] = 17,
	["PulseCD"] = 18,
	["RaidCD"] = 19,
	["Raidframe"] = 20,
	["Skins"] = 21,
	["Tooltip"] = 22,
	["Unitframe"] = 23,
	["WorldMap"] = 24,
}

local function Local(o)
	local string = o
	for option, value in pairs(UIConfigLocal) do
		if option == o then string = value end
	end
	return string
end

local NewButton = function(text, parent)
	local K, C, L = unpack(KkthnxUI)

	local result = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	local label = result:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetText(text)
	result:SetWidth(label:GetWidth())
	result:SetHeight(label:GetHeight())
	result:SetFontString(label)
	result:SetNormalTexture("")
	result:SetHighlightTexture("")
	result:SetPushedTexture("")
	result.Left:SetAlpha(0)
	result.Right:SetAlpha(0)
	result.Middle:SetAlpha(0)

	return result
end

local NormalButton = function(text, parent)
	local K, C, L = unpack(KkthnxUI)

	local result = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	local label = result:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetJustifyH("LEFT")
	label:SetText(text)
	result:SetSize(100, 23)
	result:SetFontString(label)
	if IsAddOnLoaded("Aurora") then
		local F = unpack(Aurora)
		F.Reskin(result)
	else
		result:SkinButton()
	end

	return result
end

StaticPopupDialogs.PERCHAR = {
	text = UIConfigLocal.ConfigPerChar,
	OnAccept = function()
		if KkthnxUIConfigAllCharacters:GetChecked() then
			KkthnxUIConfigAll[realm][name] = true
		else
			KkthnxUIConfigAll[realm][name] = false
		end
		ReloadUI()
	end,
	OnCancel = function()
		UIConfigCover:Hide()
		if KkthnxUIConfigAllCharacters:GetChecked() then
			KkthnxUIConfigAllCharacters:SetChecked(false)
		else
			KkthnxUIConfigAllCharacters:SetChecked(true)
		end
	end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs.RESET_PERCHAR = {
	text = UIConfigLocal.ConfigResetChar,
	OnAccept = function()
		KkthnxUIConfigPrivate = KkthnxUIConfigPublic
		ReloadUI()
	end,
	OnCancel = function() if UIConfig and UIConfig:IsShown() then UIConfigMain:Hide() end end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs.RESET_ALL = {
	text = UIConfigLocal.ConfigResetAll,
	OnAccept = function()
		KkthnxUIConfigPublic = nil
		KkthnxUIConfigPrivate = nil
		ReloadUI()

		KkthnxUIDataPerChar.Install = false
	end,
	OnCancel = function() UIConfigMain:Hide() end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

local function SetValue(group, option, value)
	local mergesettings
	if KkthnxUIConfigPrivate == KkthnxUIConfigPublic then
		mergesettings = true
	else
		mergesettings = false
	end

	if KkthnxUIConfigAll[realm][name] == true then
		if not KkthnxUIConfigPrivate then KkthnxUIConfigPrivate = {} end
		if not KkthnxUIConfigPrivate[group] then KkthnxUIConfigPrivate[group] = {} end
		KkthnxUIConfigPrivate[group][option] = value
	else
		if mergesettings == true then
			if not KkthnxUIConfigPrivate then KkthnxUIConfigPrivate = {} end
			if not KkthnxUIConfigPrivate[group] then KkthnxUIConfigPrivate[group] = {} end
			KkthnxUIConfigPrivate[group][option] = value
		end

		if not KkthnxUIConfigPublic then KkthnxUIConfigPublic = {} end
		if not KkthnxUIConfigPublic[group] then KkthnxUIConfigPublic[group] = {} end
		KkthnxUIConfigPublic[group][option] = value
	end
end

local VISIBLE_GROUP = nil
local lastbutton = nil
local function ShowGroup(group, button)
	local K, C, L = unpack(KkthnxUI)

	if lastbutton then lastbutton:SetText(lastbutton:GetText().sub(lastbutton:GetText(), 11, -3)) end
	if VISIBLE_GROUP then _G["UIConfig"..VISIBLE_GROUP]:Hide() end

	if _G["UIConfig"..group] then
		local o = "UIConfig"..group
		local translate = Local(group)
		_G["UIConfigTitle"]:SetText(translate)

		local height = _G["UIConfig"..group]:GetHeight()
		_G["UIConfig"..group]:Show()

		local scrollamntmax = 305
		local scrollamntmin = scrollamntmax - 10
		local max = height > scrollamntmax and height-scrollamntmin or 1

		if max == 1 then
			_G["UIConfigGroupSlider"]:SetValue(1)
			_G["UIConfigGroupSlider"]:Hide()
		else
			_G["UIConfigGroupSlider"]:SetMinMaxValues(0, max)
			_G["UIConfigGroupSlider"]:Show()
			_G["UIConfigGroupSlider"]:SetValue(1)
		end

		_G["UIConfigGroup"]:SetScrollChild(_G["UIConfig"..group])

		local x
		if UIConfigGroupSlider:IsShown() then
			_G["UIConfigGroup"]:EnableMouseWheel(true)
			_G["UIConfigGroup"]:SetScript("OnMouseWheel", function(self, delta)
				if UIConfigGroupSlider:IsShown() then
					if delta == -1 then
						x = _G["UIConfigGroupSlider"]:GetValue()
						_G["UIConfigGroupSlider"]:SetValue(x + 10)
					elseif delta == 1 then
						x = _G["UIConfigGroupSlider"]:GetValue()
						_G["UIConfigGroupSlider"]:SetValue(x - 30)
					end
				end
			end)
		else
			_G["UIConfigGroup"]:EnableMouseWheel(false)
		end

		VISIBLE_GROUP = group
		lastbutton = button
	end
end

local Loaded
function CreateUIConfig()
	if InCombatLockdown() and not Loaded then Print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
	local K, C, L = unpack(KkthnxUI)

	if UIConfigMain then
		ShowGroup("General")
		UIConfigMain:Show()
		return
	end

	-- Main Frame
	local UIConfigMain = CreateFrame("Frame", "UIConfigMain", UIParent)
	UIConfigMain:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 200)
	UIConfigMain:SetSize(780, 482)
	UIConfigMain:SetBackdrop(K.Backdrop)
	UIConfigMain:SetBackdropColor(.05, .05, .05)
	UIConfigMain:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
	UIConfigMain:SetFrameStrata("DIALOG")
	UIConfigMain:SetFrameLevel(20)
	UIConfigMain:EnableMouse(true)
	UIConfigMain:SetScript("OnMouseDown", function() UIConfigMain:StartMoving() end)
	UIConfigMain:SetScript("OnMouseUp", function() UIConfigMain:StopMovingOrSizing() end)
	UIConfigMain:SetClampedToScreen(true)
	UIConfigMain:SetMovable(true)
	tinsert(UISpecialFrames, "UIConfigMain")

	-- Version Title
	local TitleBoxVer = CreateFrame("Frame", "TitleBoxVer", UIConfigMain)
	TitleBoxVer:SetSize(180, 28)
	TitleBoxVer:SetPoint("TOPLEFT", UIConfigMain, "TOPLEFT", 23, -15)

	local TitleBoxVerText = TitleBoxVer:CreateFontString("UIConfigTitleVer", "OVERLAY", "GameFontNormal")
	TitleBoxVerText:SetPoint("CENTER")
	TitleBoxVerText:SetText("|cff3c9bedKkthnxUI|r "..K.Version)

	-- Main Frame Title
	local TitleBox = CreateFrame("Frame", "TitleBox", UIConfigMain)
	TitleBox:SetSize(540, 28)
	TitleBox:SetPoint("TOPLEFT", TitleBoxVer, "TOPRIGHT", 15, 0)

	local TitleBoxText = TitleBox:CreateFontString("UIConfigTitle", "OVERLAY", "GameFontNormal")
	TitleBoxText:SetPoint("LEFT", TitleBox, "LEFT", 15, 0)

	-- Options Frame
	local UIConfig = CreateFrame("Frame", "UIConfig", UIConfigMain)
	UIConfig:SetPoint("TOPLEFT", TitleBox, "BOTTOMLEFT", 10, -15)
	UIConfig:SetSize(520, 400)

	local UIConfigBG = CreateFrame("Frame", "UIConfigBG", UIConfig)
	UIConfigBG:SetPoint("TOPLEFT", -10, 10)
	UIConfigBG:SetPoint("BOTTOMRIGHT", 10, -10)

	-- Group Frame
	local groups = CreateFrame("ScrollFrame", "UIConfigCategoryGroup", UIConfig)
	groups:SetPoint("TOPLEFT", TitleBoxVer, "BOTTOMLEFT", 10, -15)
	groups:SetSize(160, 400)

	local groupsBG = CreateFrame("Frame", "groupsBG", UIConfig)
	groupsBG:SetPoint("TOPLEFT", groups, -10, 10)
	groupsBG:SetPoint("BOTTOMRIGHT", groups, 10, -10)

	local UIConfigCover = CreateFrame("Frame", "UIConfigCover", UIConfigMain)
	UIConfigCover:SetPoint("TOPLEFT", 0, 0)
	UIConfigCover:SetPoint("BOTTOMRIGHT", 0, 0)
	UIConfigCover:SetFrameLevel(UIConfigMain:GetFrameLevel() + 20)
	UIConfigCover:EnableMouse(true)
	UIConfigCover:SetScript("OnMouseDown", function(self) print(UIConfigLocal.MakeSelection) end)
	UIConfigCover:Hide()

	-- Group Scroll
	local slider = CreateFrame("Slider", "UIConfigCategorySlider", groups)
	slider:SetPoint("TOPRIGHT", 0, 0)
	slider:SetSize(24, 400)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetOrientation("VERTICAL")
	slider:CreateBackdrop(4)
	local r, g, b, a = unpack(C.Media.Backdrop_Color)
	slider:SetBackdropColor(r, g, b, a)
	slider:SetValueStep(20)
	slider:SetScript("OnValueChanged", function(self, value) groups:SetVerticalScroll(value) end)

	local function sortMyTable(a, b)
		return ALLOWED_GROUPS[a] < ALLOWED_GROUPS[b]
	end
	local function pairsByKey(t, f)
		local a = {}
		for n in pairs(t) do tinsert(a, n) end
		tsort(a, sortMyTable)
		local i = 0
		local iter = function()
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
		return iter
	end

	local GetOrderedIndex = function(t)
		local OrderedIndex = {}

		for key in pairs(t) do tinsert(OrderedIndex, key) end
		tsort(OrderedIndex)
		return OrderedIndex
	end

	local OrderedNext = function(t, state)
		local Key

		if (state == nil) then
			t.OrderedIndex = GetOrderedIndex(t)
			Key = t.OrderedIndex[1]
			return Key, t[Key]
		end

		Key = nil
		for i = 1, #t.OrderedIndex do
			if (t.OrderedIndex[i] == state) then Key = t.OrderedIndex[i + 1] end
		end

		if Key then return Key, t[Key] end
		t.OrderedIndex = nil
		return
	end

	local PairsByKeys = function(t) return OrderedNext, t, nil end

	local child = CreateFrame("Frame", nil, groups)
	child:SetPoint("TOPLEFT")
	local offset = 5
	for i in pairsByKey(ALLOWED_GROUPS) do
		local o = "UIConfig"..i
		local translate = Local(i)
		local button = NewButton(translate, child)
		button:SetSize(125, 16)
		button:SetPoint("TOPLEFT", 5, -offset)
		button:SetScript("OnClick", function(self) ShowGroup(i, button) self:SetText(format("|cff%02x%02x%02x%s|r", K.Color.r*255, K.Color.g*255, K.Color.b*255, translate)) end)
		offset = offset + 20
	end
	child:SetSize(125, offset)
	slider:SetMinMaxValues(0, (offset == 0 and 1 or offset - 12 * 33))
	slider:SetValue(1)
	groups:SetScrollChild(child)

	local x
	_G["UIConfigCategoryGroup"]:EnableMouseWheel(true)
	_G["UIConfigCategoryGroup"]:SetScript("OnMouseWheel", function(self, delta)
		if _G["UIConfigCategorySlider"]:IsShown() then
			if delta == -1 then
				x = _G["UIConfigCategorySlider"]:GetValue()
				_G["UIConfigCategorySlider"]:SetValue(x + 10)
			elseif delta == 1 then
				x = _G["UIConfigCategorySlider"]:GetValue()
				_G["UIConfigCategorySlider"]:SetValue(x - 20)
			end
		end
	end)

	local group = CreateFrame("ScrollFrame", "UIConfigGroup", UIConfig)
	group:SetPoint("TOPLEFT", 0, 5)
	group:SetSize(520, 400)

	-- Options Scroll
	local slider = CreateFrame("Slider", "UIConfigGroupSlider", group)
	slider:SetPoint("TOPRIGHT", 0, 0)
	slider:SetSize(24, 400)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetOrientation("VERTICAL")
	slider:SetValueStep(20)
	slider:SetScript("OnValueChanged", function(self, value) group:SetVerticalScroll(value) end)

	for i in pairs(ALLOWED_GROUPS) do
		local frame = CreateFrame("Frame", "UIConfig"..i, UIConfigGroup)
		frame:SetPoint("TOPLEFT")
		frame:SetWidth(225)

		local offset = 5

		if type(C[i]) ~= "table" then Error(i.." GroupName not found in config table.") return end
		for j, value in PairsByKeys(C[i]) do
			if type(value) == "boolean" then
				local button = CreateFrame("CheckButton", "UIConfig"..i..j, frame, "InterfaceOptionsCheckButtonTemplate")
				local o = "UIConfig"..i..j
				local translate = Local(i..j)
				_G["UIConfig"..i..j.."Text"]:SetText(translate)
				_G["UIConfig"..i..j.."Text"]:SetFontObject(GameFontHighlight)
				_G["UIConfig"..i..j.."Text"]:SetWidth(460)
				_G["UIConfig"..i..j.."Text"]:SetJustifyH("LEFT")
				button:SetChecked(value)
				button:SetScript("OnClick", function(self) SetValue(i, j, (self:GetChecked() and true or false)) end)
				button:SetPoint("TOPLEFT", 5, -offset)
				offset = offset + 25
			elseif type(value) == "number" or type(value) == "string" then
				local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				local o = "UIConfig"..i..j
				local translate = Local(i..j)
				label:SetText(translate)
				label:SetSize(460, 20)
				label:SetJustifyH("LEFT")
				label:SetPoint("TOPLEFT", 5, -offset)

				local editbox = CreateFrame("EditBox", nil, frame)
				editbox:SetAutoFocus(false)
				editbox:SetMultiLine(false)
				editbox:SetSize(220, 28)
				editbox:SetMaxLetters(255)
				editbox:SetTextInsets(8, 0, 0, 0)
				editbox:SetFontObject(GameFontHighlight)
				editbox:SetPoint("TOPLEFT", 8, -(offset + 20))
				editbox:SetText(value)
				editbox:SetBackdrop(K.Backdrop)
				editbox:SetBackdropBorderColor(unpack(C.Media.Border_Color))
				editbox:SetBackdropColor(.05, .05, .05)

				local okbutton = CreateFrame("Button", nil, frame)
				okbutton:SetHeight(editbox:GetHeight() - 8)
				okbutton:SkinButton()
				okbutton:SetPoint("LEFT", editbox, "RIGHT", 2, 0)

				local oktext = okbutton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				oktext:SetText(OKAY)
				oktext:SetPoint("CENTER", okbutton, "CENTER", -1, 0)
				okbutton:SetWidth(oktext:GetWidth() + 5)
				okbutton:Hide()

				if type(value) == "number" then
					editbox:SetScript("OnEscapePressed", function(self) okbutton:Hide() self:ClearFocus() self:SetText(value) end)
					editbox:SetScript("OnChar", function(self) okbutton:Show() end)
					editbox:SetScript("OnEnterPressed", function(self) okbutton:Hide() self:ClearFocus() SetValue(i, j, tonumber(self:GetText())) end)
					okbutton:SetScript("OnMouseDown", function(self) editbox:ClearFocus() self:Hide() SetValue(i, j, tonumber(editbox:GetText())) end)
				else
					editbox:SetScript("OnEscapePressed", function(self) okbutton:Hide() self:ClearFocus() self:SetText(value) end)
					editbox:SetScript("OnChar", function(self) okbutton:Show() end)
					editbox:SetScript("OnEnterPressed", function(self) okbutton:Hide() self:ClearFocus() SetValue(i, j, tostring(self:GetText())) end)
					okbutton:SetScript("OnMouseDown", function(self) editbox:ClearFocus() self:Hide() SetValue(i, j, tostring(editbox:GetText())) end)
				end

				offset = offset + 45
			elseif type(value) == "table" then
				local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				local o = "UIConfig"..i..j
				local translate = Local(i..j)
				label:SetText(translate)
				label:SetSize(440, 20)
				label:SetJustifyH("LEFT")
				label:SetPoint("TOPLEFT", 5, -offset)

				colorbuttonname = (label:GetText().."ColorPicker")

				local colorbutton = CreateFrame("Button", colorbuttonname, frame)
				colorbutton:SetHeight(28)
				colorbutton:SetBackdrop(K.Backdrop)
				colorbutton:SetBackdropBorderColor(unpack(value))
				colorbutton:SetBackdropColor(value[1], value[2], value[3], 0.3)
				colorbutton:SetPoint("LEFT", label, "RIGHT", 2, 0)

				local colortext = colorbutton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				colortext:SetText(COLOR)
				colortext:SetPoint("CENTER")
				colortext:SetJustifyH("CENTER")
				colorbutton:SetWidth(colortext:GetWidth() + 12)

				local oldvalue = value

				local function round(number, decimal)
					return (("%%.%df"):format(decimal)):format(number)
				end

				colorbutton:SetScript("OnMouseDown", function(self)
					if ColorPickerFrame:IsShown() then return end
					local newR, newG, newB, newA
					local fired = 0

					local r, g, b, a = self:GetBackdropBorderColor()
					r, g, b, a = round(r, 2), round(g, 2), round(b, 2), round(a, 2)
					local originalR, originalG, originalB, originalA = r, g, b, a

					local function ShowColorPicker(r, g, b, a, changedCallback)
						ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback
						ColorPickerFrame:SetColorRGB(r, g, b)
						a = tonumber(a)
						ColorPickerFrame.hasOpacity = (a ~= nil and a ~= 1)
						ColorPickerFrame.opacity = a
						ColorPickerFrame.previousValues = {originalR, originalG, originalB, originalA}
						ColorPickerFrame:Hide()
						ColorPickerFrame:Show()
					end

					local function myColorCallback(restore)
						fired = fired + 1
						if restore ~= nil then
							-- The user bailed, we extract the old color from the table created by ShowColorPicker
							newR, newG, newB, newA = unpack(restore)
						else
							-- Something changed
							newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
						end

						value = {newR, newG, newB, newA}
						SetValue(i, j, (value))
						self:SetBackdropBorderColor(newR, newG, newB, newA)
						self:SetBackdropColor(newR, newG, newB, 0.3)
					end

					ShowColorPicker(originalR, originalG, originalB, originalA, myColorCallback)
				end)

				offset = offset + 25
			end
		end

		frame:SetHeight(offset)
		frame:Hide()
	end

	local reset = NormalButton(DEFAULT, UIConfigMain)
	reset:SetPoint("TOPRIGHT", UIConfigBG, "TOPRIGHT", 128, 0)
	reset:SetScript("OnClick", function(self)
		UIConfigCover:Show()
		if KkthnxUIConfigAll[realm][name] == true then
			StaticPopup_Show("RESET_PERCHAR")
		else
			StaticPopup_Show("RESET_ALL")
		end
	end)

	local totalreset = NormalButton(UIConfigLocal.ConfigButtonReset, UIConfigMain)
	totalreset:SetPoint("TOPRIGHT", UIConfigBG, "TOPRIGHT", 128, -31)
	totalreset:SetScript("OnClick", function(self)
		StaticPopup_Show("RESET_UI")
		KkthnxUIConfigPrivate = {}
		if KkthnxUIConfigAll[realm][name] == true then
			KkthnxUIConfigAll[realm][name] = {}
		end
		KkthnxUIConfigPublic = {}
	end)

	local load = NormalButton("|cff00FF00" .. UIConfigLocal.ConfigApplyButton .. "|r", UIConfigMain)
	load:SetPoint("TOP", totalreset, "BOTTOM", 0, -30)
	load:SetScript("OnClick", function(self) ReloadUI() end)

	local close = NormalButton("|cffFF0000" .. UIConfigLocal.ConfigCloseButton .. "|r", UIConfigMain)
	close:SetPoint("TOP", load, "BOTTOM", 0, -8)
	close:SetScript("OnClick", function(self) PlaySound("igMainMenuOption") UIConfigMain:Hide() end)

	local RightButtonsBG = CreateFrame("Frame", "RightButtonsBG", UIConfigMain)
	RightButtonsBG:SetSize(116, 154)
	RightButtonsBG:SetTemplate()
	RightButtonsBG:SetBackdropColor(.05, .05, .05)
	RightButtonsBG:SetFrameLevel(UIConfigMain:GetFrameLevel(- 1))
	RightButtonsBG:SetPoint("TOPRIGHT", UIConfigBG, "TOPRIGHT", 136, 8)

	if KkthnxUIConfigAll then
		local button = CreateFrame("CheckButton", "KkthnxUIConfigAllCharacters", TitleBox, "InterfaceOptionsCheckButtonTemplate")
		button:SetScript("OnClick", function(self) StaticPopup_Show("PERCHAR") UIConfigCover:Show() end)
		button:SetPoint("RIGHT", TitleBox, "RIGHT", -3, 0)
		button:SetHitRectInsets(0, 0, 0, 0)
		if IsAddOnLoaded("Aurora") then
			local F = unpack(Aurora)
			F.ReskinCheck(button)
		end

		local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetText(UIConfigLocal.ConfigSetSavedSettings)
		label:SetPoint("RIGHT", button, "LEFT")

		if KkthnxUIConfigAll[realm][name] == true then
			button:SetChecked(true)
		else
			button:SetChecked(false)
		end
	end

	local bgSkins = {TitleBox, TitleBoxVer, UIConfigBG, groupsBG}
	for _, sb in pairs(bgSkins) do
		sb:SetBackdrop(K.Backdrop)
		sb:SetBackdropColor(unpack(C.Media.Backdrop_Color))
		sb:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	end

	ShowGroup("General")
	loaded = true
end

do
	function SlashCmdList.CONFIG(msg, editbox)
		if not UIConfigMain or not UIConfigMain:IsShown() then
			PlaySound("igMainMenuOption")
			CreateUIConfig()
			HideUIPanel(GameMenuFrame)
		else
			PlaySound("igMainMenuOption")
			UIConfigMain:Hide()
		end
	end
	SLASH_CONFIG1 = "/cfg"
	SLASH_CONFIG2 = "/configui"

	function SlashCmdList.RESETCONFIG()
		if UIConfigMain and UIConfigMain:IsShown() then UIConfigCover:Show() end

		if KkthnxUIConfigAll[realm][name] == true then
			StaticPopup_Show("RESET_PERCHAR")
		else
			StaticPopup_Show("RESET_ALL")
		end
	end
	SLASH_RESETCONFIG1 = "/resetconfig"
end

do
	local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
	frame:Hide()

	frame.name = "|cff3c9bedKkthnxUI|r"
	frame:SetScript("OnShow", function(self)
		if self.show then return end

		local K, C, L = unpack(KkthnxUI)

		local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 16, -16)
		title:SetText("Info:")

		local subtitle = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle:SetWidth(580)
		subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
		subtitle:SetJustifyH("LEFT")
		subtitle:SetText("UI Site: |cff3c9bedhttps://kkthnx.github.io/KkthnxUI_Legion|r\nGitHub: |cff3c9bedhttps://github.com/Kkthnx/KkthnxUI_Legion|r\nChangelog: |cff3c9bedhttps://github.com/Kkthnx/KkthnxUI_Legion/commits/master|r")

		local title2 = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title2:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
		title2:SetText("Credits:")

		local subtitle2 = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle2:SetWidth(580)
		subtitle2:SetPoint("TOPLEFT", title2, "BOTTOMLEFT", 0, -8)
		subtitle2:SetJustifyH("LEFT")
		subtitle2:SetText("ALZA, AcidWeb, Aezay, Affli, Ailae, Allez, Ammo, Astromech, Beoko, BernCarney, Bitbyte, Blamdarot, Bozo, Bunny67, Caellian, Califpornia, Camealion, Chiril, Crum, CrusaderHeimdall, Cybey, Dawn, Don Kaban, Dridzt, Kkthnx, Durcyn, Eclipse, Egingell, Elv22, Evilpaul, Evl, Favorit, Fernir, Foof, Freebaser, freesay, Goldpaw, Gorlasch, Gsuz, Haleth, Haste, Hoochie, Hungtar, HyPeRnIcS, Hydra, Ildyria, Jaslm, Karl_w_w, Karudon, Katae, Kellett, Kemayo, Killakhan, Kraftman, Kunda, Leatrix, Magdain, |cFFFF69B4Magicnachos|r, Meurtcriss, Monolit, MrRuben5, Myrilandell of Lothar, Nathanyel, Nefarion, Nightcracker, Nils Ruesch, Partha, Peatah, Phanx, Rahanprout, Rav, Renstrom, RustamIrzaev, SDPhantom, Safturento, Sara.Festung, Sildor, Silverwind, SinaC, Slakah, Soeters, Starlon, Suicidal Katt, Syzgyn, Tekkub, Telroth, Thalyra, Thizzelle, Tia Lynn, Tohveli, Tukz, Tuller, Veev, Villiv, Wetxius, Woffle of Dark Iron, Wrug, Xuerian, Yleaf, Zork, g0st, gi2k15, iSpawnAtHome, m2jest1c, p3lim, sticklord")

		local title3 = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title3:SetPoint("TOPLEFT", subtitle2, "BOTTOMLEFT", 0, -16)
		title3:SetText("Chinese Translation Needed:")

		local subtitle3 = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle3:SetWidth(580)
		subtitle3:SetPoint("TOPLEFT", title3, "BOTTOMLEFT", 0, -8)
		subtitle3:SetJustifyH("LEFT")
		subtitle3:SetText("|cff3c9bedKkthnxUI|r is looking for Chinese (Simplified) and Chinese (Traditional) translation. If you wanna translate for us, you can PM me or make pull requests on GitHub")

		local title4 = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title4:SetPoint("TOPLEFT", subtitle3, "BOTTOMLEFT", 0, -16)
		title4:SetText("Supporters")

		local subtitle4 = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle4:SetWidth(580)
		subtitle4:SetPoint("TOPLEFT", title4, "BOTTOMLEFT", 0, -8)
		subtitle4:SetJustifyH("LEFT")
		subtitle4:SetText("XploitNT, jChirp, |cFFFF69B4Magicnachos|r")

		local version = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		version:SetPoint("BOTTOMRIGHT", -16, 16)
		version:SetText("Version: "..K.Version)

		self.show = true
	end)

	InterfaceOptions_AddCategory(frame)
end

-- Button in GameMenuButton frame
if not IsAddOnLoaded("KkthnxUI_Config") and IsAddOnLoaded("ConsolePort") then return end

local button = CreateFrame("Button", "GameMenuButtonSettingsUI", GameMenuFrame, "GameMenuButtonTemplate")
button:SetText("|cff3c9bedKkthnxUI|r")
button:SetPoint("TOP", "GameMenuButtonAddons", "BOTTOM", 0, -1)

GameMenuFrame:HookScript("OnShow", function()
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + button:GetHeight())
	GameMenuButtonLogout:SetPoint("TOP", button, "BOTTOM", 0, -16)
end)

button:SetScript("OnClick", function()
	PlaySound("igMainMenuOption")
	HideUIPanel(GameMenuFrame)
	if not UIConfigMain or not UIConfigMain:IsShown() then
		CreateUIConfig()
	else
		UIConfigMain:Hide()
	end
end)