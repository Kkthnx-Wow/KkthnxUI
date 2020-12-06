local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local C_Map_HasUserWaypoint = _G.C_Map.HasUserWaypoint
local C_SuperTrack_SetSuperTrackedUserWaypoint = _G.C_SuperTrack.SetSuperTrackedUserWaypoint
local C_Timer_After = _G.C_Timer.After
local IsAddOnLoaded = _G.IsAddOnLoaded

local function SetupSuperTracked()
	C_SuperTrack_SetSuperTrackedUserWaypoint(true)
end

local function UserHasWayPoint()
	if C_Map_HasUserWaypoint() == true then
		C_Timer_After(0.1, SetupSuperTracked)
	end
end

function Module:CreateAutoMapPin()
	if IsAddOnLoaded("AutoTrackMapPin") then
		return
	end

	if C["Automation"].AutoTrackPin then
		K:RegisterEvent("USER_WAYPOINT_UPDATED", UserHasWayPoint)
	else
		K:RegisterEvent("USER_WAYPOINT_UPDATED", UserHasWayPoint)
	end
end