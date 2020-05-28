local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local bit_band = _G.bit.band
local math_random = _G.math.random
local select = _G.select
local string_find = _G.string.find
local string_sub = _G.string.sub

local COMBATLOG_OBJECT_REACTION_HOSTILE = _G.COMBATLOG_OBJECT_REACTION_HOSTILE
local COMBATLOG_OBJECT_TYPE_PLAYER = _G.COMBATLOG_OBJECT_TYPE_PLAYER
local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local DoEmote = _G.DoEmote
local GetAchievementInfo = _G.GetAchievementInfo
local IsInInstance = _G.IsInInstance

local pvpEmoteList = {
	"BARK", "BECKON", "BITE", "BONK", "BYE", "CACKLE",
	"CALM", "CHUCKLE", "COMFORT", "CUDDLE", "CURTSEY", "FLEX",
	"GIGGLE", "GLOAT", "GRIN", "GROWL", "GUFFAW", "INSULT",
	"LAUGH", "LICK", "MOCK", "MOO", "MOON", "MOURN",
	"NO", "PITY", "RASP", "ROAR", "ROFL", "RUDE",
	"SCRATCH", "SHOO", "SIGH", "SLAP", "SMIRK", "SNARL",
	"SNICKER", "SNIFF", "SNUB", "SOOTHE", "TAP", "TAUNT",
	"TEASE", "THANK", "TICKLE", "VETO", "VIOLIN", "YAWN"
}

local function SetupPvPEmote()
	local _, combatEvent, _, _, _, _, _, _, destName, destFlags = CombatLogGetCurrentEventInfo()
	local _, instanceType = IsInInstance()

	if instanceType == "raid" or instanceType == "party" or instanceType == "scenario" then -- No reason to run a pvp mod in dungeon/raids...
		return
	end

	if combatEvent ~= "PARTY_KILL" then -- PARTY_KILL might be the event we are looking for here...
		return
	end

	if type(destName) ~= "string" then
		return
	end

	-- We need to use the destFlags bit field to get information about the player who died,
	-- because the "Unit" commands (UnitName, UnitIsPlayer, etc.) provided by Blizzard will
	-- simply not work on enemy players (or players not in our raid/party) unless they are
	-- specifically targeted by us and we use for example UnitName("target") or likewise.
	-- Source: https://books.google.no/books?id=rAmNCqpmunIC&pg=PA254&lpg=PA254&dq=wow+api+combatlog_object&source=bl&ots=e0s4eMaIUx&sig=ACfU3U1-sRDUYMBRAbB7ndGr2YCoF2gQ7A&hl=en&sa=X&ved=2ahUKEwjrk7H7zrHoAhWWHHcKHdn6AygQ6AEwAHoECAoQAQ#v=onepage&q=wow%20api%20combatlog_object&f=false
	-- In case the link doesn't work, the link links to page 254 in the book:
	-- "Beginning Lua with World of Warcraft Add-ons" by Paul Emmerich in the "Unit Flags" section.
	if bit_band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) ~= COMBATLOG_OBJECT_TYPE_PLAYER then
		return
	end

	if bit_band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= COMBATLOG_OBJECT_REACTION_HOSTILE then
		return
	end

	local name = UNKNOWN
	local hugged
	local i, j = string_find(destName, '-')

	if i == nil then
		name = destName
	else
		name = string_sub(destName, 0, j - 1)
	end

	if hugged or select(4, GetAchievementInfo(247)) then
		-- Fire off a random emote, to keep it interesting.
		DoEmote(pvpEmoteList[math_random(1, #pvpEmoteList)], name)
	else
		DoEmote("HUG", name)
		-- Set a flag indicating we have tried it once,
		-- in case we're dealing with a bugged achievement.
		-- No point spamming hug forever when the issue requires
		-- a server restart or client relog to be fixed anyway.
		hugged = true
	end
end

function Module:CreatePvPEmote()
	if not C["Misc"].PvPEmote then
		return
	end

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", SetupPvPEmote)
end