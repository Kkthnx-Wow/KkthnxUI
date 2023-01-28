local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

local bit_band = _G.bit.band
local math_random = _G.math.random
local table_wipe = _G.table.wipe

local BossBanner_BeginAnims = _G.BossBanner_BeginAnims
local COMBATLOG_OBJECT_TYPE_PLAYER = _G.COMBATLOG_OBJECT_TYPE_PLAYER
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local DoEmote = _G.DoEmote
local GetAchievementInfo = _G.GetAchievementInfo
local GetBattlefieldScore = _G.GetBattlefieldScore
local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
local PlaySoundFile = _G.PlaySoundFile
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local TopBannerManager_Show = _G.TopBannerManager_Show
local UnitGUID = _G.UnitGUID
local hooksecurefunc = _G.hooksecurefunc

local pvpEmoteList = {
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

-- Refactored code
local BG_Opponents = {} -- Table to store opponents in the battleground

-- Function to populate BG_Opponents table with opponents from the battleground
local function SetupOpponentsTable()
	table_wipe(BG_Opponents) -- Clear table before populating it

	-- Iterate through all scores in the battleground
	for index = 1, GetNumBattlefieldScores() do
		local name, _, _, _, _, faction, _, _, classToken = GetBattlefieldScore(index)
		if not name then
			return
		end

		-- Check if the faction of the current score is equal to player's faction and add it to BG_Opponents table if so
		if (K.Faction == "Horde" and faction == 1) or (K.Faction == "Alliance" and faction == 0) then
			BG_Opponents[name] = classToken
		end
	end
end

local function SetupKillingBlow()
	-- Get the current combat log event info
	local _, subevent, sourceGUID, _, Caster, _, _, _, TargetName, TargetFlags = CombatLogGetCurrentEventInfo()

	-- Check if the event is a party kill and the source of the kill is the player
	if subevent == "PARTY_KILL" and sourceGUID == UnitGUID("player") then
		-- Get the target type (player or NPC) from the target flags
		local mask = bit_band(TargetFlags, COMBATLOG_OBJECT_TYPE_PLAYER)

		-- Check if caster is player and target is either an opponent in a battleground or a player
		if Caster == K.Name and (BG_Opponents[TargetName] or mask > 0) then
			-- If target is a player in a battleground add class color to name
			if mask > 0 and BG_Opponents[TargetName] then
				TargetName = "|c" .. RAID_CLASS_COLORS[BG_Opponents[TargetName]].colorStr .. TargetName .. "|r" or TargetName
				TargetName = TargetName
			end

			-- Check if Killing Blow announcement is enabled in settings
			if C["Announcements"].KillingBlow then
				-- Show BossBanner with name of killed target
				TopBannerManager_Show(_G["BossBanner"], { name = TargetName, mode = "PVPKILL" })
			end

			-- Check if PvP Emote announcement is enabled in settings
			if C["Announcements"].PvPEmote then
				-- Check if achievement for killing 1000 players has been completed
				if select(4, GetAchievementInfo(247)) then
					-- Fire off random emote to keep it interesting
					DoEmote(pvpEmoteList[math_random(1, #pvpEmoteList)], TargetName)

				-- If achievement has not been completed fire off hug emote
				else
					DoEmote("HUG", TargetName)
				end
			end
		end
	end
end

function Module:CreateKillingBlow()
	hooksecurefunc(_G["BossBanner"], "PlayBanner", function(self, data)
		if data and data.mode == "PVPKILL" then
			self.Title:SetText(data.name)
			self.Title:Show()
			self.SubTitle:Hide()
			self:Show()
			BossBanner_BeginAnims(self)
			PlaySoundFile("Interface\\AddOns\\KkthnxUI\\Media\\Sounds\\KillingBlow.ogg", "Master")
		end
	end)

	K:RegisterEvent("UPDATE_BATTLEFIELD_SCORE", SetupOpponentsTable)
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", SetupKillingBlow)
end
