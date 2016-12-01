local K, C, L = select(2, ...):unpack()

-- Wow API
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local SetCVar = SetCVar

-- Kill all stuff on default UI that we don"t need
local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("ADDON_LOADED")
DisableBlizzard:SetScript("OnEvent", function(self, event)
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
	end

	if C.Raidframe.Enable then
		InterfaceOptionsFrameCategoriesButton10:SetHeight(0.00001)
		InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)

		if CompactRaidFrameManager then
			CompactRaidFrameManager:SetParent(UIFrameHider)
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
			PartyMember:SetParent(UIFrameHider)
			PartyMember:Hide()
			Health:UnregisterAllEvents()
			Power:UnregisterAllEvents()

			Pet:UnregisterAllEvents()
			Pet:SetParent(UIFrameHider)
			PetHealth:UnregisterAllEvents()

			HidePartyFrame()
			ShowPartyFrame = K.Noop
			HidePartyFrame = K.Noop
		end
	end

	if C.Minimap.Garrison == true then
		GarrisonLandingPageTutorialBox:Kill()
	end

	if not UnitAffectingCombat("player") then
		Advanced_UIScaleSlider:Kill()
		Advanced_UseUIScale:Kill()
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
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)
	end

	if C.Unitframe.Enable then
		InterfaceOptionsCombatPanelTargetOfTarget:Kill()
		SetCVar("showPartyBackground", 0)
	end

	if C.Cooldown.Enable then
		SetCVar("countdownForCooldowns", 0)
		InterfaceOptionsActionBarsPanelCountdownCooldowns:Hide()
	end

	if C.Nameplates.Enable then
		SetCVar("ShowClassColorInNameplate", 1)
		-- Hide the option to rescale, because we will do it from KkthnxUI settings.
		InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Hide()
	end

	if C.Chat.Enable then
		SetCVar("chatStyle", "im")
	end

	if C.Minimap.Enable then
		InterfaceOptionsDisplayPanelRotateMinimap:Hide()
	end

	if C.ActionBar.Enable then
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
	end
end)