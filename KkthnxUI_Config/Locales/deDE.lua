if (GetLocale() ~= "deDE") then return end

-- Localization for deDE

local PerformanceSlight = "\n|cffFF0000Eine Deaktivierung könnte die Spielperformance leicht erhöhen|r" -- For semi-high CPU options
local ToggleOffReminder = "\n|cffFF0000Schalte diesen Menüpunt aus, um Deine Aktionsleisten manuell zu steuern|r"

-- Actionbar
UIConfigLocal.ActionBarBottomBars = "Anzahl der Leisten am unteren Rand (1, 2 oder 3)"
UIConfigLocal.ActionBarButtonSize = "Buttongröße"
UIConfigLocal.ActionBarButtonSpace = "Buttonabstand"
UIConfigLocal.ActionBarEnable = "Aktivere Aktionsleisten"
UIConfigLocal.ActionBarEquipBorder = "Zeige einen grünen Rand um angelegte Items"
UIConfigLocal.ActionBarGrid = "Zeige leere Aktionleistenplätze an"
UIConfigLocal.ActionBarHideHighlight = "Verstecke Proc Anzeigen"
UIConfigLocal.ActionBarHotkey = "Zeige Hotkey auf den Buttons"
UIConfigLocal.ActionBarMacro = "Zeige Makronamen auf den Buttons"
UIConfigLocal.ActionBarOutOfMana = "Farbe wenn Mana leer"
UIConfigLocal.ActionBarOutOfRange = "Farbe wenn ausser Reichweite"
UIConfigLocal.ActionBarPetBarHide = "Verstecke die Begleiterleiste"
UIConfigLocal.ActionBarPetBarHorizontal = "Aktiviere horizontale Begleiterleiste"
UIConfigLocal.ActionBarPetBarMouseover = "Begleiterleiste bei mouseover (nur für horizontale Begleiterleiste)"
UIConfigLocal.ActionBarRightBars = "Anzahl der Aktionsleisten rechts (0, 1, 2 oder 3)"
UIConfigLocal.ActionBarRightBarsMouseover = "Rechte Leisten bei mouseover"
UIConfigLocal.ActionBarSelfCast = "Immer Selbstzauber bei rechtsklick (ungeachtet des momentanten Ziels)"
UIConfigLocal.ActionBarSplitBars = "Teile die fünfte Aktionsleiste auf zwei Leisten mit 6 Buttons auf"
UIConfigLocal.ActionBarStanceBarHide = "Verstecke die Haltungsleiste"
UIConfigLocal.ActionBarStanceBarHorizontal = "Aktiviere horizontale Haltungsleiste"
UIConfigLocal.ActionBarStanceBarMouseover = "Haltungsleiste bei mouseover"
UIConfigLocal.ActionBarToggleMode = "Aktivere Umschaltmode"..ToggleOffReminder

-- Ankündigungen
UIConfigLocal.Announcements = "Ankündigungen"
UIConfigLocal.AnnouncementsInterrupt = "Ankündigungen im Gruppen-/Schlachtzugchat wenn Du jemanden unterbrochen hast."
UIConfigLocal.AnnouncementsPullCountdown = "Simples Script um einen Pulltimer zu starten. Tippe /pc in den Chat."
UIConfigLocal.AnnouncementsSaySapped = "Kopfnussansage wenn die ein |cFFFFF569Schurke|r aus dem Kampf genommen hat."

-- Automatisierung
UIConfigLocal.Automation = "Automatisierung"
UIConfigLocal.AutomationAutoCollapse = "Automatisches Einklappen der Questanzeige in Instanzen"
UIConfigLocal.AutomationAutoInvite = "Automatisches Akzeptieren von Einladungen (NUR Freunde/Gildenmitglieder)"
UIConfigLocal.AutomationDeclineDuel = "Automatische Ablehnung von Duellen"
UIConfigLocal.AutomationResurrection = "Automatisches Wiederbeleben auf Schlachtfeldern"
UIConfigLocal.AutomationScreenShot = "Automatisches Bildschirmfoto bei erreichen eines Erfolges"

