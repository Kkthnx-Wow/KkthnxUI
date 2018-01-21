local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local ClassModuleFont = K.GetFont(C["Unitframe"].Font)
local ClassModuleTexture = K.GetTexture(C["Unitframe"].Texture)

local function OnEnter(self)
	if (not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	self:UpdateTooltip()
end

local function UpdateTooltip(self)
	local value = self:GetValue()
	local min, max = self:GetMinMaxValues()
	GameTooltip:SetText(self.powerName, 1, 1, 1)
	GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, true)
	GameTooltip:AddLine(format("\n%d (%d%%)", value, (value - min) / (max - min) * 100), 1, 1, 1)
	GameTooltip:Show()
end

function K.CreateAlternativePower(self)
	self.AlternativePower = CreateFrame("StatusBar", nil, self)
	self.AlternativePower:SetPoint("TOPLEFT", _G["oUF_Player"].Power, "BOTTOMLEFT", 0, -1)
	self.AlternativePower:SetPoint("TOPRIGHT", _G["oUF_Player"].Power, "BOTTOMRIGHT", 0, -1)
	self.AlternativePower:SetHeight(3)
	self.AlternativePower:SetStatusBarTexture(ClassModuleTexture)
	self.AlternativePower:SetStatusBarColor(0, 0.5, 1)
	self.AlternativePower.Smooth = C["Unitframe"].Smooth
	self.AlternativePower.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.AlternativePower:EnableMouse(true)
	self.AlternativePower.UpdateTooltip = UpdateTooltip
	self.AlternativePower:SetScript("OnEnter", OnEnter)
end