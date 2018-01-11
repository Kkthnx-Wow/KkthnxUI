local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("KillingBlow", "AceHook-3.0", "AceEvent-3.0")
if C["Misc"].KillingBlow ~= true then return end

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

-- Lua API
local _G = _G
local bit_band = _G.bit.band
local hooksecurefunc = _G.hooksecurefunc

local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
local GetBattlefieldScore = _G.GetBattlefieldScore
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local PlaySound = _G.PlaySound

-- GLOBALS: COMBATLOG_OBJECT_TYPE_PLAYER, TopBannerManager_Show, BossBanner_BeginAnims

-- We need to check these for overkill damage in cases where
-- PARTY_KILL for some reason refuse to fire.
local damageEvents = {
	SWING_DAMAGE = true,
	RANGE_DAMAGE = true,
	SPELL_DAMAGE = true,
	SPELL_BUILDING_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true
}

local playerGUID = UnitGUID("player")
local unitFilter = COMBATLOG_OBJECT_CONTROL_PLAYER
local FactionToken = UnitFactionGroup("player")
local BG_Opponents = {}

function Module:OpponentsTable()
	table.wipe(BG_Opponents)
	for index = 1, _G.GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = _G.GetBattlefieldScore(index)
		if (FactionToken == "Horde" and faction == 1) or (FactionToken == "Alliance" and faction == 0) then
			BG_Opponents[name] = classToken
		end
	end
end

function Module:LogParse(event, ...)
	local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags = ...

	local mask = bit.band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER)
	local isKillingBlow

	-- Note that UnitIsPlayer
	if ((subEvent == "PARTY_KILL") and (sourceGUID == playerGUID) and (BG_Opponents[destName] or mask > 0) and (bit_band(destFlags, unitFilter) and _G.UnitIsPlayer(destName))) then

		if mask > 0 and BG_Opponents[destName] then
			destName = "|c"..RAID_CLASS_COLORS[BG_Opponents[destName]].colorStr..destName.."|r"
		end

		_G.TopBannerManager_Show(_G["BossBanner"], {name = destName, mode = "PVPKILL"})
		isKillingBlow = true

		-- Workarounds for situations where the PARTY_KILL event won't fire
	elseif damageEvents[subEvent] then
		local overkill = _G.select(16, ...)
		if (overkill and overkill > 0) then
			if ((sourceGUID == playerGUID) or (sourceGUID == _G.UnitGUID("pet"))) and (bit_band(destFlags, unitFilter) and _G.UnitIsPlayer(destName)) then

				if mask > 0 and BG_Opponents[destName] then
					destName = "|c"..RAID_CLASS_COLORS[BG_Opponents[destName]].colorStr..destName.."|r"
				end

				_G.TopBannerManager_Show(_G["BossBanner"], {name = destName, mode = "PVPKILL"})
				isKillingBlow = true
			end
		end
	end
end

function Module:OnInitialize()
	_G.hooksecurefunc(_G["BossBanner"], "PlayBanner", function(self, data)
		if data then
			if isKillingBlow then
				self.Title:SetText(data.name)
				self.Title:Show()
				self.SubTitle:Hide()
				self:Show()

				BossBanner_BeginAnims(self)
				PlaySound("UI_Raid_Boss_Defeated")
			end
		end
	end)

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "LogParse")
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", "OpponentsTable")
end