local K = unpack(select(2, ...))
--if C.Misc.PvPEmote ~= true then
--	return
--end

local Module = K:NewModule("PvPEmote", "AceEvent-3.0")

local _G = _G
local bit_band = bit.band
local math_random = math.random
local select = select

local DoEmote = _G.DoEmote
local GetAchievementInfo = _G.GetAchievementInfo

local PVPEmotes = {
	"BARK", "BECKON", "BYE", "BITE", "BONK",
	"CACKLE", "CALM", "CHUCKLE", "COMFORT", "CUDDLE", "CURTSEY", "FLEX",
	"GIGGLE", "GLOAT", "GRIN", "GROWL", "GUFFAW", "INSULT", "LAUGH", "LICK",
	"MOCK", "MOO", "MOON", "MOURN", "NO", "PITY", "RASP", "ROAR", "ROFL", "RUDE",
	"SCRATCH", "SHOO", "SIGH", "SLAP", "SMIRK", "SNARL", "SNICKER", "SNIFF", "SNUB", "SOOTHE",
	"TAP", "TAUNT", "TEASE", "THANK", "TICKLE", "VETO", "VIOLIN", "YAWN"
}

local unitFilter = COMBATLOG_OBJECT_CONTROL_PLAYER
function Module:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local _, _, _, sourceGUID, _, _, _, _, destName,  destFlags = ...

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

function Module:OnInitialize()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end