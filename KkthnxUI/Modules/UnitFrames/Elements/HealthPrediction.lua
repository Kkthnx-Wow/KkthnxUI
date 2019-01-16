local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitGetTotalAbsorbs = _G.UnitGetTotalAbsorbs

local CreateFrame = _G.CreateFrame
local UnitGetTotalAbsorbs = _G.UnitGetTotalAbsorbs

function Module:CreateHealthPrediction(Width)
	if not self:IsElementEnabled("HealthPrediction") then
		self:EnableElement("HealthPrediction")
	end

	local Health = self.Health

	Width = Width > 0 and Width or Health:GetWidth()

	local Database = C["HealthPrediction"]
	local Texture = K.GetTexture(Database.Texture)
	local PointL = "LEFT"
	local PointR = "RIGHT"
	local PointB = "BOTTOM"
	local PointT = "TOP"

	local myBar = CreateFrame("StatusBar", nil, Health)
	myBar:SetFrameLevel(11)
	myBar:SetParent(Health)
	myBar:SetStatusBarTexture(Texture)
	myBar:SetStatusBarColor(Database.Personal[1], Database.Personal[2], Database.Personal[3], Database.Personal[4])
	myBar:SetPoint(PointT, Health, PointT)
	myBar:SetPoint(PointB, Health, PointB)
	myBar:SetPoint(PointL, Health:GetStatusBarTexture(), PointR)
	myBar:SetSize(Width, 0)
	myBar:Hide()

	local otherBar = CreateFrame("StatusBar", nil, Health)
	otherBar:SetFrameLevel(11)
	otherBar:SetParent(Health)
	otherBar:SetStatusBarTexture(Texture)
	otherBar:SetStatusBarColor(Database.Others[1], Database.Others[2], Database.Others[3], Database.Others[4])
	otherBar:SetPoint(PointT, Health, PointT)
	otherBar:SetPoint(PointB, Health, PointB)
	otherBar:SetPoint(PointL, myBar:GetStatusBarTexture(), PointR)
	otherBar:SetSize(Width, 0)
	otherBar:Hide()

	local absorbBar = CreateFrame("StatusBar", nil, Health)
	absorbBar:SetFrameLevel(11)
	absorbBar:SetParent(Health)
	absorbBar:SetStatusBarTexture(Texture)
	absorbBar:SetStatusBarColor(Database.Absorbs[1], Database.Absorbs[2], Database.Absorbs[3], Database.Absorbs[4])
	absorbBar:SetPoint(PointT, Health, PointT)
	absorbBar:SetPoint(PointB, Health, PointB)
	absorbBar:SetPoint(PointR, Health, PointR)
	absorbBar:SetSize(Width, 0)
	absorbBar:SetReverseFill(true)
	absorbBar:Hide()

	absorbBar.Overlay = Health:CreateTexture("$parentOverlay", "ARTWORK", "TotalAbsorbBarOverlayTemplate", 1)
	absorbBar.Overlay:SetVertexColor(Database.Absorbs[1], Database.Absorbs[2], Database.Absorbs[3], Database.Absorbs[4])
    absorbBar.Overlay:SetAllPoints(absorbBar:GetStatusBarTexture())

	local healAbsorbBar = CreateFrame("StatusBar", nil, Health)
	healAbsorbBar:SetFrameLevel(11)
	healAbsorbBar:SetParent(Health)
	healAbsorbBar:SetStatusBarTexture(Texture)
	healAbsorbBar:SetStatusBarColor(Database.HealAbsorbs[1], Database.HealAbsorbs[2], Database.HealAbsorbs[3], Database.HealAbsorbs[4])
	healAbsorbBar:SetPoint(PointT, Health, PointT)
	healAbsorbBar:SetPoint(PointB, Health, PointB)
	healAbsorbBar:SetPoint(PointR, Health:GetStatusBarTexture(), PointR)
	healAbsorbBar:SetSize(Width, 0)
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:Hide()

    local overAbsorb = Health:CreateTexture(nil, "ARTWORK")
	overAbsorb:SetTexture(Texture)
	overAbsorb:SetVertexColor(1, 1, 0, 0.25)
	overAbsorb:SetPoint(PointT, Health, PointT)
	overAbsorb:SetPoint(PointB, Health, PointB)
	overAbsorb:SetPoint(PointL, Health, PointR)
	overAbsorb:SetSize(1, 0)
	overAbsorb:Hide()

    local overHealAbsorb = Health:CreateTexture(nil, "ARTWORK")
	overHealAbsorb:SetTexture(Texture)
	overHealAbsorb:SetVertexColor(1, 0, 0, 0.25)
	overHealAbsorb:SetPoint(PointT, Health, PointT)
	overHealAbsorb:SetPoint(PointB, Health, PointB)
	overHealAbsorb:SetPoint(PointR, Health, PointL)
	overHealAbsorb:SetSize(1, 0)
	overHealAbsorb:Hide()

	return {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		overAbsorb = overAbsorb,
        overHealAbsorb = overHealAbsorb,
		maxOverflow = 1,
		PostUpdate = Module.UpdateHealthPrediction,
		parent = self,
	}
end

function Module:UpdateHealthPrediction(unit, _, _, _, _, hasOverAbsorb)
	if hasOverAbsorb then
		self.absorbBar:SetValue(UnitGetTotalAbsorbs(unit))
	end
end