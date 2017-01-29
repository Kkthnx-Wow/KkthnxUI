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
	FPUse = "%s utilisé %s.",
	Interrupted = INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!",
	PCAborted = "Pull annulé!",
	PCGo = "GO!",
	PCMessage = "Pulling %s dans %s..",
	Recieved = " reçu de ",
	Sapped = "Sappé",
	SappedBy = "Sappé par: ",
	SSThanks = "Merci pour "
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
	AFK = "|cffff0000[AFK]|r",
	BigChatOff = "Grande fonction de tchat désactivée",
	BigChatOn = "Grande fonction de tchat activée",
	DND = "|cffe7e716[DND]|r",
	Guild = "G",
	GuildRecruitment = "GuildRecruitment",
	Instance = "I",
	InstanceLeader = "IL",
	LocalDefense = "LocalDefense",
	LookingForGroup = "LookingForGroup",
	Officer = "O",
	Party = "P",
	PartyLeader = "P",
	Raid = "R",
	RaidLeader = "R",
	RaidWarning = "W",
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
	ShiftClick = "Shift + click:",
	Skada = "Toggle Skada",
}

-- Cooldowns
L.Cooldowns = {
	Cooldowns = "CD: ",
	CombatRes = "BattleRes",
	CombatResRemainder = "Résurrection de bataille : ",
	NextTime = "Prochaine fois: "
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
	Header2 = "1. Essentiels",
	Header3 = "2. Unitframes",
	Header4 = "3. Features",
	Header5 = "4. Choses que vous devez savoir!",
	Header6 = "5. Commandes",
	Header7 = "6. Fini",
	Header8 = "1. Paramètres essentiels",
	Header9 = "2. Social",
	Header10 = "3. Frames",
	Header11 = "4. Success!",
	InitLine1 = "Merci d'avoir choisi KkthnxUI!",
	InitLine2 = "Vous serez guidé par le processus d'installation simple en quelques étapes. À chaque étape, vous pouvez décider si vous souhaitez ou non appliquer les paramètres présentés.",
	InitLine3 = "Vous êtes également invité à suivre le tutoriel sur certaines des caractéristiques KkthnxUI.",
	InitLine4 = "Appuyez sur le bouton 'Tutoriel' pour vous guider dans cette petite introduction, ou appuyez sur 'Installer' pour sauter cette étape.",
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
	ButtonTutorial = "Tutoriel",
	ButtonInstall = "Installer",
	ButtonNext = "Suivant",
	ButtonSkip = "Passer",
	ButtonContinue = "Continuer",
	ButtonFinish = "Finir",
	ButtonClose = "Fermer",
	Complete = "Installation terminé"
}

