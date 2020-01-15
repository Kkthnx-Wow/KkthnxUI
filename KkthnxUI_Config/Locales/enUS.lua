-- local MissingDesc = "The description for this module/setting is missing. Someone should really remind Kkthnx to do his job!"
local ModuleNewFeature = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]] -- Used for newly implemented features.
-- local PerformanceIncrease = "|n|nDisabling this may slightly increase performance|r" -- For semi-high CPU options
-- local RestoreDefault = "|n|nRight-click to restore to default" -- For color pickers

local _G = _G

_G.KkthnxUIConfig["enUS"] = {
	-- Menu Groups Display Names
	["GroupNames"] = {
		-- Let's Keep This In Alphabetical Order, Shall We?
		["ActionBar"] = "Action Bar",
		["Announcements"] = "Announcements",
		["Auras"] = "Auras",
		["Automation"] = "Automation",
		["Chat"] = "Chat",
		["DataBars"] = "Data Bars",
		["DataText"] = "Data Text",
		["Filger"] = "Filger",
		["General"] = "General",
		["Inventory"] = "Inventory",
		["Loot"] = "Loot",
		["Minimap"] = "Minimap",
		["Misc"] = "Miscellaneous",
		["Nameplate"] = "Nameplates",
		["Party"] = "Party",
		["PulseCooldown"] = "Pulse Cooldown",
		["QuestNotifier"] = "Quest Notifier",
		["Raid"] = "Raid",
		["Skins"] = "Skins",
		["Tooltip"] = "Tooltip",
		["UIFonts"] = "Fonts",
		["UITextures"] = "Textures",
		["Unitframe"] = "Unit Frames",
		["WorldMap"] = "World Map",
	},

	-- Actionbar Local
	["ActionBar"] = {
		["Cooldowns"] = {
			["Name"] = "Show Cooldowns",
			["Desc"] = "Display cooldowns on the actionbars and other elements.",
		},

		["Count"] = {
			["Name"] = "Show Item Counts",
			["Desc"] = "Show how many of the item you have in your bags on the actionbars.",
		},

		["DecimalCD"] = {
			["Name"] = "Decimal for Cooldown in 3s",
		},

		["DefaultButtonSize"] = {
			["Name"] = "Main ActionBar Button Size",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable ActionBars",
		},

		["EquipBorder"] = {
			["Name"] = "Equiped Border Indicator",
			["Desc"] = "Display a green border for items you have equipped and put onto your actionbar. |n|nFor example, on use trinkets you put onto your bars will show a green border.",
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
		},

		["RareAlert"] = {
			["Name"] = "Announce Rares, Chests & War Supplies",
		},

		["ItemAlert"] = {
			["Name"] = "Announce Items Being Placed",
		},

		["BrokenSpell"] = {
			["Name"] = "Announce When Someone Breaks A Crowd Control Spell",
		},

		["Interrupt"] = {
			["Name"] = "Announce Interrupt/Stolen/Dispell In Groups",
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

		["AutoDeclineDuels"] = {
			["Name"] = "Auto Decline Player Duels",
		},

		["AutoDeclinePetDuels"] = {
			["Name"] = "Auto Decline Pet Duels",
		},

		["AutoInvite"] = {
			["Name"] = "Accept Invites From Friends & Guild Members",
		},

		["AutoDisenchant"] = {
			["Name"] = "Auto Disenchant With 'ALT'",
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

		["AutoSetRole"] = {
			["Name"] = "Auto Set Your Role In Groups",
		},

		["AutoTabBinder"] = {
			["Name"] = "Only Tab Target Enemy Players",
		},

		["BuffThanks"] = {
			["Name"] = "Thank Players For Buffs (Open World Only)",
		},

		["BlockMovies"] = {
			["Name"] = "Block Movies You Already Seen",
		},

		["DeclinePvPDuel"] = {
			["Name"] = "Decline PvP Duels",
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

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable Inventory",
			["Desc"] = "Enable/Disable the Inventory Module.",
		},

		["ClassRelatedFilter"] = {
			["Name"] = "Filter Class Items",
		},

		["ScrapIcon"] = {
			["Name"] = "Show Scrap Icon",
		},

		["UpgradeIcon"] = {
			["Name"] = "Show Upgrade Icon",
		},

		["QuestItemFilter"] = {
			["Name"] = "Filter Quest Items",
		},

		["TradeGoodsFilter"] = {
			["Name"] = "Filter Trade/Goods Items",
		},

		["BagsWidth"] = {
			["Name"] = "Bags Width",
		},

		["BankWidth"] = {
			["Name"] = "Bank Width",
		},

		["DeleteButton"] = {
			["Name"] = "Bags Delete Button",
		},

		["GatherEmpty"] = {
			["Name"] = "Gather Empty Slots Into One Slot",
		},

		["IconSize"] = {
			["Name"] = "Slot Icon Size",
		},

		["ItemFilter"] = {
			["Name"] = "Item Filtering",
		},

		["ItemSetFilter"] = {
			["Name"] = "Use ItemSet Filter",
		},

		["ReverseSort"] = {
			["Name"] = "Bags Reverse Sorting",
		},

		["ShowNewItem"] = {
			["Name"] = "Show New Item Glow",
		},

		["SpecialBagsColor"] = {
			["Name"] = "Show Special Bags Color",
			["Desc"] = "Show color for special bags:|n|n- |CFFABD473Hunter|r quiver or ammo pouch|n- |CFF8787EDWarlock|r soul pouch|n- Enchanted mageweave pouch|n- Herb pouch"
		},

		["BagsiLvl"] = {
			["Name"] = "Display Item Level",
			["Desc"] = "Displays item level on equippable items.",
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
			["Name"] = "|cff00cc4c".."Enable Auras",
		},

		["Reminder"] = {
			["Name"] = "Auras Reminder (Shout/Intellect/Poison)",
		},

		["ReverseBuffs"] = {
			["Name"] = "Buffs Grow Right",
		},

		["ReverseDebuffs"] = {
			["Name"] = "Debuffs Grow Right",
		},

		["Statue"] = {
			["Name"] = "Show |CFF00FF96Monk|r Statue",
		},

		["Totems"] = {
			["Name"] = "Show Totems Bar",
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

		["ChatItemLevel"] = {
			["Name"] = "Show ItemLevel on ChatFrames",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable Chat",
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
		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable DataBars",
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
			["Name"] = "Show FPS and Latency",
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
			["Name"] = "|cff00cc4c".."Enable Filger",
			["Desc"] = "Filger is a very minimal buff/debuff tracking module that will allow you to track buffs/debuffs on yourself, target, etc, and also can be used to track cooldowns."
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
		["AutoScale"] = {
			["Name"] = "Auto Scale",
		},

		["ColorTextures"] = {
			["Name"] = "Color 'Most' KkthnxUI Borders",
		},

		["DisableTutorialButtons"] = {
			["Name"] = "Disable Tutorial Buttons",
		},

		["FixGarbageCollect"] = {
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

		["VersionCheck"] = {
			["Name"] = "|cff00cc4c".."Enable Version Checking",
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
		["AutoConfirm"] = {
			["Name"] = "Auto Confirm Loot Dialogs",
		},

		["AutoGreed"] = {
			["Name"] = "Auto Greed Green Items",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable Loot",
		},

		["FastLoot"] = {
			["Name"] = "Faster Auto-Looting",
		},

		["GroupLoot"] = {
			["Name"] = "|cff00cc4c".."Enable Group Loot",
		},
	},

	-- Minimap Local
	["Minimap"] = {
		["Calendar"] = {
			["Name"] = "Show Calendar",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable Minimap",
		},

		["ResetZoom"] = {
			["Name"] = "Reset Minimap Zoom",
		},

		["ResetZoomTime"] = {
			["Name"] = "Reset Zoom Time",
		},

		["ShowGarrison"] = {
			["Name"] = "Show Garrison Button",
		},

		["ShowRecycleBin"] = {
			["Name"] = "Show Recycle Bin",
		},

		["Size"] = {
			["Name"] = "Minimap Size",
		},

		["BlipTexture"] = {
			["Name"] = "Blip Icon Styles",
			["Desc"] = "Change the minimap blip icons for nodes, party and so on.",
		},

		["LocationText"] = {
			["Name"] = "Location Text Style",
			["Desc"] = "Change settings for the display of the location text that is on the minimap.",
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
			["Name"] = "Enhanced Colors (Friends/Guild +)",
		},

		["GemEnchantInfo"] = {
			["Name"] = "Character/Inspect Gem/Enchant Info",
		},

		["ItemLevel"] = {
			["Name"] = "Show Character/Inspect ItemLevel Info",
		},

		["KillingBlow"] = {
			["Name"] = "Show Your Killing Blow Info",
		},

		["PvPEmote"] = {
			["Name"] = "Auto Emote On Your Killing Blow",
		},

		["ShowWowHeadLinks"] = {
			["Name"] = "Show Wowhead Links Above Questlog Frame",
		},

		["SlotDurability"] = {
			["Name"] = "Show Slot Durability %",
		},

		["TradeTabs"] = {
			["Name"] = "Show TradeTabs",
			["Desc"] = "Add spellbook-like tabs to the TradeSkillFrame. It will add one for each of your professions and one for each of the profession 'suppliment' abilities (cooking, disenchant, etc)"
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
	["Nameplate"] = {
		["AKSProgress"] = {
			["Name"] = "Show AngryKeystones Progress",
		},

		["AuraSize"] = {
			["Name"] = "Auras Size",
		},

		["Distance"] = {
			["Name"] = "Nameplete MaxDistance",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable Nameplates",
		},

		["ExplosivesScale"] = {
			["Name"] = "Scale Nameplates for Explosives",
		},

		["ClassIcon"] = {
			["Name"] = "Show Hostile Player ClassIcons",
		},

		["HealerIcon"] = {
			["Name"] = "Show Healer Icons In Arena/Battlegrounds",
		},

		["FullHealth"] = {
			["Name"] = "Show Health Value",
		},

		["HealthTextSize"] = {
			["Name"] = "HealthText FontSize",
		},

		["InsideView"] = {
			["Name"] = "Interacted Nameplate Stay Inside",
		},

		["MaxPowerGlow"] = {
			["Name"] = "Fully Charged Glow",
		},

		["MinAlpha"] = {
			["Name"] = "Non-Target Nameplate Alpha",
		},

		["HostileCC"] = {
			["Name"] = "Show Hostile ClassColor",
		},

		["FriendlyCC"] = {
			["Name"] = "Show Friendly ClassColor",
		},

		["DPSRevertThreat"] = {
			["Name"] = "Revert Threat Color If Not Tank",
		},

		["TankMode"] = {
			["Name"] = "Force TankMode Colored",
		},

		["CustomUnitColor"] = {
			["Name"] = "Colored Custom Units",
		},

		["MinScale"] = {
			["Name"] = "Non-Target Nameplate Scale",
		},

		["NameTextSize"] = {
			["Name"] = "NameText FontSize",
		},

		["NameplateClassPower"] = {
			["Name"] = "Target Nameplate ClassPower",
		},

		["PPHeight"] = {
			["Name"] = "Classpower/Healthbar Height",
		},

		["PPHideOOC"] = {
			["Name"] = "Only Visible in Combat",
		},

		["PPIconSize"] = {
			["Name"] = "PlayerPlate IconSize",
		},

		["PPPHeight"] = {
			["Name"] = "PlayerPlate Powerbar Height",
		},

		["PPPowerText"] = {
			["Name"] = "Show PlayerPlate Power Value",
		},

		["PlateHeight"] = {
			["Name"] = "Nameplate Height",
		},

		["PlateWidth"] = {
			["Name"] = "Nameplate Width",
		},

		["QuestIndicator"] = {
			["Name"] = "Quest Progress Indicator",
		},

		["ShowPlayerPlate"] = {
			["Name"] = "Show Pensonal Resource",
		},

		["VerticalSpacing"] = {
			["Name"] = "Nameplate Vertical Spacing",
		},

		["MaxAuras"] = {
			["Name"] = "Max Auras",
		},

		["TargetIndicator"] = {
			["Name"] = "TargetIndicator Style",
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
			["Name"] = "Show Additional Mana Power (|CFFFF7D0ADruid|r, |CFFFFFFFFPriest|r, |CFF0070DEShaman|r)",
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
			["Name"] = "|cff00cc4c".."Enable Castbars",
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
			["Name"] = "|cff00cc4c".."Enable Unitframes",
		},

		["GlobalCooldown"] = {
			["Name"] = "Show Global Cooldown",
		},

		["ResurrectSound"] = {
			["Name"] = "Sound Played When You Are Resurrected",
		},

		["HideTargetofTarget"] = {
			["Name"] = "Hide TargetofTarget Frame",
		},

		["OnlyShowPlayerDebuff"] = {
			["Name"] = "Only Show Your Debuffs",
		},

		["PlayerAuraBars"] = {
			["Name"] = "Show Player Aura Bars Instead Of Aura Icons",
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

		["PvPIndicator"] = {
			["Name"] = "Show PvP Indicator on Player / Target",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Show HealPrediction Statusbars",
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

		["TargetAuraBars"] = {
			["Name"] = "Show Target Aura Bars Instead Of Aura Icons",
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

		["HealthbarColor"] = {
			["Name"] = "Health Color Format",
		},

		["PlayerHealthFormat"] = {
			["Name"] = "Player Health Format",
		},

		["PlayerPowerFormat"] = {
			["Name"] = "Player Power Format",
		},

		["TargetHealthFormat"] = {
			["Name"] = "Target Health Format",
		},

		["TargetPowerFormat"] = {
			["Name"] = "Target Power Format",
		},

		["TargetLevelFormat"] = {
			["Name"] = "Target Level Format",
		},
	},

	-- Arena Local
	["Arena"] = {
		["Castbars"] = {
			["Name"] = "Show Castbars",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable Arena",
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
			["Name"] = "|cff00cc4c".."Enable Boss",
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
			["Name"] = "|cff00cc4c".."Enable Party",
		},

		["HorizonParty"] = {
			["Name"] = "Horizontal Party Frames",
		},

		["PortraitTimers"] = {
			["Name"] = "Portrait Spell Timers",
		},

		["ShowBuffs"] = {
			["Name"] = "Show Party Buffs",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Show HealPrediction Statusbars",
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

		["HealthbarColor"] = {
			["Name"] = "Health Color Format",
		},

		["PartyHealthFormat"] = {
			["Name"] = "Party Health Format",
		},

		["PartyPowerFormat"] = {
			["Name"] = "Party Power Format",
		},
	},

	["PulseCooldown"] = {
		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable PulseCooldown",
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
			["Name"] = "|cff00cc4c".."Enable QuestNotifier",
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
		["SpecRaidPos"] = {
			["Name"] = "Save Raid Posions Based On Specs",
		},

		["ShowTeamIndex"] = {
			["Name"] = "Show Group Number Team Index",
		},

		["ReverseRaid"] = {
			["Name"] = "Reverse Raid Frame Growth",
		},

		["ShowHealPrediction"] = {
			["Name"] = "Show HealPrediction Statusbars",
		},

		["HorizonRaid"] = {
			["Name"] = "Horizontal Raid Frames",
		},

		["NumGroups"] = {
			["Name"] = "Number Of Groups to Show",
		},

		["AuraDebuffIconSize"] = {
			["Name"] = "Aura Debuff Icon Size",
		},

		["AuraWatch"] = {
			["Name"] = "Show AuraWatch Icons",
		},

		["AuraDebuffs"] = {
			["Name"] = "Show AuraDebuff Icons",
		},

		["AuraWatchIconSize"] = {
			["Name"] = "AuraWatch Icon Size",
		},

		["AuraWatchTexture"] = {
			["Name"] = "Show Color AuraWatch Texture",
		},

		["Enable"] = {
			["Name"] = "|cff00cc4c".."Enable Raidframes",
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

		["HealthbarColor"] = {
			["Name"] = "Health Color Format",
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

		["MapScale"] = {
			["Name"] = "Worldmap Scale",
		},

		["MapReveal"] = {
			["Name"] = "Map Reveal",
			["Desc"] = "Show areas on the world map you have yet to discover",
		},

		["PartyIconSize"] = {
			["Name"] = "Party Icon Size",
			["Desc"] = "Adjust the size of player party icons on the world map",
		},

		["PlayerIconSize"] = {
			["Name"] = "Player Icon Size",
			["Desc"] = "Adjust the size of your player icon on the world map",
		},

		["WorldMapIcons"] = {
			["Name"] = "Worldmap Scale",
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
			["Name"] = "Show Azerite Tooltip Traits",
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

		["ShowIDs"] = {
			["Name"] = "Show Tooltip IDs",
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

		["FilgerFonts"] = {
			["Name"] = "Filger Fonts",
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