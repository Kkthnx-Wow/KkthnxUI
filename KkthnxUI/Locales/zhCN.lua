local K, _, L = unpack(select(2, ...))
-- Localization for ruRU

if (GetLocale() ~= "zhCN") then
	return
end

local _G = _G

local GetItemClassInfo = _G.GetItemClassInfo
local GetItemSubClassInfo = _G.GetItemSubClassInfo
local LE_ITEM_CLASS_ITEM_ENHANCEMENT = _G.LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_MISCELLANEOUS = _G.LE_ITEM_CLASS_MISCELLANEOUS
local LE_ITEM_CLASS_QUESTITEM = _G.LE_ITEM_CLASS_QUESTITEM
local LE_ITEM_CLASS_TRADEGOODS = _G.LE_ITEM_CLASS_TRADEGOODS

-- Install Localization
L["Install"] = {
	Chat_Set = "Chat Set",
	CVars_Set = "CVars Set",
	Step_0 = "Thank you for choosing |cff4488ffKkthnxUI|r!|n|nYou will be guided through the installation process in a few simple steps. At each step you can decide whether or not you want to apply or skip the presented settings.",
	Step_1 = "The first step applies the essential settings. This is |cffff0000recommended|r for any user unless you want to apply only a specific part of the settings.|n|nClick 'Apply' to apply the settings and 'Next' to continue the install process. If you wish to skip this step just press 'Next'.",
	Step_2 = "The second step applies the correct chat setup. If you are a new user this step is recommended. If you are an existing user you may want to skip this step.|n|nClick 'Apply' to apply the settings and 'Next' to continue the install process. If you wish to skip this step just press 'Next'.",
	Step_3 = "Installation is complete. Please click the 'Complete' button to reload the UI. Enjoy KkthnxUI!",
	Welcome_1 = "Welcome to |cff4488ffKkthnxUI|r v"..K.Version.." "..K.Client..", "..string.format("|cff%02x%02x%02x%s|r", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255, K.Name),
	Welcome_2 = "Type |cffffbb44/cfg|r to access the in-game configuration menu.",
	Welcome_3 = "If you are in need of support you can visit our Discord |cffffbb44YUmxqQm|r",

	StepTitle_0 = "WELCOME",
	StepTitle_1 = "CVARS",
	StepTitle_2 = "CHAT",
	StepTitle_3 = "COMPLETE",
}

-- StaticPopups Localization
L["StaticPopups"] = {
	BoostUI = "Accepting this will adjust your GFX(Graphics) settings to 'try' to improve your FPS.",
	Cancel = "You have canceled this dialog.",
	Changes_Reload = "One or more of the changes you have made require a ReloadUI.",
	Config_Reload = "One or more of the changes you have made require a ReloadUI.",
	Delete_Grays = "Delete gray items?",
	Disband_Group = "Are you sure you want to disband the group?",
	Fix_Actionbars = "There seems to be an issue with your actionbars. Would you like to attempt to fix the issue?",
	KkthnxUI_Update = "KkthnxUI is out of date. You can download the newest version from Curse!",
	Reset_UI = "Are you sure you want to reset all the settings on this profile?",
	Resolution_Changed = "We detected a resolution change on your World of Warcraft client. We HIGHLY RECOMMEND restarting your game. Do you want to proceed?",
	Restart_GFX = "One or more of the changes you have made require a restart of the graphics engine.",
	Set_UI_Scale = "Automatically scale the User Interface based on your screen resolution?",
	Warning_Blizzard_AddOns = "It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled.",
	WoWHeadLink = "Wowhead Link",
}