-- Taschen
UIConfigLocal.Bags = "Taschen"
UIConfigLocal.BagsButtonSize = "Größe der Taschenplätze"
UIConfigLocal.BagsEnable = "Aktiviere die 'Alles in einer Tasche' Ansicht"
UIConfigLocal.BagsInsertLeftToRight = "Set the loot to the left most bag first"
UIConfigLocal.BagsItemsPerRow = "aschenplatzanzahl pro Reihe"
UIConfigLocal.BagsSortRightToLeft = "Sort bags right to left, bottom to top"
UIConfigLocal.BagsSpacing = "Zwischenraum zwischen den Taschenslots"

-- Blizzard
UIConfigLocal.Blizzard = "Blizzard"
UIConfigLocal.BlizzardColorTextures = "Passe von den meisten UI Texturen den Farbton an."
UIConfigLocal.BlizzardRaidTools = "Raid Hilfsmittel"
UIConfigLocal.BlizzardReplaceBlizzardFonts = "Ersetze die Standard |cff00B4FFBlizzard Schriftarten|r auf vielen UI Elementen der |cff3c9bedKkthnxUI|r."
UIConfigLocal.BlizzardTalkingHeadScale = "Scale the Talking Head Frame"
UIConfigLocal.BlizzardTexturesColor = "UI Texturfarbton"

-- Datenleisten
UIConfigLocal.DataBars = "Datenleisten"
UIConfigLocal.DataBarsArtifactColor = "Farbe der Artefaktleiste"
UIConfigLocal.DataBarsArtifactEnable = "Aktiviere die Artefaktleiste"
UIConfigLocal.DataBarsArtifactFade = "Verblassen der Artefaktleiste"
UIConfigLocal.DataBarsArtifactHeight = "Höhe der Artefaktleiste"
UIConfigLocal.DataBarsArtifactWidth = "Breite der Artefaktleiste"
UIConfigLocal.DataBarsExperienceColor = "Farbe der Erfahrungsleiste"
UIConfigLocal.DataBarsExperienceEnable = "Aktiviere die Erfahrungsleiste"
UIConfigLocal.DataBarsExperienceFade = "Fade Experience bar"
UIConfigLocal.DataBarsExperienceHeight = "Höhe der Erfahrungsleiste"
UIConfigLocal.DataBarsExperienceRestedColor = "Farbe der Erfahrungsleiste (Erholung)"
UIConfigLocal.DataBarsExperienceWidth = "Breite der Erfahrungsleiste"
UIConfigLocal.DataBarsHonorColor = "Farbe der Ehreleiste"
UIConfigLocal.DataBarsHonorEnable = "Aktiviere die Ehreleiste"
UIConfigLocal.DataBarsHonorFade = "Verblassen der Ehreleiste"
UIConfigLocal.DataBarsHonorHeight = "Höhe der Ehreleiste"
UIConfigLocal.DataBarsHonorWidth = "Breite der Ehreleiste"
UIConfigLocal.DataBarsInfoText = "Display info text on all databars"
UIConfigLocal.DataBarsReputationEnable = "Aktiviere die Rufleiste"
UIConfigLocal.DataBarsReputationFade = "Verblassen der Rufleiste"
UIConfigLocal.DataBarsReputationHeight = "Höhe der Rufleiste"
UIConfigLocal.DataBarsReputationWidth = "Breite der Rufleiste"

-- Auren
UIConfigLocal.Auras = "Auren"
UIConfigLocal.AurasAnimation = "Zeige eine 'pop in' Animation der Auren"..PerformanceSlight
UIConfigLocal.AurasBuffsPerRow = "Anzahl der Stärkungszauber bevor eine neue Zeile angefangen wird"
UIConfigLocal.AurasConsolidate = "Auren einklappen"
UIConfigLocal.AurasEnable = "Aktivere Auren"
UIConfigLocal.AurasFlash = "Aufblitzen der Auren, wenn die Zeit fast abgelaufen ist"..PerformanceSlight
UIConfigLocal.AurasHideBuffs = "Deaktivere die Stärkungszauberanzeige"
UIConfigLocal.AurasHideDebuffs = "Deaktivere die Schwächungszauberanzeige"

