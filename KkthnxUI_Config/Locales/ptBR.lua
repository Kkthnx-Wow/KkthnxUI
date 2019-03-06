if (GetLocale() ~= "ptBR") then
	return
end

local MissingDesc = "The description for this module/setting is missing. Someone should really remind Kkthnx to do his job!"
local ModuleNewFeature = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]] -- Used for newly implemented features.
local PerformanceIncrease = "|n|nDisabling this may slightly increase performance|r" -- For semi-high CPU options
local RestoreDefault = "|n|nRight-click to restore to default" -- For color pickers

local _G = _G

local ARENA = _G.ARENA
local AURAS = _G.AURAS
local BATTLEGROUNDS = _G.BATTLEGROUNDS
local BINDING_HEADER_ACTIONBAR = _G.BINDING_HEADER_ACTIONBAR
local BINDING_NAME_TOGGLEGARRISONLANDINGPAGE = _G.BINDING_NAME_TOGGLEGARRISONLANDINGPAGE
local BOSS = _G.BOSS
local CHAT = _G.CHAT
local COMBAT = _G.COMBAT
local DUNGEONS = _G.DUNGEONS
local GARRISON_LANDING_PAGE_TITLE = _G.GARRISON_LANDING_PAGE_TITLE
local GARRISON_LOCATION_TOOLTIP = _G.GARRISON_LOCATION_TOOLTIP
local GENERAL = _G.GENERAL
local INVENTORY_TOOLTIP = _G.INVENTORY_TOOLTIP
local LOOT = _G.LOOT
local MINIMAP_LABEL = _G.MINIMAP_LABEL
local MISCELLANEOUS = _G.MISCELLANEOUS
local PARTY = _G.PARTY
local RAID = _G.RAID
local RAIDS = _G.RAIDS
local RAID_CONTROL = _G.RAID_CONTROL
local REVERSE_NEW_LOOT_TEXT = _G.REVERSE_NEW_LOOT_TEXT
local ROLE = _G.ROLE
local SCENARIOS = _G.SCENARIOS
local UNITFRAME_LABEL = _G.UNITFRAME_LABEL
local UNIT_NAMEPLATES = _G.UNIT_NAMEPLATES
local WORLDMAP_BUTTON = _G.WORLDMAP_BUTTON

