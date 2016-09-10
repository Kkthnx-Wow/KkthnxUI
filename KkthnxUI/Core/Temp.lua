local K, C, L = select(2, ...):unpack()
--[[
local _G = _G

local CreateFrame = CreateFrame
local DISABLE = DISABLE
local HIDE = HIDE

local Tutorial = CreateFrame("Frame", nil, UIParent)

K.TutorialList = {
	"For technical support visit us at https://github.com/Kkthnx.",
	"You can toggle the microbar by using your right mouse button on the minimap.",
	"You can set your keybinds quickly by typing /kb.",
	"The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro to do this.",
	"You can access copy chat and chat menu functions by mouse over the bottom right corner of chat panel and left/right click on the button that will appear.",
	"If you are experiencing issues with KkthnxUI try disabling all your addons except KkthnxUI, remember KkthnxUI is a full UI replacement addon, you cannot run two addons that do the same thing.",
	"To setup which channels appear in which chat frame, right click the chat tab and go to settings.",
	"You can use the /resetui command to reset all of your movers. You can also type /movbeui and just right click a mover to reset its position.",
	"To move abilities on the actionbars by default hold shift + drag. You can change the modifier key from the actionbar options menu.",
	"You can see someones average item level of their gear by holding alt and mousing over them. It should appear inside the tooltip."
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
	title:SetText("|cff2eb6ffKkthnxUI|r")

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

function Tutorial:OnEvent(event, ...)
	if (event == "PLAYER_LOGIN") then
		Tutorial:Tutorials(forceShow)
	end
end

Tutorial:RegisterEvent("PLAYER_LOGIN")
Tutorial:SetScript("OnEvent", Tutorial.OnEvent)
--]]