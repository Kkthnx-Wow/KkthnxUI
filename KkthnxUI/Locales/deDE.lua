local K, C, L = unpack(select(2, ...))
if (GetLocale() ~= "deDE") then return end

-- Localization for deDE clients

L.AFKScreen = {
	NoGuild = "Keine Gilde",
	Sun = "Sonntag",
	Mon = "Montag",
	Tue = "Dienstag",
	Wed = "Mittwoch",
	Thu = "Donnerstag",
	Fri = "Freitag",
	Sat = "Samstag",
	Jan = "Januar",
	Feb = "Februar",
	Mar = "März",
	Apr = "April",
	May = "Mai",
	Jun = "Juni",
	Jul = "Juli",
	Aug = "August",
	Sep = "September",
	Oct = "Oktober",
	Nov = "November",
	Dec = "Dezember"
}

L.Announce = {
	FPUse = "%s benutzt %s.",
	Interrupted = INTERRUPTED.." %s's \124cff71d5ff\124HZauber:%d:0\124h[%s]\124h\124r!",
	PCAborted = "Pull ABGEBROCHEN!",
	PCGo = "LOS GEHT'S!",
	PCMessage = "Pulle %s in %s..",
	Recieved = " erhalten von ",
	Sapped = "Kopfnuss",
	SappedBy = "Kopfnuss von: ",
	SSThanks = "Danke für "
}

L.Auras = {
	MoveBuffs = "Bewege Buffs",
	MoveDebuffs = "Bewege Debuffs",
}

-- Merchant Localization
L.Merchant = {
	NotEnoughMoney = "Du hast nicht genug Gold um Deine Ausrüstung zu reparieren!",
	RepairCost = "Deine Ausrüstung wurde repariert. Die Kosten dafür betragen",
	SoldTrash = "Dein Müll aus den Taschen wurde beim Händler verkauft und Du erhälst"
}

-- Bindings Localization
L.Bind = {
	Binding = "Tastenbelegungen",
	Cleared = "Alle Tastenbelegungen verworfen für",
	Discard = "Alle neuen Tastenbelegungen wurden verworfen.",
	Instruct = "Bewege die Maus über jeden beliebigen Aktionsbutton um ihn zu belegen. Drücke ESC, oder die rechte Maustaste, um die Belegung zu verwerfen.",
	Key = "Taste",
	NoSet = "Keine Tastenbelegungen gesetzt",
	Saved = "Alle Tastenbelegungen wurden gespeichert.",
	Trigger = "Auslöser"
}

-- Chat Localization
L.Chat = {
	AFK = "|cffff0000[AFK]|r",
	BigChatOff = "Großer Chat deaktiviert",
	BigChatOn = "Großer Chat aktiviert",
	DND = "|cffe7e716[DND]|r",
	Guild = "G",
	GuildRecruitment = "GildenRekrutierung",
	Instance = "I",
	InstanceLeader = "IL",
	LocalDefense = "LokaleVerteidigung",
	LookingForGroup = "SucheNachGruppe",
	Officer = "O",
	Party = "P",
	PartyLeader = "P",
	Raid = "R",
	RaidLeader = "R",
	RaidWarning = "W",
}

-- ToggleButton Localization
L.ToggleButton = {
	Config = "Zeige/Verstecke KkthnxUI Konfiguration",
	Functions = "Button Funktionen:",
	LeftClick = "Links-Klick:",
	MiddleClick = "Mittel-Klick:",
	MoveUI = "UI bewegen",
	Recount = "Zeige/Verstecke Recount",
	RightClick = "Rechts-Klick:",
	ShiftClick = "Shift + Klick:",
	Skada = "Zeige/Verstecke Skada",
}

-- Cooldowns
L.Cooldowns = {
	Cooldowns = "CD: ",
	CombatRes = "BattleRes",
	CombatResRemainder = "Battle Resurrection: ",
	NextTime = "Zeit bis: "
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "Klick: Öffnet die Artefaktübersicht",
	ArtifactRemaining = "|cffe6cc80Verbleibend: %s|r",
	HonorLeftClick = "|cffcacacaLinksklick: Öffnet die Ehreübersicht|r",
}

