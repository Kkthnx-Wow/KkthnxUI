-- Gui for KkthnxUI (by fernir, tukz and tohveli, shestak)
local K, C, L

local _G = _G
local unpack = unpack
local sub = string.sub
local max = math.max
local print = print
local format = string.format
local pairs, type = pairs, type

local CreateFrame = CreateFrame
local Locale = GetLocale()
local name = UnitName("player")
local realm = GetRealmName()

if (Locale == "enGB") then
	Locale = "enUS"
end

Print = function(...)
	print("|cff3c9bedKkthnxUI_Config|r:", ...)
end

local ALLOWED_GROUPS = {
	["General"] = 1,
	["ActionBar"] = 2,
	["Announcements"] = 3,
	["Auras"] = 4,
	["Automation"] = 5,
	["Bags"] = 6,
	["Blizzard"] = 7,
	["Chat"] = 8,
	["Cooldown"] = 9,
	["DataBars"] = 10,
	["DataText"] = 11,
	["Filger"] = 12,
	["Loot"] = 13,
	["Minimap"] = 14,
	["Misc"] = 15,
	["Nameplates"] = 16,
	["PulseCD"] = 17,
	["RaidCD"] = 18,
	["Raidframe"] = 19,
	["Skins"] = 20,
	["Tooltip"] = 21,
	["Unitframe"] = 22,
	["WorldMap"] = 23,
}

