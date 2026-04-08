--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Provides visual and social feedback for PvP killing blows.
-- - Design: Hijacks Blizzard's BossBanner to display victim names and optionally performs emotes.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Announcements = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent math, table, and WoW UI globals.
local bit_band, math_random = bit.band, math.random
local table_wipe = table.wipe
local BossBanner_BeginAnims, DoEmote, GetAchievementInfo, GetBattlefieldScore, GetNumBattlefieldScores, RAID_CLASS_COLORS = BossBanner_BeginAnims, DoEmote, GetAchievementInfo, GetBattlefieldScore, GetNumBattlefieldScores, RAID_CLASS_COLORS
local TopBannerManager_Show, hooksecurefunc, CombatLogGetCurrentEventInfo = TopBannerManager_Show, hooksecurefunc, CombatLogGetCurrentEventInfo

-- NOTE: Collection of emotes used for PvP taunting.
local pvpEmotes = {
	"ANGRY",
	"BARK",
	"BECKON",
	"BITE",
	"BONK",
	"BURP",
	"BYE",
	"CACKLE",
	"CALM",
	"CHUCKLE",
	"COMFORT",
	"CRACK",
	"CUDDLE",
	"CURTSEY",
	"FLEX",
	"GIGGLE",
	"GLOAT",
	"GRIN",
	"GROWL",
	"GUFFAW",
	"INSULT",
	"LAUGH",
	"LICK",
	"MOCK",
	"MOO",
	"MOON",
	"MOURN",
	"NO",
	"NOSEPICK",
	"PITY",
	"RASP",
	"ROAR",
	"ROFL",
	"RUDE",
	"SCRATCH",
	"SHOO",
	"SIGH",
	"SLAP",
	"SMIRK",
	"SNARL",
	"SNICKER",
	"SNIFF",
	"SNUB",
	"SOOTHE",
	"TAP",
	"TAUNT",
	"TEASE",
	"THANK",
	"THREATEN",
	"TICKLE",
	"VETO",
	"VIOLIN",
	"YAWN",
}

local battlegroundOpponents = {}

-- ---------------------------------------------------------------------------
-- HELPERS
-- ---------------------------------------------------------------------------

-- REASON: Scans the battlefield score table to identify enemy players and their classes.
function Announcements:BuildBattlegroundOpponents()
	table_wipe(battlegroundOpponents)
	for index = 1, GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = GetBattlefieldScore(index)
		if (K.Faction == "Horde" and faction == 1) or (K.Faction == "Alliance" and faction == 0) then
			-- NOTE: Map name to classToken for class-coloring during announcements.
			battlegroundOpponents[name] = classToken
		end
	end
end

-- ---------------------------------------------------------------------------
-- EVENT HANDLERS
-- ---------------------------------------------------------------------------

function Announcements:OnCombatLogEvent()
	local _, eventType, _, _, caster, _, _, _, targetName, targetFlags = CombatLogGetCurrentEventInfo()

	-- REASON: Filters for 'PARTY_KILL' where the player is the source (caster).
	if eventType == "PARTY_KILL" and caster == K.Name then
		local isPlayer = bit_band(targetFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
		local isBattlegroundOpponent = battlegroundOpponents[targetName] ~= nil

		if isPlayer or isBattlegroundOpponent then
			if isBattlegroundOpponent then
				local classColor = RAID_CLASS_COLORS[battlegroundOpponents[targetName]]
				targetName = string.format("|c%s%s|r", classColor.colorStr, targetName)
			end

			if C["Announcements"].KillingBlow then
				-- NOTE: Mode 'KKUI_PVPKILL' is our custom identifier for the BossBanner hook.
				TopBannerManager_Show(_G.BossBanner, { name = targetName, mode = "KKUI_PVPKILL" })
			end

			if C["Announcements"].PvPEmote then
				-- NOTE: Fallback to 'hug' if the player doesn't have the 'Make Love, Not Warcraft' achievement.
				local _, _, _, hasAchievement = GetAchievementInfo(247)
				local emote = hasAchievement and pvpEmotes[math_random(#pvpEmotes)] or "hug"
				DoEmote(emote, targetName)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- REGISTRATION & HOOKING
-- ---------------------------------------------------------------------------

function Announcements:SetupKillingBlowAnnounce()
	-- REASON: Hook Blizzard's PlayBanner to inject our custom PvP kill display logic.
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

	if C["Announcements"].KillingBlow or C["Announcements"].PvPEmote then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent)
		K:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", self.BuildBattlegroundOpponents)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent)
		K:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE", self.BuildBattlegroundOpponents)
	end
end
