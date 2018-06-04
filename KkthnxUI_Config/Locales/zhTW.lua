local Locale = GetLocale()

-- Localization for zhTW clients
if (Locale ~= "zhTW") then
	return
end

local ModuleFont = "Pick a font from the provided fonts for this module."
local ModuleFontOutline = "Apply a font outline for this module"
local ModuleHeight = "Pick the perfect Height for this module"
local ModuleTexture = "Pick a texture from the provided textures for this module."
local ModuleToggle = "Enable or disable this module based on your preference."
local ModuleWidth = "Pick the perfect Width for this module"
local PerformanceIncrease = "|n|nDisabling this may slightly increase performance|r" -- For semi-high CPU options
local RestoreDefault = "|n|nRight-click to restore to default" -- For color pickers
local SupportedFrames = "|n|nSuported frames for quest/arena URLs are|cff02FF02|n|nAchievements|nWorldMap|nEncounterJournal|r" -- For WorldMapPlus

KkthnxUIConfig["zhTW"] = {
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

		["ColorTextures"] = {
			["Name"] = "Toggle Border Color",
			["Desc"] = "Change the color of the main border of the UI",
		},

		["TexturesColor"] = {
			["Name"] = "Border Color",
			["Desc"] = "Main border color of the UI. |n|n|cffFF0000'Toggle Border Color' has to be enabled for this to work|r"..RestoreDefault,
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
			["Desc"] = ModuleTexture,
		},

		["Font"] = {
			["Name"] = "Font",
			["Desc"] = ModuleFont
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Set the font size for most things in the UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, etc.)",
		},

		["MoveBlizzardFrames"] = {
			["Name"] = "Move Blizzard Frames",
			["Desc"] = "Allow Blizzard frames to be moved",
		},

		["SpellTolerance"] = {
			["Name"] = "Spell Tolerance",
			["Desc"] = "Periodically adjust the Spell Tolerance variable to match your world latency so that spell queueing always works optimally, regardless of your instance server's location.",
		},

		["TaintLog"] = {
			["Name"] = "Log Taints",
			["Desc"] = "Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also, a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay.",
		},

		["ReplaceBlizzardFonts"] = {
			["Name"] = "Replace Blizzard Fonts",
			["Desc"] = "Change some of the default Blizzard fonts to match the UI",
		},
	},

	-- Loot Local
	["Loot"] = {
		["Enable"] = {
			["Name"] = "Enable Loot",
			["Desc"] = ModuleToggle,
		},

		["GroupLoot"] = {
			["Name"] = "GroupLoot",
			["Desc"] = "Toggle the loot roll frame.",
		},

		["AutoQuality"] = {
			["Name"] = "Loot Quality",
			["Desc"] = "Sets the auto greed/disenchant quality\n\nUncommon: Rolls on Uncommon only\nRare: Rolls on Rares & Uncommon",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
			["Desc"] = ModuleTexture,
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
			["Desc"] = "Buttons size",
		},

		["ButtonSpace"] = {
			["Name"] = "Button Space",
			["Desc"] = "Buttons space",
		},

		["DetailedReport"] = {
			["Name"] = "Detailed Report",
			["Desc"] = "Displays a detailed report of every item sold when enabled. Disabled to just show the profit or expenses as a total.",
		},

		["Enable"] = {
			["Name"] = "Enable Inventory",
			["Desc"] = ModuleToggle,
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

		["AutoRepair"] = {
			["Name"] = "Auto Repair",
			["Desc"] = "When visiting a repair merchant, automatically repair our gear",
		},

		["AutoSell"] = {
			["Name"] = "Auto Sell Grays",
			["Desc"] = "When visiting a vendor, automatically sell gray quality items",
		},

		["AutoSellMisc"] = {
			["Name"] = "Sell Misc Items",
			["Desc"] = "Automatically sells useless items that are not gray quality",
			["Default"] = "Automatically sells useless items that are not gray quality",
		},

		["SortInverted"] = {
			["Name"] = "Sort Inverted",
			["Desc"] = "Direction the bag sorting will use to allocate the items.",
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

		["Enable"] = {
			["Name"] = "Enable Actionbars",
			["Desc"] = ModuleToggle
		},

		["Grid"] = {
			["Name"] = "Toggle Actionbar Grid",
			["Desc"] = "Show empty action bar buttons",
		},

		["HideHighlight"] = {
			["Name"] = "Toggle Highlight",
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
			["Name"] = "Disable Stance Pages",
			["Desc"] = "Disables automatic page-switching depending on the players stance. |n|nOnly affects |cffFFF569Rogues|r and |cffFF7D0ADruids|r, has no effect on other classes",
		},

		["PetBarHide"] = {
			["Name"] = "Petbar toggle",
			["Desc"] = "Hide pet bar",
		},

		["PetBarHorizontal"] = {
			["Name"] = "Petbar Horizontal",
			["Desc"] = "Enable horizontal pet bar",
		},

		["RightBars"] = {
			["Name"] = "Rightbars",
			["Desc"] = "Number of action bars on right (0, 1, 2 or 3)",
		},

		["SplitBars"] = {
			["Name"] = "Splitbars",
			["Desc"] = "Split the fifth bar on two bars on 6 buttons",
		},

		["StanceBarHide"] = {
			["Name"] = "Stancebar Hide",
			["Desc"] = "Hide stance bar",
		},

		["StanceBarHorizontal"] = {
			["Name"] = "Stancebar Horizontal",
			["Desc"] = "Enable horizontal stance bar",
		},

		["ToggleMode"] = {
			["Name"] = "Actionbar ToggleMode",
			["Desc"] = "Lock / Unlock the toggle mode on our Actionbars (This will always be above the top bar!)",
		},

		["AddNewSpells"] = {
			["Name"] = "Auto Add New Spells",
			["Desc"] = "Auto add new learned spells to the actionbar. (This is needed for some quests)",
		},
	},

	-- Nameplates Local
	["Nameplates"] = {
		["AurasSize"] = {
			["Name"] = "Auras Size",
			["Desc"] = "Size of the auras",
		},

		["BadColor"] = {
			["Name"] = "Bad Color",
			["Desc"] = "Bad threat color, varies depending if your a tank or dps/heal"..RestoreDefault,
		},

		["CastbarName"] = {
			["Name"] = "Castbar Name",
			["Desc"] = "Show castbar name",
		},

		["CastUnitReaction"] = {
			["Name"] = "Cast Unit Reaction",
			["Desc"] = "Reaction castbar colors"..RestoreDefault,
		},

		["Clamp"] = {
			["Name"] = "Clamp",
			["Desc"] = "Clamp nameplates to the top of the screen when outside of view",
		},

		["Cutaway"] = {
			["Name"] = "Cutaway Bars",
			["Desc"] = "Bars will transition in a cutaway style when health is lost."..PerformanceIncrease,
		},

		["Distance"] = {
			["Name"] = "Distance",
			["Desc"] = "Show nameplates for units within this range",
		},

		["Enable"] = {
			["Name"] = "Enable Nameplates",
			["Desc"] = ModuleToggle..PerformanceIncrease,
		},

		["EnhancedThreat"] = {
			["Name"] = "Enhanced Threat",
			["Desc"] = "Enable threat feature, automatically changes by your role",
		},

		["ThreatPercent"] = {
			["Name"] = "Threat Percent",
			["Desc"] = "Enable threat percent on the nameplates",
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Font size on the nameplates",
		},

		["GoodColor"] = {
			["Name"] = "Good Color",
			["Desc"] = "Good threat color, varies depending if your a tank or dps/heal"..RestoreDefault,
		},

		["HealerIcon"] = {
			["Name"] = "Healer Icon",
			["Desc"] = "Show healer icon beside enemy healers nameplate in battlegrounds",
		},

		["HealthValue"] = {
			["Name"] = "Health Value",
			["Desc"] = "Numeral health value",
		},

		["Height"] = {
			["Name"] = "Height",
			["Desc"] = ModuleHeight,
		},

		["NameAbbreviate"] = {
			["Name"] = "Name Abbreviate",
			["Desc"] = "Display abbreviated names that are over 20 characters long",
		},

		["NearColor"] = {
			["Name"] = "Near Color",
			["Desc"] = "Losing/Gaining threat color"..RestoreDefault,
		},

		["OffTankColor"] = {
			["Name"] = "Off Tank Color",
			["Desc"] = "Offtank threat color"..RestoreDefault,
		},

		["OORAlpha"] = {
			["Name"] = "OOR Alpha",
			["Desc"] = "The alpha to set units that are out of range to.",
		},

		["Outline"] = {
			["Name"] = "Outline",
			["Desc"] = ModuleFontOutline,
		},

		["Smooth"] = {
			["Name"] = "Smooth",
			["Desc"] = "Bars will transition smoothly."..PerformanceIncrease,
		},

		["SmoothSpeed"] = {
			["Name"] = "Smooth Speed",
			["Desc"] = "How fast the bars will transition smoothly.",
		},

		["TotemIcons"] = {
			["Name"] = "Totem Icons",
			["Desc"] = "Show icon above enemy totems nameplate",
		},

		["TrackAuras"] = {
			["Name"] = "Track Auras",
			["Desc"] = "Show auras (from the whitelist)",
		},

		["Width"] = {
			["Name"] = "Width",
			["Desc"] = ModuleWidth,
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

		["AutoInvite"] = {
			["Name"] = "Auto Invite",
			["Desc"] = "Automatically accept invites from guild/friends.",
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
	},

	-- Auras Local
	["Auras"] = {
		["Enable"] = {
			["Name"] = "Enable Auras",
			["Desc"] = ModuleToggle,
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
			["Desc"] = "Aura Size",
		},

		["VerticalSpacing"] = {
			["Name"] = "Vertical Spacing",
			["Desc"] = "Vertical spacing of auras",
		},

		["WrapAfter"] = {
			["Name"] = "Wrap After",
			["Desc"] = "Begin a new row or column after this many auras.",
		},

		["FadeThreshold"] = {
			["Name"] = "Fade Threshold",
			["Desc"] = "Fade Threshold",
		},

		["GrowthDirection"] = {
			["Name"] = "Growth Direction",
			["Desc"] = "Description Needed",
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
			["Desc"] = ModuleToggle,
		},

		["Fading"] = {
			["Name"] = "Fading",
			["Desc"] = "Fade Chat",
		},

		["WhisperSound"] = {
			["Name"] = "Whisper Sound",
			["Desc"] = "Play a whisper sound",
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
			["Desc"] = "Shorten Channel Names",
		},

		["RemoveRealmNames"] = {
			["Name"] = "Remove Realm Names",
			["Desc"] = "Remove Realm Names",
		},

		["Height"] = {
			["Name"] = "Height",
			["Desc"] = ModuleHeight,
		},

		["LinkBrackets"] = {
			["Name"] = "Link Brackets",
			["Desc"] = "Wrap links in brackets",
		},

		["LinkColor"] = {
			["Name"] = "Link Color",
			["Desc"] = "Color links in chat"..RestoreDefault,
		},

		["MessageFilter"] = {
			["Name"] = "Message Filter",
			["Desc"] = "Filter messages in chat.",
		},

		["QuickJoin"] = {
			["Name"] = "Quick Join",
			["Desc"] = "Toggle QuickJoin messages in chat.",
		},

		["Font"] = {
			["Name"] = "Font",
			["Desc"] = ModuleFont
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
			["Desc"] = ModuleWidth,
		},

		["BubbleBackdrop"] = {
			["Name"] = "Bubble Backdrop",
			["Desc"] = "If you choose to have a backdrop or not!",
		},
	},

	-- Cooldown Local
	["Cooldown"] = {
		["Days"] = {
			["Name"] = "Days",
			["Desc"] = "Description Needed"..RestoreDefault,
		},

		["Enable"] = {
			["Name"] = "Enable Cooldowns",
			["Desc"] = ModuleToggle,
		},

		["Expiring"] = {
			["Name"] = "Expiring",
			["Desc"] = "Description Needed"..RestoreDefault,
		},

		["ExpiringDuration"] = {
			["Name"] = "Expiring Duration",
			["Desc"] = "Description Needed",
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Description Needed",
		},

		["Hours"] = {
			["Name"] = "Hours",
			["Desc"] = "Description Needed"..RestoreDefault,
		},

		["Minutes"] = {
			["Name"] = "Minutes",
			["Desc"] = "Description Needed"..RestoreDefault,
		},

		["Seconds"] = {
			["Name"] = "Seconds",
			["Desc"] = "Description Needed"..RestoreDefault,
		},

		["Threshold"] = {
			["Name"] = "Threshold",
			["Desc"] = "Description Needed",
		},
	},

	-- Databars Local
	["DataBars"] = {
		["ArtifactColor"] = {
			["Name"] = "Artifact Color",
			["Desc"] = "Color of the Artifactbar"..RestoreDefault,
		},

		["MouseOver"] = {
			["Name"] = "Mouseover",
			["Desc"] = "The bars are not shown unless you mouse over the them."
		},

		["ArtifactEnable"] = {
			["Name"] = "Enable Artifact",
			["Desc"] = "Enable artifactbar",
		},

		["ArtifactHeight"] = {
			["Name"] = "Artifact Height",
			["Desc"] = ModuleHeight,
		},

		["ArtifactWidth"] = {
			["Name"] = "Artifact Width",
			["Desc"] = ModuleWidth,
		},

		["ExperienceColor"] = {
			["Name"] = "Experience Color",
			["Desc"] = "Color of the Experiencebar"..RestoreDefault,
		},

		["ExperienceEnable"] = {
			["Name"] = "Enable Experience",
			["Desc"] = "Enable experiencebar",
		},

		["ExperienceHeight"] = {
			["Name"] = "Experience Height",
			["Desc"] = ModuleHeight,
		},

		["ExperienceRestedColor"] = {
			["Name"] = "Experience Rested Color",
			["Desc"] = "Color of the rested experiencebar"..RestoreDefault,
		},

		["ExperienceWidth"] = {
			["Name"] = "Experience Width",
			["Desc"] = ModuleWidth,
		},

		["HonorColor"] = {
			["Name"] = "Honor Color",
			["Desc"] = "Color of the honorbar"..RestoreDefault,
		},

		["HonorEnable"] = {
			["Name"] = "Enable Honor",
			["Desc"] = "Enable honorbar",
		},

		["HonorHeight"] = {
			["Name"] = "Honor Height",
			["Desc"] = ModuleHeight,
		},

		["HonorWidth"] = {
			["Name"] = "Honor Width",
			["Desc"] = ModuleWidth,
		},

		["ReputationEnable"] = {
			["Name"] = "Enable Reputation",
			["Desc"] = "Enable reputationbar",
		},

		["ReputationHeight"] = {
			["Name"] = "Reputation Height",
			["Desc"] = ModuleHeight,
		},

		["ReputationWidth"] = {
			["Name"] = "Reputation Width",
			["Desc"] = ModuleWidth,
		},

		["Outline"] = {
			["Name"] = "Outline",
			["Desc"] = ModuleFontOutline,
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
			["Desc"] = ModuleTexture,
		},
	},

	-- Quests Local
	["Quests"] = {
		["AutoCollapse"] = {
			["Name"] = "Auto Collapse",
			["Desc"] = "Auto collapse the objective tracker based on the settings below.",
		},

		["AutoReward"] = {
			["Name"] = "Auto Reward",
			["Desc"] = "Automatically selects a reward with highest selling price when quest is completed. Does not really finish the quest.",
		},

		["Arena"] = {
			["Name"] = "Arena",
			["Desc"] = "Auto collapse tracker in arena",
		},

		["Raid"] = {
			["Name"] = "Raid",
			["Desc"] = "Auto collapse tracker in raid",
		},

		["Orderhall"] = {
			["Name"] = "Orderhall",
			["Desc"] = "Auto collapse tracker in orderhall",
		},

		["Garrison"] = {
			["Name"] = "Garrison",
			["Desc"] = "Auto collapse tracker in garrison",
		},

		["Dungeon"] = {
			["Name"] = "Dungeon",
			["Desc"] = "Auto collapse tracker in dungeon",
		},

		["Combat"] = {
			["Name"] = "Combat",
			["Desc"] = "Auto collapse tracker in combat",
		},

		["Battleground"] = {
			["Name"] = "Battleground",
			["Desc"] = "Auto collapse tracker in battleground",
		},

		["Scenario"] = {
			["Name"] = "Scenario",
			["Desc"] = "Auto collapse tracker in scenario",
		},

		["Rested"] = {
			["Name"] = "Rested",
			["Desc"] = "Auto collapse tracker in rested arenas",
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
			["Desc"] = ModuleFontOutline,
		},

		["System"] = {
			["Name"] = "System",
			["Desc"] = "Display FPS-MS at the bottom right corner of the screen",
		},

		["Time"] = {
			["Name"] = "Enable Time Datatext",
			["Desc"] = "Display a clock on the bottom of the minimap",
		},

		["Time24Hr"] = {
			["Name"] = "24 Hour Time",
			["Desc"] = "Display 24 time format",
		},
	},

	-- Skins Local
	["Skins"] = {
		["Bagnon"] = {
			["Name"] = "Bagnon",
			["Desc"] = "Bagnon skin",
		},

		["BigWigs"] = {
			["Name"] = "BigWigs",
			["Desc"] = "BigWigs skin",
		},

		["ChatBubbles"] = {
			["Name"] = "Chat Bubbles",
			["Desc"] = "ChatBubbles skin",
		},

		["DBM"] = {
			["Name"] = "Deadly Boss Mods (DBM)",
			["Desc"] = "Deadly Boss Mods (DBM) skin",
		},

		["Recount"] = {
			["Name"] = "Recount",
			["Desc"] = "Recount skin",
		},

		["Skada"] = {
			["Name"] = "Skada",
			["Desc"] = "Skada skin",
		},

		["Spy"] = {
			["Name"] = "Spy",
			["Desc"] = "Spy skin",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
			["Desc"] = ModuleTexture,
		},

		["WeakAuras"] = {
			["Name"] = "WeakAuras",
			["Desc"] = "WeakAuras skin",
		},
	},

	-- Minimap Local
	["Minimap"] = {
		["Calendar"] = {
			["Name"] = "Calendar",
			["Desc"] = "Display a small calendar",
		},

		["CollectButtons"] = {
			["Name"] = "Collect Buttons",
			["Desc"] = "Collect buttons in a row on the left side of the map",
		},

		["Enable"] = {
			["Name"] = "Enable Minimap",
			["Desc"] = ModuleToggle,
		},

		["ResetZoom"] = {
			["Name"] = "Reset Zoom",
			["Desc"] = "Reset Zoom",
		},

		["ResetZoomTime"] = {
			["Name"] = "Reset Zoom Time",
			["Desc"] = "Reset zoom at said amount of seconds",
		},

		["Size"] = {
			["Name"] = "Size",
			["Desc"] = "Size of minimap",
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

		["ColorPicker"] = {
			["Name"] = "Improved Color Picker",
			["Desc"] = "Improved ColorPicker",
		},

		["ItemLevel"] = {
			["Name"] = "Item Level",
			["Desc"] = "Item level on character slot buttons",
		},

		["KillingBlow"] = {
			["Name"] = "KillingBlow",
			["Desc"] = "Display a message about your killing blow",
		},

		["PvPEmote"] = {
			["Name"] = "PVP Emote",
			["Desc"] = "Make a silly emote at the player you just killed (Kkthnx spits on you!)",
		},

		["SlotDurability"] = {
			["Name"] = "Slot Durability",
			["Desc"] = "Durability percentage on character slot buttons",
		},
	},

	-- Filger Local
	["Filger"] = {
		["Bars"] = {
			["Name"] = "Enable HoTs/Dots bars",
			["Desc"] = ModuleToggle..PerformanceIncrease,
		},

		["Enable"] = {
			["Name"] = "Enable Filger",
			["Desc"] = ModuleToggle..PerformanceIncrease,
		},

		["TestMode"] = {
			["Name"] = "Test Mode",
			["Desc"] = "Test icon mode",
		},

		["MaxTestIcon"] = {
			["Name"] = "Max Test Icon",
			["Desc"] = "The number of icons to the test",
		},

		["ShowTooltip"] = {
			["Name"] = "Show Tooltip",
			["Desc"] = "Show tooltip",
		},

		["DisableCD"] = {
			["Name"] = "Disable CD",
			["Desc"] = "Disable cooldowns",
		},

		["BuffSize"] = {
			["Name"] = "Buff Size",
			["Desc"] = "Buffs size",
		},

		["CooldownSize"] = {
			["Name"] = "Cooldown Size",
			["Desc"] = "Cooldowns size",
		},

		["PvPSize"] = {
			["Name"] = "PVP Size",
			["Desc"] = "PVP debuffs size",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
			["Desc"] = ModuleTexture,
		},
	},

	-- Unitframe Local
	["Unitframe"] = {
		["CastbarHeight"] = {
			["Name"] = "Castbar Height",
			["Desc"] = ModuleHeight,
		},

		["CastbarIcon"] = {
			["Name"] = "Castbar Icon",
			["Desc"] = "Create an icon beside the cast bar",
		},

		["NameAbbreviate"] = {
			["Name"] = "Name Abbreviate",
			["Desc"] = "Display abbreviated names that are over 20 characters long",
		},

		["CastbarLatency"] = {
			["Name"] = "Castbar Latency",
			["Desc"] = "Display your latency on the cast bar",
		},

		["CombatFade"] = {
			["Name"] = "Combat Fade",
			["Desc"] = "Fade the unitframe when out of combat, not casting or no target exists. (This affects your Player and Pet frame)",
		},

		["OnlyShowPlayerDebuff"] = {
			["Name"] = "Only Show Player Debuffs",
			["Desc"] = "Only show your debuffs on frames (This affects your Target and Boss frames)",
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
			["Desc"] = ModuleWidth,
		},

		["CastClassColor"] = {
			["Name"] = "Castbar Classcolor",
			["Desc"] = "Color cast bars as class color",
		},

		["CastReactionColor"] = {
			["Name"] = "Castbar Reaction Color",
			["Desc"] = "Color cast bars as reaction to the target",
		},

		["ColorHealthByValue"] = {
			["Name"] = "Health By Value",
			["Desc"] = "Color health by amount remaining.",
		},

		["CombatText"] = {
			["Name"] = "Portrait Combat Text",
			["Desc"] = "Enable combat text on player and target frames",
		},

		["Cutaway"] = {
			["Name"] = "Cutaway Bars",
			["Desc"] = "Bars will transition in a cutaway style when health is lost."..PerformanceIncrease,
		},

		["DebuffsOnTop"] = {
			["Name"] = "Debuffs On Top",
			["Desc"] = "Display debuffs ontop and buffs on the bottom (affects only Target Frame)",
		},

		["Enable"] = {
			["Name"] = "Enable Unitframes",
			["Desc"] = ModuleToggle,
		},

		["Font"] = {
			["Name"] = "Font",
			["Desc"] = ModuleFont
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Unitframe font size",
		},

		["GlobalCooldown"] = {
			["Name"] = "Global Cooldown",
			["Desc"] = "Display a global CD on the unit frames healthbar (only shows for player frame)",
		},

		["OORAlpha"] = {
			["Name"] = "OOR Alpha",
			["Desc"] = "The alpha to set units that are out of range to.",
		},

		["Outline"] = {
			["Name"] = "Font Outline",
			["Desc"] = ModuleFontOutline,
		},

		["Party"] = {
			["Name"] = "Party Frames",
			["Desc"] = "Enable those sexy party frames <3",
		},

		["TargetHighlight"] = {
			["Name"] = "Target Highlight",
			["Desc"] = "Highlight your current selected party target",
		},

		["PartyAsRaid"] = {
			["Name"] = "Party as Raid Frames",
			["Desc"] = "Check this if you want to use the Raidframes instead of the Partyframes.",
		},

		["PowerPredictionBar"] = {
			["Name"] = "Power Prediction Bar",
			["Desc"] = "Display a bar at which determines how much a spell will cost of power?",
		},

		["PvPText"] = {
			["Name"] = "Set PVP Text",
			["Desc"] = "Toggle the PvP Text",
		},

		["ShowArena"] = {
			["Name"] = "Enable Arena",
			["Desc"] = "Enable arena frames",
		},

		["ShowBoss"] = {
			["Name"] = "Enable Boss",
			["Desc"] = "Enable boss frames",
		},

		["ShowPlayer"] = {
			["Name"] = "Show Player In Party",
			["Desc"] = "Display your self in the party frames or not. Hell I don't care",
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
			["Desc"] = ModuleTexture,
		},

		["ThreatPercent"] = {
			["Name"] = "Threat Percent",
			["Desc"] = "Enable threat percent on the nameplates",
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
	["Raidframe"] = {
		["AuraWatch"] = {
			["Name"] = "Aura Watch Timers",
			["Desc"] = "Display a timer on debuff icons created by Debuff Watch",
		},

		["AuraWatchIconSize"] = {
			["Name"] = "Aura Watch Icon Size",
			["Desc"] = "Pick your size",
		},

		["Cutaway"] = {
			["Name"] = "Cutaway Bars",
			["Desc"] = "Bars will transition in a cutaway style when health is lost."..PerformanceIncrease,
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
			["Desc"] = "Pick your poison",
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
			["Name"] = "Enable Raidframes",
			["Desc"] = ModuleToggle,
		},

		["Height"] = {
			["Name"] = "Raid Height",
			["Desc"] = ModuleHeight,
		},

		["RaidGroups"] = {
			["Name"] = "Raid Groups",
			["Desc"] = "Number of groups in the raid",
		},

		["Width"] = {
			["Name"] = "Raid Width",
			["Desc"] = ModuleWidth,
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

		["Outline"] = {
			["Name"] = "Outline",
			["Desc"] = ModuleFontOutline,
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
			["Desc"] = ModuleTexture,
		},

		["Font"] = {
			["Name"] = "Font",
			["Desc"] = ModuleFont
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
			["Desc"] = "If checked, a checkbox/quest URLs will be shown at the top of the map which will allow you to toggle unexplored areas and obtain quest/arena link info directly."..SupportedFrames,
		},
	},

	-- Tooltip Local
	["Tooltip"] = {
		["CursorAnchor"] = {
			["Name"] = "Cursor Anchor",
			["Desc"] = "Anchor the tooltip to the cursor.",
		},

		["Enable"] = {
			["Name"] = "Enable Tooltip",
			["Desc"] = ModuleToggle,
		},

		["FontOutline"] = {
			["Name"] = "Font Outline",
			["Desc"] = ModuleFontOutline,
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Determine your font size",
		},

		["GuildRanks"] = {
			["Name"] = "Guild Ranks",
			["Desc"] = "Display players guild ranks",
		},

		["HealthbarHeight"] = {
			["Name"] = "Healthbar Height",
			["Desc"] = ModuleHeight,
		},

		["HealthBarText"] = {
			["Name"] = "Healthbar Text",
			["Desc"] = "Show health bar text",
		},

		["Icons"] = {
			["Name"] = "Icons",
			["Desc"] = "Display tooltip icons",
		},

		["InspectInfo"] = {
			["Name"] = "Inspect Info",
			["Desc"] = "Display a players item level and spec (you need to be holding the shift key down too)",
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
			["Name"] = "SpellID",
			["Desc"] = "Display spell id",
		},

		["Texture"] = {
			["Name"] = "Statusbar Texture",
			["Desc"] = ModuleTexture,
		},
	},

	-- Errors Local
	["Error"] = {
		["Black"] = {
			["Name"] = "Black",
			["Desc"] = "Hide errors from black list",
		},

		["Combat"] = {
			["Name"] = "Combat",
			["Desc"] = "Hide all errors in combat",
		},

		["White"] = {
			["Name"] = "White",
			["Desc"] = "Show errors from white list",
		},
	},
}