local K, C, L, _ = select(2, ...):unpack()
if K.Class ~= "HUNTER" and K.Level > 10 then return end

local select = select
local CreateFrame = CreateFrame
local GetPetHappiness = GetPetHappiness
local HasPetUI = HasPetUI

-- Pet Happiness Chat Reminder
local PetHappiness = CreateFrame("Frame")
local OnEvent = function(self, event, ...)
	local happiness = GetPetHappiness()
	local hunterPet = select(2, HasPetUI())
	local unit, power = ...

	if (event == "UNIT_POWER" and unit == "pet" and power == "HAPPINESS" and happiness and hunterPet and self.happiness ~= happiness) then
		self.happiness = happiness
		if (happiness == 1) then
			DEFAULT_CHAT_FRAME:AddMessage(L_CLASS_HUNTER_UNHAPPY, 1, 0, 0)
		elseif (happiness == 2) then
			DEFAULT_CHAT_FRAME:AddMessage(L_CLASS_HUNTER_CONTENT, 1, 1, 0)
		elseif (happiness == 3) then
			DEFAULT_CHAT_FRAME:AddMessage(L_CLASS_HUNTER_HAPPY, 0, 1, 0)
		end
	elseif (event == "UNIT_PET") then
		self.happiness = happiness
		if (happiness == 1) then
			DEFAULT_CHAT_FRAME:AddMessage(L_CLASS_HUNTER_UNHAPPY, 1, 0, 0)
		end
	end
end
PetHappiness:RegisterEvent("UNIT_POWER")
PetHappiness:RegisterEvent("UNIT_PET")
PetHappiness:SetScript("OnEvent", OnEvent)