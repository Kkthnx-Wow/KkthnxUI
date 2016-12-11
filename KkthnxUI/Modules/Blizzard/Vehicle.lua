local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

local Movers = K.Movers

-- Move vehicle indicator
local VehicleAnchor = CreateFrame("Frame", "VehicleAnchor", UIParent)
VehicleAnchor:SetPoint(unpack(C.Position.Vehicle))
VehicleAnchor:SetSize(130, 130)
Movers:RegisterFrame(VehicleAnchor)

hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(_, _, parent)
	if parent == "MinimapCluster" or parent == _G["MinimapCluster"] then
		VehicleSeatIndicator:ClearAllPoints()
		VehicleSeatIndicator:SetPoint("BOTTOM", VehicleAnchor, "BOTTOM", -30, -54)
		VehicleSeatIndicator:SetFrameStrata("LOW")
	end
end)

-- Vehicle indicator on mouseover
if C.Blizzard.VehicleMouseover == true then
	local function VehicleNumSeatIndicator()
		if VehicleSeatIndicatorButton6 then
			K.numSeat = 6
		elseif VehicleSeatIndicatorButton5 then
			K.numSeat = 5
		elseif VehicleSeatIndicatorButton4 then
			K.numSeat = 4
		elseif VehicleSeatIndicatorButton3 then
			K.numSeat = 3
		elseif VehicleSeatIndicatorButton2 then
			K.numSeat = 2
		elseif VehicleSeatIndicatorButton1 then
			K.numSeat = 1
		end
	end

	local function vehmousebutton(alpha)
		for i = 1, K.numSeat do
		local pb = _G["VehicleSeatIndicatorButton"..i]
			pb:SetAlpha(alpha)
		end
	end

	local function vehmouse()
		if VehicleSeatIndicator:IsShown() then
			VehicleSeatIndicator:SetAlpha(0)
			VehicleSeatIndicator:EnableMouse(true)

			VehicleNumSeatIndicator()

			VehicleSeatIndicator:HookScript("OnEnter", function() VehicleSeatIndicator:SetAlpha(1) vehmousebutton(1) end)
			VehicleSeatIndicator:HookScript("OnLeave", function() VehicleSeatIndicator:SetAlpha(0) vehmousebutton(0) end)

			for i = 1, K.numSeat do
				local pb = _G["VehicleSeatIndicatorButton"..i]
				pb:SetAlpha(0)
				pb:HookScript("OnEnter", function(self) VehicleSeatIndicator:SetAlpha(1) vehmousebutton(1) end)
				pb:HookScript("OnLeave", function(self) VehicleSeatIndicator:SetAlpha(0) vehmousebutton(0) end)
			end
		end
	end
	hooksecurefunc("VehicleSeatIndicator_Update", vehmouse)
end