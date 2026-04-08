--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Custom button to exit vehicles, mounts, or taxis.
-- - Design: Uses a SecureHandlerStateTemplate to toggle visibility based on exit capability.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("ActionBar")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

local tinsert = tinsert
local UnitOnTaxi, TaxiRequestEarlyLanding, VehicleExit = UnitOnTaxi, TaxiRequestEarlyLanding, VehicleExit
local padding = 0

-- ---------------------------------------------------------------------------
-- VEHICLE EXIT BUTTON
-- ---------------------------------------------------------------------------

-- REASON: Updates the dimensions and mover size for the exit button when settings change.
function Module:UpdateVehicleButton()
	local frame = _G["KKUI_ActionBarExit"]
	if not frame then
		return
	end

	local size = C["ActionBar"]["VehButtonSize"]
	local framSize = size + 2 * padding
	frame.buttons[1]:SetSize(size, size)
	frame:SetSize(framSize, framSize)
	frame.mover:SetSize(framSize, framSize)
end

-- REASON: Creates the secure button that allows players to exit vehicles/mounts during combat safely.
function Module:CreateLeaveVehicle()
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBarExit", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "LeaveVehicle", "LeaveVehicle", { "BOTTOM", UIParent, "BOTTOM", 320, 6 })

	-- NOTE: Use ActionButtonTemplate for consistent styling and SecureHandlerClickTemplate for secure execution.
	local button = CreateFrame("CheckButton", "KKUI_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	tinsert(buttonList, button)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:RegisterForClicks("AnyUp")

	-- Stylize the icon with the default Blizzard exit texture.
	button.icon:SetTexture("INTERFACE\\VEHICLES\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(0.216, 0.784, 0.216, 0.784)
	button.icon:SetDrawLayer("ARTWORK")
	button.icon.__lockdown = true -- WARNING: Critical to prevent other modules from accidentally changing the texture.

	if button.Arrow then
		button.Arrow:SetAlpha(0)
	end

	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton.OnEnter)
	button:SetScript("OnLeave", K.HideTooltip)

	-- REASON: Handle diverse exit scenarios (taxi vs standard vehicle).
	button:SetScript("OnClick", function(self)
		if UnitOnTaxi("player") then
			TaxiRequestEarlyLanding()
		else
			VehicleExit()
		end
		self:SetChecked(true)
	end)

	button:SetScript("OnShow", function(self)
		self:SetChecked(false)
	end)

	frame.buttons = buttonList

	-- ---------------------------------------------------------------------------
	-- STATE DRIVER
	-- ---------------------------------------------------------------------------

	-- NOTE: State driver evaluates if the player is in a state where exiting is possible.
	frame.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
	RegisterStateDriver(frame, "exit", frame.frameVisibility)

	-- REASON: Using a secure snippet ensures the button is shown/hidden without causing taint in combat.
	frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
	if not CanExitVehicle() then
		frame:Hide()
	end
end