-- Commands Localization
L["Commands"] = {
	AbandonQuests = "All quests that are NOT marked complete, have been abandoned!",
	BlizzardAddOnsOn = "The following addon was re-enabled: ",
	CheckQuestInfo = "\nEnter questID found in Wowhead URL\nhttp://wowhead.com/quest=ID\nExample: /checkquest 12045\n",
	CheckQuestComplete = " has been completed!",
	CheckQuestNotComplete = " has not been completed!",
	ConfigNotFound = "KkthnxUI config not found!",
	ConfigPerAccount = "Your settings are currently set across all your characters! You can't use this command!",
	FixParty = "\n|cff4488ff".."If you are still stuck in party, try the following".."|r\n\n|cff00ff001.|r Invite someone to a group and have them accept.\n|cff00ff002.|r Convert your group to a raid.\n|cff00ff003.|r Use the previous leave party command again.\n|cff00ff004.|r Invite your friend back to a group.\n\n",
	LuaErrorInfo = "|cffff0000/luaerror on - /luaerror off|r",
	LuaErrorOff = "|cffff0000Lua errors off.|r",
	Profile = "Profile ",
	ProfileDel = " Deleted: ",
	ProfileInfo = "\n/profile list\n/profile #\n/profile delete #\n\n",
	ProfileNotFound = "Profile not found",
	ProfileSelection = "Please type a profile to use (example: /profile Stormreaver-Kkthnx)",
	SetUIScale = "KkthnxUI is already controlling the Auto UI Scale feature!",
	SetUIScaleSucc = "Successfully set UI scale to ",
	UIHelp = "\nKkthnxUI Commands:\n\n'|cff00ff00/install|r' or '|cff00ff00/reset|r' : Install or reset KkthnxUI to default settings.\n'|cff00ff00/config|r' : Display in-game configuration window.\n'|cff00ff00/moveui|r' : Move Frames.\n'|cff00ff00/testui|r' : Test Unit Frames.\n'|cff00ff00/profile|r' : Use KkthnxUI settings (existing profile) from another character.\n'|cff00ff00/killquests|r' : Remove all non completed quests.\n'|cff00ff00/clearcombat|r' : Clear all CombatLog entries.\n'|cff00ff00/setscale|r' : Sets the UI to pixel perfect.\n'|cff00ff00/rd|r' : Disbands your raid group.\n'|cff00ff00/clearchat|r' : Clear everything in your chat window.\n'|cff00ff00/checkquest|r' : Check if you have completed a quest or not.\n",
}

-- ActionBars Localization
L["Actionbars"] = {
	All_Binds_Cleared = "All keybindings cleared for",
	All_Binds_Discarded = "All newly set keybindings were discarded.",
	All_Binds_Saved = "All keybindings have been saved.",
	Binding = "Binding",
	Fix_Actionbars = "There seems to be an issue with your actionbars. Would you like to attempt to fix the issue?",
	Key = "Key",
	Keybind_Mode = "Hover, your mouse over any action button, to bind it. Press the escape key or right click to clear the current action button's keybinding.",
	Locked = "|CFFFF0000Locked|r",
	No_Bindings_Set = "No Bindings Set",
	Trigger = "Trigger",
	Unlocked = "|CFF008000Unlocked|r",
}

-- AFKCam Localization
L["AFKCam"] = {
	NoGuild = "No Guild",
}

-- AddOnsData Localization
L["AddOnData"] = {
	AllAddOnsText = "All supported AddOn profiles loaded, if the AddOn is loaded!",
	InfoText = "|cffffff00The following commands are supported for AddOn profiles.|r\n\n|cff00ff00/settings dbm|r, to apply the settings |cff00ff00DeadlyBossMods.|r\n|cff00ff00/settings msbt|r, to apply the settings |cff00ff00MikScrollingBattleText.|r\n|cff00ff00/settings skada|r, to apply the settings |cff00ff00Skada.|r\n|cff00ff00/settings bt4 or bartender|r, to apply the settings |cff00ff00Bartender4.|r\n|cff00ff00/settings buggrabber|r, to apply the settings |cff00ff00!BugGrabber.|r\n|cff00ff00/settings bugsack|r, to apply the settings |cff00ff00BugSack.|r\n|cff00ff00/settings bugsack|r, to apply the settings |cff00ff00BugSack.|r\n|cff00ff00/settings pawn|r, to apply the settings |cff00ff00Pawn.|r\n|cff00ff00/settings bigwigs|r, to apply the settings |cff00ff00BigWigs.|r\n|cff00ff00/settings all|r, to apply settings for all supported AddOns, if that AddOn is loaded!\n\n",
	BigWigsText = "|cffffff00".."BigWigs profile loaded".."|r",
	BigWigsNotText = "|CFFFF0000AddOn BigWigs is not loaded!|r",
	BartenderText = "|cffffff00".."Bartender4 profile loaded".."|r",
	BartenderNotText = "|CFFFF0000AddOn Bartender4 is not loaded!|r",
	BugGrabberText = "|cffffff00".."BugGrabber profile loaded".."|r",
	BugGrabberNotText = "|CFFFF0000AddOn !BugGrabber is not loaded!|r",
	BugSackText = "|cffffff00".."BugSack profile loaded".."|r",
	BugSackNotText = "|CFFFF0000AddOn BugSack is not loaded!|r",
	DBMText = "|cffffff00".."DBM profile loaded".."|r",
	DBMNotText = "|CFFFF0000AddOn DeadlyBossMods is not loaded!|r",
	MSBTText = "|cffffff00".."MikScrollingBattleText profile loaded".."|r",
	MSBTNotText = "|CFFFF0000AddOn MikScrollingBattleText is not loaded!|r",
	PawnText = "|cffffff00".."Pawn profile loaded".."|r",
	PawnNotText ="|CFFFF0000AddOn Pawn is not loaded!|r",
	SkadaText = "|cffffff00".."Skada profile loaded".."|r",
	SkadaNotText = "|CFFFF0000AddOn Skada is not loaded!|r",
}

