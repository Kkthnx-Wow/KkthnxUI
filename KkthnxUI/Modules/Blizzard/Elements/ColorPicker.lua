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

	local hexBox = pickerFrame.Content and pickerFrame.Content.HexBox
	if hexBox then
		hexBox:SkinEditBox()
		hexBox:ClearAllPoints()
		hexBox:SetPoint("BOTTOMRIGHT", -25, 67)
	end
end
