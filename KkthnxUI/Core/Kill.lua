local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Kill", "AceEvent-3.0")

local _G = _G

local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local LE_FRAME_TUTORIAL_GARRISON_BUILDING = _G.LE_FRAME_TUTORIAL_GARRISON_BUILDING
local LE_FRAME_TUTORIAL_PET_JOURNAL = _G.LE_FRAME_TUTORIAL_PET_JOURNAL
local LE_FRAME_TUTORIAL_WORLD_MAP_FRAME = _G.LE_FRAME_TUTORIAL_WORLD_MAP_FRAME
local SetCVar = _G.SetCVar
local SetCVarBitfield = _G.SetCVarBitfield
local SetInsertItemsLeftToRight = _G.SetInsertItemsLeftToRight
local SetSortBagsRightToLeft = _G.SetSortBagsRightToLeft

-- GLOBALS: Advanced_UseUIScale, Advanced_UIScaleSlider, RuneFrame,PartyMemberBackground
-- GLOBALS: BagHelpBox, BuffFrame, HelpOpenTicketButtonTutorial, HelpPlate, HelpPlateTooltip
-- GLOBALS: CompactRaidFrameManager_UpdateShown, CompactRaidFrameManager_UpdateOptionsFlowContainer
-- GLOBALS: CompactRaidFrameManager, CompactRaidFrameContainer, CompactUnitFrameProfiles_ApplyProfile
-- GLOBALS: InterfaceOptionsActionBarsPanelAlwaysShowActionBars, InterfaceOptionsActionBarsPanelBottomLeft
-- GLOBALS: InterfaceOptionsActionBarsPanelBottomRight, InterfaceOptionsActionBarsPanelRight
-- GLOBALS: InterfaceOptionsActionBarsPanelRightTwo, PetJournalTutorialButton, PlayerTalentFrame
-- GLOBALS: InterfaceOptionsUnitFramePanelPartyBackground, WorldMapFrameTutorialButton
-- GLOBALS: PlayerTalentFramePetSpecializationTutorialButton, PlayerTalentFrameSpecializationTutorialButton
-- GLOBALS: PlayerTalentFrameTalentsTutorialButton, PremadeGroupsPvETutorialAlert, ReagentBankHelpBox
-- GLOBALS: ShowPartyFrame, HidePartyFrame, InterfaceOptionsFrameCategoriesButton10
-- GLOBALS: SpellBookFrameTutorialButton, TemporaryEnchantFrame, TutorialFrameAlertButton

function Module:ADDON_LOADED(_, addon)
	if (C["Raid"].Enable) then
		InterfaceOptionsFrameCategoriesButton10:SetScale(0.00001)
		InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)
		if not InCombatLockdown() then
			CompactRaidFrameManager:Kill()
			CompactRaidFrameContainer:Kill()
		end
		ShowPartyFrame = K.Noop
		HidePartyFrame = K.Noop
		CompactUnitFrameProfiles_ApplyProfile = K.Noop
		CompactRaidFrameManager_UpdateShown = K.Noop
		CompactRaidFrameManager_UpdateOptionsFlowContainer = K.Noop
	end

	Advanced_UseUIScale:Kill()
	Advanced_UIScaleSlider:Kill()

	if (C["Cooldown"].Enable) then
		SetCVar("countdownForCooldowns", 0)
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
	end

	if (C["Unitframe"].Enable) then
		if (K.Class == "DEATHKNIGHT") then
			RuneFrame:Kill()
		end

		K.KillMenuOption(true, "InterfaceOptionsCombatPanelTargetOfTarget")

		if (InterfaceOptionsUnitFramePanelPartyBackground) then
			InterfaceOptionsUnitFramePanelPartyBackground:Hide()
			InterfaceOptionsUnitFramePanelPartyBackground:SetAlpha(0)
		end

		if (PartyMemberBackground) then
			PartyMemberBackground:SetParent(K.UIFrameHide)
			PartyMemberBackground:Hide()
			PartyMemberBackground:SetAlpha(0)
		end
	end

	if (C["General"].DisableTutorialButtons) then
		BagHelpBox:Kill()
		HelpOpenTicketButtonTutorial:Kill()
		PremadeGroupsPvETutorialAlert:Kill()
		ReagentBankHelpBox:Kill()
		TutorialFrameAlertButton:Kill()
		SpellBookFrameTutorialButton:Kill()
		WorldMapFrameTutorialButton:Kill()

		if PetJournalTutorialButton then
			PetJournalTutorialButton:Kill()
		end

		if (PlayerTalentFrame) then
			PlayerTalentFrameSpecializationTutorialButton:Kill()
			PlayerTalentFrameTalentsTutorialButton:Kill()
			PlayerTalentFramePetSpecializationTutorialButton:Kill()
		end

		HelpPlate:Kill()
		HelpPlateTooltip:Kill()

		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)
	end

	if (C["ActionBar"].Enable) then
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
	end

	if (C["Nameplates"].Enable) then
		SetCVar("ShowClassColorInNameplate", 1)
		-- Hide these options, because we will do it from KkthnxUI settings.
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesMakeLarger")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesAggroFlash")
	end

	if (C["Minimap"].Enable) then
		K.KillMenuOption(true, "InterfaceOptionsDisplayPanelRotateMinimap")
	end

	if (C["Inventory"].Enable) then
		SetSortBagsRightToLeft(true)
		SetInsertItemsLeftToRight(false)
	end

	if (not C["Unitframe"].Party) and (not C["Raid"].Enable) then
		C["Raid"].RaidUtility = false
	end
end

function Module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED")
end