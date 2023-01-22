local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local UIErrorsFrame = _G.UIErrorsFrame

local playerNearDeath = false
local petNearDeath = false

function Module:SetupHealthAnnounce()
	local playerHealth = UnitHealth("player")
	local playerHealthMax = UnitHealthMax("player")
	local playerHealthPercent = K.Round(playerHealth / playerHealthMax * 100, 1)

	if UnitIsPlayer("player") and not UnitIsDead("player") then
		if playerHealthPercent <= 30 and not playerNearDeath then
			playerNearDeath = true
			UIErrorsFrame:AddMessage(K.InfoColor .. string_format(L["The health for %s is low!"], K.Name))
			DoEmote("healme")
		elseif playerHealthPercent > 30 + 20 and playerNearDeath then
			playerNearDeath = false
		end
	end

	local validPetClasses = { "HUNTER", "WARLOCK" }
	local petHealth = UnitHealth("pet")
	local petHealthMax = UnitHealthMax("pet")
	local petHealthPercent = K.Round(petHealth / petHealthMax * 100, 1) or 1

	-- Ternary operator to check if the player's class is valid for this function
	local isValidPetClass = (tContains(validPetClasses, K.Class) and UnitExists("pet") and not UnitIsDead("pet"))

	if petHealthPercent <= 30 and not petNearDeath and isValidPetClass then
		petNearDeath = true
		UIErrorsFrame:AddMessage(K.InfoColor .. string_format(L["The health for %s is low!"], UnitName("pet")))
		PlaySound(211593) -- Spell_PetBattle_Health_Buff
	elseif petHealthPercent > 50 and petNearDeath then
		petNearDeath = false
	end
end

function Module:CreateHealthAnnounce()
	if not C["Announcements"].HealthAlert then
		return
	end

	C_Timer.NewTicker(1, Module.SetupHealthAnnounce)
end
