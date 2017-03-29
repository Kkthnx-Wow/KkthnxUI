local K, C, L = unpack(select(2, ...))
if (GetLocale() ~= "frFR") then return end

-- Localization for frFR clients

L.AFKScreen = {
	NoGuild = "Sans Guilde",
	Sun = "Dimanche",
	Mon = "Lundi",
	Tue = "Mardi",
	Wed = "Mercredit",
	Thu = "Jeudi",
	Fri = "Vendredi",
	Sat = "Samedi",
	Jan = "Janvier",
	Feb = "Février",
	Mar = "Mars",
	Apr = "Avril",
	May = "Mai",
	Jun = "Juin",
	Jul = "Juillet",
	Aug = "Août",
	Sep = "Septembre",
	Oct = "Octobre",
	Nov = "Novembre",
	Dec = "Décembre"
}

L.Announce = {
	Interrupted = INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "Pull annulé!",
	PCGo = "GO!",
	PCMessage = "Pulling %s dans %s..",
	Sapped = "Sappé",
	SappedBy = "Sappé par: ",
}

L.Auras = {
	MoveBuffs = "Déplacer les Buffs",
	MoveDebuffs = "Déplacer les Debuffs",
}

-- Merchant Localization
L.Merchant = {
	NotEnoughMoney = "Vous n'avez pas assez d'argent pour réparer!",
	RepairCost = "Vos objets ont été réparés pour",
	SoldTrash = "Vos objets inutiles ont été vendues pour"
}

-- Bindings Localization
L.Bind = {
	Binding = "Binding",
	Cleared = "Tous vos binds sont effacés pour",
	Discard = "Tous les nouveaux raccourcis clavier ont été supprimés.",
	Instruct = "Survolez, votre souris sur n'importe quel bouton d'action, pour le lier. Appuyez sur la touche ESC ou cliquez avec le bouton droit pour effacer le raccourci clavier du bouton d'action actuel.",
	Key = "Key",
	NoSet = "Pas de raccourçis établis",
	Saved = "Tous les raccourçis ont été sauvegardé.",
	Trigger = "Trigger"
}

-- Chat Localization
L.Chat = {
	AFK = "|cffff0000[ABS]|r",
	BigChatOff = "Grande fonction de tchat désactivée",
	BigChatOn = "Grande fonction de tchat activée",
	DND = "|cffe7e716[NPD]|r",
	General = "Général",
	Guild = "G",
	GuildRecruitment = "GuildRecruitment",
	Instance = "I",
	InstanceLeader = "IL",
	InvalidTarget = "Cible incorrecte",
	LocalDefense = "LocalDefense",
	LookingForGroup = "LookingForGroup",
	Officer = "O",
	Party = "Gr",
	PartyLeader = "CdG",
	Raid = "R",
	RaidLeader = "R",
	RaidWarning = "W",
	Says = "dit",
	Trade = "Commerce",
	Whispers = "chuchote",
	Yells = "crie",
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
	ArtifactClick = "Clique: Ouvre l'aperçu de l'artefact",
	ArtifactRemaining = "|cffe6cc80Remaining: %s|r",
	HonorLeftClick = "|cffcacacaLeft Clique: Ouvre le menu d'honneur|r",
}

-- DataText Localization
L.DataText = {
	Bandwidth = "Bande passante",
	BaseAssault = "Bases assaillies:",
	BaseDefend = "Bases défendues:",
	CartControl = "Chariots contrôlés:",
	Damage = "Dégat: ",
	DamageDone = "Dégat fait:",
	Death = "Morts:",
	DemolisherDestroy = "Démolisseurs détruits:",
	Download = "Télécharger",
	FlagCapture = "Drapeaux capturés:",
	FlagReturn = "Drapeaux retournés:",
	GateDestroy = "Portes détruites:",
	GraveyardAssault = "Cimetières assaillis:",
	GraveyardDefend = "Cimetières défendus:",
	Healing = "Guérison: ",
	HealingDone = "Guérison fait:",
	HomeLatency = "Latence:",
	Honor = "Honneur: ",
	HonorableKill = "Victoires honorables:",
	HonorGained = "Honneur gagné:",
	KillingBlow = "Coups tueur: ",
	MemoryUsage = "(Maintenez SHIFT) Utilisation de la mémoire",
	OrbPossession = "Orb Possessions:",
	SavedDungeons = "Donjon sauvegardé(s)",
	SavedRaids = "Raid sauvegardé(s)",
	StatsFor = "Stats pour ",
	TotalCPU = "CPU Total:",
	TotalMemory = "Mémoire totale:",
	TowerAssault = "Tours assaillis:",
	TowerDefend = "Tours défendues:",
	VictoryPts = "Points de victoire:"
}

