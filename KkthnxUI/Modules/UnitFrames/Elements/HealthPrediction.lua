local K, C = unpack(select(2, ...))

local _G = _G

local CreateFrame = _G.CreateFrame

local PredictionFont = K.GetFont(C["Unitframe"].Font)
local PredictionTexture = K.GetTexture(C["Unitframe"].Texture)

function K.CreateHealthPrediction(self)
	local mhpb = CreateFrame("StatusBar", nil, self.Health)
	mhpb:SetParent(self.Health)
	mhpb:SetStatusBarTexture(PredictionTexture)
	mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
	mhpb:Hide()

	local ohpb = CreateFrame("StatusBar", nil, self.Health)
	ohpb:SetParent(self.Health)
	ohpb:SetStatusBarTexture(PredictionTexture)
	ohpb:SetStatusBarColor(0, 1, 0, 0.25)
	ohpb:Hide()

	local absorbBar = CreateFrame("StatusBar", nil, self.Health)
	absorbBar:SetParent(self.Health)
	absorbBar:SetStatusBarTexture(PredictionTexture)
	absorbBar:SetStatusBarColor(1, 1, 0, 0.25)
	absorbBar:Hide()

	local healAbsorbBar = CreateFrame("StatusBar", nil, self.Health)
	healAbsorbBar:SetParent(self.Health)
	healAbsorbBar:SetStatusBarTexture(PredictionTexture)
	healAbsorbBar:SetStatusBarColor(1, 0, 0, 0.25)
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:Hide()

	local HealthPrediction = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = absorbBar,
		healAbsorbBar = healAbsorbBar,
		maxOverflow = 1,
		PostUpdate = K.UpdateHealComm
	}
	HealthPrediction.parent = self

	return HealthPrediction
end

function K.UpdateFillBar(self, previousTexture, bar, amount, inverted)
	if (amount == 0) then
		bar:Hide()
		return previousTexture
	end

	bar:ClearAllPoints()
	if (inverted) then
		bar:SetPoint("TOPRIGHT", previousTexture, "TOPRIGHT")
		bar:SetPoint("BOTTOMRIGHT", previousTexture, "BOTTOMRIGHT")
	else
		bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT")
		bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT")
	end

	local totalWidth, totalHeight = self.Health:GetSize()
	bar:SetWidth(totalWidth)

	return bar:GetStatusBarTexture()
end

function K.UpdateHealComm(self, unit, myIncomingHeal, allIncomingHeal, totalAbsorb, healAbsorb)
	local frame = self.parent
	local previousTexture = frame.Health:GetStatusBarTexture()

	K.UpdateFillBar(frame, previousTexture, self.healAbsorbBar, healAbsorb, true)
	previousTexture = K.UpdateFillBar(frame, previousTexture, self.myBar, myIncomingHeal)
	previousTexture = K.UpdateFillBar(frame, previousTexture, self.otherBar, allIncomingHeal)
	previousTexture = K.UpdateFillBar(frame, previousTexture, self.absorbBar, totalAbsorb)
end