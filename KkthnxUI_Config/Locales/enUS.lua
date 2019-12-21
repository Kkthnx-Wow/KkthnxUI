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
		["Nameplates"] = "Nameplates",
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
			["Name"] = "Enable ActionBars",
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
			["Name"] = "Enable",
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

		["OffTankColor"] = {
			["Name"] = "Off Tank Threat Color",
		},

		["Clamp"] = {
			["Name"] = "Clamp Nameplates",
			["Desc"] = "Clamp nameplates to the top of the screen when outside of view."
		},

		["ClassIcons"] = {
			["Name"] = "Show Enemy Class Icons",
			["Desc"] = "Show Enemy Class Icons to help better determine what class they are. |n|nThis is helpful for people who are colorblind!"
		},

		["Combat"] = {
			["Name"] = "Show Nameplates In Combat",
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

		["QuestInfo"] = {
			["Name"] = "Show Quest Info Icon",
		},

		["SelectedScale"] = {
			["Name"] = "Selected Nameplate Scale",
		},

		["ShowFullHealth"] = {
			["Name"] = "Show Full Health",
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

		["HealthbarColor"] = {
			["Name"] = "Health Color Format",
		},

		["LevelFormat"] = {
			["Name"] = "Level Format Display",
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
			["Name"] = "Enable Castbars",
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
			["Name"] = "Enable Unitframes",
		},

		["EnergyTick"] = {
			["Name"] = "Show Energy/Mana Ticks",
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