local K, C = unpack(select(2, ...))

local CreateFrame = CreateFrame

function K.CreateHealthPrediction(self)
	local mhpb = CreateFrame("StatusBar", nil, self.Health)
	mhpb:SetParent(self.Health)
	mhpb:SetStatusBarTexture(C["Media"].Texture)
	mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
	mhpb:Hide()

	local ohpb = CreateFrame("StatusBar", nil, self.Health)
	ohpb:SetParent(self.Health)
	ohpb:SetStatusBarTexture(C["Media"].Texture)
	ohpb:SetStatusBarColor(0, 1, 0, 0.25)
	ohpb:Hide()

	local absorbBar = CreateFrame("StatusBar", nil, self.Health)
	absorbBar:SetParent(self.Health)
	absorbBar:SetStatusBarTexture(C["Media"].Texture)
	absorbBar:SetStatusBarColor(1, 1, 0, 0.25)
	absorbBar:Hide()

	local healAbsorbBar = CreateFrame("StatusBar", nil, self.Health)
	healAbsorbBar:SetParent(self.Health)
	healAbsorbBar:SetStatusBarTexture(C["Media"].Texture)
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