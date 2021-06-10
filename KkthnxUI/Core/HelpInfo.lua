local K, C = unpack(select(2, ...))
-- local Module = K:NewModule("HelpInfo")

local helpCommands = {
	["checkquest"] = "|cff669DFF/checkquest ID|r or |cff669DFF/questcheck ID|r - Check the completion status of a quest",
	["clearchat"] = "|cff669DFF/clearchat|r - Clear your chat window of all text in it",
	["clearcombat"] = "|cff669DFF/clearcombat|r - Clear your combatlog of all text in it",
	["convert"] = "|cff669DFF/convert|r or |cff669DFF/toraid|r or |cff669DFF/toparty|r - Convert to party or raid and vise versa",
	["dbmtest"] = "|cff669DFF/dbmtest|r - Test DeadlyBossMods bars (Must have DBM installed/enabled)",
	["deletequestitems"] = "|cff669DFF/deletequestitems|r or |cff669DFF/dqi|r - Delete all quest items that are in your bags",
	["grid"] = "|cff669DFF/grid #|r or |cff669DFF/align #|r - Display a grid which allows you to better align frames",
	["install"] = "|cff669DFF/install|r - Show KkthnxUI installer",
	["kaw"] = "|cff669DFF/kaw|r - Show KkthnxUI aurawatch configurations window",
	["kcl"] = "|cff669DFF/kcl|r - Show KkthnxUI most recent changelog",
	["killquests"] = "|cff669DFF/killquests|r - Remove all quests from your questlog",
	["kstatus"] = "|cff669DFF/kstatus|r - Show KkthnxUI status report window. Used to reporting bugs",
	["moveui"] = "|cff669DFF/moveui|r - Move 'most' KkthnxUI elements as you please",
	["rc"] = "|cff669DFF/rc|r - Start a readycheck on your current group",
	["ri"] = "|cff669DFF/ri|r - Reset the most recent instance you were in",
	["rl"] = "|cff669DFF/rl|r - Reload your user interface quickly",
	["ticket"] = "|cff669DFF/ticket|r - Write a ticket to Blizzard for help",
	["trackingdebuffs"] = "|cff669DFF/tracking|r or |cff669DFF/kt|r - Add/remove debuff tracking for auras on raid",
}

local Help = CreateFrame("Frame", "KKUI_HelpInfo", UIParent)
local Texts = {}
local Count = 1

function Help:OnEnable()
	self:SetSize(600, 500)
	self:SetPoint("TOP", UIParent, "TOP", 0, -200)
	self:CreateBorder()

	self.Logo = self:CreateTexture(nil, "OVERLAY")
	self.Logo:SetSize(512, 256)
	self.Logo:SetBlendMode("ADD")
	self.Logo:SetAlpha(0.06)
	self.Logo:SetTexture(C["Media"].Textures.LogoTexture)
	self.Logo:SetPoint("CENTER", self, "CENTER", 0, 0)

	self.Title = self:CreateFontString(nil, "OVERLAY")
	self.Title:SetFontObject(KkthnxUIFont)
	self.Title:SetFont(select(1, self.Title:GetFont()), 22, select(3, self.Title:GetFont()))
	self.Title:SetPoint("TOP", self, "TOP", 0, -8)
	self.Title:SetText(K.InfoColor.."KkthnxUI|r "..K.SystemColor.."Commands Help|r")

	local ll = CreateFrame("Frame", nil, self)
	ll:SetPoint("TOP", self.Title, -100, -30)
	K.CreateGF(ll, 200, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, self)
	lr:SetPoint("TOP", self.Title, 100, -30)
	K.CreateGF(lr, 200, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")

	self.Close = CreateFrame("Button", nil, self)
	self.Close:SetSize(32, 32)
	self.Close:SetPoint("TOPRIGHT", self, "TOPRIGHT", -4, -4)
	self.Close:SkinCloseButton()
	self.Close:SetScript("OnClick", function(self) self:GetParent():Hide() end)

	for Index, Value in pairs(helpCommands) do
		Texts[Index] = self:CreateFontString(nil, "OVERLAY")
		Texts[Index]:SetFontObject(KkthnxUIFont)
		Texts[Index]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 20, 22 * Count)
		Texts[Index]:SetText(Value)

		Count = Count + 1
	end

	self:Hide()
end

Help:OnEnable()

SlashCmdList["KKUI_HELP"] = function()
	Help:Show()
end
_G.SLASH_KKUI_HELP1 = "/khelp"