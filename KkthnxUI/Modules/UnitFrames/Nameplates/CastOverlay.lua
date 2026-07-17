--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Lift nameplate cast bars to UIParent so casts render above neighbors.
-- - Design: Reparent bar + labelAnchor together (text must share HIGH strata or it
--   draws under other plates). Restore both on clear / setting off.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local LIFT_STRATA = "HIGH"

local function castOverlayEnabled()
	return C["Nameplate"].CastOverlay == true
end

local function getLift(plate)
	local lift = plate._castLift
	if not lift then
		lift = CreateFrame("Frame", nil, UIParent)
		lift:SetFrameStrata(LIFT_STRATA)
		lift:SetIgnoreParentScale(true)
		lift:SetSize(1, 1)
		lift:EnableMouse(false)
		if lift.EnableMouseMotion then
			lift:EnableMouseMotion(false)
		end
		plate._castLift = lift
	end
	return lift
end

local function liftCastLabels(cast, strata)
	local anchor = cast.labelAnchor
	if not anchor then
		return
	end
	-- Labels are children of the castbar; strata follows the bar once reparented.
	-- Explicit SetFrameStrata keeps them above neighbors if Blizzard reassigns levels.
	anchor:SetFrameStrata(strata)
	if cast.Text then
		cast.Text:SetDrawLayer("OVERLAY", 7)
	end
	if cast.Time then
		cast.Time:SetDrawLayer("OVERLAY", 7)
	end
end

local function restoreCastLabels(cast, plate)
	local anchor = cast.labelAnchor
	if not anchor then
		return
	end
	anchor:SetFrameStrata(plate:GetFrameStrata())
end

function Module:RefreshCastOverlay(plate)
	local cast = plate and plate.Castbar
	if not cast then
		return
	end

	if castOverlayEnabled() then
		local lift = getLift(plate)
		if cast:GetParent() ~= lift then
			cast:SetParent(lift)
			cast:SetFrameStrata(LIFT_STRATA)
			plate._castOverlayLifted = true
		end
		liftCastLabels(cast, LIFT_STRATA)
		local scale = plate:GetEffectiveScale()
		if plate._castLiftScale ~= scale then
			plate._castLiftScale = scale
			lift:SetScale(scale)
		end
	elseif plate._castOverlayLifted then
		cast:SetParent(plate)
		cast:SetFrameStrata(plate:GetFrameStrata())
		restoreCastLabels(cast, plate)
		plate._castOverlayLifted = nil
		plate._castLiftScale = nil
	end
end

function Module:ClearAllCastOverlays()
	local platesList = Module.NP and Module.NP.platesList
	if not platesList then
		return
	end
	for plate in pairs(platesList) do
		if plate._castOverlayLifted and plate.Castbar then
			plate.Castbar:SetParent(plate)
			plate.Castbar:SetFrameStrata(plate:GetFrameStrata())
			restoreCastLabels(plate.Castbar, plate)
			plate._castOverlayLifted = nil
			plate._castLiftScale = nil
		end
	end
end

function Module:RefreshAllCastOverlays()
	local platesList = Module.NP and Module.NP.platesList
	if not platesList then
		return
	end
	for plate in pairs(platesList) do
		Module:RefreshCastOverlay(plate)
	end
end