-- DataText Localization
L.DataText = {
	Bandwidth = "Bandbreite",
	BaseAssault = "Stützpunkte angegriffen:",
	BaseDefend = "Stützpunkte verteidigt:",
	CartControl = "Loren kontrolliert:",
	Damage = "Schaden: ",
	DamageDone = "Verursachter Schaden:",
	Death = "Tode:",
	DemolisherDestroy = "Verwüster zerstört:",
	Download = "Download",
	FlagCapture = "Flaggen eingenommen:",
	FlagReturn = "Flaggen zurückgebracht:",
	GateDestroy = "Tore zerstört:",
	GraveyardAssault = "Friedhöfe angegriffen:",
	GraveyardDefend = "Friedhöfe verteidigt:",
	Healing = "Heilung: ",
	HealingDone = "Verursachte Heilung:",
	HomeLatency = "Heimlatenz:",
	Honor = "Ehre: ",
	HonorableKill = "Ehrenhafte Tötungen:",
	HonorGained = "Ehre erhalten:",
	KillingBlow = "Todesstöße: ",
	MemoryUsage = "(Halte Shift) Speichervrebrauch",
	OrbPossession = "Kugel in Besitz:",
	SavedDungeons = "Gespeicherte(r) Dungeon(s)",
	SavedRaids = "Gespeicherte(r) Raid(s)",
	StatsFor = "Stats für ",
	TotalCPU = "CPU Gesamt:",
	TotalMemory = "Speichernutzung Übersicht:",
	TowerAssault = "Türme angegriffen:",
	TowerDefend = "Türme verteidigt:",
	VictoryPts = "Siegpunkte:"
}

-- headers
L.Install = {
	Header1 = "Welcome",
	Header2 = "1. Essentials",
	Header3 = "2. Unitframes",
	Header4 = "3. Features",
	Header5 = "4. Things you should know!",
	Header6 = "5. Commands",
	Header7 = "6. Finished",
	Header8 = "1. Essential Settings",
	Header9 = "2. Social",
	Header10 = "3. Frames",
	Header11 = "4. Success!",
	InitLine1 = "Thank you for choosing KkthnxUI!",
	InitLine2 = "You will be guided through the installation process in a few simple steps. At each step, you can decide whether or not you want to apply or skip the presented settings.",
	InitLine3 = "You are also given the possibility to be shown a brief tutorial on some of the features of KkthnxUI.",
	InitLine4 = "Press the 'Tutorial' button to be guided through this small introduction, or press 'Install' to skip this step.",
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
	Step3Line4 = "Klicke auf 'Fortfahren' um die Einstellungen zu übernehmen, oder klicke auf 'Überspringen' wenn du diesen Installationschritt überspringen möchtest.",
	Step4Line1 = "Installation erfolgreich abgeschlossen.",
	Step4Line2 = "Bitte klick auf 'Fertigstellen' um das UI neu zu laden.",
	Step4Line3 = "",
	Step4Line4 = "Genieße KkthnxUI! Besuche uns bei Discord @ |cff748BD9discord.gg/Kjyebkf|r",
	ButtonTutorial = "Anleitung",
	ButtonInstall = "Installieren",
	ButtonNext = "Weiter",
	ButtonSkip = "Überspringen",
	ButtonContinue = "Forfahren",
	ButtonFinish = "Fertigstellen",
	ButtonClose = "Schließen",
	Complete = "Installation Abgeschlossen"
}