-- tutorial 1
L.Tutorial = {
	Step1Line1 = "Ce didacticiel rapide vous montrera quelques-unes des fonctionnalités de KkthnxUI.",
	Step1Line2 = "Tout d'abord, l'essentiel que vous devez savoir avant de pouvoir jouer avec ce UI.",
	Step1Line3 = "Cet installateur est partiellement spécifique aux personnages. Bien que certains des paramètres qui seront appliqués plus tard sont à l'échelle du compte, vous devez exécuter le script d'installation pour chaque nouveau personnage exécutant KkthnxUI. Le script est automatiquement affiché sur chaque nouveau personnage que vous ouvrez une session avec KkthnxUI installé pour la première fois. En outre, les options peuvent être trouvées dans /KkthnxUI/Config/Settings.lua pour `Power` utilisateurs ou en tapant /KkthnxUI dans le jeu pour `Friendly` .",
	Step1Line4 = "Un utilisateur puissant est un utilisateur d'un ordinateur personnel qui a la capacité d'utiliser des fonctionnalités avancées (ex: Lua édition) qui sont au-delà des capacités des utilisateurs normaux. Un utilisateur convivial est un utilisateur normal et n'est pas nécessairement capable de programmer. Il est recommandé pour eux d'utiliser notre outil de configuration dans le jeu (/ KkthnxUI) pour les paramètres qu'ils souhaitent être modifiés dans KkthnxUI.",
	Step2Line1 = "KkthnxUI Inclut une version intégrée de oUF (oUFKkthnxUI) créée par Haste. Cela gère toutes les trames de l'unité sur l'écran, les buffs et debuffs, et les éléments spécifiques à la classe.",
	Step2Line2 = "Vous pouvez visiter wowinterface.com et recherchez oUF pour plus d'informations sur cet outil.",
	Step2Line3 = "Pour changer facilement les positions unitframes, tapez simplement / moveui.",
	Step2Line4 = "",
	Step3Line1 = "KkthnxUI est une interface utilisateur redessinée de Blizzard. Rien de moins, rien de plus. Approximativement toutes les fonctionnalités que vous voyez avec l'interface utilisateur par défaut est disponible par KkthnxUI. Les seules fonctionnalités non disponibles via l'interface utilisateur par défaut sont certaines fonctionnalités automatisées qui ne sont pas vraiment visibles à l'écran, par exemple, la vente d'objets gris lorsque vous visitez un fournisseur ou, les sacs de tri automatique.",
	Step3Line2 = "Ce n'est pas tout le monde qui aime des choses comme les compteurs DPS, Boss mods, les compteurs de menace, etc, nous jugeons que c'est la meilleure chose à faire. KkthnxUI est fait autour de l'idée de travailler pour toutes les classes, les rôles, les spécifications, le type de gameplay, le goût des utilisateurs, etc. C'est pourquoi KkthnxUI est l'une des interfaces utilisateur les plus populaires actuellement. Il s'adapte à tous les styles de jeu et est extrêmement modifiable. Il est également conçu pour être un bon début pour tout le monde qui veulent faire leur propre interface personnalisée sans dépendre des add-ons. Depuis 2012, beaucoup d'utilisateurs ont commencé à utiliser KkthnxUI comme base pour leur propre interface utilisateur.",
	Step3Line3 = "Les utilisateurs peuvent visiter notre section de mods supplémentaires sur notre site Web ou en visitant www.wowinterface.com pour installer des fonctionnalités supplémentaires ou des mods.",
	Step3Line4 = "",
	Step4Line1 = "Pour définir le nombre de barres souhaitées, placez la souris sur la gauche ou la droite de la barre d'action inférieure. Faites la même chose sur la droite, par le bas. Pour copier le texte du cadre de discussion, cliquez sur le bouton affiché sur la souris dans le coin inférieur droit des images de chat.",
	Step4Line2 = "Vous pouvez cliquer avec le bouton gauche de la souris sur 80% du texte de données pour afficher divers panneaux de Blizzard. Ami(e)s et Guilde possède également des fonctions cliquées avec le bouton droit de la souris.",
	Step4Line3 = "Il existe des menus déroulants disponibles. Un clic droit sur le bouton [X] (Fermer) du sac montrera des sacs. En cliquant avec le bouton droit de la souris sur Minimap,.",
	Step4Line4 = "",
	Step5Line1 = "Enfin, KkthnxUI inclut des commandes "/" utiles. Voici une liste.",
	Step5Line2 = "/moveui vous permet de déplacer beaucoup de cadres n'importe où sur l'écran. /rl recharge l'interface.",
	Step5Line3 = "/tt vous permet de chuchoter votre cible. /rc lance un ready check. /rd vous décroche d'un groupe ou un raid. /ainv active les invitations auto par messages privés. (/ainv off) pour désactiver ",
	Step5Line4 = "/gm Bascule le cadre d'aide. /install ou /tutorial charge cet installateur. ",
	Step6Line1 = "Le didacticiel est terminé. Vous pouvez choisir de le reconsulter à tout moment en tapant /tutorial.",
	Step6Line2 = "Je vous suggère de jeter un coup d'oeil à config / config.lua ou de taper / KkthnxUI pour personnaliser l'interface utilisateur selon vos besoins.",
	Step6Line3 = "Vous pouvez maintenant continuer à installer l'interface utilisateur si ce n'est pas encore fait ou si vous voulez rétablir la valeur par défaut!",
	Step6Line4 = "",
	Message1 = "Pour obtenir de l'aide, visitez https://github.com/Kkthnx.",
	Message2 = "Vous pouvez basculer la microbar en utilisant le bouton droit de votre souris sur la mini-carte.",
	Message3 = "Vous pouvez définir vos raccourcis clavier rapidement en tapant /kb.",
	Message4 = "Le focus d'unité peut être définie en tapant / focus lorsque vous ciblez l'unité que vous souhaitez focus. Il est recommandé de faire une macro pour faire cela.",
	Message5 = "Vous pouvez accéder aux fonctions de tchat par la souris sur le coin inférieur droit du panneau de discussion et cliquer gauche sur le bouton qui apparaîtra.",
	Message6 = "Si vous rencontrez des problèmes avec l'interface utilisateur de Kkthnx essayez de désactiver tous vos addons à l'exception de l'interface utilisateur Kkthnx, n'oubliez pas que KkthnxUI est un addon complet de remplacement d'interface utilisateur, vous ne pouvez pas exécuter deux addons qui font la même chose.",
	Message7 = "Pour configurer les canaux qui s'affichent dans le cadre de discussion, cliquez avec le bouton droit de la souris sur l'onglet de discussion et allez dans les paramètres.",
	Message8 = "Vous pouvez utiliser la commande / resetui pour réinitialiser tous vos déplacements effectués sur l'affichage. Vous pouvez également taper / moveui et juste un clic droit sur un module pour réinitialiser sa position.",
	Message9 = "Pour déplacer des capacités sur les barres d'action par défaut, maintenez la touche shift + glisser enfoncée. Vous pouvez modifier la touche de modification dans le menu d'options de la barre d'actions.",
	Message10 = "Vous pouvez voir le niveau d'élément moyen de leur équipement en activant le niveau d'élément pour l'info-bulle"
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

-- Mail Localization
L.Mail = {
	Complete = "Terminé.",
	Messages = "messages",
	Need = "Besoin d'une boîte aux lettres.",
	Stopped = "Arrêté, l'inventaire est complet.",
	Unique = "Arrêté. Trouvé un élément unique en double dans un sac ou en banque."
}

-- World Map Localization
L.Map = {
	Fog = "Brouillard de guerre"
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
	Armory = "Armurerie",
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
}

-- Raid Utility Localization
L.Raid = {
	UtilityDisband = "Dissoudre groupe",
	DisbandRaid = "Êtes-vous sûr de vouloir dissoudre votre groupe?"
}

-- Tooltip Localization
L.Tooltip = {
	AchievementComplete = "Votre statut: Complété le ",
	AchievementIncomplete = "Votre statut: Incomplet",
	AchievementStatus = "Votre statut:",
	ItemCount = "Item count:",
	ItemID = "Item ID:",
	SpellID = "Spell ID:"
}

L.WatchFrame = {
	WowheadLink = "Wowhead Link"
}

L.Welcome = {
	Line1 = "Bienvenue sur |cff3c9bedKkthnxUI|r v",
	Line2 = "",
	Line3 = "Tapez /cfg pour configurer l'interface, ou visitez www.github.com/kkthnx|r",
	Line4 = "",
	Line5 = "Certaines de vos questions peuvent être répondu sur /uihelp"
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
		"/pulsecd - Test de cooldown.",
		"/tt - Cible de chuchotement.",
		"/ainv - Autorise les invitations automatiques.",
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