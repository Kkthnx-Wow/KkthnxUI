local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

-- Wow Lua
local _G = _G

-- Wow API
local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc

local Movers = K.Movers

--No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: VehicleSeatIndicator, MinimapCluster, VehicleSeatMover

local VehicleIndicator = CreateFrame("Frame", nil, UIParent)
VehicleIndicator:RegisterEvent("PLAYER_LOGIN")
VehicleIndicator:SetScript("OnEvent", function(self)
	local function VehicleSeatIndicator_SetPosition(_, _, parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			VehicleSeatIndicator:ClearAllPoints()

			if VehicleSeatMover then
				VehicleSeatIndicator:SetPoint("TOPLEFT", VehicleSeatMover, "TOPLEFT", 0, 0)
			else
				VehicleSeatIndicator:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 22, -45)
				Movers:RegisterFrame(VehicleSeatIndicator)
			end

			VehicleSeatIndicator:SetScale(0.8)
		end
	end
	hooksecurefunc(VehicleSeatIndicator,"SetPoint", VehicleSeatIndicator_SetPosition)

	VehicleSeatIndicator:SetPoint("TOPLEFT", MinimapCluster, "TOPLEFT", 2, 2) -- initialize mover
end)