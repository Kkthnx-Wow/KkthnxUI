local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- LUA API
local _G = _G
local format = string.format
local unpack = unpack

-- WOW API
local CreateFrame = CreateFrame
local Movers = K["Movers"]

StaticPopupDialogs["FIX_ACTIONBARS"] = {
	text = L_POPUP_FIX_ACTIONBARS,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ReloadUI,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

-- SHOW EMPTY BUTTONS
local ShowGrid = CreateFrame("Frame")
ShowGrid:RegisterEvent("PLAYER_ENTERING_WORLD")
ShowGrid:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	local Installed = SavedOptionsPerChar.Install
	if Installed then
		local b1, b2, b3, b4 = GetActionBarToggles()
		if (not b1 or not b2 or not b3 or not b4) then
			SetActionBarToggles(1, 1, 1, 1)
			StaticPopup_Show("FIX_ACTIONBARS")
		end
	end

	for i = 1, 12 do
		local button = _G[format("ActionButton%d", i)]
		button:SetAttribute("showgrid", 1)
		button:SetAttribute("statehidden", true)
		button:Show()
		ActionButton_ShowGrid(button)

		button = _G[format("MultiBarRightButton%d", i)]
		button:SetAttribute("showgrid", 1)
		button:SetAttribute("statehidden", true)
		button:Show()
		ActionButton_ShowGrid(button)

		button = _G[format("MultiBarBottomRightButton%d", i)]
		button:SetAttribute("showgrid", 1)
		button:SetAttribute("statehidden", true)
		button:Show()
		ActionButton_ShowGrid(button)

		button = _G[format("MultiBarLeftButton%d", i)]
		button:SetAttribute("showgrid", 1)
		button:SetAttribute("statehidden", true)
		button:Show()
		ActionButton_ShowGrid(button)

		button = _G[format("MultiBarBottomLeftButton%d", i)]
		button:SetAttribute("showgrid", 1)
		button:SetAttribute("statehidden", true)
		button:Show()
		ActionButton_ShowGrid(button)
	end
end)

-- VEHICLE BUTTON ANCHOR
local VehicleButtonAnchor = CreateFrame("Frame", "VehicleButtonAnchor", UIParent)
VehicleButtonAnchor:SetPoint(unpack(C.Position.VehicleBar))
VehicleButtonAnchor:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
Movers:RegisterFrame(VehicleButtonAnchor)

-- VEHICLE BUTTON
local vehicle = CreateFrame("Button", "VehicleButton", UIParent)
vehicle:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
vehicle:SetPoint("BOTTOMLEFT", VehicleButtonAnchor, "BOTTOMLEFT")
vehicle:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
vehicle:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
vehicle:GetNormalTexture():ClearAllPoints()
vehicle:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
vehicle:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
vehicle:CreateBackdrop(2)
vehicle:StyleButton(true)
vehicle:RegisterForClicks("AnyUp")
vehicle:SetFrameLevel(3)

hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", function()
	if CanExitVehicle() then
		if UnitOnTaxi("player") then
			vehicle:SetScript("OnClick", function(self)
				TaxiRequestEarlyLanding()
				self:LockHighlight()
			end)
		else
			vehicle:SetScript("OnClick", function(self)
				VehicleExit()
			end)
		end
		vehicle:Show()
	else
		vehicle:Hide()
	end
end)

hooksecurefunc("PossessBar_UpdateState", function()
	for i = 1, NUM_POSSESS_SLOTS do
		local _, name, enabled = GetPossessInfo(i)
		if enabled then
			vehicle:SetScript("OnClick", function()
				CancelUnitBuff("player", name)
			end)
			vehicle:Show()
		else
			vehicle:Hide()
		end
	end
end)

-- SET TOOLTIP
vehicle:SetScript("OnEnter", function(self)
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
vehicle:SetScript("OnLeave", function() GameTooltip:Hide() end)