-- Chat
UIConfigLocal.ChatBubbleBackdrop = "Entferne den Hintergrund der Sprachblasen."
UIConfigLocal.ChatDamageMeterSpam = "Zeige den 'damage meter spam' zusammengefasst in einem 'line-link' an"
UIConfigLocal.ChatEnable = "Aktiviere Chat"
UIConfigLocal.ChatFading = "Fades out chat messages after a certain period of time."
UIConfigLocal.ChatFadingTimeVisible = "Set how long in seconds the chat messages remain visible before fading out."
UIConfigLocal.ChatFadingTimeFading = "Set how much time the chat messages will spend fading out in seconds."
UIConfigLocal.ChatHeight = "Höhe des Chatfensters"
UIConfigLocal.ChatLinkBrackets = "Zeige URL Links in Klammern"
UIConfigLocal.ChatLinkColor = "Farbe der Links im Chat"
UIConfigLocal.ChatMessageFilter = "Removing some systems spam('Player1' won duel 'Player2')"
UIConfigLocal.ChatOutline = "Verwende einen Umriss um die Schriftart im Chat"
UIConfigLocal.ChatScrollByX = "Setze die Anzahl der Zeile die im Chat gesprungen werden beim scrollen"
UIConfigLocal.ChatSpamFilter = "Removing some players chat spam in trade"
UIConfigLocal.ChatTabsMouseover = "Chattabs bei 'mouseover'"
UIConfigLocal.ChatTabsOutline = "Verwende einen Umriss um die Schritart der Chattabs"
UIConfigLocal.ChatWhispSound = "Spiele einen Sound ab, wenn du eine Flüsternachricht bekommst"
UIConfigLocal.ChatWidth = "Breite des Chatfensters"

-- Datatexte
UIConfigLocal.DataText = "Datatexte"
UIConfigLocal.DataTextBattleground = "Aktiviere die Datatextanzeige auf Schlachtfeldern"
UIConfigLocal.DataTextLocalTime = "Benutze die lokale Zeit bei der Zeitanzeige auf der Minimap, anstatt der Serverzeit"
UIConfigLocal.DataTextSystem = "Aktivere den Datatext unter der Minimap, der Dir Deine FPS & MS anzeigt"
UIConfigLocal.DataTextTime = "Aktiviere den Datatext auf der Minimap, der Dir die Uhrzeit anzeigt"
UIConfigLocal.DataTextTime24Hr = "Stelle die Zeitanzeige in der Minimap auf das 24 Stunden Format um"

-- Fehler
UIConfigLocal.Error = "Fehler"
UIConfigLocal.ErrorBlack = "Verstecke Fehler der Schwarzen Liste"
UIConfigLocal.ErrorWhite = "Zeige Fehler der Weißen Liste"
UIConfigLocal.ErrorCombat = "Verberge alle Fehlermeldungen im Kampf"

-- Abklingzeiten
UIConfigLocal.Cooldown = "Abklingzeiten"
UIConfigLocal.CooldownEnable = "Aktivere das UI Modul für die Abklingzeiten"
UIConfigLocal.CooldownFontSize = "chriftgröße der Abklingzeiten"
UIConfigLocal.CooldownThreshold = "Abklingzeiten Schwellenwert"

-- General
UIConfigLocal.GeneralAutoScale = "AAutomatische UI Skalierung"
UIConfigLocal.GeneralBubbleFontSize = "Schriftgröße in den Sprachblasen"
UIConfigLocal.GeneralDisableTutorialButtons = "Disables the tutorial button found on some frames"
UIConfigLocal.GeneralFontSize = "Set the font size for everything in UI. Note: This doesn't effect everything"
UIConfigLocal.GeneralSpellTolerance = "Periodically update the Spell Tolerance option to your latency"
UIConfigLocal.GeneralTaintLog = "Log Fehler"
UIConfigLocal.GeneralToggleButton = "Toggle button under minimap (if DataText System is enabled)"
UIConfigLocal.GeneralUIScale = "UI Skalierung (Wenn automatische Skalierung deaktivert ist)"
UIConfigLocal.GeneralUseBlizzardFonts = "Use the default blizzard font"
UIConfigLocal.GeneralUseFlatTextures = "Use flat statusbar textures"
UIConfigLocal.GeneralWelcomeMessage = "Willkommensnachricht im Chat anzeigen."

-- Loot
UIConfigLocal.LootAutoGreed = "Aktiviere automatisch auf Gier & Entzaubern würfeln bei grünen Gegenständen auf Max Level"
UIConfigLocal.LootConfirmDisenchant = "Auto confirm disenchant"
UIConfigLocal.LootEnable = "ktiviere das Beutefenster"
UIConfigLocal.LootGroupLoot = "Aktivere das Fenster für die Beute der Gruppen"
UIConfigLocal.LootIconSize = "Symbolgröße"
UIConfigLocal.LootWidth = "Größe des Beutefensters"

