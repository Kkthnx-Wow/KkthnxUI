local K, C, _ = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

-- There seems to be an issue with GetSpecialization() not being up on first login. It will work fine once you /reload the ui.
-- Maybe workaround this with checking if logged in.

local _G = _G

local CAT_FORM = _G.CAT_FORM
local GetShapeshiftFormID = _G.GetShapeshiftFormID
local GetSpecialization = _G.GetSpecialization
local hooksecurefunc = _G.hooksecurefunc
local MAX_TOTEMS = _G.MAX_TOTEMS
local SPEC_SHAMAN_RESTORATION = _G.SPEC_SHAMAN_RESTORATION
local UnitClass = _G.UnitClass

local CMS = CreateFrame("Frame")

-- GLOBALS: oUF_KkthnxPlayer, TotemFrame, RuneFrame, SPEC_MAGE_ARCANE, MageArcaneChargesFrame, SPEC_MONK_BREWMASTER, MonkStaggerBar
-- GLOBALS: PriestBarFrame_CheckAndShow, InsanityBarFrame, MonkStaggerBar_OnLoad, RuneFrame_OnLoad
-- GLOBALS: SPEC_MONK_WINDWALKER, MonkHarmonyBarFrame, SPEC_PALADIN_RETRIBUTION, PaladinPowerBarFrame, ComboPointPlayerFrame
-- GLOBALS: WarlockPowerFrame, oUF_KkthnxPet, EclipseBarFrame, PriestBarFrame, TotemFrame_Update, EclipseBar_UpdateShown

local function CustomTotemFrame_Update()
	local _, class = UnitClass("player")

	TotemFrame:ClearAllPoints()
	if (class == "PALADIN" or class == "DEATHKNIGHT") then
		local hasPet = oUF_KkthnxPet and oUF_KkthnxPet:IsShown()
		if (hasPet) then
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", -18, -12)
		else
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 17, 0)
		end
	elseif (class == "DRUID") then
		local form = GetShapeshiftFormID()
		if (form == CAT_FORM) then
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 37, -5)
		else
			TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 57, 0)
		end
	elseif (class == "MAGE") then
		TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", 0, -12)
	elseif (class == "MONK") then
		TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", -18, -12)
	elseif (class == "SHAMAN") then
		local form = GetShapeshiftFormID()
		if ((GetSpecialization() == SPEC_SHAMAN_RESTORATION) or (form == 16)) then -- wolf form
			TotemFrame:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 27, 2)
		else
			TotemFrame:SetPoint("TOP", oUF_KkthnxPlayer, "BOTTOM", 27, -10)
		end
	elseif (class == "WARLOCK") then
		TotemFrame:SetPoint("TOPLEFT", oUF_KkthnxPlayer, "BOTTOMLEFT", -18, -12)
	end
end

function CMS:SetupAlternatePowerBar(self)
	self.AdditionalPower = K.CreateOutsideBar(self, false, 0, 0, 1)
	self.DruidMana = self.AdditionalPower
	self.AdditionalPower.colorPower = true

	self.AdditionalPower.Value = K.SetFontString(self.AdditionalPower, C.Media.Font, 10, nil, "CENTER")
	self.AdditionalPower.Value:SetPoint("CENTER", self.AdditionalPower, 0, 0.5)
	self.AdditionalPower.Value:Hide()

	self.AdditionalPower.Smooth = C.Unitframe.Smooth
	-- self.AdditionalPower.SmoothSpeed = C.Unitframe.SmoothSpeed * 10
	self:Tag(self.AdditionalPower.Value, "[KkthnxUI:DruidMana]")
end

function CMS:SetupTotemFrame(self)
	TotemFrame:ClearAllPoints()
	TotemFrame:SetParent(self)

	for i = 1, MAX_TOTEMS do
		local _, totemBorder = _G["TotemFrameTotem"..i]:GetChildren()

		_G["TotemFrameTotem"..i]:SetFrameStrata("LOW")
		_G["TotemFrameTotem"..i.. "Duration"]:SetParent(totemBorder)
		_G["TotemFrameTotem"..i.. "Duration"]:SetDrawLayer("OVERLAY")
		_G["TotemFrameTotem"..i.. "Duration"]:ClearAllPoints()
		_G["TotemFrameTotem"..i.. "Duration"]:SetPoint("BOTTOM", _G["TotemFrameTotem"..i], 0, 3)
		_G["TotemFrameTotem"..i.. "Duration"]:SetFont(C.Media.Font, 10, "OUTLINE")
		_G["TotemFrameTotem"..i.. "Duration"]:SetShadowOffset(0, 0)
	end

	hooksecurefunc("TotemFrame_Update", CustomTotemFrame_Update)
	CustomTotemFrame_Update()