local function Local(Option)
	local K = KkthnxUI[1]

	-- Actionbar Settings
	if Option == "UIConfigActionBar" then Option = ACTIONBAR_LABEL end
	if Option == "UIConfigActionBarBottomBars" then Option = L_GUI_ACTIONBAR_BOTTOMBARS end
	if Option == "UIConfigActionBarButtonSize" then Option = L_GUI_ACTIONBAR_BUTTON_SIZE end
	if Option == "UIConfigActionBarButtonSpace" then Option = L_GUI_ACTIONBAR_BUTTON_SPACE end
	if Option == "UIConfigActionBarEnable" then Option = L_GUI_ACTIONBAR_ENABLE end
	if Option == "UIConfigActionBarEquipBorder" then Option = L_GUI_ACTIONBAR_EQUIP_BORDER end
	if Option == "UIConfigActionBarGrid" then Option = L_GUI_ACTIONBAR_GRID end
	if Option == "UIConfigActionBarHideHighlight" then Option = L_GUI_ACTIONBAR_HIDE_HIGHLIGHT end
	if Option == "UIConfigActionBarHotkey" then Option = L_GUI_ACTIONBAR_HOTKEY end
	if Option == "UIConfigActionBarMacro" then Option = L_GUI_ACTIONBAR_MACRO end
	if Option == "UIConfigActionBarOutOfMana" then Option = L_GUI_ACTIONBAR_OUT_OF_MANA end
	if Option == "UIConfigActionBarOutOfRange" then Option = L_GUI_ACTIONBAR_OUT_OF_RANGE end
	if Option == "UIConfigActionBarPetBarHide" then Option = L_GUI_ACTIONBAR_PETBAR_HIDE end
	if Option == "UIConfigActionBarPetBarHorizontal" then Option = L_GUI_ACTIONBAR_PETBAR_HORIZONTAL end
	if Option == "UIConfigActionBarRightBars" then Option = L_GUI_ACTIONBAR_RIGHTBARS end
	if Option == "UIConfigActionBarSelfCast" then Option = L_GUI_ACTIONBAR_SELFCAST end
	if Option == "UIConfigActionBarSplitBars" then Option = L_GUI_ACTIONBAR_SPLIT_BARS end
	if Option == "UIConfigActionBarStanceBarHide" then Option = L_GUI_ACTIONBAR_STANCEBAR_HIDE end
	if Option == "UIConfigActionBarStanceBarHorizontal" then Option = L_GUI_ACTIONBAR_STANCEBAR_HORIZONTAL end
	if Option == "UIConfigActionBarToggleMode" then Option = L_GUI_ACTIONBAR_TOGGLE_MODE end
	if Option == "UIConfigActionBarPetBarMouseover" then Option = L_GUI_ACTIONBAR_PETBAR_MOUSEOVER end
	if Option == "UIConfigActionBarRightBarsMouseover" then Option = L_GUI_ACTIONBAR_RIGHTBARS_MOUSEOVER end
	if Option == "UIConfigActionBarStanceBarMouseover" then Option = L_GUI_ACTIONBAR_STANCEBAR_MOUSEOVER end

	-- Announcement Settings
	if Option == "UIConfigAnnouncements" then Option = L_GUI_ANNOUNCEMENTS end
	if Option == "UIConfigAnnouncementsBadGear" then Option = L_GUI_ANNOUNCEMENTS_BAD_GEAR end
	if Option == "UIConfigAnnouncementsInterrupt" then Option = L_GUI_ANNOUNCEMENTS_INTERRUPT end
	if Option == "UIConfigAnnouncementsPullCountdown" then Option = L_GUI_ANNOUNCEMENTS_PULL_COUNTDOWN end
	if Option == "UIConfigAnnouncementsSaySapped" then Option = L_GUI_ANNOUNCEMENTS_SAY_SAPPED end
	if Option == "UIConfigAnnouncementsSpells" then Option = L_GUI_ANNOUNCEMENTS_SPELLS end
	if Option == "UIConfigAnnouncementsSpellsFromAll" then Option = L_GUI_ANNOUNCEMENTS_SPELLS_FROM_ALL end
	if Option == "UIConfigAnnouncementsToys" then Option = L_GUI_ANNOUNCEMENTS_TOY_TRAIN end

	-- Automation Settings
	if Option == "UIConfigAutomation" then Option = L_GUI_AUTOMATION end
	if Option == "UIConfigAutomationAutoCollapse" then Option = L_GUI_AUTOMATION_AUTOCOLLAPSE end
	if Option == "UIConfigAutomationAutoInvite" then Option = L_GUI_AUTOMATION_ACCEPTINVITE end
	if Option == "UIConfigAutomationDeclineDuel" then Option = L_GUI_AUTOMATION_DECLINEDUEL end
	if Option == "UIConfigAutomationLoggingCombat" then Option = L_GUI_AUTOMATION_LOGGING_COMBAT end
	if Option == "UIConfigAutomationNoBanner" then Option = L_GUI_AUTOMATION_NO_BANNER end
	if Option == "UIConfigAutomationResurrection" then Option = L_GUI_AUTOMATION_RESURRECTION end
	if Option == "UIConfigAutomationScreenShot" then Option = L_GUI_AUTOMATION_SCREENSHOT end
	if Option == "UIConfigAutomationTabBinder" then Option = L_GUI_AUTOMATION_TAB_BINDER end

	-- Bag Settings
	if Option == "UIConfigBags" then Option = L_GUI_BAGS end
	if Option == "UIConfigBagsBagFilter" then Option = L_GUI_BAGS_BAG_FILTER end
	if Option == "UIConfigBagsSortRightToLeft" then Option = L_GUI_BAGS_SORT_RIGHTTOLEFT end
	if Option == "UIConfigBagsButtonSize" then Option = L_GUI_BAGS_BUTTON_SIZE end
	if Option == "UIConfigBagsEnable" then Option = L_GUI_BAGS_ENABLE end
	if Option == "UIConfigBagsInsertLeftToRight" then Option = L_GUI_BAGS_INSERT_LEFTTORIGHT end
	if Option == "UIConfigBagsItemsPerRow" then Option = L_GUI_BAGS_ITEMS_PER_ROW end
	if Option == "UIConfigBagsPulseNewItem" then Option = L_GUI_BAGS_PULSE_NEW_ITEMS end
	if Option == "UIConfigBagsSpacing" then Option = L_GUI_BAGS_SPACING end

	-- Blizzard Settings
	if Option == "UIConfigBlizzard" then Option = L_GUI_BLIZZARD end
	if Option == "UIConfigBlizzardClassColor" then Option = L_GUI_BLIZZARD_CLASS_COLOR end
	if Option == "UIConfigBlizzardColorTextures" then Option = L_GUI_BLIZZARD_COLOR_TEXTURES end
	if Option == "UIConfigBlizzardVehicleMouseover" then Option = L_GUI_BLIZZARD_VEHICLE_MOUSEOVER end
	if Option == "UIConfigBlizzardEasyDelete" then Option = L_GUI_BLIZZARD_EASYDELETE end
	if Option == "UIConfigBlizzardReplaceBlizzardFonts" then Option = L_GUI_BLIZZARD_REPLACE_BLIZZARD_FONTS end
	if Option == "UIConfigBlizzardReputationGain" then Option = L_GUI_BLIZZARD_REPUTATIONGAIN end
	if Option == "UIConfigBlizzardTexturesColor" then Option = L_GUI_BLIZZARD_TEXTURES_COLOR end

	-- DataBar Settings
	if Option == "UIConfigDataBars" then Option = L_GUI_DATABARS end
	if Option == "UIConfigDataBarsArtifactColor" then Option = L_GUI_DATABARS_ARTIFACT_COLOR end
	if Option == "UIConfigDataBarsArtifactEnable" then Option = L_GUI_DATABARS_ARTIFACT_ENABLE end
	if Option == "UIConfigDataBarsArtifactFade" then Option = L_GUI_DATABARS_ARTIFACT_FADE end
	if Option == "UIConfigDataBarsArtifactHeight" then Option = L_GUI_DATABARS_ARTIFACT_HEIGHT end
	if Option == "UIConfigDataBarsArtifactWidth" then Option = L_GUI_DATABARS_ARTIFACT_WIDTH end
	if Option == "UIConfigDataBarsExperienceColor" then Option = L_GUI_DATABARS_EXPERIENCE_COLOR end
	if Option == "UIConfigDataBarsExperienceEnable" then Option = L_GUI_DATABARS_EXPERIENCE_ENABLE end
	if Option == "UIConfigDataBarsExperienceFade" then Option = L_GUI_DATABARS_EXPERIENCE_FADE end
	if Option == "UIConfigDataBarsExperienceHeight" then Option = L_GUI_DATABARS_EXPERIENCE_HEIGHT end
	if Option == "UIConfigDataBarsExperienceRestedColor" then Option = L_GUI_DATABARS_EXPERIENCE_REST_COLOR end
	if Option == "UIConfigDataBarsExperienceWidth" then Option = L_GUI_DATABARS_EXPERIENCE_WIDTH end
	if Option == "UIConfigDataBarsHonorColor" then Option = L_GUI_DATABARS_HONOR_COLOR end
	if Option == "UIConfigDataBarsHonorEnable" then Option = L_GUI_DATABARS_HONOR_ENABLE end
	if Option == "UIConfigDataBarsHonorFade" then Option = L_GUI_DATABARS_HONOR_FADE end
	if Option == "UIConfigDataBarsHonorHeight" then Option = L_GUI_DATABARS_HONOR_HEIGHT end
	if Option == "UIConfigDataBarsHonorWidth" then Option = L_GUI_DATABARS_HONOR_WIDTH end
	if Option == "UIConfigDataBarsReputationEnable" then Option = L_GUI_DATABARS_REPUTATION_ENABLE end
	if Option == "UIConfigDataBarsReputationFade" then Option = L_GUI_DATABARS_REPUTATION_FADE end
	if Option == "UIConfigDataBarsReputationHeight" then Option = L_GUI_DATABARS_REPUTATION_HEIGHT end
	if Option == "UIConfigDataBarsReputationWidth" then Option = L_GUI_DATABARS_REPUTATION_WIDTH end

	-- Auras Settings
	if Option == "UIConfigAuras" then Option = L_GUI_AURAS end
	if Option == "UIConfigAurasEnable" then Option = L_GUI_AURAS_ENABLE end
	if Option == "UIConfigAurasConsolidate" then Option = L_GUI_AURAS_CONSOLIDATE end
	if Option == "UIConfigAurasFlash" then Option = L_GUI_AURAS_FLASH end
	if Option == "UIConfigAurasHideBuffs" then Option = L_GUI_AURAS_HIDE_BUFFS end
	if Option == "UIConfigAurasHideDebuffs" then Option = L_GUI_AURAS_HIDE_DEBUFFS end
	if Option == "UIConfigAurasAnimation" then Option = L_GUI_AURAS_ANIMATION end
	if Option == "UIConfigAurasBuffsPerRow" then Option = L_GUI_AURAS_BUFFS_PERROW end
	if Option == "UIConfigAurasCastBy" then Option = L_GUI_AURAS_CASTBY end

	-- Chat Settings
	if Option == "UIConfigChat" then Option = CHAT end
	if Option == "UIConfigChatDamageMeterSpam" then Option = L_GUI_CHAT_DAMAGE_METER_SPAM end
	if Option == "UIConfigChatEnable" then Option = L_GUI_CHAT_ENABLE end
	if Option == "UIConfigChatFading" then Option = L_GUI_CHAT_FADING end
	if Option == "UIConfigChatFilter" then Option = L_GUI_CHAT_SPAM end
	if Option == "UIConfigChatHeight" then Option = L_GUI_CHAT_HEIGHT end
	if Option == "UIConfigChatLinkBrackets" then Option = L_GUI_CHAT_LINKBRACKETS end
	if Option == "UIConfigChatLinkColor" then Option = L_GUI_CHAT_LINKCOLOR end
	if Option == "UIConfigChatOutline" then Option = L_GUI_CHAT_OUTLINE end
	if Option == "UIConfigChatScrollByX" then Option = L_GUI_CHAT_SCROLLBYX end
	if Option == "UIConfigChatSpam" then Option = L_GUI_CHAT_GOLD end
	if Option == "UIConfigChatTabsMouseover" then Option = L_GUI_CHAT_TABS_MOUSEOVER end
	if Option == "UIConfigChatTabsOutline" then Option = L_GUI_CHAT_TABS_OUTLINE end
	if Option == "UIConfigChatWhispSound" then Option = L_GUI_CHAT_WHISP end
	if Option == "UIConfigChatWidth" then Option = L_GUI_CHAT_WIDTH end

	-- DataText Settings
	if Option == "UIConfigDataText" then Option = L_GUI_DATATEXT end
	if Option == "UIConfigDataTextBattleground" then Option = L_GUI_DATATEXT_BATTLEGROUND end
	if Option == "UIConfigDataTextLocalTime" then Option = L_GUI_DATATEXT_LOCALTIME end
	if Option == "UIConfigDataTextLocation" then Option = L_GUI_DATATEXT_LOCATION end
	if Option == "UIConfigDataTextSystem" then Option = L_GUI_DATATEXT_SYSTEM end
	if Option == "UIConfigDataTextTime" then Option = L_GUI_DATATEXT_TIME end
	if Option == "UIConfigDataTextTime24Hr" then Option = L_GUI_DATATEXT_TIME24HR end
	if Option == "UIConfigDataTextBottomBar" then Option = L_GUI_DATATEXT_BOTTOMBAR end

	-- Cooldown Settings
	if Option == "UIConfigCooldown" then Option = L_GUI_COOLDOWN end
	if Option == "UIConfigCooldownEnable" then Option = L_GUI_COOLDOWN_ENABLE end
	if Option == "UIConfigCooldownFontSize" then Option = L_GUI_COOLDOWN_FONT_SIZE end
	if Option == "UIConfigCooldownThreshold" then Option = L_GUI_COOLDOWN_THRESHOLD end

	-- Filger
	if Option == "UIConfigFilger" then Option = L_GUI_FILGER end
	if Option == "UIConfigFilgerBuffsSize" then Option = L_GUI_FILGER_BUFFS_SIZE end
	if Option == "UIConfigFilgerCooldownSize" then Option = L_GUI_FILGER_COOLDOWN_SIZE end
	if Option == "UIConfigFilgerDisableCD" then Option = L_GUI_FILGER_DISABLE_CD end
	if Option == "UIConfigFilgerEnable" then Option = L_GUI_FILGER_ENABLE end
	if Option == "UIConfigFilgerMaxTestIcon" then Option = L_GUI_FILGER_MAX_TEST_ICON end
	if Option == "UIConfigFilgerPvPSize" then Option = L_GUI_FILGER_PVP_SIZE end
	if Option == "UIConfigFilgerShowTooltip" then Option = L_GUI_FILGER_SHOW_TOOLTIP end
	if Option == "UIConfigFilgerTestMode" then Option = L_GUI_FILGER_TEST_MODE end

	-- General Settings
	if Option == "UIConfigGeneral" then Option = GENERAL_LABEL end
	if Option == "UIConfigGeneralAutoScale" then Option = L_GUI_GENERAL_AUTOSCALE end
	if Option == "UIConfigGeneralBubbleBackdrop" then Option = L_GUI_GENERAL_CHATBUBBLE_NOBACKDROP end
	if Option == "UIConfigGeneralBubbleFontSize" then Option = L_GUI_GENERAL_CHATBUBBLE_FONTSIZE end
	if Option == "UIConfigGeneralCustomLagTolerance" then Option = L_GUI_GENERAL_LAG_TOLERANCE end
	if Option == "UIConfigGeneralShowConfigButton" then Option = L_GUI_GENERAL_SHOW_CONFIG_BUTTON end
	if Option == "UIConfigGeneralTranslateMessage" then Option = L_GUI_GENERAL_TRANSLATE_MESSAGE end
	if Option == "UIConfigGeneralUIScale" then Option = L_GUI_GENERAL_UISCALE end
	if Option == "UIConfigGeneralWelcomeMessage" then Option = L_GUI_GENERAL_WELCOME_MESSAGE end
	if Option == "UIConfigGeneralQuestSounds" then Option = L_GUI_GENERAL_QUESTSOUNDS end
	if Option == "UIConfigGeneralPathFinder" then Option = L_GUI_GENERAL_PATHFINDER end

	-- Loot Settings
	if Option == "UIConfigLoot" then Option = LOOT end
	if Option == "UIConfigLootAutoGreed" then Option = L_GUI_LOOT_AUTOGREED end
	if Option == "UIConfigLootConfirmDisenchant" then Option = L_GUI_LOOT_AUTODE end
	if Option == "UIConfigLootEnable" then Option = L_GUI_LOOT_ENABLE end
	if Option == "UIConfigLootGroupLoot" then Option = L_GUI_LOOT_ROLL_ENABLE end
	if Option == "UIConfigLootIconSize" then Option = L_GUI_LOOT_ICON_SIZE end
	if Option == "UIConfigLootLootFilter" then Option = L_GUI_LOOT_BETTER_LOOTFILTER end
	if Option == "UIConfigLootWidth" then Option = L_GUI_LOOT_WIDTH end

	-- Minimap Settings
	if Option == "UIConfigMinimap" then Option = L_GUI_MINIMAP end
	if Option == "UIConfigMinimapCollectButtons" then Option = L_GUI_MINIMAP_COLLECTBUTTONS end
	if Option == "UIConfigMinimapEnable" then Option = L_GUI_MINIMAP_ENABLEMINIMAP end
	if Option == "UIConfigMinimapFadeButtons" then Option = L_GUI_MINIMAP_FADEBUTTONS end
	if Option == "UIConfigMinimapGarrison" then Option = L_GUI_MINIMAP_GARRISON end
	if Option == "UIConfigMinimapInvert" then Option = L_GUI_MINIMAP_MINIMAPINVERT end
	if Option == "UIConfigMinimapPing" then Option = L_GUI_MINIMAP_PING end
	if Option == "UIConfigMinimapSize" then Option = L_GUI_MINIMAP_MINIMAPSIZE end

	-- Misc Settings
	if Option == "UIConfigMisc" then Option = L_GUI_MISC end
	if Option == "UIConfigMiscAFKCamera" then Option = L_GUI_MISC_SPIN_CAMERA end
	if Option == "UIConfigMiscAlreadyKnown" then Option = L_GUI_MISC_ALREADY_KNOWN end
	if Option == "UIConfigMiscArmory" then Option = L_GUI_MISC_ARMORY_LINK end
	if Option == "UIConfigMiscAutoRepair" then Option = L_GUI_MISC_AUTOREPAIR end
	if Option == "UIConfigMiscAutoSellGrays" then Option = L_GUI_MISC_AUTOSELLGRAYS end
	if Option == "UIConfigMiscBGSpam" then Option = L_GUI_MISC_HIDE_BG_SPAM end
	if Option == "UIConfigMiscColorPicker" then Option = L_GUI_MISC_COLOR_PICKER end
	if Option == "UIConfigMiscEnhancedMail" then Option = L_GUI_MISC_ENCHANCED_MAIL end
	if Option == "UIConfigMiscErrors" then Option = L_GUI_MISC_ERRORS end
	if Option == "UIConfigMiscInviteKeyword" then Option = L_GUI_MISC_INVKEYWORD end
	if Option == "UIConfigMiscItemLevel" then Option = L_GUI_MISC_ITEMLEVEL end
	if Option == "UIConfigMiscMoveBlizzard" then Option = L_GUI_MISC_MOVE_BLIZZARD end
	if Option == "UIConfigMiscSellMisc" then Option = L_GUI_MISC_SELLMISC end
	if Option == "UIConfigMiscSlotDurability" then Option = L_GUI_MISC_SLOT_DURABILITY end
	if Option == "UIConfigMiscUseGuildRepair" then Option = L_GUI_MISC_USEGUILDREPAIR end
	if Option == "UIConfigMiscQuestLevel" then Option = L_GUI_MISC_QUESTLEVEL end

	-- Nameplate Settings
	if Option == "UIConfigNameplates" then Option = L_GUI_NAMEPLATES end
	if Option == "UIConfigNameplatesAdditionalHeight" then Option = L_GUI_NAMEPLATES_AD_HEIGHT end
	if Option == "UIConfigNameplatesAdditionalWidth" then Option = L_GUI_NAMEPLATES_AD_WIDTH end
	if Option == "UIConfigNameplatesAurasSize" then Option = L_GUI_NAMEPLATES_DEBUFFS_SIZE end
	if Option == "UIConfigNameplatesBadColor" then Option = L_GUI_NAMEPLATES_BAD_COLOR end
	if Option == "UIConfigNameplatesCastbarName" then Option = L_GUI_NAMEPLATES_CASTBAR_NAME end
	if Option == "UIConfigNameplatesClassIcons" then Option = L_GUI_NAMEPLATES_CLASS_ICON end
	if Option == "UIConfigNameplatesCombat" then Option = L_GUI_NAMEPLATES_COMBAT end
	if Option == "UIConfigNameplatesEnable" then Option = L_GUI_NAMEPLATES_ENABLE end
	if Option == "UIConfigNameplatesEnhancedThreat" then Option = L_GUI_NAMEPLATES_THREAT end
	if Option == "UIConfigNameplatesGoodColor" then Option = L_GUI_NAMEPLATES_GOOD_COLOR end
	if Option == "UIConfigNameplatesHealerIcon" then Option = L_GUI_NAMEPLATES_HEALER_ICON end
	if Option == "UIConfigNameplatesHealthValue" then Option = L_GUI_NAMEPLATES_HEALTH end
	if Option == "UIConfigNameplatesHeight" then Option = L_GUI_NAMEPLATES_HEIGHT end
	if Option == "UIConfigNameplatesNameAbbreviate" then Option = L_GUI_NAMEPLATES_NAME_ABBREV end
	if Option == "UIConfigNameplatesNearColor" then Option = L_GUI_NAMEPLATES_NEAR_COLOR end
	if Option == "UIConfigNameplatesShowCastbar" then Option = L_GUI_NAMEPLATES_CASTBAR end
	if Option == "UIConfigNameplatesTrackAuras" then Option = L_GUI_NAMEPLATES_SHOW_DEBUFFS end
	if Option == "UIConfigNameplatesWidth" then Option = L_GUI_NAMEPLATES_WIDTH end

	-- PulseCD Settings
	if Option == "UIConfigPulseCD" then Option = L_GUI_PULSECD end
	if Option == "UIConfigPulseCDEnable" then Option = L_GUI_PULSECD_ENABLE end
	if Option == "UIConfigPulseCDSize" then Option = L_GUI_PULSECD_SIZE end
	if Option == "UIConfigPulseCDSound" then Option = L_GUI_PULSECD_SOUND end
	if Option == "UIConfigPulseCDAnimationScale" then Option = L_GUI_PULSECD_ANIM_SCALE end
	if Option == "UIConfigPulseCDHoldTime" then Option = L_GUI_PULSECD_HOLD_TIME end
	if Option == "UIConfigPulseCDThreshold" then Option = L_GUI_PULSECD_THRESHOLD end

	-- RaidCD Settings
	if Option == "UIConfigRaidCD" then Option = L_GUI_RAIDCD end
	if Option == "UIConfigRaidCDEnable" then Option = L_GUI_RAIDCD_ENABLE end
	if Option == "UIConfigRaidCDHeight" then Option = L_GUI_RAIDCD_HEIGHT end
	if Option == "UIConfigRaidCDWidth" then Option = L_GUI_RAIDCD_WIDTH end
	if Option == "UIConfigRaidCDUpWards" then Option = L_GUI_RAIDCD_SORT end
	if Option == "UIConfigRaidCDExpiration" then Option = L_GUI_RAIDCD_EXPIRATION end
	if Option == "UIConfigRaidCDShowSelf" then Option = L_GUI_RAIDCD_SHOW_SELF end
	if Option == "UIConfigRaidCDShowIcon" then Option = L_GUI_RAIDCD_ICONS end
	if Option == "UIConfigRaidCDShowInRaid" then Option = L_GUI_RAIDCD_IN_RAID end
	if Option == "UIConfigRaidCDShowInParty" then Option = L_GUI_RAIDCD_IN_PARTY end
	if Option == "UIConfigRaidCDShowInArena" then Option = L_GUI_RAIDCD_IN_ARENA end

	-- Skins Settings
	if Option == "UIConfigSkins" then Option = L_GUI_SKINS end
	if Option == "UIConfigSkinsCLCRet" then Option = L_GUI_SKINS_CLCR end
	if Option == "UIConfigSkinsChatBubble" then Option = L_GUI_SKINS_CHAT_BUBBLE end
	if Option == "UIConfigSkinsDBM" then Option = L_GUI_SKINS_DBM end
	if Option == "UIConfigSkinsDBMMove" then Option = L_GUI_SKINS_DBM_MOVE end
	if Option == "UIConfigSkinsMinimapButtons" then Option = L_GUI_SKINS_MINIMAP_BUTTONS end
	if Option == "UIConfigSkinsRecount" then Option = L_GUI_SKINS_RECOUNT end
	if Option == "UIConfigSkinsSkada" then Option = L_GUI_SKINS_SKADA end
	if Option == "UIConfigSkinsSpy" then Option = L_GUI_SKINS_SPY end
	if Option == "UIConfigSkinsWeakAuras" then Option = L_GUI_SKINS_WEAKAURAS end

	-- Tooltip Settings
	if Option == "UIConfigTooltip" then Option = L_GUI_TOOLTIP end
	if Option == "UIConfigTooltipAchievements" then Option = L_GUI_TOOLTIP_ACHIEVEMENTS end
	if Option == "UIConfigTooltipCursor" then Option = L_GUI_TOOLTIP_CURSOR end
	if Option == "UIConfigTooltipEnable" then Option = L_GUI_TOOLTIP_ENABLE end
	if Option == "UIConfigTooltipHealthValue" then Option = L_GUI_TOOLTIP_HEALTH end
	if Option == "UIConfigTooltipHyperLink" then Option = L_GUI_TOOLTIP_HYPERLINK end
	if Option == "UIConfigTooltipInstanceLock" then Option = L_GUI_TOOLTIP_INSTANCE_LOCK end
	if Option == "UIConfigTooltipItemCount" then Option = L_GUI_TOOLTIP_ITEM_COUNT end
	if Option == "UIConfigTooltipItemIcon" then Option = L_GUI_TOOLTIP_ICON end
	if Option == "UIConfigTooltipShowSpec" then Option = L_GUI_TOOLTIP_SHOWSPEC end
	if Option == "UIConfigTooltipSpellID" then Option = L_GUI_TOOLTIP_SPELL_ID end

	-- Unitframe Settings
	if Option == "UIConfigUnitframe" then Option = L_GUI_UNITFRAME end
	if Option == "UIConfigUnitframeCastbars" then Option = L_GUI_UNITFRAME_CASTBARS end
	if Option == "UIConfigUnitframeCastbarSafeZoneColor" then Option = L_GUI_UNITFRAME_CASTBARSAFEZONECOLOR end
	if Option == "UIConfigUnitframeClassColor" then Option = L_GUI_UNITFRAME_CLASSCOLOR end
	if Option == "UIConfigUnitframeClassPortraits" then Option = L_GUI_UNITFRAME_CLASSPORTRAITS end
	if Option == "UIConfigUnitframeCombatText" then Option = L_GUI_UNITFRAME_COMBAT_TEXT end
	if Option == "UIConfigUnitframeEnable" then Option = L_GUI_UNITFRAME_ENABLE end
	if Option == "UIConfigUnitframeFlatClassPortraits" then Option = L_GUI_UNITFRAME_FLAT_CLASSPORTRAITS end
	if Option == "UIConfigUnitframeFocusCastbarHeight" then Option = L_GUI_UNITFRAME_FOCUSCASTBAR_HEIGHT end
	if Option == "UIConfigUnitframeFocusCastbarWidth" then Option = L_GUI_UNITFRAME_FOCUSCASTBAR_WIDTH end
	if Option == "UIConfigUnitframeIconPlayer" then Option = L_GUI_UNITFRAME_ICONPLAYER end
	if Option == "UIConfigUnitframeIconTarget" then Option = L_GUI_UNITFRAME_ICONTARGET end
	if Option == "UIConfigUnitframeParty" then Option = L_GUI_UNITFRAME_PARTY end
	if Option == "UIConfigUnitframePlayerCastbarHeight" then Option = L_GUI_UNITFRAME_PLAYERCASTBAR_HEIGHT end
	if Option == "UIConfigUnitframePlayerCastbarWidth" then Option = L_GUI_UNITFRAME_PLAYERCASTBAR_WIDTH end
	if Option == "UIConfigUnitframePlayerDebuffsOnly" then Option = L_GUI_UNITFRAME_PLAYERDEBUFFS_ONLY end
	if Option == "UIConfigUnitframePortraitTimer" then Option = L_GUI_UNITFRAME_PORTRAITTIMER end
	if Option == "UIConfigUnitframePowerPredictionBar" then Option = L_GUI_UNITFRAME_POWERPREDICTIONBAR end
	if Option == "UIConfigUnitframeScale" then Option = L_GUI_UNITFRAME_SCALE end
	if Option == "UIConfigUnitframeShowArena" then Option = L_GUI_UNITFRAME_SHOWARENA end
	if Option == "UIConfigUnitframeShowBoss" then Option = L_GUI_UNITFRAME_SHOWBOSS end
	if Option == "UIConfigUnitframeShowPlayer" then Option = L_GUI_UNITFRAME_SHOWPLAYER end
	if Option == "UIConfigUnitframeStyle" then Option = L_GUI_UNITFRAME_STYLE end
	if Option == "UIConfigUnitframeTargetCastbarHeight" then Option = L_GUI_UNITFRAME_TARGETCASTBAR_HEIGHT end
	if Option == "UIConfigUnitframeTargetCastbarWidth" then Option = L_GUI_UNITFRAME_TARGETCASTBAR_WIDTH end
	if Option == "UIConfigUnitframeTextHealthColor" then Option = L_GUI_UNITFRAME_TEXTHEALTHCOLOR end
	if Option == "UIConfigUnitframeTextNameColor" then Option = L_GUI_UNITFRAME_TEXTNAMECOLOR end
	if Option == "UIConfigUnitframeTextPowerColor" then Option = L_GUI_UNITFRAME_TEXTPOWERCOLOR end
	if Option == "UIConfigUnitframeThreatGlow" then Option = L_GUI_UNITFRAME_THREATGLOW end
	if Option == "UIConfigUnitframeThreatValue" then Option = L_GUI_UNITFRAME_THREATVALUE end

	-- Raidframe Settings
	if Option == "UIConfigRaidframe" then Option = L_GUI_RAIDFRAME end
	if Option == "UIConfigRaidframeAuraWatch" then Option = L_GUI_RAIDFRAME_AURAWATCH end
	if Option == "UIConfigRaidframeAuraWatchTimers" then Option = L_GUI_RAIDFRAME_AURAWATCH_TIMERS end
	if Option == "UIConfigRaidframeDeficitThreshold" then Option = L_GUI_RAIDFRAME_DEFICITTHRESHOLD end
	if Option == "UIConfigRaidframeEnable" then Option = L_GUI_RAIDFRAME_ENABLE end
	if Option == "UIConfigRaidframeHeight" then Option = L_GUI_RAIDFRAME_HEIGHT end
	if Option == "UIConfigRaidframeHorizontalHealthBars" then Option = L_GUI_RAIDFRAME_HORIZONTAL_HEALTHBARS end
	if Option == "UIConfigRaidframeIconSize" then Option = L_GUI_RAIDFRAME_ICONSIZE end
	if Option == "UIConfigRaidframeIndicatorSize" then Option = L_GUI_RAIDFRAME_INDICATORSIZE end
	if Option == "UIConfigRaidframeMainTankFrames" then Option = L_GUI_RAIDFRAME_MAINTANKFRAMES end
	if Option == "UIConfigRaidframeManabarHorizontal" then Option = L_GUI_RAIDFRAME_MANABAR_HORIZONTAL end
	if Option == "UIConfigRaidframeManabarShow" then Option = L_GUI_RAIDFRAME_MANABARSHOW end
	if Option == "UIConfigRaidframeMaxUnitPerColumn" then Option = L_GUI_RAIDFRAME_MAXUNIT_PERCOLUMN end
	if Option == "UIConfigRaidframeRaidAsParty" then Option = L_GUI_RAIDFRAME_RAIDASPARTY end
	if Option == "UIConfigRaidframeScale" then Option = L_GUI_RAIDFRAME_SCALE end
	if Option == "UIConfigRaidframeShowMouseoverHighlight" then Option = L_GUI_RAIDFRAME_SHOWMOUSEOVER_HIGHLIGHT end
	if Option == "UIConfigRaidframeShowNotHereTimer" then Option = L_GUI_RAIDFRAME_SHOW_NOTHERETIMER end
	if Option == "UIConfigRaidframeShowResurrectText" then Option = L_GUI_RAIDFRAME_SHOWRESURRECT_TEXT end
	if Option == "UIConfigRaidframeShowRolePrefix" then Option = L_GUI_RAIDFRAME_SHOWROLE_PREFIX end
	if Option == "UIConfigRaidframeShowThreatText" then Option = L_GUI_RAIDFRAME_SHOWTHREATTEXT end
	if Option == "UIConfigRaidframeWidth" then Option = L_GUI_RAIDFRAME_WIDTH end

	-- WorldMap Settings
	if Option == "UIConfigWorldMap" then Option = L_GUI_WORLDMAP end
	if Option == "UIConfigWorldMapAlphaWhenMoving" then Option = L_GUI_WORLDMAP_ALPHA_WHENMOVING end
	if Option == "UIConfigWorldMapCoordinates" then Option = L_GUI_WORLDMAP_COORDS end
	if Option == "UIConfigWorldMapFadeWhenMoving" then Option = L_GUI_WORLDMAP_FADE_WHENMOVING end
	if Option == "UIConfigWorldMapFogOfWar" then Option = L_GUI_WORLDMAP_FOG_OF_WAR end
	if Option == "UIConfigWorldMapSmallWorldMap" then Option = L_GUI_WORLDMAP_SMALL_WORLDMAP end

	K.Option = Option