-- Minimap
UIConfigLocal.Minimap = "Minimap"
UIConfigLocal.MinimapCalendar = "Calendar icon is shown on minimap"
UIConfigLocal.MinimapCollectButtons = "Sammel die Minimapbuttons und zeige sie in einer Leiste an"
UIConfigLocal.MinimapEnable = "Aktiviere die Minima"
UIConfigLocal.MinimapFadeButtons = "Fade addon button when collected next to minimap"
UIConfigLocal.MinimapGarrison = "Zeige das Garnisonssymbol an der Minimap"
UIConfigLocal.MinimapResetZoom = "Reset Zoom"
UIConfigLocal.MinimapResetZoomTime = "Reset Zoom in seconds"
UIConfigLocal.MinimapSize = "Größe der Minimap"

-- Sonstiges
UIConfigLocal.Misc = "Sonstiges"
UIConfigLocal.MiscAFKCamera = "Drehe die Kamera während Du AFK bist"
UIConfigLocal.MiscAutoRepair = "Repariere automatisch Deine Ausrüstung beim Händler"
UIConfigLocal.MiscAutoSellGrays = "Verkaufe automatisch graue Gegenstände beim Händler"
UIConfigLocal.MiscBGSpam = "Lösche 'Boss Emote spam' während du auf dem Schlachtfeld bist"
UIConfigLocal.MiscColorPicker = "Verbesserte Farbauswahl"
UIConfigLocal.MiscCombatState = "Display a message when you enter/leave combat at the top of the screen"
UIConfigLocal.MiscEnhancedPvpMessages = "Zeigt Schlachtfeld Nachrichten in der Mitte des Bildschirms."
UIConfigLocal.MiscItemLevel = "Zeige den Itemlevel auf Deinen Gegenständen in der Charakterübersicht an"
UIConfigLocal.MiscKillingBlow = "Teilt dir mit ob du den Todesstoß bei einer Kreatur/einem Spieler hattest"
UIConfigLocal.MiscNoBanner = "Autoverstecken des Boss Loot Frame"
UIConfigLocal.MiscPvPEmote = "Does a random emote on a player that you get a killing blow on"
UIConfigLocal.MiscSellMisc = "Automatisches Verkaufen von unnützen Gegenständen die nicht grauer Qualität sind"
UIConfigLocal.MiscSlotDurability = "Zeige die Haltbarkeit auf Deinen Gegenständen in der Charakterübersicht an"
UIConfigLocal.MiscUseGuildRepair = "Bei Benutzung von 'Automatisches Reparieren', benutzte die Gildenbank"

-- Namensplaketten
UIConfigLocal.Nameplates = "Namensplaketten"
UIConfigLocal.NameplatesAdditionalSize = "Zusätzliche Höhe für die ausgewählte Namenplakette"
UIConfigLocal.NameplatesAurasSize = "Größe der Schwächungszauber"
UIConfigLocal.NameplatesBadColor = "Farbe wenn die Bedrohung NICHT ok ist, variert je nach Rolle die Du spielst ->dps/heal"
UIConfigLocal.NameplatesCastbarName = "Zeige namen des Zaubers"
UIConfigLocal.NameplatesCastUnitReaction = "Color castbars by the reaction type of non-player units"
UIConfigLocal.NameplatesClamp = "Setze die Namensplaketten an den oberen Bildschrimrand fest, wenn die ausser Sicht wären"
UIConfigLocal.NameplatesDistance = "Zeige Namensplaketten für Einheiten im Sichtbereich"
UIConfigLocal.NameplatesEnable = "Aktiviere die Namensplaketten"
UIConfigLocal.NameplatesEnhancedThreat = "Aktiviere das Bedrohungsfeature. Wechselt automatisch je nach Deiner Rolle"
UIConfigLocal.NameplatesGoodColor = "Farbe wenn die Bedrohung ok ist, variert je nach Rolle die Du spielst ->dps/heal"
UIConfigLocal.NameplatesHealerIcon = "Zeige Symbole über den Namensplaketten an, wenn der Spieler ein Heiler ist"
UIConfigLocal.NameplatesHealthValue = "Zeige die Lebenswerte auf den Plaketten an"
UIConfigLocal.NameplatesHeight = "Höhe der Namensplaketten"
UIConfigLocal.NameplatesNameAbbreviate = "Kürze den Namen wenn er länger als 18 Zeichen ist"
UIConfigLocal.NameplatesFontSize = "Font size for most nameplate text"
UIConfigLocal.NameplatesNearColor = "Verliere/Gewinne Bedrohungsfarbe"
UIConfigLocal.NameplatesOffTankColor = "Offtank threat color"
UIConfigLocal.NameplatesSmooth = "Bars will transition smoothly"
UIConfigLocal.NameplatesTotemIcons = "Show icon above enemy totems nameplate" -- Needs Translation
UIConfigLocal.NameplatesTrackAuras = "Zeige Schwächungszauber"
UIConfigLocal.NameplatesWidth = "Breite der Namensplaketten"

