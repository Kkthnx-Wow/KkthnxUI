local K, C, L = select(2, ...):unpack()
-- Localization FOR ENUS & ENGB CLIENTS

-- AFKSpin Localization
L_AFKSCREEN_NOGUILD = "No Guild"

-- Announce Localization
L_ANNOUNCE_FP_USE = "%s used %s."
L_ANNOUNCE_INTERRUPTED = INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!"
L_ANNOUNCE_PC_ABORTED = "Pull ABORTED!"
L_ANNOUNCE_PC_GO = "GO!"
L_ANNOUNCE_PC_MSG = "Pulling %s in %s.."
L_ANNOUNCE_SAPPED = "Sapped"
L_ANNOUNCE_SAPPED_BY = "Sapped by: "

-- Auras Localization
L_AURAS_MOVEBUFFS = "Move Buffs"
L_AURAS_MOVEDEBUFFS = "Move Debuffs"

-- F.A.Q
L_FAQ_BUTTON_01 = "General"
L_FAQ_BUTTON_02 = "Action Bars"
L_FAQ_BUTTON_03 = "Unit Frames"
L_FAQ_BUTTON_04 = "Chat"
L_FAQ_BUTTON_05 = "UI Commands"
L_FAQ_BUTTON_06 = "Keybindings"
L_FAQ_BUTTON_07 = "Minimap"
L_FAQ_BUTTON_08 = "Bags"
L_FAQ_BUTTON_09 = "Misc."
L_FAQ_BUTTON_10 = "Bug Reports"
L_FAQ_BUTTON_11 = "UI Update"
L_FAQ_CONTENT10TEXT1 = ""
L_FAQ_CONTENT10TEXT2 = ""
L_FAQ_CONTENT10TITLE = "|cff3c9bedOMG Errors|r"
L_FAQ_CONTENT11TEXT1 = ""
L_FAQ_CONTENT11TEXT2 = ""
L_FAQ_CONTENT11TITLE = "|cff3c9bedUpdating UI|r"
L_FAQ_CONTENT1TEXT1 = ""
L_FAQ_CONTENT1TEXT2 = ""
L_FAQ_CONTENT1TITLE = "|cff3c9bedGeneral|r"
L_FAQ_CONTENT2TEXT1 = ""
L_FAQ_CONTENT2TEXT2 = ""
L_FAQ_CONTENT2TITLE = "|cff3c9bedActionbars|r"
L_FAQ_CONTENT3TEXT1 = ""
L_FAQ_CONTENT3TEXT2 = ""
L_FAQ_CONTENT3TITLE = "|cff3c9bedUnitframes|r"
L_FAQ_CONTENT4TEXT1 = ""
L_FAQ_CONTENT4TEXT2 = ""
L_FAQ_CONTENT4TITLE = "|cff3c9bedChat|r"
L_FAQ_CONTENT5TEXT1 = "The following chat commands are available to you:"
L_FAQ_CONTENT5TEXT2 = "/rl - Reload interface./n/rc - Activates a ready check.\n/gm - Opens GM frame.\n/rd - Disband party or raid.\n/toraid - Convert to party or raid.\n/teleport - Teleportation from random dungeon.\n/spec, /ss - Switches between talent spec's.\n/frame - Description is not ready.\n/farmmode - Increase the size of the minimap.\n/moveui - Allows the movement of interface elements.\n/resetui - Resets general settings to default.\n/resetconfig - Resets KkthnxUI_Config settings.\n/settings ADDON_NAME - Applies settings to msbt, dbm, skada, or all addons.\n/pulsecd - Self cooldown pulse test.\n/tt - Whisper target.\n/ainv - Enables automatic invitation.\n/cfg - Opens interface settings.\n/patch - Display Wow patch info."
L_FAQ_CONTENT5TITLE = "|cff3c9bedUI Slashcommands|r"
L_FAQ_CONTENT6TEXT1 = ""
L_FAQ_CONTENT6TEXT2 = ""
L_FAQ_CONTENT6TITLE = "|cff3c9bedKeybinding|r"
L_FAQ_CONTENT7TEXT1 = ""
L_FAQ_CONTENT7TEXT2 = ""
L_FAQ_CONTENT7TITLE = "|cff3c9bedMinimap|r"
L_FAQ_CONTENT8TEXT1 = ""
L_FAQ_CONTENT8TEXT2 = ""
L_FAQ_CONTENT8TITLE = "|cff3c9bedBags|r"
L_FAQ_CONTENT9TEXT1 = ""
L_FAQ_CONTENT9TEXT2 = ""
L_FAQ_CONTENT9TITLE = "|cff3c9bedMisc.|r"
L_FAQ_GENERALTEXT1 = "|cffffff00Welcome to |cff3c9bedKkthnxUI|r v"..K.Version.." "..K.Client..", "..format("|cff%02x%02x%02x%s|r", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255, K.Name).."|r \n\nUse the menu on the left to learn more about the individual points about the UI."
L_FAQ_GENERALTEXT2 = ""
L_FAQ_GENERALTITLE = "|cff3c9bedKkthnxUI - Frequently Asked Question(s).|r"