KkthnxUIConfig["ptBR"] = {
	-- Menu Groups Display Names
	["GroupNames"] = {
		-- Let's keep this in alphabetical order, shall we?
		["ActionBar"] = BINDING_HEADER_ACTIONBAR,
		["Announcements"] = "Announcements",
		["Arena"] = ARENA,
		["Auras"] = AURAS,
		["Automation"] = "Automation",
		["Boss"] = BOSS,
		["Chat"] = CHAT,
		["DataBars"] = "Data Bars",
		["DataText"] = "Data Text",
		["Filger"] = "Filger",
		["Firestorm"] = "Firestorm", -- this is a realm name and shouldn't be translated.
		["General"] = GENERAL,
		["HealthPrediction"] = "Health Prediction",
		["Inventory"] = INVENTORY_TOOLTIP,
		["Loot"] = LOOT,
		["Minimap"] = MINIMAP_LABEL,
		["MinimapButtons"] = "Minimap Buttons",
		["Misc"] = MISCELLANEOUS,
		["Nameplates"] = UNIT_NAMEPLATES,
		["Party"] = PARTY,
		["Raid"] = RAID,
		["Skins"] = "Skins",
		["Tooltip"] = "Tooltip",
		["Unitframe"] = UNITFRAME_LABEL,
		["WorldMap"] = WORLDMAP_BUTTON
	},

	-- General Local
	["General"] = {
		["AutoScale"] = {
			["Name"] = "Auto Scale",
			["Desc"] = "Automatically scale the User Interface based on your screen resolution",
		},

		["UIScale"] = {
			["Name"] = "UI Scale",
			["Desc"] = "Set a custom UI scale |n|n|cffFF0000'Auto Scale' has to be disabled for this to work|r",
		},

		["DisableTutorialButtons"] = {
			["Name"] = "Disable Tutorial Buttons",
			["Desc"] = "Disables the tutorial buttons found on some frames.",
		},

		["Welcome"] = {
			["Name"] = "Welcome Message",
			["Desc"] = "Enable the `Welcome to KkthnxUI` in chat",
		},

		["FixGarbageCollect"] = {
			["Name"] = "Fix Garabage Collection",
			["Desc"] = "Garbage collection is being overused and misused and it's causing lag and performance drops.|n|nMemory usage is unrelated to performance, and tracking memory usage does not track 'bad' addons.|n|nDevelopers can disable this setting to enable the functionality when looking for memory leaks, but for the average end-user this is a completely pointless thing to track.",
		},

		["ColorTextures"] = {
			["Name"] = "Enable BorderColor",
			["Desc"] = "Change the color of the main border of the UI",
		},

		["TexturesColor"] = {
			["Name"] = "Border Color",
			["Desc"] = "Main border color of the UI. |n|n|cffFF0000'Enable Border Color' has to be enabled for this to work|r"..RestoreDefault,
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Set the font size for most things in the UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, etc.)",
		},

		["LagTolerance"] = {
			["Name"] = "Lag Tolerance",
			["Desc"] = "Automatically update the Blizzard Custom Lag Tolerance option to your latency",
		},

		["MoveBlizzardFrames"] = {
			["Name"] = "Move Blizzard Frames",
		},

		["ReplaceBlizzardFonts"] = {
			["Name"] = "Replace Blizzard Fonts",
			["Desc"] = "Change some of the default Blizzard fonts to match the UI",
		},
	},

	-- Health Prediction Local
	["HealthPrediction"] = {
		["Absorbs"] = {
			["Name"] = "Absorbs",
			["Desc"] = MissingDesc,
		},

		["HealAbsorbs"] = {
			["Name"] = "HealAbsorbs",
			["Desc"] = MissingDesc,
		},

		["Others"] = {
			["Name"] = "Others",
			["Desc"] = MissingDesc,
		},

		["Personal"] = {
			["Name"] = "Personal",
			["Desc"] = MissingDesc,
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},
	},

	-- Loot Local
	["Loot"] = {
		["Enable"] = {
			["Name"] = "Enable Loot",
		},

		["GroupLoot"] = {
			["Name"] = "GroupLoot",
			["Desc"] = "Enable/Disable the loot roll frame.",
		},

		["AutoQuality"] = {
			["Name"] = "Loot Quality",
			["Desc"] = "Sets the auto greed/disenchant quality\n\nUncommon: Rolls on Uncommon only\nRare: Rolls on Rares & Uncommon",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["AutoConfirm"] = {
			["Name"] = "Auto Confirm",
			["Desc"] = "Automatically click OK on BOP items",
		},

		["AutoGreed"] = {
			["Name"] = "Auto Greed",
			["Desc"] = "Automatically greed uncommon (green) quality items at max level",
		},

		["AutoDisenchant"] = {
			["Name"] = "Auto Disenchant",
			["Desc"] = "Automatically disenchant uncommon (green) quality items at max level",
		},

		["Level"] = {
			["Name"] = "Level",
			["Desc"] = "Level to start auto-rolling from",
		},

		["ByLevel"] = {
			["Name"] = "Roll Based On Level",
			["Desc"] = "This will auto-roll if you are above the given level if: You cannot equip the item being rolled on, or the iLevel of your equipped item is higher than the item being rolled on or you have an heirloom equipped in that slot",
		},

		["FastLoot"] = {
			["Name"] = "Fast Loot",
			["Desc"] = "The amount of time it takes to auto loot creatures will be significantly reduced.|n|n|cffFF0000Requires AutoLoot to be enabled!",
		},
	},

	-- Bags Local
	["Inventory"] = {
		["BagColumns"] = {
			["Name"] = "BagColumns",
			["Desc"] = "Number of columns in the main bags",
		},

		["BankColumns"] = {
			["Name"] = "Bank Columns",
			["Desc"] = "Number of columns in the bank",
		},

		["ButtonSize"] = {
			["Name"] = "Button Size",
		},

		["ButtonSpace"] = {
			["Name"] = "Button Space",
		},

		["DetailedReport"] = {
			["Name"] = "Detailed Report",
			["Desc"] = "Displays a detailed report of every item sold when enabled. Disabled to just show the profit or expenses as a total.",
		},

		["Enable"] = {
			["Name"] = "Enable Inventory",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["ItemLevel"] = {
			["Name"] = "Item Level",
			["Desc"] = "Displays item level on equippable items.",
		},

		["ItemLevelThreshold"] = {
			["Name"] = "Item Level Threshold",
			["Desc"] = "The minimum item level required for it to be shown.",
		},

		["PulseNewItem"] = {
			["Name"] = "Pulse New Items",
			["Desc"] = "Flash new items in the bags",
		},

		["JunkIcon"] = {
			["Name"] = "Junk Icon",
			["Desc"] = "Display the junk icon on all grey items that can be vendored.",
		},

		["ScrapIcon"] = {
			["Name"] = "Scrap Icon",
			["Desc"] = "Display the scrap icon on all items that you can scrap.",
		},

		["ReverseLoot"] = {
			["Name"] = REVERSE_NEW_LOOT_TEXT,
			["Desc"] = REVERSE_NEW_LOOT_TEXT,
		},

		["BindText"] = {
			["Name"] = "Bind Text",
			["Desc"] = "Show Bind on Equip/Use Text",
		},

		["SortInverted"] = {
			["Name"] = "Sort Inverted",
			["Desc"] = "Direction the bag sorting will use to allocate the items.",
		},

		["AutoRepair"] = {
			["Name"] = "Auto Repair",
			["Desc"] = "When visiting a repair merchant, automatically repair our gear",
		},

		["AutoSell"] = {
			["Name"] = "Auto Sell Grays",
			["Desc"] = "When visiting a vendor, automatically sell gray quality items",
		},

		["UseGuildRepairFunds"] = {
			["Name"] = "Use Guild Repair",
			["Desc"] = "When using 'Auto Repair', use funds from the Guild Bank",
		},
	},

	["MinimapButtons"] = {
		["EnableBar"] = {
			["Name"] = "Enable Bar",
			["Desc"] = "Enable minimap buttons collected in a bar instead of around the minimap",
		},

		["BarMouseOver"] = {
			["Name"] = "Bar Mouseover",
			["Desc"] = "Make the bar mouseover",
		},

		["ButtonSpacing"] = {
			["Name"] = "Button Spacing",
			["Desc"] = "How much space between each icon (this only applies to the bar being enabled)",
		},

		["ButtonsPerRow"] = {
			["Name"] = "Buttons Per Row",
			["Desc"] = "How many buttons per row (this only applies to the bar being enabled)",
		},

		["IconSize"] = {
			["Name"] = "Icon Size",
			["Desc"] = "Size of the minimap icons",
		},
	},

	-- Actionbar Local
	["ActionBar"] = {
		["MicroBar"] = {
			["Name"] = "Micro Bar",
			["Desc"] = "Enable",
		},

		["MicroBarMouseover"] = {
			["Name"] = "Micro Bar Mouseover",
			["Desc"] = "The MicroBar is not shown unless you mouse over the MicroBar",
		},

		["BottomBars"] = {
			["Name"] = "Bottom Bars",
			["Desc"] = "The amount of bars to display on the bottom. Note: Value can only be 1-3",
		},

		["ButtonSize"] = {
			["Name"] = "Button Size",
			["Desc"] = "The size of the action buttons.",
		},

		["ButtonSpace"] = {
			["Name"] = "Button Space",
			["Desc"] = "The spacing between buttons.",
		},

		["Cooldowns"] = {
			["Name"] = "Cooldowns",
			["Desc"] = "Actionbar cooldowns",
		},

		["Enable"] = {
			["Name"] = "Enable Actionbars",
		},

		["ShowGrid"] = {
			["Name"] = "Actionbar Grid",
			["Desc"] = "Show empty action bar buttons",
		},

		["EquipBorder"] = {
			["Name"] = "Equipped Item Border",
			["Desc"] = "Display Green Border on Equipped Items",
		},

		["RightMouseover"] = {
			["Name"] = "Right Bars Mouseover",
		},

		["PetMouseover"] = {
			["Name"] = "Pet Mouseover",
			["Desc"] = "Petbar mouseover (Only for horizontal petbar)",
		},

		["StanceMouseover"] = {
			["Name"] = "Stance Mouseover",
			["Desc"] = "Stancebar mouseover (Only for horizontal stancebar)",
		},

		["HideHighlight"] = {
			["Name"] = "Proc Highlight",
			["Desc"] = "Hide proc highlight",
		},

		["Hotkey"] = {
			["Name"] = "Hotkey",
			["Desc"] = "Show hotkey on buttons",
		},

		["Macro"] = {
			["Name"] = "Macro",
			["Desc"] = "Show macro name on buttons",
		},

		["OutOfMana"] = {
			["Name"] = "Out Of Mana",
			["Desc"] = "Out of Mana color"..RestoreDefault,
		},

		["OutOfRange"] = {
			["Name"] = "Out Of Range",
			["Desc"] = "Out of Range color"..RestoreDefault,
		},

		["DisableStancePages"] = {
			["Name"] = "Disable Stealth Paging",
			["Desc"] = "Disables automatic page-switching when stealthed. |n|nOnly affects |cffFFF569Rogues|r and |cffFF7D0ADruids|r, has no effect on other classes",
		},

		["PetBarHide"] = {
			["Name"] = "Pet Bar Hide",
			["Desc"] = "Hide pet bar",
		},

		["PetBarHorizontal"] = {
			["Name"] = "Pet Bar Horizontal",
			["Desc"] = "Enable horizontal pet bar",
		},

		["RightBars"] = {
			["Name"] = "Right Bars",
			["Desc"] = "Number of action bars on right (0, 1, 2 or 3)",
		},

		["SplitBars"] = {
			["Name"] = "Split Bars",
			["Desc"] = "Split the fifth bar on two bars on 6 buttons",
		},

		["StanceBarHide"] = {
			["Name"] = "Stance Bar Hide",
			["Desc"] = "Hide stance bar",
		},

		["StanceBarHorizontal"] = {
			["Name"] = "Stance Bar Horizontal",
			["Desc"] = "Enable horizontal stance bar",
		},

		["ToggleMode"] = {
			["Name"] = "Toggle Mode",
			["Desc"] = "Lock / Unlock the toggle mode on our Actionbars (This will always be above the top bar!)",
		},

		["AddNewSpells"] = {
			["Name"] = "Auto Add New Spells",
			["Desc"] = "Auto add new learned spells to the actionbar. (This is needed for some quests)",
		},

		["Font"] = {
			["Name"] = "Font",
		},
	},

	-- Nameplates Local
	["Nameplates"] = {
		["ClassResource"] = {
			["Name"] = "Class Resource",
			["Desc"] = "Display class resources on the nameplates (Combo, Runes...)|n|nDo not forget to enable this in the blizzard options too (Esc > Interface > Names and check Unit Nameplates options)",
		},

		["QuestIcon"] = {
			["Name"] = "Quest Icon",
			["Desc"] = "Show a progress quest icon next to the nameplates.",
		},

		["NonTargetAlpha"] = {
			["Name"] = "Non Target Alpha",
			["Desc"] = "Change the alpha level of the non targeted Nameplates.",
		},

		["Totems"] = {
			["Name"] = "Totems Icons",
			["Desc"] = "Show icon above enemy totems nameplate",
		},

		["TrackAuras"] = {
			["Name"] = "Track Auras",
			["Desc"] = "Show auras on nameplates",
		},

		["ClassIcons"] = {
			["Name"] = "Class Icons",
			["Desc"] = "Icons by class in PvP",
		},

		["TankedByTankColor"] = {
			["Name"] = "Tanked Color",
			["Desc"] = "Use Tanked Color when a nameplate is being effectively tanked by another tank.",
		},

		["BadTransition"] = {
			["Name"] = "Bad Transition",
			["Desc"] = "Bad Transition Color"..RestoreDefault,
		},

		["GoodTransition"] = {
			["Name"] = "Good Transition",
			["Desc"] = "Good Transition Color"..RestoreDefault,
		},

		["AurasSize"] = {
			["Name"] = "Auras Size",
			["Desc"] = "Size of the auras",
		},

		["DecimalLength"] = {
			["Name"] = "Decimal Length",
			["Desc"] = "Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames.",
		},

		["ShowEnemyCombat"] = {
			["Name"] = "Enemy Combat Toggle",
			["Desc"] = "Control enemy nameplates toggling on or off when in combat.",
		},

		["ShowFriendlyCombat"] = {
			["Name"] = "Friendly Combat Toggle",
			["Desc"] = "Control friendly nameplates toggling on or off when in combat.",
		},

		["QuestIconSize"] = {
			["Name"] = "Quest Icon Size",
			["Desc"] = "Size of the questicon on nameplates.",
		},

		["OverlapH"] = {
			["Name"] = "Overlap Horizontal",
			["Desc"] = "How much nameplates will be spaced from one another left/right.",
		},

		["OverlapV"] = {
			["Name"] = "Overlap Vertical",
			["Desc"] = "How much nameplates will be spaced from one another up/down.",
		},

		["BadColor"] = {
			["Name"] = "Bad Color",
			["Desc"] = "Bad threat color, varies depending if your a tank or dps/heal"..RestoreDefault,
		},

		["CastHeight"] = {
			["Name"] = "Cast Height",
			["Desc"] = "Height of castbar",
		},

		["Combat"] = {
			["Name"] = "Combat",
			["Desc"] = "Show nameplates in combat only",
		},

		["Clamp"] = {
			["Name"] = "Clamp",
			["Desc"] = "Clamp nameplates to the top of the screen when outside of view",
		},

		["Distance"] = {
			["Name"] = "Distance",
			["Desc"] = "Show nameplates for units within this range",
		},

		["TargetArrow"] = {
			["Name"] = "Target Arrow",
			["Desc"] = "Display an arrow at the top of the NamePlates to help determine who or what you are targeting",
		},

		["EliteIcon"] = {
			["Name"] = "Elite Icon",
			["Desc"] = "Display an Elite Icon on the right side of the NamePlates.",
		},

		["Enable"] = {
			["Name"] = "Enable Nameplates",
		},

		["Threat"] = {
			["Name"] = "Threat",
			["Desc"] = "Enable threat feature, automatically changes by your role",
		},

		["GoodColor"] = {
			["Name"] = "Good Color",
			["Desc"] = "Good threat color, varies depending if your a tank or dps/heal"..RestoreDefault,
		},

		["MarkHealers"] = {
			["Name"] = "Mark Healers",
			["Desc"] = "Show healer icon beside enemy healers nameplate in battlegrounds",
		},

		["HealthValue"] = {
			["Name"] = "Health Value",
			["Desc"] = "Numeral health value",
		},

		["Height"] = {
			["Name"] = "Height",
		},

		["NearColor"] = {
			["Name"] = "Near Color",
			["Desc"] = "Losing/Gaining threat color"..RestoreDefault,
		},

		["OffTankColor"] = {
			["Name"] = "Off Tank Color",
			["Desc"] = "Offtank threat color"..RestoreDefault,
		},

		["Smooth"] = {
			["Name"] = "Smooth",
			["Desc"] = "Bars will transition smoothly."..PerformanceIncrease,
		},

		["SmoothSpeed"] = {
			["Name"] = "Smooth Speed",
			["Desc"] = "How fast the bars will transition smoothly.",
		},

		["SelectedScale"] = {
			["Name"] = "Selected Scale",
			["Desc"] = "Scale size of the nameplate selected",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["HealthFormat"] = {
			["Name"] = "Health Format",
			["Desc"] = "Health numbers formatting style",
		},

		["Width"] = {
			["Name"] = "Width",
		},
	},

	-- Announcements Local
	["Announcements"] = {
		["PullCountdown"] = {
			["Name"] = "Pull Countdown",
			["Desc"] = "Pull countdown announce (/pc #)",
		},

		["SaySapped"] = {
			["Name"] = "Say Sapped",
			["Desc"] = "Say sapped announcements in /say",
		},

		["Interrupt"] = {
			["Name"] = "Interrupt",
			["Desc"] = "Announce in desired channel when you interrupt",
		},
	},

	-- Automation Local
	["Automation"] = {
		["BlockMovies"] = {
			["Name"] = "Block Movies",
			["Desc"] = "Boss encounter movies will only be allowed to play once (so you can watch each one) and will then be blocked."
		},

		["AutoCollapse"] = {
			["Name"] = "Auto Collapse",
			["Desc"] = "Auto collapse the objective tracker based on the settings below.",
		},

		["AutoReward"] = {
			["Name"] = "Auto Reward",
			["Desc"] = "Automatically selects a reward with highest selling price when quest is completed. Does not really finish the quest.",
		},

		["AutoInvite"] = {
			["Name"] = "Auto Invite",
			["Desc"] = "Automatically accept invites from guild/friends.",
		},

		["AutoQuest"] = {
			["Name"] = "Auto Quest",
			["Desc"] = "Automatically allows the player to quickly accept and deliver quests, among other features, to speed up the questing experience.",
		},

		["InviteKeyword"] = {
			["Name"] = "Invite Keyword",
			["Desc"] = "Automatically accept invites from from anyone who whispers you the invite keyword",
		},

		["AutoRelease"] = {
			["Name"] = "Auto Release",
			["Desc"] = "Automatically releases your spirit when you die XD.",
		},

		["AutoResurrect"] = {
			["Name"] = "Auto Resurrect",
			["Desc"] = "Automatically accepts your resurrection request",
		},

		["AutoResurrectCombat"] = {
			["Name"] = "Auto Resurrect Combat",
			["Desc"] = "Automatically accepts your resurrection request in combat",
		},

		["AutoResurrectThank"] = {
			["Name"] = "Auto Resurrect Thanks",
			["Desc"] = "Automatically say thank you for your resurrection",
		},

		["DeclinePetDuel"] = {
			["Name"] = "Decline Pet Duels",
			["Desc"] = "Automatically decline pet duels",
		},

		["DeclinePvPDuel"] = {
			["Name"] = "Decline PvP Duels",
			["Desc"] = "Automatically decline PvP duels",
		},

		["ScreenShot"] = {
			["Name"] = "Screen Shot",
			["Desc"] = "Automatically and takes a screenshot every time you get an achivement!",
		},

		["Rested"] = {
			["Name"] = "Rested",
		},

		["Garrison"] = {
			["Name"] = GARRISON_LOCATION_TOOLTIP,
		},

		["Orderhall"] = {
			["Name"] = "Class Hall",
		},

		["Battleground"] = {
			["Name"] = BATTLEGROUNDS,
		},

		["Arena"] = {
			["Name"] = ARENA,
		},

		["Dungeon"] = {
			["Name"] = DUNGEONS,
		},

		["Scenario"] = {
			["Name"] = SCENARIOS,
		},

		["Raid"] = {
			["Name"] = RAIDS,
		},

		["Combat"] = {
			["Name"] = COMBAT,
		},
	},

	-- Auras Local
	["Auras"] = {
		["Enable"] = {
			["Name"] = "Enable Auras",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["HorizontalSpacing"] = {
			["Name"] = "Horizontal Spacing",
			["Desc"] = "Horizontal spacing of auras",
		},

		["MaxWraps"] = {
			["Name"] = "Max Wraps",
			["Desc"] = "Maximum number of times the auras will wrap",
		},

		["SeperateOwn"] = {
			["Name"] = "Seperate Own",
			["Desc"] = "Indicate whether buffs you cast yourself should be separated before or after.",
		},

		["Size"] = {
			["Name"] = "Aura Size",
		},

		["VerticalSpacing"] = {
			["Name"] = "Vertical Spacing",
		},

		["WrapAfter"] = {
			["Name"] = "Wrap After",
			["Desc"] = "Begin a new row or column after this many auras.",
		},

		["FadeThreshold"] = {
			["Name"] = "Fade Threshold",
		},

		["GrowthDirection"] = {
			["Name"] = "Growth Direction",
			["Desc"] = MissingDesc,
		},

		["SortDir"] = {
			["Name"] = "Sort Direction",
			["Desc"] = "Defines the sort order of the selected sort method.",
		},

		["SortMethod"] = {
			["Name"] = "Sort Method",
			["Desc"] = "Defines how the group is sorted",
		},
	},

	-- Chat Local
	["Chat"] = {
		["Background"] = {
			["Name"] = "Chat Background",
			["Desc"] = "Add a chat background",
		},

		["BackgroundAlpha"] = {
			["Name"] = "Chat Background Alpha",
			["Desc"] = "Control the alpha of the chat background (0 - 100)",
		},

		["Enable"] = {
			["Name"] = "Enable Chat",
		},

		["Fading"] = {
			["Name"] = "Fading",
			["Desc"] = "Chat fading",
		},

		["WhisperSound"] = {
			["Name"] = "Whisper Sound",
			["Desc"] = "Play a whisper sound",
		},

		["VoiceOverlay"] = {
			["Name"] = "Voice Chat Overlay",
			["Desc"] = "Replace Blizzard's Voice Overlay.",
		},

		["FadingTimeFading"] = {
			["Name"] = "Fading Time Fading",
			["Desc"] = "How fast text will fade",
		},

		["FadingTimeVisible"] = {
			["Name"] = "Fading Time Visible",
			["Desc"] = "Chat Visible Before Fade",
		},

		["ShortenChannelNames"] = {
			["Name"] = "Shorten Channel Names",
		},

		["RemoveRealmNames"] = {
			["Name"] = "Remove Realm Names",
		},

		["Height"] = {
			["Name"] = "Height",
		},

		["LinkBrackets"] = {
			["Name"] = "Link Brackets",
			["Desc"] = "Wrap links in brackets",
		},

		["LinkColor"] = {
			["Name"] = "Link Color",
			["Desc"] = "Color links in chat"..RestoreDefault,
		},

		["QuickJoin"] = {
			["Name"] = "Quick Join",
			["Desc"] = "Show clickable Quick Join messages inside of the chat.",
		},

		["Filter"] = {
			["Name"] = "Spam Filter",
			["Desc"] = "Block annoying spam in chat.",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["ScrollByX"] = {
			["Name"] = "Scroll By X",
			["Desc"] = "Scroll Chat Lines By #",
		},

		["TabsMouseover"] = {
			["Name"] = "Tabs Mouseover",
			["Desc"] = "Mouseover chat tabs",
		},

		["Width"] = {
			["Name"] = "Width",
		},
	},

	-- Databars Local
	["DataBars"] = {
		["Enable"] = {
			["Name"] = "Enable Databars",
		},

		["Text"] = {
			["Name"] = "Text",
			["Desc"] = "Display text on the databars",
		},

		["AzeriteColor"] = {
			["Name"] = "Azerite Color",
			["Desc"] = "Color of the Azerite"..RestoreDefault,
		},

		["MouseOver"] = {
			["Name"] = "Mouseover",
			["Desc"] = "The bars are not shown unless you mouse over them."
		},

		["Width"] = {
			["Name"] = "Width",
		},

		["ExperienceColor"] = {
			["Name"] = "Experience Color",
			["Desc"] = "Color of the Experience"..RestoreDefault,
		},

		["ExperienceRestedColor"] = {
			["Name"] = "Experience Rested Color",
			["Desc"] = "Color of the Rested Experience"..RestoreDefault,
		},

		["Height"] = {
			["Name"] = "Height",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["TrackHonor"] = {
			["Name"] = "Track Honor",
			["Desc"] = "Track your honor experience as a databar",
		},
	},

	-- DataText Local
	["DataText"] = {
		["Battleground"] = {
			["Name"] = "Battleground",
			["Desc"] = "Battleground datatext (Only shows in BGs)",
		},

		["LocalTime"] = {
			["Name"] = "Local Time",
			["Desc"] = "Display local time instead of server / realm time format",
		},

		["Outline"] = {
			["Name"] = "Outline",
		},

		["System"] = {
			["Name"] = "System",
			["Desc"] = "Display FPS-MS at the bottom right corner of the screen",
		},

		["Time"] = {
			["Name"] = "Time",
			["Desc"] = "Display a clock on the bottom of the minimap",
		},

		["Time24Hr"] = {
			["Name"] = "24 Hour Time",
			["Desc"] = "Display 24 time format",
		},
	},

	-- Skins Local
	["Skins"] = {
		["BlizzardBags"] = {
			["Name"] = "Blizzard Bags",
		},

		["Bagnon"] = {
			["Name"] = "Bagnon",
		},

		["BigWigs"] = {
			["Name"] = "BigWigs",
		},

		["ChatBubbles"] = {
			["Name"] = "Chat Bubbles",
		},

		["DBM"] = {
			["Name"] = "Deadly Boss Mods",
		},

		["Recount"] = {
			["Name"] = "Recount",
		},

		["Skada"] = {
			["Name"] = "Skada",
		},

		["Spy"] = {
			["Name"] = "Spy",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["WeakAuras"] = {
			["Name"] = "WeakAuras",
		},
	},

	-- Minimap Local
	["Minimap"] = {
		["Calendar"] = {
			["Name"] = "Calendar",
			["Desc"] = "Display a small calendar",
		},

		["GarrisonLandingPage"] = {
			["Name"] = GARRISON_LANDING_PAGE_TITLE,
			["Desc"] = BINDING_NAME_TOGGLEGARRISONLANDINGPAGE,
		},

		["Enable"] = {
			["Name"] = "Enable Minimap",
		},

		["VignetteAlert"] = {
			["Name"] = "Vignette Alert",
			["Desc"] = "Displays alerts for Treasures and Rares that are on your Minimap so you don't miss them.",
		},

		["ResetZoom"] = {
			["Name"] = "Reset Zoom",
		},

		["ResetZoomTime"] = {
			["Name"] = "Reset Zoom Time",
			["Desc"] = "Reset minimap zoom at the set amount of seconds",
		},

		["Size"] = {
			["Name"] = "Size",
		},
	},

	-- Miscellaneous Local
	["Misc"] = {
		["AFKCamera"] = {
			["Name"] = "AFK Camera",
			["Desc"] = "Watch yourself dance. (Shame on you!)",
		},

		["BattlegroundSpam"] = {
			["Name"] = "Battleground Spam",
			["Desc"] = "Remove Boss Emote spam during BG",
		},

		["NoTalkingHead"] = {
			["Name"] = "Hide TalkingHead",
			["Desc"] = "Removes the message dialog that appears for quests/dungeons",
		},

		["InspectInfo"] = {
			["Name"] = "Display Inspect Info",
			["Desc"] = "Shows item level of each item, enchants, and gems when inspecting another player.",
		},

		["ColorPicker"] = {
			["Name"] = "Improved Color Picker",
			["Desc"] = "Improved ColorPicker",
		},

		["ItemLevel"] = {
			["Name"] = "Item Level",
			["Desc"] = "Item level on character slot buttons",
		},

		["EnhancedFriends"] = {
			["Name"] = "Enhanced Friends List",
			["Desc"] = "Enhances the friends list to look better",
		},

		["ImprovedStats"] = {
			["Name"] = "Improved Stats",
			["Desc"] = "Provides an updated and logical display of the character stats",
		},

		["KillingBlow"] = {
			["Name"] = "Killing Blow",
			["Desc"] = "Display a message about your killing blow",
		},

		["PvPEmote"] = {
			["Name"] = "PVP Emote",
			["Desc"] = "Make a silly emote at the player you just killed (Kkthnx spits on you!)",
		},

		["ProfessionTabs"] = {
			["Name"] = "Enhanced Profession Tabs",
			["Desc"] = "Makes it easier to get to your professions and keep them orderly",
		},

		["SlotDurability"] = {
			["Name"] = "Slot Durability",
			["Desc"] = "Durability percentage on character slot buttons",
		},

		["CharacterInfo"] = {
			["Name"] = "Display Character Info",
			["Desc"] = "Shows item level of each item, enchants, and gems on the character page.",
		},
	},

	-- Filger Local
	["Filger"] = {
		["Enable"] = {
			["Name"] = "Enable Filger",
			["Desc"] = PerformanceIncrease,
		},

		["TestMode"] = {
			["Name"] = "Test Mode",
		},

		["MaxTestIcon"] = {
			["Name"] = "Max Test Icon",
			["Desc"] = "The number of icons to the test",
		},

		["ShowTooltip"] = {
			["Name"] = "Show Tooltip",
		},

		["DisableCD"] = {
			["Name"] = "Disable Cooldowns",
		},

		["BuffSize"] = {
			["Name"] = "Buff Size",
		},

		["CooldownSize"] = {
			["Name"] = "Cooldown Size",
		},

		["PvPSize"] = {
			["Name"] = "PVP Size",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},
	},

	-- Filger Local
	["Firestorm"] = {
		["ChatFilter"] = {
			["Name"] = "Firestorm Chat Filter",
			["Desc"] = "This will filter all the 'AutoBroadcast' and more to make chat more retail like",
		},
	},

	-- Unitframe Local
	["Unitframe"] = {
		["ClassResource"] = {
			["Name"] = "Class Resource",
			["Desc"] = "Display class resources on the player frame (Combo, Runes...)",
		},

		["CastbarLatency"] = {
			["Name"] = "Castbar Latency",
		},

		["MouseoverHighlight"] = {
			["Name"] = "Mouseover Highlight",
			["Desc"] = "Highlight a units Health Bar when you are moused over them. (Only works for Target and Party right now!)",
		},

		["CastbarHeight"] = {
			["Name"] = "Castbar Height",
		},

		["DecimalLength"] = {
			["Name"] = "Decimal Length",
			["Desc"] = "Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames.",
		},

		["CastbarIcon"] = {
			["Name"] = "Castbar Icon",
			["Desc"] = "Create an icon beside the cast bar",
		},

		["CombatFade"] = {
			["Name"] = "Combat Fade",
			["Desc"] = "Fade the unitframe when out of combat, not casting or no target exists. (This affects your Player and Pet frame)",
		},

		["OnlyShowPlayerDebuff"] = {
			["Name"] = "Only Show Player Debuffs",
			["Desc"] = "Only show your debuffs on frames (This affects your Target and Boss frames)",
		},

		["PlayerBuffs"] = {
			["Name"] = "Player Buffs",
			["Desc"] = "Display your buffs under the player frame",
		},

		["PortraitTimers"] = {
			["Name"] = "Portrait Timers",
			["Desc"] = "Displays important PvP buffs/debuffs with timers on your Portraits",
		},

		["Castbars"] = {
			["Name"] = "Enable Castbars",
			["Desc"] = "Enable cast bar for unit frames",
		},

		["CastbarTicks"] = {
			["Name"] = "Show Castbar Ticks",
			["Desc"] = "Display tick marks on the castbar for channelled spells. This will adjust automatically for spells like Drain Soul and add additional ticks based on haste.",
		},

		["CastbarWidth"] = {
			["Name"] = "Castbar Width",
		},

		["CastbarTicksWidth"] = {
			["Name"] = "Castbar Ticks Width",
		},

		["CastClassColor"] = {
			["Name"] = "Class Castbars",
			["Desc"] = "Color castbars by the class of player units.",
		},

		["CastReactionColor"] = {
			["Name"] = "Reaction Castbars",
			["Desc"] = "Color castbars by the reaction type of non-player units.",
		},

		["DebuffsOnTop"] = {
			["Name"] = "Debuffs On Top",
			["Desc"] = "Display debuffs ontop and buffs on the bottom (affects only Target Frame)",
		},

		["Enable"] = {
			["Name"] = "Enable Unitframes",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["GlobalCooldown"] = {
			["Name"] = "Global Cooldown",
			["Desc"] = "Display a global CD on the unit frames healthbar (only shows for player frame)",
		},

		["TargetHighlight"] = {
			["Name"] = "Target Highlight",
			["Desc"] = "Highlight your current selected party target",
		},

		["PowerPredictionBar"] = {
			["Name"] = "Power Prediction Bar",
			["Desc"] = "Display a bar at which determines how much a spell will cost of power?",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
			["Desc"] = "Bars will transition smoothly."..PerformanceIncrease,
		},

		["SmoothSpeed"] = {
			["Name"] = "Smooth Speed",
			["Desc"] = "How fast the bars will transition smoothly.",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["ThreatPercent"] = {
			["Name"] = "Threat Percent",
			["Desc"] = "Enable threat percent on the target/focus frames",
		},

		["PortraitStyle"] = {
			["Name"] = "Portrait Style",
			["Desc"] = "2D, Class Icons, Blizzlike and more |n|n3D Portraits could degrade performance",
		},

		["NumberPrefixStyle"] = {
			["Name"] = "Unit Prefix Style",
			["Desc"] = "The unit prefixes you want to use when values are shortened in KkthnxUI. This is mostly used on UnitFrames.",
		},
	},

	-- Arena Local
	["Arena"] = {
		["Castbars"] = {
			["Name"] = "Enable Castbars",
		},

		["CastbarIcon"] = {
			["Name"] = "Castbar Icon",
			["Desc"] = "Create an icon beside the cast bar",
		},

		["DecimalLength"] = {
			["Name"] = "Decimal Length",
			["Desc"] = "Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames.",
		},

		["Enable"] = {
			["Name"] = "Enable Arena Frames",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
			["Desc"] = "Bars will transition smoothly."..PerformanceIncrease,
		},

		["SmoothSpeed"] = {
			["Name"] = "Smooth Speed",
			["Desc"] = "How fast the bars will transition smoothly.",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["NumberPrefixStyle"] = {
			["Name"] = "Unit Prefix Style",
			["Desc"] = "The unit prefixes you want to use when values are shortened in KkthnxUI. This is mostly used on UnitFrames.",
		},
	},

	-- Arena Local
	["Boss"] = {
		["Castbars"] = {
			["Name"] = "Enable Castbars",
		},

		["CastbarIcon"] = {
			["Name"] = "Castbar Icon",
			["Desc"] = "Create an icon beside the cast bar",
		},

		["CastbarHeight"] = {
			["Name"] = "Castbar Height",
		},

		["CastbarWidth"] = {
			["Name"] = "Castbar Width",
		},

		["DecimalLength"] = {
			["Name"] = "Decimal Length",
			["Desc"] = "Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames.",
		},

		["Enable"] = {
			["Name"] = "Enable Boss Frames",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
			["Desc"] = "Bars will transition smoothly."..PerformanceIncrease,
		},

		["SmoothSpeed"] = {
			["Name"] = "Smooth Speed",
			["Desc"] = "How fast the bars will transition smoothly.",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["ThreatPercent"] = {
			["Name"] = "Threat Percent",
			["Desc"] = "Enable threat percent on the boss frame",
		},

		["NumberPrefixStyle"] = {
			["Name"] = "Unit Prefix Style",
			["Desc"] = "The unit prefixes you want to use when values are shortened in KkthnxUI. This is mostly used on UnitFrames.",
		},

		["PortraitStyle"] = {
			["Name"] = "Portrait Style",
			["Desc"] = "2D, Class Icons, Blizzlike and more |n|n3D Portraits could degrade performance",
		},
	},

	-- Party Local
	["Party"] = {
		["Castbars"] = {
			["Name"] = "Enable Castbars",
		},

		["CastbarIcon"] = {
			["Name"] = "Castbar Icon",
			["Desc"] = "Create an icon beside the cast bar",
		},

		["Enable"] = {
			["Name"] = "Enable Party Frames",
		},

		["MouseoverHighlight"] = {
			["Name"] = "Mouseover Highlight",
			["Desc"] = "Highlight a units Health Bar when you are moused over them. (Only works for Target and Party right now!)",
		},

		["DecimalLength"] = {
			["Name"] = "Decimal Length",
			["Desc"] = "Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames.",
		},

		["PartyAsRaid"] = {
			["Name"] = "Party as Raid Frames",
			["Desc"] = "Check this if you want to use the Raidframes instead of the Partyframes.",
		},

		["PortraitTimers"] = {
			["Name"] = "Portrait Timers",
			["Desc"] = "Displays important PvP buffs/debuffs with timers on your Portraits",
		},

		["ShowBuffs"] = {
			["Name"] = "Show Buffs",
			["Desc"] = "Toggle the display of buffs on the party frames.",
		},

		["ShowPlayer"] = {
			["Name"] = "Show Player In Party",
			["Desc"] = "Display your self in the party frames or not. Hell I don't care",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
			["Desc"] = "Bars will transition smoothly." .. PerformanceIncrease,
		},

		["SmoothSpeed"] = {
			["Name"] = "Smooth Speed",
			["Desc"] = "How fast the bars will transition smoothly.",
		},

		["TargetHighlight"] = {
			["Name"] = "Target Highlight",
			["Desc"] = "Highlight your current selected party target",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["PortraitStyle"] = {
			["Name"] = "Portrait Style",
			["Desc"] = "2D, Class Icons, Blizzlike and more |n|n3D Portraits could degrade performance",
		},

		["NumberPrefixStyle"] = {
			["Name"] = "Unit Prefix Style",
			["Desc"] = "The unit prefixes you want to use when values are shortened in KkthnxUI. This is mostly used on UnitFrames.",
		},
	},

	-- Raidframe Local
	["Raid"] = {
		["AuraWatch"] = {
			["Name"] = "Aura Watch Timers",
			["Desc"] = "Display a timer on debuff icons created by Debuff Watch",
		},

		["AuraWatchIconSize"] = {
			["Name"] = "Aura Watch Icon Size",
		},

		["AuraWatchTexture"] = {
			["Name"] = "Aura Watch Texture",
			["Desc"] = "Display a colored texture over your aura watch corner icons. Disable this if you want to see the spell icon instead",
		},

		["RaidTools"] = {
			["Name"] = "Raid Utility",
			["Desc"] = "Enables the 'Raid Control' utility panel",
		},

		["RaidLayout"] = {
			["Name"] = "Raid Layout",
			["Desc"] = "Choose between a Healer or Damage raidframe layout"
		},

		["TargetHighlight"] = {
			["Name"] = "Target Highlight",
			["Desc"] = "Highlight your current selected raid target"
		},

		["AuraDebuffIconSize"] = {
			["Name"] = "Aura Debuff Icon Size",
		},

		["DeficitThreshold"] = {
			["Name"] = "Deficit Threshold",
			["Desc"] = "Show health deficit when it's more than displayed value",
		},

		["ColorHealthByValue"] = {
			["Name"] = "Health By Value",
			["Desc"] = "Color health by amount remaining.",
		},

		["Enable"] = {
			["Name"] = "Enable Raid Frames",
		},

		["Height"] = {
			["Name"] = "Raid Height",
		},

		["RaidGroups"] = {
			["Name"] = "Raid Groups",
			["Desc"] = "Number of groups in the raid",
		},

		["Width"] = {
			["Name"] = "Raid Width",
		},

		["MainTankFrames"] = {
			["Name"] = "Main Tank Frames",
			["Desc"] = "You know the people who take all the damage?",
		},

		["ManabarShow"] = {
			["Name"] = "Manabar Display",
			["Desc"] = "Off or on. Its a 50% chance here",
		},

		["MaxUnitPerColumn"] = {
			["Name"] = "Max Unit Per Column",
			["Desc"] = "How many frame will display per row/column",
		},

		["RaidUtility"] = {
			["Name"] = RAID_CONTROL,
			["Desc"] = "Enables the custom Raid Control panel.",
		},

		["ShowMouseoverHighlight"] = {
			["Name"] = "Show Mouseover Highlight",
			["Desc"] = "We can see better!",
		},

		["ShowNotHereTimer"] = {
			["Name"] = "Not Here Timer (AFK)",
			["Desc"] = "Display when someone is AFK in your raid",
		},

		["ShowRolePrefix"] = {
			["Name"] = "Show Role Prefix",
			["Desc"] = "Display an H for the healer or T for the tank",
		},

		["Smooth"] = {
			["Name"] = "Smooth",
			["Desc"] = "Bars will transition smoothly."..PerformanceIncrease,
		},

		["SmoothSpeed"] = {
			["Name"] = "Smooth Speed",
			["Desc"] = "How fast the bars will transition smoothly.",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},

		["Font"] = {
			["Name"] = "Font",
		},

		["GroupBy"] = {
			["Name"] = "Group By",
			["Desc"] = "Set the order that the group will sort.",
		},
	},

	-- Worldmap Local
	["WorldMap"] = {
		["AlphaWhenMoving"] = {
			["Name"] = "Alpha When Moving",
			["Desc"] = "Alpha value at which the map will fade",
		},

		["Coordinates"] = {
			["Name"] = "Coordinates",
			["Desc"] = "Puts coordinates on the world map.",
		},

		["FadeWhenMoving"] = {
			["Name"] = "Fade When Moving",
			["Desc"] = "Map Opacity When Moving",
		},

		["SmallWorldMap"] = {
			["Name"] = "Small WorldMap",
			["Desc"] = "Make the world map smaller.",
		},

		["WorldMapPlus"] = {
			["Name"] = "WorldMap Plus",
			["Desc"] = "If checked, a checkbox/quest URLs will be shown at the top of the map which will allow you to toggle unexplored areas and obtain quest/arena link info directly.",
		},
	},

	-- Tooltip Local
	["Tooltip"] = {
		["PlayerRoles"] = {
			["Name"] = ROLE,
			["Desc"] = "Display the unit role in the tooltip.",
		},

		["CursorAnchor"] = {
			["Name"] = "Cursor Anchor",
			["Desc"] = "Anchor the tooltip to the mouse cursor.",
		},

		["Enable"] = {
			["Name"] = "Enable Tooltip",
		},

		["ShowMount"] = {
			["Name"] = "Current Mount",
			["Desc"] = "Display info about the current mount the unit is riding.",
		},

		["FontOutline"] = {
			["Name"] = "Font Outline",
		},

		["FontSize"] = {
			["Name"] = "Font Size",
		},

		["CursorAnchorX"] = {
			["Name"] = "Cursor Anchor Offset X",
		},

		["CursorAnchorY"] = {
			["Name"] = "Cursor Anchor Offset Y",
		},

		["GuildRanks"] = {
			["Name"] = "Guild Ranks",
			["Desc"] = "Display players guild ranks",
		},

		["HealthbarHeight"] = {
			["Name"] = "Healthbar Height",
		},

		["HealthBarText"] = {
			["Name"] = "Healthbar Text",
			["Desc"] = "Show health bar text",
		},

		["TargetInfo"] = {
			["Name"] = "Target Info",
			["Desc"] = "When in a raid group display if anyone in your raid is targeting the current tooltip unit.",
		},

		["Icons"] = {
			["Name"] = "Icons",
			["Desc"] = "Display tooltip icons",
		},

		["InspectInfo"] = {
			["Name"] = "Inspect Info",
			["Desc"] = "Display a players item level and spec (you need to be holding the shift key down too)",
		},

		["NpcID"] = {
			["Name"] = "NPC IDs",
			["Desc"] = "Display the npc ID when mousing over a npc tooltip.",
		},

		["ItemQualityBorder"] = {
			["Name"] = "ItemQuality Border",
			["Desc"] = "Display item quality colors on the border",
		},

		["PlayerTitles"] = {
			["Name"] = "Player Titles",
			["Desc"] = "Display players titles",
		},

		["SpellID"] = {
			["Name"] = "Spell/Item IDs",
			["Desc"] = "Display the spell or item ID when mousing over a spell or item tooltip.",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
		},
	},
}