--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Re-anchors Blizzard's UI widget containers (e.g., power bars, info frames).
-- - Design: Creates mover frames and hooks SetPoint methods to force custom positions.
-- - Events: UPDATE_UI_WIDGET
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Blizzard")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local Minimap = _G.Minimap
local UIParent = _G.UIParent
local UIWidgetBelowMinimapContainerFrame = _G.UIWidgetBelowMinimapContainerFrame
local UIWidgetPowerBarContainerFrame = _G.UIWidgetPowerBarContainerFrame
local hooksecurefunc = hooksecurefunc

-- ---------------------------------------------------------------------------
-- UI Widget Anchoring
-- ---------------------------------------------------------------------------
function Module:CreateUIWidgets()
	-- REASON: Manages widgets typically placed below the Minimap (e.g., scenario objectives).
	local minimapWidgetMover = CreateFrame("Frame", "KKUI_WidgetMover", UIParent)
	minimapWidgetMover:SetSize(200, 50)
	K.Mover(minimapWidgetMover, "UIWidgetFrame", "UIWidgetFrame", { "TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -28 })

	-- WARNING: Hook SetPoint to override Blizzard's internal frame management which often resets positions during scenarios.
	if UIWidgetBelowMinimapContainerFrame then
		hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", function(self, _, parent)
			if parent ~= minimapWidgetMover then
				self:ClearAllPoints()
				self:SetPoint("TOPRIGHT", minimapWidgetMover)
			end
		end)
	end

	-- REASON: Manages widgets that act as power bars (e.g., encounter-specific energy).
	local powerBarWidgetMover = CreateFrame("Frame", "KKUI_WidgetPowerBarMover", UIParent)
	powerBarWidgetMover:SetSize(260, 40)
	K.Mover(powerBarWidgetMover, "UIWidgetPowerBar", "UIWidgetPowerBar", { "BOTTOM", UIParent, "BOTTOM", 0, 250 })

	local isUpdating = false
	local widgetPositionFrame = CreateFrame("Frame", "WidgetPositionFrame")

	local function updateWidgetPosition()
		-- REASON: Throttles position updates to prevent infinite recursions and combat-related errors.
		if isUpdating or InCombatLockdown() or not UIWidgetPowerBarContainerFrame or not powerBarWidgetMover then
			return
		end

		local widget = UIWidgetPowerBarContainerFrame
		local point, relativeTo, _, x, y = widget:GetPoint()
		local scale = widget:GetScale()

		-- REASON: Enforces a consistent center-anchor and custom scale (0.8) for encounter power bars.
		if point ~= "CENTER" or relativeTo ~= powerBarWidgetMover or x ~= 0 or y ~= 0 or scale ~= 0.8 then
			isUpdating = true
			widget:ClearAllPoints()
			widget:SetPoint("CENTER", powerBarWidgetMover)
			widget:SetScale(0.8)
			isUpdating = false
		else
			-- REASON: Avoid unnecessary event processing once the correct position is reached.
			widgetPositionFrame:UnregisterEvent("UPDATE_UI_WIDGET")
		end
	end

	if UIWidgetPowerBarContainerFrame then
		hooksecurefunc(UIWidgetPowerBarContainerFrame, "SetPoint", updateWidgetPosition)
		widgetPositionFrame:RegisterEvent("UPDATE_UI_WIDGET")
		widgetPositionFrame:SetScript("OnEvent", updateWidgetPosition)
	end
end