-- Merchant Localization
L_MERCHANT_NOTENOUGHMONEY = "You don't have enough money to repair!"
L_MERCHANT_REPAIRCOST = "Your items have been repaired for"
L_MERCHANT_SOLDTRASH = "Your vendor trash has been sold and you earned"

-- Bindings Localization
L_BIND_BINDING = "Binding"
L_BIND_CLEARED = "All keybindings cleared for"
L_BIND_DISCARD = "All newly set keybindings were discarded."
L_BIND_INSTRUCT = "Hover, your mouse over any action button, to bind it. Press the escape key or right click to clear the current action button's keybinding."
L_BIND_KEY = "Key"
L_BIND_NO_SET = "No bindings set"
L_BIND_SAVED = "All keybindings have been saved."

-- Chat Localization
L_CHAT_AFK = "|cffff0000[AFK]|r"
L_CHAT_DND = "|cffe7e716[DND]|r"
L_CHAT_GUILD = "G"
L_CHAT_GUILDRECRUITMENT = "GuildRecruitment"
L_CHAT_INSTANCE = "I"
L_CHAT_INSTANCE_LEADER = "IL"
L_CHAT_LOCALDEFENSE = "LocalDefense"
L_CHAT_LOOKINGFORGROUP = "LookingForGroup"
L_CHAT_OFFICER = "O"
L_CHAT_PARTY = "P"
L_CHAT_PARTY_LEADER = "P"
L_CHAT_RAID = "R"
L_CHAT_RAID_LEADER = "R"
L_CHAT_RAID_WARNING = "W"
L_CHAT_PET_BATTLE = "Pet Battle"

-- Configbutton Localization
L_CONFIGBUTTON_FUNC = "Buttonfunctions:"
L_CONFIGBUTTON_LEFTCLICK = "Left click:"
L_CONFIGBUTTON_RIGHTCLICK = "Right click:"
L_CONFIGBUTTON_MIDDLECLICK = "Middle click:"
L_CONFIGBUTTON_SHIFTCLICK = "Shift + click:"
L_CONFIGBUTTON_MOVEUI = "Move UI Elements"
L_CONFIGBUTTON_RECOUNT = "Show/Hide Recount Frame"
L_CONFIGBUTTON_SKADA = "Show/Hide Skada Frame"
L_CONFIGBUTTON_CONFIG = "Show KkthnxUI Configmenu"
L_CONFIGBUTTON_SPEC = "Show KkthnxUI-Specmenu"
L_CONFIGBUTTON_SPECMENU = "Specialization selection"
L_CONFIGBUTTON_SPECERROR = "You already have this spec active!"

-- Cooldowns
L_COOLDOWNS = "CD: "
L_COOLDOWNS_COMBATRESS = "BattleRes"
L_COOLDOWNS_COMBATRESS_REMAINDER = "Battle Resurrection: "
L_COOLDOWNS_NEXTTIME = "Next time: "

-- DataBars Localization
L_DATABARS_ARTIFACT_CLICK = "Click: Opens the artifact overview"
L_DATABARS_ARTIFACT_REMANING = "|cffe6cc80Remaining: %s|r"
L_DATABARS_HONOR_LEFTCLICK = "|cffccccccLeft Click: Opens the honor frame|r"
L_DATABARS_HONOR_RIGHTCLICK = "|cffccccccRight Click: Opens the honor talents frame|r"

