local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
ns.classModule = {}

local function updateTotemPosition()
	TotemFrame:ClearAllPoints()
	if (K.Class == "PALADIN" or K.Class == "DEATHKNIGHT") then
		local hasPet = oUF_KkthnxPet and oUF_KkthnxPet:IsShown()
		if (hasPet) then
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", -18, -12)
		else
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 17, 0)
		end
	elseif (K.Class == "DRUID") then
		local form = GetShapeshiftFormID()
		if (form == CAT_FORM) then
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 37, -5)
		else
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 57, 0)
		end
	elseif (K.Class == "MAGE") then
		TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 0, -12)
	elseif (K.Class == "MONK") then
		TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", -18, -12)
	elseif (K.Class == "SHAMAN") then
		local form = GetShapeshiftFormID()
		if ((GetSpecialization() == SPEC_SHAMAN_RESTORATION) or (form == 16)) then -- wolf form
			TotemFrame:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 27, 2)
		else
			TotemFrame:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 27, -10)
		end
	elseif (K.Class == "WARLOCK") then
		TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", -18, -12)
	end
end

function ns.classModule.Totems(self)
	TotemFrame:ClearAllPoints()
	TotemFrame:SetParent(self)

	for i = 1, MAX_TOTEMS do
		local _, totemBorder = _G["TotemFrameTotem"..i]:GetChildren()
		if C.Blizzard.ColorTextures == true then
			totemBorder:GetRegions():SetVertexColor(unpack(C.Blizzard.TexturesColor))
		end

		_G["TotemFrameTotem"..i]:SetFrameStrata("LOW")
		if C.Cooldown.Enable then
			_G["TotemFrameTotem"..i.. "Duration"]:SetParent(UIFrameHider)
		else
			_G["TotemFrameTotem"..i.. "Duration"]:SetParent(totemBorder)
			_G["TotemFrameTotem"..i.. "Duration"]:SetDrawLayer("OVERLAY")
			_G["TotemFrameTotem"..i.. "Duration"]:ClearAllPoints()
			_G["TotemFrameTotem"..i.. "Duration"]:SetPoint("BOTTOM", _G["TotemFrameTotem"..i], 0, 3)
			_G["TotemFrameTotem"..i.. "Duration"]:SetFont(C.Media.Font, 10, "OUTLINE")
			_G["TotemFrameTotem"..i.. "Duration"]:SetShadowOffset(0, 0)
		end
	end

	-- K.Noop these else we'll get a taint
	TotemFrame_AdjustPetFrame = K.Noop
	PlayerFrame_AdjustAttachments = K.Noop

	hooksecurefunc("TotemFrame_Update", updateTotemPosition)
	updateTotemPosition()
end

function ns.classModule.alternatePowerBar(self)
	self.AdditionalPower = K.CreateOutsideBar(self, false, 0, 0, 1)
	self.DruidMana = self.AdditionalPower
	self.AdditionalPower.colorPower = true

	self.AdditionalPower.Value = K.SetFontString(self.AdditionalPower, C.Media.Font, 13, nil, "CENTER")
	self.AdditionalPower.Value:SetPoint("CENTER", self.AdditionalPower, 0, 0.5)
	self.AdditionalPower.Value:Hide()
	self:Tag(self.AdditionalPower.Value, "[KkthnxUI:DruidMana]")
end

function ns.classModule.DEATHKNIGHT(self, config, uconfig)
	if (config.DEATHKNIGHT.showRunes) then
		RuneFrame:SetParent(self)
		RuneFrame_OnLoad(RuneFrame)
		RuneFrame:ClearAllPoints()
		RuneFrame:SetPoint("TOP", self, "BOTTOM", 33, -1)
		if (ns.config.playerStyle == "normal") then
			RuneFrame:SetFrameStrata("LOW")
		end
		for i = 1, 6 do
			local b = _G["RuneButtonIndividual"..i].Border
			if C.Blizzard.ColorTextures == true then
				b:GetRegions():SetVertexColor(unpack(C.Blizzard.TexturesColor))
			end
		end
	end
end

function ns.classModule.MAGE(self, config, uconfig)
	if (config.MAGE.showArcaneStacks) then
		MageArcaneChargesFrame:SetParent(self)
		MageArcaneChargesFrame:ClearAllPoints()
		MageArcaneChargesFrame:SetPoint("TOP", self, "BOTTOM", 30, -0.5)

		return MageArcaneChargesFrame
	end
end

function ns.classModule.MONK(self, config, uconfig)
	if (config.MONK.showStagger) then
		-- Stagger Bar for tank monk
		MonkStaggerBar:SetParent(self)
		MonkStaggerBar_OnLoad(MonkStaggerBar)
		MonkStaggerBar:ClearAllPoints()
		MonkStaggerBar:SetPoint("TOP", self, "BOTTOM", 31, 0)
		if C.Blizzard.ColorTextures == true then
			MonkStaggerBar.MonkBorder:SetVertexColor(unpack(C.Blizzard.TexturesColor))
		end
		MonkStaggerBar:SetFrameLevel(1)
	end

	if (config.MONK.showChi) then
		-- Monk combo points for Windwalker
		MonkHarmonyBarFrame:SetParent(self)
		MonkHarmonyBarFrame:ClearAllPoints()
		MonkHarmonyBarFrame:SetPoint("TOP", self, "BOTTOM", 31, 18)
		if C.Blizzard.ColorTextures == true then
			select(2, MonkHarmonyBarFrame:GetRegions()):SetVertexColor(unpack(C.Blizzard.TexturesColor))
		end
		return MonkHarmonyBarFrame
	end
end

function ns.classModule.PALADIN(self, config, uconfig)
	if (config.PALADIN.showHolyPower) then
		PaladinPowerBarFrame:SetParent(self)
		PaladinPowerBarFrame:ClearAllPoints()
		PaladinPowerBarFrame:SetPoint("TOP", self, "BOTTOM", 27, 4)
		PaladinPowerBarFrame:SetFrameStrata("LOW")
		if C.Blizzard.ColorTextures == true then
			PaladinPowerBarFrameBG:SetVertexColor(unpack(C.Blizzard.TexturesColor))
		end
		return PaladinPowerBarFrame
	end
end

function ns.classModule.PRIEST(self, config, uconfig)
	if (config.PRIEST.showInsanity) then
		InsanityBarFrame:SetParent(self)
		InsanityBarFrame:ClearAllPoints()
		InsanityBarFrame:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 52, -50)
		return InsanityBarFrame
	end
end

function ns.classModule.WARLOCK(self, config, uconfig)
	if (config.WARLOCK.showShards) then
		WarlockPowerFrame:SetParent(self)
		WarlockPowerFrame:ClearAllPoints()
		WarlockPowerFrame:SetPoint("TOP", self, "BOTTOM", 29, -2)
		if (ns.config.playerStyle == "normal") then
			WarlockPowerFrame:SetFrameStrata("LOW")
		end
		for i = 1, 5 do
			local shard = _G["WarlockPowerFrameShard"..i]
			if C.Blizzard.ColorTextures == true then
				select(5, shard:GetRegions()):SetVertexColor(unpack(C.Blizzard.TexturesColor))
			end
		end

		return WarlockPowerFrame
	end
end