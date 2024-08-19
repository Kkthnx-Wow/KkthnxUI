local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Localize API functions
local UnitHealth, UnitHealthMax, UnitIsPlayer, UnitIsDead, UnitExists, UnitName = UnitHealth, UnitHealthMax, UnitIsPlayer, UnitIsDead, UnitExists, UnitName
local DoEmote, PlaySound, UnitAffectingCombat, IsInGroup = DoEmote, PlaySound, UnitAffectingCombat, IsInGroup
local string_format, UIErrorsFrame = string.format, UIErrorsFrame

-- Local variables
local playerNearDeath, petNearDeath = false, false
local validPetClasses = { ["HUNTER"] = true, ["WARLOCK"] = true }

-- Check if player should check health
local function shouldCheckHealth()
	return UnitAffectingCombat("player") and IsInGroup()
end

-- Check player's health and handle low health alerts
local function checkPlayerHealth()
	if not shouldCheckHealth() or UnitIsDead("player") then
		return
	end

	local playerHealthPercent = K.Round(UnitHealth("player") / UnitHealthMax("player") * 100, 1)

	if playerHealthPercent <= 30 and not playerNearDeath then
		playerNearDeath = true
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(L["The health for %s is low!"], K.Name))
		DoEmote("healme")
	elseif playerHealthPercent > 50 and playerNearDeath then
		playerNearDeath = false
	end
end

-- Check pet's health and handle low health alerts
local function checkPetHealth()
	if not shouldCheckHealth() or not validPetClasses[K.Class] or UnitIsDead("pet") then
		return
	end

	local petHealthPercent = K.Round(UnitHealth("pet") / UnitHealthMax("pet") * 100, 1)

	if petHealthPercent <= 30 and not petNearDeath then
		petNearDeath = true
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(L["The health for %s is low!"], UnitName("pet")))
		PlaySound(211593) -- Spell_PetBattle_Health_Buff
	elseif petHealthPercent > 50 and petNearDeath then
		petNearDeath = false
	end
end

-- Set up health announcement checks
function Module:SetupHealthAnnounce()
	checkPlayerHealth()
	checkPetHealth()
end

-- Create the health announcement system
function Module:CreateHealthAnnounce()
	if not C["Announcements"].HealthAlert then
		return
	end

	C_Timer.NewTicker(1, function()
		Module:SetupHealthAnnounce()
	end)
end
