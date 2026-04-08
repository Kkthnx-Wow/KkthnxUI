--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically releases spirit in battlegrounds and specified PvP zones.
-- - Design: Hooks PLAYER_DEAD and checks the current map/instance type to trigger RepopMe.
-- - Events: PLAYER_DEAD
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local C_DeathInfo_GetSelfResurrectOptions = C_DeathInfo.GetSelfResurrectOptions
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local IsInInstance = IsInInstance
local RepopMe = RepopMe

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
local PVP_AREAS = {
	[123] = true, -- Wintergrasp
	[244] = true, -- Tol Barad (PvP)
	[588] = true, -- Ashran
	[622] = true, -- Stormshield
	[624] = true, -- Warspear
}

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function playerDead()
	-- REASON: Do not auto-release if the player has self-resurrection options (e.g., Soulstone, Reincarnation).
	local resOptions = C_DeathInfo_GetSelfResurrectOptions()
	if resOptions and #resOptions > 0 then
		return
	end

	local isInstance, instanceType = IsInInstance()
	local areaID = C_Map_GetBestMapForUnit("player")

	-- REASON: In Battlegrounds and specific PvP world zones, releasing immediately is standard and desired.
	if (isInstance and instanceType == "pvp") or (areaID and PVP_AREAS[areaID]) then
		RepopMe()
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoRelease()
	-- REASON: Entry point to register for death events based on user configuration.
	if C["Automation"].AutoRelease then
		K:RegisterEvent("PLAYER_DEAD", playerDead)
	else
		K:UnregisterEvent("PLAYER_DEAD", playerDead)
	end
end
