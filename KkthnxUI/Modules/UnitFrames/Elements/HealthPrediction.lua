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

	if self:IsElementEnabled("HealthPrediction") then
		self.HealthPrediction:ForceUpdate()
	end

	Width = Width > 0 and Width or self:GetWidth()

	local Health = self.Health
	local Database = C["HealthPrediction"]
	local Texture = K.GetTexture(Database.Texture)
	local PointL = "LEFT"
	local PointR = "RIGHT"
	local PointB = "BOTTOM"
	local PointT = "TOP"

	local myBar = CreateFrame("StatusBar", nil, Health)
	myBar:SetFrameLevel(11)
	myBar:SetStatusBarTexture(Texture)
	myBar:SetStatusBarColor(Database.Personal[1], Database.Personal[2], Database.Personal[3], Database.Personal[4])
	myBar:ClearAllPoints()
	myBar:SetPoint(PointT, Health, PointT)
	myBar:SetPoint(PointB, Health, PointB)
	myBar:SetPoint(PointL, Health:GetStatusBarTexture(), PointR)
	myBar:SetWidth(Width)

	local otherBar = CreateFrame("StatusBar", nil, Health)
	otherBar:SetFrameLevel(11)
	otherBar:SetStatusBarTexture(Texture)
	otherBar:SetStatusBarColor(Database.Others[1], Database.Others[2], Database.Others[3], Database.Others[4])
	otherBar:ClearAllPoints()
	otherBar:SetPoint(PointT, Health, PointT)
	otherBar:SetPoint(PointB, Health, PointB)
	otherBar:SetPoint(PointL, myBar:GetStatusBarTexture(), PointR)
	otherBar:SetWidth(Width)

	local absorbBar = CreateFrame("StatusBar", nil, Health)
	absorbBar:SetFrameLevel(11)
	absorbBar:SetStatusBarTexture(Texture)
	absorbBar:SetStatusBarColor(Database.Absorbs[1], Database.Absorbs[2], Database.Absorbs[3], Database.Absorbs[4])
	absorbBar:ClearAllPoints()
	absorbBar:SetPoint(PointT, Health, PointT)
	absorbBar:SetPoint(PointB, Health, PointB)
	absorbBar:SetPoint(PointR, otherBar:GetStatusBarTexture(), PointR)
	absorbBar:SetWidth(Width)
	absorbBar:SetReverseFill(true)

   	absorbBar.Overlay = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
	absorbBar.Overlay:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Absorb", "REPEAT", "REPEAT")
	absorbBar.Overlay:SetVertexColor(Database.Absorbs[1], Database.Absorbs[2], Database.Absorbs[3], Database.Absorbs[4])
	absorbBar.Overlay:SetHorizTile(true)
	absorbBar.Overlay:SetVertTile(true)
	absorbBar.Overlay:SetAllPoints(absorbBar:GetStatusBarTexture())

	local healAbsorbBar = CreateFrame("StatusBar", nil, Health)
	healAbsorbBar:SetFrameLevel(11)
	healAbsorbBar:SetStatusBarTexture(Texture)
	healAbsorbBar:SetStatusBarColor(Database.HealAbsorbs[1], Database.HealAbsorbs[2], Database.HealAbsorbs[3], Database.HealAbsorbs[4])
	healAbsorbBar:ClearAllPoints()
	healAbsorbBar:SetPoint(PointT, Health, PointT)
	healAbsorbBar:SetPoint(PointB, Health, PointB)
	healAbsorbBar:SetPoint(PointR, Health:GetStatusBarTexture(), PointR)
	healAbsorbBar:SetWidth(Width)
	healAbsorbBar:SetReverseFill(true)

    local overAbsorb = Health:CreateTexture(nil, "ARTWORK")
	overAbsorb:SetTexture(Texture)
	overAbsorb:SetVertexColor(1, 1, 0, 0.25)
	overAbsorb:ClearAllPoints()
	overAbsorb:SetPoint(PointT, Health, PointT)
	overAbsorb:SetPoint(PointB, Health, PointB)
	overAbsorb:SetPoint(PointL, Health, PointR)
	overAbsorb:SetWidth(1)

    local overHealAbsorb = Health:CreateTexture(nil, "ARTWORK")
	overHealAbsorb:SetTexture(Texture)
	overHealAbsorb:SetVertexColor(1, 0, 0, 0.25)
	overHealAbsorb:ClearAllPoints()
	overHealAbsorb:SetPoint(PointT, Health, PointT)
	overHealAbsorb:SetPoint(PointB, Health, PointB)
	overHealAbsorb:SetPoint(PointR, Health, PointL)
	overHealAbsorb:SetWidth(1)

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