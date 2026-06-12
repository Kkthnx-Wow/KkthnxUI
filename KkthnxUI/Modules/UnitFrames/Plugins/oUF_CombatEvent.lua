--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Restore oUF's per-frame combat-log event helpers.
-- - Design: MIDNIGHT (12.0) shipped a newer oUF that dropped the legacy
--   frame:RegisterCombatEvent / frame:UnregisterCombatEvent methods that the
--   Swing, FloatingCombatFeedback and Nameplate (SpellInterruptor) plugins still
--   rely on. Rather than edit the vendored library, we re-attach the methods to
--   every unit frame through the supported oUF:RegisterMetaFunction hook and fan
--   COMBAT_LOG_EVENT_UNFILTERED out through KkthnxUI's existing single dispatcher
--   (K:RegisterEvent), mirroring NDui's one-CLEU-frame model.
-- - Events: COMBAT_LOG_EVENT_UNFILTERED
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local oUF = K.oUF

if not oUF or not oUF.RegisterMetaFunction then
	return
end

-- PERF: Localize hot globals/utilities.
local next = _G.next
local IsSecret = K.IsSecret

-- registry[subevent] = { [frame] = { [func] = true, ... }, ... }
local registry = {}
local listening = false

-- REASON: Single CLEU consumer. KkthnxUI's dispatcher fetches the payload once
-- (see Init.lua) and forwards it here with `event` first, then the full
-- CombatLogGetCurrentEventInfo() tuple (timestamp, eventType, hideCaster, ...).
-- We strip the leading event + eventType so registered handlers receive the
-- classic oUF signature: func(frame, timestamp, hideCaster, sourceGUID, ...).
local function CombatDispatcher(_, timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	-- SECRET (12.0): the subevent is a Blizzard constant and should never be
	-- secret, but guard before using it as a table key so a secret value can
	-- never error the dispatch ("cannot be indexed with secret keys").
	if IsSecret(eventType) then
		return
	end

	local frames = registry[eventType]
	if not frames then
		return
	end

	for frame, funcs in next, frames do
		for func in next, funcs do
			func(frame, timestamp, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
		end
	end
end

-- [[ frame:RegisterCombatEvent(subevent, func) ]]
-- Registers `func` to run for this frame whenever COMBAT_LOG_EVENT_UNFILTERED
-- fires with the given subevent (e.g. "SPELL_INTERRUPT", "SWING_DAMAGE").
local function RegisterCombatEvent(self, subevent, func)
	if type(subevent) ~= "string" or type(func) ~= "function" then
		return
	end

	local frames = registry[subevent]
	if not frames then
		frames = {}
		registry[subevent] = frames
	end

	local funcs = frames[self]
	if not funcs then
		funcs = {}
		frames[self] = funcs
	end

	funcs[func] = true

	-- REASON: Only subscribe to the (spammy) combat log once a listener exists.
	if not listening then
		listening = true
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatDispatcher)
	end
end

-- [[ frame:UnregisterCombatEvent(subevent, func) ]]
local function UnregisterCombatEvent(self, subevent, func)
	local frames = registry[subevent]
	if not frames then
		return
	end

	local funcs = frames[self]
	if not funcs then
		return
	end

	funcs[func] = nil

	if not next(funcs) then
		frames[self] = nil
	end

	if not next(frames) then
		registry[subevent] = nil
	end

	-- REASON: Drop the CLEU subscription entirely once nothing is listening.
	if listening and not next(registry) then
		listening = false
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatDispatcher)
	end
end

-- NOTE: RegisterMetaFunction silently no-ops if a future oUF restores these
-- methods, so the library wins automatically and we never fight it.
oUF:RegisterMetaFunction("RegisterCombatEvent", RegisterCombatEvent)
oUF:RegisterMetaFunction("UnregisterCombatEvent", UnregisterCombatEvent)
