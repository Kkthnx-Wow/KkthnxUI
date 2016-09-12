local K, C, L = select(2, ...):unpack()

local _G = _G

local CreateFrame = CreateFrame
local DISABLE = DISABLE
local HIDE = HIDE

local Tutorial = CreateFrame("Frame", nil, UIParent)

K.TutorialList = {
	L_TUTORIAL_MESSAGE_1,
	L_TUTORIAL_MESSAGE_2,
	L_TUTORIAL_MESSAGE_3,
	L_TUTORIAL_MESSAGE_4,
	L_TUTORIAL_MESSAGE_5,
	L_TUTORIAL_MESSAGE_6,
	L_TUTORIAL_MESSAGE_7,
	L_TUTORIAL_MESSAGE_8,
	L_TUTORIAL_MESSAGE_9,
	L_TUTORIAL_MESSAGE_10,
}

function Tutorial:SetNextTutorial()
	SavedOptionsPerChar.currentTutorial = SavedOptionsPerChar.currentTutorial or 0
	SavedOptionsPerChar.currentTutorial = SavedOptionsPerChar.currentTutorial + 1

	if SavedOptionsPerChar.currentTutorial > #K.TutorialList then
		SavedOptionsPerChar.currentTutorial = 1
	end

	TutorialWindow.desc:SetText(K.TutorialList[SavedOptionsPerChar.currentTutorial])
end

function Tutorial:SetPrevTutorial()
	SavedOptionsPerChar.currentTutorial = SavedOptionsPerChar.currentTutorial or 0
	SavedOptionsPerChar.currentTutorial = SavedOptionsPerChar.currentTutorial - 1

	if SavedOptionsPerChar.currentTutorial <= 0 then
		SavedOptionsPerChar.currentTutorial = #K.TutorialList
	end

	TutorialWindow.desc:SetText(K.TutorialList[SavedOptionsPerChar.currentTutorial])
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
	title:SetText("|cff2eb6ffKkthnxUI|r" .." v".. K.Version)

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
	f.disableButton:SetScript("OnShow", function(self) self:SetChecked(SavedOptionsPerChar.hideTutorial) end)

	f.disableButton:SetScript("OnClick", function(self) SavedOptionsPerChar.hideTutorial = self:GetChecked() end)

	f.hideButton = CreateFrame("Button", f:GetName().."HideButton", f, "OptionsButtonTemplate")
	f.hideButton:SetPoint("BOTTOMRIGHT", -5, 5)
	_G[f.hideButton:GetName() .. "Text"]:SetText(HIDE)
	f.hideButton:SetScript("OnClick", function(self) StaticPopupSpecial_Hide(self:GetParent()) end)

	f.nextButton = CreateFrame("Button", f:GetName().."NextButton", f, "OptionsButtonTemplate")
	f.nextButton:SetPoint("RIGHT", f.hideButton, "LEFT", -4, 0)
	f.nextButton:SetWidth(22)
	_G[f.nextButton:GetName() .. "Text"]:SetText(">")
	f.nextButton:SetScript("OnClick", function(self) Tutorial:SetNextTutorial() end)

	f.prevButton = CreateFrame("Button", f:GetName().."PrevButton", f, "OptionsButtonTemplate")
	f.prevButton:SetPoint("RIGHT", f.nextButton, "LEFT", -4, 0)
	f.prevButton:SetWidth(22)
	_G[f.prevButton:GetName() .. "Text"]:SetText("<")
	f.prevButton:SetScript("OnClick", function(self) Tutorial:SetPrevTutorial() end)

	return f
end

function Tutorial:Tutorials(forceShow)
	if (not forceShow and SavedOptionsPerChar.hideTutorial) or (not forceShow and not SavedOptionsPerChar.Install) then return end
	local f = TutorialWindow
	if not f then
		f = Tutorial:SpawnTutorialFrame()
	end

	StaticPopupSpecial_Show(f)

	self:SetNextTutorial()
end

function Tutorial:OnEvent(event)
	if (event == "PLAYER_LOGIN") then
		Tutorial:Tutorials(forceShow)
	end
end

Tutorial:RegisterEvent("PLAYER_LOGIN")
Tutorial:SetScript("OnEvent", Tutorial.OnEvent)