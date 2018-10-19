local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
  return
end

local Module = K:GetModule("Unitframes")

function Module:CreatePowerPrediction()
  local power = self.Power
  local width = power:GetWidth()
  local point = "RIGHT"
  local texture = K.GetTexture(C["Unitframe"].Texture)

  local PowerPrediction = {}

  local r, g, b = power:GetStatusBarColor()

  local mainBar = CreateFrame("StatusBar", nil, power)
  mainBar:SetReverseFill(true)
  mainBar:SetPoint("TOP", power, "TOP")
  mainBar:SetPoint("BOTTOM", power, "BOTTOM")
  mainBar:SetPoint(point, power:GetStatusBarTexture(), point)
  mainBar:SetStatusBarTexture(texture)
  mainBar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)
  mainBar:SetSize(width, 0)
  mainBar:Hide()

  r, g, b = self.AdditionalPower:GetStatusBarColor()

  local altBar = CreateFrame("StatusBar", nil, self.AdditionalPower)
  altBar:SetReverseFill(true)
  altBar:SetPoint("TOP", self.AdditionalPower, "TOP")
  altBar:SetPoint("BOTTOM", self.AdditionalPower, "BOTTOM")
  altBar:SetPoint(point, self.AdditionalPower:GetStatusBarTexture(), point)
  altBar:SetStatusBarTexture(texture)
  altBar:SetStatusBarColor(r * 1.25, g * 1.25, b * 1.25)
  altBar:SetSize(width, 0)
  altBar:Hide()

  PowerPrediction.mainBar = mainBar
  PowerPrediction.altBar = altBar
  PowerPrediction.parent = self

  return PowerPrediction
end