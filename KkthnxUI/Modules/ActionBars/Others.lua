local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local _G = _G
local GetCVarBool = GetCVarBool
local SetCVar = SetCVar
local CreateFrame = CreateFrame
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS

-- Show empty buttons
local ShowGrid = CreateFrame("Frame")
ShowGrid:RegisterEvent("PLAYER_ENTERING_WORLD")
ShowGrid:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if C.ActionBar.ShowGrid == true then
		ActionButton_HideGrid = K.Noop
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local Button

			Button = _G[format("ActionButton%d", i)]
			Button:SetAttribute("showgrid", 1)
			Button:SetAttribute("statehidden", true)
			Button:Show()
			ActionButton_ShowGrid(Button)

			Button = _G[format("MultiBarRightButton%d", i)]
			Button:SetAttribute("showgrid", 1)
			Button:SetAttribute("statehidden", true)
			Button:Show()
			ActionButton_ShowGrid(Button)

			Button = _G[format("MultiBarBottomRightButton%d", i)]
			Button:SetAttribute("showgrid", 1)
			Button:SetAttribute("statehidden", true)
			Button:Show()
			ActionButton_ShowGrid(Button)

			Button = _G[format("MultiBarLeftButton%d", i)]
			Button:SetAttribute("showgrid", 1)
			Button:SetAttribute("statehidden", true)
			Button:Show()
			ActionButton_ShowGrid(Button)

			Button = _G[format("MultiBarBottomLeftButton%d", i)]
			Button:SetAttribute("showgrid", 1)
			Button:SetAttribute("statehidden", true)
			Button:Show()
			ActionButton_ShowGrid(Button)
		end
	end
end)

if not GetCVarBool("lockActionBars") then
	SetCVar("lockActionBars", 1)
end

-- Vehicle button anchor
local VehicleButtonAnchor = CreateFrame("Frame", "VehicleButtonAnchor", UIParent)
VehicleButtonAnchor:SetPoint(unpack(C.Position.VehicleBar))
VehicleButtonAnchor:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)

-- Vehicle button
local vehicle = CreateFrame("BUTTON", "VehicleButton", UIParent, "SecureActionButtonTemplate")
vehicle:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
vehicle:SetPoint("BOTTOMLEFT", VehicleButtonAnchor, "BOTTOMLEFT", 0, 0)
vehicle:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
vehicle:GetNormalTexture():SetTexCoord(0.2, 0.8, 0.2, 0.8)
vehicle:GetNormalTexture():ClearAllPoints()
vehicle:GetNormalTexture():SetPoint("TOPLEFT", 2, -2)
vehicle:GetNormalTexture():SetPoint("BOTTOMRIGHT", -2, 2)
vehicle:CreateBackdrop(2)
vehicle:StyleButton(false)
vehicle:RegisterForClicks("AnyUp")
vehicle:SetScript("OnClick", function() VehicleExit() end)
RegisterStateDriver(vehicle, "visibility", "[target=vehicle,exists] show;hide")