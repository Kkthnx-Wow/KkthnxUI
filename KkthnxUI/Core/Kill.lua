local K, C, L, _ = select(2, ...):unpack()

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local SetCVar = SetCVar

-- Kill all stuff on default UI that we don't need
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon, ...)

	if addon == "Blizzard_AchievementUI" then
		if C.Tooltip.Enable then
			hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
		end
	end

	Advanced_UseUIScale:Kill()
	Advanced_UIScaleSlider:Kill()
	TutorialFrameAlertButton:Kill()
	HelpOpenTicketButtonTutorial:Kill()
	TalentMicroButtonAlert:Kill()
	CollectionsMicroButtonAlert:Kill()
	ReagentBankHelpBox:Kill()
	BagHelpBox:Kill()
	EJMicroButtonAlert:Kill()
	PremadeGroupsPvETutorialAlert:Kill()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)

	SetCVar("countdownForCooldowns", 0)
	InterfaceOptionsActionBarsPanelCountdownCooldowns:Kill()

	if C.Chat.Enable then
		--SetCVar("chatStyle", "im")
	end

	if C.Unitframe.Enable then
		PartyMemberBackground:Kill()
	end

	if C.Minimap.Enable then
		InterfaceOptionsDisplayPanelRotateMinimap:Kill()
	end

	if C.ActionBar.Enable then
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
	end

	if C.Unitframe.EnhancedFrames then
		SetCVar("fullSizeFocusFrame", 1)
	end
end)