-- tutorial 1
L.Tutorial = {
	Step1Line1 = "This quick tutorial will show you some of the features in KkthnxUI.",
	Step1Line2 = "First, the essentials that you should know before you can play with this UI.",
	Step1Line3 = "This installer is partially character-specific. While some of the settings that will be applied later on are account-wide, you need to run the install script for each new character running KkthnxUI. The script is auto shown on every new character you log in with KkthnxUI installed for the first time. Also, the options can be found in /KkthnxUI/Config/Settings.lua for `Power` users or by typing /KkthnxUI in the game for `Friendly` users.",
	Step1Line4 = "A power user is a user of a personal computer who has the ability to use advanced features (ex: Lua editing) which are beyond the abilities of normal users. A friendly user is a normal user and is not necessarily capable of programming. It's recommended for them to use our in-game configuration tool (/KkthnxUI) for settings they want to be changed in KkthnxUI.",
	Step2Line1 = "KkthnxUI includes an embedded version of oUF (oUFKkthnxUI) created by Haste. This handles all of the unit frames on the screen, the buffs and debuffs, and the class-specific elements.",
	Step2Line2 = "You can visit wowinterface.com and search for oUF for more information about this tool.",
	Step2Line3 = "To easily change the unitframes positions, just type /moveui.",
	Step2Line4 = "",
	Step3Line1 = "KkthnxUI is a redesigned Blizzard UI. Nothing less, nothing more. Approxmently all features you see with Default UI is available though KkthnxUI. The only features not available through default UI are some automated features not really visible on screen, for example, auto selling grays when visiting a vendor or, auto sorting bags.",
	Step3Line2 = "Not everyone enjoys things like DPS meters, Boss mods, Threat meters, etc, we judge that it's the best thing to do. KkthnxUI is made around the idea to work for all classes, roles, specs, type of gameplay, a taste of the users, etc. This why KkthnxUI is one of the most popular UI at the moment. It fits everyone's play style and is extremely editable. It's also designed to be a good start for everyone that want to make their own custom UI without depending on add-ons. Since 2012 a lot of users have started using KkthnxUI as a base for their own UI.",
	Step3Line3 = "Users may want to visit our extra mods section on our website or by visiting www.wowinterface.com to install additional features or mods.",
	Step3Line4 = "",
	Step4Line1 = "To set how many bars you want, mouseover on left or right of bottom action bar background. Do the same on the right, via bottom. To copy text from the chat frame, click the button shown on mouseover in the right bottom corner of chat frames.",
	Step4Line2 = "You can left-click through 80% of data text to show various panels from Blizzard. Friend and Guild Datatext have right-clicked features as well.",
	Step4Line3 = "There are some dropdown menus available. Right-clicking on the [X] (Close) bag button will show bags. right-clicking the Minimap will show the micro menu.",
	Step4Line4 = "",
	Step5Line1 = "Lastly, KkthnxUI includes useful slash commands. Below is a list.",
	Step5Line2 = "/moveui allow you to move lots of the frames anywhere on the screen. /rl reloads the UI.",
	Step5Line3 = "/tt lets you whisper your target. /rc initiates a ready check. /rd disbands a party or raid. /ainv enable auto invite by whisper to you. (/ainv off) to turn it off",
	Step5Line4 = "/gm toggles the Help frame. /install or /tutorial loads this installer. ",
	Step6Line1 = "The tutorial is complete. You can choose to reconsult it at any time by typing /tutorial.",
	Step6Line2 = "I suggest you have a look through config/config.lua or type /KkthnxUI to customize the UI to your needs.",
	Step6Line3 = "You can now continue to install the UI if it's not done yet or if you want to reset to default!",
	Step6Line4 = "",
}

-- AutoInvite Localization
L.Invite = {
	Enable = "Automatische Einladungen aktiviert: ",
	Disable = "Automatische Einladungen deaktiviert"
}

-- Info Localization
L.Info = {
	Disabnd = "Auflösung der Gruppe...",
	Duel = "Duellaufforderung abgelehnt von ",
	Errors = "Noch keine Fehler.",
	Invite = "Akzeptiere Einladung von ",
	NotInstalled = " ist nicht installiert.",
	PetDuel = "Haustierkampfduell abgelehnt von ",
	SettingsAll = "Tippe /settings all, um die Einstellungen für alle Modifikationen zu übernehmen.",
	SettingsDbm = "Tippe /settings dbm, um die Einstellungen für DBM zu übernehmen.",
	SettingsMsbt = "Tippe /settings msbt, um die Einstellungen für MSBT zu übernehmen.",
	SettingsSkada = "Tippe /settings skada, um die Einstellungen für Skada zu übernehmen.",
	SkinDisabled1 = "Skin für ",
	SkinDisabled2 = " ist deaktviert."
}

