local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.leaveVehicle

local _G = _G
local table_insert = _G.table.insert

local CanExitVehicle = _G.CanExitVehicle
local CreateFrame = _G.CreateFrame
local MainMenuBarVehicleLeaveButton_OnEnter = _G.MainMenuBarVehicleLeaveButton_OnEnter
local RegisterStateDriver = _G.RegisterStateDriver
local TaxiRequestEarlyLanding = _G.TaxiRequestEarlyLanding
local UIParent = _G.UIParent
local UnitOnTaxi = _G.UnitOnTaxi
local VehicleExit = _G.VehicleExit

function Module:CreateLeaveVehicle()
	local padding, margin = 0, 5
	local num = 1
	local buttonList = {}
	local buttonSize = C["ActionBar"].DefaultButtonSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KKUI_LeaveVehicleBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * buttonSize + (num - 1) * margin + 2 * padding)
	frame:SetHeight(buttonSize + 2 * padding)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 260, 4}

	-- The Button
	local button = CreateFrame("CheckButton", "KKUI_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	table_insert(buttonList, button) -- Add The Button Object To The List
	button:SetSize(buttonSize, buttonSize)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:StyleButton()
	button:RegisterForClicks("AnyUp")

	button.icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(.216, .784, .216, .784)

	button.icon.__lockdown = true

	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", K.HideTooltip)
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

	-- Frame Visibility
	frame.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
	RegisterStateDriver(frame, "exit", frame.frameVisibility)

	frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
	if not CanExitVehicle() then
		frame:Hide()
	end

	-- Create Drag Frame And Drag Functionality
	if K.ActionBars.userPlaced then
		frame.mover = K.Mover(frame, "LeaveVehicle", "LeaveVehicle", frame.Pos)
	end

	-- create the mouseover functionality
	if FilterConfig.fader then
		K.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end