local _, _, L = unpack(KkthnxUI)

--[[-----------------------------------------------------------------------------
-- GUIResetButtons
--
-- Shared Ctrl-hover reset button helper for GUI.lua and ExtraGUI.lua.
--
-- REASON: both config UIs duplicated the same undo-button atlas fallback, tooltip,
-- Ctrl-state tracking, and mouse-leave hiding. The reset action itself remains a
-- callback supplied by the caller, so main GUI and ExtraGUI keep their own reset
-- persistence/reload behavior.
-----------------------------------------------------------------------------]]

local pairs = pairs
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local C_Texture = C_Texture
local C_Timer = C_Timer
local IsControlKeyDown = IsControlKeyDown
local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR

local GUIResetButtons = {}
KkthnxUI[1].GUIResetButtons = GUIResetButtons

local resetButtons = {}

local ctrlChecker = CreateFrame("Frame")
ctrlChecker:SetScript("OnEvent", function(_, _, key, state)
	if key ~= "LCTRL" and key ~= "RCTRL" then
		return
	end

	if state == 1 then
		for widget, resetButton in pairs(resetButtons) do
			if widget:IsMouseOver() then
				resetButton:Show()
				break
			end
		end
	else
		for _, resetButton in pairs(resetButtons) do
			resetButton:Hide()
		end
		GameTooltip:Hide()
	end
end)
ctrlChecker:RegisterEvent("MODIFIER_STATE_CHANGED")

function GUIResetButtons:Attach(widget, label, configPath, cleanText, onReset, xOffset)
	widget:EnableMouse(true)

	local resetButton = CreateFrame("Button", nil, widget)
	resetButton:SetSize(16, 16)
	resetButton:SetPoint("LEFT", label, "RIGHT", xOffset or 5, 0)
	resetButton:Hide()

	local undoIcon = resetButton:CreateTexture(nil, "ARTWORK")
	undoIcon:SetAllPoints()
	undoIcon:SetAlpha(0.7)

	if C_Texture.GetAtlasInfo("common-icon-undo") then
		undoIcon:SetAtlas("common-icon-undo", true)
		undoIcon:SetSize(16, 16)
	else
		undoIcon:SetTexture("Interface\\Buttons\\UI-RefreshButton")
		undoIcon:SetTexCoord(0, 1, 0, 1)
	end

	resetButton:SetScript("OnEnter", function(self)
		undoIcon:SetAlpha(1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Reset to Default"] or "Reset to Default", 1, 1, 1, 1, true)
		GameTooltip:AddLine(L["Click to reset this setting to its default value"] or "Click to reset this setting to its default value", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
		GameTooltip:Show()
	end)

	resetButton:SetScript("OnLeave", function()
		undoIcon:SetAlpha(0.7)
		GameTooltip:Hide()
	end)

	resetButton:SetScript("OnClick", function(_, button)
		if button == "LeftButton" and onReset then
			onReset(configPath, widget, cleanText)
		end
	end)

	widget.ResetButton = resetButton

	widget:HookScript("OnEnter", function()
		if IsControlKeyDown() then
			resetButton:Show()
		end
	end)

	widget:HookScript("OnLeave", function()
		C_Timer.After(0.01, function()
			if resetButton:IsShown() and not widget:IsMouseOver() and not resetButton:IsMouseOver() then
				resetButton:Hide()
			end
		end)
	end)

	resetButtons[widget] = resetButton
	return resetButton
end

