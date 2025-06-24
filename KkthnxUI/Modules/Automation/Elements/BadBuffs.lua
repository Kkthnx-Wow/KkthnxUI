local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Cache frequently used API functions
local InCombatLockdown = InCombatLockdown
local CancelSpellByName = CancelSpellByName
local C_UnitAuras_GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex
local C_Spell_GetSpellLink = C_Spell.GetSpellLink
local C_Timer_After = C_Timer.After

-- Constants
local PLAYER_UNIT = "player"
local COMBAT_RETRY_DELAY = 0.1
local AURA_UPDATE_DELAY = 0.05
local BUFF_REMOVAL_RETRY_DELAY = 0.2
local TABLE_EMPTY_RETRY_DELAY = 0.5
local INITIAL_CHECK_DELAY = 1.0
local LATE_CHECK_DELAY = 3.0

-- State management
local state = {
	waitingForCombatEnd = false,
	isInitialized = false,
	lastCheckTime = 0,
	checkThrottle = 0.1, -- Minimum time between checks
}

-- Local function cache for better performance
local function IsTableEmpty(t)
	return not t or not next(t)
end

local function IsInCombat()
	return InCombatLockdown()
end

-- Optimized buff checking function
local function CheckAndRemoveBadBuffs(event)
	-- Throttle checks to prevent excessive API calls
	local currentTime = GetTime()
	if currentTime - state.lastCheckTime < state.checkThrottle then
		return
	end
	state.lastCheckTime = currentTime

	-- Early exit if bad buffs table is not populated
	if IsTableEmpty(C.CheckBadBuffs) then
		C_Timer_After(TABLE_EMPTY_RETRY_DELAY, CheckAndRemoveBadBuffs)
		return
	end

	-- Handle combat restrictions
	if IsInCombat() then
		if not state.waitingForCombatEnd then
			state.waitingForCombatEnd = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", function()
				state.waitingForCombatEnd = false
				K:UnregisterEvent("PLAYER_REGEN_ENABLED")
				C_Timer_After(COMBAT_RETRY_DELAY, CheckAndRemoveBadBuffs)
			end)
		end
		return
	end

	-- Reset combat waiting flag
	state.waitingForCombatEnd = false

	-- Efficient buff scanning with early exit
	local removedCount = 0
	local index = 1

	repeat
		local aura = C_UnitAuras_GetBuffDataByIndex(PLAYER_UNIT, index)
		if not aura then
			break
		end

		-- Direct table lookup for better performance
		if C.CheckBadBuffs[aura.name] then
			CancelSpellByName(aura.name)
			local spellLink = C_Spell_GetSpellLink(aura.spellId)
			K.Print(K.SystemColor .. "Removed Bad Buff: " .. (spellLink or aura.name) .. "|r")
			removedCount = removedCount + 1
		end

		index = index + 1
	until false -- Use repeat-until for better performance than while

	-- Only retry if we actually removed something
	if removedCount > 0 then
		C_Timer_After(BUFF_REMOVAL_RETRY_DELAY, CheckAndRemoveBadBuffs)
	end
end

-- Optimized event handler with debouncing
local eventHandlerCache = {}
local function HandleBadBuffsEvent(event, unit)
	-- Early exit for non-player units
	if unit and unit ~= PLAYER_UNIT then
		return
	end

	-- Debounce rapid events
	local cacheKey = event .. (unit or "")
	if eventHandlerCache[cacheKey] then
		return
	end

	eventHandlerCache[cacheKey] = true
	C_Timer_After(AURA_UPDATE_DELAY, function()
		eventHandlerCache[cacheKey] = nil
		CheckAndRemoveBadBuffs(event)
	end)
end

-- Cleanup function for proper resource management
local function CleanupBadBuffs()
	state.waitingForCombatEnd = false
	state.isInitialized = false
	state.lastCheckTime = 0
	wipe(eventHandlerCache)
end

-- Main module function with proper initialization
function Module:CreateAutoBadBuffs()
	-- Cleanup any existing state
	CleanupBadBuffs()

	if not C["Automation"].NoBadBuffs then
		-- Unregister all events
		K:UnregisterEvent("UNIT_AURA", HandleBadBuffsEvent)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", HandleBadBuffsEvent)
		K:UnregisterEvent("PLAYER_LOGIN", HandleBadBuffsEvent)
		K:UnregisterEvent("SPELLS_CHANGED", HandleBadBuffsEvent)
		return
	end

	-- Register events efficiently
	local events = {
		{ "UNIT_AURA", HandleBadBuffsEvent, PLAYER_UNIT },
		{ "PLAYER_ENTERING_WORLD", HandleBadBuffsEvent },
		{ "PLAYER_LOGIN", HandleBadBuffsEvent },
		{ "SPELLS_CHANGED", HandleBadBuffsEvent },
	}

	for _, eventData in ipairs(events) do
		K:RegisterEvent(unpack(eventData))
	end

	-- Schedule initial checks with proper timing
	C_Timer_After(INITIAL_CHECK_DELAY, CheckAndRemoveBadBuffs)
	C_Timer_After(LATE_CHECK_DELAY, CheckAndRemoveBadBuffs)

	state.isInitialized = true
end
