local K, C, L = unpack(select(2, ...))

local _G = _G

local SetCVar = _G.SetCVar
local SetInsertItemsLeftToRight = _G.SetInsertItemsLeftToRight
local SetSortBagsRightToLeft = _G.SetSortBagsRightToLeft

local KillBlizzy = CreateFrame("Frame")
KillBlizzy:RegisterEvent("PLAYER_LOGIN")
KillBlizzy:RegisterEvent("ADDON_LOADED")
KillBlizzy:SetScript("OnEvent", function(_, event)
	if (event == "PLAYER_LOGIN") then
		if (C["Raid"].Enable) then
			InterfaceOptionsFrameCategoriesButton10:SetHeight(0.00001)
			InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)

			if CompactRaidFrameManager then
				CompactRaidFrameManager:SetParent(K.UIFrameHider)
			end

			if CompactUnitFrameProfiles then
				CompactUnitFrameProfiles:UnregisterAllEvents()
			end

			for i = 1, MAX_PARTY_MEMBERS do
				local PartyMember = _G["PartyMemberFrame" .. i]
				local Health = _G["PartyMemberFrame" .. i .. "HealthBar"]
				local Power = _G["PartyMemberFrame" .. i .. "ManaBar"]
				local Pet = _G["PartyMemberFrame" .. i .."PetFrame"]
				local PetHealth = _G["PartyMemberFrame" .. i .."PetFrame" .. "HealthBar"]

				PartyMember:UnregisterAllEvents()
				PartyMember:SetParent(K.UIFrameHider)
				PartyMember:Hide()
				Health:UnregisterAllEvents()
				Power:UnregisterAllEvents()

				Pet:UnregisterAllEvents()
				Pet:SetParent(K.UIFrameHider)
				PetHealth:UnregisterAllEvents()

				HidePartyFrame()
				ShowPartyFrame = K.Noop
				HidePartyFrame = K.Noop
			end
		end

		if (C["Unitframe"].Enable) then
			for i = 1, MAX_BOSS_FRAMES do
				local Boss = _G["Boss"..i.."TargetFrame"]
				local Health = _G["Boss"..i.."TargetFrame".."HealthBar"]
				local Power = _G["Boss"..i.."TargetFrame".."ManaBar"]

				Boss:UnregisterAllEvents()
				Boss.Show = K.Noop
				Boss:Hide()

				Health:UnregisterAllEvents()
				Power:UnregisterAllEvents()
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

		if C["General"].AutoScale then
			Advanced_UseUIScale:Kill()
			Advanced_UIScaleSlider:Kill()
		end

		if (C["Cooldown"].Enable) then
			SetCVar("countdownForCooldowns", 0)
			K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
		end

		if (C["General"].DisableTutorialButtons) then
			BagHelpBox:UnregisterAllEvents()
			BagHelpBox:SetParent(K.UIFrameHider)
			BagHelpBox:Hide()

			HelpOpenTicketButtonTutorial:UnregisterAllEvents()
			HelpOpenTicketButtonTutorial:SetParent(K.UIFrameHider)
			HelpOpenTicketButtonTutorial:Hide()

			PremadeGroupsPvETutorialAlert:UnregisterAllEvents()
			PremadeGroupsPvETutorialAlert:SetParent(K.UIFrameHider)
			PremadeGroupsPvETutorialAlert:Hide()

			ReagentBankHelpBox:UnregisterAllEvents()
			ReagentBankHelpBox:SetParent(K.UIFrameHider)
			ReagentBankHelpBox:Hide()

			TutorialFrameAlertButton:UnregisterAllEvents()
			TutorialFrameAlertButton:SetParent(K.UIFrameHider)
			TutorialFrameAlertButton:Hide()

			SpellBookFrameTutorialButton:UnregisterAllEvents()
			SpellBookFrameTutorialButton:SetParent(K.UIFrameHider)
			SpellBookFrameTutorialButton:Hide()

			WorldMapFrameTutorialButton:UnregisterAllEvents()
			WorldMapFrameTutorialButton:SetParent(K.UIFrameHider)
			WorldMapFrameTutorialButton:Hide()

			if PetJournalTutorialButton then
				PetJournalTutorialButton:UnregisterAllEvents()
				PetJournalTutorialButton:SetParent(K.UIFrameHider)
				PetJournalTutorialButton:Hide()
			end

			HelpPlate:UnregisterAllEvents()
			HelpPlate:SetParent(K.UIFrameHider)
			HelpPlate:Hide()

			HelpPlateTooltip:UnregisterAllEvents()
			HelpPlateTooltip:SetParent(K.UIFrameHider)
			HelpPlateTooltip:Hide()

			if (PlayerTalentFrame) then
				PlayerTalentFrameSpecializationTutorialButton:UnregisterAllEvents()
				PlayerTalentFrameSpecializationTutorialButton:SetParent(K.UIFrameHider)
				PlayerTalentFrameSpecializationTutorialButton:Hide()

				PlayerTalentFrameTalentsTutorialButton:UnregisterAllEvents()
				PlayerTalentFrameTalentsTutorialButton:SetParent(K.UIFrameHider)
				PlayerTalentFrameTalentsTutorialButton:Hide()

				PlayerTalentFramePetSpecializationTutorialButton:UnregisterAllEvents()
				PlayerTalentFramePetSpecializationTutorialButton:SetParent(K.UIFrameHider)
				PlayerTalentFramePetSpecializationTutorialButton:Hide()
			end
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

		if not C["Party"].Enable and not C["Raid"].Enable then
			C["Raid"].RaidUtility = false
		end
	end
end)