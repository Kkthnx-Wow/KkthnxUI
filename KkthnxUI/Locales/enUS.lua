local _, _, L = unpack(select(2, ...))
-- Localization for enUS & enGB

local _G = _G

local GetItemClassInfo = _G.GetItemClassInfo
local GetItemSubClassInfo = _G.GetItemSubClassInfo
local LE_ITEM_CLASS_ITEM_ENHANCEMENT = _G.LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_MISCELLANEOUS = _G.LE_ITEM_CLASS_MISCELLANEOUS
local LE_ITEM_CLASS_QUESTITEM = _G.LE_ITEM_CLASS_QUESTITEM
local LE_ITEM_CLASS_TRADEGOODS = _G.LE_ITEM_CLASS_TRADEGOODS

-- Install Localization
L.Install = {
	Step_0 = "Thank you for choosing |cff4488ffKkthnxUI|r!|n|nYou will be guided through the installation process in a few simple steps. At each step you can decide whether or not you want to apply or skip the presented settings.",
	Step_1 = "The first step applies the essential settings. This is |cffff0000recommended|r for any user unless you want to apply only a specific part of the settings.|n|nClick 'Apply' to apply the settings and 'Next' to continue the install process. If you wish to skip this step just press 'Next'.",
	Step_2 = "The second step applies the correct chat setup. If you are a new user this step is recommended. If you are an existing user you may want to skip this step.|n|nClick 'Apply' to apply the settings and 'Next' to continue the install process. If you wish to skip this step just press 'Next'.",
	Step_3 = "Installation is complete. Please click the 'Complete' button to reload the UI. Enjoy KkthnxUI!\n\nVisit us at\n\n|cff7289DADiscord:|r YUmxqQm\n|cff3b5998Facebook:|r @kkthnxui\n|cff00acedTwitter:|r @kkthnxui",
	Welcome_1 = "Welcome to |cff4488ffKkthnxUI|r v",
	Welcome_2 = "Type |cffffbb44/cfg|r to access the in-game configuration menu.",
	Welcome_3 = "If you are in need of support you can visit our Discord |cffffbb44YUmxqQm|r",
}

-- StaticPopups Localization
L.StaticPopups = {
	Cant_Buy_Bank = "You Can't buy anymore bank slots!",
	Changes_Reload = "One or more of the changes you have made require a ReloadUI.",
	Config_Reload = "One or more of the changes you have made require a ReloadUI.",
	Delete_Grays = "|cffff2020WARNING!|r\n\nYou are about to delete all your gray items. You will not receive any currency for this. Do you want to continue?\n\nThe net worth of items being deleted displayed below.",
	Disband_Group = "Are you sure you want to disband the group?"
	KkthnxUI_Update = "KkthnxUI is out of date. You can download the newest version from Curse!",
	No_Bank_Bags = "Please purchase a bank slot first.",
	Restart_GFX = "One or more of the changes you have made require a restart of the graphics engine.",
}

-- Commands Localization
L.Commands = {
	ConfigPerAccount = "Your settings are currently set accross toons so you can't use this command!",
	ProfileNotFound = "Profile not found",
	ProfileSelection = "Please type a profile to use (example: /profile Stormreaver-Kkthnx)",
}

