local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitGetTotalAbsorbs = _G.UnitGetTotalAbsorbs

function Module:CreateHealthPrediction()
	local Health = self.Health
	local Width = Health:GetWidth()

	Width = Width > 0 and Width or Health.WIDTH

	local Database = C["HealthPrediction"]
	local Texture = K.GetTexture(Database.Texture)
	local PointL = "LEFT"
	local PointR = "RIGHT"
	local PointB = "BOTTOM"
	local PointT = "TOP"
	local ShowAbsorbAmount = Database.ShowAbsorbAmount

	local myBar = CreateFrame("StatusBar", nil, Health)
	myBar:SetParent(Health)
	myBar:SetStatusBarTexture(Texture)
	myBar:SetStatusBarColor(Database.Personal[1], Database.Personal[2], Database.Personal[3], Database.Personal[4])
	myBar:SetPoint(PointT, Health, PointT)
	myBar:SetPoint(PointB, Health, PointB)
	myBar:SetPoint(PointL, Health:GetStatusBarTexture(), PointR)
	myBar:SetSize(Width, 0)
	myBar:Hide()

	local otherBar = CreateFrame("StatusBar", nil, Health)
	otherBar:SetParent(Health)
	otherBar:SetStatusBarTexture(Texture)
	otherBar:SetStatusBarColor(Database.Others[1], Database.Others[2], Database.Others[3], Database.Others[4])
	otherBar:SetPoint(PointT, Health, PointT)
	otherBar:SetPoint(PointB, Health, PointB)
	otherBar:SetPoint(PointL, myBar:GetStatusBarTexture(), PointR)
	otherBar:SetSize(Width, 0)
	otherBar:Hide()

	local absorbBar = CreateFrame("StatusBar", nil, Health)
	absorbBar:SetParent(Health)
	absorbBar:SetStatusBarTexture(Texture)
	absorbBar:SetStatusBarColor(Database.Absorbs[1], Database.Absorbs[2], Database.Absorbs[3], Database.Absorbs[4])
	absorbBar:SetPoint(PointT, Health, PointT)
	absorbBar:SetPoint(PointB, Health, PointB)
	if ShowAbsorbAmount then
		absorbBar:SetPoint(PointR, Health, PointR)
	else
		absorbBar:SetPoint(PointL, otherBar:GetStatusBarTexture(), PointR)
	end
	absorbBar:SetSize(Width, 0)
	absorbBar:SetReverseFill(ShowAbsorbAmount)
	absorbBar:Hide()

	absorbBar.Overlay = absorbBar:CreateTexture(nil, "ARTWORK", "TotalAbsorbBarOverlayTemplate", 1)
	absorbBar.Overlay:SetAllPoints(absorbBar:GetStatusBarTexture())

	local healAbsorbBar = CreateFrame("StatusBar", nil, Health)
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
	overAbsorb:SetVertexColor(Database.OverAbsorbs[1], Database.OverAbsorbs[2], Database.OverAbsorbs[3], Database.OverAbsorbs[4])
	overAbsorb:SetPoint(PointT, Health, PointT)
	overAbsorb:SetPoint(PointB, Health, PointB)
	overAbsorb:SetPoint(PointL, Health, PointR)
	overAbsorb:SetSize(1, 0)
	overAbsorb:Hide()

	local overHealAbsorb = Health:CreateTexture(nil, "ARTWORK")
	overHealAbsorb:SetTexture(Texture)
	overHealAbsorb:SetVertexColor(Database.OverHealAbsorbs[1], Database.OverHealAbsorbs[2], Database.OverHealAbsorbs[3], Database.OverHealAbsorbs[4])
	overHealAbsorb:SetPoint(PointT, Health, PointT)
	overHealAbsorb:SetPoint(PointB, Health, PointB)
	overHealAbsorb:SetPoint(PointR, Health, PointL)
	overHealAbsorb:SetSize(1, 0)
	overHealAbsorb:Hide()

	if not ShowAbsorbAmount then
		overAbsorb = overAbsorb_
		overHealAbsorb = overHealAbsorb_
	else
		if overAbsorb then
			overAbsorb:Hide()
			overAbsorb = nil
			overHealAbsorb:Hide()
			overHealAbsorb = nil
		end
	end

	return {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		maxOverflow = 1 + (Database.MaxOverflow or 0),
		overAbsorb_ = overAbsorb,
		overHealAbsorb_ = overHealAbsorb,
		PostUpdate = Module.UpdateHealthPrediction,
		parent = self,
	}
end

function Module:UpdateHealthPrediction(unit, _, _, _, _, hasOverAbsorb)
	if hasOverAbsorb then
		self.absorbBar:SetValue(UnitGetTotalAbsorbs(unit))
	end
end