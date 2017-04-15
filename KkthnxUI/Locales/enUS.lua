local K, C, L = unpack(select(2, ...))

-- Localization for enUS & enGB

L.AFKScreen = {
	NoGuild = "No Guild",
	Sun = "Sunday",
	Mon = "Monday",
	Tue = "Tuesday",
	Wed = "Wednesday",
	Thu = "Thursday",
	Fri = "Friday",
	Sat = "Saturday",
	Jan = "January",
	Feb = "February",
	Mar = "March",
	Apr = "April",
	May = "May",
	Jun = "June",
	Jul = "July",
	Aug = "August",
	Sep = "September",
	Oct = "October",
	Nov = "November",
	Dec = "December"
}

L.Announce = {
	Interrupted = INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "Pull ABORTED!",
	PCGo = "GO!",
	PCMessage = "Pulling %s in %s..",
	Sapped = "Sapped",
	SappedBy = "Sapped by: ",
}

L.Auras = {
	MoveBuffs = "Move Buffs",
	MoveDebuffs = "Move Debuffs",
}

-- Merchant Localization
L.Merchant = {
	NotEnoughMoney = "You don't have enough money to repair!",
	RepairCost = "Your items have been repaired for",
	SoldTrash = "Your vendor trash has been sold and you earned"
}

-- Bindings Localization
L.Bind = {
	Binding = "Binding",
	Cleared = "All keybindings cleared for",
	Discard = "All newly set keybindings were discarded.",
	Instruct = "Hover, your mouse over any action button, to bind it. Press the escape key or right click to clear the current action button's keybinding.",
	Key = "Key",
	NoSet = "No bindings set",
	Saved = "All keybindings have been saved.",
	Trigger = "Trigger"
}

L.Chat = {
	AFK = "|cffff0000[AFK]|r",
	BigChatOff = "Big chat feature deactivated",
	BigChatOn = "Big chat feature activated",
	DND = "|cffe7e716[DND]|r",
	General = "General",
	Guild = "G",
	GuildRecruitment = "GuildRecruitment",
	Instance = "I",
	InstanceLeader = "IL",
	InvalidTarget = "Invalid Target",
	LocalDefense = "LocalDefense",
	LookingForGroup = "LookingForGroup",
	Officer = "O",
	Party = "P",
	PartyLeader = "P",
	Raid = "R",
	RaidLeader = "R",
	RaidWarning = "RW",
	Says = "says",
	Trade = "Trade",
	Whispers = "whispers",
	Yells = "yells",
}

-- ToggleButton Localization
L.ToggleButton = {
	Config = "Toggle KkthnxUI Config",
	Functions = "ToggleButton functions:",
	LeftClick = "Left click:",
	MiddleClick = "Middle click:",
	MoveUI = "Toggle Move UI",
	Recount = "Toggle Recount",
	RightClick = "Right click:",
	Skada = "Toggle Skada",
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "Toggle Artifact Frame",
	HonorClick = "Toggle Honor Frame",
	ReputationClick = "Toggle Reputation Frame",
}

-- DataText Localization
L.DataText = {
	Bandwidth = "Bandwidth",
	BaseAssault = "Bases Assaulted:",
	BaseDefend = "Bases Defended:",
	CartControl = "Carts Controlled:",
	Damage = "Damage: ",
	DamageDone = "Damage Done:",
	Death = "Deaths:",
	DemolisherDestroy = "Demolishers Destroyed:",
	Download = "Download",
	FlagCapture = "Flags Captured:",
	FlagReturn = "Flags Returned:",
	GateDestroy = "Gates Destroyed:",
	GraveyardAssault = "Graveyards Assaulted:",
	GraveyardDefend = "Graveyards Defended:",
	Healing = "Healing: ",
	HealingDone = "Healing Done:",
	HomeLatency = "Home Latency:",
	Honor = "Honor: ",
	HonorableKill = "Honorable Kills:",
	HonorGained = "Honor Gained:",
	KillingBlow = "Killing Blows: ",
	MemoryUsage = "(Hold Shift) Memory Usage",
	OrbPossession = "Orb Possessions:",
	SavedDungeons = "Saved Dungeon(s)",
	SavedRaids = "Saved Raid(s)",
	StatsFor = "Stats for ",
	TotalCPU = "Total CPU:",
	TotalMemory = "Total Memory:",
	TowerAssault = "Towers Assaulted:",
	TowerDefend = "Towers Defended:",
	VictoryPts = "Victory Points:"
}