-- DataText Localization
L_DATATEXT_ARMERROR = "Could not get Call To Arms information."
L_DATATEXT_AVOIDANCESHORT = "Avd: "
L_DATATEXT_BAGS = "Bags"
L_DATATEXT_BANDWIDTH = "Bandwidth: "
L_DATATEXT_BASESASSAULTED = "Bases Assaulted:"
L_DATATEXT_BASESDEFENDED = "Bases Defended:"
L_DATATEXT_CARTS_CONTROLLED = "Carts Controlled:"
L_DATATEXT_COMBATTIME = "Combat/Arena Time"
L_DATATEXT_COORDS = "Coords"
L_DATATEXT_DEMOLISHERSDESTROYED = "Demolishers Destroyed:"
L_DATATEXT_DOWNLOAD = "Download: "
L_DATATEXT_FLAGSCAPTURED = "Flags Captured:"
L_DATATEXT_FLAGSRETURNED = "Flags Returned:"
L_DATATEXT_FPS = "FPS"
L_DATATEXT_GATESDESTROYED = "Gates Destroyed:"
L_DATATEXT_GOLDDEFICIT = "Deficit: "
L_DATATEXT_GOLDEARNED = "Earned: "
L_DATATEXT_GOLDPROFIT = "Profit: "
L_DATATEXT_GOLDSERVER = "Server: "
L_DATATEXT_GOLDSPENT = "Spent: "
L_DATATEXT_GOLDTOTAL = "Total: "
L_DATATEXT_GRAVEYARDSASSAULTED = "Graveyards Assaulted:"
L_DATATEXT_GRAVEYARDSDEFENDED = "Graveyards Defended:"
L_DATATEXT_GUILDNOGUILD = "No Guild"
L_DATATEXT_LOOTSPEC_CHANGE = "|cffFFFFFFRight Click:|r Change Loot Specialization|r"
L_DATATEXT_LOOTSPEC_SHOW = "|cffFFFFFFShift + Left Click:|r Show Talent Specialization UI|r"
L_DATATEXT_LOOTSPEC_SPEC = "Spec"
L_DATATEXT_LOOTSPEC_TALENT = "|cffFFFFFFLeft Click:|r Change Talent Specialization|r"
L_DATATEXT_MEMORY = "Memory"
L_DATATEXT_MICROMENU = "MicroMenu"
L_DATATEXT_MS = "MS"
L_DATATEXT_NODUNGEONARM = "No dungeons are currently offering a Call To Arms."
L_DATATEXT_NOORDERHALLUNLOCK = "You have not unlocked your OrderHall"
L_DATATEXT_NOORDERHALLWO = "Orderhall+"
L_DATATEXT_ORB_POSSESSIONS = "Orb Possessions:"
L_DATATEXT_ORDERHALL = "OrderHall"
L_DATATEXT_ORDERHALLREPORT = "Click: Open the OrderHall report"
L_DATATEXT_SYSTEM = "System Stats: "
L_DATATEXT_TOTALBAGSSLOTS = "Total Bag Slots"
L_DATATEXT_TOTALFREEBAGSSLOTS = "Free Bag Slots"
L_DATATEXT_TOTALMEMORY = "Total Memory Usage:"
L_DATATEXT_TOTALMEMORYUSAGE = "Total Memory Usage"
L_DATATEXT_TOTALUSEDBAGSSLOTS = "Used Bag Slots"
L_DATATEXT_TOWERSASSAULTED = "Towers Assaulted:"
L_DATATEXT_TOWERSDEFENDED = "Towers Defended:"
L_DATATEXT_VICTORY_POINTS = "Victory Points:"
L_DATATEXT_SLOTS = {
	[1] = {1, INVTYPE_HEAD, 1000},
	[2] = {3, INVTYPE_SHOULDER, 1000},
	[3] = {5, INVTYPE_ROBE, 1000},
	[4] = {6, INVTYPE_WAIST, 1000},
	[5] = {9, INVTYPE_WRIST, 1000},
	[6] = {10, INVTYPE_HAND, 1000},
	[7] = {7, INVTYPE_LEGS, 1000},
	[8] = {8, INVTYPE_FEET, 1000},
	[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
	[10] = {17, INVTYPE_WEAPONOFFHAND, 1000},
	[11] = {18, INVTYPE_RANGED, 1000}
}

-- headers
L_INSTALL_HEADER_1 = "Welcome"
L_INSTALL_HEADER_2 = "1. Essentials"
L_INSTALL_HEADER_3 = "2. Unitframes"
L_INSTALL_HEADER_4 = "3. Features"
L_INSTALL_HEADER_5 = "4. Things you should know!"
L_INSTALL_HEADER_6 = "5. Commands"
L_INSTALL_HEADER_7 = "6. Finished"
L_INSTALL_HEADER_8 = "1. Essential Settings"
L_INSTALL_HEADER_9 = "2. Social"
L_INSTALL_HEADER_10= "3. Frames"
L_INSTALL_HEADER_11= "4. Success!"

-- install
L_INSTALL_INIT_LINE_1 = "Thank you for choosing KkthnxUI!"
L_INSTALL_INIT_LINE_2 = "You will be guided through the installation process in a few simple steps. At each step, you can decide whether or not you want to apply or skip the presented settings."
L_INSTALL_INIT_LINE_3 = "You are also given the possibility to be shown a brief tutorial on some of the features of KkthnxUI."
L_INSTALL_INIT_LINE_4 = "Press the 'Tutorial' button to be guided through this small introduction, or press 'Install' to skip this step."

-- tutorial 1
L_TUTORIAL_STEP_1_LINE_1 = "This quick tutorial will show you some of the features in KkthnxUI."
L_TUTORIAL_STEP_1_LINE_2 = "First, the essentials that you should know before you can play with this UI."
L_TUTORIAL_STEP_1_LINE_3 = "This installer is partially character-specific. While some of the settings that will be applied later on are account-wide, you need to run the install script for each new character running KkthnxUI. The script is auto shown on every new character you log in with KkthnxUI installed for the first time. Also, the options can be found in /KkthnxUI/Config/Settings.lua for `Power` users or by typing /KkthnxUI in the game for `Friendly` users."
L_TUTORIAL_STEP_1_LINE_4 = "A power user is a user of a personal computer who has the ability to use advanced features (ex: Lua editing) which are beyond the abilities of normal users. A friendly user is a normal user and is not necessarily capable of programming. It's recommended for them to use our in-game configuration tool (/KkthnxUI) for settings they want to be changed in KkthnxUI."

-- tutorial 2
L_TUTORIAL_STEP_2_LINE_1 = "KkthnxUI includes an embedded version of oUF (oUFKkthnxUI) created by Haste. This handles all of the unit frames on the screen, the buffs and debuffs, and the class-specific elements."
L_TUTORIAL_STEP_2_LINE_2 = "You can visit wowinterface.com and search for oUF for more information about this tool."
L_TUTORIAL_STEP_2_LINE_3 = "To easily change the unitframes positions, just type /moveui."
L_TUTORIAL_STEP_2_LINE_4 = ""

-- tutorial 3
L_TUTORIAL_STEP_3_LINE_1 = "KkthnxUI is a redesigned Blizzard UI. Nothing less, nothing more. Approxmently all features you see with Default UI is available though KkthnxUI. The only features not available through default UI are some automated features not really visible on screen, for example, auto selling grays when visiting a vendor or, auto sorting bags."
L_TUTORIAL_STEP_3_LINE_2 = "Not everyone enjoys things like DPS meters, Boss mods, Threat meters, etc, we judge that it's the best thing to do. KkthnxUI is made around the idea to work for all classes, roles, specs, type of gameplay, a taste of the users, etc. This why KkthnxUI is one of the most popular UI at the moment. It fits everyone's play style and is extremely editable. It's also designed to be a good start for everyone that want to make their own custom UI without depending on add-ons. Since 2012 a lot of users have started using KkthnxUI as a base for their own UI."
L_TUTORIAL_STEP_3_LINE_3 = "Users may want to visit our extra mods section on our website or by visiting www.wowinterface.com to install additional features or mods."
L_TUTORIAL_STEP_3_LINE_4 = ""

-- tutorial 4
L_TUTORIAL_STEP_4_LINE_1 = "To set how many bars you want, mouseover on left or right of bottom action bar background. Do the same on the right, via bottom. To copy text from the chat frame, click the button shown on mouseover in the right bottom corner of chat frames."
L_TUTORIAL_STEP_4_LINE_2 = "You can left-click through 80% of data text to show various panels from Blizzard. Friend and Guild Datatext have right-clicked features as well."
L_TUTORIAL_STEP_4_LINE_3 = "There are some dropdown menus available. Right-clicking on the [X] (Close) bag button will show bags. right-clicking the Minimap will show the micro menu."
L_TUTORIAL_STEP_4_LINE_4 = ""

-- tutorial 5
L_TUTORIAL_STEP_5_LINE_1 = "Lastly, KkthnxUI includes useful slash commands. Below is a list."
L_TUTORIAL_STEP_5_LINE_2 = "/moveui allow you to move lots of the frames anywhere on the screen. /rl reloads the UI."
L_TUTORIAL_STEP_5_LINE_3 = "/tt lets you whisper your target. /rc initiates a ready check. /rd disbands a party or raid. /ainv enable auto invite by whisper to you. (/ainv off) to turn it off"
L_TUTORIAL_STEP_5_LINE_4 = "/gm toggles the Help frame. /install or /tutorial loads this installer. "

-- tutorial 6
L_TUTORIAL_STEP_6_LINE_1 = "The tutorial is complete. You can choose to reconsult it at any time by typing /tutorial."
L_TUTORIAL_STEP_6_LINE_2 = "I suggest you have a look through config/config.lua or type /KkthnxUI to customize the UI to your needs."
L_TUTORIAL_STEP_6_LINE_3 = "You can now continue to install the UI if it's not done yet or if you want to reset to default!"
L_TUTORIAL_STEP_6_LINE_4 = ""

-- Install step 1
L_INSTALL_STEP_1_LINE_1 = "These steps will apply the correct CVar settings for KkthnxUI."
L_INSTALL_STEP_1_LINE_2 = "The first step applies the essential settings."
L_INSTALL_STEP_1_LINE_3 = "This is |cffff0000recommended|r for any user unless you want to apply only a specific part of the settings."
L_INSTALL_STEP_1_LINE_4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step."

-- Install step 2
L_INSTALL_STEP_2_LINE_0 = "Another chat addon is found. We will ignore this step. Please press skip to continue installation."
L_INSTALL_STEP_2_LINE_1 = "The second step applies the correct chat setup."
L_INSTALL_STEP_2_LINE_2 = "If you are a new user, this step is recommended. If you are an existing user, you may want to skip this step."
L_INSTALL_STEP_2_LINE_3 = "It is normal that your chat font will appear too big upon applying these settings. It will revert back to normal when you finish with the installation."
L_INSTALL_STEP_2_LINE_4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step."

-- Install step 3
L_INSTALL_STEP_3_LINE_1 = "The third and final step applies for the default frame positions."
L_INSTALL_STEP_3_LINE_2 = "This step is |cffff0000recommended|r for new users."
L_INSTALL_STEP_3_LINE_3 = ""
L_INSTALL_STEP_3_LINE_4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step."

-- Install step 4
L_INSTALL_STEP_4_LINE_1 = "Installation is complete."
L_INSTALL_STEP_4_LINE_2 = "Please click the 'Finish' button to reload the UI."
L_INSTALL_STEP_4_LINE_3 = ""
L_INSTALL_STEP_4_LINE_4 = "Enjoy KkthnxUI! Visit us on Discord @ |cff748BD9discord.gg/Kjyebkf|r"

-- buttons
L_INSTALL_BUTTON_TUTORIAL = "Tutorial"
L_INSTALL_BUTTON_INSTALL = "Install"
L_INSTALL_BUTTON_NEXT = "Next"
L_INSTALL_BUTTON_SKIP = "Skip"
L_INSTALL_BUTTON_CONTINUE = "Continue"
L_INSTALL_BUTTON_FINISH = "Finish"
L_INSTALL_BUTTON_CLOSE = "Close"

-- AutoInvite Localization
L_INVITE_ENABLE = "Autoinvite enabled: "
L_INVITE_DISABLE = "AutoInvite disabled"

-- Info Localization
L_INFO_DISBAND = "Disbanding group..."
L_INFO_DUEL = "Declined duel request from "
L_INFO_PET_DUEL = "Declined pet duel request from "
L_INFO_INVITE = "Accepted invite from "
L_INFO_SETTINGS_DBM = "Type /settings dbm, to apply the settings DBM."
L_INFO_SETTINGS_MSBT = "Type /settings msbt, to apply the settings MSBT."
L_INFO_SETTINGS_SKADA = "Type /settings skada, to apply the settings Skada."
L_INFO_SETTINGS_Abu = "Type /settings abu, to apply the settings oUF_Abu."
L_INFO_SETTINGS_ALL = "Type /settings all, to apply the settings for all modifications."
L_INFO_NOT_INSTALLED = " is not installed."
L_INFO_SKIN_DISABLED1 = "Skin for "
L_INFO_SKIN_DISABLED2 = " is disabled."

-- Install Message Localization
L_INSTALL_COMPLETE = "Installation Complete"

-- Loot Localization
L_LOOT_ANNOUNCE = "Announce to"
L_LOOT_CANNOT = "Cannot roll"
L_LOOT_CHEST = ">> Loot from chest"
L_LOOT_FISH = "Fishing loot"
L_LOOT_MONSTER = ">> Loot from "
L_LOOT_RANDOM = "Random Player"
L_LOOT_SELF = "Self Loot"
L_LOOT_TO_GUILD = " Guild"
L_LOOT_TO_INSTANCE = " Instance"
L_LOOT_TO_PARTY = " Party"
L_LOOT_TO_RAID = " Raid"
L_LOOT_TO_SAY = " Say"

-- Mail Localization
L_MAIL_COMPLETE = "All done."
L_MAIL_MESSAGES = "messages"
L_MAIL_NEED = "Need a mailbox."
L_MAIL_STOPPED = "Stopped, inventory is full."
L_MAIL_UNIQUE = "Stopped. Found a unique duplicate item in a bag or the bank."

-- World Map Localization
L_MAP_FOG = "Fog of War"

-- FarmMode Minimap
L_MINIMAP_FARMMODE_ON = "Farm mode enabled"
L_MINIMAP_FARMMODE_OFF = "Farm mode disabled"

-- Misc Localization
L_MISC_COPPERSHORT = "|cffeda55fc|r"
L_MISC_GOLDSHORT = "|cffffd700g|r"
L_MISC_REPAIR = "Warning! You need to do a repair of your equipment as soon as possible!"
L_MISC_SILVERSHORT = "|cffc7c7cfs|r"
L_MISC_UI_OUTDATED = "Your version of KkthnxUI is out of date. You can download the newest version from Curse.com. Get the Curse app and have KkthnxUI automatically updated with the Client!"
L_MISC_UNDRESS = "Undress"
L_MISC_ENTERCOMBAT = "+ Entering Combat"
L_MISC_LEAVECOMBAT = "- Leaving Combat"

-- Popup Localization
L_POPUP_ARMORY = "Armory"
L_POPUP_BOOSTUI = "|cffff0000WARNING|r |n|nThis will optimize your performance by turning down the graphics and tweaking them. Hit accept only if you are having |cffff0000FPS|r issues!|r"
L_POPUP_DISBAND_RAID = "Are you sure you want to disband the group?"
L_POPUP_FIX_ACTIONBARS = "There is something wrong with your action bars. Do you want to reload the UI to fix it?"
L_POPUP_INSTALLUI = "Thank you for choosing |cff3c9bedKkthnxUI|r! |n|nAccept this installation dialog to apply settings."
L_POPUP_RELOADUI = "Installation is complete. Please click the 'Accept' button to reload the UI. Enjoy |cff3c9bedKkthnxUI|r. |n|nVisit me at |cff3c9bedwww.github.com/kkthnx|r."
L_POPUP_RESET_DATATEXT = "Are you sure you want to reset all datatexts to default?"
L_POPUP_RESETUI = "Are you sure you want to reset all settings for |cff3c9bedKkthnxUI|r?"
L_POPUP_RESOLUTIONCHANGED = "We detected a resolution change on your World of Warcraft client. We HIGHLY RECOMMEND restarting your game. Do you want to proceed?"
L_POPUP_SETTINGS_ALL = "|cffff0000WARNING|r |n|nThis will apply all the supported addons settings and import them to go with |cff3c9bedKkthnxUI|r. This feature will not do anything if you do not have one of the supported add-ons."
L_POPUP_SETTINGS_DBM = "We need to change the bar positions of |cff3c9bedDBM|r."

-- Raid Utility Localization
L_RAID_UTIL_DISBAND = "Disband Group"
L_POPUP_DISBAND_RAID = "Are you sure you want to disband the group?"

-- Tooltip Localization
L_TOOLTIP_ACH_COMPLETE = "Your Status: Completed on "
L_TOOLTIP_ACH_INCOMPLETE = "Your Status: Incomplete"
L_TOOLTIP_ACH_STATUS = "Your Status:"
L_TOOLTIP_ITEM_COUNT = "Item count:"
L_TOOLTIP_ITEM_ID = "Item ID:"
L_TOOLTIP_SPELL_ID = "Spell ID:"

-- Tutorial Localization
L_TUTORIAL_MESSAGE_1 = "For technical support visit https://github.com/Kkthnx."
L_TUTORIAL_MESSAGE_2 = "You can toggle the microbar by using your right mouse button on the minimap."
L_TUTORIAL_MESSAGE_3 = "You can set your keybindings quickly by typing /kb."
L_TUTORIAL_MESSAGE_4 = "The focus unit can be set by typing /focus when you are targeting the unit you want to focus. It is recommended you make a macro do this."
L_TUTORIAL_MESSAGE_5 = "You can access copy chat and chat menu functions by mouse over the bottom right corner of chat panel and left click on the button that will appear."
L_TUTORIAL_MESSAGE_6 = "If you are experiencing issues with KkthnxUI try disabling all your addons except KkthnxUI, remember KkthnxUI is a full UI replacement addon, you cannot run two addons that do the same thing."
L_TUTORIAL_MESSAGE_7 = "To setup which channels appear in which chat frame, right click the chat tab and go to settings."
L_TUTORIAL_MESSAGE_8 = "You can use the /resetui command to reset all of your movers. You can also type /moveui and just right click a mover to reset its position."
L_TUTORIAL_MESSAGE_9 = "To move abilities on the action bars by default hold shift + drag. You can change the modifier key from the action bar options menu."
L_TUTORIAL_MESSAGE_10 = "You can see someones average item level of their gear by enabling the item level for tooltip option"

-- Wowhead Link Localization
L_WATCH_WOWHEAD_LINK = "Wowhead Link"

-- Welcome Localization
L_WELCOME_LINE_1 = "Welcome to |cff3c9bedKkthnxUI|r v"
L_WELCOME_LINE_2_1 = ""
L_WELCOME_LINE_2_2 = "Type /cfg to config interface, or visit www.github.com/kkthnx|r"
L_WELCOME_LINE_2_3 = ""
L_WELCOME_LINE_2_4 = "Some of your questions can be answered by typing /uihelp"

-- Slash Commands Localization
L_SLASHCMD_HELP = {
	"",
	"|cff3c9bedAvailable slash commands:|r",
	"--------------------------",
	"/rl - Reload interface.",
	"/rc - Activates a ready check.",
	"/gm - Opens GM frame.",
	"/rd - Disband party or raid.",
	"/toraid - Convert to party or raid.",
	"/teleport - Teleportation from random dungeon.",
	"/spec, /ss - Switches between talent spec's.",
	"/frame - Description is not ready.",
	"/farmmode - Increase the size of the minimap.",
	"/moveui - Allows the movement of interface elements.",
	"/resetui - Resets general settings to default.",
	"/resetconfig - Resets KkthnxUI_Config settings.",
	"/settings ADDON_NAME - Applies settings to msbt, dbm, skada, or all addons.",
	"/pulsecd - Self cooldown pulse test.",
	"/tt - Whisper target.",
	"/ainv - Enables automatic invitation.",
	"/cfg - Opens interface settings.",
	"/patch - Display Wow patch info.",
	"",
	"|cff3c9bedAvailable hidden features:|r",
	"--------------------------",
	"Right-click minimap for micromenu.",
	"Middle mouse click minimap for tracking.",
	"Left click experience bar opens rep frame.",
	"Left click artifact bar opens artifact frame.",
	"Hold alt and obtain player ilvl and spec in tooltip.",
	"Hold shift to scroll instantly to end or start of chat.",
	"Copy button to the bottom right side of chat.",
	"Middle mouse click copy button to /roll.",
}
