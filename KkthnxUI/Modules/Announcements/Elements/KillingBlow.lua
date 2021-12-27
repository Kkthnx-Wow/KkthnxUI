local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

local _G = _G
local bit_band = _G.bit.band
local math_random = _G.math.random
local table_wipe = _G.table.wipe

local COMBATLOG_OBJECT_TYPE_PLAYER = _G.COMBATLOG_OBJECT_TYPE_PLAYER
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local DoEmote = _G.DoEmote
local GetAchievementInfo = _G.GetAchievementInfo
local GetBattlefieldScore = _G.GetBattlefieldScore
local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
local PlaySoundFile = _G.PlaySoundFile
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitGUID = _G.UnitGUID
local hooksecurefunc = _G.hooksecurefunc

local pvpEmoteList = {
	"ANGRY", "BARK", "BECKON", "BITE", "BONK", "BURP", "BYE", "CACKLE",
	"CALM", "CHUCKLE", "COMFORT", "CRACK", "CUDDLE", "CURTSEY", "FLEX",
	"GIGGLE", "GLOAT", "GRIN", "GROWL", "GUFFAW", "INSULT",
	"LAUGH", "LICK", "MOCK", "MOO", "MOON", "MOURN",
	"NO", "NOSEPICK", "PITY", "RASP", "ROAR", "ROFL", "RUDE",
	"SCRATCH", "SHOO", "SIGH", "SLAP", "SMIRK", "SNARL",
	"SNICKER", "SNIFF", "SNUB", "SOOTHE", "TAP", "TAUNT",
	"TEASE", "THANK", "THREATEN", "TICKLE", "VETO", "VIOLIN", "YAWN"
}

local BG_Opponents = {}
function Module:OpponentsTable()
	table_wipe(BG_Opponents)
	for index = 1, GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = GetBattlefieldScore(index)
		if (K.Faction == "Horde" and faction == 1) or (K.Faction == "Alliance" and faction == 0) then
			BG_Opponents[name] = classToken
		end
	end
end

function Module:SetupKillingBlow()
	local _, subevent, sourceGUID, _, Caster, _, _, _, TargetName, TargetFlags = CombatLogGetCurrentEventInfo()
	if subevent == "PARTY_KILL" and sourceGUID == UnitGUID("player") then
		local mask = bit_band(TargetFlags, COMBATLOG_OBJECT_TYPE_PLAYER)
		if Caster == K.Name and (BG_Opponents[TargetName] or mask > 0) then
			if mask > 0 and BG_Opponents[TargetName] then
				TargetName = "|c"..RAID_CLASS_COLORS[BG_Opponents[TargetName]].colorStr..TargetName.."|r" or TargetName
				TargetName = TargetName
			end

			if C["Announcements"].KillingBlow then
				TopBannerManager_Show(_G["BossBanner"], {name = TargetName, mode = "PVPKILL"})
			end

			if C["Announcements"].PvPEmote then
				if select(4, GetAchievementInfo(247)) then
					-- Fire off a random emote, to keep it interesting.
					DoEmote(pvpEmoteList[math_random(1, #pvpEmoteList)], TargetName)
				else
					DoEmote("HUG", TargetName)
				end
			end
		end
	end
end

function Module:CreateKillingBlow()
	hooksecurefunc(_G["BossBanner"], "PlayBanner", function(self, data)
		if (data) then
			if (data.mode == "PVPKILL") then
				self.Title:SetText(data.name)
				self.Title:Show()
				self.SubTitle:Hide()
				self:Show()
				BossBanner_BeginAnims(self)
				PlaySoundFile("Interface\\AddOns\\KkthnxUI\\Media\\Sounds\\KillingBlow.ogg", "Master")
			end
		end
	end)

	K:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", self.OpponentsTable)
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.SetupKillingBlow)
end