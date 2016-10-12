local K, C, L = select(2, ...):unpack()
if C.Skins.Skada ~= true then return end

-- SKADA SKIN
if not IsAddOnLoaded("Skada") or not C.Skins.Skada then return end

local Skada = Skada
local barmod = Skada.displays["bar"]

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	barmod.ApplySettings_(self, win)

	local skada = win.bargroup

	skada:SetTexture(C.Media.Texture)
	skada:SetSpacing(1, 1)
	skada:SetFont(C.Media.Font, 12)

	skada:SetBackdrop(nil)
	skada.borderFrame:SetBackdrop(nil)

	if not skada.border then
		skada.border = CreateFrame("Frame", "KkthnxUI"..skada:GetName().."Skin", skada)
		skada.border:SetAllPoints(skada.borderFrame)
		skada.border:CreateBackdrop("Transparent")
	end
end

for _, window in ipairs(Skada:GetWindows()) do
	window:UpdateDisplay()
end