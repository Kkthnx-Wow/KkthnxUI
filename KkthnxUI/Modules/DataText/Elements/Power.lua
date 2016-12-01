local K, C, L = select(2, ...):unpack()

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local format = string.format

local function Update(self)
	local Value, Spell
	local Base, PosBuff, NegBuff = UnitAttackPower("player")
	local Effective = Base + PosBuff + NegBuff
	local RangedBase, RangedPosBuff, RangedNegBuff = UnitRangedAttackPower("player")
	local RangedEffective = RangedBase + RangedPosBuff + RangedNegBuff
	local Text = ATTACK_POWER

	HealPower = GetSpellBonusHealing()
	SpellPower = GetSpellBonusDamage(7)
	AttackPower = Effective

	if (HealPower > SpellPower) then
		Spell = HealPower
	else
		Spell = SpellPower
	end

	if (AttackPower > Spell and K.Class ~= "HUNTER") then
		Value = AttackPower
	elseif (K.Class == "HUNTER") then
		Value = RangedEffective
	else
		Value = Spell
		Text = ITEM_MOD_SPELL_POWER_SHORT
	end

	self.Text:SetFormattedText("%s: %s", NameColor .. Text .. "|r", ValueColor .. K.Comma(Value) .. "|r")
end

local function Enable(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", Update)
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
end

DataText:Register(ATTACK_POWER, Enable, Disable, Update)