end

local NewButton = function(text, parent)

	local result = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	local label = result:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetText(text)
	result:SetWidth(label:GetWidth())
	result:SetHeight(label:GetHeight())
	result:SetFontString(label)
	result:SetNormalTexture("")
	result:SetHighlightTexture("")
	result:SetPushedTexture("")
	result.Left:SetAlpha(0)
	result.Right:SetAlpha(0)
	result.Middle:SetAlpha(0)

	return result
end

local NormalButton = function(text, parent)

	local result = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	local label = result:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetJustifyH("LEFT")
	label:SetText(text)
	result:SetSize(100, 23)
	result:SetFontString(label)
	if IsAddOnLoaded("Aurora") then
		local F = unpack(Aurora)
		F.Reskin(result)
	else
		result:SkinButton()
	end

	return result
end

StaticPopupDialogs.PERCHAR = {
	text = L_GUI_PER_CHAR,
	OnAccept = function()
		if KkthnxUIConfigAllCharacters:GetChecked() then
			KkthnxUIConfigAll[realm][name] = true
		else
			KkthnxUIConfigAll[realm][name] = false
		end
		ReloadUI()
	end,
	OnCancel = function()
		UIConfigCover:Hide()
		if KkthnxUIConfigAllCharacters:GetChecked() then
			KkthnxUIConfigAllCharacters:SetChecked(false)
		else
			KkthnxUIConfigAllCharacters:SetChecked(true)
		end
	end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs.RESET_PERCHAR = {
	text = L_GUI_RESET_CHAR,
	OnAccept = function()
		KkthnxUIConfigPrivate = KkthnxUIConfigPublic
		ReloadUI()
	end,
	OnCancel = function() if UIConfig and UIConfig:IsShown() then UIConfigCover:Hide() end end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs.RESET_ALL = {
	text = L_GUI_RESET_ALL,
	OnAccept = function()
		KkthnxUIConfigPublic = nil
		KkthnxUIConfigPrivate = nil
		ReloadUI()

		KkthnxUIDataPerChar.Install = false
	end,
	OnCancel = function() UIConfigCover:Hide() end,
	button1 = ACCEPT,
	button2 = CANCEL,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3
}

local function SetValue(group, option, value)
	local mergesettings
	if KkthnxUIConfigPrivate == KkthnxUIConfigPublic then
		mergesettings = true
	else
		mergesettings = false
	end

	if KkthnxUIConfigAll[realm][name] == true then
		if not KkthnxUIConfigPrivate then KkthnxUIConfigPrivate = {} end
		if not KkthnxUIConfigPrivate[group] then KkthnxUIConfigPrivate[group] = {} end
		KkthnxUIConfigPrivate[group][option] = value
	else
		if mergesettings == true then
			if not KkthnxUIConfigPrivate then KkthnxUIConfigPrivate = {} end
			if not KkthnxUIConfigPrivate[group] then KkthnxUIConfigPrivate[group] = {} end
			KkthnxUIConfigPrivate[group][option] = value
		end

		if not KkthnxUIConfigPublic then KkthnxUIConfigPublic = {} end
		if not KkthnxUIConfigPublic[group] then KkthnxUIConfigPublic[group] = {} end
		KkthnxUIConfigPublic[group][option] = value
	end
end

local VISIBLE_GROUP = nil
local lastbutton = nil
local function ShowGroup(group, button)
	local K = KkthnxUI[1]

	if lastbutton then
		lastbutton:SetText(lastbutton:GetText().sub(lastbutton:GetText(), 11, -3))
	end
	if VISIBLE_GROUP then
		_G["UIConfig"..VISIBLE_GROUP]:Hide()
	end
	if _G["UIConfig"..group] then
		local Option = "UIConfig"..group
		Local(Option)
		_G["UIConfigTitle"]:SetText(K.Option)
		local height = _G["UIConfig"..group]:GetHeight()
		_G["UIConfig"..group]:Show()
		local scrollamntmax = 400
		local scrollamntmin = scrollamntmax - 10
		local max = height > scrollamntmax and height-scrollamntmin or 1

		if max == 1 then
			_G["UIConfigGroupSlider"]:SetValue(1)
			_G["UIConfigGroupSlider"]:Hide()
		else
			_G["UIConfigGroupSlider"]:SetMinMaxValues(0, max)
			_G["UIConfigGroupSlider"]:Show()
			_G["UIConfigGroupSlider"]:SetValue(1)
		end
		_G["UIConfigGroup"]:SetScrollChild(_G["UIConfig"..group])

		local x
		if UIConfigGroupSlider:IsShown() then
			_G["UIConfigGroup"]:EnableMouseWheel(true)
			_G["UIConfigGroup"]:SetScript("OnMouseWheel", function(self, delta)
				if UIConfigGroupSlider:IsShown() then
					if delta == -1 then
						x = _G["UIConfigGroupSlider"]:GetValue()
						_G["UIConfigGroupSlider"]:SetValue(x + 10)
					elseif delta == 1 then
						x = _G["UIConfigGroupSlider"]:GetValue()
						_G["UIConfigGroupSlider"]:SetValue(x - 30)
					end
				end
			end)
		else
			_G["UIConfigGroup"]:EnableMouseWheel(false)
		end

		VISIBLE_GROUP = group
		lastbutton = button
	end
end

local Loaded
function CreateUIConfig()
	if InCombatLockdown() and not Loaded then Print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
	local K = KkthnxUI[1]
	local C = KkthnxUI[2]

	if UIConfigMain then
		ShowGroup("General")
		UIConfigMain:Show()
		return
	end

	-- Main Frame
	local UIConfigMain = CreateFrame("Frame", "UIConfigMain", UIParent)
	UIConfigMain:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 200)
	UIConfigMain:SetSize(780, 482)
	UIConfigMain:SetBackdrop(K.Backdrop)
	UIConfigMain:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	UIConfigMain:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
	UIConfigMain:SetFrameStrata("DIALOG")
	UIConfigMain:SetFrameLevel(20)
	UIConfigMain:EnableMouse(true)
	UIConfigMain:SetScript("OnMouseDown", function() UIConfigMain:StartMoving() end)
	UIConfigMain:SetScript("OnMouseUp", function() UIConfigMain:StopMovingOrSizing() end)
	UIConfigMain:SetClampedToScreen(true)
	UIConfigMain:SetMovable(true)
	tinsert(UISpecialFrames, "UIConfigMain")

	-- Version Title
	local TitleBoxVer = CreateFrame("Frame", "TitleBoxVer", UIConfigMain)
	TitleBoxVer:SetSize(180, 28)
	TitleBoxVer:SetPoint("TOPLEFT", UIConfigMain, "TOPLEFT", 23, -15)

	local TitleBoxVerText = TitleBoxVer:CreateFontString("UIConfigTitleVer", "OVERLAY", "GameFontNormal")
	TitleBoxVerText:SetPoint("CENTER")
	TitleBoxVerText:SetText("|cff3c9bedKkthnxUI|r "..K.Version)

	-- Main Frame Title
	local TitleBox = CreateFrame("Frame", "TitleBox", UIConfigMain)
	TitleBox:SetSize(540, 28)
	TitleBox:SetPoint("TOPLEFT", TitleBoxVer, "TOPRIGHT", 15, 0)

	local TitleBoxText = TitleBox:CreateFontString("UIConfigTitle", "OVERLAY", "GameFontNormal")
	TitleBoxText:SetPoint("LEFT", TitleBox, "LEFT", 15, 0)

	-- Options Frame
	local UIConfig = CreateFrame("Frame", "UIConfig", UIConfigMain)
	UIConfig:SetPoint("TOPLEFT", TitleBox, "BOTTOMLEFT", 10, -15)
	UIConfig:SetSize(520, 400)

	local UIConfigBG = CreateFrame("Frame", "UIConfigBG", UIConfig)
	UIConfigBG:SetPoint("TOPLEFT", -10, 10)
	UIConfigBG:SetPoint("BOTTOMRIGHT", 10, -10)

	-- Group Frame
	local groups = CreateFrame("ScrollFrame", "UIConfigCategoryGroup", UIConfig)
	groups:SetPoint("TOPLEFT", TitleBoxVer, "BOTTOMLEFT", 10, -15)
	groups:SetSize(160, 400)

	local groupsBG = CreateFrame("Frame", "groupsBG", UIConfig)
	groupsBG:SetPoint("TOPLEFT", groups, -10, 10)
	groupsBG:SetPoint("BOTTOMRIGHT", groups, 10, -10)

	local UIConfigCover = CreateFrame("Frame", "UIConfigCover", UIConfigMain)
	UIConfigCover:SetPoint("TOPLEFT", 0, 0)
	UIConfigCover:SetPoint("BOTTOMRIGHT", 0, 0)
	UIConfigCover:SetFrameLevel(UIConfigMain:GetFrameLevel() + 20)
	UIConfigCover:EnableMouse(true)
	UIConfigCover:SetScript("OnMouseDown", function(self) print(L_GUI_MAKE_SELECTION) end)
	UIConfigCover:Hide()

	-- Group Scroll
	local slider = CreateFrame("Slider", "UIConfigCategorySlider", groups)
	slider:SetPoint("TOPRIGHT", 0, 0)
	slider:SetSize(20, 400)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetOrientation("VERTICAL")
	slider:CreateBackdrop(4)
	local r, g, b, a = unpack(C.Media.Backdrop_Color)
	slider:SetBackdropColor(r, g, b, 0.8)
	slider:SetValueStep(20)
	slider:SetScript("OnValueChanged", function(self, value) groups:SetVerticalScroll(value) end)

	--[[
	if not slider.bg then
		slider.bg = CreateFrame("Frame", nil, slider)
		slider.bg:SetPoint("TOPLEFT", slider:GetThumbTexture(), "TOPLEFT", 10, -7)
		slider.bg:SetPoint("BOTTOMRIGHT", slider:GetThumbTexture(), "BOTTOMRIGHT", -7, 7)
		slider:GetThumbTexture():SetAlpha(0)
	end
	--]]

	local function sortMyTable(a, b)
		return ALLOWED_GROUPS[a] < ALLOWED_GROUPS[b]
	end
	local function pairsByKey(t, f)
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a, sortMyTable)
		local i = 0
		local iter = function()
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
		return iter
	end

	local GetOrderedIndex = function(t)
		local OrderedIndex = {}

		for key in pairs(t) do table.insert(OrderedIndex, key) end
		table.sort(OrderedIndex)
		return OrderedIndex
	end

	local OrderedNext = function(t, state)
		local Key

		if (state == nil) then
			t.OrderedIndex = GetOrderedIndex(t)
			Key = t.OrderedIndex[1]
			return Key, t[Key]
		end

		Key = nil
		for i = 1, #t.OrderedIndex do
			if (t.OrderedIndex[i] == state) then Key = t.OrderedIndex[i + 1] end
		end

		if Key then return Key, t[Key] end
		t.OrderedIndex = nil
		return
	end

	local PairsByKeys = function(t) return OrderedNext, t, nil end

	local child = CreateFrame("Frame", nil, groups)
	child:SetPoint("TOPLEFT")
	local offset = 5
	for i in pairsByKey(ALLOWED_GROUPS) do
		local Option = "UIConfig"..i
		Local(Option)
		local button = NewButton(K.Option, child)
		button:SetSize(125, 16)
		button:SetPoint("TOPLEFT", 5, -offset)
		button:SetScript("OnClick", function(self) ShowGroup(i, button) self:SetText(format("|cff%02x%02x%02x%s|r", K.Color.r*255, K.Color.g*255, K.Color.b*255, K.Option)) end)
		offset = offset + 20
	end
	child:SetSize(125, offset)
	slider:SetMinMaxValues(0, (offset == 0 and 1 or offset - 12 * 33))
	slider:SetValue(1)
	groups:SetScrollChild(child)

	local x
	_G["UIConfigCategoryGroup"]:EnableMouseWheel(true)
	_G["UIConfigCategoryGroup"]:SetScript("OnMouseWheel", function(self, delta)
		if _G["UIConfigCategorySlider"]:IsShown() then
			if delta == -1 then
				x = _G["UIConfigCategorySlider"]:GetValue()
				_G["UIConfigCategorySlider"]:SetValue(x + 10)
			elseif delta == 1 then
				x = _G["UIConfigCategorySlider"]:GetValue()
				_G["UIConfigCategorySlider"]:SetValue(x - 20)
			end
		end
	end)

	local group = CreateFrame("ScrollFrame", "UIConfigGroup", UIConfig)
	group:SetPoint("TOPLEFT", 0, 5)
	group:SetSize(520, 400)

	-- Options Scroll
	local slider = CreateFrame("Slider", "UIConfigGroupSlider", group)
	slider:SetPoint("TOPRIGHT", 0, 0)
	slider:SetSize(24, 400)
	slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	slider:SetOrientation("VERTICAL")
	slider:SetValueStep(20)
	slider:SetScript("OnValueChanged", function(self, value) group:SetVerticalScroll(value) end)

	for i in pairs(ALLOWED_GROUPS) do
		local frame = CreateFrame("Frame", "UIConfig"..i, UIConfigGroup)
		frame:SetPoint("TOPLEFT")
		frame:SetWidth(225)

		local offset = 5

		if type(C[i]) ~= "table" then Error(i.." GroupName not found in config table.") return end
		for j, value in PairsByKeys(C[i]) do
			if type(value) == "boolean" then
				local button = CreateFrame("CheckButton", "UIConfig"..i..j, frame, "InterfaceOptionsCheckButtonTemplate")
				local Option = "UIConfig"..i..j
				Local(Option)
				_G["UIConfig"..i..j.."Text"]:SetText(K.Option)
				_G["UIConfig"..i..j.."Text"]:SetFontObject(GameFontHighlight)
				_G["UIConfig"..i..j.."Text"]:SetWidth(460)
				_G["UIConfig"..i..j.."Text"]:SetJustifyH("LEFT")
				button:SetChecked(value)
				button:SetScript("OnClick", function(self) SetValue(i, j, (self:GetChecked() and true or false)) end)
				button:SetPoint("TOPLEFT", 5, -offset)
				offset = offset + 25
			elseif type(value) == "number" or type(value) == "string" then
				local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				local Option = "UIConfig"..i..j
				Local(Option)
				label:SetText(K.Option)
				label:SetSize(460, 20)
				label:SetJustifyH("LEFT")
				label:SetPoint("TOPLEFT", 5, -offset)

				local editbox = CreateFrame("EditBox", nil, frame)
				editbox:SetAutoFocus(false)
				editbox:SetMultiLine(false)
				editbox:SetSize(220, 24)
				editbox:SetMaxLetters(255)
				editbox:SetTextInsets(4, 0, 0, 0)
				editbox:SetFontObject(GameFontHighlight)
				editbox:SetPoint("TOPLEFT", 8, -(offset + 20))
				editbox:SetText(value)
				editbox:SetBackdrop(K.Backdrop)
				editbox:SetBackdropColor(unpack(C.Media.Backdrop_Color))

				local okbutton = CreateFrame("Button", nil, frame)
				okbutton:SetHeight(editbox:GetHeight() - 8)
				okbutton:SkinButton()
				okbutton:SetPoint("LEFT", editbox, "RIGHT", 2, 0)

				local oktext = okbutton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				oktext:SetText(OKAY)
				oktext:SetPoint("CENTER", okbutton, "CENTER", -1, 0)
				okbutton:SetWidth(oktext:GetWidth() + 5)
				okbutton:Hide()

				if type(value) == "number" then
					editbox:SetScript("OnEscapePressed", function(self) okbutton:Hide() self:ClearFocus() self:SetText(value) end)
					editbox:SetScript("OnChar", function(self) okbutton:Show() end)
					editbox:SetScript("OnEnterPressed", function(self) okbutton:Hide() self:ClearFocus() SetValue(i, j, tonumber(self:GetText())) end)
					okbutton:SetScript("OnMouseDown", function(self) editbox:ClearFocus() self:Hide() SetValue(i, j, tonumber(editbox:GetText())) end)
				else
					editbox:SetScript("OnEscapePressed", function(self) okbutton:Hide() self:ClearFocus() self:SetText(value) end)
					editbox:SetScript("OnChar", function(self) okbutton:Show() end)
					editbox:SetScript("OnEnterPressed", function(self) okbutton:Hide() self:ClearFocus() SetValue(i, j, tostring(self:GetText())) end)
					okbutton:SetScript("OnMouseDown", function(self) editbox:ClearFocus() self:Hide() SetValue(i, j, tostring(editbox:GetText())) end)
				end

				offset = offset + 45
			elseif type(value) == "table" then
				local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				local Option = "UIConfig"..i..j
				Local(Option)
				label:SetText(K.Option)
				label:SetSize(440, 20)
				label:SetJustifyH("LEFT")
				label:SetPoint("TOPLEFT", 5, -offset)

				colorbuttonname = (label:GetText().."ColorPicker")

				local colorbutton = CreateFrame("Button", colorbuttonname, frame)
				colorbutton:SetHeight(20)
				colorbutton:SetBackdrop(K.Backdrop)
				colorbutton:SetBackdropBorderColor(unpack(value))
				colorbutton:SetBackdropColor(value[1], value[2], value[3], 0.3)
				colorbutton:SetPoint("LEFT", label, "RIGHT", 2, 0)

				local colortext = colorbutton:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
				colortext:SetText(COLOR)
				colortext:SetPoint("CENTER")
				colortext:SetJustifyH("CENTER")
				colorbutton:SetWidth(colortext:GetWidth() + 5)

				local oldvalue = value

				local function round(number, decimal)
					return (("%%.%df"):format(decimal)):format(number)
				end

				colorbutton:SetScript("OnMouseDown", function(self)
					if ColorPickerFrame:IsShown() then return end
					local newR, newG, newB, newA
					local fired = 0

					local r, g, b, a = self:GetBackdropBorderColor()
					r, g, b, a = round(r, 2), round(g, 2), round(b, 2), round(a, 2)
					local originalR, originalG, originalB, originalA = r, g, b, a

					local function ShowColorPicker(r, g, b, a, changedCallback)
						ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = changedCallback, changedCallback, changedCallback
						ColorPickerFrame:SetColorRGB(r, g, b)
						a = tonumber(a)
						ColorPickerFrame.hasOpacity = (a ~= nil and a ~= 1)
						ColorPickerFrame.opacity = a
						ColorPickerFrame.previousValues = {originalR, originalG, originalB, originalA}
						ColorPickerFrame:Hide()
						ColorPickerFrame:Show()
					end

					local function myColorCallback(restore)
						fired = fired + 1
						if restore ~= nil then
							-- The user bailed, we extract the old color from the table created by ShowColorPicker
							newR, newG, newB, newA = unpack(restore)
						else
							-- Something changed
							newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
						end

						value = {newR, newG, newB, newA}
						SetValue(i, j, (value))
						self:SetBackdropBorderColor(newR, newG, newB, newA)
						self:SetBackdropColor(newR, newG, newB, 0.3)
					end

					ShowColorPicker(originalR, originalG, originalB, originalA, myColorCallback)
				end)

				offset = offset + 25
			end
		end

		frame:SetHeight(offset)
		frame:Hide()
	end

	local reset = NormalButton(DEFAULT, UIConfigMain)
	reset:SetPoint("TOPRIGHT", UIConfigBG, "TOPRIGHT", 126, 0)
	reset:SetScript("OnClick", function(self)
		UIConfigCover:Show()
		if KkthnxUIConfigAll[realm][name] == true then
			StaticPopup_Show("RESET_PERCHAR")
		else
			StaticPopup_Show("RESET_ALL")
		end
	end)

	local totalreset = NormalButton(L_GUI_BUTTON_RESET, UIConfigMain)
	totalreset:SetPoint("TOPRIGHT", UIConfigBG, "TOPRIGHT", 126, -31)
	totalreset:SetScript("OnClick", function(self)
		StaticPopup_Show("RESET_UI")
		KkthnxUIConfigPrivate = {}
		if KkthnxUIConfigAll[realm][name] == true then
			KkthnxUIConfigAll[realm][name] = {}
		end
		KkthnxUIConfigPublic = {}
	end)

	local load = NormalButton("|cff00FF00" .. L_GUI_APPLY .. "|r", UIConfigMain)
	load:SetPoint("TOP", totalreset, "BOTTOM", 0, -30)
	load:SetScript("OnClick", function(self) ReloadUI() end)

	local close = NormalButton("|cffFF0000" .. L_GUI_CLOSE .. "|r", UIConfigMain)
	close:SetPoint("TOP", load, "BOTTOM", 0, -8)
	close:SetScript("OnClick", function(self) PlaySound("igMainMenuOption") UIConfigMain:Hide() end)

	if KkthnxUIConfigAll then
		local button = CreateFrame("CheckButton", "KkthnxUIConfigAllCharacters", TitleBox, "InterfaceOptionsCheckButtonTemplate")
		button:SetScript("OnClick", function(self) StaticPopup_Show("PERCHAR") UIConfigCover:Show() end)
		button:SetPoint("RIGHT", TitleBox, "RIGHT", -3, 0)
		button:SetHitRectInsets(0, 0, 0, 0)
		if IsAddOnLoaded("Aurora") then
			local F = unpack(Aurora)
			F.ReskinCheck(button)
		end

		local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetText(L_GUI_SET_SAVED_SETTTINGS)
		label:SetPoint("RIGHT", button, "LEFT")

		if KkthnxUIConfigAll[realm][name] == true then
			button:SetChecked(true)
		else
			button:SetChecked(false)
		end
	end

	local bgSkins = {TitleBox, TitleBoxVer, UIConfigBG, groupsBG}
	for _, sb in pairs(bgSkins) do
		sb:SetBackdrop(K.Backdrop)
		sb:SetBackdropColor(unpack(C.Media.Backdrop_Color))
		sb:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	end

	ShowGroup("General")
	loaded = true
