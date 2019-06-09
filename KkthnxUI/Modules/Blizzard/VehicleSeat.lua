local K, C = unpack(select(2, ...))
local Module = K:NewModule("VehicleSeat", "AceEvent-3.0")

-- Wow Lua
local _G = _G

-- Wow API
local UIParent = _G.UIParent

function Module:PositionVehicleFrame()
	local VehicleSeatMover = CreateFrame("Frame", "VehicleSeatMover", UIParent)
	VehicleSeatMover:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -4)
	VehicleSeatMover:SetWidth((VehicleSeatIndicator:GetWidth() - 25))
	VehicleSeatMover:SetHeight(VehicleSeatIndicator:GetHeight() - 25)

	VehicleSeatIndicator:ClearAllPoints()
	VehicleSeatIndicator:SetPoint("CENTER", VehicleSeatMover, "CENTER", 0, 0)
	VehicleSeatIndicator:SetScale(0.8)

	-- This will block UIParent_ManageFramePositions() to be executed
	VehicleSeatIndicator.IsShown = function()
		return false
	end

	K.Mover(VehicleSeatMover, "VehicleSeat", "VehicleSeat", {"TOPLEFT", UIParent, "TOPLEFT", 4, -4})
end

function Module:OnInitialize()
	self:PositionVehicleFrame()
end
