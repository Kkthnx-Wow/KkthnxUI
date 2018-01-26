local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local UnitframeFont = K.GetFont(C["Unitframe"].Font)
local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

function K.CreateAdditionalPower(self)
	-- Additional mana
	local addPower = CreateFrame("StatusBar", nil, self)
	addPower:SetPoint("BOTTOM", self.Health, "TOP", 0, 6)
	addPower:SetStatusBarTexture(UnitframeTexture, "BORDER")
	addPower:SetSize(self.Health:GetWidth(), 10)
	addPower.colorPower = true
	addPower:SetTemplate("Transparent")
	addPower.Smooth = C["Unitframe"].Smooth
	addPower.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10

	addPower.Value = addPower:CreateFontString(nil, "OVERLAY")
	addPower.Value:SetFont(C.Media.Font, 9)
	addPower.Value:SetShadowOffset(1, -1)
	addPower.Value:SetPoint("CENTER", addPower, 0, 0)

	self:Tag(addPower.Value, "[KkthnxUI:AltPowerCurrent]")

	self.AdditionalPower = addPower
end