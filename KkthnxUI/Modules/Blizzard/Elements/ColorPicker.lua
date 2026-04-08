--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Enhances the default Blizzard Color Picker with class color presets and hex support.
-- - Design: Modifies the ColorPickerFrame to add custom buttons for all WoW classes.
-- - Events: Hooked into the ColorPickerFrame initialization.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local CreateFrame = CreateFrame
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local pairs = pairs
local strmatch = string.match
local tonumber = tonumber

-- ---------------------------------------------------------------------------
-- Utility Logic
-- ---------------------------------------------------------------------------
local function translateColor(hex)
	-- REASON: Converts a 2-character hex string into a 0.0-1.0 float value for WoW RGB APIs.
	if not hex then
		hex = "ff"
	end
	return tonumber(hex, 16) / 255
end

-- ---------------------------------------------------------------------------
-- Color Picker Enhancements
-- ---------------------------------------------------------------------------
function Module:EnhancedPicker_UpdateColor()
	-- REASON: Updates the active ColorPicker selection when a class color preset button is clicked.
	local r, g, b = strmatch(self.colorStr, "(%x%x)(%x%x)(%x%x)$")
	r = translateColor(r)
	g = translateColor(g)
	b = translateColor(b)

	local colorPickerFrame = _G.ColorPickerFrame
	if colorPickerFrame and colorPickerFrame.Content and colorPickerFrame.Content.ColorPicker then
		colorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
	end
end

function Module:CreateColorPicker()
	-- REASON: Entry point for the Color Picker enhancement.
	-- COMPAT: Check for conflicting addons like ColorPickerPlus.
	if _G.C_AddOns.IsAddOnLoaded("ColorPickerPlus") or C["Misc"].ColorPicker ~= true then
		return
	end

	local pickerFrame = _G.ColorPickerFrame
	if not pickerFrame then
		return
	end

	pickerFrame:SetHeight(250)
	-- REASON: Makes the Color Picker movable by clicking and dragging its header.
	if pickerFrame.Header then
		K.CreateMoverFrame(pickerFrame.Header, pickerFrame)
	end

	-- -----------------------------------------------------------------------
	-- Class Color Presets
	-- -----------------------------------------------------------------------
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

	-- -----------------------------------------------------------------------
	-- Hex Box Skinning
	-- -----------------------------------------------------------------------
	local hexBox = pickerFrame.Content and pickerFrame.Content.HexBox
	if hexBox then
		if hexBox.SkinEditBox then
			hexBox:SkinEditBox()
		end
		hexBox:ClearAllPoints()
		hexBox:SetPoint("BOTTOMRIGHT", -25, 67)
	end
end
