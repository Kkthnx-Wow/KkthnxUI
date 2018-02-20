local _, _, L = unpack(select(2, ...))
-- Localization for ruRU

if (GetLocale() ~= "ruRU") then
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
	Step_3 = "Installation is complete. Please click the 'Complete' button to reload the UI. Enjoy KkthnxUI!|n|nVisit us at|n|n|cff7289DADiscord:|r YUmxqQm|n|cff3b5998Facebook:|r @kkthnxui|n|cff00acedTwitter:|r @kkthnxui",
	Welcome_1 = "Welcome to |cff4488ffKkthnxUI|r v",
	Welcome_2 = "Type |cffffbb44/cfg|r to access the in-game configuration menu.",
	Welcome_3 = "If you are in need of support you can visit our Discord |cffffbb44YUmxqQm|r",
}

-- StaticPopups Localization
L["StaticPopups"] = {
	Changes_Reload = "One or more of the changes you have made require a ReloadUI.",
	Config_Reload = "One or more of the changes you have made require a ReloadUI.",
	Delete_Grays = "|cffff2020WARNING!|r|n|nYou are about to delete all your gray items. You will not receive any currency for this. Do you want to continue?|n|nThe net worth of items being deleted displayed below.",
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
	Config = "'|cff00ff00/config|r' : Display in-game configuration window.",
	ConfigPerAccount = "Your settings are currently set accross toons so you can't use this command!",
	Install = "'|cff00ff00/install|r' or '|cff00ff00/reset|r' : Install or reset KkthnxUI to default settings.",
	Move = "'|cff00ff00/moveui|r' : Move Frames.",
	Profile = "'|cff00ff00/profile|r' : Use KkthnxUI settings (existing profile) from another character.",
	ProfileNotFound = "Profile not found",
	ProfileSelection = "Please type a profile to use (example: /profile Stormreaver-Kkthnx)",
	Test = "'|cff00ff00/testui|r' : Test Unit Frames.",
	Title = "KkthnxUI Commands:",
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
	No_Bindings_Set = "No Bindings Set",
	Trigger = "Trigger",
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
	Lua_Error_Recieved = "|cFFE30000Lua error recieved. You can view the error message when you exit combat.",
	No_Errors = "No error yet.",
	Raid_Menu = "Raid Menu",
	Taint_Error = "%s: %s tried to call the protected function '%s'.",
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
	AltClickl = "Alt + Left click:",
	Config = "Toggle Config",
	Details = "Toggle Details",
	Functions = "Functions",
	LeftClick = "Left click:",
	MiddleClick = "Middle click:",
	MoveUI = "MoveUI",
	Recount = "Toggle Recount",
	Right_Click = "Right click:",
	Roll = "Roll 1-100. You win!",
	Shift_Left_Click = "Shift + Left click:",
	Shift_Right_Click = "Shift + Right click:",
	Skada = "Toggle Skada",
	Toggle_Bags = "Toggle Bags",
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
	Toggle_Artifact = "<Left-Click to toggle Artifact Window>",
	Toggle_Honor = "<Left-Click to toggle Honor Window>",
	Toggle_Reputation = "<Left-Click to toggle Reputation Window>",
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
	Artifact_Use = "Right click to use",
	Buttons_Artifact = "Right click to use Artifact Power item in bag",
	Buttons_Sort = "Left Click: Sort |nRight Click: Blizzard Sort",
	Buttons_Stack = "Stack Items",
	Cant_Buy_Slot = "Can't buy anymore slots!",
	NotEnoughMoney = "You don't have enough money to repair!",
	Purchase_Slot = "Purchase Bags Slot",
	RepairCost = "Your items have been repaired for",
	Right_Click_Search = "Right-click to search",
	Shift_Move = "Hold Shift + Drag",
	Show_Bags = "Toggle Bags",
	SoldTrash = "Your vendor trash has been sold and you earned",
	TrashList = "|n|nTrash List:|n",
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
}