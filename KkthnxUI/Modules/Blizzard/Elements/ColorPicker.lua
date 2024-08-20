local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- Cache global references
local string_format = string.format
local string_match = string.match
local tonumber = tonumber
local CreateFrame = CreateFrame
local ColorPickerFrame = ColorPickerFrame
local pairs = pairs
local _G = _G

-- Utility function to translate color
local function translateColor(r)
	if not r then
		r = "ff"
	end
	return tonumber(r, 16) / 255
end

-- Enhanced ColorPickerFrame functions
function Module:EnhancedPicker_UpdateColor()
	local r, g, b = string_match(self.colorStr, "(%x%x)(%x%x)(%x%x)$")
	r = translateColor(r)
	g = translateColor(g)
	b = translateColor(b)

	ColorPickerFrame:SetColorRGB(r, g, b)
end

local function GetBoxColor(box)
	local r = tonumber(box:GetText())
	if not r or r < 0 or r > 255 then
		r = 255
	end
	return r
end

local function updateColorRGB(self)
	local r = GetBoxColor(ColorPickerFrame.__boxR)
	local g = GetBoxColor(ColorPickerFrame.__boxG)
	local b = GetBoxColor(ColorPickerFrame.__boxB)

	self.colorStr = string_format("%02x%02x%02x", r, g, b)
	Module.EnhancedPicker_UpdateColor(self)
end

local function updateColorStr(self)
	self.colorStr = self:GetText()
	Module.EnhancedPicker_UpdateColor(self)
end

local function editBoxClearFocus(self)
	self:ClearFocus()
end

local function createCodeBox(width, index, text)
	local box = CreateFrame("EditBox", nil, ColorPickerFrame)
	box:SetSize(width, 20)
	box:SetAutoFocus(false)
	box:SetTextInsets(5, 5, 0, 0)
	box:SetMaxLetters(index == 4 and 6 or 3)
	box:SetPoint("TOPLEFT", _G.ColorSwatch, "BOTTOMLEFT", 0, -index * 26)
	box:SetFontObject(K.UIFont)

	local bg = CreateFrame("Button", nil, box)
	bg:SetAllPoints()
	bg:SetFrameLevel(box:GetFrameLevel())
	bg:CreateBorder()

	box:SetScript("OnEscapePressed", editBoxClearFocus)
	box:SetScript("OnEnterPressed", editBoxClearFocus)
	K.CreateFontString(box, 14, text, "", "", "LEFT", -15, 0)

	if index == 4 then
		box:HookScript("OnEnterPressed", updateColorStr)
	else
		box:HookScript("OnEnterPressed", updateColorRGB)
	end

	return box
end

-- Create enhanced color picker frame
function Module:CreateColorPicker()
	if C_AddOns.IsAddOnLoaded("ColorPickerPlus") or C["Misc"].ColorPicker ~= true then
		return
	end

	local pickerFrame = ColorPickerFrame
	pickerFrame:SetHeight(250)
	K.CreateMoverFrame(pickerFrame.Header, pickerFrame)

	local colorBar = CreateFrame("Frame", nil, pickerFrame)
	colorBar:SetSize(1, 20)
	colorBar:SetPoint("BOTTOM", 3, 35)

	local count = 0
	for class, name in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do
		local value = K.ClassColors[class]
		if value then
			local bu = CreateFrame("Button", nil, colorBar)
			bu:SetSize(20, 20)

			local icon = bu:CreateTexture(nil, "ARTWORK")
			icon:SetAllPoints()
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			icon:SetColorTexture(value.r, value.g, value.b)

			bu:SetPoint("LEFT", count * 25, 0)
			bu:CreateBorder()

			bu.colorStr = value.colorStr
			bu:SetScript("OnClick", Module.EnhancedPicker_UpdateColor)
			K.AddTooltip(bu, "ANCHOR_TOP", "|c" .. value.colorStr .. name)

			count = count + 1
		end
	end
	colorBar:SetWidth(count * 25)

	pickerFrame.__boxR = createCodeBox(45, 1, "|cffff0000R")
	pickerFrame.__boxG = createCodeBox(45, 2, "|cff00ff00G")
	pickerFrame.__boxB = createCodeBox(45, 3, "|cff0000ffB")
	pickerFrame.__boxH = createCodeBox(70, 4, "#")

	pickerFrame:HookScript("OnColorSelect", function(self)
		local r, g, b = self:GetColorRGB()
		r = K.Round(r * 255)
		g = K.Round(g * 255)
		b = K.Round(b * 255)

		self.__boxR:SetText(r)
		self.__boxG:SetText(g)
		self.__boxB:SetText(b)
		self.__boxH:SetText(string_format("%02x%02x%02x", r, g, b))
	end)

	pickerFrame.Header:StripTextures()
	pickerFrame.Header:ClearAllPoints()
	pickerFrame.Header:SetPoint("TOP", pickerFrame, 0, 10)
	pickerFrame.Border:Hide()

	pickerFrame:CreateBorder()
	_G.ColorPickerOkayButton:SkinButton()
	_G.ColorPickerCancelButton:SkinButton()

	_G.ColorPickerCancelButton:ClearAllPoints()
	_G.ColorPickerCancelButton:SetPoint("BOTTOMLEFT", pickerFrame, "BOTTOM", 3, 6)
	_G.ColorPickerOkayButton:ClearAllPoints()
	_G.ColorPickerOkayButton:SetPoint("BOTTOMRIGHT", pickerFrame, "BOTTOM", -3, 6)
end
