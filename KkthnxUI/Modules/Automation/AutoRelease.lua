local K, C, L = unpack(select(2, ...))
if C["Automation"].AutoRelease ~= true then
	return
end

local Module = K:NewModule("AutoRelease", "AceEvent-3.0")

local _G = _G

local IsInInstance = _G.IsInInstance

-- Auto release the spirit in battlegrounds
function Module:PLAYER_DEAD()
	-- If player has ability to self-resurrect (soulstone, reincarnation, etc), do nothing and quit
	if C_DeathInfo.GetSelfResurrectOptions() and #C_DeathInfo.GetSelfResurrectOptions() > 0 then
		return
	end

	-- Resurrect if player is in a battleground
	local InstStat, InstType = IsInInstance()
	if InstStat and InstType == "pvp" then
		RepopMe()
		return
	end

	-- Resurrect if playuer is in a PvP location
	local areaID = C_Map.GetBestMapForUnit("player") or 0
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

function Module:OnEnable()
	self:RegisterEvent("PLAYER_DEAD")
end
