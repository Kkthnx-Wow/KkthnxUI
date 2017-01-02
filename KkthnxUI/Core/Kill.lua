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
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

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
			K.KillMenuPanel(10, "InterfaceOptionsFrameCategoriesButton")
			if not InCombatLockdown() then
				CompactRaidFrameContainer:Kill()
				CompactRaidFrameManager:Kill()
			end

			CompactRaidFrameManager_UpdateOptionsFlowContainer = K.Noop
			CompactRaidFrameManager_UpdateShown = K.Noop
			CompactUnitFrameProfiles_ApplyProfile = K.Noop
		end
	end

	K.KillMenuOption(true, "Advanced_UseUIScale")
	K.KillMenuOption(true, "Advanced_UIScaleSlider")

	if C.Cooldown.Enable then
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
		local DisableCD = GetCVarBool("countdownForCooldowns")
		if not DisableCD and not InCombatLockdown() then
			SetCVar("countdownForCooldowns", 0)
		end
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
		K.KillMenuOption(true, "InterfaceOptionsCombatPanelTargetOfTarget")
	end

	if C.Nameplates.Enable then
		local PlateClassColor = GetCVarBool("ShowClassColorInNameplate")
		if not PlateClassColor and not InCombatLockdown() then
			SetCVar("ShowClassColorInNameplate", 1)
		end
		-- Hide the option to rescale, because we will do it from KkthnxUI settings.
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesMakeLarger")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesAggroFlash")
	end

	if C.Chat.Enable then
		local ChatStyle = GetCVarBool("chatStyle")
		if not ChatStyle and not InCombatLockdown() then
			SetCVar("chatStyle", "im")
		end
	end

	if C.ActionBar.Enable then
		if InCombatLockdown() then return end
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
		InterfaceOptionsActionBarsPanelBottomRight:SetAlpha(0)
		InterfaceOptionsActionBarsPanelBottomRight:SetScale(0.0001)
		InterfaceOptionsActionBarsPanelBottomLeft:SetAlpha(0)
		InterfaceOptionsActionBarsPanelBottomLeft:SetScale(0.0001)
		InterfaceOptionsActionBarsPanelRightTwo:SetAlpha(0)
		InterfaceOptionsActionBarsPanelRightTwo:SetScale(0.0001)
		InterfaceOptionsActionBarsPanelRight:SetAlpha(0)
		InterfaceOptionsActionBarsPanelRight:SetScale(0.0001)
	end

	if C.Minimap.Enable then
		K.KillMenuOption(true, "InterfaceOptionsDisplayPanelRotateMinimap")
	end

	if event == "ADDON_LOADED" then
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end)