-- headers
L.Install = {
	Header1 = "Bienvenue",
	Header8 = "1. Paramètres essentiels",
	Header9 = "2. Social",
	Header10 = "3. Frames",
	Header11 = "4. Success!",
	InitLine1 = "Merci d'avoir choisi KkthnxUI!",
	InitLine2 = "Vous serez guidé par le processus d'installation simple en quelques étapes. À chaque étape, vous pouvez décider si vous souhaitez ou non appliquer les paramètres présentés.",
	Step1Line1 = "Ces étapes appliqueront les paramètres CVar correctes pour KkthnxUI.",
	Step1Line2 = "La première étape s'applique aux paramètres essentiels.",
	Step1Line3 = "C'est |cffff0000recommended|r pour tout utilisateur à moins que vous ne souhaitiez appliquer qu'une partie spécifique des paramètres.",
	Step1Line4 = "Cliquez sur 'Continuer' pour appliquer les paramètres, ou cliquez sur 'Passer' si vous souhaitez sauter cette étape.",
	Step2Line0 = "Un autre addon de discussion est trouvé. Nous ignorerons cette étape. Veuillez cliquer sur Sauter pour continuer l'installation..",
	Step2Line1 = "La deuxième étape s'applique à la configuration de chat correcte.",
	Step2Line2 = "Si vous êtes un nouvel utilisateur, cette étape est recommandée. Si vous êtes un utilisateur confirmé, vous pouvez sauter cette étape.",
	Step2Line3 = "Il est normal que votre police d'écriture de tchat s'affiche trop grande lors de l'application de ces paramètres. Il revient à la normale lorsque vous avez terminé avec l'installation.",
	Step2Line4 = "Cliquez sur 'Continuer' pour appliquer les paramètres ou cliquez sur 'Passer' si vous souhaitez ignorer cette étape.",
	Step3Line1 = "La troisième et dernière étape s'applique aux positions de trame par défaut.",
	Step3Line2 = "Cette étape est |cffff0000recommended|r pour les nouveaux utilisateurs.",
	Step3Line3 = "",
	Step3Line4 = "Cliquez sur 'Continuer' pour appliquer les paramètres ou cliquez sur 'Passer' si vous souhaitez ignorer cette étape.",
	Step4Line1 = "L'installation est terminée.",
	Step4Line2 = "Cliquez sur le bouton 'Finir' pour recharger l'interface.",
	Step4Line3 = "",
	Step4Line4 = "Profitez de KkthnxUI! Rejoignez-nous sur Discord @ |cff748BD9discord.gg/Kjyebkf|r",
	ButtonInstall = "Installer",
	ButtonNext = "Suivant",
	ButtonSkip = "Passer",
	ButtonContinue = "Continuer",
	ButtonFinish = "Finir",
	ButtonClose = "Fermer",
	Complete = "Installation terminé"
}
-- AutoInvite Localization
L.Invite = {
	Enable = "Autoinvite activé: ",
	Disable = "AutoInvite désactivé"
}

-- Info Localization
L.Info = {
	Disabnd = "Dissoudre groupe...",
	Duel = "Décliné les invites en duel de ",
	Errors = "Pas encore d'erreur.",
	Invite = "Invitation accepté de ",
	NotInstalled = " n'est pas installé.",
	PetDuel = "Demande en duel de pet refusée ",
	SettingsALL = "Tapez /settings all, pour appliquer les paramètres pour toutes les modifications.",
	SettingsDBM = "Tapez /settings dbm, pour appliquer les paramètres DBM.",
	SettingsMSBT = "Tapez /settings msbt, pour appliquer les paramètres MSBT.",
	SettingsSKADA = "Tapez /settings skada, pour appliquer les paramètres Skada.",
	SkinDisabled1 = "Skin pour ",
	SkinDisabled2 = " est désactivé."
}

-- Loot Localization
L.Loot = {
	Announce = "Annoncer à",
	Cannot = "Ne peut pas roll",
	Chest = ">> Loot d'un coffre",
	Fish = "Loot de pêche",
	Monster = ">> Loot de ",
	Random = "Joueur aléatoire",
	Self = "Loot personnel",
	ToGuild = " Guilde",
	ToInstance = " Instance",
	ToParty = " Groupe",
	ToRaid = " Raid",
	ToSay = " Dire"
}

-- FarmMode Minimap
L.Minimap = {
	FarmModeOn = "Farm mode activé",
	FarmModeOff = "Farm mode désactivé"
}

