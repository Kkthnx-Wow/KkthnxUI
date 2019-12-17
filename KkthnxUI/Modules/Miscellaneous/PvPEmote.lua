local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local bit_band = bit.band
local math_random = math.random
local select = select

local DoEmote = _G.DoEmote
local GetAchievementInfo = _G.GetAchievementInfo
local unitFilter = _G.COMBATLOG_OBJECT_CONTROL_PLAYER

local PVPEmotes = {
	"BARK", "BECKON", "BITE", "BONK", "BYE", "CACKLE",
	"CALM", "CHUCKLE", "COMFORT", "CUDDLE", "CURTSEY", "FLEX",
	"GIGGLE", "GLOAT", "GRIN", "GROWL", "GUFFAW", "INSULT",
	"LAUGH", "LICK", "MOCK", "MOO", "MOON", "MOURN",
	"NO", "PITY", "RASP", "ROAR", "ROFL", "RUDE",
	"SCRATCH", "SHOO", "SIGH", "SLAP", "SMIRK", "SNARL",
	"SNICKER", "SNIFF", "SNUB", "SOOTHE", "TAP", "TAUNT",
	"TEASE", "THANK", "TICKLE", "VETO", "VIOLIN", "YAWN"
}

function Module.COMBAT_LOG_EVENT_UNFILTERED()
	local _, subEvent, _, sourceGUID, _, _, _, _, destName, destFlags = CombatLogGetCurrentEventInfo()

	local alreadyHugged
	if (subEvent == "PARTY_KILL") and (sourceGUID == K.GUID) and (bit_band(destFlags, unitFilter) > 0) then
		if alreadyHugged or select(4, GetAchievementInfo(247)) then
			-- Fire off a random emote, to keep it interesting.
			DoEmote(PVPEmotes[math_random(1, #PVPEmotes)], destName)
		else
			DoEmote("HUG", destName)
			-- Set a flag indicating we have tried it once,
			-- in case we're dealing with a bugged achievement.
			-- No point spamming hug forever when the issue requires
			-- a server restart or client relog to be fixed anyway.
			alreadyHugged = true
		end
	end
end

function Module:CreatePvPEmote()
	if C.Misc.PvPEmote ~= true then
		return
	end

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.COMBAT_LOG_EVENT_UNFILTERED)
end