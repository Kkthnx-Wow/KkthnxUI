local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local UnitframeFont = K.GetFont(C["Unitframe"].Font)
local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

function K.CreateStagger(self)
	local stagger = CreateFrame("StatusBar", nil, self)
	stagger:SetPoint("LEFT", 4, 0)
	stagger:SetPoint("RIGHT", -4, 0)
	stagger:SetPoint("BOTTOM", self, "TOP", 0, 3)
	stagger:SetHeight(12)
	stagger:SetStatusBarTexture(UnitframeTexture)
	stagger:SetTemplate("Transparent")

	self.Stagger = stagger
end