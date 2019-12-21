-- local MissingDesc = "The description for this module/setting is missing. Someone should really remind Kkthnx to do his job!"
local ModuleNewFeature = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]] -- Used for newly implemented features.
-- local PerformanceIncrease = "|n|nDisabling this may slightly increase performance|r" -- For semi-high CPU options
-- local RestoreDefault = "|n|nRight-click to restore to default" -- For color pickers

local _G = _G

_G.KkthnxUIConfig["deDE"] = {
	-- Menu Groups Display Names
	["GroupNames"] = {
		-- Let's Keep This In Alphabetical Order, Shall We?
		["ActionBar"] = "Aktionsleisten",
		["Announcements"] = "Ansagen",
		["Arena"] = "Arena",
		["Auras"] = "Buffs",
		["Automation"] = "Automatisierung",
		["Boss"] = "Boss",
		["Chat"] = "Chat",
		["DataBars"] = "Datenleisten",
		["DataText"] = "Datentext",
		["Filger"] = "Filger",
		["General"] = "Allgemein",
		["Inventory"] = "Inventar",
		["Loot"] = "Beute",
		["Minimap"] = "Minikarte",
		["Misc"] = "Diverses",
		["Nameplates"] = "Namensplaketten",
		["Party"] = "Gruppe",
		["PulseCooldown"] = "Pulse Cooldown",
		["QuestNotifier"] = "Questbenachrichtigung",
		["Raid"] = "Raid",
		["Skins"] = "Aussehen",
		["Tooltip"] = "Tooltip",
		["UIFonts"] = "Schriftarten",
		["UITextures"] = "Texturen",
		["Unitframe"] = "Einheitenfenster",
		["WorldMap"] = "Weltkarte",
	},

	-- Actionbar Local
	["ActionBar"] = {
		["Cooldowns"] = {
			["Name"] = "Zeige Abklingzeiten",
		},

		["Count"] = {
			["Name"] = "Zeige Gegenstandsanzahl",
		},

		["DecimalCD"] = {
			["Name"] = "Dezimal für Abklingzeiten in 3s",
		},

		["DefaultButtonSize"] = {
			["Name"] = "Größe der Knöpfe der Hauptaktionsleiste",
		},

		["DisableStancePages"] = {
			["Name"] = "Deaktiviere Haltungsseiten (Druiden & Schurken )",
		},

		["Enable"] = {
			["Name"] = "Aktiviere Aktionsleisten",
		},

		["EquipBorder"] = {
			["Name"] = "Angelegte Gegenstände mit Rahmen hervorheben",
		},

		["FadeRightBar"] = {
			["Name"] = "Rechte Aktionsleiste 1 verblassen",
		},

		["FadeRightBar2"] = {
			["Name"] = "Rechte Aktionsleiste 2 verblassen",
		},

		["HideHighlight"] = {
			["Name"] = "Deaktiviere Proc-Hervorhebung",
		},

		["Hotkey"] = {
			["Name"] = "Tastaturkürzel anzeigen",
		},

		["Macro"] = {
			["Name"] = "Makronamen anzeigen",
		},

		["MicroBar"] = {
			["Name"] = "Mikroleiste anzeigen",
		},

		["MicroBarMouseover"] = {
			["Name"] = "Mikroleiste ausblenden",
		},

		["OverrideWA"] = {
			["Name"] = "Verstecke Cooldowns auf WeakAuras",
		},

		["RightButtonSize"] = {
			["Name"] = "Größe der Knöpfe der rechten Aktionsleisten",
		},

		["StancePetSize"] = {
			["Name"] = "Größe der Begleiter- & Haltungsknöpfe",
		}
	},

	-- Announcements Local
	["Announcements"] = {
		["PullCountdown"] = {
			["Name"] = "Pull-Countdown ansagen (/pc #)",
		},

		["SaySapped"] = {
			["Name"] = "Ansagen wenn betäubt",
		},

		["Interrupt"] = {
			["Name"] = "Unterbrechungen ansagen",
		},

		["RareAlert"] = {
			["Name"] = "Announce Rares, Chests & War Supplies",
		},

		["ItemAlert"] = {
			["Name"] = "Announce Items Being Placed",
		}
	},

	-- Automation Local
	["Automation"] = {
		["AutoBubbles"] = {
			["Name"] = "Nachrichtenblasen automatich aktivieren",
			["Desc"] = "Nachrichtenblasen abhängig von der Instanz-Art aktivieren. Werden in Schlachtzügen/Instanzen deaktiviert."
		},

		["AutoCollapse"] = {
			["Name"] = "Zielverfolgung automatisch zusammenklappen",
		},

		["AutoInvite"] = {
			["Name"] = "Einladungen von Freunden & Gildenmitgliedern annehmen",
		},

		["AutoDisenchant"] = {
			["Name"] = "Automatisch mit der 'ALT' Taste entzaubern",
		},

		["AutoQuest"] = {
			["Name"] = "Quests automatisch abgeben & annehmen",
		},

		["AutoRelease"] = {
			["Name"] = "In Schlachtfeldern & Arenen automatisch freilassen",
		},

		["AutoResurrect"] = {
			["Name"] = "Wiederbelebungsversuche automatisch annehmen",
		},

		["AutoResurrectThank"] = {
			["Name"] = "'Danke' sagen wenn wiederbelebt",
		},

		["AutoReward"] = {
			["Name"] = "Questbelohnungen automatisch auswählen",
		},

		["AutoSetRole"] = {
			["Name"] = "Auto Set Your Role In Groups",
		},

		["AutoTabBinder"] = {
			["Name"] = "Nur anderen Spieler mit der Tab-Taste ins Ziel nehmen",
		},

		["BuffThanks"] = {
			["Name"] = "Bei Spielern für Buffs bedanken (nur in der offenen Welt)",
		},

		["BlockMovies"] = {
			["Name"] = "Filme blockieren, die du bereits gesehen hast",
		},

		["DeclinePvPDuel"] = {
			["Name"] = "PvP Duelle ablehnen",
		},

		["WhisperInvite"] = {
			["Name"] = "Schlüsselwort für automatische Einladung (durch flüstern)",
		},
	},

	-- Bags Local
	["Inventory"] = {
		["AutoSell"] = {
			["Name"] = "Automatsicher Verkauf grauer Gegenstände",
			["Desc"] = "Bei Besuch eines Händlers automatisch alle grauen Gegenstände verkaufen.",
		},

		["BagBar"] = {
			["Name"] = "Taschenleiste zeigen",
		},

		["BagBarMouseover"] = {
			["Name"] = "Taschenleiste ausblenden",
		},

		["ButtonSize"] = {
			["Name"] = "Größe der einzelnen Taschenknöpfe",
		},

		["ButtonSpace"] = {
			["Name"] = "Abstand der Taschenknöpfe zueinander",
		},

		["ClassRelatedFilter"] = {
			["Name"] = "Filter für Klassenspezifische Gegenstände",
		},

		["ScrapIcon"] = {
			["Name"] = "Show Scrap Icon",
		},

		["UpgradeIcon"] = {
			["Name"] = "Show Upgrade Icon",
		},

		["QuestItemFilter"] = {
			["Name"] = "Filter für Questgegendstände",
		},

		["TradeGoodsFilter"] = {
			["Name"] = "Filter für Handwerkswaren",
		},

		["BagsWidth"] = {
			["Name"] = "Breite der Taschen",
		},

		["BankWidth"] = {
			["Name"] = "Breite der Bank",
		},

		["DeleteButton"] = {
			["Name"] = "Zeige 'Löschen' Knopf im Inventar",
		},

		["GatherEmpty"] = {
			["Name"] = "Leere Slots als einen Slot aufsummieren",
		},

		["DetailedReport"] = {
			["Name"] = "Verkauf grauer Gegenstände - genauer Bericht",
			["Desc"] = "Zeigt einen genauen Bericht über jeden verkauften Gegenstand, wenn aktiviert.",
		},

		["Enable"] = {
			["Name"] = "Aktivieren",
			["Desc"] = "(De-)Aktivieren des Taschenmoduls.",
		},


		["IconSize"] = {
			["Name"] = "Größe der Slots im Inventar",
		},


		["ItemFilter"] = {
			["Name"] = "Aktiviere Filterung im Inventar",
		},

		["ItemLevel"] = {
			["Name"] = "Gegenstandsstufe anzeigen",
			["Desc"] = "Zeigt die Gegenstandsstufe auf anlegbaren Gegenständen.",
		},

		["JunkIcon"] = {
			["Name"] = "Zeige Müll SymbolShow Junk Icon",
			["Desc"] = "Zeige Müll Symbol auf allen grauen Gegenständen die verkauft werden können.",
		},

		["PulseNewItem"] = {
			["Name"] = "Hebe neue Gegenstände durch einen glühenden Rahmen hervor.",
		},

		["AutoRepair"] = {
			["Name"] = "Ausrüstung automatisch reparieren",
		},

		["ReverseSort"] = {
			["Name"] = "Sortierungsrichtung umkehren",
		},

		["ShowNewItem"] = {
			["Name"] = "Show New Item Glow",
		},

		["SpecialBagsColor"] = {
			["Name"] = "Spezialtaschen einfärben",
			["Desc"] = "Spezielle Taschen einfärben:|n|n- |CFFABD473Jäger|r Köcher oder Munitionsbeutel|n- |CFF8787EDHexenmeister|r Seelenbeutel|n- Verzauberter Magiestoffbeutel|n- Kräuterbeutel"
		},

		["BagsiLvl"] = {
			["Name"] = "Zeige Gegenstandsstufe",
			["Desc"] = "Zeigt Gegenstandsstufe an ausrüstbaren Gegenständen.",
		},
	},

	-- Auras Local
	["Auras"] = {
		["BuffSize"] = {
			["Name"] = "Größe für Stärkungszaubersymbole",
		},

		["BuffsPerRow"] = {
			["Name"] = "Stärkungszauber pro Reihe",
		},

		["DebuffSize"] = {
			["Name"] = "Schwächungszaubersymbolgröße",
		},

		["DebuffsPerRow"] = {
			["Name"] = "Schwächungszauber pro Reihe",
		},

		["Enable"] = {
			["Name"] = "Aktivieren",
		},

		["Reminder"] = {
			["Name"] = "Bufferinnerungen (Ruf/Intelligenz/Gift)",
		},

		["ReverseBuffs"] = {
			["Name"] = "Stärkungszauber erweitern nach Rechts",
		},

		["ReverseDebuffs"] = {
			["Name"] = "Schwächungszauber erweitern nach Rechts",
		},
	},

	-- Chat Local
	["Chat"] = {
		["Background"] = {
			["Name"] = "Chathintergrund anzeigen",
		},

		["BackgroundAlpha"] = {
			["Name"] = "Chat Hintergrund Alpha",
		},

		["BlockAddonAlert"] = {
			["Name"] = "AddOn Warnungen blockieren",
		},

		["ChatItemLevel"] = {
			["Name"] = "Zeige Gegenstandstufe in Chatfenstern",
		},

		["Enable"] = {
			["Name"] = "Chat aktivieren",
		},

		["EnableFilter"] = {
			["Name"] = "Chat-Filter aktivieren",
		},

		["Fading"] = {
			["Name"] = "Chat verblassen",
		},

		["FadingTimeFading"] = {
			["Name"] = "Dauer des Verblassens des Chats",
		},

		["FadingTimeVisible"] = {
			["Name"] = "Zeit, bevor der Chat verblassst wird",
		},

		["Height"] = {
			["Name"] = "Chat-Höhe",
		},

		["QuickJoin"] = {
			["Name"] = "Schnellbeitrittnachrichten",
			["Desc"] = "Zeige anklickbare Schnellbeitrittnachrichten im Chat an."
		},

		["ScrollByX"] = {
			["Name"] = "Scrollen um '#' Zeilen",
		},

		["ShortenChannelNames"] = {
			["Name"] = "Kanalnamen einkürzen",
		},

		["TabsMouseover"] = {
			["Name"] = "Chat-Tabs verblassen",
		},

		["WhisperSound"] = {
			["Name"] = "Geräusch bei Flüstern",
		},

		["Width"] = {
			["Name"] = "Chat-Breite",
		},

	},

	-- Databars Local
	["DataBars"] = {
		["Enable"] = {
			["Name"] = "Datenleisten aktivieren",
		},

		["ExperienceColor"] = {
			["Name"] = "Farbe der Erfahrungsleiste",
		},

		["Height"] = {
			["Name"] = "Datenleistenhöhe",
		},

		["HonorColor"] = {
			["Name"] = "Farbe der Ehrenleiste",
		},

		["MouseOver"] = {
			["Name"] = "Datenleisten verblassen",
		},

		["RestedColor"] = {
			["Name"] = "Farbe der Leiste wenn ausgeruht",
		},

		["Text"] = {
			["Name"] = "Text anzeigen",
		},

		["TrackHonor"] = {
			["Name"] = "Ehre verfolgen",
		},

		["Width"] = {
			["Name"] = "Datenleistenbreite",
		},

	},

	-- DataText Local
	["DataText"] = {
		["Battleground"] = {
			["Name"] = "Schlachtfeldinformationen",
		},

		["LocalTime"] = {
			["Name"] = "12 Stunden Zeitformat",
		},

		["System"] = {
			["Name"] = "FPS und Latenz anzeigen",
		},

		["Time"] = {
			["Name"] = "Zeige Uhrzeit an der Minikarte",
		},

		["Time24Hr"] = {
			["Name"] = "24 Stunden Zeitformat",
		},
	},

	-- Filger Local
	["Filger"] = {
		["BuffSize"] = {
			["Name"] = "Stärkungszaubergröße",
		},

		["CooldownSize"] = {
			["Name"] = "Cooldown Größe",
		},

		["DisableCD"] = {
			["Name"] = "Cooldown-Verfolgung deaktivieren",
		},

		["DisablePvP"] = {
			["Name"] = "PvP-Verfolgung deaktivieren",
		},

		["Expiration"] = {
			["Name"] = "Nach Auslaufzeit sortieren",
		},

		["Enable"] = {
			["Name"] = "Filger aktivieren",
		},

		["MaxTestIcon"] = {
			["Name"] = "Maximale Anzahgl von Testsymbolen",
		},

		["PvPSize"] = {
			["Name"] = "PvP-Symbolgröße",
		},

		["ShowTooltip"] = {
			["Name"] = "Zeige Tooltip, wenn Maus darüber",
		},

		["TestMode"] = {
			["Name"] = "Test-Modus",
		},
	},

	-- General Local
	["General"] = {
		["AutoScale"] = {
			["Name"] = "Automatische Skalierung",
		},

		["ColorTextures"] = {
			["Name"] = "Einfärben der 'meisten' KkthnxUI Ränder",
		},

		["DisableTutorialButtons"] = {
			["Name"] = "Tutorial-Knöpfe deaktivieren",
		},

		["FixGarbageCollect"] = {
			["Name"] = "Müllsammlung korrigieren",
		},

		["FontSize"] = {
			["Name"] = "Allgemeine Schriftgröße",
		},

		["HideErrors"] = {
			["Name"] = "Verstecke 'einige' UI Fehler",
		},

		["LagTolerance"] = {
			["Name"] = "Lagtoleranz automatisch einstellen",
		},

		["MoveBlizzardFrames"] = {
			["Name"] = "Blizzard-Fenster verschieben",
		},

		["ReplaceBlizzardFonts"] = {
			["Name"] = "Ersetze 'einige' Blizzard Schriftarten",
		},

		["TexturesColor"] = {
			["Name"] = "Texturenfarbe",
		},

		["Welcome"] = {
			["Name"] = "Zeige Willkommensnachricht",
		},

		["NumberPrefixStyle"] = {
			["Name"] = "Nummernpräfix-Stil für Einheitenfenster",
		},

		["PortraitStyle"] = {
			["Name"] = "Portraitstil für Einheitenfenster",
		},

		["UIScale"] = {
			["Name"] = "Interface Skalierung",
		},
	},

	-- Loot Local
	["Loot"] = {
		["AutoConfirm"] = {
			["Name"] = "Beutedialoge automatisch bestätigen",
		},

		["AutoGreed"] = {
			["Name"] = "Automatisch 'Gier' für grüne Gegenstände wählen",
		},

		["Enable"] = {
			["Name"] = "Beute-Modul aktivieren",
		},

		["FastLoot"] = {
			["Name"] = "Schnelleres Schnellplündern",
		},

		["GroupLoot"] = {
			["Name"] = "Gruppenbeute aktivieren",
		},
	},

	-- Minimap Local
	["Minimap"] = {
		["Calendar"] = {
			["Name"] = "Kalender anzeigen",
		},

		["Enable"] = {
			["Name"] = "Minikarte aktivieren",
		},

		["ResetZoom"] = {
			["Name"] = "Zoom der Minikarte zurücksetzen",
		},

		["ResetZoomTime"] = {
			["Name"] = "Zeit, nach der der Zoom zurückgesetzt wird",
		},

		["ShowRecycleBin"] = {
			["Name"] = "Zeige Papierkorb",
		},

		["Size"] = {
			["Name"] = "Größe der Minikarte",
		},

		["BlipTexture"] = {
			["Name"] = "Stil der Blip Symbole",
			["Desc"] = "Ändere die Blip Symbole der Minimap für Ressourcen, Gruppenmitglieder etc.",
		},

		["LocationText"] = {
			["Name"] = "Location Text Style",
			["Desc"] = "Change settings for the display of the location text that is on the minimap.",
		},
	},

	-- Miscellaneous Local
	["Misc"] = {
		["AFKCamera"] = {
			["Name"] = "AFK Kamera",
		},

		["ColorPicker"] = {
			["Name"] = "Verbesserter Farbwähler",
		},

		["EnhancedFriends"] = {
			["Name"] = "Verbesserte Farben (Freunde/Gilde +)",
		},

		["GemEnchantInfo"] = {
			["Name"] = "Charakter/Betrachten Edelsteine-/Verzauberungsinfo",
		},

		["ItemLevel"] = {
			["Name"] = "Zeige Charakter/Betrachten Gegenstandsstufe",
		},

		["KillingBlow"] = {
			["Name"] = "Zeige Informationen über deine Tötungsschläge/-treffer",
		},

		["PvPEmote"] = {
			["Name"] = "Automatisches Emote bei Tötungsschlag/-treffer",
		},

		["ShowWowHeadLinks"] = {
			["Name"] = "Zeige Wowhead Links über dem Questlog Fenster",
		},

		["SlotDurability"] = {
			["Name"] = "Zeige Slothaltbarkeit in %",
		},

		["EnchantmentScroll"] = {
			["Name"] = "Create Enchantment Scrolls With A Single Click"

		},

		["ImprovedStats"] = {
			["Name"] = "Display Character Frame Full Stats"

		},

		["NoTalkingHead"] = {
			["Name"] = "Remove And Hide The TalkingHead Frame"

		}
	},

	-- Nameplates Local
	["Nameplates"] = {
		["GoodColor"] = {
			["Name"] = "Farbe für gute Bedrohung",
		},

		["NearColor"] = {
			["Name"] = "Farbe nahe der Bedrohungsgrenze",
		},

		["BadColor"] = {
			["Name"] = "Farbe für schlechte Bedrohung",
		},

		["OffTankColor"] = {
			["Name"] = "Farbe für die Bedrohung des Nebentanks",
		},

		["Clamp"] = {
			["Name"] = "In Sicht halten",
			["Desc"] = "Behält die Namensplaketten am oberen Rand in Sicht wenn diese außerhalb des Sichtfeldes geraten würden."
		},

		["ClassIcons"] = {
			["Name"] = "Zeige gegnerische Klassensymbole",
			["Desc"] = "Zeige gegnerische Klassensymbole um die Klasse einfacher bestimmen zu können. |n|nDies ist sehr nützlich für Farbenblinde!"
		},

		["ClassResource"] = {
			["Name"] = "Zeige Klassenressourcen",
		},

		["Combat"] = {
			["Name"] = "Zeige Namensplaketten im Kampf",
		},

		["Enable"] = {
			["Name"] = "Aktiviere Namensplaketten",
		},

		["HealthValue"] = {
			["Name"] = "Zeige Werte für Lebenspunkte",
		},

		["HealthbarColor"] = {
			["Name"] = "Einfärbung der Lebensleiste",
		},

		["Height"] = {
			["Name"] = "Höhe der Namensplaketten",
		},

		["NonTargetAlpha"] = {
			["Name"] = "Alpha für Nichtziel Namensplaketten",
		},

		["QuestInfo"] = {
			["Name"] = "Zeige Questinformationssymbol",
		},

		["SelectedScale"] = {
			["Name"] = "Ausgewählte Skalierung für Namensplaketten",
		},

		["ShowFullHealth"] = {
			["Name"] = "Zeige Lebenspunkte an",
		},

		["Smooth"] = {
			["Name"] = "Leisten flüssiger zeichnen",
		},

		["TankMode"] = {
			["Name"] = "Tank Modus",
		},

		["Threat"] = {
			["Name"] = "Bedrohung an Namensplakette",
		},

		["TrackAuras"] = {
			["Name"] = "Stärkungs-/Schwächungszauber verfolgen",
		},

		["Width"] = {
			["Name"] = "Breite der Namensplaketten",
		},

		["LevelFormat"] = {
			["Name"] = "Anzeigeformat für das Level",
		},

		["TargetArrowMark"] = {
			["Name"] = "Zeige Zielpfeile",
		},

		["HealthFormat"] = {
			["Name"] = "ANzeigeformat für Lebenspunkte",
		},

		["ShowEnemyCombat"] = {
			["Name"] = "Zeige feindliche im Kampf",
		},

		["ShowFriendlyCombat"] = {
			["Name"] = "Zeige freundliche im Kampf",
		},

		["LoadDistance"] = {
			["Name"] = "Load Distance",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Show Health Prediction Bars",
		},

		["VerticalSpacing"] = {
			["Name"] = "Vertical Spacing",
		}
	},

	-- Skins Local
	["Skins"] = {
		["ChatBubbles"] = {
			["Name"] = "Verändere das Aussehen von Nachrichtenblasen",
		},

		["DBM"] = {
			["Name"] = "Verändere das Aussehen von DeadlyBossMods",
		},

		["Details"] = {
			["Name"] = "Verändere das Aussehen von Details",
		},

		["Hekili"] = {
			["Name"] = "Verändere das Aussehen von Hekili",
		},

		["Skada"] = {
			["Name"] = "Verändere das Aussehen von Skada",
		},

		["TalkingHeadBackdrop"] = {
			["Name"] = "Zeige den Hintergrund des Redenden Kopfes",
		},

		["WeakAuras"] = {
			["Name"] = "Verändere das Aussehen von WeakAuras",
		},
	},

	-- Unitframe Local
	["Unitframe"] = {
		["AdditionalPower"] = {
			["Name"] = "Zeige Druidenmana (nur bei gewandelter Gestalt)",
		},

		["CastClassColor"] = {
			["Name"] = "Zauberleisten in Klassenfarbe",
		},

		["CastReactionColor"] = {
			["Name"] = "Zauberleisten in Reaktionsfarbe",
		},

		["CastbarLatency"] = {
			["Name"] = "Zeige Latenz in Zauberleiste",
		},

		["Castbars"] = {
			["Name"] = "Zauberleisten aktivieren",
		},

		["ClassResources"] = {
			["Name"] = "Show Class Resources",
		},

		["Stagger"] = {
			["Name"] = "Show |CFF00FF96Monk|r Stagger Bar",
		},

		["PlayerPowerPrediction"] = {
			["Name"] = "Show Player Power Prediction",
		},

		["CombatFade"] = {
			["Name"] = "Einheitenfenster ausblenden (außerhalb des Kampfes)",
		},

		["CombatText"] = {
			["Name"] = "Zeige Meldungen des Kamptextes",
		},

		["DebuffHighlight"] = {
			["Name"] = "Zeige Hervorhebung bei Lebenspunkteschwächungszauber",
		},

		["DebuffsOnTop"] = {
			["Name"] = "Zeige Schwächungszauber des Ziels oberhalb",
		},

		["Enable"] = {
			["Name"] = "Einheitenfenster aktivieren",
		},

		["EnergyTick"] = {
			["Name"] = "Zeige Energie-Ticks (Druide / Schurke)",
		},

		["GlobalCooldown"] = {
			["Name"] = "Zeige die Globale Abklingzeit",
		},

		["HealthbarColor"] = {
			["Name"] = "Einfärbung der Lebensleiste",
		},

		["HideTargetofTarget"] = {
			["Name"] = "Verstecke das Ziel des Zieles",
		},

		["OnlyShowPlayerDebuff"] = {
			["Name"] = "Nur eigene Schwächungszauber anzeigen",
		},

		["PlayerBuffs"] = {
			["Name"] = "Zeige Stärkungszauber am Spielerfenster",
		},

		["PlayerCastbarHeight"] = {
			["Name"] = "Höhe der Spielerzauberleiste",
		},

		["PlayerCastbarWidth"] = {
			["Name"] = "Breite der Spielerzauberleiste",
		},

		["PortraitTimers"] = {
			["Name"] = "Zauberzeiten im Portrait anzeigen",
		},

		["PvPIndicator"] = {
			["Name"] = "Zeige PvP-Symbole am Spieler/Ziel",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Zeige hereinkommende Heilung an",
		},

		["ShowPlayerLevel"] = {
			["Name"] = "Zeige Spielerlevel am Spielerfenster",
		},

		["ShowPlayerName"] = {
			["Name"] = "Zeige Spielername am Spielerfenster",
		},

		["Smooth"] = {
			["Name"] = "Leisten flüssiger zeichnen",
		},

		["Swingbar"] = {
			["Name"] = "Zeige Swing-Leiste",
		},

		["SwingbarTimer"] = {
			["Name"] = "Zeige Timer in Swingleiste",
		},

		["TargetCastbarHeight"] = {
			["Name"] = "Höhe der Zielzauberleiste",
		},

		["TargetCastbarWidth"] = {
			["Name"] = "Breite der Zielzauberleiste",
		},

		["TotemBar"] = {
			["Name"] = "Zeige Totemleiste",
		},

		["PlayerHealthFormat"] = {
			["Name"] = "Anzeigeformat für Lebenspunkte des Spielers",
		},

		["PlayerPowerFormat"] = {
			["Name"] = "Anzeigeformat für die Ressource des Spielers",
		},

		["TargetHealthFormat"] = {
			["Name"] = "Anzeigeformat für Lebenspunkte des Zieles",
		},

		["TargetPowerFormat"] = {
			["Name"] = "Anzeigeformat für die Ressource des Zieles",
		},

		["TargetLevelFormat"] = {
			["Name"] = "Anzeigeformat für das Level des Zieles",
		},
	},

	-- Arena Local
	["Arena"] = {
		["Castbars"] = {
			["Name"] = "Zeige Zauberleisten",
		},

		["Enable"] = {
			["Name"] = "Arena-Modul aktivieren",
		},

		["Smooth"] = {
			["Name"] = "Leisten flüssiger zeichnen",
		},
	},

	-- Boss Local
	["Boss"] = {
		["Castbars"] = {
			["Name"] = "Zeige Zauberleisten",
		},

		["Enable"] = {
			["Name"] = "Aktiviere Boss-Modul",
		},

		["Smooth"] = {
			["Name"] = "Leisten flüssiger zeichnen",
		},
	},

	-- Party Local
	["Party"] = {
		["Castbars"] = {
			["Name"] = "Zeige Zauberleisten",
		},

		["Enable"] = {
			["Name"] = "Aktiviere Gruppen-Modul",
		},

		["HorizonParty"] = {
			["Name"] = "Horizontal Party Frames",
		},

		["HealthbarColor"] = {
			["Name"] = "Einfärbung der Lebensleiste",
		},

		["PortraitTimers"] = {
			["Name"] = "Zauberzeiten im Portrait anzeigen",
		},

		["ShowBuffs"] = {
			["Name"] = "Zeige Stärkungszauber der Gruppe",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Zeige hereinkommende Heilung an",
		},

		["ShowPlayer"] = {
			["Name"] = "Zeige Spieler in der Gruppen an",
		},

		["Smooth"] = {
			["Name"] = "Leisten flüssiger zeichnen",
		},

		["TargetHighlight"] = {
			["Name"] = "Hebe das ausgewählte Ziel hervor",
		},

		["PartyHealthFormat"] = {
			["Name"] = "Anzeigeformat für das Leben der Gruppe",
		},

		["PartyPowerFormat"] = {
			["Name"] = "Anzeigeformat für die Ressourcen der Gruppe",
		},
	},

	["PulseCooldown"] = {
		["Enable"] = {
			["Name"] = "Enable PulseCooldown",
		},

		["HoldTime"] = {
			["Name"] = "How Long To Display",
		},

		["MinTreshold"] = {
			["Name"] = "Minimal Threshold Time",
		},

		["Size"] = {
			["Name"] = "Icon Size",
		},

		["Sound"] = {
			["Name"] = "Play Sound On Pulse",
		},
	},

	-- QuestNotifier Local
	["QuestNotifier"] = {
		["Enable"] = {
			["Name"] = "Questbenachrichtigungen aktivieren",
		},

		["QuestProgress"] = {
			["Name"] = "Questfortschritt",
			["Desc"] = "Benachrichtige über Questfortschritt im Chat. Das kann u.U. sehr viel werden, also verärgere deine Gruppe nicht!",
		},

		["OnlyCompleteRing"] = {
			["Name"] = "Nur 'Fertig' Sound",
			["Desc"] = "Spiele nur den Sound ab, wenn eine Quest abgeschlossen wurde"
		},
	},

	-- Raidframe Local
	["Raid"] = {
		["SpecRaidPos"] = {
			["Name"] = "Save Raid Posions Based On Specs",
		},

		["ShowTeamIndex"] = {
			["Name"] = "Show Group Number Team Index",
		},

		["ReverseRaid"] = {
			["Name"] = "Reverse Raid Frame Growth",
		},

		["HorizonRaid"] = {
			["Name"] = "Horizontal Raid Frames",
		},

		["NumGroups"] = {
			["Name"] = "Number Of Groups to Show",
		},

		["AuraDebuffIconSize"] = {
			["Name"] = "Schwächungszaubersymbolgröße",
		},

		["AuraWatch"] = {
			["Name"] = "Zeige Symbole für überwachte Zauber",
		},

		["AuraWatchIconSize"] = {
			["Name"] = "Größe der Symbole für überwachte Zauber",
		},

		["AuraWatchTexture"] = {
			["Name"] = "Textur für Symbole für überwachte Zauber",
		},

		["Enable"] = {
			["Name"] = "Schlachtzugsfenster aktivieren",
		},

		["Height"] = {
			["Name"] = "Höhe des Schlachtzuges",
		},

		["HealthbarColor"] = {
			["Name"] = "Einfärbung der Lebensleiste",
		},

		["MainTankFrames"] = {
			["Name"] = "Zeige Fenster für Haupttanks",
		},

		["ManabarShow"] = {
			["Name"] = "Zeige Manaleisten",
		},

		["MaxUnitPerColumn"] = {
			["Name"] = "Maximale Anzahl von Einheiten pro Spalte",
		},

		["RaidUtility"] = {
			["Name"] = "Show Raid Utility Frame",
		},

		["ShowGroupText"] = {
			["Name"] = "Zeige Spielergruppen #",
		},

		["ShowNotHereTimer"] = {
			["Name"] = "Zeige AFK/DND Status",
		},

		["ShowRolePrefix"] = {
			["Name"] = "Zeige Heiler/Tank Rollen",
		},

		["Smooth"] = {
			["Name"] = "Leisten flüssiger zeichnen",
		},

		["TargetHighlight"] = {
			["Name"] = "Hebe das ausgewählte Ziel hervor",
		},

		["Width"] = {
			["Name"] = "Breite des Schlachtzuges",
		},

		["RaidLayout"] = {
			["Name"] = "Schlachtzugslayout",
		},

		["GroupBy"] = {
			["Name"] = "Sortiere Schlachtzugsfenster",
		},

		["HealthFormat"] = {
			["Name"] = "Anzeigeformat für Lebenspunkte",
		},
	},

	-- Worldmap Local
	["WorldMap"] = {
		["AlphaWhenMoving"] = {
			["Name"] = "Alpha bei Bewegung",
		},

		["Coordinates"] = {
			["Name"] = "Zeige Spieler/Maus Koordinaten",
		},

		["FadeWhenMoving"] = {
			["Name"] = "Weltkarte verblassen lassen bei Bewegung",
		},

		["MapScale"] = {
			["Name"] = "Skalierung der Weltkarte",
		},

		["SmallWorldMap"] = {
			["Name"] = "Kleinere Weltkarte nutzen",
		},

		["WorldMapPlus"] = {
			["Name"] = "Zeige erweiterte Funktionen der Weltkarte",
		},
	},

	-- Tooltip Local
	["Tooltip"] = {
		["AzeriteArmor"] = {
			["Name"] = "Show Azerite Tooltip Traits",
		},

		["ClassColor"] = {
			["Name"] = "Färbe Rahmen abhängig von der Qualität",
		},

		["CombatHide"] = {
			["Name"] = "Verstecke Tooltip im Kampf",
		},

		["Cursor"] = {
			["Name"] = "Tooltip am Mauszeiger",
		},

		["FactionIcon"] = {
			["Name"] = "Zeige Fraktionssymbol",
		},

		["HideJunkGuild"] = {
			["Name"] = "Gildennamen abkürzen",
		},

		["HideRank"] = {
			["Name"] = "Verstecke Gildenrang",
		},

		["HideRealm"] = {
			["Name"] = "Zeige Realm-Namen wenn 'UMSCHALT' gedrückt wird",
		},

		["HideTitle"] = {
			["Name"] = "Verstecke Einheiten Titel",
		},

		["Icons"] = {
			["Name"] = "Gegenstandssymbole",
		},

		["ShowIDs"] = {
			["Name"] = "Zeige IDs im Tooltip",
		},

		["LFDRole"] = {
			["Name"] = "Zeige Symbole für die zugewiesen Rolle",
		},

		["SpecLevelByShift"] = {
			["Name"] = "Zeige Spezialisierung/Gegenstandsstufe wenn 'UMSCHALT' gedürckt wird",
		},

		["TargetBy"] = {
			["Name"] = "Zeige 'Einheit ist Ziel von'",
		},
	},

	-- Fonts Local
	["UIFonts"] = {
		["ActionBarsFonts"] = {
			["Name"] = "Aktionsleiten",
		},

		["AuraFonts"] = {
			["Name"] = "Stärkungs-/Schwächungszauber",
		},

		["ChatFonts"] = {
			["Name"] = "Chat",
		},

		["DataBarsFonts"] = {
			["Name"] = "Datenleisten",
		},

		["DataTextFonts"] = {
			["Name"] = "Datentexte",
		},

		["FilgerFonts"] = {
			["Name"] = "Filger Schriftart",
		},

		["GeneralFonts"] = {
			["Name"] = "Allgemein",
		},

		["InventoryFonts"] = {
			["Name"] = "Inventar",
		},

		["MinimapFonts"] = {
			["Name"] = "Minikarte",
		},

		["NameplateFonts"] = {
			["Name"] = "Namensplaketten",
		},

		["QuestTrackerFonts"] = {
			["Name"] = "Questverfolgung",
		},

		["SkinFonts"] = {
			["Name"] = "Aussehen",
		},

		["TooltipFonts"] = {
			["Name"] = "Tooltip",
		},

		["UnitframeFonts"] = {
			["Name"] = "Einheitenfenster",
		},
	},

	-- Textures Local
	["UITextures"] = {
		["DataBarsTexture"] = {
			["Name"] = "Datenleisten",
		},

		["FilgerTextures"] = {
			["Name"] = "Filger",
		},

		["GeneralTextures"] = {
			["Name"] = "Allgemein",
		},

		["LootTextures"] = {
			["Name"] = "Beute",
		},

		["NameplateTextures"] = {
			["Name"] = "Namensplaketten",
		},

		["QuestTrackerTexture"] = {
			["Name"] = "Questverfolgung",
		},

		["SkinTextures"] = {
			["Name"] = "Aussehen",
		},

		["TooltipTextures"] = {
			["Name"] = "Tooltip",
		},

		["UnitframeTextures"] = {
			["Name"] = "Einheitenfenster",
		},

		["HealPredictionTextures"] = {
			["Name"] = "Heilungsvorhersage",
		},
	}
}