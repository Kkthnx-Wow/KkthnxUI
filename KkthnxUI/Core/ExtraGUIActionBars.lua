---@diagnostic disable: undefined-global
local K, C, L = unpack(KkthnxUI)

--[[-----------------------------------------------------------------------------
-- ExtraGUIActionBars
--
-- Registers ActionBar extra configuration panels for ExtraGUI.
--
-- REASON: ExtraGUI.lua had eight copy-pasted bar registrations plus eight
-- one-line scale helpers. A loop expresses the real structure: every action bar
-- exposes the same size/per-row/count/font/fade controls with bar-specific paths.
-----------------------------------------------------------------------------]]

local ExtraGUIActionBars = {}
K.ExtraGUIActionBars = ExtraGUIActionBars

local function UpdateActionBarScale(barName)
	K:GetModule("ActionBar"):UpdateActionSize(barName)
end

local function UpdateABFaderState()
	local actionBarModule = K:GetModule("ActionBar")
	if not actionBarModule.fadeParent then
		return
	end
	actionBarModule:UpdateFaderState()
	actionBarModule.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
end

local function CreateBarPanel(extraGUI, barIndex, barName)
	return function(parent)
		local yOffset = -10
		local function onScaleChanged()
			UpdateActionBarScale(barName)
		end

		local sizeSlider = extraGUI:CreateSlider(parent, "ActionBar." .. barName .. "Size", L["Button Size"], 20, 80, 1, L[barName .. "Size Desc"], onScaleChanged)
		sizeSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local perRowSlider = extraGUI:CreateSlider(parent, "ActionBar." .. barName .. "PerRow", L["Button PerRow"], 1, 12, 1, L[barName .. "PerRow Desc"], onScaleChanged)
		perRowSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local numSlider = extraGUI:CreateSlider(parent, "ActionBar." .. barName .. "Num", L["Button Num"], 1, 12, 1, L[barName .. "Num Desc"], onScaleChanged)
		numSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local fontSlider = extraGUI:CreateSlider(parent, "ActionBar." .. barName .. "Font", L["Button FontSize"], 8, 20, 1, L[barName .. "Font Desc"], onScaleChanged)
		fontSlider:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		local fadeSwitch = extraGUI:CreateSwitch(parent, "ActionBar." .. barName .. "Fade", L["Enable Fade for Bar " .. barIndex], L["Allows Bar " .. barIndex .. " to fade based on the specified conditions"], UpdateABFaderState)
		fadeSwitch:SetPoint("TOPLEFT", 0, yOffset)
		yOffset = yOffset - 35

		parent:SetHeight(math.abs(yOffset) + 20)
	end
end

function ExtraGUIActionBars:Register(extraGUI)
	for i = 1, 8 do
		local barIndex = i
		local barName = "Bar" .. barIndex
		extraGUI:RegisterExtraConfig("ActionBar." .. barName, CreateBarPanel(extraGUI, barIndex, barName), "Bar " .. barIndex)
	end
end