end

do
	function SlashCmdList.CONFIG(msg, editbox)
		if not UIConfigMain or not UIConfigMain:IsShown() then
			PlaySound("igMainMenuOption")
			CreateUIConfig()
			HideUIPanel(GameMenuFrame)
		else
			PlaySound("igMainMenuOption")
			UIConfigMain:Hide()
		end
	end
	SLASH_CONFIG1 = "/config"
	SLASH_CONFIG2 = "/cfg"
	SLASH_CONFIG3 = "/configui"
	SLASH_CONFIG4 = "/kc"
	SLASH_CONFIG5 = "/kkthnxui"

	function SlashCmdList.RESETCONFIG()
		if UIConfigMain and UIConfigMain:IsShown() then UIConfigCover:Show() end

		if KkthnxUIConfigAll[realm][name] == true then
			StaticPopup_Show("RESET_PERCHAR")
		else
			StaticPopup_Show("RESET_ALL")
		end
	end
	SLASH_RESETCONFIG1 = "/resetconfig"
end

do
	local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
	frame:Hide()

	frame.name = "|cff3c9bedKkthnxUI|r"
	frame:SetScript("OnShow", function(self)
		if self.show then return end

		local title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 16, -16)
		title:SetText("Info:")

		local subtitle = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle:SetWidth(380)
		subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
		subtitle:SetJustifyH("LEFT")
		subtitle:SetText("UI Site: |cff3c9bedhttps://kkthnx.github.io/KkthnxUI_Legion|r\nGitHub: |cff3c9bedhttps://github.com/Kkthnx/KkthnxUI_Legion|r\nChangelog: |cff3c9bedhttps://github.com/Kkthnx/KkthnxUI_Legion/commits/master|r")

		local title2 = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title2:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
		title2:SetText("Credits:")

		local subtitle2 = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle2:SetWidth(380)
		subtitle2:SetPoint("TOPLEFT", title2, "BOTTOMLEFT", 0, -8)
		subtitle2:SetJustifyH("LEFT")
		subtitle2:SetText("ALZA, AcidWeb, Aezay, Affli, Ailae, Allez, Ammo, Astromech, Beoko, BernCarney, Bitbyte, Blamdarot, Bozo, Bunny67, Caellian, Califpornia, Camealion, Chiril, Crum, CrusaderHeimdall, Cybey, Dawn, Don Kaban, Dridzt, Duffed, Durcyn, Eclipse, Egingell, Elv22, Evilpaul, Evl, Favorit, Fernir, Foof, Freebaser, freesay, Goldpaw, Gorlasch, Gsuz, Haleth, Haste, Hoochie, Hungtar, HyPeRnIcS, Hydra, Ildyria, Jaslm, Karl_w_w, Karudon, Katae, Kellett, Kemayo, Killakhan, Kraftman, Kunda, Leatrix, Magdain, |cFFFF69B4Magicnachos|r, Meurtcriss, Monolit, MrRuben5, Myrilandell of Lothar, Nathanyel, Nefarion, Nightcracker, Nils Ruesch, Partha, Peatah, Phanx, Rahanprout, Rav, Renstrom, RustamIrzaev, SDPhantom, Safturento, Sara.Festung, Sildor, Silverwind, SinaC, Slakah, Soeters, Starlon, Suicidal Katt, Syzgyn, Tekkub, Telroth, Thalyra, Thizzelle, Tia Lynn, Tohveli, Tukz, Tuller, Veev, Villiv, Wetxius, Woffle of Dark Iron, Wrug, Xuerian, Yleaf, Zork, g0st, gi2k15, iSpawnAtHome, m2jest1c, p3lim, sticklord")

		local title3 = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title3:SetPoint("TOPLEFT", subtitle2, "BOTTOMLEFT", 0, -16)
		title3:SetText("Translation Needed:")

		local subtitle3 = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle3:SetWidth(380)
		subtitle3:SetPoint("TOPLEFT", title3, "BOTTOMLEFT", 0, -8)
		subtitle3:SetJustifyH("LEFT")
		subtitle3:SetText("|cff3c9bedKkthnxUI|r is looking for Russian translation. If you wanna translate for us, you can PM me or make pull requests on GitHub")

		local title4 = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title4:SetPoint("TOPLEFT", subtitle3, "BOTTOMLEFT", 0, -16)
		title4:SetText("Supporters")

		local subtitle4 = self:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		subtitle4:SetWidth(380)
		subtitle4:SetPoint("TOPLEFT", title4, "BOTTOMLEFT", 0, -8)
		subtitle4:SetJustifyH("LEFT")
		subtitle4:SetText("XploitNT, jChirp, |cFFFF69B4Magicnachos|r")

		local version = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		version:SetPoint("BOTTOMRIGHT", -16, 16)
		version:SetText("Version: "..K.Version)

		self.show = true
	end)

	InterfaceOptions_AddCategory(frame)