-- headers
L.Install = {
	Header1 = "Welcome",
	Header8 = "1. Essential Settings",
	Header9 = "2. Social",
	Header10 = "3. Frames",
	Header11 = "4. Success!",
	InitLine1 = "Thank you for choosing KkthnxUI!",
	InitLine2 = "You will be guided through the installation process in a few simple steps. At each step, you can decide whether or not you want to apply or skip the presented settings.",
	Step1Line1 = "These steps will apply the correct CVar settings for KkthnxUI.",
	Step1Line2 = "The first step applies the essential settings.",
	Step1Line3 = "This is |cffff0000recommended|r for any user unless you want to apply only a specific part of the settings.",
	Step1Line4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step.",
	Step2Line0 = "Another chat addon is found. We will ignore this step. Please press skip to continue installation.",
	Step2Line1 = "The second step applies the correct chat setup.",
	Step2Line2 = "If you are a new user, this step is recommended. If you are an existing user, you may want to skip this step.",
	Step2Line3 = "It is normal that your chat font will appear too big upon applying these settings. It will revert back to normal when you finish with the installation.",
	Step2Line4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step.",
	Step3Line1 = "The third and final step applies for the default frame positions.",
	Step3Line2 = "This step is |cffff0000recommended|r for new users.",
	Step3Line3 = "",
	Step3Line4 = "Click 'Continue' to apply the settings, or click 'Skip' if you wish to skip this step.",
	Step4Line1 = "Installation is complete.",
	Step4Line2 = "Please click the 'Finish' button to reload the UI.",
	Step4Line3 = "",
	Step4Line4 = "Enjoy KkthnxUI! Visit us on Discord @ |cff748BD9discord.gg/Kjyebkf|r",
	ButtonInstall = "Install",
	ButtonNext = "Next",
	ButtonSkip = "Skip",
	ButtonContinue = "Continue",
	ButtonFinish = "Finish",
	ButtonClose = "Close",
	Complete = "Installation Complete"
}

-- AutoInvite Localization
L.Invite = {
	Enable = "Autoinvite enabled: ",
	Disable = "AutoInvite disabled"
}

-- Info Localization
L.Info = {
	Disabnd = "Disbanding group...",
	Duel = "Declined duel request from ",
	Errors = "No error yet.",
	Invite = "Accepted invite from ",
	NotInstalled = " is not installed.",
	PetDuel = "Declined pet duel request from ",
	SettingsALL = "Type /settings all, to apply the settings for all modifications.",
	SettingsDBM = "Type /settings dbm, to apply the settings DBM.",
	SettingsMSBT = "Type /settings msbt, to apply the settings MSBT.",
	SettingsSKADA = "Type /settings skada, to apply the settings Skada.",
	SkinDisabled1 = "Skin for ",
	SkinDisabled2 = " is disabled."
}

-- Loot Localization
L.Loot = {
	Announce = "Announce to",
	Cannot = "Cannot roll",
	Chest = ">> Loot from chest",
	Fish = "Fishing loot",
	Monster = ">> Loot from ",
	Random = "Random Player",
	Self = "Self Loot",
	ToGuild = " Guild",
	ToInstance = " Instance",
	ToParty = " Party",
	ToRaid = " Raid",
	ToSay = " Say"
}

-- FarmMode Minimap
L.Minimap = {
	FarmModeOn = "Farm mode enabled",
	FarmModeOff = "Farm mode disabled"
}

-- Misc Localization
L.Misc = {
	BuyStack = "Alt-Click to buy a stack",
	Collapse = "The Collapse",
	CopperShort = "|cffeda55fc|r",
	GoldShort = "|cffffd700g|r",
	SilverShort = "|cffc7c7cfs|r",
	TriedToCall = "%s: %s tried to call the protected function '%s'.",
	UIOutdated = "Your version of KkthnxUI is out of date. You can download the newest version from Curse.com. Get the Curse app and have KkthnxUI automatically updated with the Client!",
	Undress = "Undress"
}

