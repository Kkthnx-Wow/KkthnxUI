local K, C = unpack(select(2, ...))
local Module = K:NewModule("PvPEmote", "AceHook-3.0", "AceEvent-3.0")
-- Sourced: DiabolicUI, KkthnxUI (Goldpaw, Kkthnx)

-- Lua API
local _G = _G
local bit_band = bit.band
local math_random = math.random
local select = select

-- Wow API
local DoEmote = _G.DoEmote
local GetAchievementInfo = _G.GetAchievementInfo
local UnitGUID = _G.UnitGUID
local UnitIsPlayer = _G.UnitIsPlayer

-- Obey the alphabet!
local emotes = {
	"BARK", "BECKON", "BYE", "BITE", "BONK",
	"CACKLE", "CALM", "CHUCKLE", "COMFORT", "CUDDLE", "CURTSEY", "FLEX",
	"GIGGLE", "GLOAT", "GRIN", "GROWL", "GUFFAW", "INSULT", "LAUGH", "LICK",
	"MOCK", "MOO", "MOON", "MOURN", "NO", "PITY", "RASP", "ROAR", "ROFL", "RUDE",
	"SCRATCH", "SHOO", "SIGH", "SLAP", "SMIRK", "SNARL", "SNICKER", "SNIFF", "SNUB", "SOOTHE",
	"TAP", "TAUNT", "TEASE", "THANK", "TICKLE", "VETO", "VIOLIN", "YAWN"
}

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

function Module:Setup(_, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, ...)
	if not C["Misc"].PvPEmote then return end

	local alreadyHugged
	local isKillingBlow

	-- Note that UnitIsPlayer
	if ((subEvent == "PARTY_KILL") and (sourceGUID == playerGUID) and (bit_band(destFlags, unitFilter) and UnitIsPlayer(destName))) then
		isKillingBlow = true

		-- Workarounds for situations where the PARTY_KILL event won't fire
	elseif damageEvents[subEvent] then
		local overkill = select(16, ...)
		if (overkill and overkill > 0) then
			if ((sourceGUID == playerGUID) or (sourceGUID == UnitGUID("pet"))) and (bit_band(destFlags, unitFilter) and UnitIsPlayer(destName)) then
				isKillingBlow = true
			end
		end
	end

	if isKillingBlow then
		if alreadyHugged or select(4, GetAchievementInfo(247)) then
			-- Fire off a random emote, to keep it interesting.
			DoEmote(emotes[math_random(1, #emotes)], destName)
		else
			-- Do a hug to attempt to get the achievement "Make love, not Warcraft".
			DoEmote("HUG", destName)

			-- Set a flag indicating we have tried it once,
			-- in case we're dealing with a bugged achievement.
			-- No point spamming hug forever when the issue requires
			-- a server restart or client relog to be fixed anyway.
			alreadyHugged = true
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("PLAYER_DEAD", "Setup")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "Setup")
end