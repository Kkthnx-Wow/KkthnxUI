--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Monitors player and pet health to trigger low-health warnings.
-- - Design: Uses a periodic C_Timer ticker to poll health levels rather than event spam.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache API references for frequent polling within the ticker loop.
local UnitHealth, UnitHealthMax, UnitIsDead = UnitHealth, UnitHealthMax, UnitIsDead
local UnitName, DoEmote, PlaySound = UnitName, DoEmote, PlaySound
local UnitAffectingCombat, IsInGroup = UnitAffectingCombat, IsInGroup
local string_format, time = string.format, time
local UIErrorsFrame = UIErrorsFrame

local playerNearDeath, petNearDeath = false, false
local ALERT_THRESHOLD = 30 -- NOTE: Trigger alert below this percent.
local RECOVERY_THRESHOLD = 50 -- NOTE: Reset alert status after health rises above this percent.
local ALERT_COOLDOWN = 5 -- NOTE: Enforce 5s cooldown between consecutive audio/text alerts.
local VALID_PET_CLASSES = { ["HUNTER"] = true, ["WARLOCK"] = true }
local debugEnabled = false

local lastPlayerAlertTime = 0
local lastPetAlertTime = 0

-- ---------------------------------------------------------------------------
-- UTILITIES
-- ---------------------------------------------------------------------------

local function debugLog(message, ...)
	if debugEnabled then
		print("[DEBUG] " .. string_format(message, ...))
	end
end

local function GetHealthPercent(unit)
	local maxHealth = UnitHealthMax(unit)
	-- SECRET (12.0): in combat/instances UnitHealth(Max) return secret numbers that
	-- cannot be compared or used in arithmetic. There is no readable way to compute a
	-- percent in that state, so bail (nil) and let the caller skip the alert instead
	-- of crashing. This effectively disables in-combat health alerts under Midnight.
	if K.IsSecret(maxHealth) then
		return nil
	end

	if maxHealth == 0 then
		return 0
	end

	local health = UnitHealth(unit)
	if K.IsSecret(health) then
		return nil
	end

	return (health / maxHealth) * 100
end

local function ShouldCheckPlayerHealth()
	local inCombat, inGroup = UnitAffectingCombat("player"), IsInGroup()
	debugLog("Player Health Check - InCombat: %s, InGroup: %s", tostring(inCombat), tostring(inGroup))
	-- REASON: Only alert player health in groups/combat to reduce non-critical chatter.
	return inCombat and inGroup
end

local function ShouldCheckPetHealth()
	local inCombat = UnitAffectingCombat("player")
	debugLog("Pet Health Check - InCombat: %s", tostring(inCombat))
	-- REASON: Pet health is monitored during combat to alert owners of imminent pet loss.
	return inCombat
end

-- ---------------------------------------------------------------------------
-- CORE LOGIC
-- ---------------------------------------------------------------------------

-- REASON: Handles the state engine for alert triggering and recovery.
local function HandleHealthAlert(unit, threshold, recoveryThreshold, alertFlag, lastAlertTime, messageCallback, soundCallback)
	-- SECRET (12.0): UnitIsDead can be a secret boolean in combat; only act on it
	-- when readable, otherwise fall through (GetHealthPercent will bail safely).
	local dead = UnitIsDead(unit)
	if K.NotSecret(dead) and dead then
		debugLog("Skipping health check for %s (unit is dead)", unit)
		return alertFlag, lastAlertTime
	end

	local rawPercent = GetHealthPercent(unit)
	if not rawPercent then
		debugLog("Health percent for %s is nil, skipping.", unit)
		return alertFlag, lastAlertTime
	end

	local healthPercent = K.Round(rawPercent, 1)

	debugLog("%s health: %.1f%%", unit, healthPercent)
	local currentTime = time()

	-- Trigger alert logic.
	if healthPercent <= threshold and not alertFlag then
		-- PERF: Enforce cooldown to prevent spam if health fluctuates rapidly near the threshold.
		if currentTime - lastAlertTime < ALERT_COOLDOWN then
			debugLog("[COOLDOWN] Alert for %s is on cooldown. Skipping alert.", unit)
		else
			debugLog("[ALERT] %s health below threshold: %.1f%% (<= %d%%)", unit, healthPercent, threshold)
			alertFlag = true
			lastAlertTime = currentTime
			messageCallback(healthPercent)
			if soundCallback then
				soundCallback()
			end
		end
	-- Reset state for the next alert drop.
	elseif healthPercent > recoveryThreshold and alertFlag then
		debugLog("[RECOVERY] %s health recovered: %.1f%% (> %d%%)", unit, healthPercent, recoveryThreshold)
		alertFlag = false
	end

	return alertFlag, lastAlertTime
end

local function CheckPlayerHealth()
	if not ShouldCheckPlayerHealth() then
		debugLog("Skipping player health check (not in group or combat)")
		return
	end

	playerNearDeath, lastPlayerAlertTime = HandleHealthAlert("player", ALERT_THRESHOLD, RECOVERY_THRESHOLD, playerNearDeath, lastPlayerAlertTime, function(health)
		debugLog("Player health is low at %.1f%%", health)
		local playerName = K.Name or "Player"
		local alertMessage = L["The health for %s is low!"] or "The health for %s is low!"
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(alertMessage, playerName))
		DoEmote("healme")
	end)
end

local function CheckPetHealth()
	if not VALID_PET_CLASSES[K.Class] then
		debugLog("Skipping pet health check (invalid pet class: %s)", K.Class)
		return
	end

	if not ShouldCheckPetHealth() then
		debugLog("Skipping pet health check (not in combat)")
		return
	end

	petNearDeath, lastPetAlertTime = HandleHealthAlert("pet", ALERT_THRESHOLD, RECOVERY_THRESHOLD, petNearDeath, lastPetAlertTime, function(health)
		debugLog("Pet health is low at %.1f%%", health)
		local petName = UnitName("pet") or "Pet"
		local alertMessage = L["The health for %s is low!"] or "The health for %s is low!"
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(alertMessage, petName))
	end, function()
		PlaySound(211593) -- SoundID: UI_Critter_Crowd_Mumble_Low
	end)
end

-- ---------------------------------------------------------------------------
-- REGISTRATION
-- ---------------------------------------------------------------------------

function Module:SetupHealthAnnounce()
	debugLog("Running health checks...")
	CheckPlayerHealth()
	CheckPetHealth()
end

function Module:CreateHealthAnnounce()
	if not C["Announcements"].HealthAlert then
		debugLog("Health alert system disabled in settings.")
		return
	end

	debugLog("Initializing health alert system...")
	-- PERF: Use a 1-second ticker to balance responsiveness and CPU usage.
	C_Timer.NewTicker(1, function()
		Module:SetupHealthAnnounce()
	end)
end