-- Config GUI Buttons
UIConfigLocal.ConfigApplyButton = "Apply"
UIConfigLocal.ConfigButtonReset = "UI zurücksetzen"
UIConfigLocal.ConfigCloseButton = "Close"

-- Config Static Popups
UIConfigLocal.ConfigPerChar = "Bist Du sicher, dass Du auf 'Einstellungen für jeden Charakter einzeln' wechseln willst?"
UIConfigLocal.ConfigResetAll = "Bist Du sicher, dass Du alle Einstellungen für das |cff3c9bedKkthnxUI|r zurücksetzen willst?"
UIConfigLocal.ConfigResetChar = "Bist Du sicher, dass Du die Einstellungen für jeden Deiner Charaktere zurücksetzen willst|r?"
UIConfigLocal.ConfigSetSavedSettings = "Setze Einstellungen für jeden Charakter einzeln"

-- Skins
UIConfigLocal.Skins = "AddOn Skins" -- Needs Translation
UIConfigLocal.SkinsBigWigs = "BigWigs" -- Needs Translation
UIConfigLocal.SkinsChatBubble = "Blizzard Sprachblasen"
UIConfigLocal.SkinsDBM = "DeadlyBossMods" -- Needs Translation
UIConfigLocal.SkinsMinimapButtons = "Minimap buttons" -- Needs Translation
UIConfigLocal.SkinsRecount = "Recount" -- Needs Translation
UIConfigLocal.SkinsSkada = "Skada" -- Needs Translation
UIConfigLocal.SkinsSpy = "Spy" -- Needs Translation
UIConfigLocal.SkinsWeakAuras = "WeakAuras" -- Needs Translation

-- Tooltip
UIConfigLocal.Tooltip = "Tooltip"
UIConfigLocal.TooltipCursor = "Tooltip be anchored to mouse cursor"
UIConfigLocal.TooltipEnable = "Enable tooltip"
UIConfigLocal.TooltipHealthValue = "Numeral health value"
UIConfigLocal.TooltipItemCount = "Display how many of a certain item you have on you"
UIConfigLocal.TooltipItemIcon = "Item icon in tooltip"
UIConfigLocal.TooltipRank = "Display guild ranks if a unit is guilded."
UIConfigLocal.TooltipSpellID = "Display the spell or item ID when mousing over a spell or item tooltip."
UIConfigLocal.TooltipTalents = "Display the players talent spec and item level in the tooltip, this may not instantly update when mousing over players"

