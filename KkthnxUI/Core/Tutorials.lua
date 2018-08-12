local K = unpack(select(2, ...))

local _G = _G

local CreateFrame = _G.CreateFrame
local DISABLE = _G.DISABLE
local HIDE = _G.HIDE
local playerName = _G.UnitName("player")
local playerRealm = _G.GetRealmName()

K.TutorialList = {
	"For technical support visit us in Discord |nhttps://discord.gg/YUmxqQm.",
	"If you are experiencing issues with KkthnxUI try disabling all your addons except KkthnxUI.",
	"To move abilities on the actionbars by default hold shift + drag.",
	"To setup which channels appear in which chat frame, right click the chat tab and go to settings.",
	"You can access copy chat and chat menu functions top right corner of chat and left/right click on the buttons",
	"You can see someones average item level of their gear by holding shift and mousing over them. It should appear inside the tooltip.",
	"You can set your keybinds quickly by typing /kb.",
	"You can toggle the microbar by using your middle mouse button on the minimap.",
	"You can use the /moveui command move frames around.",
	"Keep in mind Blizzard has blocked addons from modifying friendly nameplates in instances in 7.2. We can't do anything about this."
}

function K:SetNextTutorial()
	KkthnxUIData[playerRealm][playerName].currentTutorial = KkthnxUIData[playerRealm][playerName].currentTutorial or 0
	KkthnxUIData[playerRealm][playerName].currentTutorial = KkthnxUIData[playerRealm][playerName].currentTutorial + 1

	if KkthnxUIData[playerRealm][playerName].currentTutorial > #K.TutorialList then
		KkthnxUIData[playerRealm][playerName].currentTutorial = 1
	end

	KkthnxUITutorialWindow.desc:SetText(K.TutorialList[KkthnxUIData[playerRealm][playerName].currentTutorial])
end

function K:SetPrevTutorial()
	KkthnxUIData[playerRealm][playerName].currentTutorial = KkthnxUIData[playerRealm][playerName].currentTutorial or 0
	KkthnxUIData[playerRealm][playerName].currentTutorial = KkthnxUIData[playerRealm][playerName].currentTutorial - 1

	if KkthnxUIData[playerRealm][playerName].currentTutorial <= 0 then
		KkthnxUIData[playerRealm][playerName].currentTutorial = #K.TutorialList
	end

	KkthnxUITutorialWindow.desc:SetText(K.TutorialList[KkthnxUIData[playerRealm][playerName].currentTutorial])
end

function K:SpawnTutorialFrame()
	local f = CreateFrame("Frame", "KkthnxUITutorialWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(110)
	f:CreateBorder()
	f:Hide()

	local header = CreateFrame("Button", nil, f)
	header:CreateBorder()
	header:SetWidth(120)
	header:SetHeight(24)
	header:SetPoint("CENTER", f, "TOP")
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	local title = header:CreateFontString("OVERLAY")
	title:FontTemplate()
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText("|cff4488ffKkthnxUI Tutorial|r")

	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 30)
	f.desc = desc

	f.disableButton = CreateFrame("CheckButton", f:GetName().."DisableButton", f, "OptionsCheckButtonTemplate")
	_G[f.disableButton:GetName() .. "Text"]:SetText(DISABLE)
	_G[f.disableButton:GetName() .. "Text"]:SetPoint("LEFT", f.disableButton, "RIGHT", 4, 0)
	f.disableButton:SetSize(16, 16)
	f.disableButton:SetPoint("BOTTOMLEFT", 4, 4)
	f.disableButton:SkinButton()

	f.disableButton:SetScript("OnShow", function(self)
		if KkthnxUIData[playerRealm][playerName].hideTutorial == true then
			self:SetChecked(true)
		else
			self:SetChecked(false)
		end
	end)

	f.disableButton:SetScript("OnClick", function(self)
		if self:GetChecked() == true then
			KkthnxUIData[playerRealm][playerName].hideTutorial = true
		else
			KkthnxUIData[playerRealm][playerName].hideTutorial = false
		end
	end)

	f.hideButton = CreateFrame("Button", f:GetName().."HideButton", f, "OptionsButtonTemplate")
	f.hideButton:SetPoint("BOTTOMRIGHT", -5, 5)
	f.hideButton:SkinButton()
	_G[f.hideButton:GetName() .. "Text"]:SetText(HIDE)

	f.hideButton:SetScript("OnClick", function(self)
		_G.StaticPopupSpecial_Hide(self:GetParent())
	end)

	f.nextButton = CreateFrame("Button", f:GetName().."NextButton", f, "OptionsButtonTemplate")
	f.nextButton:SetPoint("RIGHT", f.hideButton, "LEFT", -4, 0)
	f.nextButton:SetWidth(20)
	f.nextButton:SkinButton()
	_G[f.nextButton:GetName() .. "Text"]:SetText(">")
	f.nextButton:SetScript("OnClick", function()
		K:SetNextTutorial()
	end)

	f.prevButton = CreateFrame("Button", f:GetName().."PrevButton", f, "OptionsButtonTemplate")
	f.prevButton:SetPoint("RIGHT", f.nextButton, "LEFT", -4, 0)
	f.prevButton:SetWidth(20)
	f.prevButton:SkinButton()
	_G[f.prevButton:GetName() .. "Text"]:SetText("<")
	f.prevButton:SetScript("OnClick", function()
		K:SetPrevTutorial()
	end)

	return f
end

function K:LoadTutorials()
	if (KkthnxUIData[playerRealm][playerName].hideTutorial) or (not KkthnxUIData[playerRealm][playerName].InstallComplete) then
		return
	end

	local f = KkthnxUITutorialWindow
	if not f then
		f = K:SpawnTutorialFrame()
	end

	_G.StaticPopupSpecial_Show(f)

	self:SetNextTutorial()
end