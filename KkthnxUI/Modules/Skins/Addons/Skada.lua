local K, C, L = unpack(select(2, ...))
if C["Skins"].Skada ~= true or not K.IsAddOnEnabled("Skada") then return end

local _G = _G

local AcceptFrame = _G.AcceptFrame
local CreateFrame = _G.CreateFrame
local NO = _G.NO
local Skada = _G.Skada
local UIParent = _G.UIParent
local YES = _G.YES

local SkadaFont = K.GetFont(C["Skins"].Font)
local SkadaTexture = K.GetTexture(C["Skins"].Texture)

function K.AcceptFrame(MainText, Function)
	if not AcceptFrame then
		AcceptFrame = CreateFrame("Frame", "AcceptFrame", UIParent)
		AcceptFrame:SetTemplate("Transparent")
		AcceptFrame:SetPoint("CENTER", UIParent, "CENTER")
		AcceptFrame:SetFrameStrata("DIALOG")
		AcceptFrame.Text = AcceptFrame:CreateFontString(nil, "OVERLAY")
		AcceptFrame.Text:SetFont(C["Media"].Font, 14)
		AcceptFrame.Text:SetPoint("TOP", AcceptFrame, "TOP", 0, -10)
		AcceptFrame.Accept = CreateFrame("Button", nil, AcceptFrame, "OptionsButtonTemplate")
		AcceptFrame.Accept:SkinButton()
		AcceptFrame.Accept:SetSize(70, 24)
		AcceptFrame.Accept:SetPoint("RIGHT", AcceptFrame, "BOTTOM", -10, 20)
		AcceptFrame.Accept:SetFormattedText("|cFFFFFFFF%s|r", YES)
		AcceptFrame.Close = CreateFrame("Button", nil, AcceptFrame, "OptionsButtonTemplate")
		AcceptFrame.Close:SkinButton()
		AcceptFrame.Close:SetSize(70, 24)
		AcceptFrame.Close:SetPoint("LEFT", AcceptFrame, "BOTTOM", 10, 20)
		AcceptFrame.Close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
		AcceptFrame.Close:SetFormattedText("|cFFFFFFFF%s|r", NO)
	end
	AcceptFrame.Text:SetText(MainText)
	AcceptFrame:SetSize(AcceptFrame.Text:GetStringWidth() + 100, AcceptFrame.Text:GetStringHeight() + 60)
	AcceptFrame.Accept:SetScript("OnClick", Function)
	AcceptFrame:Show()
end

function Skada:ShowPopup()
	K.AcceptFrame(L.Skins.Skada_Reset, function(self)
		Skada:Reset()
		self:GetParent():Hide()
	end)
end

local barmod = Skada.displays["bar"]

barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	barmod.ApplySettings_(self, win)

	local skada = win.bargroup

	skada:SetTexture(SkadaTexture)
	skada:SetSpacing(1, 1)

	skada:SetBackdrop(nil)
	skada.borderFrame:SetBackdrop(nil)

	if not skada.border then
		skada.border = CreateFrame("Frame", "KkthnxUI"..skada:GetName().."Skin", skada)
		skada.border:SetAllPoints(skada.borderFrame)
		skada.border:SetTemplate("Transparent")
	end
end

for _, window in ipairs(Skada:GetWindows()) do
	window:UpdateDisplay()
end