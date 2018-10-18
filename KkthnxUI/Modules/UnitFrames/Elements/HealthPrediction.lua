local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateHealthPrediction()
	local Texture = C["Media"].Blank
	local Health = self.Health
	local WidthH = Health:GetWidth()
	local PointT = "TOP"
	local PointB = "BOTTOM"
	local PointL = "LEFT"
	local PointR = "RIGHT"


	local myBar = CreateFrame("StatusBar", nil, Health)
	myBar:SetParent(Health)
	myBar:SetStatusBarTexture(Texture)
	myBar:SetStatusBarColor(0, 0.827, 0.765, 0.8)
	myBar:SetPoint(PointT, Health, PointT)
	myBar:SetPoint(PointB, Health, PointB)
	myBar:SetPoint(PointL, Health:GetStatusBarTexture(), PointR)
	myBar:SetWidth(WidthH)
	myBar:Hide()

	local otherBar = CreateFrame("StatusBar", nil, Health)
	otherBar:SetParent(Health)
	otherBar:SetStatusBarTexture(Texture)
	otherBar:SetStatusBarColor(0.0, 0.631, 0.557, 0.8)
	otherBar:SetPoint(PointT, Health, PointT)
	otherBar:SetPoint(PointB, Health, PointB)
	otherBar:SetPoint(PointL, myBar:GetStatusBarTexture(), PointR)
	otherBar:SetWidth(WidthH)
	otherBar:Hide()

	local absorbBar = CreateFrame("StatusBar", nil, Health)
	absorbBar:SetParent(Health)
	absorbBar:SetStatusBarTexture(Texture)
	absorbBar:SetStatusBarColor(0.85, 0.85, 0.9, 0.8)
	absorbBar:SetPoint(PointT, Health, PointT)
	absorbBar:SetPoint(PointB, Health, PointB)
	absorbBar:SetPoint(PointR, Health, PointR)
	absorbBar:SetWidth(WidthH)
	absorbBar:Hide()

	if absorbBar then
		absorbBar.Overlay = absorbBar:CreateTexture(nil, "ARTWORK", "TotalAbsorbBarOverlayTemplate", 1)
		absorbBar.Overlay:SetAllPoints(absorbBar:GetStatusBarTexture())
	end

	local healAbsorbBar = CreateFrame("StatusBar", nil, Health)
	healAbsorbBar:SetParent(Health)
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:SetStatusBarTexture(Texture)
	healAbsorbBar:SetStatusBarColor(0.9, 0.1, 0.3, 0.8)
	healAbsorbBar:SetPoint(PointT, Health, PointT)
	healAbsorbBar:SetPoint(PointB, Health, PointB)
	healAbsorbBar:SetPoint(PointR, Health:GetStatusBarTexture(), PointR)
	healAbsorbBar:SetWidth(WidthH)
	healAbsorbBar:Hide()

	local overAbsorb = Health:CreateTexture(nil, "ARTWORK")
	if overAbsorb then
		overAbsorb:SetPoint(PointT, Health, PointT)
		overAbsorb:SetPoint(PointB, Health, PointB)
		overAbsorb:SetPoint(PointL, Health, PointR, -4, 0)
		overAbsorb:SetWidth(8)
	end
	overAbsorb:Hide()

	local overHealAbsorb = Health:CreateTexture(nil, "ARTWORK")
	if overHealAbsorb then
		overHealAbsorb:SetPoint(PointT, Health, PointT)
		overHealAbsorb:SetPoint(PointB, Health, PointB)
		overHealAbsorb:SetPoint(PointR, Health, PointL, -4, 0)
		overHealAbsorb:SetSize(8, Health:GetHeight())
	end
	overHealAbsorb:Hide()

	return {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		maxOverflow = 1,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		parent = self,
		PostUpdate = Module.UpdateHealPrediction,
	}
end

function Module:UpdateHealPrediction(unit, _, _, _, _, hasOverAbsorb)
	if hasOverAbsorb then
		self.absorbBar:SetValue(_G.UnitGetTotalAbsorbs(unit))
	end
end
