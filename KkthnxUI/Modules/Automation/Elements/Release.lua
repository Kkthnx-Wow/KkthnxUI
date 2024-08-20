local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local C_DeathInfo_GetSelfResurrectOptions = C_DeathInfo.GetSelfResurrectOptions
local IsInInstance = IsInInstance
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local RepopMe = RepopMe

-- List of PvP areas by their map IDs
local pvpAreas = {
	[123] = true, -- Wintergrasp
	[244] = true, -- Tol Barad (PvP)
	[588] = true, -- Ashran
	[622] = true, -- Stormshield
	[624] = true, -- Warspear
}

local function PLAYER_DEAD()
	-- Check if self-resurrection options exist (soulstone, reincarnation, etc.)
	if C_DeathInfo_GetSelfResurrectOptions() and #C_DeathInfo_GetSelfResurrectOptions() > 0 then
		return -- Player can self-resurrect, do nothing
	end

	local isInstance, instanceType = IsInInstance()
	local areaID = C_Map_GetBestMapForUnit("player")

	-- Automatically release if in a PvP location or battleground
	if (isInstance and instanceType == "pvp") or (areaID and pvpAreas[areaID]) then
		RepopMe()
	end
end

function Module:CreateAutoRelease()
	if C["Automation"].AutoRelease then
		K:RegisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	else
		K:UnregisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	end
end
