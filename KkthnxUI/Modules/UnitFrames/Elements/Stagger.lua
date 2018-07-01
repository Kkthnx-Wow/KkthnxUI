local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

function Module:CreateStagger()
	local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

	local stagger = CreateFrame("StatusBar", nil, self)
	stagger:SetPoint("LEFT", 4, 0)
	stagger:SetPoint("RIGHT", -4, 0)
	stagger:SetPoint("BOTTOM", self, "TOP", 0, 3)
	stagger:SetHeight(12)
	stagger:SetStatusBarTexture(UnitframeTexture)

	stagger.Background = stagger:CreateTexture(nil, "BACKGROUND", -1)
	stagger.Background:SetAllPoints()
	stagger.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	stagger.Border = CreateFrame("Frame", nil, stagger)
	stagger.Border:SetAllPoints()
	K.CreateBorder(stagger.Border)

	self.Stagger = stagger
end
