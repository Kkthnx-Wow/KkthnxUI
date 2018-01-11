local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DisableBlizzard", "AceEvent-3.0")

-- Lua API
local _G = _G

-- Wow API
local CompactRaidFrameManager_GetSetting = _G.CompactRaidFrameManager_GetSetting
local CompactRaidFrameManager_SetSetting = _G.CompactRaidFrameManager_SetSetting
local CompactRaidFrameManager_UpdateShown = _G.CompactRaidFrameManager_UpdateShown
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local StaticPopup_Show =_G.StaticPopup_Show
local UIParent = _G.UIParent

-- Kill all stuff on default UI that we don"t need
local function HideRaid()
	if InCombatLockdown() then return end
	CompactRaidFrameManager:Kill()
	local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

function Module:DisableBlizzard()
	if (not C["Unitframe"].Enable) and (not C["Raidframe"].Enable) then return end
	if not CompactRaidFrameManager_UpdateShown then
		StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
	else
		if not CompactRaidFrameManager.hookedHide then
			hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
			CompactRaidFrameManager:HookScript("OnShow", HideRaid)
			CompactRaidFrameManager.hookedHide = true
		end
		CompactRaidFrameContainer:UnregisterAllEvents()

		HideRaid()
	end
end

function Module:ControlBlizzard()
	if C["General"].AutoScale then
		K.KillMenuOption(true, "Advanced_UseUIScale")
		K.KillMenuOption(true, "Advanced_UIScaleSlider")
	end

	if C["Cooldown"].Enable then
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
	end

	if C["General"].DisableTutorialButtons then
		if MainMenuBarDownload then
			MainMenuBarDownload:Kill()
		end

		BagHelpBox:Kill()
		CollectionsMicroButtonAlert:Kill()
		EJMicroButtonAlert:Kill()
		GuildMicroButtonTabard:Kill()
		HelpOpenTicketButtonTutorial:Kill()
		HelpPlate:Kill()
		HelpPlateTooltip:Kill()
		MainMenuBarPerformanceBar:Kill()
		MicroButtonPortrait:Kill()
		PremadeGroupsPvETutorialAlert:Kill()
		ReagentBankHelpBox:Kill()
		SpellBookFrameTutorialButton:Kill()
		TalentMicroButtonAlert:Kill()
		TutorialFrameAlertButton:Kill()
		WorldMapFrameTutorialButton:Kill()
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

	if C["Bags"].Enable then
		SetSortBagsRightToLeft(true)
		SetInsertItemsLeftToRight(false)
	end

	if (not C["Unitframe"].Party) and (not C["Raidframe"].Enable) then
		C["Raidframe"].RaidUtility = false
	end
end

function Module:OnInitialize()
	self:ControlBlizzard()
	K.KillMenuPanel(10, "InterfaceOptionsFrameCategoriesButton")

	if C["Raidframe"].Enable == true then
		self:DisableBlizzard()
		self:RegisterEvent("GROUP_ROSTER_UPDATE", "DisableBlizzard")
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
	else
		CompactUnitFrameProfiles:RegisterEvent("VARIABLES_LOADED")
		UIParent:RegisterEvent("GROUP_ROSTER_UPDATE") -- We need to register this if people want to use default blizz raid frames.
	end
end
