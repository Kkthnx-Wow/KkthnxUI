local K, C, L = select(2, ...):unpack()

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
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local MAX_PARTY_MEMBERS = MAX_PARTY_MEMBERS
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

-- Kill all stuff on default UI that we don't need
local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("ADDON_LOADED")
DisableBlizzard:SetScript("OnEvent", function(self, event)
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
			InterfaceOptionsFrameCategoriesButton10:SetParent(UIFrameHider)
			if not InCombatLockdown() then
				if IsAddOnLoaded("Blizzard_CompactRaidFrames") then
					CompactRaidFrameManager:SetParent(UIFrameHider)
					CompactUnitFrameProfiles:UnregisterAllEvents()
				end
			end

			CompactUnitFrameProfiles_ApplyProfile = K.Noop
			CompactRaidFrameManager_UpdateShown = K.Noop
			CompactRaidFrameManager_UpdateOptionsFlowContainer = K.Noop
		end
	end

	Advanced_UIScaleSlider:Kill()
	Advanced_UseUIScale:Kill()

	InterfaceOptionsActionBarsPanelCountdownCooldowns:Kill()
	SetCVar("countdownForCooldowns", 0)

	if C.General.DisableTutorialButtons then
		BagHelpBox:Kill()
		CollectionsMicroButtonAlert:Kill()
		EJMicroButtonAlert:Kill()
		HelpOpenTicketButtonTutorial:Kill()
		HelpPlate:Kill()
		HelpPlateTooltip:Kill()
		PremadeGroupsPvETutorialAlert:Kill()
		ReagentBankHelpBox:Kill()
		SpellBookFrameTutorialButton:Kill()
		TalentMicroButtonAlert:Kill()
		TutorialFrameAlertButton:Kill()
		WorldMapFrameTutorialButton:Kill()
	end

	if C.Unitframe.Enable then
		InterfaceOptionsCombatPanelTargetOfTarget:SetScale(0.0001)
		InterfaceOptionsCombatPanelTargetOfTarget:SetAlpha(0)
	end

	if C.Nameplates.Enable then
		SetCVar("ShowClassColorInNameplate", 1)
	end

	if C.ActionBar.Enable then
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
	end

	DisableBlizzard:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)