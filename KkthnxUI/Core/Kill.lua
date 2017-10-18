local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DisableBlizzard", "AceEvent-3.0")

-- Lua API
local _G = _G

-- Wow API
local CompactRaidFrameManager_UpdateShown = _G.CompactRaidFrameManager_UpdateShown
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local StaticPopup_Show = _G.StaticPopup_Show
local MAX_PARTY_MEMBERS = _G.MAX_PARTY_MEMBERS
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES
local UIParent = _G.UIParent

-- Kill all stuff on default UI that we don't need
function Module:KillStuff(addon)
	if addon == "Blizzard_AchievementUI" then
		if C["Tooltip"].Enable then
			hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
		end
	end

	if C["Raidframe"].Enable then
		if not CompactRaidFrameManager_UpdateShown then
			StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
		else
			K.KillMenuPanel(10, "InterfaceOptionsFrameCategoriesButton")

			if CompactRaidFrameManager then
				CompactRaidFrameManager:UnregisterAllEvents()
				CompactRaidFrameManager:SetParent(K.UIFrameHider)
			end

			if CompactUnitFrameProfiles then
				CompactUnitFrameProfiles:UnregisterAllEvents()
			end
		end
	end

	if C["Unitframe"].Enable then
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

		for i = 1, MAX_PARTY_MEMBERS do
			local PartyMember = _G["PartyMemberFrame" .. i]
			local Health = _G["PartyMemberFrame"..i.."HealthBar"]
			local Power = _G["PartyMemberFrame"..i.."ManaBar"]
			local Pet = _G["PartyMemberFrame" ..i.."PetFrame"]
			local PetHealth = _G["PartyMemberFrame" ..i.."PetFrame".."HealthBar"]

			PartyMember:UnregisterAllEvents()
			PartyMember:SetParent(K.UIFrameHider)
			PartyMember:Hide()
			Health:UnregisterAllEvents()
			Power:UnregisterAllEvents()

			Pet:UnregisterAllEvents()
			Pet:SetParent(K.UIFrameHider)
			PetHealth:UnregisterAllEvents()

			if (not InCombatLockdown()) then
				HidePartyFrame()
				ShowPartyFrame = K.Noop
				HidePartyFrame = K.Noop
			end
		end

	end

	if C["General"].AutoScale then
		K.KillMenuOption(true, "Advanced_UseUIScale")
		K.KillMenuOption(true, "Advanced_UIScaleSlider")
	end

	if C["Cooldown"].Enable then
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
	end

	if C["General"].DisableTutorialButtons then
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

	-- Kill off the game menu button latency display
	if MainMenuBarPerformanceBar then
		MainMenuBarPerformanceBar:Hide()
		MainMenuBarPerformanceBar:SetParent(K.UIFrameHider)
	end

	if C["Unitframe"].Enable then
		K.KillMenuOption(true, "InterfaceOptionsCombatPanelTargetOfTarget")
	end

	if C["Auras"].Enable then
		BuffFrame:Kill()
		TemporaryEnchantFrame:Kill()
		K.KillMenuPanel(12, "InterfaceOptionsFrameCategoriesButton")
	end

	if C["Nameplates"].Enable then
		-- Hide these options, because we will do it from KkthnxUI settings.
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesMakeLarger")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesAggroFlash")
	end

	if C["ActionBar"].Enable then
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:EnableMouse(false)
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

	if C["Minimap"].Enable then
		K.KillMenuOption(true, "InterfaceOptionsDisplayPanelRotateMinimap")
	end
end

function Module:OnEnable()
	Module:KillStuff()
end

function Module:OnDisable()

end