local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Kill", "AceEvent-3.0")

function Module:ADDON_LOADED(event, addon)
	if addon == "Blizzard_AchievementUI" then
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
		K.KillMenuOption(true, "Advanced_UseUIScale")
		K.KillMenuOption(true, "Advanced_UIScaleSlider")
	end

	if C["General"].DisableTutorialButtons then
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
	end

	if C["Cooldown"].Enable then
		SetCVar("countdownForCooldowns", 0)
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
	end

	if C["Chat"].Enable then
		SetCVar("chatStyle", "im")
	end

	if C["Unitframe"].Enable then
		if K.Class == "DEATHKNIGHT" then
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
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
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

	if C["Bags"].Enable then
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
