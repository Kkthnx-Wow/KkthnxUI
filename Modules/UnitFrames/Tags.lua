--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Tags.lua
	Purpose:
		Custom oUF text tags. Bar values are not here on purpose: health and power
		can be secret numbers, so those are driven straight into SetFormattedText
		from the bar's PostUpdate (see Elements/Texts.lua).

		A tag may return a secret string, oUF handles that. What a tag must never
		do is measure or slice one, so every string operation below is gated on a
		secret check first.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local oUF = K.oUF
local IsSecret = K.IsSecret

local UnitName = UnitName
local UnitLevel = UnitLevel
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitIsAFK = UnitIsAFK
local UnitIsConnected = UnitIsConnected
local UnitIsDND = UnitIsDND
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction

-- ---------------------------------------------------------------------------
-- Name
-- ---------------------------------------------------------------------------

-- Colour prefix for a name. oUF ships [raidcolor], but that only knows about
-- players, so every NPC comes out white and a hostile mob reads the same as a
-- quest giver. This covers reactions as well, and greys out anyone who has
-- dropped connection.
oUF.Tags.Methods["kkui:namecolor"] = function(unit)
	if not C.Unitframe.NameColor then
		return ""
	end

	-- When the health bar already carries the class/reaction colour, keep the
	-- name white so the two do not double up. The name only takes the colour
	-- when the bar is a plain green health bar.
	if C.Unitframe.ClassHealth then
		return ""
	end

	if not UnitIsConnected(unit) then
		return "|cff909090"
	end

	local color
	if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
		-- The class token can be a Midnight secret value, which cannot be used as
		-- a table key. Fall back to the client's own class color lookup.
		local _, class = UnitClass(unit)
		if issecretvalue(class) then
			color = C_ClassColor.GetClassColor(class)
		elseif class then
			color = oUF.colors.class[class]
		end
	else
		-- Reaction is likewise secret for hostile units, so only index our table
		-- with a plain value.
		local reaction = UnitReaction(unit, "player")
		if reaction and not issecretvalue(reaction) then
			color = oUF.colors.reaction[reaction]
		end
	end

	return color and color:GenerateHexColorMarkup() or ""
end
oUF.Tags.Events["kkui:namecolor"] = "UNIT_NAME_UPDATE UNIT_FACTION UNIT_CONNECTION"

-- Trim long names to a character count. Every name font string is also width
-- bounded, so the client already ellipsizes on its own, this is the extra cap
-- for players who want short names on wide frames.
--
-- Byte level string.sub would cut a multibyte character in half and render as a
-- broken glyph, so this needs the UTF8 helpers. If they are missing, hand back
-- the full name and let the width bound do the work rather than error on every
-- roster update.
oUF.Tags.Methods["kkui:name"] = function(unit)
	local name = UnitName(unit)
	if not name then
		return ""
	end
	-- Restricted identities arrive as secret strings. Nothing here can measure or
	-- slice one, so pass it straight through.
	if IsSecret(name) then
		return name
	end

	local limit = C.Unitframe.NameLength or 0
	local utf8len, utf8sub = string.utf8len, string.utf8sub
	if limit > 0 and utf8len and utf8sub and utf8len(name) > limit then
		return utf8sub(name, 1, limit) .. "..."
	end
	return name
end
oUF.Tags.Events["kkui:name"] = "UNIT_NAME_UPDATE"

-- Short name for the narrow raid frames: the first few characters, no ellipsis,
-- so a whole group reads cleanly at a glance.
oUF.Tags.Methods["kkui:nameshort"] = function(unit)
	local name = UnitName(unit)
	if not name then
		return ""
	end
	if IsSecret(name) then
		return name
	end
	local utf8len, utf8sub = string.utf8len, string.utf8sub
	if utf8len and utf8sub and utf8len(name) > 5 then
		return utf8sub(name, 1, 5)
	end
	return name
end
oUF.Tags.Events["kkui:nameshort"] = "UNIT_NAME_UPDATE"

-- ---------------------------------------------------------------------------
-- Status
-- ---------------------------------------------------------------------------

-- Both flags carry SecretInChatMessagingLockdown, so the booleans themselves can
-- be secret. Nothing useful to show in that case, and branching on one would
-- error, so bail out.
oUF.Tags.Methods["kkui:afkdnd"] = function(unit)
	local afk, dnd = UnitIsAFK(unit), UnitIsDND(unit)
	if IsSecret(afk) or IsSecret(dnd) then
		return ""
	end

	if afk then
		return " |cff999999" .. (CHAT_FLAG_AFK or "<AFK>") .. "|r"
	elseif dnd then
		return " |cff999999" .. (CHAT_FLAG_DND or "<DND>") .. "|r"
	end
	return ""
end
oUF.Tags.Events["kkui:afkdnd"] = "PLAYER_FLAGS_CHANGED"

-- Level plus the classification shorthand, so "82+" reads as an elite.
oUF.Tags.Methods["kkui:level"] = function(unit)
	local level = UnitLevel(unit)
	if not level or level <= 0 then
		return "??"
	end

	local class = UnitClassification(unit)
	if class == "worldboss" then
		return level .. "B"
	elseif class == "rareelite" then
		return level .. "R+"
	elseif class == "elite" then
		return level .. "+"
	elseif class == "rare" then
		return level .. "R"
	end
	return level
end
oUF.Tags.Events["kkui:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"