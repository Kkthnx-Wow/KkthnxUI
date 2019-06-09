local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = table.insert

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
	local padding, margin, size = 0, 5, 34
	local num = 1
	local buttonList = {}

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_LeaveVehicleBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	if C["ActionBar"].Style.Value == 3 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 130}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 320, 100}
	end
	frame:SetScale(1)

	-- The Button
	local button = CreateFrame("CheckButton", "KkthnxUI_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	table_insert(buttonList, button) -- Add The Button Object To The List
	--button:SetFrameStrata("HIGH")
	button:SetSize(size, size)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:StyleButton()
	button:RegisterForClicks("AnyUp")
	button.icon:SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(.216, .784, .216, .784)
	button:SetNormalTexture(nil)
	button:GetPushedTexture():SetTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	--button:CreateBorder()
	K.CreateBorder(button)

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
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "Vehicle", "Vehicle", frame.Pos)
end