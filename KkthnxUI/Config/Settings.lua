local _, C = unpack(select(2, ...))

local _G = _G

local GUILD = _G.GUILD
local NONE = _G.NONE
local PLAYER = _G.PLAYER

-- Actionbar
C["ActionBar"] = {
	["Cooldowns"] = true,
	["Count"] = true,
	["CustomBar"] = false,
	["CustomBarButtonSize"] = 34,
	["CustomBarNumButtons"] = 12,
	["CustomBarNumPerRow"] = 12,
	["DecimalCD"] = true,
	["DefaultButtonSize"] = 34,
	["Enable"] = true,
	["FadePetBar"] = false,
	["FadeRightBar"] = false,
	["FadeRightBar2"] = false,
	["FadeStanceBar"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["MicroBar"] = true,
	["MicroBarMouseover"] = false,
	["OverrideWA"] = false,
	["PetBar"] = true,
	["RightButtonSize"] = 34,
	["StanceBar"] = true,
	["StancePetSize"] = 30,
	["Layout"] = {
		["Options"] = {
			["Mainbar 2x3x4"] = "3x4 Boxed arrangement",
			["Mainbar 3x12"] = "Default Style",
			["Mainbar 4x12"] = "Four Stacked",
		},
		["Value"] = "Default Style"
	},
}

-- Announcements
C["Announcements"] = {
	["ItemAlert"] = false,
	["PullCountdown"] = true,
	["RareAlert"] = false,
	["ResetInstance"] = true,
	["SaySapped"] = false,
	["Interrupt"] = {
		["Options"] = {
			["Disabled"] = "NONE",
			["Emote"] = "EMOTE",
			["Party Only"] = "PARTY",
			["Party/Raid"] = "RAID",
			["Raid Only"] = "RAID_ONLY",
			["Say"] = "SAY",
			["Yell"] = "YELL"
		},
		["Value"] = "PARTY"
	},
}

-- Automation
C["Automation"] = {
	["AutoBlockStrangerInvites"] = false,
	["AutoCollapse"] = false,
	["AutoDeclineDuels"] = false,
	["AutoDeclinePetDuels"] = false,
	["AutoDisenchant"] = false,
	["AutoGoodbye"] = false,
	["AutoInvite"] = false,
	["AutoPartySync"] = false,
	["AutoQuest"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectThank"] = false,
	["AutoReward"] = false,
	["AutoScreenshot"] = false,
	["AutoSetRole"] = false,
	["AutoSkipCinematic"] = false,
	["AutoSummon"] = false,
	["AutoTabBinder"] = false,
	["NoBadBuffs"] = false,
	["WhisperInvite"] = "inv+",
}

C["Inventory"] = {
	["AutoSell"] = true,
	["BagBar"] = true,
	["BagBarMouseover"] = false,
	["BagsItemLevel"] = false,
	["BagsWidth"] = 12,
	["BankWidth"] = 14,
	["DeleteButton"] = true,
	["Enable"] = true,
	["FilterAzerite"] = true,
	["FilterConsumable"] = true,
	["FilterEquipment"] = true,
	["FilterFavourite"] = true,
	["FilterGoods"] = false,
	["FilterJunk"] = true,
	["FilterLegendary"] = true,
	["FilterMount"] = true,
	["FilterQuest"] = true,
	["GatherEmpty"] = false,
	["IconSize"] = 34,
	["ItemFilter"] = true,
	["ItemSetFilter"] = false,
	["ReverseSort"] = false,
	["ShowNewItem"] = true,
	["SpecialBagsColor"] = false,
	["UpgradeIcon"] = true,
	["AutoRepair"] = {
		["Options"] = {
			[NONE] = 0,
			[GUILD] = 1,
			[PLAYER] = 2,
		},
		["Value"] = 2
	},
}

-- Buffs & Debuffs
C["Auras"] = {
	["BuffSize"] = 30,
	["BuffsPerRow"] = 16,
	["DebuffSize"] = 34,
	["DebuffsPerRow"] = 16,
	["Enable"] = true,
	["Reminder"] = false,
	["ReverseBuffs"] = false,
	["ReverseDebuffs"] = false,
	["TotemSize"] = 32,
	["Totems"] = true,
	["VerticalTotems"] = true,
}

-- Chat
C["Chat"] = {
	["AllowFriends"] = true,
	["Background"] = true,
	["BlockAddonAlert"] = false,
	["BlockStranger"] = false,
	["ChatFilterList"] = "%*",
	["ChatFilterWhiteList"] = "",
	["ChatItemLevel"] = true,
	["ChatMenu"] = true,
	["Enable"] = true,
	["EnableFilter"] = true,
	["Fading"] = true,
	["FadingTimeVisible"] = 100,
	["FilterMatches"] = 1,
	["Freedom"] = true,
	["Height"] = 150,
	["Lock"] = true,
	["LootIcons"] = false,
	["OldChatNames"] = false,
	["Sticky"] = false,
	["TabsMouseover"] = true,
	["WhisperColor"] = true,
	["WhisperSound"] = true,
	["Width"] = 392,
	["TimestampFormat"] = {
		["Options"] = {
			["Disable"] = 1,
			["03:27 PM"] = 2,
			["03:27:32 PM"] = 3,
			["15:27"] = 4,
			["15:27:32"] = 5,
		},
		["Value"] = 1
	},
}

-- DataBars
C["DataBars"] = {
	["AzeriteColor"] = {.901, .8, .601},
	["Enable"] = true,
	["ExperienceColor"] = {0, 0.4, 1, .8},
	["Height"] = 14,
	["HonorColor"] = {240/255, 114/255, 65/255},
	["MouseOver"] = false,
	["RestedColor"] = {1, 0, 1, 0.2},
	["TrackHonor"] = false,
	["Width"] = 180,
	["Text"] = {
		["Options"] = {
			["NONE"] = 0,
			["PERCENT"] = 1,
			["CURMAX"] = 2,
			["CURPERC"] = 3,
			["CUR"] = 4,
			["REM"] = 5,
			["CURREM"] = 6,
			["CURPERCREM"] = 7,
		},
		["Value"] = 1
	},
}

-- Datatext
C["DataText"] = {
	["Latency"] = true,
	["Location"] = true,
	["System"] = true,
	["Time"] = true,
}

C["AuraWatch"] = {
	["Enable"] = true,
	["ClickThrough"] = false,
	["IconScale"] = 1,
	["DeprecatedAuras"] = false,
	["QuakeRing"] = false,
	["InternalCD"] = {},
	["AuraList"] = {
		["Switcher"] = {},
		["IgnoreSpells"] = {},
	},
}

-- General
C["General"] = {
	["AutoScale"] = true,
	["ColorTextures"] = false,
	["FontSize"] = 12,
	["MissingTalentAlert"] = true,
	["MoveBlizzardFrames"] = false,
	["NoTutorialButtons"] = false,
	["ReplaceBlizzardFonts"] = true,
	["ReplaceCombatFont"] = true,
	["TexturesColor"] = {1, 1, 1},
	["UIScale"] = 0.71111,
	["UseGlobal"] = false,
	["VersionCheck"] = true,
	["Welcome"] = true,
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Standard: b/m/k"] = 1,
			["Asian: y/w"] = 2,
			["Full Digits"] = 3,
		},
		["Value"] = 1
	},
	["Profiles"] = {
		["Options"] = {},
	},
}

