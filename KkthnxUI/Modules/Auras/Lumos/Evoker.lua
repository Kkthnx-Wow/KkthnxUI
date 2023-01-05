local K = unpack(KkthnxUI)
local Module = K:GetModule("Auras")

if K.Class ~= "EVOKER" then
	return
end

local function GetUnitAura(unit, spell, filter)
	return Module:GetUnitAura(unit, spell, filter)
end

local function UpdateCooldown(button, spellID, texture)
	return Module:UpdateCooldown(button, spellID, texture)
end

local function UpdateBuff(button, spellID, auraID, cooldown, glow)
	return Module:UpdateAura(button, "player", auraID, "HELPFUL", spellID, cooldown, glow)
end

local function UpdateDebuff(button, spellID, auraID, cooldown, glow)
	return Module:UpdateAura(button, "target", auraID, "HARMFUL", spellID, cooldown, glow)
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
	if spec == 1 then --湮灭
		UpdateCooldown(self.lumos[1], 370553, true) --扭转天平
		do
			local button = self.lumos[2]
			local spellID = IsPlayerSpell(375783) and 382266 or 357208
			UpdateSpellStatus(button, spellID)
			UpdateCooldown(button, spellID, true)
			local name = GetUnitAura("player", 370553, "HELPFUL") --扭转天平高亮
			if name then
				K.ShowOverlayGlow(button)
			else
				K.HideOverlayGlow(button)
			end
		end

		do
			local button3 = self.lumos[3]
			local button4 = self.lumos[4]
			UpdateSpellStatus(button3, 356995)
			UpdateCooldown(button3, 356995, true)
			UpdateSpellStatus(button4, 357211)
			UpdateCooldown(button4, 357211, true)

			local hasBurst = GetUnitAura("player", 359618, "HELPFUL") --高亮精华迸发
			if hasBurst then
				K.ShowOverlayGlow(button3)
				K.ShowOverlayGlow(button3)
			else
				K.HideOverlayGlow(button4)
				K.HideOverlayGlow(button4)
			end
		end

		UpdateCooldown(self.lumos[5], 357210, true) --深呼吸
	elseif spec == 2 then --恩护
		local spellID = IsPlayerSpell(375783) and 382614 or 355936
		UpdateCooldown(self.lumos[1], spellID, true) --梦境吐息

		do
			local button2 = self.lumos[2] --翡翠之花
			UpdateSpellStatus(button2, 355913)
			UpdateCooldown(button2, 355913, true)
			local button3 = self.lumos[3] --回响
			UpdateSpellStatus(button3, 364343)
			UpdateCooldown(button3, 364343, true)

			local hasBurst = GetUnitAura("player", 369299, "HELPFUL") --高亮精华迸发
			if hasBurst then
				K.ShowOverlayGlow(button2)
				K.ShowOverlayGlow(button2)
			else
				K.HideOverlayGlow(button3)
				K.HideOverlayGlow(button3)
			end
		end

		UpdateCooldown(self.lumos[4], 366155, true) --逆转
		UpdateCooldown(self.lumos[5], 360995, true) --清脆之拥
	end
end