-- Loot Localization
L.Loot = {
	Announce = "Ankündigung nach",
	Cannot = "Kann nicht würfeln",
	Chest = ">> Beute aus Kiste",
	Fish = "Schräge Beute",
	Monster = ">> Beute von ",
	Random = "Zufälliger Spieler",
	Self = "Eigene Beute",
	ToGuild = " Gilde",
	ToInstance = " Instanz",
	ToParty = " Gruppe",
	ToRaid = " Schlachtzug",
	ToSay = " Sagen"
}

-- Mail Localization
L.Mail = {
	Complete = "Alles ausgeführt.",
	Messages = "Nachrichten",
	Need = "Benötigt einen Briefkasten.",
	Stopped = "Abgebrochen, Taschen sind voll.",
	Unique = "Abgebrochen. Ein doppelter, einzigartiger Gegenstand wurde in Deiner Tasche oder auf der bank gefunden."
}

-- World Map Localization
L.Map = {
	Fog = "Nebel des Krieges"
}

-- FarmMode Minimap
L.Minimap = {
	FarmModeOn = "Farm mode aktiviert",
	FarmModeOff = "Farm mode deaktiviert"
}

-- Misc Localization
L.Misc = {
	BuyStack = "Alt-Klick um einen Stapel zu kaufen",
	Collapse = "The Collapse",
	CopperShort = "|cffeda55fc|r",
	GoldShort = "|cffffd700g|r",
	SilverShort = "|cffc7c7cfs|r",
	TriedToCall = "%s: %s versucht die geschützte Funktion aufrufen '%s'.",
	UIOutdated = "Achtung! Deine Version von KkthnxUI ist veraltet. Du kannst die neueste Version von Curse.com downloaden. Benutzte die Curse App und lasse Deine KkthnxUI automatisch vom Client aktualisieren!",
	Undress = "Ausziehen"
}

L.Popup = {
	Armory = "Armory",
	BlizzardAddOns = "It appears one of your AddOns have disabled the AddOn Blizzard_CompactRaidFrames. This can cause errors and other issues. The AddOn will now be re-enabled.",
	BoostUI = "|cffff0000WARNUNG|r |n|nDiese Einstellung optimiert Deine Performance indem die Grafikdetails runtergesetzt werden. Klicke nur auf Annehmen wenn Du massive |cffff0000FPS|r Probleme hast!|r",
	DisableUI = "KkthnxUI funktioniert mit deiner eingestellten Auflösung wahrscheinlich nicht, möchtest du KkthnxUI deaktivieren? (Wähle Abbrechen, wenn du eine andere Auflösung einstellen magst)",
	DisbandRaid = "Bist Du sicher, dass Du den Schlachtzug auflösen willst?",
	FixActionbars = "Etwas stimmt mit den Aktionsleisten nicht. Möchtest Du das UI neu laden um diesen Fehler zu beheben?",
	InstallUI = "Danke das du |cff3c9bedKkthnxUI|r verwendest! |n|nSobald Du auf 'Annehmen' klickst, beginnen wir mit der Installation.",
	ReloadUI = "Die Installation ist abgeschlossen. Bitte klick erneut auf 'Annehmen' um das UI neu zu laden.|n|nViel Spaß mit |cff3c9bedKkthnxUI|r. |n|nFür Updates der UI besuche meine Seite auf |cff3c9bedhttps://github.com/Kkthnx|r.",

	ResetUI = "Bist Du sicher, dass Du alle Einstellungen von |cff3c9bedKkthnxUI|r zurücksetzen willst?",
	ResolutionChanged = "Deine Grafikauflösung wurde geändert und der Spieleclient muss neu gestartet werden. Möchtest Du das Spiel jetzt neu starten?",
	SettingsAll = "|cffff0000WARNUNG|r |n|nWenn Du auf Annehmen klickst werden alle Einstellungen für die Addons übernommen, die von |cff3c9bedKkthnxUI|r unterstützt werden. Diese Einstellungen sind unwirksam, wenn keine unterstützten Addons installiert sind.",
	SettingsBW = "Einige Elemente von BigWigs müssen verschoben werden.",
	SettingsDBM = "Wir müssen die Leistenpositionen von |cff3c9bedDBM|r ändern.",
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "Schlachtzug auflösen",
	DisbandRaid = "Bist Du sicher, dass Du den Schlachtzug auflösen willst?"
}