-- Loot
C["Loot"] = {
	["AutoConfirm"] = false,
	["AutoGreed"] = false,
	["Enable"] = true,
	["FastLoot"] = false,
	["GroupLoot"] = true,
}

-- Minimap
C["Minimap"] = {
	["Calendar"] = true,
	["Enable"] = true,
	["ResetZoom"] = false,
	["ResetZoomTime"] = 4,
	["ShowGarrison"] = true,
	["ShowRecycleBin"] = true,
	["Size"] = 180,
	["LocationText"] = {
		["Options"] = {
			["Always Display"] = "SHOW",
			["Hide"] = "Hide",
			["Minimap Mouseover"] = "MOUSEOVER",
		},
		["Value"] = "MOUSEOVER"
	},
	["BlipTexture"] = {
		["Options"] = {
			["Blizzard"] = "Interface\\MiniMap\\ObjectIconsAtlas",
			["Charmed"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Charmed",
			["Nandini"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Nandini-New",
		},
		["Value"] = "Interface\\MiniMap\\ObjectIconsAtlas"
	},
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["AutoBubbles"] = false,
	["ColorPicker"] = false,
	["EasyMarking"] = false,
	["EnhancedFriends"] = false,
	["GemEnchantInfo"] = false,
	["HideBanner"] = false,
	["HideBossEmote"] = false,
	["ImprovedStats"] = false,
	["ItemLevel"] = false,
	["KillingBlow"] = false,
	["NoTalkingHead"] = false,
	["PvPEmote"] = false,
	["ShowWowHeadLinks"] = false,
	["SlotDurability"] = false,
	["TradeTabs"] = false,
	["ShowMarkerBar"] = {
		["Options"] = {
			["Grids"] = 1,
			["Horizontal"] = 2,
			["Vertical"] = 3,
			[DISABLE] = 4,
		},
		["Value"] = 4
	},
}

C["Nameplate"] = {
	["AKSProgress"] = false,
	["AuraSize"] = 22,
	["ClassAuras"] = true,
	["ClassIcon"] = false,
	["CustomColor"] = {0, 0.8, 0.3},
	["CustomUnitColor"] = true,
	["DPSRevertThreat"] = false,
	["Distance"] = 42,
	["Enable"] = true,
	["ExecuteRatio"] = 0,
	["ExplosivesScale"] = false,
	["FriendlyCC"] = false,
	["FullHealth"] = false,
	["HealthTextSize"] = 10,
	["HostileCC"] = true,
	["InsecureColor"] = {1, 0, 0},
	["InsideView"] = true,
	["MaxAuras"] = 5,
	["MinAlpha"] = 1,
	["MinScale"] = 1,
	["NameOnly"] = true,
	["NameTextSize"] = 10,
	["NameplateClassPower"] = true,
	["OffTankColor"] = {0.2, 0.7, 0.5},
	["PPGCDTicker"] = true,
	["PPHeight"] = 5,
	["PPHideOOC"] = true,
	["PPIconSize"] = 32,
	["PPPHeight"] = 6,
	["PPPowerText"] = true,
	["PlateHeight"] = 9,
	["PlateWidth"] = 134,
	["QuestIndicator"] = true,
	["SecureColor"] = {1, 0, 1},
	["ShowPlayerPlate"] = false,
	["Smooth"] = false,
	["TankMode"] = false,
	["TargetIndicatorColor"] = {1, 1, 0},
	["TransColor"] = {1, 0.8, 0},
	["VerticalSpacing"] = 0.7,
	["AuraFilter"] = {
		["Options"] = {
			["White & Black List"] = 1,
			["List & Player"] = 2,
			["List & Player & CCs"] = 3,
		},
		["Value"] = 3
	},
	["TargetIndicator"] = {
		["Options"] = {
			["Disable"] = 1,
			["Top Arrow"] = 2,
			["Right Arrow"] = 3,
			["Border Glow"] = 4,
			["Top Arrow + Glow"] = 5,
			["Right Arrow + Glow"] = 6,
		},
		["Value"] = 4
	},
}

C["PulseCooldown"] = {
	["AnimScale"] = 1.5,
	["Enable"] = false,
	["HoldTime"] = 0.5,
	["Size"] = 75,
	["Sound"] = false,
	["Threshold"] = 3,
}

-- Skins
C["Skins"] = {
	["Bartender4"] = false,
	["BigWigs"] = false,
	["BlizzardFrames"] = true,
	["ChatBubbleAlpha"] = 0.9,
	["ChatBubbles"] = true,
	["ChocolateBar"] = false,
	["DeadlyBossMods"] = false,
	["Details"] = false,
	["Hekili"] = false,
	["RareScanner"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["TalkingHeadBackdrop"] = true,
	["TellMeWhen"] = false,
	["TitanPanel"] = false,
	["WeakAuras"] = false,
}

-- Tooltip
C["Tooltip"] = {
	["ClassColor"] = false,
	["CombatHide"] = false,
	["Cursor"] = false,
	["FactionIcon"] = false,
	["HideJunkGuild"] = true,
	["HideRank"] = true,
	["HideRealm"] = true,
	["HideTitle"] = true,
	["Icons"] = true,
	["LFDRole"] = false,
	["ShowIDs"] = false,
	["SpecLevelByShift"] = true,
	["TargetBy"] = true,
}

-- Fonts
C["UIFonts"] = {
	["ActionBarsFonts"] = "KkthnxUI Outline",
	["AuraFonts"] = "KkthnxUI Outline",
	["ChatFonts"] = "KkthnxUI",
	["DataBarsFonts"] = "KkthnxUI",
	["DataTextFonts"] = "KkthnxUI",
	["FilgerFonts"] = "KkthnxUI Outline",
	["GeneralFonts"] = "KkthnxUI",
	["InventoryFonts"] = "KkthnxUI Outline",
	["MinimapFonts"] = "KkthnxUI",
	["NameplateFonts"] = "KkthnxUI",
	["QuestTrackerFonts"] = "KkthnxUI",
	["SkinFonts"] = "KkthnxUI",
	["TooltipFonts"] = "KkthnxUI",
	["UnitframeFonts"] = "KkthnxUI",
}

-- Textures
C["UITextures"] = {
	["DataBarsTexture"] = "KkthnxUI",
	["FilgerTextures"] = "KkthnxUI",
	["GeneralTextures"] = "KkthnxUI",
	["HealPredictionTextures"] = "KkthnxUI",
	["LootTextures"] = "KkthnxUI",
	["NameplateTextures"] = "KkthnxUI",
	["QuestTrackerTexture"] = "KkthnxUI",
	["SkinTextures"] = "KkthnxUI",
	["TooltipTextures"] = "KkthnxUI",
	["UnitframeTextures"] = "KkthnxUI",
}

-- Unitframe
C["Unitframe"] = {
	["AdditionalPower"] = true,
	["AutoAttack"] = true,
	["CastClassColor"] = false,
	["CastReactionColor"] = false,
	["CastbarLatency"] = true,
	["Castbars"] = true,
	["ClassResources"] = true,
	["CombatFade"] = false,
	["CombatText"] = false,
	["DebuffHighlight"] = true,
	["Enable"] = true,
	["FCTOverHealing"] = false,
	["GlobalCooldown"] = false,
	["HideTargetofTarget"] = false,
	["HotsDots"] = true,
	["OnlyShowPlayerDebuff"] = false,
	["PetCombatText"] = true,
	["HideTargetOfTargetLevel"] = false,
	["HideTargetOfTargetName"] = false,
	["PlayerBuffs"] = false,
	["PlayerCastbarHeight"] = 24,
	["PlayerCastbarWidth"] = 260,
	["PlayerDeBuffs"] = false,
	["PlayerPowerPrediction"] = true,
	["PortraitTimers"] = false,
	["PvPIndicator"] = true,
	["ResurrectSound"] = false,
	["ShowHealPrediction"] = true,
	["ShowPlayerLevel"] = true,
	["ShowPlayerName"] = false,
	["Smooth"] = false,
	["Stagger"] = true,
	["Swingbar"] = false,
	["SwingbarTimer"] = false,
	["TargetBuffs"] = true,
	["TargetBuffsPerRow"] = 6,
	["TargetCastbarHeight"] = 24,
	["TargetCastbarWidth"] = 260,
	["TargetDebuffs"] = true,
	["TargetDebuffsPerRow"] = 5,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
	},
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits"
		},
		["Value"] = "DefaultPortraits"
	},
}

