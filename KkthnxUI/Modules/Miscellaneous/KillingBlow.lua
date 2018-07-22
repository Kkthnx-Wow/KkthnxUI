local K, C, L = unpack(select(2, ...))
if C["Misc"].KillingBlow ~= true then
	return
end

local Module = K:NewModule("KillingBlow", "AceEvent-3.0")

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

local _G = _G
local bit_band = bit.band
local table_wipe = table.wipe
local hooksecurefunc = _G.hooksecurefunc

local BossBanner_BeginAnims = _G.BossBanner_BeginAnims
local COMBATLOG_OBJECT_TYPE_PLAYER = _G.COMBATLOG_OBJECT_TYPE_PLAYER
local PlaySound = _G.PlaySound
local PlaySoundKitID = _G.PlaySoundKitID
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local SOUNDKIT = _G.SOUNDKIT
local TopBannerManager_Show = _G.TopBannerManager_Show

local BG_Opponents = {}
local FactionToken = _G.UnitFactionGroup("player")

function Module:UPDATE_BATTLEFIELD_SCORE()
	table_wipe(BG_Opponents)
	for index = 1, _G.GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = _G.GetBattlefieldScore(index)
		if (FactionToken == "Horde" and faction == 1) or (FactionToken == "Alliance" and faction == 0) then
			BG_Opponents[name] = classToken
		end
	end
end

function Module:COMBAT_LOG_EVENT_UNFILTERED()
	local _, subevent, _, _, Caster, _, _, _, TargetName, TargetFlags = CombatLogGetCurrentEventInfo()

	if subevent == "PARTY_KILL" then
		local mask = bit_band(TargetFlags, COMBATLOG_OBJECT_TYPE_PLAYER)
		if Caster == K.Name and (BG_Opponents[TargetName] or mask > 0) then
			if mask > 0 and BG_Opponents[TargetName] then
				TargetName = "|c" .. RAID_CLASS_COLORS[BG_Opponents[TargetName]].colorStr .. TargetName .. "|r"
			end

			TopBannerManager_Show(_G["BossBanner"], {name = TargetName, mode = "PVPKILL"})
		end
	end
end

function Module:OnEnable()
	hooksecurefunc(_G["BossBanner"], "PlayBanner", function(self, data)
		if (data) then
			if (data.mode == "PVPKILL") then
				self.Title:SetText(data.name)
				self.Title:Show()
				self.SubTitle:Hide()
				self:Show()
				BossBanner_BeginAnims(self)
				PlaySound(PlaySoundKitID and "UI_Raid_Boss_Defeated" or SOUNDKIT.UI_RAID_BOSS_DEFEATED)
			end
		end
	end)

	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
end