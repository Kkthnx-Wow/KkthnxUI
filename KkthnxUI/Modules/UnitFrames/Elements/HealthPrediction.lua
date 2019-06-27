local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

local setWidth = {
	arena = 140,
	nameplate = C["Nameplates"].Width,
	party = 114,
	player = 140,
	raid = C["Raid"].Width,
	target = 140,
}

function Module:CreateHealthPrediction(unit)
	local health = self.Health
	local level = 11
	local width = setWidth[unit] or self.Health:GetWidth()
	local texture = C["Media"].Blank

	local healAbsorbBar = CreateFrame("StatusBar", nil, health)
	healAbsorbBar:SetFrameLevel(level + 1)
	healAbsorbBar:SetPoint("TOPRIGHT", health:GetStatusBarTexture())
	healAbsorbBar:SetPoint("BOTTOMRIGHT", health:GetStatusBarTexture())
	healAbsorbBar:SetWidth(width)
	healAbsorbBar:SetReverseFill(true)
	healAbsorbBar:SetStatusBarTexture(texture)
	healAbsorbBar:SetStatusBarColor(1, 0, 0, 0.25)
	K:SetSmoothing(healAbsorbBar, true)

	local overHealAbsorb = health:CreateTexture(nil, "ARTWORK")
	overHealAbsorb:SetWidth(5)
	overHealAbsorb:SetPoint("TOPRIGHT", health, "TOPLEFT")
	overHealAbsorb:SetPoint("BOTTOMRIGHT", health, "BOTTOMLEFT")

	local myBar = CreateFrame("StatusBar", nil, health)
	myBar:SetFrameLevel(level)
	myBar:SetPoint("TOPLEFT", health:GetStatusBarTexture(), "TOPRIGHT")
	myBar:SetPoint("BOTTOMLEFT", health:GetStatusBarTexture(), "BOTTOMRIGHT")
	myBar:SetWidth(width)
	myBar:SetStatusBarTexture(texture)
	myBar:SetStatusBarColor(0, 1, 0.5, 0.25)
	K:SetSmoothing(myBar, true)

	local otherBar = CreateFrame("StatusBar", nil, health)
	otherBar:SetFrameLevel(level)
	otherBar:SetPoint("TOPLEFT", myBar:GetStatusBarTexture(), "TOPRIGHT")
	otherBar:SetPoint("BOTTOMLEFT", myBar:GetStatusBarTexture(), "BOTTOMRIGHT")
	otherBar:SetWidth(width)
	otherBar:SetStatusBarTexture(texture)
	otherBar:SetStatusBarColor(0, 1, 0, 0.25)
	K:SetSmoothing(otherBar, true)

	local absorbBar = CreateFrame("StatusBar", nil, health)
	absorbBar:SetFrameLevel(level + 1)
	absorbBar:SetPoint("TOPLEFT", otherBar:GetStatusBarTexture(), "TOPRIGHT")
	absorbBar:SetPoint("BOTTOMLEFT", otherBar:GetStatusBarTexture(), "BOTTOMRIGHT")
	absorbBar:SetWidth(width)
	absorbBar:SetStatusBarTexture(texture)
	absorbBar:SetStatusBarColor(1, 1, 0, 0.25)
	K:SetSmoothing(absorbBar, true)

	local overlay = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
	overlay:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Absorb", "REPEAT", "REPEAT")
	overlay:SetHorizTile(true)
	overlay:SetVertTile(true)
	overlay:SetAllPoints(absorbBar:GetStatusBarTexture())
	overlay:SetAlpha(0.25)

	local overAbsorb = health:CreateTexture(nil, "ARTWORK")
	overAbsorb:SetWidth(5)
	overAbsorb:SetPoint("TOPLEFT", health, "TOPRIGHT", -3, 0)
	overAbsorb:SetPoint("BOTTOMLEFT", health, "BOTTOMRIGHT", -3, 0)

	self.HealthPrediction = {
		healAbsorbBar = healAbsorbBar,
		myBar = myBar,
		otherBar = otherBar,
		absorbBar = absorbBar,
		overAbsorb = overAbsorb,
		overHealAbsorb = overHealAbsorb,
		maxOverflow = 1,
	}
end