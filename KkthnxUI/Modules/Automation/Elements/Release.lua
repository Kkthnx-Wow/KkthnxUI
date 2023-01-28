local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local IsInInstance = _G.IsInInstance
local C_DeathInfo_GetSelfResurrectOptions = _G.C_DeathInfo.GetSelfResurrectOptions
local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit

local function PLAYER_DEAD()
	-- If player has ability to self-resurrect (soulstone, reincarnation, etc), do nothing and quit
	if C_DeathInfo_GetSelfResurrectOptions() and #C_DeathInfo_GetSelfResurrectOptions() > 0 then
		return
	end

	-- Resurrect if player is in a PvP location or battleground
	local InstStat, InstType = IsInInstance()
	local areaID = C_Map_GetBestMapForUnit("player") or 0

	if
		(InstStat and InstType == "pvp")
		or areaID == 123 -- Wintergrasp
		or areaID == 244 -- Tol Barad (PvP)
		or areaID == 588 -- Ashran
		or areaID == 622 -- Stormshield
		or areaID == 624 -- Warspear
	then
		RepopMe()
		return
	end
end

function Module:CreateAutoRelease()
	if C["Automation"].AutoRelease == true then
		K:RegisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	else
		K:UnregisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	end
end