-- ActionBars Localization
L.Actionbars = {
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
L.Announcements = {

}

-- Auras Localization
L.Auras = {

}

-- Automation Localization
L.Automation = {
	DuelCanceled_Regular = "Duel request from %s rejected.",
	DuelCanceled_Pet = "Pet duel request from %s rejected.",
}

-- Blizzard Localization
L.Blizzard = {

}

-- Chat Localization
L.Chat = {
	AFK = "",
	DND = "",
	Guild = "G",
	Instance = "I",
	Instance_Leader = "IL",
	Invaild_Target = "Invaild Target",
	Officer = "O",
	Party = "P",
	Party_Leader = "PL",
	Raid = "R",
	Raid_Leader = "RL",
	Raid_Warning = "RW",
	Says = "S",
	Trade = "Trade",
	Whispers = "W",
	Yells = "Y",
}

-- Configbutton Localization
L.ConfigButton = {
	Functions = "Functions",
	LeftClick = "Left click:",
	RightClick = "Right click:",
	MiddleClick = "Middle click:",
	ShiftClickl = "Shift + Left click:",
	ShiftClickr = "Shift + Right click:",
	AltClickl = "Alt + Left click:",
	MoveUI = "MoveUI",
	Recount = "Toggle Recount",
	Skada = "Toggle Skada",
	Details = "Toggle Details",
	Config = "Toggle Config",
	Roll = "Roll 1-100. You win!",
}

-- Databars Localization
L.Databars = {
	Toggle_Artifact = "<Left-Click to toggle Artifact Window>",
	Toggle_Honor = "<Left-Click to toggle Honor Window>",
	Toggle_Reputation = "<Left-Click to toggle Reputation Window>",
}

-- Datatext Localization
L.Datatext = {

}

-- Inventory Localization
L.Inventory = {
	Artifact_Count = "Count: ",
	Artifact_Use = "Right click to use",
	Buttons_Artifact = "Right click to use Artifact Power item in bag",
	Buttons_Sort = "Left Click: Sort \nRight Click: Blizzard Sort",
	Buttons_Stack = "Stack Items",
	Right_Click_Search = "Right-click to search",
	Shift_Move = "Hold Shift + Drag",
	Show_Bags = "Toggle Bags",
}

-- Loot Localization
L.Loot = {

}

-- Maps Localization
L.Maps = {

}

-- Miscellaneous Localization
L.Miscellaneous = {
	Apr = "Apr",
	Aug = "Aug",
	Config_Not_Found = "KkthnxUI_Config was not found!",
	Copper_Short = "|cffeda55fc|r",
	Dec = "Dec",
	Feb = "Feb",
	Fri = "Fri",
	Gold_Short = "|cffffd700g|r",
	Jan = "Jan",
	Jul = "Jul",
	Jun = "Jun",
	KkthnxUI_Scale_Button = "KkthnxUI Scale Config",
	Mar = "Mar",
	May = "May",
	Mon = "Mon",
	No_Guild = "No Guild",
	Nov = "Nov",
	Oct = "Oct",
	Sat = "Sat",
	Sep = "Sept",
	Silver_Short = "|cffc7c7cfs|r",
	Sun = "Sun",
	Thu = "Thurs",
	Tue = "Tues",
	UIOutdated = "Your version of KkthnxUI is out of date. You can download the newest version from Curse.com. Get the Curse app and have KkthnxUI automatically updated with the Client!",
	Wed = "Wed",
}

-- Nameplates Localization
L.Nameplates = {

}

-- Panels Localization
L.Panels = {

}

-- Quests Localization
L.Quests = {

}

-- Skins Localization
L.Skins = {
	Skada_Reset = "Do you want to reset Skada?",
}

-- Tooltip Localization
L.Tooltip = {
	Bank = "Bank",
	Companion_Pets = GetItemSubClassInfo(LE_ITEM_CLASS_MISCELLANEOUS, 2),
	Count = "Count",
	Item_Enhancement = GetItemClassInfo(LE_ITEM_CLASS_ITEM_ENHANCEMENT),
	Other = GetItemSubClassInfo(LE_ITEM_CLASS_MISCELLANEOUS, 4),
	Quest = GetItemClassInfo(LE_ITEM_CLASS_QUESTITEM),
	Tradeskill = GetItemClassInfo(LE_ITEM_CLASS_TRADEGOODS),
}

-- UnitFrames Localization
L.Unitframes = {
	Dead = "Dead",
	Ghost = "Ghost",
}

-- Config Localization
L.Config = {
	CharSettings = "Use Character Settings",
	ConfigNotFound = "Config not found!",
	GlobalSettings = "Use Global Settings",
}
