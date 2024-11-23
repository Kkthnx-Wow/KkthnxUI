local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Localize API functions
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDead = UnitIsDead
local UnitName = UnitName
local DoEmote = DoEmote
local PlaySound = PlaySound
local UnitAffectingCombat = UnitAffectingCombat
local IsInGroup = IsInGroup
local string_format = string.format
local UIErrorsFrame = UIErrorsFrame

-- Local variables
local playerNearDeath, petNearDeath = false, false
local VALID_PET_CLASSES = { ["HUNTER"] = true, ["WARLOCK"] = true }

-- Utility to calculate health percentage
local function GetHealthPercent(unit)
	local maxHealth = UnitHealthMax(unit)
	if maxHealth == 0 then
		return 0
	end
	return (UnitHealth(unit) / maxHealth) * 100
end

-- Check if the player is in combat and in a group
local function ShouldCheckHealth()
	return UnitAffectingCombat("player") and IsInGroup()
end

-- Handle health alerts for a given unit
local function HandleHealthAlert(unit, threshold, recoveryThreshold, alertFlag, messageCallback, soundCallback)
	if not ShouldCheckHealth() or UnitIsDead(unit) then
		return alertFlag -- Return current state if checks fail
	end

	local healthPercent = K.Round(GetHealthPercent(unit), 1)

	if healthPercent <= threshold and not alertFlag then
		alertFlag = true
		messageCallback(healthPercent)
		if soundCallback then
			soundCallback()
		end
	elseif healthPercent > recoveryThreshold and alertFlag then
		alertFlag = false
	end

	return alertFlag -- Always return a boolean value
end

-- Health announcement for player
local function CheckPlayerHealth()
	playerNearDeath = HandleHealthAlert("player", 30, 50, playerNearDeath, function()
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(L["The health for %s is low!"], K.Name))
		DoEmote("healme")
	end)
end

-- Health announcement for pet
local function CheckPetHealth()
	if not VALID_PET_CLASSES[K.Class] then
		return
	end

	petNearDeath = HandleHealthAlert("pet", 30, 50, petNearDeath, function()
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(L["The health for %s is low!"], UnitName("pet")))
	end, function()
		PlaySound(211593) -- Spell_PetBattle_Health_Buff
	end)
end

-- Run health checks
function Module:SetupHealthAnnounce()
	CheckPlayerHealth()
	CheckPetHealth()
end

-- Initialize the health announcement system
function Module:CreateHealthAnnounce()
	if not C["Announcements"].HealthAlert then
		return
	end

	C_Timer.NewTicker(1, function()
		Module:SetupHealthAnnounce()
	end)
end