C["Party"] = {
	["Castbars"] = false,
	["Enable"] = true,
	["PortraitTimers"] = false,
	["ShowBuffs"] = true,
	["ShowHealPrediction"] = true,
	["ShowPet"] = false,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
}

C["Boss"] = {
	["Castbars"] = true,
	["Enable"] = true,
	["Smooth"] = false,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
}

C["Arena"] = {
	["Castbars"] = true,
	["Enable"] = true,
	["Smooth"] = false,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
}

-- Raidframe
C["Raid"] = {
	["AuraDebuffIconSize"] = 22,
	["AuraDebuffs"] = true,
	["AuraWatch"] = true,
	["AuraWatchIconSize"] = 11,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Height"] = 40,
	["HorizonRaid"] = false,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["NumGroups"] = 6,
	["RaidUtility"] = true,
	["ReverseRaid"] = false,
	["ShowHealPrediction"] = true,
	["ShowNotHereTimer"] = true,
	["ShowTeamIndex"] = false,
	["Smooth"] = false,
	["SpecRaidPos"] = false,
	["TargetHighlight"] = false,
	["Width"] = 66,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
	["HealthFormat"] = {
        ["Options"] = {
			["Disable HP"] = 1,
			["Health Percentage"] = 2,
			["Health Remaining"] = 3,
			["Health Lost"] = 4,
        },
        ["Value"] = 1
    },
}

C["QuestNotifier"] = {
	["Enable"] = false,
	["OnlyCompleteRing"] = false,
	["QuestProgress"] = false,
}

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["MapRevealGlow"] = true,
	["SmallWorldMap"] = true,
	["MapReveal"] = false,
}