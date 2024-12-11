local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- WoW API references
local UnitHealth, UnitHealthMax, UnitIsDead = UnitHealth, UnitHealthMax, UnitIsDead
local UnitName, DoEmote, PlaySound = UnitName, DoEmote, PlaySound
local UnitAffectingCombat, IsInGroup = UnitAffectingCombat, IsInGroup
local string_format, time = string.format, time
local UIErrorsFrame = UIErrorsFrame

-- Local Constants & Variables
local playerNearDeath, petNearDeath = false, false
local ALERT_THRESHOLD = 30 -- Trigger alert below this percent
local RECOVERY_THRESHOLD = 50 -- Reset alert after health rises above this percent
local ALERT_COOLDOWN = 5 -- Time (in seconds) to prevent repeated alerts
local VALID_PET_CLASSES = { ["HUNTER"] = true, ["WARLOCK"] = true }
local debugEnabled = false -- Set to false to disable debug logging

-- Timestamp variables to track cooldowns
local lastPlayerAlertTime = 0
local lastPetAlertTime = 0

-- Utility Functions
local function debugLog(message, ...)
	if debugEnabled then
		print("[DEBUG] " .. string_format(message, ...))
	end
end

local function GetHealthPercent(unit)
	local maxHealth = UnitHealthMax(unit)
	if maxHealth == 0 then
		return 0
	end
	return (UnitHealth(unit) / maxHealth) * 100
end

local function ShouldCheckPlayerHealth()
	local inCombat, inGroup = UnitAffectingCombat("player"), IsInGroup()
	debugLog("Player Health Check - InCombat: %s, InGroup: %s", tostring(inCombat), tostring(inGroup))
	return inCombat and inGroup -- Player health check requires combat and group presence
end

local function ShouldCheckPetHealth()
	local inCombat = UnitAffectingCombat("player")
	debugLog("Pet Health Check - InCombat: %s", tostring(inCombat))
	return inCombat -- Pet health check only requires combat
end

local function HandleHealthAlert(unit, threshold, recoveryThreshold, alertFlag, lastAlertTime, messageCallback, soundCallback)
	if UnitIsDead(unit) then
		debugLog("Skipping health check for %s (unit is dead)", unit)
		return alertFlag, lastAlertTime
	end

	local healthPercent = K.Round(GetHealthPercent(unit), 1)
	if not healthPercent then
		debugLog("Health percent for %s is nil, skipping.", unit)
		return alertFlag, lastAlertTime
	end

	debugLog("%s health: %.1f%%", unit, healthPercent)
	local currentTime = time()

	-- Trigger alert if health is below threshold
	if healthPercent <= threshold and not alertFlag then
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
	-- Reset alert if health is recovered
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
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(L["The health for %s is low!"], K.Name))
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
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(L["The health for %s is low!"], UnitName("pet")))
	end, function()
		PlaySound(211593) -- Spell_PetBattle_Health_Buff
	end)
end

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
	C_Timer.NewTicker(1, function()
		Module:SetupHealthAnnounce()
	end)
end
