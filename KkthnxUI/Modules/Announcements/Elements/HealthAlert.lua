local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- UI and String Functions
local string_format = string.format
local UIErrorsFrame = UIErrorsFrame

-- Unit and Combat Functions
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitIsPlayer, UnitIsDead, UnitExists, UnitName = UnitIsPlayer, UnitIsDead, UnitExists, UnitName
local DoEmote, PlaySound = DoEmote, PlaySound

local playerNearDeath = false
local petNearDeath = false
local validPetClasses = { ["HUNTER"] = true, ["WARLOCK"] = true }

local function shouldCheckHealth()
	return UnitAffectingCombat("player") and IsInGroup()
end

local function checkPlayerHealth()
	if not shouldCheckHealth() then
		return
	end

	if not UnitIsPlayer("player") or UnitIsDead("player") then
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

local function checkPetHealth()
	if not shouldCheckHealth() then
		return
	end

	if not validPetClasses[K.Class] or not UnitExists("pet") or UnitIsDead("pet") then
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

function Module:SetupHealthAnnounce()
	checkPlayerHealth()
	checkPetHealth()
end

function Module:CreateHealthAnnounce()
	if not C["Announcements"].HealthAlert then
		return
	end

	C_Timer.NewTicker(1, function()
		Module:SetupHealthAnnounce()
	end)
end
