local K, C = KkthnxUI[1], KkthnxUI[2]
local Announcements = K:GetModule("Announcements")

local bit_band, math_random = bit.band, math.random
local table_wipe = table.wipe
local BossBanner_BeginAnims, DoEmote, GetAchievementInfo, GetBattlefieldScore, GetNumBattlefieldScores, RAID_CLASS_COLORS = BossBanner_BeginAnims, DoEmote, GetAchievementInfo, GetBattlefieldScore, GetNumBattlefieldScores, RAID_CLASS_COLORS
local TopBannerManager_Show, hooksecurefunc, CombatLogGetCurrentEventInfo = TopBannerManager_Show, hooksecurefunc, CombatLogGetCurrentEventInfo

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

function Announcements:BuildBattlegroundOpponents()
	table_wipe(battlegroundOpponents) -- Clear the battleground opponents list
	for index = 1, GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = GetBattlefieldScore(index)
		if (K.Faction == "Horde" and faction == 1) or (K.Faction == "Alliance" and faction == 0) then
			battlegroundOpponents[name] = classToken -- Store opponent name and classToken in the table
		end
	end
end

function Announcements:OnCombatLogEvent()
	local _, eventType, _, _, caster, _, _, _, targetName, targetFlags = CombatLogGetCurrentEventInfo()

	if eventType == "PARTY_KILL" and caster == K.Name then
		local isPlayer = bit_band(targetFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
		local isBattlegroundOpponent = battlegroundOpponents[targetName] ~= nil

		if isPlayer or isBattlegroundOpponent then
			if isBattlegroundOpponent then
				local classColor = RAID_CLASS_COLORS[battlegroundOpponents[targetName]]
				targetName = string.format("|c%s%s|r", classColor.colorStr, targetName) -- Colorize target name based on class
			end

			if C["Announcements"].KillingBlow then
				TopBannerManager_Show(_G.BossBanner, { name = targetName, mode = "KKUI_PVPKILL" }) -- Show the BossBanner with PvP kill info
			end

			if C["Announcements"].PvPEmote then
				local _, _, _, hasAchievement = GetAchievementInfo(247)
				local emote = hasAchievement and pvpEmotes[math_random(#pvpEmotes)] or "hug" -- Random emote or "hug" if no achievement
				DoEmote(emote, targetName) -- Execute emote on the target
			end
		end
	end
end

function Announcements:SetupKillingBlowAnnounce()
	hooksecurefunc(_G.BossBanner, "PlayBanner", function(self, data)
		if data and data.mode == "KKUI_PVPKILL" then
			self.Title:SetText(data.name) -- Set title to target name
			self.Title:Show() -- Show the title
			self.SubTitle:Hide() -- Hide the subtitle
			self:Show() -- Display the banner
			BossBanner_BeginAnims(self) -- Start animation for the banner
			PlaySound(SOUNDKIT.UI_RAID_BOSS_DEFEATED) -- Play sound for raid boss defeat
		end
	end)

	if C["Announcements"].KillingBlow or C["Announcements"].PvPEmote then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent) -- Register event to listen for combat log events
		K:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", self.BuildBattlegroundOpponents) -- Register event to update battlefield opponents list
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent) -- Unregister event if settings are disabled
		K:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE", self.BuildBattlegroundOpponents) -- Unregister battlefield score update event
	end
end
