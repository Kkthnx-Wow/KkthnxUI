local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Kill", "AceEvent-3.0")

function Module:ADDON_LOADED(event, addon)
	if (addon == "Blizzard_AchievementUI") then
		if C["Tooltip"].Enable then
			hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
		end
	end

	if C["Raidframe"].Enable then
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

	if C["General"].AutoScale then
		Advanced_UseUIScale:Disable()
		Advanced_UIScaleSlider:Disable()
		getglobal(Advanced_UseUIScale:GetName().."Text"):SetTextColor(1, 0, 0, 1)
		getglobal(Advanced_UIScaleSlider:GetName().."Text"):SetTextColor(1, 0, 0, 1)
		getglobal(Advanced_UseUIScale:GetName().."Text"):SetText("'UI Scale' is unavailable while Auto Scale is active. Click the button below for options.")
		Advanced_UseUIScaleText:SetPoint("LEFT", Advanced_UseUIScale, "LEFT", 4, -40)
	end

	if C["General"].DisableTutorialButtons then
		BagHelpBox:Kill()
		CollectionsMicroButtonAlert:Kill()
		EJMicroButtonAlert:Kill()
		HelpOpenTicketButtonTutorial:Kill()
		PremadeGroupsPvETutorialAlert:Kill()
		ReagentBankHelpBox:Kill()
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_APPEARANCE_TAB, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_KNOWLEDGE, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BAG_SETTINGS, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BONUS_ROLL_ENCOUNTER_JOURNAL_LINK, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BOOSTED_SPELL_BOOK, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BOUNTY_FINISHED, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BOUNTY_INTRO, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CLEAN_UP_BAGS, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CORE_ABILITITES, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FRIENDS_LIST_QUICK_JOIN, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GAME_TIME_AUCTION_HOUSE, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_LANDING, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_MISSION_LIST, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_MISSION_PAGE, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_ZONE_ABILITY, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GLYPH, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL_LEVEL, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HEIRLOOM_JOURNAL_TAB, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HONOR_TALENT_FIRST_TALENT, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HONOR_TALENT_HONOR_LEVELS, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HONOR_TALENT_PRESTIGE, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_IGNORE_QUEST, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_INVENTORY_FIXUP_CHECK_EXPANSION_LEGION, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_INVENTORY_FIXUP_EXPANSION_LEGION, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_LFG_LIST, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSIONS, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_REAGENT_BANK_UNLOCK, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SPEC, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SPELLBOOK, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TALENT, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_FAVORITE, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TOYBOX_MOUSEWHEEL_PAGING, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_JOURNAL_TAB, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_MODEL_CLICK, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_OUTFIT_DROPDOWN, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_TRANSMOG_SPECS_BUTTON, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_VIEWABLE_ARTIFACT, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WHAT_HAS_CHANGED, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WRAPPED_COLLECTION_ITEMS, true)
		TalentMicroButtonAlert:Kill()
		TutorialFrameAlertButton:Kill()
	end

	if C["Cooldown"].Enable then
		SetCVar("countdownForCooldowns", 0)
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
	end

	if C["Chat"].Enable then
		SetCVar("chatStyle", "im")
	end

	if C["Unitframe"].Enable then
		if (K.Class == "DEATHKNIGHT") then
			RuneFrame:Kill()
		end
		K.KillMenuOption(true, "InterfaceOptionsCombatPanelTargetOfTarget")
		SetCVar("showPartyBackground", 0)
	end

	if C["Auras"].Enable then
		BuffFrame:Kill()
		TemporaryEnchantFrame:Kill()
		K.KillMenuPanel(12, "InterfaceOptionsFrameCategoriesButton")
	end

	if C["ActionBar"].Enable then
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
	end

	if C["Nameplates"].Enable then
		SetCVar("ShowClassColorInNameplate", 1)
		-- Hide these options, because we will do it from KkthnxUI settings.
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesMakeLarger")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesAggroFlash")
	end

	if C["Minimap"].Enable then
		K.KillMenuOption(true, "InterfaceOptionsDisplayPanelRotateMinimap")
	end

	if C["Inventory"].Enable then
		SetSortBagsRightToLeft(true)
		SetInsertItemsLeftToRight(false)
	end

	if (not C["Unitframe"].Party) and (not C["Raidframe"].Enable) then
		C["Raidframe"].RaidUtility = false
	end
end

function Module:OnInitialize()
	self:RegisterEvent("ADDON_LOADED")
end