end

function CMS:HideAltResources(self)
	local playerClass = select(2, UnitClass("player"))

	if (self.classPowerBar) then
		self.classPowerBar:Hide()
	end

	TotemFrame:Hide()

	if (playerClass == "SHAMAN") then
	elseif (playerClass == "DRUID") then
		-- EclipseBarFrame:Hide()
	elseif (playerClass == "DEATHKNIGHT") then
		RuneFrame:Hide()
	elseif (playerClass == "PRIEST") then
		PriestBarFrame:Hide()
	end
end

function CMS:ShowAltResources(self)
	local playerClass = select(2, UnitClass("player"))

	if (self.classPowerBar) then
		self.classPowerBar:Setup()
	end

	TotemFrame_Update()

	if (playerClass == "SHAMAN") then
	elseif (playerClass == "DRUID") then
		-- EclipseBar_UpdateShown(EclipseBarFrame)
	elseif (playerClass == "DEATHKNIGHT") then
		RuneFrame:Show()
	elseif (playerClass == "PRIEST") then
		PriestBarFrame_CheckAndShow()
	end
end

function CMS:SetupResources(self)
	local playerClass = select(2, UnitClass("player"))

	-- Alternate Mana Bar
	if (C.UnitframePlugins.AdditionalPower) and (playerClass == "DRUID" or playerClass == "SHAMAN" or playerClass == "PRIEST") then
		K.CMS:SetupAlternatePowerBar(self)
	end

	-- Warlock Soul Shards
	if (playerClass == "WARLOCK") then
		WarlockPowerFrame:SetParent(self)
		WarlockPowerFrame:ClearAllPoints()
		WarlockPowerFrame:SetPoint("TOP", self, "BOTTOM", 29, -2)
	end

	-- Priest Insanity Bar
	if (playerClass == "PRIEST") then
		InsanityBarFrame:SetParent(self)
		InsanityBarFrame:ClearAllPoints()
		InsanityBarFrame:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 52, -50)
	end

	-- Holy Power Bar (Retribution Only)
	if (playerClass == "PALADIN") then
		PaladinPowerBarFrame:SetParent(self)
		PaladinPowerBarFrame:ClearAllPoints()
		PaladinPowerBarFrame:SetPoint("TOP", self, "BOTTOM", 27, 4)
		PaladinPowerBarFrame:SetFrameStrata("LOW")
	end

	-- Monk Chi / Stagger Bar
	if (playerClass == "MONK") then
		-- Windwalker Chi
		MonkHarmonyBarFrame:SetParent(self)
		MonkHarmonyBarFrame:ClearAllPoints()
		MonkHarmonyBarFrame:SetPoint("TOP", self, "BOTTOM", 31, 18)

		-- Brewmaster Stagger Bar
		MonkStaggerBar:SetParent(self)
		MonkStaggerBar_OnLoad(MonkStaggerBar)
		MonkStaggerBar:ClearAllPoints()
		MonkStaggerBar:SetPoint("TOP", self, "BOTTOM", 31, 0)
		MonkStaggerBar:SetFrameLevel(1)
	end

	-- Deathknight Runebar
	if (playerClass == "DEATHKNIGHT") then
		RuneFrame:SetParent(self)
		if K.WoWBuild >= 24367 then --7.2.5
			RuneFrameMixin.OnLoad(RuneFrame)
		else
			RuneFrame_OnLoad(RuneFrame)
		end
		RuneFrame:ClearAllPoints()
		RuneFrame:SetPoint("TOP", self, "BOTTOM", 33, -1)
	end

	-- Arcane Mage
	if (playerClass == "MAGE") then
		MageArcaneChargesFrame:SetParent(self)
		MageArcaneChargesFrame:ClearAllPoints()
		MageArcaneChargesFrame:SetPoint("TOP", self, "BOTTOM", 30, -0.5)
	end
end

K.CMS = CMS