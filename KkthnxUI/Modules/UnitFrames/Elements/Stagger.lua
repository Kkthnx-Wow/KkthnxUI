local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local UnitframeFont = K.GetFont(C["Unitframe"].Font)
local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

function K.CreateStagger(self)
	if K.Class ~= "MONK" then return end

	local stagger = CreateFrame("StatusBar", nil, self)
	stagger:SetPoint("LEFT")
	stagger:SetPoint("RIGHT")
	stagger:SetPoint("BOTTOM", self, "TOP", 0, 0)
	stagger:SetHeight(12)
	stagger:SetStatusBarTexture(UnitframeTexture)

	self.Stagger = stagger
end