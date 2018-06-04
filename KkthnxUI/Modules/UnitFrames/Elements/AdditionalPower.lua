local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

function Module:CreateAdditionalPower()
	local UnitframeFont = K.GetFont(C["Unitframe"].Font)
	local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

	local addPower = CreateFrame("StatusBar", nil, self)
	addPower:SetPoint("LEFT", 4, 0)
	addPower:SetPoint("RIGHT", -4, 0)
	addPower:SetPoint("BOTTOM", self, "TOP", 0, 3)
	addPower:SetHeight(12)
	addPower:SetStatusBarTexture(UnitframeTexture, "BORDER")
	addPower.colorPower = true
	addPower:SetTemplate("Transparent")
	addPower.Smooth = C["Unitframe"].Smooth
	addPower.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10

	addPower.Value = addPower:CreateFontString(nil, "OVERLAY")
	addPower.Value:SetFont(C.Media.Font, 10)
	addPower.Value:SetShadowOffset(1, -1)
	addPower.Value:SetPoint("CENTER", addPower, 0, 0)

	self:Tag(addPower.Value, "[KkthnxUI:AltPowerCurrent]")

	self.AdditionalPower = addPower
end