-- Announcements Localization
L["Announcements"] = {
	Pull_Aborted = "Pull ABORTED!",
	Pulling = "Pulling %s in %s..",
	Sapped = "Sapped!",
	Sapped_By = "Sapped by: ",
}

-- Auras Localization
L["Auras"] = {

}

-- Automation Localization
L["Automation"] = {
	DuelCanceled_Pet = "Pet duel request from %s rejected.",
	DuelCanceled_Regular = "Duel request from %s rejected.",
	MovieBlocked = "You've seen this movie before, skipping it.",
}

-- Blizzard Localization
L["Blizzard"] = {
	Disband_Group = "Disband Group",
	No_Errors = "No error yet.",
	Raid_Menu = "Raid Menu",
}

-- Chat Localization
L["Chat"] = {
	AFK = "",
	DND = "",
	Invaild_Target = "Invaild Target",
	-- Channel Names
	Conversation = "Conversation",
	General = "General",
	LocalDefense = "LocalDefense",
	LookingForGroup = "LookingForGroup",
	Trade = "Trade",
	WorldDefense = "WorldDefense",
	-- Short Channel Names
	S_Conversation = "C",
	S_General = "G",
	S_Guild = "g",
	S_InstanceChat = "i",
	S_InstanceChatLeader = "I",
	S_LocalDefense = "LD",
	S_LookingForGroup = "LFG",
	S_Officer = "o",
	S_Party = "p",
	S_PartyGuide = "PG",
	S_PartyLeader = "PL",
	S_Raid = "r",
	S_RaidLeader = "R",
	S_RaidWarning = "W",
	S_Say = "s",
	S_Trade = "T",
	S_WhisperIncoming = "w",
	S_WhisperOutgoing = "@",
	S_WorldDefense = "WD",
	S_Yell = "y",
}

-- Configbutton Localization
L["ConfigButton"] = {
	ActionbarLock = "Actionbar Lock",
	Changelog = "Changelog",
	CopyChat = "Copy chat",
	Emotions = "Emotions",
	Functions = "Functions",
	Install = "Install",
	LeftClick = "Left click:",
	MiddleClick = "Middle click:",
	MoveUI = "MoveUI",
	ProfileList = "Profile list",
	Right_Click = "Right click:",
	Roll = "Roll 1-100. You win!",
	ToggleConfig = "Toggle Config",
	UIHelp = "UI Help",
}

-- Databars Localization
L["Databars"] = {
	AP = "AP:",
	Bars = "Bars",
	Current_Level = "Current Level:",
	Experience = "Experience",
	Honor_Remaining = "Honor Remaining:",
	Honor_XP = "Honor XP:",
	Remaining = "Remaining:",
	Rested = "Rested:",
	Share = "Share Your Experience",
	Toggle_PvP = "Toggle PvP UI",
	Toggle_Reputation = "Toggle Reputation UI",
	XP = "XP:",
}

-- Datatext Localization
L["DataText"] = {
	BaseAssault = "Bases Assaulted:",
	BaseDefend = "Bases Defended:",
	CallToArms = "Call to Arms",
	CartControl = "Carts Controlled:",
	ControlBy = "Controlled by:",
	Damage = "Damage: ",
	DamageDone = "Damage Done:",
	Death = "Deaths:",
	DemolisherDestroy = "Demolishers Destroyed:",
	FlagCapture = "Flags Captured:",
	FlagReturn = "Flags Returned:",
	GateDestroy = "Gates Destroyed:",
	GraveyardAssault = "Graveyards Assaulted:",
	GraveyardDefend = "Graveyards Defended:",
	Healing = "Healing: ",
	HealingDone = "Healing Done:",
	Honor = "Honor: ",
	HonorableKill = "Honorable Kills:",
	HonorGained = "Honor Gained:",
	KillingBlow = "Killing Blows: ",
	OrbPossession = "Orb Possessions:",
	StatsFor = "Stats for ",
	TowerAssault = "Towers Assaulted:",
	TowerDefend = "Towers Defended:",
	VictoryPts = "Victory Points:",
}

