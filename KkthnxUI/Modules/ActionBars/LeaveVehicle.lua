local K, C, L = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then return end
local Module = K:NewModule("LeaveVehicle", "AceEvent-3.0")

local _G = _G

local UnitOnTaxi = _G.UnitOnTaxi
local TaxiRequestEarlyLanding = _G.TaxiRequestEarlyLanding
local VehicleExit = _G.VehicleExit
local CanExitVehicle = _G.CanExitVehicle
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local function Vehicle_OnEvent(self)
	if (CanExitVehicle()) then
		self:Show()
		self:GetNormalTexture():SetVertexColor(1, 1, 1)
		self:EnableMouse(true)
	else
		self:Hide()
	end
end

local function Vehicle_OnClick(self)
	if (UnitOnTaxi("player")) then
		TaxiRequestEarlyLanding()
		self:GetNormalTexture():SetVertexColor(1, 0, 0)
		self:EnableMouse(false)
	else
		VehicleExit()
	end
end

function Module:UpdateVehicleLeave()
	local button = LeaveVehicleButton
	if not button then return end

	button:ClearAllPoints()
	button:SetPoint("CENTER", VehicleButtonAnchor, "CENTER")
	button:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
end

function Module:CreateVehicleLeave()
	local VehicleButtonAnchor = CreateFrame("Frame", "VehicleButtonAnchor", UIParent)
	VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", "ActionButton1", "BOTTOMLEFT", -6, 0)
	VehicleButtonAnchor:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
	if VehicleButtonAnchor then
		K.Movers:RegisterFrame(VehicleButtonAnchor)
	end

	local vehicle = CreateFrame("Button", "LeaveVehicleButton", UIParent)
	vehicle:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
	vehicle:SetFrameStrata("HIGH")
	vehicle:SetPoint("CENTER", VehicleButtonAnchor, "CENTER")
	vehicle:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	vehicle:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
	vehicle:GetNormalTexture():SetAllPoints()
	vehicle:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	vehicle:GetPushedTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
	vehicle:GetPushedTexture():SetAllPoints()
	vehicle:StyleButton()
	vehicle:SetTemplate("Transparent", true)
	vehicle:RegisterForClicks("AnyUp")

	vehicle:SetScript("OnClick", Vehicle_OnClick)
	vehicle:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	vehicle:SetScript("OnLeave", GameTooltip_Hide)
	vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")
	vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
	vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
	vehicle:RegisterEvent("VEHICLE_UPDATE")
	vehicle:SetScript("OnEvent", Vehicle_OnEvent)

	self:UpdateVehicleLeave()

	vehicle:Hide()
end

function Module:OnInitialize()
	self:CreateVehicleLeave()
end