end

local GameMenu = CreateFrame("Frame")
local Menu = GameMenuFrame
local Header = GameMenuFrameHeader
local Logout = GameMenuButtonLogout
local Addons = GameMenuButtonAddons

function GameMenu:AddHooks()
	local Logout = GameMenuButtonLogout

	Menu:SetHeight(Menu:GetHeight() + Logout:GetHeight())
	local _, relTo, _, _, offY = Logout:GetPoint()
	if relTo ~= GameMenu.KkthnxUI then
		GameMenu.KkthnxUI:ClearAllPoints()
		GameMenu.KkthnxUI:SetPoint("TOPLEFT", relTo, "BOTTOMLEFT", 0, -1)
		Logout:ClearAllPoints()
		Logout:SetPoint("TOPLEFT", GameMenu.KkthnxUI, "BOTTOMLEFT", 0, offY)
	end
end

function GameMenu:EnableKkthnxUIConfig()
	local Logout = GameMenuButtonLogout

	local KkthnxUI = CreateFrame("Button", nil, Menu, "GameMenuButtonTemplate")
	KkthnxUI:SetSize(Logout:GetWidth(), Logout:GetHeight())
	KkthnxUI:SetPoint("TOPLEFT", GameMenuButtonAddons, "BOTTOMLEFT", 0, -1)
	KkthnxUI:SetText("|cff3c9bedKkthnxUI|r")
	KkthnxUI:SetScript("OnClick", function(self)
		if UIConfigMain and UIConfigMain:IsShown() then
			UIConfigMain:Hide()
		else
			CreateUIConfig()
			HideUIPanel(Menu)
		end
	end)

	hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", self.AddHooks)
	self.KkthnxUI = KkthnxUI
end

if IsAddOnLoaded("KkthnxUI_Config") and not IsAddOnLoaded("ConsolePort") then
	GameMenu:EnableKkthnxUIConfig()
end