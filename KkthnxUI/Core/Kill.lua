local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local type = type

-- Wow API
local CompactRaidFrameContainer = CompactRaidFrameContainer
local CompactRaidFrameManager_GetSetting = CompactRaidFrameManager_GetSetting
local CompactRaidFrameManager_SetSetting = CompactRaidFrameManager_SetSetting
local CompactRaidFrameManager_UpdateShown = CompactRaidFrameManager_UpdateShown
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local SetCVar = SetCVar
local SetCVarBitfield = SetCVarBitfield
local StaticPopup_Show = StaticPopup_Show
local UnitAffectingCombat = UnitAffectingCombat

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: addon, InterfaceOptionsFrameCategoriesButton10, PetFrame_Update, PlayerFrame_AnimateOut
-- GLOBALS: PlayerFrame_AnimFinished, PlayerFrame_ToPlayerArt, PlayerFrame_ToVehicleArt, CompactRaidFrameManager
-- GLOBALS: UIFrameHider, CompactUnitFrameProfiles, HidePartyFrame, ShowPartyFrame, GarrisonLandingPageTutorialBox
-- GLOBALS: Advanced_UIScaleSlider, Advanced_UseUIScale, BagHelpBox, CollectionsMicroButtonAlert, EJMicroButtonAlert
-- GLOBALS: HelpOpenTicketButtonTutorial, HelpPlate, HelpPlateTooltip, PremadeGroupsPvETutorialAlert, ReagentBankHelpBox
-- GLOBALS: SpellBookFrameTutorialButton, TalentMicroButtonAlert, TutorialFrameAlertButton, WorldMapFrameTutorialButton
-- GLOBALS: LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, LE_FRAME_TUTORIAL_PET_JOURNAL, LE_FRAME_TUTORIAL_GARRISON_BUILDING
-- GLOBALS: InterfaceOptionsCombatPanelTargetOfTarget, InterfaceOptionsActionBarsPanelCountdownCooldowns, PlayerFrame
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesMakeLarger, InterfaceOptionsDisplayPanelRotateMinimap, RuneFrame
-- GLOBALS: InterfaceOptionsActionBarsPanelBottomLeft, InterfaceOptionsActionBarsPanelBottomRight, unit
-- GLOBALS: InterfaceOptionsActionBarsPanelRight, InterfaceOptionsActionBarsPanelRightTwo, InterfaceOptionsActionBarsPanelAlwaysShowActionBars
-- GLOBALS: PetFrame, TargetFrame, ComboFrame, FocusFrame, FocusFrameToT, TargetFrameToT, UIParent, PetJournalTutorialButton
-- GLOBALS: PlayerTalentFramePetSpecializationTutorialButton, PlayerTalentFrameSpecializationTutorialButton, PlayerTalentFrameTalentsTutorialButton
-- GLOBALS: InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy, NamePlateDriverFrame

-- Kill all stuff on default UI that we don"t need
local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("ADDON_LOADED")
DisableBlizzard:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_AchievementUI" then
		if C.Tooltip.Enable then
			hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
		end
	end

	if C.Unitframe.Enable then
		function PetFrame_Update() end
		function PlayerFrame_AnimateOut() end
		function PlayerFrame_AnimFinished() end
		function PlayerFrame_ToPlayerArt() end
		function PlayerFrame_ToVehicleArt() end

		HidePartyFrame = K.Noop
		ShowPartyFrame = K.Noop
	end

	if C.Raidframe.Enable then
		if not CompactRaidFrameManager_UpdateShown then
			StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
		else
			InterfaceOptionsFrameCategoriesButton10:SetHeight(0.00001)
			InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)
			if not InCombatLockdown() then
				CompactRaidFrameManager:Kill()
				CompactRaidFrameContainer:Kill()
			end

			CompactUnitFrameProfiles_ApplyProfile = K.Noop
			CompactRaidFrameManager_UpdateShown = K.Noop
			CompactRaidFrameManager_UpdateOptionsFlowContainer = K.Noop
		end
	end

	Advanced_UIScaleSlider:Kill()
	Advanced_UseUIScale:Kill()

	if C.Cooldown.Enable then
		InterfaceOptionsActionBarsPanelCountdownCooldowns:Kill()
		SetCVar("countdownForCooldowns", 0)
	end

	if C.General.DisableTutorialButtons then
		BagHelpBox:Kill()
		CollectionsMicroButtonAlert:Kill()
		EJMicroButtonAlert:Kill()
		HelpOpenTicketButtonTutorial:Kill()
		HelpPlate:Kill()
		HelpPlateTooltip:Kill()
		PremadeGroupsPvETutorialAlert:Kill()
		ReagentBankHelpBox:Kill()
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
		SpellBookFrameTutorialButton:Kill()
		TalentMicroButtonAlert:Kill()
		TutorialFrameAlertButton:Kill()
		WorldMapFrameTutorialButton:Kill()
	end

	if C.Unitframe.Enable then
		InterfaceOptionsCombatPanelTargetOfTarget:SetScale(0.00001)
		InterfaceOptionsCombatPanelTargetOfTarget:SetAlpha(0)
	end

	if C.Nameplates.Enable then
		SetCVar("ShowClassColorInNameplate", 1)
		-- Hide the option to rescale, because we will do it from KkthnxUI settings.
		InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Hide()
		InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:SetScale(0.00001)
		InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy:Hide()
		InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy:SetScale(0.00001)
		InterfaceOptionsNamesPanelUnitNameplatesAggroFlash:Hide()
		InterfaceOptionsNamesPanelUnitNameplatesAggroFlash:SetScale(0.00001)
	end

	if C.Chat.Enable then
		SetCVar("chatStyle", "im")
	end

	if C.ActionBar.Enable then
		InterfaceOptionsActionBarsPanelBottomLeft:Hide()
		InterfaceOptionsActionBarsPanelBottomRight:Hide()
		InterfaceOptionsActionBarsPanelRight:Hide()
		InterfaceOptionsActionBarsPanelRightTwo:Hide()
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Hide()
	end

	if C.Minimap.Enable then
		InterfaceOptionsDisplayPanelRotateMinimap:Kill()
	end
end)