-- Tooltip Localization
L.Tooltip = {
	AchievementComplete = "Dein Status: Abgeschlossen am ",
	AchievementIncomplete = "Dein Status: Unvollständig",
	AchievementStatus = "Dein Status:",
	ItemCount = "Gegenstandsanzahl:",
	ItemID = "Gegenstands-ID:",
	SpellID = "Zauber-ID:"
}

L.WatchFrame = {
	WowheadLink = "Wowhead Link"
}

L.Welcome = {
	Line1 = "Willkommen bei |cff3c9bedKkthnxUI|r v",
	Line2 = "",
	Line3 = "Tippe /cfg in den Chat ein um Dein Interface einzurichten",
	Line4 = "",
	Line5 = "Einige Fragen werden Dir eventuell durch den Chatbefehl /uihelp"
}

L.Zone = {
	ArathiBasin = "Arathi Basin",
	Gilneas = "The Battle for Gilneas"
}

L.SlashCommand = {
	Help = {
		"",
		"|cff3c9bedVerfügbare Charbefehle:|r",
		"--------------------------",
		"/rl - Läd das Interface neu.",
		"/rc - Aktivert den Readycheck.",
		"/gm - Öffnet das GM Fenster.",
		"/rd - Löst den Schlachtzug, oder die Party auf.",
		"/toraid - Konvertiert die Gruppe in einen Schlachtzug.",
		"/teleport - Teleportation aus einen zufälligen Dungeon.",
		"/spec, /ss - Wechselt zwischen den Talentspezialisierungen.",
		"/frame - Zeigt die Fenstereigeneschaften an.",
		"/farmmode - Vergrössert den Minimapausschnitt.",
		"/moveui - Erlaubt das Verschieben der Interface Elemente.",
		"/resetui - Setzt die Einstellungen auf den Standartwert zurück.",
		"/resetconfig - Setzt alle Einstellungen aus dem KkthnxUI_Config Menü auf den Standartwert zurück.",
		"/settings ADDON_NAME - Übernimmt die Einstellungen für msbt, dbm, skada, oder allen Addons.",
		"/pulsecd - Abklingzeit Pulsetest.",
		"/tt - Ziel anflüstern.",
		"/ainv - Aktiviert die automatischen Einladungen.",
		"/cfg - Öffnet das Interface Einstellgsmenü.",
		"/patch - Zeigt die Wow Patch Info.",
		"",
		"|cff3c9bedVerfügbare, versteckte Features:|r",
		"--------------------------",
		"Rechtsklick auf die Minimap zeigt das Mikromenü.",
		"Mit der mittleren Maustaste auf die Minimap klicken zeigt das Aufspührmenü.",
		"Linksklick auf die Erfahrungsleiste öffnet das Ruffenster.",
		"Linksklick auf die Artefaktleiste öffnet die Artefaktübersicht.",
		"Halte ALT und fahre mit der Maus über einen Spieler um sein ilvl und Spez im Tooltip zu sehen.",
		"Halte Shift um mit der Maus schnell ans Ende oder Anfang im Chat zu scrollen.",
		"Chatkopie aufrufen ->Rechtsunten im Chat auf das Symbol klicken.",
		"Mit der mittleren Maustaste auf das Chatkopie Symbol klicken um zu würfeln -> /roll.",
	}
}