local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

-- Based on oUF_GCD(by Exactly)
local _, ns = ...
local oUF = ns.oUF

local starttime, duration, usingspell, spellid
local GetTime = GetTime

local referenceSpells = {
	47541,			-- Death Coil (Death Knight)
	45902,			-- Blood Strike (Death Knight) (was 66215)
	186257,			-- Aspect of the Cheetah (Hunter)
	585,			-- Smite (Priest)
	35395,			-- Crusader Strike (Paladin)
	172,			-- Corruption (Warlock)
	34428,			-- Victory Rush (Warrior) (was 772)
	44614,			-- Frostfire (Mage)
	403,			-- Lightning Bolt (Shaman)
	6770,			-- Sap (Rogue)
	5176,			-- Wrath (Druid)
	100780,			-- Jab (Monk)
	162794,			-- Chaos Strike (Demon Hunter, Havoc)
	222030,			-- Soul Cleave (Demon Hunter, Vengeance)
}

local GetTime = GetTime
local BOOKTYPE_SPELL = BOOKTYPE_SPELL
local GetSpellCooldown = GetSpellCooldown

local spellid = nil

local Init = function()
	local FindInSpellbook = function(spell)
		for tab = 1, 4 do
			local _, _, offset, numSpells = GetSpellTabInfo(tab)
			for i = (1+offset), (offset + numSpells) do
				local bspell = GetSpellBookItemName(i, BOOKTYPE_SPELL)
				if (bspell == spell) then
					return i
				end
			end
		end
		return nil
	end

	for _, lspell in pairs(referenceSpells) do
		local na = GetSpellInfo (lspell)
		local x = FindInSpellbook(na)
		if x ~= nil then
			spellid = lspell
			break
		end
	end

	if spellid == nil then
		-- XXX: print some error ..
		print ("Spell not found: "..spell.."!")
	end

	return spellid
end

local OnUpdateGCD = function(self)
	local perc = (GetTime() - self.starttime) / self.duration
	if perc > 1 then
		self:Hide()
	else
		self:SetValue(perc)
	end
end

local OnHideGCD = function(self)
	self:SetScript("OnUpdate", nil)
end

local OnShowGCD = function(self)
	self:SetScript("OnUpdate", OnUpdateGCD)
end

local Update = function(self, event, unit)
	if self.GCD then
		if spellid == nil then
			if Init() == nil then
				return
			end
		end

		local start, dur = GetSpellCooldown(spellid)

		if (not start) then return end
		if (not dur) then dur = 0 end

		if (dur == 0) then
			self.GCD:Hide()
		else
			self.GCD.starttime = start
			self.GCD.duration = dur
			self.GCD:Show()
		end
	end
end

local Enable = function(self)
	if (self.GCD) then
		self.GCD:Hide()
		self.GCD.starttime = 0
		self.GCD.duration = 0
		self.GCD:SetMinMaxValues(0, 1)

		self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Update)
		self.GCD:SetScript("OnHide", OnHideGCD)
		self.GCD:SetScript("OnShow", OnShowGCD)
	end
end

local Disable = function(self)
	if (self.GCD) then
		self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		self.GCD:Hide()
	end
end

oUF:AddElement("GCD", Update, Enable, Disable)