-- Inventory Localization
L["Inventory"] = {
	Artifact_Count = "Count: ",
	Artifact_Use = "|cff02FF02|nRight click to use|r",
	Bank = "Switch to Bank",
	--Buttons_Artifact = "|cff02FF02|nRight click to use Artifact Power item in bag|r",
	Buttons_Sort = "Left Click: Sort |nRight Click: Blizzard Sort",
	Buttons_Stack = "Stack Items",
	Cant_Buy_Slot = "Can't buy anymore slots!",
	GuildRepair = "Your items have been repaired using guild bank funds for: ",
	NotatVendor = "You must be at a vendor.",
	NotEnoughMoney = "You don't have enough money to repair!",
	Purchase_Slot = "Purchase Bags Slot",
	Reagents = "Switch to reagents",
	RepairCost = "Your items have been repaired for: ",
	Right_Click_Search = "Right-click to search",
	Shift_Move = "Hold Shift + Drag",
	Show_Bags = "Toggle Bags",
	SoldTrash = "Vendored gray items for: ",
	TrashList = "|n|nTrash List:|n",
	VendorGrays = "Vendoring Grays",
}

-- Loot Localization
L["Loot"] = {
	Empty_Slot = "Empty Slot",
	Fishy_Loot = "Fishy Loot",
}

-- Maps Localization
L["Maps"] = {
	DisableToHide = "Disable to hide areas|nyou have not yet discovered.",
	EnableToShow = "Enable to show hidden areas|nyou have not yet discovered.",
	HideUnDiscovered = "Hide Undiscovered Areas",
	PressToCopy = "|nPress <CTRL/C> to copy.",
	Reveal = "Reveal",
	RevealHidden = "Reveal Hidden Areas",
	Spotted = "spotted! ",
	TomTom = "Enable AddOn TomTom for this feature. You can download it from Curse",
}

-- Miscellaneous Localization
L["Miscellaneous"] = {
	Config_Not_Found = "KkthnxUI_Config was not found!",
	Copper_Short = "|cffeda55fc|r",
	Gold_Short = "|cffffd700g|r",
	KkthnxUI_Scale_Button = "KkthnxUI Scale Config",
	Mail_Complete = "All done.",
	Mail_Messages = "messages",
	Mail_Need = "Need a mailbox.",
	Mail_Stopped = "Stopped, inventory is full.",
	Mail_Unique = "Stopped. Found a duplicate unique item in bag or in bank.",
	Repair = "Warning! You need to do a repair of your equipment as soon as possible!",
	Silver_Short = "|cffc7c7cfs|r",
	UIOutdated = "Your version of KkthnxUI is out of date. You can download the newest version from Curse.com. Get the Curse app and have KkthnxUI automatically updated with the Client!",
}

-- Nameplates Localization
L["Nameplates"] = {

}

-- Panels Localization
L["Panels"] = {

}

-- Quests Localization
L["Quests"] = {

}

-- RaidCooldown
L["RaidCooldown"] = {
	Cooldown = "CD: ",
	Combatress = "BattleRes",
	Combatress_Remainder = "Battle Resurrection: ",
	Nexttime = "Next time: ",
}

-- Skins Localization
L["Skins"] = {
	Skada_Reset = "Do you want to reset Skada?",
}

-- Tooltip Localization
L["Tooltip"] = {
	Bank = "Bank",
	Companion_Pets = GetItemSubClassInfo(LE_ITEM_CLASS_MISCELLANEOUS, 2),
	Count = "Count",
	Item_Enhancement = GetItemClassInfo(LE_ITEM_CLASS_ITEM_ENHANCEMENT),
	Other = GetItemSubClassInfo(LE_ITEM_CLASS_MISCELLANEOUS, 4),
	Quest = GetItemClassInfo(LE_ITEM_CLASS_QUESTITEM),
	Tradeskill = GetItemClassInfo(LE_ITEM_CLASS_TRADEGOODS),
}

-- UnitFrames Localization
L["Unitframes"] = {
	Dead = "Dead",
	Ghost = "Ghost",
}

-- Config Localization
L["Config"] = {
	CharSettings = "Use Character Settings",
	ConfigNotFound = "Config not found!",
	GlobalSettings = "Use Global Settings",
	ResetCVars = "Reset CVars",
	ResetChat = "Reset Chat",
}