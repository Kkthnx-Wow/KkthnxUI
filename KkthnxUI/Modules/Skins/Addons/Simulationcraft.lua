local K = unpack(select(2, ...))
local ModuleSkinsTest = K:GetModule("SkinsTest")

local function SimcSkin()
	if not SimcCopyFrame then return end
	SimcCopyFrame:CreateBorder(nil, nil, nil, true)
	SimcCopyFrameButton:SkinButton()
	SimcCopyFrameScrollScrollBar:SetAlpha(0)
end

ModuleSkinsTest:LoadWithAddOn("Simulationcraft", "Simulationcraft", SimcSkin)