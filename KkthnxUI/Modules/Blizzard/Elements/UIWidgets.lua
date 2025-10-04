local K = KkthnxUI[1]
local Module = K:GetModule("Blizzard")

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UIParent = UIParent

-- Reanchor UIWidgets
function Module:CreateUIWidgets()
	-- Create a frame to move the UIWidgetFrame to a more desirable location
	local frame1 = CreateFrame("Frame", "KKUI_WidgetMover", UIParent)
	frame1:SetSize(200, 50)
	K.Mover(frame1, "UIWidgetFrame", "UIWidgetFrame", { "TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -28 })

	-- Hook the SetPoint method of UIWidgetBelowMinimapContainerFrame to make sure it's always positioned correctly
	hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", function(self, _, parent)
		if parent ~= frame1 then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame1)
		end
	end)

	-- Create a frame to move the UIWidgetPowerBar to a more desirable location
	local frame2 = CreateFrame("Frame", "KKUI_WidgetPowerBarMover", UIParent)
	frame2:SetSize(260, 40)
	K.Mover(frame2, "UIWidgetPowerBar", "UIWidgetPowerBar", { "BOTTOM", UIParent, "BOTTOM", 0, 250 })

	-- Hook the SetPoint method of UIWidgetPowerBarContainerFrame to make sure it's always positioned correctly
	local isUpdating = false
	local WidgetPositionFrame = CreateFrame("Frame", "WidgetPositionFrame")

	local function UpdateWidgetPosition()
		if isUpdating or InCombatLockdown() or not UIWidgetPowerBarContainerFrame or not frame2 then
			return
		end
		local widget = UIWidgetPowerBarContainerFrame
		local point, relativeTo, relativePoint, x, y = widget:GetPoint()
		local scale = widget:GetScale()
		if point ~= "CENTER" or relativeTo ~= frame2 or x ~= 0 or y ~= 0 or scale ~= 0.8 then
			isUpdating = true
			widget:ClearAllPoints()
			widget:SetPoint("CENTER", frame2)
			widget:SetScale(0.8)
			isUpdating = false
		else
			WidgetPositionFrame:UnregisterEvent("UPDATE_UI_WIDGET")
		end
	end

	hooksecurefunc(UIWidgetPowerBarContainerFrame, "SetPoint", UpdateWidgetPosition)
	WidgetPositionFrame:RegisterEvent("UPDATE_UI_WIDGET")
	WidgetPositionFrame:SetScript("OnEvent", UpdateWidgetPosition)
end
