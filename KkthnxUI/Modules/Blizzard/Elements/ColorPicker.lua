local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

local string_format = string.format
local string_match = string.match

-- Enhanced ColorPickerFrame
local function translateColor(r)
	if not r then
		r = "ff"
	end

	return tonumber(r, 16) / 255
end

function Module:EnhancedPicker_UpdateColor()
	local r, g, b = string_match(self.colorStr, "(%x%x)(%x%x)(%x%x)$")
	r = translateColor(r)
	g = translateColor(g)
	b = translateColor(b)

	_G.ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
end

local function GetBoxColor(box)
	local r = box:GetText()
	r = tonumber(r)
	if not r or r < 0 or r > 255 then
		r = 255
	end

	return r
end

local function updateColorRGB(self)
	local r = GetBoxColor(_G.ColorPickerFrame.__boxR)
	local g = GetBoxColor(_G.ColorPickerFrame.__boxG)
	local b = GetBoxColor(_G.ColorPickerFrame.__boxB)

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
	local box = CreateFrame("EditBox", nil, _G.ColorPickerFrame)
	box:SetSize(width, 20)
	box:SetAutoFocus(false)
	box:SetTextInsets(5, 5, 0, 0)
	box:SetMaxLetters(index == 4 and 6 or 3)
	box:SetTextInsets(0, 0, 0, 0)
	box:SetPoint("TOPLEFT", _G.ColorPickerFrame.Content.ColorSwatchCurrent, "BOTTOMLEFT", 0, -index * 26 + -3)
	box:SetFontObject(K.UIFont)

	box.bg = CreateFrame("Button", nil, box)
	box.bg:SetAllPoints()
	box.bg:SetFrameLevel(box:GetFrameLevel())
	box.bg:CreateBorder()

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

function Module:CreateColorPicker()
	if C_AddOns.IsAddOnLoaded("ColorPickerPlus") or C["Misc"].ColorPicker ~= true then
		return
	end

	local pickerFrame = _G.ColorPickerFrame
	pickerFrame:SetHeight(250)
	K.CreateMoverFrame(pickerFrame.Header, pickerFrame) -- movable by header

	local colorBar = CreateFrame("Frame", nil, pickerFrame)
	colorBar:SetSize(1, 20)
	colorBar:SetPoint("BOTTOM", 3, 35)

	local count = 0
	for class, name in pairs(_G.LOCALIZED_CLASS_NAMES_MALE) do
		local value = K.ClassColors[class]
		if value then
			local bu = CreateFrame("Button", nil, colorBar)
			bu:SetSize(20, 20)

			bu.Icon = bu:CreateTexture(nil, "ARTWORK")
			bu.Icon:SetAllPoints()
			bu.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			bu.Icon:SetColorTexture(value.r, value.g, value.b)

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
	local hexBox = pickerFrame.Content and pickerFrame.Content.HexBox
	if hexBox then
		hexBox:StripTextures()

		local bg = CreateFrame("Button", nil, hexBox)
		bg:SetAllPoints()
		bg:SetFrameLevel(hexBox:GetFrameLevel())
		bg:CreateBorder()

		hexBox:ClearAllPoints()
		hexBox:SetPoint("BOTTOMRIGHT", -27, 60)
	end

	pickerFrame.Content.ColorPicker.__owner = pickerFrame
	pickerFrame.Content.ColorPicker:HookScript("OnColorSelect", function(self)
		local r, g, b = self.__owner:GetColorRGB()
		r = K.Round(r * 255)
		g = K.Round(g * 255)
		b = K.Round(b * 255)

		self.__owner.__boxR:SetText(r)
		self.__owner.__boxG:SetText(g)
		self.__owner.__boxB:SetText(b)
	end)

	pickerFrame.Header:StripTextures()
	pickerFrame.Header:ClearAllPoints()
	pickerFrame.Header:SetPoint("TOP", pickerFrame, 0, 10)
	pickerFrame.Border:Hide()

	pickerFrame:CreateBorder()
	_G.ColorPickerFrame.Footer.OkayButton:SkinButton()
	_G.ColorPickerFrame.Footer.CancelButton:SkinButton()

	_G.ColorPickerFrame.Footer.CancelButton:ClearAllPoints()
	_G.ColorPickerFrame.Footer.CancelButton:SetPoint("BOTTOMLEFT", pickerFrame, "BOTTOM", 3, 6)
	_G.ColorPickerFrame.Footer.OkayButton:ClearAllPoints()
	_G.ColorPickerFrame.Footer.OkayButton:SetPoint("BOTTOMRIGHT", pickerFrame, "BOTTOM", -3, 6)
end
