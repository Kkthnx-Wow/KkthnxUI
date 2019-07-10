local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitIsFriend = _G.UnitIsFriend

local ImportantBuffs = {
	[1022] = true, -- Hand of Protection
	[2825] = true, -- Bloodlust
	[20707] = true, -- Soulstone
	[32182] = true, -- Heroism
	[80353] = true, -- Time Warp
	[90355] = true, -- Ancient Hysteria
	[178207] = true, -- Drums of Fury
	[230935] = true, -- Drums of the Mountain
}

local ImportantDebuffs = {
	[6788] = K.Class == "PRIEST", -- Weakened Soul
	[25771] = K.Class == "PALADIN", -- Forbearance
	[212570] = true, -- Surrendered Soul
}

local CustomBuffFilter = {
	player = function(_, _, aura, _, _, _, _, duration, _, caster, _, _, spellID, _, _, casterIsPlayer)
		return not casterIsPlayer or
		duration and duration > 0 and duration <= 300 and (aura.isPlayer or caster == "pet") or
		ImportantBuffs[spellID]
	end,

	target = function(_, unit, aura, _, _, _, _, _, _, caster, _, _, _, _, _, casterIsPlayer)
		if(UnitIsFriend(unit, "player")) then
			return aura.isPlayer or caster == "pet" or not casterIsPlayer
		else
			return true
		end
	end,
}

local CustomDebuffFilter = {
	target = function(_, unit, aura, _, _, _, _, _, _, caster, _, _, spellID, _, isBossDebuff, casterIsPlayer)
		if (not UnitIsFriend(unit, "player")) then
			return aura.isPlayer or caster == "pet" or not casterIsPlayer or isBossDebuff or ImportantDebuffs[spellID]
		else
			return true
		end
	end,

	focus = function(_, unit, aura, _, _, _, _, _, _, caster, _, _, spellID, _, isBossDebuff, casterIsPlayer)
		if (not UnitIsFriend(unit, "player")) then
			return aura.isPlayer or caster == "pet" or not casterIsPlayer or isBossDebuff or ImportantDebuffs[spellID]
		else
			return true
		end
	end,
}

function Module:CreatePlayerAuras()
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)

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
	Buffs.CustomFilter = CustomBuffFilter.player

	self.Buffs = Buffs
end

function Module:CreateTargetAuras()
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	local Auras = CreateFrame("Frame", self:GetName() .. "Auras", self)

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
		Buffs.CustomFilter = CustomBuffFilter.target

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
		Debuffs.CustomFilter = CustomDebuffFilter.target

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
end

function Module:CreateFocusAuras()
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	local Auras = CreateFrame("Frame", self:GetName() .. "Auras", self)

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
		Debuffs.CustomFilter = CustomDebuffFilter.target

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
end

function Module:CreatePartyAuras()
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)

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
end

function Module:CreatePetAuras()
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)

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
end

function Module:CreateTargetTargetAuras()
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)

	Debuffs:SetHeight(22)
	Debuffs:SetWidth(74)
	Debuffs:SetPoint("LEFT", self.Portrait, "RIGHT", 6, 0)
	Debuffs.size = 22
	Debuffs.num = 4
	Debuffs.spacdwing = 6
	Debuffs.initialAnchor = "LEFT"
	Debuffs["growth-y"] = "DOWN"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs.PostCreateIcon = Module.PostCreateAura
	Debuffs.PostUpdateIcon = Module.PostUpdateAura

	self.Debuffs = Debuffs
end

function Module:CreateArenaAuras()
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)

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

function Module:CreateBossAuras()
	local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)

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
end

function Module:CreateNameplateAuras()
	if C["Nameplates"].TrackAuras == true then
		local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)

		Debuffs:SetWidth(C["Nameplates"].Width)
		Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -4)
		Debuffs.num = 5 * 2
		Debuffs.spacing = 3
		Debuffs.size = ((((Debuffs:GetWidth() - (Debuffs.spacing * (Debuffs.num / 2 - 1))) / Debuffs.num)) * 2)
		Debuffs:SetHeight(Debuffs.size * 2)
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.onlyShowPlayer = true
		Debuffs.filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY"
		Debuffs.disableMouse = true
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	end
end