L.Popup = {
	BlizzardAddOns = "It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled.",
	BoostUI = "|cffff0000WARNING|r |n|nThis will optimize your performance by turning down the graphics and tweaking them. Hit accept only if you are having |cffff0000FPS|r issues!|r",
	DisableUI = "KkthnxUI might not work for this resolution, do you want to disable KkthnxUI? (Cancel if you want to try another resolution)",
	DisbandRaid = "Are you sure you want to disband the group?",
	FixActionbars = "There is something wrong with your action bars. Do you want to reload the UI to fix it?",
	InstallUI = "Thank you for choosing |cff3c9bedKkthnxUI|r! |n|nAccept this installation dialog to apply settings.",
	ReloadUI = "Installation is complete. Please click the 'Accept' button to reload the UI. Enjoy |cff3c9bedKkthnxUI|r. |n|nVisit me at |cff3c9bedwww.github.com/kkthnx|r.",
	ResetUI = "Are you sure you want to reset all settings for |cff3c9bedKkthnxUI|r?",
	ResolutionChanged = "We detected a resolution change on your World of Warcraft client. We HIGHLY RECOMMEND restarting your game. Do you want to proceed?",
	SettingsAll = "|cffff0000WARNING|r |n|nThis will apply all the supported addons settings and import them to go with |cff3c9bedKkthnxUI|r. This feature will not do anything if you do not have one of the supported add-ons.",
	SettingsBW = "Need to change the position of elements BigWigs.",
	SettingsDBM = "We need to change the bar positions of |cff3c9bedDBM|r.",
	SetUIScale = "This will set a near 'Pixel Perfect' Scale to your interface. Do you want to proceed?",
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "Disband Group",
	DisbandRaid = "Are you sure you want to disband the group?"
}

-- Tooltip Localization
L.Tooltip = {
	ItemCount = "Item count:",
	SpellID = "Spell ID:",
	ToggleBar = "Unlock and lock the action bars using this button. Once you have unlocked the bars, you can hover over them to see the 'toggle bar' feature to toggle more or fewer action bars.",
}

L.WatchFrame = {
	WowheadLink = "Wowhead Link"
}

L.Welcome = {
	Line1 = "Welcome to |cff3c9bedKkthnxUI|r v",
	Line2 = "",
	Line3 = "Type |cff3c9bed/cfg|r to access the in-game configuration menu.",
	Line4 = "",
	Line5 = "If you are in need of support you can visit our Discord |cff3c9bedQ2KhGY2|r"
}

L.Zone = {
	ArathiBasin = "Arathi Basin",
	Gilneas = "The Battle for Gilneas"
}

L.SlashCommand = {
	Help = {
		"",
		"|cff3c9bedAvailable slash commands:|r",
		"--------------------------",
		"/boostui - If you have FPS issues try this command.",
		"/cfg - Opens interface settings.",
		"/farmmode - Increase the size of the minimap.",
		"/frame - Get the info on any frame that can return info.",
		"/getpoint - Get the point of a frame.",
		"/gm - Opens GM frame.",
		"/moveui - Allows the movement of interface elements.",
		"/patch - Display Wow patch info.",
		"/rc - Activates a ready check.",
		"/rd - Disband party or raid.",
		"/resetconfig - Resets KkthnxUI_Config settings.",
		"/resetui - Resets general settings to default.",
		"/rl - Reload interface.",
		"/settings ADDON_NAME - Applies settings to msbt, dbm, skada, or all addons.",
		"/spec, /ss - Switches between talent spec's.",
		"/teleport - Teleportation from random dungeon.",
		"/testuf - Unit frame test.",
		"/toraid - Convert to party or raid.",
		"/tt - Whisper target.",
		"",
		"|cff3c9bedAvailable hidden features:|r",
		"--------------------------",
		"Right-click minimap for micromenu.",
		"Middle mouse click minimap for tracking.",
		"Left click experience bar opens rep frame.",
		"Left click artifact bar opens artifact frame.",
		"Hold shift to scroll instantly to end or start of chat.",
		"Copy button to the bottom right side of chat.",
		"Middle mouse click copy button to /roll.",
	}
}