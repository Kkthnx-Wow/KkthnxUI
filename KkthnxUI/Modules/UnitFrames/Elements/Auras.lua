local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitIsFriend = _G.UnitIsFriend

-- GLOBALS: DebuffTypeColor

local function FilterSharedBuffs(_, _, _, name)
	if (Module.UnImportantBuffs[name]) then
		return false
	else
		return true
	end
end

local function FilterGroupDebuffs(_, unit, button, name, _, _, _, _, _, _, caster, _, _, _, _, isBossDebuff, casterIsPlayer)
	if (not UnitIsFriend("player", unit)) then
		return button.isPlayer or caster == "pet" or not casterIsPlayer or isBossDebuff or Module.ImportantDebuffs[name]
	else
		return false
	end
end

-- We will handle these individually so we can have the up most control of our auras on each unit/frame
function Module:CreateAuras(unit)
	unit = unit:match("^(%a-)%d+") or unit

	local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	local Auras = CreateFrame("Frame", self:GetName().."Auras", self)

	if (unit == "target") then
		if C["Unitframe"].DebuffsOnTop then
			Buffs:SetHeight(21)
			Buffs:SetWidth(self.Power:GetWidth())
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Buffs.size = 21
			Buffs.num = 15
			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.PostCreateIcon = Module.PostCreateAura
			Buffs.PostUpdateIcon = Module.PostUpdateAura
			Buffs.CustomFilter = FilterSharedBuffs

			Debuffs:SetHeight(28)
			Debuffs:SetWidth(self.Health:GetWidth())
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
			Debuffs.size = 28
			Debuffs.num = 12
			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
			Debuffs.PostCreateIcon = Module.PostCreateAura
			Debuffs.PostUpdateIcon = Module.PostUpdateAura

			self.Buffs = Buffs
			self.Debuffs = Debuffs
		else
			Auras.gap = false
			Auras.size = 21
			Auras:SetHeight(21)
			Auras:SetWidth(130)
			Auras:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Auras.initialAnchor = "TOPLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "DOWN"
			Auras.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
			Auras.numBuffs = 15
			Auras.numDebuffs = 12
			Auras.spacing = 6
			Auras.showStealableBuffs = true
			Auras.PostCreateIcon = Module.PostCreateAura
			Auras.PostUpdateIcon = Module.PostUpdateAura
			self.Auras = Auras
		end
	elseif (unit == "focus") then
		if C["Unitframe"].DebuffsOnTop then
			Buffs:SetHeight(21)
			Buffs:SetWidth(self.Power:GetWidth())
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Buffs.size = 21
			Buffs.num = 15
			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.PostCreateIcon = Module.PostCreateAura
			Buffs.PostUpdateIcon = Module.PostUpdateAura
			Buffs.CustomFilter = FilterSharedBuffs

			Debuffs:SetHeight(28)
			Debuffs:SetWidth(self.Health:GetWidth())
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
			Debuffs.size = 28
			Debuffs.num = 12
			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.PostCreateIcon = Module.PostCreateAura
			Debuffs.PostUpdateIcon = Module.PostUpdateAura

			self.Buffs = Buffs
			self.Debuffs = Debuffs
		else
			Auras.gap = false
			Auras.size = 21
			Auras:SetHeight(21)
			Auras:SetWidth(130)
			Auras:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Auras.initialAnchor = "TOPLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "DOWN"
			Auras.numBuffs = 15
			Auras.numDebuffs = 12
			Auras.spacing = 6
			Auras.showStealableBuffs = true
			Auras.PostCreateIcon = Module.PostCreateAura
			Auras.PostUpdateIcon = Module.PostUpdateAura
			self.Auras = Auras
		end
	elseif (unit == "party") then
		Buffs:SetHeight(20)
		Buffs:SetWidth(self:GetWidth())
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 20
		Buffs.num = 4
		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura
		Buffs.CustomFilter = FilterSharedBuffs

		Debuffs:SetHeight(28)
		Debuffs:SetWidth(self.Power:GetWidth())
		Debuffs:SetPoint("LEFT", self, "RIGHT", 3, 0)
		Debuffs.size = 28
		Debuffs.num = 3
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura
		Debuffs.CustomFilter = FilterGroupDebuffs

		self.Buffs = Buffs
		self.Debuffs = Debuffs
	elseif (unit == "targettarget") then
		Debuffs:SetHeight(self.Portrait:GetHeight() - 4)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("LEFT", self.Portrait, "RIGHT", 6, 0)
		Debuffs.size = self.Portrait:GetHeight() - 4
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "LEFT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	elseif (unit == "pet") then
		Debuffs:SetHeight(self.Portrait:GetHeight() - 4)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("RIGHT", self.Portrait, "LEFT", -6, 0)
		Debuffs.size = self.Portrait:GetHeight() - 4
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	elseif (unit == "boss") then
		Buffs:SetHeight(self.Power:GetHeight())
		Buffs:SetWidth(self.Power:GetWidth())
		Buffs:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMLEFT", -6, 0)
		Buffs.size = self.Power:GetHeight()
		Buffs.num = 4
		Buffs.spacing = 6
		Buffs.initialAnchor = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "LEFT"
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		Debuffs:SetHeight(self.Health:GetHeight())
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("TOPRIGHT", self.Portrait, "TOPLEFT", -6, 0)
		Debuffs.size = self.Health:GetHeight()
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Buffs = Buffs
		self.Debuffs = Debuffs
	elseif (unit == "arena") then
		Buffs:SetHeight(self.Power:GetHeight())
		Buffs:SetWidth(self.Power:GetWidth())
		Buffs:SetPoint("BOTTOMRIGHT", self.Trinket, "BOTTOMLEFT", -6, 0)
		Buffs.size = self.Power:GetHeight()
		Buffs.num = 4
		Buffs.spacing = 6
		Buffs.initialAnchor = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "LEFT"
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		Debuffs:SetHeight(self.Health:GetHeight())
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("TOPRIGHT", self.Trinket, "TOPLEFT", -6, 0)
		Debuffs.size = self.Health:GetHeight()
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Buffs = Buffs
		self.Debuffs = Debuffs
	end
end