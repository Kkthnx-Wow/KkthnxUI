local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.leaveVehicle

local _G = _G
local table_insert = _G.table.insert

local CanExitVehicle = _G.CanExitVehicle
local CreateFrame = _G.CreateFrame
local GameTooltip_Hide = _G.GameTooltip_Hide
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

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_LeaveVehicleBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * FilterConfig.size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(FilterConfig.size + 2 * padding)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 260, 4}

	-- The Button
	local button = CreateFrame("CheckButton", "KkthnxUI_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	table_insert(buttonList, button) -- Add The Button Object To The List
	button:SetSize(FilterConfig.size, FilterConfig.size)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:StyleButton()
	button:RegisterForClicks("AnyUp")
	button.icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(.216, .784, .216, .784)
	button:SetNormalTexture(nil)
	button:GetPushedTexture():SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	K.CreateBorder(button)
	button:CreateInnerShadow()

	local function onClick(self)
		if UnitOnTaxi("player") then
			TaxiRequestEarlyLanding()
		else
			VehicleExit()
		end

		self:SetChecked(false)
	end
	button:SetScript("OnClick", onClick)
	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", GameTooltip_Hide)

	-- Frame Visibility
	frame.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
	RegisterStateDriver(frame, "exit", frame.frameVisibility)

	frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
	if not CanExitVehicle() then
		frame:Hide()
	end

	-- Create Drag Frame And Drag Functionality
	if K.ActionBars.userPlaced then
		K.Mover(frame, "LeaveVehicle", "LeaveVehicle", frame.Pos)
	end

	-- create the mouseover functionality
	if FilterConfig.fader then
		K.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end