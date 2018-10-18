local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
  return
end

local Module = K:GetModule("Unitframes")

function Module:CreatePowerPrediction()
  local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

  local PowerPrediction = {}

  local mainBar = CreateFrame("StatusBar", nil, self.Power)
  mainBar:SetReverseFill(true)
  mainBar:SetPoint("TOP")
  mainBar:SetPoint("BOTTOM")
  mainBar:SetPoint("RIGHT", self.Power:GetStatusBarTexture(), "RIGHT")
  mainBar:SetWidth(200)
  mainBar:SetStatusBarTexture(UnitframeTexture)
  mainBar:SetStatusBarColor(0, 1, 0.5, 0.25)
  mainBar:Hide()

  PowerPrediction.mainBar = mainBar

  local altBar = CreateFrame("StatusBar", nil, self.AdditionalPower)
  altBar:SetReverseFill(true)
  altBar:SetPoint("TOP")
  altBar:SetPoint("BOTTOM")
  altBar:SetPoint("RIGHT", self.AdditionalPower:GetStatusBarTexture(), "RIGHT")
  altBar:SetWidth(200)
  altBar:SetStatusBarTexture(UnitframeTexture)
  altBar:SetStatusBarColor(0, 1, 0, 0.25)
  altBar:Hide()

  PowerPrediction.altBar = altBar

  PowerPrediction.parent = self

  return PowerPrediction
end