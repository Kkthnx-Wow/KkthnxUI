local K, C, _ = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local _G = _G

local UnitExists = _G.UnitExists

local CMS = CreateFrame("Frame")

-- GLOBALS: oUF_KkthnxPlayer, TotemFrame, RuneFrame, SPEC_MAGE_ARCANE, MageArcaneChargesFrame, SPEC_MONK_BREWMASTER, MonkStaggerBar
-- GLOBALS: SPEC_MONK_WINDWALKER, MonkHarmonyBarFrame, SPEC_PALADIN_RETRIBUTION, PaladinPowerBarFrame, ComboPointPlayerFrame
-- GLOBALS: WarlockPowerFrame, oUF_KkthnxPet

local function CustomTotemFrame_Update()
	local hasPet = UnitExists("pet") and oUF_KkthnxPet and oUF_KkthnxPet:IsShown()

	if (K.Class == "WARLOCK") then
		if (hasPet) then
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 0, -75)
		else
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 25, -25)
		end
	end

	if (K.Class == "SHAMAN") then
		if (hasPet) then
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 0, -75)
		else
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 25, -25)
		end
	end

	if (K.Class == "PALADIN" or K.Class == "DEATHKNIGHT" or K.Class == "DRUID" or K.Class == "MAGE" or K.Class == "MONK") then
		TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 25, 0)
	end
end
hooksecurefunc("TotemFrame_Update", CustomTotemFrame_Update)

function CMS:SetupAlternatePowerBar(self)
	self.AdditionalPower = K.CreateOutsideBar(self, false, 0, 0, 1)
	self.DruidMana = self.AdditionalPower
	self.AdditionalPower.colorPower = true

	self.AdditionalPower.Value = K.SetFontString(self.AdditionalPower, C.Media.Font, 10, nil, "CENTER")
	self.AdditionalPower.Value:SetPoint("CENTER", self.AdditionalPower, 0, 0.5)
	self.AdditionalPower.Value:Hide()

	self.AdditionalPower.Smooth = C.Unitframe.Smooth
	self.AdditionalPower.SmoothSpeed = C.Unitframe.SmoothSpeed * 10
	self:Tag(self.AdditionalPower.Value, "[KkthnxUI:DruidMana]")
end

function CMS:HideAltResources()
	if (K.Class == "SHAMAN") then
		TotemFrame:Hide()
	elseif (K.Class == "DEATHKNIGHT") then
		RuneFrame:Hide()
	elseif (K.Class == "MAGE" and K.Spec == 1 or SPEC_MAGE_ARCANE) then
		MageArcaneChargesFrame:Hide()
	elseif (K.Class == "MONK") then
		if (K.Spec == 1 or SPEC_MONK_BREWMASTER) then
			MonkStaggerBar:Hide()
		elseif (K.Spec == 3 or SPEC_MONK_WINDWALKER) then
			MonkHarmonyBarFrame:Hide()
		end
	elseif (K.Class == "PALADIN" and K.Spec == 3 or SPEC_PALADIN_RETRIBUTION) then
		PaladinPowerBarFrame:Hide()
	elseif (K.Class == "ROGUE") then
		ComboPointPlayerFrame:Hide()
	elseif (K.Class == "WARLOCK") then
		WarlockPowerFrame:Hide()
	end
end

function CMS:ShowAltResources()
	if (K.Class == "SHAMAN") then
		TotemFrame:Show()
	elseif (K.Class == "DEATHKNIGHT") then
		RuneFrame:Show()
	elseif (K.Class == "MAGE" and K.Spec == 1 or SPEC_MAGE_ARCANE) then
		MageArcaneChargesFrame:Show()
	elseif (K.Class == "MONK") then
		if (K.Spec == 1 or SPEC_MONK_BREWMASTER) then
			MonkStaggerBar:Show()
		elseif (K.Spec == 3 or SPEC_MONK_WINDWALKER) then
			MonkHarmonyBarFrame:Show()
		end
	elseif (K.Class == "PALADIN" and K.Spec == 3 or SPEC_PALADIN_RETRIBUTION) then
		PaladinPowerBarFrame:Show()
	elseif (K.Class == "ROGUE") then
		ComboPointPlayerFrame:Show()
	elseif (K.Class == "WARLOCK") then
		WarlockPowerFrame:Show()
	end
end

function CMS:SetupResources(self)
	-- Alternate Mana Bar
	if (C.UnitframePlugins.AdditionalPower) and (K.Class == "DRUID" or K.Class == "SHAMAN" or K.Class == "PRIEST") then
		K.CMS:SetupAlternatePowerBar(self)
	end

	-- Warlock Soul Shards
	if (K.Class == "WARLOCK") then
		WarlockPowerFrame:ClearAllPoints()
		WarlockPowerFrame:SetParent(oUF_KkthnxPlayer)
		WarlockPowerFrame:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 30, -2)
	end

	-- Holy Power Bar (Retribution Only)
	if (K.Class == "PALADIN" and K.Spec == 3 or SPEC_PALADIN_RETRIBUTION) then
		PaladinPowerBarFrame:ClearAllPoints()
		PaladinPowerBarFrame:SetParent(self)
		PaladinPowerBarFrame:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 25, 2)
    PaladinPowerBarFrame:Show()
	end

	-- Monk Chi / Stagger Bar
	if (K.Class == "MONK") then
		-- Windwalker Chi
		MonkHarmonyBarFrame:ClearAllPoints()
		MonkHarmonyBarFrame:SetParent(oUF_KkthnxPlayer)
		MonkHarmonyBarFrame:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 30, 18)

		-- Brewmaster Stagger Bar
		MonkStaggerBar:ClearAllPoints()
		MonkStaggerBar:SetParent(oUF_KkthnxPlayer)
		MonkStaggerBar:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 30, -2)
	end

	-- Deathknight Runebar
	if (K.Class == "DEATHKNIGHT") then
		RuneFrame:ClearAllPoints()
		RuneFrame:SetParent(oUF_KkthnxPlayer)
		RuneFrame:SetPoint("TOP", self.Power, "BOTTOM", 2, -2)
	end

	-- Arcane Mage
	if (K.Class == "MAGE") then
		MageArcaneChargesFrame:ClearAllPoints()
		MageArcaneChargesFrame:SetParent(oUF_KkthnxPlayer)
		MageArcaneChargesFrame:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 30, -2)
	end

	-- Combo Point Frame
	if (K.Class == "ROGUE" or K.Class == "DRUID") then
		ComboPointPlayerFrame:ClearAllPoints()
		ComboPointPlayerFrame:SetParent(oUF_KkthnxPlayer)
		ComboPointPlayerFrame:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", -3, 2)
	end

	-- Finish TotemFrame
	if (K.Class == "SHAMAN" or K.Class == "WARLOCK" or K.Class == "DRUID" or K.Class == "PALADIN" or K.Class == "DEATHKNIGHT" or K.Class == "MAGE" or K.Class == "MONK") then
		TotemFrame:SetFrameStrata("LOW")
		TotemFrame:SetParent(oUF_KkthnxPlayer)
		CustomTotemFrame_Update()
	end
	-- Register the event!
	self:RegisterEvent("PLAYER_TOTEM_UPDATE", CustomTotemFrame_Update)
end

K.CMS = CMS