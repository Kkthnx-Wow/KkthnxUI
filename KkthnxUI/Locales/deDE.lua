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
	Interrupted = INTERRUPTED.." %s's \124cff71d5ff\124HZauber:%d:0\124h[%s]\124h\124r!",
	PCAborted = "Pull ABGEBROCHEN!",
	PCGo = "LOS GEHT'S!",
	PCMessage = "Pulle %s in %s..",
	Sapped = "Kopfnuss",
	SappedBy = "Kopfnuss von: ",
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
	General = "Allgemein",
	Guild = "G",
	GuildRecruitment = "GildenRekrutierung",
	Instance = "I",
	InstanceLeader = "IL",
	InvalidTarget = "Ungültiges Ziel",
	LocalDefense = "LokaleVerteidigung",
	LookingForGroup = "SucheNachGruppe",
	Officer = "O",
	Party = "P",
	PartyLeader = "P",
	Raid = "R",
	RaidLeader = "R",
	RaidWarning = "W",
	Says = "sagen",
	Trade = "Handel",
	Whispers = "flüstern",
	Yells = "schreien",
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
	Skada = "Zeige/Verstecke Skada",
}

-- DataBars Localization
L.DataBars = {
	ArtifactClick = "Toggle Artifact Frame",
	HonorClick = "Toggle Honor Frame",
	ReputationClick = "Toggle Reputation Frame",
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
	Step3Line4 = "Klicke auf 'Fortfahren' um die Einstellungen zu übernehmen, oder klicke auf 'Überspringen' wenn du diesen Installationschritt überspringen möchtest.",
	Step4Line1 = "Installation erfolgreich abgeschlossen.",
	Step4Line2 = "Bitte klick auf 'Fertigstellen' um das UI neu zu laden.",
	Step4Line3 = "",
	Step4Line4 = "Genieße KkthnxUI! Besuche uns bei Discord @ |cff748BD9discord.gg/Kjyebkf|r",
	ButtonInstall = "Installieren",
	ButtonNext = "Weiter",
	ButtonSkip = "Überspringen",
	ButtonContinue = "Forfahren",
	ButtonFinish = "Fertigstellen",
	ButtonClose = "Schließen",
	Complete = "Installation Abgeschlossen"
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
	SetUIScale = "This will set a near 'Pixel Perfect' Scale to your interface. Do you want to proceed?",
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "Schlachtzug auflösen",
	DisbandRaid = "Bist Du sicher, dass Du den Schlachtzug auflösen willst?"
}

-- Tooltip Localization
L.Tooltip = {
	SpellID = "Zauber-ID:",
	ItemCount = "Item count:",
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
		"/tt - Ziel anflüstern.",
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