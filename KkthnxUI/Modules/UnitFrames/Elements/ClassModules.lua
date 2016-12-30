local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

-- Lua API
local _G = _G
local unpack = unpack
local select = select

-- Wow API
local GetShapeshiftFormID = GetShapeshiftFormID
local GetSpecialization = GetSpecialization
local hooksecurefunc = hooksecurefunc

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: TotemFrame, oUF_KkthnxPet, oUF_KkthnxPlayer, CAT_FORM, SPEC_SHAMAN_RESTORATION
-- GLOBALS: MAX_TOTEMS, UIFrameHider, TotemFrame_AdjustPetFrame, PlayerFrame_AdjustAttachments
-- GLOBALS: RuneFrame, RuneFrame_OnLoad, MageArcaneChargesFrame, MonkStaggerBar, MonkStaggerBar_OnLoad
-- GLOBALS: MonkHarmonyBarFrame, PaladinPowerBarFrame, PaladinPowerBarFrameBG, InsanityBarFrame
-- GLOBALS: WarlockPowerFrame

local ClassModule = CreateFrame("Frame")

local function UpdateTotemPosition()
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

function ClassModule:Totems(self)
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

	hooksecurefunc("TotemFrame_Update", UpdateTotemPosition)
	UpdateTotemPosition()
end

function ClassModule:AlternatePowerBar(self)
	self.AdditionalPower = K.CreateOutsideBar(self, false, 0, 0, 1)
	self.DruidMana = self.AdditionalPower
	self.AdditionalPower.colorPower = true

	self.AdditionalPower.Value = K.SetFontString(self.AdditionalPower, C.Media.Font, 13, nil, "CENTER")
	self.AdditionalPower.Value:SetPoint("CENTER", self.AdditionalPower, 0, 0.5)
	self.AdditionalPower.Value:Hide()
	self:Tag(self.AdditionalPower.Value, "[KkthnxUI:DruidMana]")
end

function ClassModule:RuneFrame(self)
	if C.UnitframePlugins.RuneFrame then
		RuneFrame:SetParent(self)
		RuneFrame_OnLoad(RuneFrame)
		RuneFrame:ClearAllPoints()
		RuneFrame:SetPoint("TOP", self, "BOTTOM", 33, -1)
		RuneFrame:SetFrameStrata("LOW")
		for i = 1, 6 do
			local b = _G["RuneButtonIndividual"..i].Border
			if C.Blizzard.ColorTextures == true then
				b:GetRegions():SetVertexColor(unpack(C.Blizzard.TexturesColor))
			end
		end
	end
end

function ClassModule:ArcaneCharges(self)
	if C.UnitframePlugins.ArcaneCharges then
		MageArcaneChargesFrame:SetParent(self)
		MageArcaneChargesFrame:ClearAllPoints()
		MageArcaneChargesFrame:SetPoint("TOP", self, "BOTTOM", 30, -0.5)

		return MageArcaneChargesFrame
	end
end

function ClassModule:StaggerBar(self)
	if C.UnitframePlugins.StaggerBar then
		-- Stagger Bar for tank monk
		MonkStaggerBar:SetParent(self)
		MonkStaggerBar_OnLoad(MonkStaggerBar)
		MonkStaggerBar:ClearAllPoints()
		MonkStaggerBar:SetPoint("TOP", self, "BOTTOM", 31, -2)
		if C.Blizzard.ColorTextures == true then
			MonkStaggerBar.MonkBorder:SetVertexColor(unpack(C.Blizzard.TexturesColor))
		end
		MonkStaggerBar:SetFrameLevel(1)
	end

	if C.UnitframePlugins.HarmonyBar then
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

function ClassModule:HolyPowerBar(self)
	if C.UnitframePlugins.HolyPowerBar then
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

function ClassModule:InsanityBar(self)
	if C.UnitframePlugins.InsanityBar then
		InsanityBarFrame:SetParent(self)
		InsanityBarFrame:ClearAllPoints()
		InsanityBarFrame:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 52, -50)
		return InsanityBarFrame
	end
end

function ClassModule:ShardsBar(self)
	if C.UnitframePlugins.ShardsBar then
		WarlockPowerFrame:SetParent(self)
		WarlockPowerFrame:ClearAllPoints()
		WarlockPowerFrame:SetPoint("TOP", self, "BOTTOM", 29, -2)
		WarlockPowerFrame:SetFrameStrata("LOW")
		for i = 1, 5 do
			local shard = _G["WarlockPowerFrameShard"..i]
			if C.Blizzard.ColorTextures == true then
				select(5, shard:GetRegions()):SetVertexColor(unpack(C.Blizzard.TexturesColor))
			end
		end

		return WarlockPowerFrame
	end
end

K.ClassModule = ClassModule