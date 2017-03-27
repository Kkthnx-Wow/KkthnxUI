local K, C, L = unpack(select(2, ...))
if C.Skins.Skada ~= true or not K.CheckAddOn("Skada") then return end

local _G = _G

local CreateFrame = _G.CreateFrame
local Skada = _G.Skada

-- GLOBALS: size

local barmod = Skada.displays["bar"]

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	barmod.ApplySettings_(self, win)

	local skada = win.bargroup

	skada:SetTexture(C.Media.Texture)
	skada:SetSpacing(1, 1)

	skada:SetBackdrop(nil)
	skada.borderFrame:SetBackdrop(nil)

	if not skada.border then
		skada.border = CreateFrame("Frame", "KkthnxUI"..skada:GetName().."Skin", skada)
		skada.border:SetAllPoints(skada.borderFrame)
		skada.border:CreateBackdrop(size, 3)
	end
end

for _, window in ipairs(Skada:GetWindows()) do
	window:UpdateDisplay()
end