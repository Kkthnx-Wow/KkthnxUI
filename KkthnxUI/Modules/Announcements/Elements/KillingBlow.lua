-- Unpack the KkthnxUI Engine
local K, C = KkthnxUI[1], KkthnxUI[2]
local Announcements = K:GetModule("Announcements")

-- Cache Lua functions
local bit_band = bit.band
local math_random = math.random

-- Cache WoW API functions
local BossBanner_BeginAnims = BossBanner_BeginAnims
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local DoEmote = DoEmote
local GetAchievementInfo = GetAchievementInfo
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local TopBannerManager_Show = TopBannerManager_Show
local hooksecurefunc = hooksecurefunc

-- List of PvP emotes
-- stylua: ignore start
local pvpEmotes = {
	"ANGRY", "BARK", "BECKON", "BITE", "BONK", "BURP", "BYE", "CACKLE", "CALM", "CHUCKLE",
	"COMFORT", "CRACK", "CUDDLE", "CURTSEY", "FLEX", "GIGGLE", "GLOAT", "GRIN", "GROWL",
	"GUFFAW", "INSULT", "LAUGH", "LICK", "MOCK", "MOO", "MOON", "MOURN", "NO", "NOSEPICK",
	"PITY", "RASP", "ROAR", "ROFL", "RUDE", "SCRATCH", "SHOO", "SIGH", "SLAP", "SMIRK",
	"SNARL", "SNICKER", "SNIFF", "SNUB", "SOOTHE", "TAP", "TAUNT", "TEASE", "THANK",
	"THREATEN", "TICKLE", "VETO", "VIOLIN", "YAWN"
}
-- stylua: ignore end

local battlegroundOpponents = {} -- Table to store opponents in battlegrounds

-- Populate the battleground opponents table
function Announcements:BuildBattlegroundOpponents()
	table.wipe(battlegroundOpponents)
	for index = 1, GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = GetBattlefieldScore(index)
		if (K.Faction == "Horde" and faction == 1) or (K.Faction == "Alliance" and faction == 0) then
			battlegroundOpponents[name] = classToken
		end
	end
end

-- Handle combat log events for killing blows
function Announcements:OnCombatLogEvent()
	local _, eventType, _, _, caster, _, _, _, targetName, targetFlags = CombatLogGetCurrentEventInfo()

	if eventType == "PARTY_KILL" and caster == K.Name then
		local isPlayer = bit_band(targetFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
		local isBattlegroundOpponent = battlegroundOpponents[targetName] ~= nil

		if isPlayer or isBattlegroundOpponent then
			if isBattlegroundOpponent then
				local classColor = RAID_CLASS_COLORS[battlegroundOpponents[targetName]]
				targetName = string.format("|c%s%s|r", classColor.colorStr, targetName)
			end

			if C["Announcements"].KillingBlow then
				TopBannerManager_Show(_G.BossBanner, { name = targetName, mode = "KKUI_PVPKILL" })
			end

			if C["Announcements"].PvPEmote then
				local _, _, _, hasAchievement = GetAchievementInfo(247)
				local emote = hasAchievement and pvpEmotes[math_random(#pvpEmotes)] or "hug"
				DoEmote(emote, targetName)
			end
		end
	end
end

-- Setup the killing blow announcement system
function Announcements:SetupKillingBlowAnnounce()
	hooksecurefunc(_G.BossBanner, "PlayBanner", function(self, data)
		if data and data.mode == "KKUI_PVPKILL" then
			self.Title:SetText(data.name)
			self.Title:Show()
			self.SubTitle:Hide()
			self:Show()
			BossBanner_BeginAnims(self)
			PlaySound(SOUNDKIT.UI_RAID_BOSS_DEFEATED)
		end
	end)

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent)
	K:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", self.BuildBattlegroundOpponents)
end
