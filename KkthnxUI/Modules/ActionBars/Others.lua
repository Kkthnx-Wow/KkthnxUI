local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

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
-- GLOBALS: KkthnxUIDataPerChar, ActionButton_ShowGrid, VehicleExit, LeaveVehicleButton
-- GLOBALS: MainMenuBarVehicleLeaveButton_OnEnter, GameTooltip_Hide

local Movers = K.Movers

StaticPopupDialogs["FIX_ACTIONBARS"] = {
	text = L.Popup.FixActionbars,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ReloadUI,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

-- Show empty buttons
local ActionBars = CreateFrame("Frame")
ActionBars:RegisterEvent("PLAYER_ENTERING_WORLD")
ActionBars:SetScript("OnEvent", function(self, event)
	local Installed = KkthnxUIDataPerChar.Install
	if Installed then
		local b1, b2, b3, b4 = GetActionBarToggles()
		if (not b1 or not b2 or not b3 or not b4) then
			SetActionBarToggles(true, true, true, true)
			StaticPopup_Show("FIX_ACTIONBARS")
		end
	end

	if C.ActionBar.Grid == true then
		if not InCombatLockdown() then
			SetCVar("alwaysShowActionBars", 1)
		end

		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local button = _G[string_format("ActionButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarBottomRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarBottomLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
		end
	else
		if not InCombatLockdown() then
			SetCVar("alwaysShowActionBars", 0)
		end
	end
end)

-- Vehicle button stuff
local VehicleButtonAnchor = CreateFrame("Frame", "VehicleButtonAnchor", UIParent)
VehicleButtonAnchor:SetPoint(C.Position.VehicleBar[1], C.Position.VehicleBar[2], C.Position.VehicleBar[3], C.Position.VehicleBar[4], C.Position.VehicleBar[5])
VehicleButtonAnchor:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
Movers:RegisterFrame(VehicleButtonAnchor)

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
	button:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
end

local function CreateVehicleLeave()
	local vehicle = CreateFrame("Button", "LeaveVehicleButton", UIParent)
	vehicle:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
	vehicle:SetFrameStrata("HIGH")
	vehicle:SetPoint("BOTTOMLEFT", VehicleButtonAnchor, "BOTTOMLEFT")
	vehicle:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	vehicle:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
	vehicle:GetNormalTexture():ClearAllPoints()
	vehicle:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
	vehicle:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
	vehicle:CreateBackdrop(2)
	vehicle:StyleButton(true)
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