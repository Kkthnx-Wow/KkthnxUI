local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- Enhanced ColorPickerFrame
local function translateColor(r)
	if not r then
		r = "ff"
	end
	return tonumber(r, 16) / 255
end

function Module:EnhancedPicker_UpdateColor()
	local r, g, b = strmatch(self.colorStr, "(%x%x)(%x%x)(%x%x)$")
	r = translateColor(r)
	g = translateColor(g)
	b = translateColor(b)
	_G.ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
end

-- local function GetBoxColor(box)
-- 	local r = box:GetText()
-- 	r = tonumber(r)
-- 	if not r or r < 0 or r > 255 then
-- 		r = 255
-- 	end
-- 	return r
-- end

-- local function updateColorRGB(self)
-- 	local r = GetBoxColor(_G.ColorPickerFrame.__boxR)
-- 	local g = GetBoxColor(_G.ColorPickerFrame.__boxG)
-- 	local b = GetBoxColor(_G.ColorPickerFrame.__boxB)
-- 	self.colorStr = format("%02x%02x%02x", r, g, b)
-- 	Module.EnhancedPicker_UpdateColor(self)
-- end

-- local function updateColorStr(self)
-- 	self.colorStr = self:GetText()
-- 	Module.EnhancedPicker_UpdateColor(self)
-- end

-- local function editBoxClearFocus(self)
-- 	if self.ClearFocus then
-- 		self:ClearFocus()
-- 	end
-- end

-- local function createCodeBox(width, index, text)
-- 	local parent = ColorPickerFrame.Content.ColorSwatchCurrent
-- 	local offset = -3

-- 	local box = CreateFrame("EditBox", nil, _G.ColorPickerFrame)
-- 	box:SetSize(width, 22)
-- 	box:SetAutoFocus(false)
-- 	box:SetMaxLetters(index == 4 and 6 or 3)
-- 	box:SetTextInsets(5, 5, 0, 0)
-- 	box:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -index * 24 + offset)
-- 	K.CreateFontString(box, 13, text, "", false, "LEFT", -15, 0)

-- 	box:SetScript("OnEscapePressed", editBoxClearFocus)
-- 	box:SetScript("OnEnterPressed", editBoxClearFocus)

-- 	if index == 4 then
-- 		box:HookScript("OnEnterPressed", updateColorStr)
-- 	else
-- 		box:HookScript("OnEnterPressed", updateColorRGB)
-- 	end

-- 	box.Type = "EditBox"

-- 	return box
-- end

function Module:CreateColorPicker()
	if C_AddOns.IsAddOnLoaded("ColorPickerPlus") or C["Misc"].ColorPicker ~= true then
		return
	end

	local pickerFrame = _G.ColorPickerFrame
	pickerFrame:SetHeight(250)
	K.CreateMoverFrame(pickerFrame.Header, pickerFrame) -- movable by header

	local colorBar = CreateFrame("Frame", nil, pickerFrame)
	colorBar:SetSize(1, 22)
	colorBar:SetPoint("BOTTOM", 0, 38)

	local count = 0
	for class, name in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		local value = K.ClassColors[class]
		if value then
			local bu = CreateFrame("Button", nil, colorBar, "BackdropTemplate")
			bu:SetSize(22, 22)
			bu.Icon = bu:CreateTexture(nil, "ARTWORK")
			bu.Icon:SetColorTexture(value.r, value.g, value.b)
			bu.Icon:SetAllPoints()
			bu.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			bu:SetPoint("LEFT", count * 22, 0)
			bu.colorStr = value.colorStr
			bu:SetScript("OnClick", Module.EnhancedPicker_UpdateColor)
			K.AddTooltip(bu, "ANCHOR_TOP", "|c" .. value.colorStr .. name)

			count = count + 1
		end
	end
	colorBar:SetWidth(count * 22)

	-- pickerFrame.__boxR = createCodeBox(45, 1, "|cffff0000R")
	-- pickerFrame.__boxG = createCodeBox(45, 2, "|cff00ff00G")
	-- pickerFrame.__boxB = createCodeBox(45, 3, "|cff0000ffB")

	local hexBox = pickerFrame.Content and pickerFrame.Content.HexBox
	if hexBox then
		hexBox:SkinEditBox()
		hexBox:ClearAllPoints()
		hexBox:SetPoint("BOTTOMRIGHT", -25, 67)
	end

	-- pickerFrame.Content.ColorPicker.__owner = pickerFrame
	-- pickerFrame.Content.ColorPicker:HookScript("OnColorSelect", function(self)
	-- 	local r, g, b = self.__owner:GetColorRGB()
	-- 	r = K.Round(r * 255)
	-- 	g = K.Round(g * 255)
	-- 	b = K.Round(b * 255)

	-- 	self.__owner.__boxR:SetText(r)
	-- 	self.__owner.__boxG:SetText(g)
	-- 	self.__owner.__boxB:SetText(b)
	-- end)
end
