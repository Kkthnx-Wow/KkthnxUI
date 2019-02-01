local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
  return
end

local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreatePowerPrediction()
  local power = self.Power
  local addPower = self.AdditionalPower

  local width = power:GetWidth()
  local pointR = "RIGHT"
  local texture = K.GetTexture(C["Unitframe"].Texture)

  local mainBar = CreateFrame("StatusBar", nil, power)
  mainBar:SetReverseFill(true)
  mainBar:SetPoint("TOP", power, "TOP")
  mainBar:SetPoint("BOTTOM", power, "BOTTOM")
  mainBar:SetPoint(pointR, power:GetStatusBarTexture(), pointR)
  mainBar:SetStatusBarTexture(texture)
  mainBar:SetStatusBarColor(1, 1, 1, 0.6)
  mainBar:SetWidth(width)

  local PowerPrediction = {
    mainBar = mainBar,
    parent = self
  }

  if addPower then
    local altBar = CreateFrame("StatusBar", nil, addPower)
    altBar:SetReverseFill(true)
    altBar:SetPoint("TOP", addPower, "TOP")
    altBar:SetPoint("BOTTOM", addPower, "BOTTOM")
    altBar:SetPoint(pointR, addPower:GetStatusBarTexture(), pointR)
    altBar:SetStatusBarTexture(texture)
    altBar:SetStatusBarColor(1, 1, 1, 0.6)
    altBar:SetWidth(width)

    PowerPrediction.altBar = altBar
  end

  return PowerPrediction
end