local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateHealthPrediction()
	local texture = C["Media"].Blank
	local health = self.Health

	local mhpb = health:CreateTexture(nil, "BORDER", nil, 5)
	mhpb:SetWidth(1)
	mhpb:SetTexture(texture)
	mhpb:SetVertexColor(0, 1, .5, .5)

	local ohpb = health:CreateTexture(nil, "BORDER", nil, 5)
	ohpb:SetWidth(1)
	ohpb:SetTexture(texture)
	ohpb:SetVertexColor(0, 1, 0, .5)

	local abb = health:CreateTexture(nil, "BORDER", nil, 5)
	abb:SetWidth(1)
	abb:SetTexture(texture)
	abb:SetVertexColor(.66, 1, 1, .7)

	local abbo = health:CreateTexture(nil, "ARTWORK", nil, 1)
	abbo:SetAllPoints(abb)
	abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	abbo.tileSize = 32

	local oag = health:CreateTexture(nil, "ARTWORK", nil, 1)
	oag:SetWidth(15)
	oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	oag:SetBlendMode("ADD")
	oag:SetAlpha(.7)
	oag:SetPoint("TOPLEFT", health, "TOPRIGHT", -5, 2)
	oag:SetPoint("BOTTOMLEFT", health, "BOTTOMRIGHT", -5, -2)

	local hab = CreateFrame("StatusBar", nil, health)
	hab:SetPoint("TOP")
	hab:SetPoint("BOTTOM")
	hab:SetPoint("RIGHT", health:GetStatusBarTexture())
	hab:SetWidth(health:GetWidth())
	hab:SetReverseFill(true)
	hab:SetStatusBarTexture(texture)
	hab:SetStatusBarColor(0, .5, .8, .5)

	local ohg = health:CreateTexture(nil, "ARTWORK", nil, 1)
	ohg:SetWidth(15)
	ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	ohg:SetBlendMode("ADD")
	ohg:SetPoint("TOPRIGHT", health, "TOPLEFT", 5, 2)
	ohg:SetPoint("BOTTOMRIGHT", health, "BOTTOMLEFT", 5, -2)

	self.HealPredictionAndAbsorb = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = abb,
		absorbBarOverlay = abbo,
		overAbsorbGlow = oag,
		healAbsorbBar = hab,
		overHealAbsorbGlow = ohg,
		maxOverflow = 1,
	}
end