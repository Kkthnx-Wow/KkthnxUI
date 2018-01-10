local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

function K.AddPowerPrediction(self)
  local PowerPrediction = CreateFrame("StatusBar", nil, self.Power)
  PowerPrediction:SetPoint("RIGHT", self.Power:GetStatusBarTexture())
  PowerPrediction:SetPoint("BOTTOM")
  PowerPrediction:SetPoint("TOP")
  PowerPrediction:SetWidth(self.Power:GetWidth())
  PowerPrediction:SetHeight(self.Power:GetHeight())
  PowerPrediction:SetStatusBarTexture(UnitframeTexture, "BORDER")
  PowerPrediction:GetStatusBarTexture():SetBlendMode("ADD")
  PowerPrediction:SetStatusBarColor(0, 0, 1, 0.5)
  PowerPrediction:SetReverseFill(true)
  PowerPrediction.Smooth = C["Unitframe"].Smooth
  PowerPrediction.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10

  self.PowerPrediction = {
    mainBar = PowerPrediction
  }
end