-- Einheitenfenster
UIConfigLocal.Unitframe = "Einheitenfenster"
UIConfigLocal.UnitframeCastbarHeight = "Height of the unitframe castbars"
UIConfigLocal.UnitframeCastbarIcon = "Show castbar icons"
UIConfigLocal.UnitframeCastbarLatency = "Show Castbar latency when casting (Player only)"
UIConfigLocal.UnitframeCastbars = "Aktiviere die Zauberleiste"
UIConfigLocal.UnitframeCastbarTicks = "Display tick marks on the castbar for channelled spells."
UIConfigLocal.UnitframeCastbarWidth = "Width of the unitframe castbars"
UIConfigLocal.UnitframeCastClassColor = "Color castbars by the class of player units"
UIConfigLocal.UnitframeCastUnitReaction = "Color castbars by the reaction type of non-player units"
UIConfigLocal.UnitframeClassPortraits = "Aktiviere alten Klassenportraits"
UIConfigLocal.UnitframeColorHealth = "Unit frames will be class colored"
UIConfigLocal.UnitframeCombatText = "Zeige KampfFeedback auf den Einheitenfenstern an"
UIConfigLocal.UnitframeEnable = "Aktiviere die Einheitenfenster"
UIConfigLocal.UnitframeGCDBar = "Blitz für globalen Cooldown"
UIConfigLocal.UnitframeOutline = "Unitframe font outline"
UIConfigLocal.UnitframeParty = "Aktiviere die Gruppenfenster."
UIConfigLocal.UnitframePortraitTimer = "Zeige Portrait Zeiten"
UIConfigLocal.UnitframePowerPredictionBar = "Power prediction bar (Zeigt die wahrscheinlichen Kosten des Zaubers in der Leiste an)"
UIConfigLocal.UnitframeScale = "Skalierung einiger Einheitenfenster."
UIConfigLocal.UnitframeShowArena = "Aktiviere die Arenafenster"
UIConfigLocal.UnitframeShowBoss = "Aktiviere die Bossfenster"
UIConfigLocal.UnitframeShowPlayer = "Zeige dich selbst in der Gruppe an"
UIConfigLocal.UnitframeSmooth = "Bars will transition smoothly"
UIConfigLocal.UnitframeStyle = "Style den Look der Einheitenfenster 'fat oder normal'"
UIConfigLocal.UnitframeThreatGlow = "Aktiviere das Bedrohungsleuchten um die Einheitenfenster"
UIConfigLocal.UnitframeThreatValue = "Visueller Bedrohungstext auf dem Spielerfenster"

-- Schlachtzug
UIConfigLocal.Raidframe = "Raid Frames" -- Needs Translation
UIConfigLocal.RaidframeAuraWatch = "Zeige die Timer für Klassenspezifische Buffs in den Ecken des Schlachtzugsfenster an"
UIConfigLocal.RaidframeDeficitThreshold = "Heilung Schwellenwert"
UIConfigLocal.RaidframeEnable = "Aktiviere Schlachtzugsfenster"
UIConfigLocal.RaidframeHeight = "Höhe der Schlachtzugsfenster"
UIConfigLocal.RaidframeIconSize = "Größe der Schwächungszaubersymbole auf den Schlachtzugsfenstern."
UIConfigLocal.RaidframeMainTankFrames = "Aktiviere die Anzeige von Haupttank/assist Fenstern im Schlachtzug."
UIConfigLocal.RaidframeManabarShow = "Zeige die Manaleiste"
UIConfigLocal.RaidframeMaxUnitPerColumn = "Wieviele Einheitenfenster pro Schlachtzugsreihe"
UIConfigLocal.RaidframeOutline = "Raidframe font outline"
UIConfigLocal.RaidframeRaidAsParty = "Zeige die Schlachtzugsfenster, anstatt der Gruppenfenster."
UIConfigLocal.RaidframeScale = "Skalierung der Schlachtzugsfenster"
UIConfigLocal.RaidframeShowMouseoverHighlight = "SHebe die Einheitenfenster per 'mouseover' hevor"
UIConfigLocal.RaidframeShowNotHereTimer = "Zeige AFK/Offline Zeit an"
UIConfigLocal.RaidframeShowResurrectText = "DZeige Wiederbelebungstext an"
UIConfigLocal.RaidframeShowRolePrefix = "Zeige Rollenpräfixe '> + -'"
UIConfigLocal.RaidframeShowThreatText = "Zeige Bedrohungstext 'AGGRO'"
UIConfigLocal.RaidframeSmooth = "Bars will transition smoothly."
UIConfigLocal.RaidframeWidth = "Breite der Schlachtzugsfenster"

-- Weltkarte
UIConfigLocal.WorldMap = "Weltkarte"
UIConfigLocal.WorldMapAlphaWhenMoving = "Alphawert der Weltkarte wenn Du Dich bewegst."
UIConfigLocal.WorldMapCoordinates = "Zeige Koordinaten auf der Weltkarte an."
UIConfigLocal.WorldMapFadeWhenMoving = "Verblassen der Weltkarte wenn Du Dich bewegst."
UIConfigLocal.WorldMapSmallWorldMap = "Kleine Weltkarte anzeigen."