local K = unpack(KkthnxUI)
local Module = K:GetModule("Auras")

if K.Class ~= "MONK" then
	return
end

local _G = _G

local GetSpecialization = _G.GetSpecialization
local GetSpellCount = _G.GetSpellCount
local GetSpellTexture = _G.GetSpellTexture
local IsPlayerSpell = _G.IsPlayerSpell
local IsUsableSpell = _G.IsUsableSpell

local function UpdateCooldown(button, spellID, texture)
	return Module:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, glow)
	return Module:UpdateAura(button, "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateTargetBuff(button, spellID, auraID, cooldown)
	return Module:UpdateAura(button, "target", auraID, "HELPFUL", spellID, cooldown, true)
end

local function UpdateSpellStatus(button, spellID)
	button.Icon:SetTexture(GetSpellTexture(spellID))
	if IsUsableSpell(spellID) then
		button.Icon:SetDesaturated(false)
	else
		button.Icon:SetDesaturated(true)
	end
end

function Module:ChantLumos(self)
	local spec = GetSpecialization()
	if spec == 1 then
		UpdateCooldown(self.lumos[1], 121253, true)
		UpdateCooldown(self.lumos[2], 322101, true)
		self.lumos[2].Count:SetText(GetSpellCount(322101))
		UpdateBuff(self.lumos[3], 215479, 215479)
		UpdateBuff(self.lumos[4], 325092, 325092, nil, "END")
		UpdateBuff(self.lumos[5], 322507, 322507, true)
	elseif spec == 2 then
		UpdateCooldown(self.lumos[1], 115151, true)
		UpdateCooldown(self.lumos[2], 191837, true)
		UpdateBuff(self.lumos[3], 116680, 116680, true, true)
		UpdateTargetBuff(self.lumos[4], 116849, 116849, true)
		UpdateCooldown(self.lumos[5], 115310, true)
	elseif spec == 3 then
		UpdateCooldown(self.lumos[1], 113656, true)
		UpdateCooldown(self.lumos[2], 107428, true)

		do
			local button = self.lumos[3]
			button.Count:SetText(GetSpellCount(101546))
			UpdateSpellStatus(button, 101546)
		end

		do
			local button = self.lumos[4]
			if IsPlayerSpell(152175) then
				UpdateCooldown(button, 152175, true)
			elseif IsPlayerSpell(152173) then
				UpdateBuff(button, 152173, 152173, true, true)
			else
				UpdateBuff(button, 137639, 137639, true)
			end
		end

		Module:UpdateTotemAura(self.lumos[5], 620832, 123904, true)
	end
end