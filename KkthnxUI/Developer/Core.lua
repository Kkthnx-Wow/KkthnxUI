local K, C, L = unpack(KkthnxUI)
local Module = K:NewModule("Dev")

K.Devs = {
	["Ashanarra-Oribos"] = true,
	["Informant-Oribos"] = true,
	["Kkthnx-Arena 52"] = true,
	["Kkthnx-Oribos"] = true,
	["Swipers-Oribos"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

local _G = _G
local CreateFrame = _G.CreateFrame
local GetUnitName = _G.GetUnitName
local SendChatMessage = _G.SendChatMessage

-- Test
local ThanksButtonSetting = true

function Module:CreateThanksButton()
	self.thanksButton = CreateFrame("Button", "KKUI_ThanksButton", _G.TradeFrame, "UIPanelButtonTemplate")
	self.thanksButton:SetSize(80, 20)
	self.thanksButton:SetText("Thanks")
	self.thanksButton:SetScript("OnClick", function(self)
		if self.targetName then
			SendChatMessage("Thank you!", "WHISPER", nil, self.targetName)
		end
	end)

	self.thanksButton:SetPoint("BOTTOMLEFT", _G.TradeFrame, "BOTTOMLEFT", 5, 5)
end

function Module:FetchTargetName()
	local targetName = GetUnitName("NPC", true)
	if self.thanksButton then
		self.thanksButton.targetName = targetName
	end
end

function Module:UpdateThanksButton() -- Hook this to our config button later on
	if ThanksButtonSetting then
		if self.thanksButton then
			self.thanksButton:Show()
		else
			self:CreateThanksButton()
		end
		K:RegisterEvent("TRADE_SHOW", self.FetchTargetName)
	else
		if self.thanksButton then
			self.thanksButton:Hide()
		end
		K:UnregisterEvent("TRADE_SHOW", self.FetchTargetName)
	end
end

function Module:OnEnable()
	if not ThanksButtonSetting then
		return
	end

	self:CreateThanksButton()
	K:RegisterEvent("TRADE_SHOW", self.FetchTargetName)
end
