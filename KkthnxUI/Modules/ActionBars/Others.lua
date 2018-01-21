local K, C, L = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then return end

-- Lua API
local _G = _G
local string_format = string.format

-- Wow API
local CanExitVehicle = _G.CanExitVehicle
local CreateFrame = _G.CreateFrame
local GetActionBarToggles = _G.GetActionBarToggles
local InCombatLockdown = _G.InCombatLockdown
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local SetActionBarToggles = _G.SetActionBarToggles
local SetCVar = _G.SetCVar
local StaticPopup_Show =_G.StaticPopup_Show
local TaxiRequestEarlyLanding = _G.TaxiRequestEarlyLanding
local UnitOnTaxi = _G.UnitOnTaxi
local UIParent = _G.UIParent

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIData, ActionButton_ShowGrid, VehicleExit, LeaveVehicleButton
-- GLOBALS: MainMenuBarVehicleLeaveButton_OnEnter, GameTooltip_Hide

local Movers = K.Movers
local Name = UnitName("Player")
local Realm = GetRealmName()

-- Show empty buttons
local ActionBars = CreateFrame("Frame")
ActionBars:RegisterEvent("PLAYER_ENTERING_WORLD")
ActionBars:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	SetActionBarToggles(1, 1, 1, 1, 0)

	local IsInstalled = KkthnxUIData[Realm][Name].InstallComplete
	if IsInstalled then
		local b1, b2, b3, b4 = GetActionBarToggles()
		if (not b1 or not b2 or not b3 or not b4) then
			SetActionBarToggles(1, 1, 1, 1, 0)
			StaticPopup_Show("FIX_ACTIONBARS")
		end
	end

	if C["ActionBar"].Grid == true then
		SetCVar("alwaysShowActionBars", 1)

		for i = 1, 12 do
			local button = _G[format("ActionButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarBottomRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarBottomLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
		end
	else
		SetCVar("alwaysShowActionBars", 0)
	end
end)

-- Vehicle button stuff
local VehicleButtonAnchor = CreateFrame("Frame", "VehicleButtonAnchor", UIParent)
VehicleButtonAnchor:SetPoint("BOTTOMRIGHT", "ActionButton1", "BOTTOMLEFT", -6, 0)
VehicleButtonAnchor:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
if VehicleButtonAnchor then
	Movers:RegisterFrame(VehicleButtonAnchor)
end

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

local function UpdateVehicleLeave()
	local button = LeaveVehicleButton
	if not button then return end

	button:ClearAllPoints()
	button:SetPoint("BOTTOMLEFT", VehicleButtonAnchor, "BOTTOMLEFT")
	button:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
end

local function CreateVehicleLeave()
	local vehicle = CreateFrame("Button", "LeaveVehicleButton", UIParent)
	vehicle:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
	vehicle:SetFrameStrata("HIGH")
	vehicle:SetPoint("BOTTOMLEFT", VehicleButtonAnchor, "BOTTOMLEFT")
	vehicle:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	vehicle:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
	vehicle:GetNormalTexture():ClearAllPoints()
	vehicle:GetNormalTexture():SetAllPoints()
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

	UpdateVehicleLeave()

	vehicle:Hide()
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	CreateVehicleLeave()
end)