local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local IsInInstance = _G.IsInInstance
local C_DeathInfo_GetSelfResurrectOptions = _G.C_DeathInfo.GetSelfResurrectOptions
local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit

local function PLAYER_DEAD()
	-- If player has ability to self-resurrect (soulstone, reincarnation, etc), do nothing and quit
	if C_DeathInfo_GetSelfResurrectOptions() and #C_DeathInfo_GetSelfResurrectOptions() > 0 then
		return
	end

	-- Resurrect if player is in a battleground
	local InstStat, InstType = IsInInstance()
	if InstStat and InstType == "pvp" then
		RepopMe()
		return
	end

	-- Resurrect if playuer is in a PvP location
	local areaID = C_Map_GetBestMapForUnit("player") or 0
	if areaID == 123 -- Wintergrasp
	or areaID == 244 -- Tol Barad (PvP)
	or areaID == 588 -- Ashran
	or areaID == 622 -- Stormshield
	or areaID == 624 -- Warspear
	then
		RepopMe()
		return
	end
	return
end


function Module:CreateAutoRelease()
	if C["Automation"].AutoRelease == true then
		K:RegisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	else
		K:UnregisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	end
end