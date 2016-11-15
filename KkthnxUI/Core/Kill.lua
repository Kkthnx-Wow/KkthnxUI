local K, C, L = select(2, ...):unpack()

-- Wow API
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local SetCVar = SetCVar

-- Kill all stuff on default UI that we don"t need
local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("PLAYER_LOGIN")
DisableBlizzard:SetScript("OnEvent", function(self, event)
	if addon == "Blizzard_AchievementUI" then
		if C.Tooltip.Enable then
			hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
		end
	end

	if C.Unitframe.Enable then
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
		if (not InCombatLockdown()) then
			if ((LoadAddOn("Blizzard_CUFProfiles") or LoadAddOn("Blizzard_CompactRaidFrames"))) then
				DisableAddOn("Blizzard_CUFProfiles")
				DisableAddOn("Blizzard_CompactRaidFrames")
			end
		end

		InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
		InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)

		if (CompactRaidFrameManager) then
			CompactRaidFrameManager:SetParent(UIFrameHider)
		end

		if (CompactUnitFrameProfiles) then
			CompactUnitFrameProfiles:UnregisterAllEvents()
		end

		for i = 1, MAX_PARTY_MEMBERS do
			_G["PartyMemberFrame"..i]:UnregisterAllEvents()
			_G["PartyMemberFrame"..i]:SetParent(UIFrameHider)
			_G["PartyMemberFrame"..i]:Hide()
			_G["PartyMemberFrame"..i.."HealthBar"]:UnregisterAllEvents()
			_G["PartyMemberFrame"..i.."ManaBar"]:UnregisterAllEvents()
			_G["PartyMemberFrame"..i.."PetFrame"]:UnregisterAllEvents()
			_G["PartyMemberFrame"..i.."PetFrame"]:SetParent(UIFrameHider)
			_G["PartyMemberFrame"..i.."PetFrame".."HealthBar"]:UnregisterAllEvents()

			HidePartyFrame()
			ShowPartyFrame = K.Noop
			HidePartyFrame = K.Noop
		end
	end

	InterfaceOptionsFrameCategoriesButton9:SetHeight(0.00001)
	InterfaceOptionsFrameCategoriesButton9:SetAlpha(0)
	InterfaceOptionsFrameCategoriesButton10:SetHeight(0.00001)
	InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)

	if C.Minimap.Garrison == true then
		GarrisonLandingPageTutorialBox:Kill()
	end
	HelpOpenTicketButtonTutorial:Kill()
	HelpPlate:Kill()
	HelpPlateTooltip:Kill()
	TalentMicroButtonAlert:Kill()
	EJMicroButtonAlert:Kill()

	if C.Unitframe.Enable then
		InterfaceOptionsCombatPanelTargetOfTarget:Kill()
		SetCVar("showPartyBackground", 0)
	end

	if C.Cooldown.Enable then
		SetCVar("countdownForCooldowns", 0)
		InterfaceOptionsActionBarsPanelCountdownCooldowns:Kill()
	end

	if C.Nameplates.Enable then
		SetCVar("ShowClassColorInNameplate", 1)
	end

	if C.Chat.Enable then
		SetCVar("chatStyle", "im")
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
end)