-- Misc Localization
L.Misc = {
	BuyStack = "Alt-Click pour acheter un stack",
	Collapse = "The Collapse",
	CopperShort = "|cffeda55fc|r",
	GoldShort = "|cffffd700g|r",
	SilverShort = "|cffc7c7cfs|r",
	TriedToCall = "%s: %s tried to call the protected function '%s'.",
	UIOutdated = "Votre version de KkthnxUI est périmé. Vous pouvez télécharger la dernière version sur Curse.com. Obtenez l'application Curse et demandez à KkthnxUI de mettre à jour automatiquement avec le client!",
	Undress = "Undress"
}

L.Popup = {
	BlizzardAddOns = "Il semble qu'un de vos AddOns a désactivé l'AddOn Blizzard_CompactRaidFrames. Cela peut provoquer des erreurs et d'autres problèmes. L'AddOn sera maintenant réactivé.",
	BoostUI = "|cffff0000WARNING|r |n|nCela permettra d'optimiser vos performances en baissant les graphismes. Cliquez sur accepter seulement si vous avez |cffff0000FPS|r des problèmes!|r",
	DisableUI = "KkthnxUI peut ne pas fonctionner pour cette résolution, voulez-vous désactiver KkthnxUI? (Annuler si vous voulez essayer une avec autre résolution)",
	DisbandRaid = "Êtes-vous sûr de vouloir dissoudre votre groupe?",
	FixActionbars = "Il y a quelque chose qui ne va pas avec vos barres d'actions. Voulez-vous recharger l'interface utilisateur pour le corriger?",
	InstallUI = "Merci d'avoir choisi |cff3c9bedKkthnxUI|r! |n|nAcceptez cette boîte de dialogue d'installation pour appliquer les paramètres.",
	ReloadUI = "L'installation est terminée. Cliquez sur le bouton 'Accepter' pour recharger l'interface utilisateur. Amusez vous |cff3c9bedKkthnxUI|r. |n|n Visitez moi sur |cff3c9bedwww.github.com/kkthnx|r.",
	ResetUI = "Voulez-vous vraiment réinitialiser tous les paramètres |cff3c9bedKkthnxUI|r?",
	ResolutionChanged = "Nous avons détecté un changement de résolution sur votre client World of Warcraft. Nous recommandons fortement de redémarrer votre jeu. Voulez-vous poursuivre?",
	SettingsAll = "|cffff0000WARNING|r |n|nCela s'appliquera à tous les paramètres des addons pris en charge et les importera pour aller avec |cff3c9bedKkthnxUI|r. Cette fonctionnalité ne fera rien si vous n'avez pas l'un des modules complémentaires pris en charge.",
	SettingsBW = "Besoin de changer la position des éléments BigWigs.",
	SettingsDBM = "Nous devons changer les positions |cff3c9bedDBM|r.",
	SetUIScale = "This will set a near 'Pixel Perfect' Scale to your interface. Do you want to proceed?",
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "Dissoudre groupe",
	DisbandRaid = "Êtes-vous sûr de vouloir dissoudre votre groupe?"
}

-- Tooltip Localization
L.Tooltip = {
	ItemCount = "Item count:",
	SpellID = "Spell ID:"
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
		"/rl - Recharger l'interface.",
		"/rc - Active un ready check.",
		"/gm - Ouvre GM frame.",
		"/rd - Dissoudre d'un group ou un raid.",
		"/toraid - Convertir à un group ou raid.",
		"/teleport - Téléportation d'un donjon aléatoire.",
		"/spec, /ss - Changer entre des spécialisations.",
		"/frame - La description n'est pas prête.",
		"/farmmode - Augmente la taille de la mini-carte.",
		"/moveui - Autorise le mouvement de l'interface.",
		"/resetui - Réinitialise les paramètres généraux par défaut.",
		"/resetconfig - Réinitialise les paramètres KkthnxUI_Config.",
		"/settings ADDON_NAME - Applique les paramètres msbt, dbm, skada, ou tous les addons.",
		"/tt - Cible de chuchotement.",
		"/cfg - Ouvre les paramètres de l'interface.",
		"/patch - Afficher les infos de WoW.",
		"",
		"|cff3c9bedFonctions cachées disponibles:|r",
		"--------------------------",
		"Clique-droit minimap pour le micromenu.",
		"Clique du milieu clique minimap pour suivre.",
		"Clique-gauche ouvre le cadre barre d'expérience des réputations.",
		"Clique-gauche artifact bar opens artifact frame.",
		"Maintenez alt pour obtenir le iLVL du joueur et spécialisation dans l'info-bull.",
		"Maintenez shift pour faire défiler instantanément la fin ou le début du chat.",
		"Copy button to the bottom right side of chat.",
		"Middle mouse click copy button to /roll.",
	}
}