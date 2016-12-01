local K, C, L = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- LUA API
local _G = _G
local format = string.format
local unpack = unpack

-- WOW API
local ActionBars = CreateFrame("Frame")
local CreateFrame = CreateFrame
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
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	local Installed = KkthnxUIDataPerChar.Install
	if Installed then
		local b1, b2, b3, b4 = GetActionBarToggles()
		if (not b1 or not b2 or not b3 or not b4) then
			SetActionBarToggles(1, 1, 1, 1)
			StaticPopup_Show("FIX_ACTIONBARS")
		end
	end

	if C.ActionBar.Grid == true then
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

-- Vehicle button anchor
local VehicleButtonAnchor = CreateFrame("Frame", "VehicleButtonAnchor", UIParent)
VehicleButtonAnchor:SetPoint(unpack(C.Position.VehicleBar))
VehicleButtonAnchor:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
Movers:RegisterFrame(VehicleButtonAnchor)

-- Vehicle button
local Vehicle = CreateFrame("Button", "VehicleButton", UIParent)
Vehicle:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
Vehicle:SetPoint("BOTTOMLEFT", VehicleButtonAnchor, "BOTTOMLEFT")
Vehicle:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
Vehicle:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
Vehicle:GetNormalTexture():ClearAllPoints()
Vehicle:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
Vehicle:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
Vehicle:CreateBackdrop(2)
Vehicle:StyleButton(true)
Vehicle:RegisterForClicks("AnyUp")
Vehicle:SetFrameLevel(3)

hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", function()
	if CanExitVehicle() then
		if UnitOnTaxi("player") then
			Vehicle:SetScript("OnClick", function(self)
				TaxiRequestEarlyLanding()
				self:LockHighlight()
			end)
		else
			Vehicle:SetScript("OnClick", function(self)
				VehicleExit()
			end)
		end
		Vehicle:Show()
	else
		Vehicle:Hide()
	end
end)

hooksecurefunc("PossessBar_UpdateState", function()
	for i = 1, NUM_POSSESS_SLOTS do
		local _, name, enabled = GetPossessInfo(i)
		if enabled then
			Vehicle:SetScript("OnClick", function()
				CancelUnitBuff("player", name)
			end)
			Vehicle:Show()
		else
			Vehicle:Hide()
		end
	end
end)

-- Set tooltip
Vehicle:SetScript("OnEnter", function(self)
	if UnitOnTaxi("player") then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(TAXI_CANCEL, 1, 1, 1)
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, 1, 0.8, 0, true)
		GameTooltip:Show()
	elseif IsPossessBarVisible() then
		GameTooltip_AddNewbieTip(self, CANCEL, 1, 1, 1, nil)
	else
		GameTooltip_AddNewbieTip(self, LEAVE_VEHICLE, 1, 1, 1, nil)
	end
end)
Vehicle:SetScript("OnLeave", function() GameTooltip:Hide() end)
