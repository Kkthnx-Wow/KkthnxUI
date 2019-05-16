local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

local function FilterSharedBuffs(_, _, _, name)
	if (Module.UnImportantBuffs[name]) then
		return false
	else
		return true
	end
end

-- We will handle these individually so we can have the up most control of our auras on each unit/frame
function Module:CreateAuras(unit)
	unit = unit:match("^(%a-)%d+") or unit

	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	local Auras = CreateFrame("Frame", self:GetName() .. "Auras", self)

	K.Movers:RegisterFrame(Buffs)
	K.Movers:RegisterFrame(Debuffs)
	K.Movers:RegisterFrame(Auras)

	if (unit == "player") then
		if K.Class == "ROGUE"
		or K.Class == "DRUID"
		or K.Class == "MAGE"
		or K.Class == "MONK"
		or K.Class == "DEATHKNIGHT"
		or K.Class == "SHAMAN"
		or K.Class == "PALADIN"
		or K.Class == "WARLOCK" then
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -26)
		else
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		end
		Buffs:SetWidth(140)
		Buffs.num = 5 * 4
		Buffs.spacing = 6
		Buffs.size = ((((Buffs:GetWidth() - (Buffs.spacing * (Buffs.num / 4 - 1))) / Buffs.num)) * 4)
		Buffs:SetHeight(Buffs.size * 4)
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura
		Buffs.CustomFilter = FilterSharedBuffs

		self.Buffs = Buffs
	elseif (unit == "target") then
		if C["Unitframe"].DebuffsOnTop then
			Buffs:SetWidth(140)
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Buffs.num = 5 * 4
			Buffs.spacing = 6
			Buffs.size = ((((Buffs:GetWidth() - (Buffs.spacing * (Buffs.num / 4 - 1))) / Buffs.num)) * 4)
			Buffs:SetHeight(Buffs.size * 4)
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.PostCreateIcon = Module.PostCreateAura
			Buffs.PostUpdateIcon = Module.PostUpdateAura
			Buffs.CustomFilter = FilterSharedBuffs

			Debuffs:SetWidth(140)
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, -70)
			Debuffs.num = 4 * 4
			Debuffs.spacing = 6
			Debuffs.size = ((((Debuffs:GetWidth() - (Debuffs.spacing * (Debuffs.num / 4 - 1))) / Debuffs.num)) * 4)
			Debuffs:SetHeight(Debuffs.size * 4)
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
			Auras:SetWidth(140)
			Auras:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Auras.num = 5 * 4
			Auras.spacing = 6
			Auras.size = ((((Auras:GetWidth() - (Auras.spacing * (Auras.num / 4 - 1))) / Auras.num)) * 4)
			Auras:SetHeight(Auras.size * 4)
			Auras.initialAnchor = "TOPLEFT"
			Auras["growth-y"] = "DOWN"
			Auras["growth-x"] = "RIGHT"
			Auras.showStealableBuffs = true
			Auras.PostCreateIcon = Module.PostCreateAura
			Auras.PostUpdateIcon = Module.PostUpdateAura

			self.Auras = Auras
		end
	elseif (unit == "focus") then
		if C["Unitframe"].DebuffsOnTop then
			Buffs:SetHeight(21)
			Buffs:SetWidth(130)
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
			Debuffs:SetWidth(130)
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
		if C["Party"].ShowBuffs then
			Buffs:SetHeight(18)
			Buffs:SetWidth(116)
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Buffs.size = 18
			Buffs.num = 4
			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.PostCreateIcon = Module.PostCreateAura
			Buffs.PostUpdateIcon = Module.PostUpdateAura
			Buffs.CustomFilter = FilterSharedBuffs

			self.Buffs = Buffs
		end

		Debuffs:SetHeight(32)
		Debuffs:SetWidth(110)
		Debuffs:SetPoint("TOPLEFT", self, "TOPRIGHT", 3, -3)
		Debuffs.size = 32
		Debuffs.num = 3
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	elseif (unit == "targettarget") then
		Debuffs:SetHeight(22)
		Debuffs:SetWidth(74)
		Debuffs:SetPoint("LEFT", self.Portrait, "RIGHT", 6, 0)
		Debuffs.size = 22
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "LEFT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	elseif (unit == "pet") then
		Debuffs:SetHeight(22)
		Debuffs:SetWidth(74)
		Debuffs:SetPoint("RIGHT", self.Portrait, "LEFT", -6, 0)
		Debuffs.size = 22
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	elseif (unit == "boss") then
		Buffs:SetHeight(14)
		Buffs:SetWidth(130)
		Buffs:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMLEFT", -6, 0)
		Buffs.size = 14
		Buffs.num = 4
		Buffs.spacing = 6
		Buffs.initialAnchor = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "LEFT"
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		Debuffs:SetHeight(26)
		Debuffs:SetWidth(130)
		Debuffs:SetPoint("TOPRIGHT", self.Portrait, "TOPLEFT", -6, 0)
		Debuffs.size = 26
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
		Buffs:SetHeight(14)
		Buffs:SetWidth(130)
		Buffs:SetPoint("BOTTOMRIGHT", self.Trinket, "BOTTOMLEFT", -6, 0)
		Buffs.size = 14
		Buffs.num = 4
		Buffs.spacing = 6
		Buffs.initialAnchor = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "LEFT"
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		Debuffs:SetHeight(26)
		Debuffs:SetWidth(130)
		Debuffs:SetPoint("TOPRIGHT", self.Trinket, "TOPLEFT", -6, 0)
		Debuffs.size = 26
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