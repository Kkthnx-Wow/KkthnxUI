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

-- Kill all stuff on default UI that we don"t need
local function HideRaid()
	if InCombatLockdown() then return end
	CompactRaidFrameManager:SetParent(K.UIFrameHider)
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

function Module:ADDON_LOADED(_, addon)
	if addon ~= "Blizzard_ArenaUI" then return end
	Module:DisableBlizzard("arena")
	self:UnregisterEvent("ADDON_LOADED")
end

function Module:DisableMisc()
	if C["General"].AutoScale then
		K.KillMenuOption(true, "Advanced_UseUIScale")
		K.KillMenuOption(true, "Advanced_UIScaleSlider")
	end

	if C["Cooldown"].Enable then
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
	end

	if C["General"].DisableTutorialButtons then
		for i = 1, #MICRO_BUTTONS do
            if  _G[MICRO_BUTTONS[i]] then
                _G[MICRO_BUTTONS[i]]:SetParent(K.UIFrameHider)
            end
		end

		if MainMenuBarDownload then
			MainMenuBarDownload:SetParent(K.UIFrameHider)
		end

		BagHelpBox:SetParent(K.UIFrameHider)
		CollectionsMicroButtonAlert:SetParent(K.UIFrameHider)
		EJMicroButtonAlert:SetParent(K.UIFrameHider)
		HelpOpenTicketButtonTutorial:SetParent(K.UIFrameHider)
		HelpPlate:SetParent(K.UIFrameHider)
		HelpPlateTooltip:SetParent(K.UIFrameHider)
		MicroButtonPortrait:SetParent(K.UIFrameHider)
		PremadeGroupsPvETutorialAlert:SetParent(K.UIFrameHider)
		ReagentBankHelpBox:SetParent(K.UIFrameHider)
		SpellBookFrameTutorialButton:SetParent(K.UIFrameHider)
		TalentMicroButtonAlert:SetParent(K.UIFrameHider)
		TutorialFrameAlertButton:SetParent(K.UIFrameHider)
		WorldMapFrameTutorialButton:SetParent(K.UIFrameHider)
        GuildMicroButtonTabard:SetParent(K.UIFrameHider)
        MainMenuBarPerformanceBar:SetParent(K.UIFrameHider)
        TalentMicroButtonAlert:SetParent(K.UIFrameHider)
	end

	if C["Unitframe"].Enable then
		K.KillMenuOption(true, "InterfaceOptionsCombatPanelTargetOfTarget")
	end

	if C["Auras"].Enable then
		BuffFrame:SetParent(K.UIFrameHider)
		TemporaryEnchantFrame:SetParent(K.UIFrameHider)
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
	self:DisableMisc()
	K.KillMenuPanel(10, "InterfaceOptionsFrameCategoriesButton")

	if C["Raidframe"].Enable == true then
		self:DisableBlizzard()
		self:RegisterEvent("GROUP_ROSTER_UPDATE", "DisableBlizzard")
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE") -- This may fuck shit up.. we"ll see...
	else
		CompactUnitFrameProfiles:RegisterEvent("VARIABLES_LOADED")
	end

	if (not C["Unitframe"].Party) and (not C["Raidframe"].Enable) then
		C["Raidframe"].RaidUtility = false
	end

	if C["Unitframe"].Arena then
		self:SecureHook("UnitFrameThreatIndicator_Initialize")

		if not IsAddOnLoaded("Blizzard_ArenaUI") then
			self:RegisterEvent("ADDON_LOADED")
		else
			Module:DisableBlizzard("arena")
		end
	end
end