-- Lightweight luacheck config for KkthnxUI.
-- Full Blizzard API validation lives in the shared toolchain; this local file
-- just gives std lua51 plus a broad WoW surface so real issues (typos, unused
-- locals, accidental globals) stand out without a full API dump.

std = "lua51+wow"
codes = true
max_line_length = false
self = false

stds.wow = {
	read_globals = {
		"UIParent", "CreateFrame", "hooksecurefunc", "InCombatLockdown",
		"UnitName", "UnitClass", "UnitRace", "UnitFactionGroup", "UnitLevel",
		"UnitPowerType",
		"UnitGUID", "UnitHealth", "UnitHealthMax", "UnitPower", "UnitPowerMax",
		"UnitHealthPercent", "UnitPowerPercent", "UnitClassification",
		"UnitIsPlayer", "UnitInPartyIsAI", "UnitReaction", "UnitIsConnected",
		"UnitIsDeadOrGhost", "UnitIsAFK", "UnitIsDND", "UnitStagger",
		"GetRealmName", "GetLocale", "GetBuildInfo", "GetPhysicalScreenSize",
		"GetGameTime", "ReloadUI", "SetCVar", "RegisterStateDriver",
		"UnregisterStateDriver", "SlashCmdList", "LibStub", "STANDARD_TEXT_FONT",
		"RAID_CLASS_COLORS", "CUSTOM_CLASS_COLORS", "DAMAGE_TEXT_FONT",
		"UnitFrame_OnEnter", "UnitFrame_OnLeave",
		"WOW_PROJECT_ID", "WOW_PROJECT_MAINLINE", "WOW_PROJECT_CLASSIC",
		"WOW_PROJECT_CATACLYSM_CLASSIC", "WOW_PROJECT_MISTS_CLASSIC",
		"C_Map", "C_Timer", "C_AddOns", "Minimap", "MinimapCluster",
		"MinimapZoomIn", "MinimapZoomOut", "MinimapCompassTexture",
		"IsLoggedIn", "geterrorhandler", "issecretvalue", "C_ClassColor", "Enum", "wipe",
		"AbbreviateNumbers", "CurveConstants", "C_CurveUtil", "C_UnitAuras",
		"CreateColor",
		"MAX_BOSS_FRAMES", "PLAYER_OFFLINE", "DEAD", "CHAT_FLAG_AFK", "CHAT_FLAG_DND",
		"InterfaceOptionsCheckButtonTemplate", "OptionsSliderTemplate",
		"GameTooltip", "GameTooltip_Hide", "ColorPickerFrame", "OpacitySliderFrame",
		"UISpecialFrames", "UIPanelButtonTemplate", "InputBoxTemplate",
		"UnitIsPlayer", "UnitReaction", "UnitExists", "GetCreatureDifficultyColor",
		"CUSTOM_CLASS_COLORS", "FACTION_BAR_COLORS", "TooltipDataProcessor",
		"GameTooltip_SetDefaultAnchor", "SharedTooltip_SetBackdropStyle",
		"PVP_ENABLED", "TARGET", "YOU", "UnitIsUnit",
		"NUM_PET_ACTION_SLOTS", "GetNumShapeshiftForms",
		"NUM_CHAT_WINDOWS", "IsShiftKeyDown", "ChatFontNormal",
		"FCF_OpenTemporaryWindow", "ChatFrame_AddMessageEventFilter",
		"UnitClassification", "C_TooltipInfo", "GetGuildInfo",
		"CanInspect", "NotifyInspect", "ClearInspectPlayer", "GetInspectSpecialization",
		"GetSpecializationInfoByID", "GetSpecialization", "GetSpecializationInfo",
		"GetAverageItemLevel", "C_PaperDollInfo", "SPECIALIZATION", "STAT_AVERAGE_ITEM_LEVEL",
		"ToggleChatColorNamesByClassGroup", "SetItemRef", "GetTime", "getmetatable",
		"ClearOverrideBindings", "SetOverrideBindingClick", "GetBindingKey",
		"CompactPartyFrame", "CompactRaidFrameManager", "CompactRaidFrameManager_SetSetting",
		"CompactRaidFrameContainer",
		"ChatTypeInfo", "ChatEdit_UpdateHeader", "ChatFrame_ReplyTell", "RandomRoll", "ChatFrame1",
		"FCFTab_UpdateColors", "CombatLogQuickButtonFrame_CustomTexture", "GeneralDockManager",
		"C_UnitAuras", "DebuffTypeColor", "BuffFrame", "DebuffFrame",
		"GetCursorPosition", "C_Timer", "GetMinimapZoneText", "GetZonePVPInfo",
		"IsInInstance", "IsInRaid", "GetNumGroupMembers", "GetRaidRosterInfo",
		"C_Spell", "strsplit",
		"UnitXP", "UnitXPMax", "GetXPExhaustion", "IsLevelAtEffectiveMaxLevel",
		"IsXPUserDisabled", "IsRestrictedAccount", "IsTrialAccount", "IsVeteranTrialAccount",
		"IsWatchingHonorAsXP", "IsAltKeyDown", "IsInGroup", "C_ChatInfo",
		"UnitHonor", "UnitHonorMax", "UnitHonorLevel", "UIFrameFadeIn", "UIFrameFadeOut",
		"UIFrameFadeRemoveFrame", "C_Reputation", "C_GossipInfo", "C_MajorFactions",
		"C_AzeriteItem", "C_NeighborhoodInitiative", "C_Texture", "StatusTrackingBarManager",
		"FACTION_BAR_COLORS", "RENOWN_LEVEL_LABEL", "UNKNOWN", "COMBAT_XP_GAIN", "REPUTATION",
		"HONOR", "AZERITE_POWER", "LEVEL", "MAXIMUM", "REWARD_AVAILABLE",
		"ERR_QUEST_PUSH_NOT_IN_PARTY_S",
		"issecurevariable", "HideUIPanel", "PanelTemplates_GetSelectedTab",
		"DUNGEON_SCORE_LINK_ITEM_LEVEL", "GetInventoryItemQuality", "C_Item",
		"UpdateMicroButtons", "C_Container", "NUM_BAG_SLOTS", "GetItemButtonIconTexture", "EventRegistry", "MainMenuBarBagManager", "C_NamePlate",
		"C_Bank", "C_NewItems", "C_MerchantFrame", "GetMoney", "GetCoinTextureString", "ItemLocation",
		"C_CurrencyInfo", "BreakUpLargeNumbers", "MerchantFrame", "GetScreenWidth", "TooltipComparisonManager",
		"C_QuestLog", "C_GossipInfo", "C_PlayerInteractionManager", "IsControlKeyDown", "Item", "GetInstanceInfo",
		"GetNumActiveQuests", "GetActiveTitle", "GetActiveQuestID", "SelectActiveQuest", "GetNumAvailableQuests",
		"GetAvailableQuestInfo", "SelectAvailableQuest", "GetQuestID", "QuestGetAutoAccept", "QuestIsFromAreaTrigger",
		"AcknowledgeAutoAcceptQuest", "RemoveAutoQuestPopUp", "AcceptQuest", "ConfirmAcceptQuest", "GetNumAutoQuestPopUps",
		"GetAutoQuestPopUp", "ShowQuestOffer", "ShowQuestComplete", "QuestLogPushQuest", "IsQuestCompletable",
		"CompleteQuest", "GetNumQuestChoices", "GetQuestItemInfo", "GetQuestReward",
		"SHIFT_KEY_TEXT", "CTRL_KEY_TEXT", "ALT_KEY_TEXT", "NONE",
		"CancelDuel", "StaticPopup_Hide", "C_PetBattles", "CinematicFrame_CancelCinematic", "MovieFrame",
		"GetInventoryItemLink",
		"AlertFrame", "GroupLootContainer", "SetItemButtonTextureVertexColor", "GetMerchantNumItems",
		"GetMerchantItemLink", "GetNumBuybackItems", "GetBuybackItemInfo", "GetBuybackItemLink",
		"GetCurrentGuildBankTab", "GetGuildBankItemInfo", "GetGuildBankItemLink", "C_PetJournal",
		"C_TransmogCollection", "IsPartyLFG", "UnitAffectingCombat", "GetAreaText", "GetGuildRosterInfo",
		"GetGuildTradeSkillInfo", "GetQuestDifficultyColor", "C_FriendList", "C_BattleNet", "GetCVar",
		"COLLECTED", "NOT_COLLECTED", "SOURCE",
		"C_ChatBubbles", "GetCVarBool", "PawnShouldItemLinkHaveUpgradeArrowUnbudgeted",
		"AnchorUtil", "CustomAuraContainerAuraProcessingPolicy", "AuraContainerSortMethod", "AuraContainerSortDirection", "C_StringUtil",
		"CanMerchantRepair", "GetRepairAllCost", "RepairAllItems", "CanGuildBankRepair",
		"GetGuildBankWithdrawMoney", "IsInGuild",
		"FCF_ResetChatWindows", "FCF_SetLocked", "FCF_SetWindowName", "FCF_OpenNewWindow", "FCF_DockFrame",
		"ChatFrame_RemoveAllMessageGroups", "ChatFrame_AddMessageGroup", "ChatFrame_AddChannel", "ChatFrame_RemoveChannel",
		"GENERAL", "TRADE", "COMBAT_LOG", "PlaySound", "SOUNDKIT",
		"GetOverrideBarIndex", "GetVehicleBarIndex", "GetTempShapeshiftBarIndex",
		"UnitStat", "UnitArmor", "GetCritChance", "GetHaste", "GetMasteryEffect", "GetCombatRatingBonus",
		"GetVersatilityBonus", "GetLifesteal", "GetAvoidance", "GetSpeed", "GetDodgeChance", "GetParryChance",
		"GetBlockChance", "CR_VERSATILITY_DAMAGE_DONE", "CharacterStatsPane", "PaperDollFrame_UpdateStats",
		"STAT_STRENGTH", "STAT_AGILITY", "STAT_STAMINA", "STAT_INTELLECT", "STAT_ARMOR", "STAT_CRITICAL_STRIKE",
		"STAT_HASTE", "STAT_MASTERY", "STAT_VERSATILITY", "STAT_LIFESTEAL", "STAT_AVOIDANCE", "STAT_SPEED",
		"STAT_DODGE", "STAT_PARRY", "STAT_BLOCK", "STAT_CATEGORY_ATTRIBUTES", "STAT_CATEGORY_ENHANCEMENTS",
		"GetSpecialization", "GetSpecializationInfo", "UnitThreatSituation", "GetThreatStatusColor",
		"SetItemButtonTexture", "SetItemButtonCount", "SetItemButtonDesaturated", "CooldownFrame_Set", "BankFrame",
		"UnitIsAFK", "UnitIsDND", "C_MountJournal", "C_PlayerInfo", "MOUNT", "DUNGEON_SCORE",
		"UnitGroupRolesAssigned", "FROM", "CancelUnitBuff",
		"GameTimeFrame", "TimeManagerClockButton", "MinimapNorthTag", "AddonCompartmentFrame",
	},
	globals = {
		"KkthnxUI", "KkthnxUIDB",
		"SLASH_KKTHNXUI1", "SLASH_KKTHNXUI2",
		"SLASH_KKUI_PULL1", "SLASH_KKUI_PULL2",
	},
}

ignore = {
	"212", -- unused argument (common in event handlers)
	"432", -- shadowing an upvalue argument
	"143/string", -- the embedded UTF8 library adds utf8len/utf8sub to string
	"122/SlashCmdList", -- registering a slash handler is exactly this write
}

exclude_files = {
	"Libraries",
	"Media",
}
