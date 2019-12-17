local K, C = unpack(select(2, ...))
local Module = K:NewModule("Skins")

local _G = _G
local pairs = pairs
local type = type

local IsAddOnLoaded = _G.IsAddOnLoaded
local NO = _G.NO

Module.NewSkin = {}
Module.NewSkin["KkthnxUI"] = {}
local function LoadWithSkin(_, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") then
		Module:UnregisterEvent("ADDON_LOADED", LoadWithSkin)
		return
	end

	for _addon, skinfunc in pairs(Module.NewSkin) do
		if type(skinfunc) == "function" then
			if _addon == addon then
				if skinfunc then
					skinfunc()
				end
			end
		elseif type(skinfunc) == "table" then
			if _addon == addon then
				for _, skinfunc in pairs(Module.NewSkin[_addon]) do
					if skinfunc then
						skinfunc()
					end
				end
			end
		end
	end
end
K:RegisterEvent("ADDON_LOADED", LoadWithSkin)

function Module:AcceptFrame(MainText, Function)
	if not AcceptFrame then
		AcceptFrame = CreateFrame("Frame", "AcceptFrame", UIParent)

		AcceptFrame.Background = AcceptFrame:CreateTexture(nil, "BACKGROUND", -1)
		AcceptFrame.Background:SetAllPoints()
		AcceptFrame.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		K.CreateBorder(AcceptFrame)

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

function Module:OnEnable()
	self:ReskinBigWigs()
	self:ReskinDBM()
	self:ReskinDetails()
	self:ReskinSimulationcraft()
	self:ReskinSkada()
	self:ReskinSpy()
	self:ReskinTitanPanel()
	self:ReskinWeakAuras()
	self:ReskinWorldQuestTab()
end