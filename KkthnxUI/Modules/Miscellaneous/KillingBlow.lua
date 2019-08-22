local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

local _G = _G
local bit_band = _G.bit.band
local table_wipe = _G.table.wipe

local BossBanner_BeginAnims = _G.BossBanner_BeginAnims
local COMBATLOG_OBJECT_TYPE_PLAYER = _G.COMBATLOG_OBJECT_TYPE_PLAYER
local PlaySound = _G.PlaySound
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local SOUNDKIT = _G.SOUNDKIT
local hooksecurefunc = _G.hooksecurefunc

local BG_Opponents = {}
function Module.UPDATE_BATTLEFIELD_SCORE()
	table_wipe(BG_Opponents)
	for index = 1, _G.GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = _G.GetBattlefieldScore(index)
		if (K.Faction == "Horde" and faction == 1) or (K.Faction == "Alliance" and faction == 0) then
			BG_Opponents[name] = classToken
		end
	end
end

function Module.COMBAT_LOG_EVENT_UNFILTERED()
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

function Module:CreateKillingBlow()
	if C["Misc"].KillingBlow ~= true then
		return
	end

	hooksecurefunc(_G["BossBanner"], "PlayBanner", function(self, data)
		if (data) then
			if (data.mode == "PVPKILL") then
				self.Title:SetText(data.name)
				self.Title:Show()
				self.SubTitle:Hide()
				self:Show()
				BossBanner_BeginAnims(self)
				PlaySound(SOUNDKIT.UI_RAID_BOSS_DEFEATED)
			end
		end
	end)

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.COMBAT_LOG_EVENT_UNFILTERED)
	K:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", self.UPDATE_BATTLEFIELD_SCORE)
end
