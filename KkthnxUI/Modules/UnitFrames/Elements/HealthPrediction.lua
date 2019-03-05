local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateHealthPrediction(CustomWidth)
	if not self:IsElementEnabled("HealthPrediction") then
		self:EnableElement("HealthPrediction")
	end

	local Health = self.Health

	local Width = Health:GetWidth()
	Width = Width > 0 and Width or CustomWidth

	local Database = C["HealthPrediction"]
	local Texture = K.GetTexture(Database.Texture) or C["Media"].Texture
	local PointL = "LEFT"
	local PointR = "RIGHT"
	local PointB = "BOTTOM"
	local PointT = "TOP"

	local myBar = CreateFrame("StatusBar", nil, Health)
	myBar:SetFrameLevel(11)
	myBar:SetParent(Health)
	myBar:SetStatusBarTexture(Texture)
	myBar:SetStatusBarColor(Database.Personal[1], Database.Personal[2], Database.Personal[3], Database.Personal[4])
	myBar:ClearAllPoints()
	myBar:SetPoint(PointT, Health, PointT)
	myBar:SetPoint(PointB, Health, PointB)
	myBar:SetPoint(PointL, Health:GetStatusBarTexture(), PointR)
	myBar:SetSize(Width, 0)
	myBar.Smooth = true
	myBar.SmoothSpeed = 3 * 10
	myBar:Hide()

	local otherBar = CreateFrame("StatusBar", nil, Health)
	otherBar:SetFrameLevel(11)
	otherBar:SetParent(Health)
	otherBar:SetStatusBarTexture(Texture)
	otherBar:SetStatusBarColor(Database.Others[1], Database.Others[2], Database.Others[3], Database.Others[4])
	otherBar:ClearAllPoints()
	otherBar:SetPoint(PointT, Health, PointT)
	otherBar:SetPoint(PointB, Health, PointB)
	otherBar:SetPoint(PointL, myBar:GetStatusBarTexture(), PointR)
	otherBar:SetSize(Width, 0)
	otherBar.Smooth = true
	otherBar.SmoothSpeed = 3 * 10
	otherBar:Hide()

	local absorbBar = CreateFrame("StatusBar", nil, Health)
	absorbBar:SetFrameLevel(11)
	absorbBar:SetParent(Health)
	absorbBar:SetStatusBarTexture(Texture)
	absorbBar:SetStatusBarColor(Database.Absorbs[1], Database.Absorbs[2], Database.Absorbs[3], Database.Absorbs[4])
	absorbBar:ClearAllPoints()
	absorbBar:SetPoint(PointT, Health, PointT)
	absorbBar:SetPoint(PointB, Health, PointB)
	absorbBar:SetPoint(PointR, Health, PointR)
	absorbBar:SetSize(Width, 0)
	absorbBar:SetReverseFill(true)
	absorbBar.Smooth = true
	absorbBar.SmoothSpeed = 3 * 10
	absorbBar:Hide()

	absorbBar.Overlay = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
	absorbBar.Overlay:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Absorb", "REPEAT", "REPEAT")
	absorbBar.Overlay:SetVertexColor(Database.Absorbs[1], Database.Absorbs[2], Database.Absorbs[3], Database.Absorbs[4])
	absorbBar.Overlay:SetHorizTile(true)
	absorbBar.Overlay:SetVertTile(true)
	absorbBar.Overlay:SetAllPoints(absorbBar:GetStatusBarTexture())

	local healAbsorbBar = CreateFrame("StatusBar", nil, Health)
	healAbsorbBar:SetFrameLevel(11)
	healAbsorbBar:SetParent(Health)
	healAbsorbBar:SetStatusBarTexture(Texture)
	healAbsorbBar:SetStatusBarColor(Database.HealAbsorbs[1], Database.HealAbsorbs[2], Database.HealAbsorbs[3], Database.HealAbsorbs[4])
	healAbsorbBar:ClearAllPoints()
	healAbsorbBar:SetPoint(PointT, Health, PointT)
	healAbsorbBar:SetPoint(PointB, Health, PointB)
	healAbsorbBar:SetPoint(PointR, Health:GetStatusBarTexture(), PointR)
	healAbsorbBar:SetSize(Width, 0)
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar.Smooth = true
	healAbsorbBar.SmoothSpeed = 3 * 10
	healAbsorbBar:Hide()

	return {
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		maxOverflow = 1,
		parent = self,
	}
end