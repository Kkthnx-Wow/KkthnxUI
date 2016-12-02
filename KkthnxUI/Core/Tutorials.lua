local K, C, L = select(2, ...):unpack()

-- Lua API
local _G = _G

-- Wow API
local CreateFrame = CreateFrame
local StaticPopupSpecial_Hide = StaticPopupSpecial_Hide
local StaticPopupSpecial_Show = StaticPopupSpecial_Show
local UIParent = UIParent

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIDataPerChar, TutorialWindow, DISABLE, HIDE, forceShow

local Tutorial = CreateFrame("Frame", nil, UIParent)

K.TutorialList = {
	L.Tutorial.Message1,
	L.Tutorial.Message2,
	L.Tutorial.Message3,
	L.Tutorial.Message4,
	L.Tutorial.Message5,
	L.Tutorial.Message6,
	L.Tutorial.Message7,
	L.Tutorial.Message8,
	L.Tutorial.Message9,
	L.Tutorial.Message10,
}

function Tutorial:SetNextTutorial()
	KkthnxUIDataPerChar.currentTutorial = KkthnxUIDataPerChar.currentTutorial or 0
	KkthnxUIDataPerChar.currentTutorial = KkthnxUIDataPerChar.currentTutorial + 1

	if KkthnxUIDataPerChar.currentTutorial > #K.TutorialList then
		KkthnxUIDataPerChar.currentTutorial = 1
	end

	TutorialWindow.desc:SetText(K.TutorialList[KkthnxUIDataPerChar.currentTutorial])
end

function Tutorial:SetPrevTutorial()
	KkthnxUIDataPerChar.currentTutorial = KkthnxUIDataPerChar.currentTutorial or 0
	KkthnxUIDataPerChar.currentTutorial = KkthnxUIDataPerChar.currentTutorial - 1

	if KkthnxUIDataPerChar.currentTutorial <= 0 then
		KkthnxUIDataPerChar.currentTutorial = #K.TutorialList
	end

	TutorialWindow.desc:SetText(K.TutorialList[KkthnxUIDataPerChar.currentTutorial])
end

function Tutorial:SpawnTutorialFrame()
	local f = CreateFrame("Frame", "TutorialWindow", UIParent)
	f:SetFrameStrata("DIALOG")
	f:SetToplevel(true)
	f:SetClampedToScreen(true)
	f:SetWidth(360)
	f:SetHeight(110)
	f:SetTemplate("Transparent")
	f:Hide()

	local header = CreateFrame("Button", nil, f)
	header:SetTemplate("Default", true)
	header:SetBackdropColor(5/255, 5/255, 5/255, 1)
	header:SetWidth(130) header:SetHeight(30)
	header:SetPoint("CENTER", f, "TOP", 0, -2)
	header:SetFrameLevel(header:GetFrameLevel() + 2)

	local title = header:CreateFontString("OVERLAY")
	title:SetFont(C.Media.Font, 14, "OUTLINE")
	title:SetPoint("CENTER", header, "CENTER")
	title:SetText("|cff3c9bedKkthnxUI|r" .." v".. K.Version)

	local desc = f:CreateFontString("ARTWORK")
	desc:SetFontObject("GameFontHighlight")
	desc:SetJustifyV("TOP")
	desc:SetJustifyH("LEFT")
	desc:SetPoint("TOPLEFT", 18, -32)
	desc:SetPoint("BOTTOMRIGHT", -18, 30)
	f.desc = desc

	f.disableButton = CreateFrame("CheckButton", f:GetName().."DisableButton", f, "OptionsCheckButtonTemplate")
	_G[f.disableButton:GetName() .. "Text"]:SetText(DISABLE)
	f.disableButton:SetPoint("BOTTOMLEFT", 2, 0)
	f.disableButton:SetScript("OnShow", function(self) self:SetChecked(KkthnxUIDataPerChar.hideTutorial) end)
	f.disableButton:SetScript("OnClick", function(self) KkthnxUIDataPerChar.hideTutorial = self:GetChecked() end)

	f.hideButton = CreateFrame("Button", f:GetName().."HideButton", f, "OptionsButtonTemplate")
	f.hideButton:SetPoint("BOTTOMRIGHT", -7, 7)
	f.hideButton:SetSize(80, 19)
	f.hideButton:SkinButton()
	_G[f.hideButton:GetName() .. "Text"]:SetText(HIDE)
	f.hideButton:SetScript("OnClick", function(self) StaticPopupSpecial_Hide(self:GetParent()) end)

	f.nextButton = CreateFrame("Button", f:GetName().."NextButton", f, "OptionsButtonTemplate")
	f.nextButton:SetPoint("RIGHT", f.hideButton, "LEFT", -6, 0)
	f.nextButton:SetSize(20, 19)
	f.nextButton:SkinButton()
	_G[f.nextButton:GetName() .. "Text"]:SetText(">")
	f.nextButton:SetScript("OnClick", function(self) Tutorial:SetNextTutorial() end)

	f.prevButton = CreateFrame("Button", f:GetName().."PrevButton", f, "OptionsButtonTemplate")
	f.prevButton:SetPoint("RIGHT", f.nextButton, "LEFT", -6, 0)
	f.prevButton:SetSize(20, 19)
	f.prevButton:SkinButton()
	_G[f.prevButton:GetName() .. "Text"]:SetText("<")
	f.prevButton:SetScript("OnClick", function(self) Tutorial:SetPrevTutorial() end)

	return f
end

function Tutorial:Tutorials(forceShow)
	if (not forceShow and KkthnxUIDataPerChar.hideTutorial) or (not forceShow and not KkthnxUIDataPerChar.Install) then return end
	local f = TutorialWindow
	if not f then
		f = Tutorial:SpawnTutorialFrame()
	end

	StaticPopupSpecial_Show(f)

	self:SetNextTutorial()
end

Tutorial:RegisterEvent("PLAYER_ENTERING_WORLD")
Tutorial:SetScript("OnEvent", function(self, event, ...)
	Tutorial:Tutorials(forceShow)
	Tutorial:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)