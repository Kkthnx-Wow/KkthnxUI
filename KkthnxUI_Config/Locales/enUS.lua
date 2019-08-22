-- local MissingDesc = "The description for this module/setting is missing. Someone should really remind Kkthnx to do his job!"
local ModuleNewFeature = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]] -- Used for newly implemented features.
-- local PerformanceIncrease = "|n|nDisabling this may slightly increase performance|r" -- For semi-high CPU options
-- local RestoreDefault = "|n|nRight-click to restore to default" -- For color pickers

local _G = _G

local REVERSE_NEW_LOOT_TEXT = _G.REVERSE_NEW_LOOT_TEXT

_G.KkthnxUIConfig["enUS"] = {
	-- Menu Groups Display Names
	["GroupNames"] = {
		-- Let's Keep This In Alphabetical Order, Shall We?
		["ActionBar"] = "Action Bar",
		["Announcements"] = "Announcements",
		["Arena"] = "Arena",
		["Auras"] = "Auras",
		["Automation"] = "Automation",
		["Boss"] = "Boss",
		["Chat"] = "Chat",
		["DataBars"] = "Data Bars",
		["DataText"] = "Data Text",
		["Filger"] = "Filger",
		["General"] = "General",
		["Inventory"] = "Inventory",
		["Loot"] = "Loot",
		["Minimap"] = "Minimap",
		["Misc"] = "Miscellaneous",
		["Nameplates"] = "Nameplates",
		["Party"] = "Party",
		["QuestNotifier"] = "Quest Notifier",
		["Raid"] = "Raid",
		["Skins"] = "Skins",
		["Tooltip"] = "Tooltip",
		["UIFonts"] = ModuleNewFeature.."Fonts",
		["UITextures"] = ModuleNewFeature.."Textures",
		["Unitframe"] = "Unit Frames",
		["WorldMap"] = "World Map",
	},

	-- Actionbar Local
	["ActionBar"] = {
		["Cooldowns"] = {
			["Name"] = "Show Cooldowns",
		},

		["Count"] = {
			["Name"] = "Show Item Counts",
		},

		["DecimalCD"] = {
			["Name"] = "Decimal for Cooldown in 3s",
		},

		["DefaultButtonSize"] = {
			["Name"] = "Main ActionBar Button Size",
		},

		["DisableStancePages"] = {
			["Name"] = "Disable Stance Pages (Druid & Rogues)",
		},

		["Enable"] = {
			["Name"] = "Enable ActionBars",
		},

		["EquipBorder"] = {
			["Name"] = "Equiped Border Indicator",
		},

		["FadeRightBar"] = {
			["Name"] = "Fade RightBar 1",
		},

		["FadeRightBar2"] = {
			["Name"] = "Fade RightBar 2",
		},

		["HideHighlight"] = {
			["Name"] = "Hide Proc Highlight",
		},

		["Hotkey"] = {
			["Name"] = "Show Hotkey",
		},

		["Macro"] = {
			["Name"] = "Show Macro",
		},

		["MicroBar"] = {
			["Name"] = "Show MicroBar",
		},

		["MicroBarMouseover"] = {
			["Name"] = "Fade MicroBar",
		},

		["OverrideWA"] = {
			["Name"] = "Hide Cooldowns on WeakAuras",
		},

		["RightButtonSize"] = {
			["Name"] = "RightBars Button Size",
		},

		["StancePetSize"] = {
			["Name"] = "Stance & Pet Button Size",
		}
	},

	-- Announcements Local
	["Announcements"] = {
		["PullCountdown"] = {
			["Name"] = "Announce Pull Countdown (/pc #)",
		},

		["SaySapped"] = {
			["Name"] = "Announce When Sapped",
		},

		["Interrupt"] = {
			["Name"] = "Announce Interrupts",
		}
	},

	-- Automation Local
	["Automation"] = {
		["AutoBubbles"] = {
			["Name"] = "Auto Toggle Chat Bubbles",
			["Desc"] = "Toggle chat bubbles depending on your InstanceType. If you are in a Dungeon/Raid, It will be toggled off."
		},

		["AutoCollapse"] = {
			["Name"] = "Auto Collapse Objective Tracker",
		},

		["AutoInvite"] = {
			["Name"] = "Accept Invites From Friends & Guild Members",
		},

		["AutoQuest"] = {
			["Name"] = "Auto Accept & Turnin Quests",
		},

		["AutoRelease"] = {
			["Name"] = "Auto Release in Battlegrounds & Arenas",
		},

		["AutoResurrect"] = {
			["Name"] = "Auto Accept Resurrect Requests",
		},

		["AutoResurrectThank"] = {
			["Name"] = "Say 'Thank You' When Resurrected",
		},

		["AutoReward"] = {
			["Name"] = "Auto Select Quest Rewards",
		},

		["AutoTabBinder"] = {
			["Name"] = "Only Tab Target Enemy Players",
		},

		["BlockMovies"] = {
			["Name"] = "Block Movies You Already Seen",
		},

		["DeclinePetDuel"] = {
			["Name"] = "Decline BattlePet Duels",
		},

		["DeclinePvPDuel"] = {
			["Name"] = "Decline PvP Duels",
		},

		["ScreenShot"] = {
			["Name"] = "Auto Achievement Screenshots",
		},

		["WhisperInvite"] = {
			["Name"] = "Auto Invites Keyword",
		},
	},

	-- Bags Local
	["Inventory"] = {
		["AutoSell"] = {
			["Name"] = "Auto Vendor Grays",
			["Desc"] = "Automatically vendor gray items when visiting a vendor.",
		},

		["BagBar"] = {
			["Name"] = "Show Bagbar",
		},

		["BagBarMouseover"] = {
			["Name"] = "Fade Bagbar",
		},

		["BagColumns"] = {
			["Name"] = "Number of Columns In Bags",
		},

		["BankColumns"] = {
			["Name"] = "Number of Columns In Bank",
		},

		["ButtonSize"] = {
			["Name"] = "Bag Button Size",
		},

		["ButtonSpace"] = {
			["Name"] = "Bag Button Spacing",
		},

		["DetailedReport"] = {
			["Name"] = "Vendor Gray Detailed Report",
			["Desc"] = "Displays a detailed report of every item sold when enabled.",
		},

		["Enable"] = {
			["Name"] = "Enable",
			["Desc"] = "Enable/Disable the Inventory Module.",
		},

		["ItemLevel"] = {
			["Name"] = "Display Item Level",
			["Desc"] = "Displays item level on equippable items.",
		},

		["JunkIcon"] = {
			["Name"] = "Show Junk Icon",
			["Desc"] = "Display the junk icon on all grey items that can be vendored.",
		},

		["PulseNewItem"] = {
			["Name"] = "Show New Item Glow",
		},

		["ReverseLoot"] = {
			["Name"] = REVERSE_NEW_LOOT_TEXT,
		},

		["SortInverted"] = {
			["Name"] = "Use Inverted Sorting",
		},

		["AutoRepair"] = {
			["Name"] = "Auto Repair Gear",
		},
	},

	-- Auras Local
	["Auras"] = {
		["BuffSize"] = {
			["Name"] = "Buff Icon Size",
		},

		["BuffsPerRow"] = {
			["Name"] = "Buffs per Row",
		},

		["DebuffSize"] = {
			["Name"] = "DeBuff Icon Size",
		},

		["DebuffsPerRow"] = {
			["Name"] = "DeBuffs per Row",
		},

		["Enable"] = {
			["Name"] = "Enable",
		},

		["Reminder"] = {
			["Name"] = "Auras Reminder (Shout/Intellect/Poison)",
		},

		["ReverseBuffs"] = {
			["Name"] = "Buffs Grow Right",
		},

		["ReverseDebuffs"] = {
			["Name"] = "DeBuffs Grow Right",
		},
	},

	-- Chat Local
	["Chat"] = {
		["Background"] = {
			["Name"] = "Show Chat Background",
		},

		["BackgroundAlpha"] = {
			["Name"] = "Chat Background Alpha",
		},

		["BlockAddonAlert"] = {
			["Name"] = "Block Addon Alerts",
		},

		["ChatItemLevel"] = {
			["Name"] = "Show iLvl on ChatFrames",
		},

		["Enable"] = {
			["Name"] = "Enable Chat",
		},

		["EnableFilter"] = {
			["Name"] = "Enable Chat Filter",
		},

		["Fading"] = {
			["Name"] = "Fade Chat",
		},

		["FadingTimeFading"] = {
			["Name"] = "Fade Chat Time",
		},

		["FadingTimeVisible"] = {
			["Name"] = "Fading Chat Visible TIme",
		},

		["Height"] = {
			["Name"] = "Chat Height",
		},

		["QuickJoin"] = {
			["Name"] = "Quick Join Messages",
			["Desc"] = "Show clickable Quick Join messages inside of the chat."
		},

		["ScrollByX"] = {
			["Name"] = "Scroll by '#' Lines",
		},

		["ShortenChannelNames"] = {
			["Name"] = "Shorten Channel Names",
		},

		["TabsMouseover"] = {
			["Name"] = "Fade Chat Tabs",
		},

		["WhisperSound"] = {
			["Name"] = "Whisper Sound",
		},

		["Width"] = {
			["Name"] = "Chat Width",
		},

	},

	-- Databars Local
	["DataBars"] = {
		["AzeriteColor"] = {
			["Name"] = "Azerite Bar Color",
		},

		["Enable"] = {
			["Name"] = "Enable DataBars",
		},

		["ExperienceColor"] = {
			["Name"] = "Experience Bar Color",
		},

		["Height"] = {
			["Name"] = "DataBars Height",
		},

		["HonorColor"] = {
			["Name"] = "Honor Bar Color",
		},

		["MouseOver"] = {
			["Name"] = "Fade DataBars",
		},

		["RestedColor"] = {
			["Name"] = "Rested Bar Color",
		},

		["Text"] = {
			["Name"] = "Show Text",
		},

		["TrackHonor"] = {
			["Name"] = "Track Honor",
		},

		["Width"] = {
			["Name"] = "DataBars Width",
		},

	},

	-- DataText Local
	["DataText"] = {
		["Battleground"] = {
			["Name"] = "Battleground Info",
		},

		["LocalTime"] = {
			["Name"] = "12 Hour Time",
		},

		["System"] = {
			["Name"] = "Show FPS/MS on Minimap",
		},

		["Time"] = {
			["Name"] = "Show Time on Minimap",
		},

		["Time24Hr"] = {
			["Name"] = "24 Hour Time",
		},
	},

	-- Filger Local
	["Filger"] = {
		["BuffSize"] = {
			["Name"] = "Buff Size",
		},

		["CooldownSize"] = {
			["Name"] = "Cooldown Size",
		},

		["DisableCD"] = {
			["Name"] = "Disable Cooldown Tracking",
		},

		["DisablePvP"] = {
			["Name"] = "Disable PvP Tracking",
		},

		["Expiration"] = {
			["Name"] = "Sort by Expiration",
		},

		["Enable"] = {
			["Name"] = "Enable Filger",
		},

		["MaxTestIcon"] = {
			["Name"] = "Max Test Icons",
		},

		["PvPSize"] = {
			["Name"] = "PvP Icon Size",
		},

		["ShowTooltip"] = {
			["Name"] = "Show Tooltip On Hover",
		},

		["TestMode"] = {
			["Name"] = "Test Mode",
		},
	},

	-- General Local
	["General"] = {
		["ColorTextures"] = {
			["Name"] = "Color 'Most' KkthnxUI Borders",
		},

		["DisableTutorialButtons"] = {
			["Name"] = "Disable Tutorial Buttons",
		},

		["ShowTooltip"] = {
			["Name"] = "Fix Garbage Collection",
		},

		["FontSize"] = {
			["Name"] = "General Font Size",
		},

		["HideErrors"] = {
			["Name"] = "Hide 'Some' UI Errors",
		},

		["LagTolerance"] = {
			["Name"] = "Auto Lag Tolerance",
		},

		["MoveBlizzardFrames"] = {
			["Name"] = "Move Blizzard Frames",
		},

		["ReplaceBlizzardFonts"] = {
			["Name"] = "Replace 'Some' Blizzard Fonts",
		},

		["TexturesColor"] = {
			["Name"] = "Textures Color",
		},

		["Welcome"] = {
			["Name"] = "Show Welcome Message",
		},

		["NumberPrefixStyle"] = {
			["Name"] = "Unitframe Number Prefix Style",
		},

		["PortraitStyle"] = {
			["Name"] = "Unitframe Portrait Style",
		},
	},

	-- Loot Local
	["Loot"] = {
		["AutoDisenchant"] = {
			["Name"] = "Auto Disenchant With 'CTRL'",
		},

		["AutoGreed"] = {
			["Name"] = "Auto Greed/Disenchant Green Items",
		},

		["Enable"] = {
			["Name"] = "Enable Loot",
		},

		["FastLoot"] = {
			["Name"] = "Faster Auto-Looting",
		},

		["GroupLoot"] = {
			["Name"] = "Enable Group Loot",
		},
	},

	-- Minimap Local
	["Minimap"] = {
		["Calendar"] = {
			["Name"] = "Show Calendar",
		},

		["Enable"] = {
			["Name"] = "Enable Minimap",
		},

		["GarrisonLandingPage"] = {
			["Name"] = "Show Garrison icon",
		},

		["ResetZoom"] = {
			["Name"] = "Reset Minimap Zoom",
		},

		["ResetZoomTime"] = {
			["Name"] = "Reset Zoom Time",
		},

		["ShowRecycleBin"] = {
			["Name"] = "Show Recycle Bin",
		},

		["Size"] = {
			["Name"] = "Minimap Size",
		},
	},

	-- Miscellaneous Local
	["Misc"] = {
		["AFKCamera"] = {
			["Name"] = "AFK Camera",
		},

		["ColorPicker"] = {
			["Name"] = "Enhanced Color Picker",
		},

		["EnhancedFriends"] = {
			["Name"] = "Enhanced Friends List +",
	},

	["GemEnchantInfo"] = {
		["Name"] = "Character/Inspect Gem/Enchant Info",
	},

	["ImprovedStats"] = {
		["Name"] = "Improved Character Frame Stats",
	},

	["ItemLevel"] = {
		["Name"] = "Show Character/Inspect ItemLevel Info",
	},

	["KillingBlow"] = {
		["Name"] = "Show Your Killing Blow Info",
	},

	["NoTalkingHead"] = {
		["Name"] = "Hide Talking Head Frame",
	},

	["ProfessionTabs"] = {
		["Name"] = "Enhanced Profession Tabs",
	},

	["PvPEmote"] = {
		["Name"] = "Auto Emote On Your Killing Blow",
	},

	["SlotDurability"] = {
		["Name"] = "Show Slot Durability %",
	},
},

	-- Nameplates Local
	["Nameplates"] = {
		["GoodColor"] = {
			["Name"] = "Good Threat Color",
		},

		["NearColor"] = {
			["Name"] = "Near Threat Color",
		},

		["BadColor"] = {
			["Name"] = "Bad Threat Color",
		},

		["SlotDurability"] = {
			["Name"] = "Off Tank Threat Color",
		},

		["Clamp"] = {
			["Name"] = "Clamp Nameplates",
			["Desc"] = "Clamp nameplates to the top of the screen when outside of view."
		},

		["ClassResource"] = {
			["Name"] = "Show Class Resources",
		},

		["Combat"] = {
			["Name"] = "Show Nameplates In Combat",
		},

		["Distance"] = {
			["Name"] = "Nameplate Distance",
		},

		["Enable"] = {
			["Name"] = "Enable Nameplates",
		},

		["HealthValue"] = {
			["Name"] = "Show Health Value",
		},

		["Height"] = {
			["Name"] = "Nameplate Height",
		},

		["NonTargetAlpha"] = {
			["Name"] = "Non-Target Nameplate Alpha",
		},

		["OverlapH"] = {
			["Name"] = "Overlap Horizontal",
		},

		["OverlapV"] = {
			["Name"] = "Overlap Vertical",
		},

		["QuestInfo"] = {
			["Name"] = "Show Quest Info Icon",
		},

		["SelectedScale"] = {
			["Name"] = "Selected Nameplate Scale",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
		},

		["TankMode"] = {
			["Name"] = "Tank Mode",
		},

		["Threat"] = {
			["Name"] = "Nameplate Threat",
		},

		["TrackAuras"] = {
			["Name"] = "Track Buffs/DeBuffs",
		},

		["Width"] = {
			["Name"] = "Nameplate Width",
		},

		["TargetArrowMark"] = {
			["Name"] = "Show Target Arrows",
		},

		["HealthFormat"] = {
			["Name"] = "Health Format Display",
		},

		["ShowEnemyCombat"] = {
			["Name"] = "Show Enemy Combat",
		},

		["ShowFriendlyCombat"] = {
			["Name"] = "Show Friendly Combat",
		},
	},

	-- Skins Local
	["Skins"] = {
		["ChatBubbles"] = {
			["Name"] = "Skin Chat Bubbles",
		},

		["DBM"] = {
			["Name"] = "Skin DeadlyBossMods",
		},

		["Details"] = {
			["Name"] = "Skin Details",
		},

		["Hekili"] = {
			["Name"] = "Skin Hekili",
		},

		["Skada"] = {
			["Name"] = "Skin Skada",
		},

		["TalkingHeadBackdrop"] = {
			["Name"] = "Show TalkingHead Backdrop",
		},

		["WeakAuras"] = {
			["Name"] = "Skin WeakAuras",
		},
	},

	-- Unitframe Local
	["Unitframe"] = {
		["AdditionalPower"] = {
			["Name"] = "Show Additional Power",
		},

		["CastClassColor"] = {
			["Name"] = "Class Color Castbars",
		},

		["CastReactionColor"] = {
			["Name"] = "Reaction Color Castbars",
		},

		["CastbarLatency"] = {
			["Name"] = "Show Castbar Latency",
		},

		["Castbars"] = {
			["Name"] = "Enable Castbars",
		},

		["ClassResource"] = {
			["Name"] = "Show Class Resources",
		},

		["CombatFade"] = {
			["Name"] = "Fade Unitframes",
		},

		["CombatText"] = {
			["Name"] = "Show CombatText Feedback",
		},

		["DebuffHighlight"] = {
			["Name"] = "Show Health Debuff Highlight",
		},

		["DebuffsOnTop"] = {
			["Name"] = "Show Target Debuffs On-top",
		},

		["Enable"] = {
			["Name"] = "Enable Unitframes",
		},

		["GlobalCooldown"] = {
			["Name"] = "Show Global Cooldown",
		},

		["HideTargetofTarget"] = {
			["Name"] = "Hide TargetofTarget Frame",
		},

		["OnlyShowPlayerDebuff"] = {
			["Name"] = "Only Show Your Debuffs",
		},

		["PlayerBuffs"] = {
			["Name"] = "Show Player Frame Buffs",
		},

		["PlayerCastbarHeight"] = {
			["Name"] = "Player Castbar Height",
		},

		["PlayerCastbarWidth"] = {
			["Name"] = "Player Castbar Width",
		},

		["PortraitTimers"] = {
			["Name"] = "Portrait Spell Timers",
		},

		["ShowPlayerLevel"] = {
			["Name"] = "Show Player Frame Level",
		},

		["ShowPlayerName"] = {
			["Name"] = "Show Player Frame Name",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
		},

		["Swingbar"] = {
			["Name"] = "Unitframe Swingbar",
		},

		["SwingbarTimer"] = {
			["Name"] = "Unitframe Swingbar Timer",
		},

		["TargetCastbarHeight"] = {
			["Name"] = "Target Castbar Height",
		},

		["TargetCastbarWidth"] = {
			["Name"] = "Target Castbar Width",
		},

		["TotemBar"] = {
			["Name"] = "Show Totembar",
		},

		["PlayerHealthFormat"] = {
			["Name"] = "Player Health Format",
		},

		["TargetHealthFormat"] = {
			["Name"] = "Target Health Format",
		},
	},

	-- Arena Local
	["Arena"] = {
		["Castbars"] = {
			["Name"] = "Show Castbars",
		},

		["Enable"] = {
			["Name"] = "Enable Arena",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
		},
	},

	-- Boss Local
	["Boss"] = {
		["Castbars"] = {
			["Name"] = "Show Castbars",
		},

		["Enable"] = {
			["Name"] = "Enable Boss",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
		},
	},

	-- Party Local
	["Party"] = {
		["Castbars"] = {
			["Name"] = "Show Castbars",
		},

		["Enable"] = {
			["Name"] = "Enable Party",
		},

		["PortraitTimers"] = {
			["Name"] = "Portrait Spell Timers",
		},

		["ShowBuffs"] = {
			["Name"] = "Show Party Buffs",
		},

		["ShowPlayer"] = {
			["Name"] = "Show Player In Party",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
		},

		["TargetHighlight"] = {
			["Name"] = "Show Highlighted Target",
		},
	},

	-- QuestNotifier Local
	["QuestNotifier"] = {
		["Enable"] = {
			["Name"] = "Enable QuestNotifier",
		},

		["QuestProgress"] = {
			["Name"] = "Quest Progress",
			["Desc"] = "Alert on QuestProgress in chat. This can get spammy so do not piss off your groups!",
		},

		["OnlyCompleteRing"] = {
			["Name"] = "Only Complete Sound",
			["Desc"] = "Only play the complete sound at the end of completing the quest"
		},
	},

	-- Raidframe Local
	["Raid"] = {
		["AuraDebuffIconSize"] = {
			["Name"] = "Aura Debuff Icon Size",
		},

		["AuraWatch"] = {
			["Name"] = "Show AuraWatch Icons",
		},

		["AuraWatchIconSize"] = {
			["Name"] = "AuraWatch Icon Size",
		},

		["AuraWatchTexture"] = {
			["Name"] = "Show Color AuraWatch Texture",
		},

		["Enable"] = {
			["Name"] = "Enable Raidframes",
		},

		["Height"] = {
			["Name"] = "Raidframe Height",
		},

		["MainTankFrames"] = {
			["Name"] = "Show MainTank Frames",
		},

		["ManabarShow"] = {
			["Name"] = "Show Manabars",
		},

		["MaxUnitPerColumn"] = {
			["Name"] = "MaxUnit Per Column",
		},

		["RaidUtility"] = {
			["Name"] = "Show Raid Utility Frame",
		},

		["ShowGroupText"] = {
			["Name"] = "Show Player Group #",
		},

		["ShowNotHereTimer"] = {
			["Name"] = "Show Away/DND Status",
		},

		["ShowRolePrefix"] = {
			["Name"] = "Show Healer/Tank Roles",
		},

		["Smooth"] = {
			["Name"] = "Smooth Bars",
		},

		["TargetHighlight"] = {
			["Name"] = "Show Highlighted Target",
		},

		["Width"] = {
			["Name"] = "Raidframe Width",
		},

		["RaidLayout"] = {
			["Name"] = "Raid Layouts",
		},

		["GroupBy"] = {
			["Name"] = "Sort Raid Frames",
		},

		["HealthFormat"] = {
			["Name"] = "Health Format Display",
		},
	},

	-- Worldmap Local
	["WorldMap"] = {
		["AlphaWhenMoving"] = {
			["Name"] = "Alpha When Moving",
		},

		["Coordinates"] = {
			["Name"] = "Show Player/Mouse Coordinates",
		},

		["FadeWhenMoving"] = {
			["Name"] = "Fade Worldmap When Moving",
		},

		["SmallWorldMap"] = {
			["Name"] = "Show Smaller Worldmap",
		},

		["WorldMapPlus"] = {
			["Name"] = "Show Enhanced World Map Features",
		},
	},

	-- Tooltip Local
	["Tooltip"] = {
		["AzeriteArmor"] = {
			["Name"] = "Show AzeriteArmor Info",
		},

		["ClassColor"] = {
			["Name"] = "Quality Color Border",
		},

		["CombatHide"] = {
			["Name"] = "Hide Tooltip in Combat",
		},

		["Cursor"] = {
			["Name"] = "Follow Cursor",
		},

		["FactionIcon"] = {
			["Name"] = "Show Faction Icon",
		},

		["HideJunkGuild"] = {
			["Name"] = "Abbreviate Guild Names",
		},

		["HideRank"] = {
			["Name"] = "Hide Guild Rank",
		},

		["HideRealm"] = {
			["Name"] = "Show realm name by SHIFT",
		},

		["HideTitle"] = {
			["Name"] = "Hide Unit Title",
		},

		["Icons"] = {
			["Name"] = "Item Icons",
		},

		["LFDRole"] = {
			["Name"] = "Show Roles Assigned Icon",
		},

		["SpecLevelByShift"] = {
			["Name"] = "Show Spec/iLvl by SHIFT",
		},

		["TargetBy"] = {
			["Name"] = "Show Unit Targeted By",
		},
	},

	-- Fonts Local
	["UIFonts"] = {
		["ActionBarsFonts"] = {
			["Name"] = "ActionBar",
		},

		["AuraFonts"] = {
			["Name"] = "Auras",
		},

		["ChatFonts"] = {
			["Name"] = "Chat",
		},

		["DataBarsFonts"] = {
			["Name"] = "DataBars",
		},

		["DataTextFonts"] = {
			["Name"] = "DataTexts",
		},

		["GeneralFonts"] = {
			["Name"] = "General",
		},

		["InventoryFonts"] = {
			["Name"] = "Inventory",
		},

		["MinimapFonts"] = {
			["Name"] = "Minimap",
		},

		["NameplateFonts"] = {
			["Name"] = "Nameplate",
		},

		["QuestTrackerFonts"] = {
			["Name"] = "Quest Tracker",
		},

		["SkinFonts"] = {
			["Name"] = "Skins",
		},

		["TooltipFonts"] = {
			["Name"] = "Tooltip",
		},

		["UnitframeFonts"] = {
			["Name"] = "Unitframes",
		},
	},

	-- Textures Local
	["UITextures"] = {
		["DataBarsTexture"] = {
			["Name"] = "Data Bars",
		},

		["FilgerTextures"] = {
			["Name"] = "Filger",
		},

		["GeneralTextures"] = {
			["Name"] = "General",
		},

		["LootTextures"] = {
			["Name"] = "Loot",
		},

		["NameplateTextures"] = {
			["Name"] = "Nameplate",
		},

		["QuestTrackerTexture"] = {
			["Name"] = "Quest Tracker",
		},

		["SkinTextures"] = {
			["Name"] = "Skins",
		},

		["TooltipTextures"] = {
			["Name"] = "Tooltip",
		},

		["UnitframeTextures"] = {
			["Name"] = "Unitframes",
		},

		["HealPredictionTextures"] = {
			["Name"] = "Heal Prediction",
		},
	}
}