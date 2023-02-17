local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local C_DeathInfo_GetSelfResurrectOptions = C_DeathInfo.GetSelfResurrectOptions
local IsInInstance, C_Map_GetBestMapForUnit, RepopMe = IsInInstance, C_Map.GetBestMapForUnit, RepopMe

local function PLAYER_DEAD()
	local InstStat, InstType = IsInInstance()
	local areaID = C_Map_GetBestMapForUnit("player") or 0
	local pvpAreas = {
		[123] = true, -- Wintergrasp
		[244] = true, -- Tol Barad (PvP)
		[588] = true, -- Ashran
		[622] = true, -- Stormshield
		[624] = true, -- Warspear
	}

	-- If player has ability to self-resurrect (soulstone, reincarnation, etc), do nothing and quit
	if C_DeathInfo_GetSelfResurrectOptions() and #C_DeathInfo_GetSelfResurrectOptions() > 0 then
		return
	end

	-- Resurrect if player is in a PvP location or battleground
	if (InstStat and InstType == "pvp") or pvpAreas[areaID] then
		RepopMe()
	end
end

function Module:CreateAutoRelease()
	if C["Automation"].AutoRelease == true then
		K:RegisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	else
		K:UnregisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	end
end
