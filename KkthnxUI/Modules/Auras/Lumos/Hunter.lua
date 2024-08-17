local K = KkthnxUI[1]
local Module = K:GetModule("Auras")

if K.Class ~= "HUNTER" then
	return
end

-- Localize frequently used global functions
local GetSpecialization = GetSpecialization
local IsPlayerSpell = IsPlayerSpell
local GetTime = GetTime

local function GetUnitAura(unit, spell, filter)
	return Module:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return Module:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, isPet, glow)
	return Module:UpdateAura(button, isPet and "pet" or "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateDebuff(button, spellID, auraID, cooldown, glow)
	return Module:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown, glow)
end

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(C_Spell.GetSpellTexture(spellID))
	if C_Spell.IsSpellUsable(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

local myGUID = UnitGUID("player")
local currentStack, resetTime = 0, 0

local function CheckDireStacks(_, ...)
	local _, eventType, _, sourceGUID, _, _, _, _, _, _, _, spellID = ...
	if sourceGUID ~= myGUID then
		return
	end

	if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH" then
		if spellID == 281036 and GetTime() > resetTime then
			currentStack = currentStack + 1
			if currentStack == 6 then
				currentStack = 1
			end
		elseif spellID == 378747 then
			resetTime = GetTime()
			currentStack = 5
		end
	elseif eventType == "SPELL_AURA_REMOVED" and spellID == 378747 then
		if currentStack == 5 then
			currentStack = 0
		end
	end
end
K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CheckDireStacks)

function Module:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateCooldown(self.lumos[1], 34026, true)
		UpdateCooldown(self.lumos[2], 217200, true)
		UpdateBuff(self.lumos[3], 106785, 272790, false, true, "END")
		UpdateBuff(self.lumos[4], 19574, 19574, true, false, true)

		do
			local button = self.lumos[5]
			local isSpell378745 = IsPlayerSpell(378745)
			if isSpell378745 then
				UpdateBuff(button, 281036, 281036)
				button.Count:SetText(currentStack)
			else
				UpdateBuff(button, 268877, 268877)
			end
		end
	elseif spec == 2 then
		UpdateCooldown(self.lumos[1], 19434, true)
		UpdateCooldown(self.lumos[2], 257044, true)
		UpdateBuff(self.lumos[3], 257622, 257622)

		do
			local button = self.lumos[4]
			local isSpell260402 = IsPlayerSpell(260402)
			local isSpell321460 = IsPlayerSpell(321460)
			if isSpell260402 then
				UpdateBuff(button, 260402, 260402, true, false, true)
			elseif isSpell321460 then
				UpdateCooldown(button, 53351)
				UpdateSpellStatus(button, 53351)
			else
				UpdateBuff(button, 260242, 260242)
			end
		end

		UpdateBuff(self.lumos[5], 288613, 288613, true, false, true)
	elseif spec == 3 then
		UpdateDebuff(self.lumos[1], 259491, 259491, false, "END")

		do
			local button = self.lumos[2]
			UpdateCooldown(button, 259489, true)
			local name = GetUnitAura("target", 270332, "HARMFUL")
			if name then
				K.ShowOverlayGlow(button)
			else
				K.HideOverlayGlow(button)
			end
		end

		do
			local button = self.lumos[3]
			local isSpell260285 = IsPlayerSpell(260285)
			local isSpell269751 = IsPlayerSpell(269751)
			if isSpell260285 then
				UpdateBuff(button, 260285, 260286)
			elseif isSpell269751 then
				UpdateCooldown(button, 269751, true)
			else
				UpdateBuff(button, 259387, 259388, false, false, "END")
			end
		end

		do
			local button = self.lumos[4]
			local isSpell271014 = IsPlayerSpell(271014)
			if isSpell271014 then
				UpdateCooldown(button, 259495, true)
				local name = GetUnitAura("player", 363805, "HELPFUL")
				if name then
					K.ShowOverlayGlow(button)
				else
					K.HideOverlayGlow(button)
				end
			else
				UpdateDebuff(button, 259495, 269747, true)
			end
		end

		UpdateBuff(self.lumos[5], 266779, 266779, true, false, true)
	end
end
