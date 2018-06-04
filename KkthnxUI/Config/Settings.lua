local _, C = unpack(select(2, ...))

-- Actionbar
C["ActionBar"] = {
	["AddNewSpells"] = true,
	["BottomBars"] = 2,
	["ButtonSize"] = 34,
	["ButtonSpace"] = 6,
	["DisableStancePages"] = false,
	["Enable"] = true,
	["Grid"] = true,
	["HideHighlight"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["OutOfMana"] = {0.5, 0.5, 1.0},
	["OutOfRange"] = {0.8, 0.1, 0.1},
	["PetBarHide"] = false,
	["PetBarHorizontal"] = false,
	["RightBars"] = 1,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["ToggleMode"] = true,
	["Font"] = "KkthnxUI Outline",
}

C["MinimapButtons"] = {
	["EnableBar"] = false,
	["BarMouseOver"] = false,
	["ButtonSpacing"] = 6,
	["ButtonsPerRow"] = 1,
	["IconSize"] = 18,
}

-- Announcements
C["Announcements"] = {
	["PullCountdown"] = true,
	["SaySapped"] = false,
	["Interrupt"] = {
		["Options"] = {
			["Disabled"] = "NONE",
			["Emote Chat"] = "EMOTE",
			["Party Chat"] = "PARTY",
			["Raid Chat Only"] = "RAID_ONLY",
			["Raid Chat"] = "RAID",
			["Say Chat"] = "SAY",
		},
		["Value"] = "PARTY",
	},
}

-- Automation
C["Automation"] = {
	["AutoInvite"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectCombat"] = true,
	["AutoResurrectThank"] = false,
	["BlockMovies"] = false,
	["DeclinePetDuel"] = false,
	["DeclinePvPDuel"] = false,
	["InviteKeyword"] = "invite",
	["ScreenShot"] = false,
}

C["Inventory"] = {
	["AutoRepair"] = true,
	["AutoSell"] = true,
	["BagColumns"] = 10,
	["BankColumns"] = 17,
	["ButtonSize"] = 32,
	["ButtonSpace"] = 6,
	["DetailedReport"] = false,
	["Enable"] = true,
	["ItemLevel"] = false,
	["ItemLevelThreshold"] = 10,
	["JunkIcon"] = true,
	["PulseNewItem"] = false,
	["SortInverted"] = true,
	["UseGuildRepairFunds"] = false,
}

-- Buffs & Debuffs
C["Auras"] = {
	["Enable"] = true,
	["HorizontalSpacing"] = 6,
	["MaxWraps"] = 3,
	["SeperateOwn"] = 1,
	["Size"] = 32,
	["VerticalSpacing"] = 16,
	["WrapAfter"] = 12,
	["FadeThreshold"] = 5,
	["GrowthDirection"] = {
		["Options"] = {
			["Down Left"] = "DOWN_LEFT",
			["Down Right"] = "DOWN_RIGHT",
			["Left Down"] = "LEFT_DOWN",
			["Left Up"] = "LEFT_UP",
			["Right Down"] = "RIGHT_DOWN",
			["Right Up"] = "RIGHT_UP",
			["Up Left"] = "UP_LEFT",
			["Up Right"] = "UP_RIGHT",
		},
		["Value"] = "LEFT_DOWN",
	},
	["SortDir"] = {
		["Options"] = {
			["Ascending"] = "+",
			["Descending"] = "-",
		},
		["Value"] = "-",
	},
	["SortMethod"] = {
		["Options"] = {
			["Index"] = "INDEX",
			["Name"] = "NAME",
			["Time"] = "TIME",
		},
		["Value"] = "TIME",
	},
}

-- Chat
C["Chat"] = {
	["Background"] = false,
	["BackgroundAlpha"] = 0.25,
	["Enable"] = true,
	["Fading"] = true,
	["FadingTimeFading"] = 3,
	["FadingTimeVisible"] = 20,
	["Font"] = "KkthnxUI",
	["Height"] = 149,
	["LinkBrackets"] = true,
	["LinkColor"] = {0.08, 1, 0.36},
	["MessageFilter"] = false,
	["QuickJoin"] = false,
	["RemoveRealmNames"] = true,
	["ScrollByX"] = 3,
	["ShortenChannelNames"] = true,
	["TabsMouseover"] = true,
	["WhisperSound"] = true,
	["Width"] = 410,
}

-- Cooldown
C["Cooldown"] = {
	["Days"] = {0.4, 0.4, 1},
	["Enable"] = true,
	["Expiring"] = {1, 0, 0},
	["ExpiringDuration"] = 3.5,
	["FontSize"] = 17,
	["Hours"] = {0.4, 1, 1},
	["Minutes"] = {1, 1, 1},
	["Seconds"] = {1, 1, 0},
	["Threshold"] = 3,
}

-- DataBars
C["DataBars"] = {
	["ArtifactColor"] = {.901, .8, .601},
	["ArtifactEnable"] = true,
	["ArtifactHeight"] = 12,
	["ArtifactWidth"] = 164,
	["ExperienceColor"] = {0, 0.4, 1, .8},
	["ExperienceEnable"] = true,
	["ExperienceHeight"] = 12,
	["ExperienceRestedColor"] = {1, 0, 1, 0.2},
	["ExperienceWidth"] = 164,
	["HonorColor"] = {240/255, 114/255, 65/255},
	["HonorEnable"] = true,
	["HonorHeight"] = 12,
	["HonorWidth"] = 164,
	["MouseOver"] = false,
	["Outline"] = false,
	["ReputationEnable"] = true,
	["ReputationHeight"] = 12,
	["ReputationWidth"] = 164,
	["Texture"] = "KkthnxUI",
}

-- Datatext
C["DataText"] = {
	["Battleground"] = true,
	["LocalTime"] = true,
	["Outline"] = false,
	["System"] = true,
	["Time"] = true,
	["Time24Hr"] = false,
}

C["Filger"] = {
	["Bars"] = false,
	["BuffSize"] = 36,
	["CooldownSize"] = 30,
	["DisableCD"] = false,
	["Enable"] = true,
	["MaxTestIcon"] = 5,
	["PvPSize"] = 60,
	["ShowTooltip"] = false,
	["TestMode"] = false,
	["Texture"] = "KkthnxUI",
}

-- General
C["General"] = {
	["AutoScale"] = true,
	["ColorTextures"] = false,
	["DisableTutorialButtons"] = false,
	["Font"] = "KkthnxUI",
	["FontSize"] = 12,
	["MoveBlizzardFrames"] = false,
	["ReplaceBlizzardFonts"] = true,
	["SpellTolerance"] = false,
	["TaintLog"] = false,
	["Texture"] = "KkthnxUI",
	["TexturesColor"] = {0.9, 0.9, 0.9},
	["UIScale"] = 0.69,
}

-- Loot
C["Loot"] = {
	["AutoConfirm"] = false,
	["AutoDisenchant"] = false,
	["AutoGreed"] = false,
	["ByLevel"] = false,
	["Enable"] = true,
	["FastLoot"] = false,
	["GroupLoot"] = true,
	["Level"] = MAX_PLAYER_LEVEL,
	["Texture"] = "KkthnxUI",
	["AutoQuality"] = {
		["Options"] = {
			["|cffA335EE"..ITEM_QUALITY4_DESC.."|r"] = 4,
			["|cff0070DD"..ITEM_QUALITY3_DESC.."|r"] = 3,
			["|cff1EFF00"..ITEM_QUALITY2_DESC.."|r"] = 2,
		},
		["Value"] = 2,
	},
}

-- Minimap
C["Minimap"] = {
	["Calendar"] = true,
	["Enable"] = true,
	["ResetZoom"] = false,
	["ResetZoomTime"] = 4,
	["Size"] = 170,
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["BattlegroundSpam"] = false,
	["ColorPicker"] = false,
	["ItemLevel"] = false,
	["KillingBlow"] = false,
	["PvPEmote"] = false,
	["SlotDurability"] = false,
}

-- Nameplates
C["Nameplates"] = {
	["BadColor"] = {1, 0, 0},
	["CastHeight"] = 6,
	["Clamp"] = false,
	["Distance"] = 40,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["GoodColor"] = {0.2, 0.8, 0.2},
	["HealthValue"] = true,
	["Height"] = 22,
	["NearColor"] = {1, 1, 0},
	["OffTankColor"] = {0, 0.5, 1},
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
	["Threat"] = false,
	["Width"] = 146,
}

-- Quests
C["Quests"] = {
	["AutoCollapse"] = false,
	["AutoReward"] = false,
}

-- Skins
C["Skins"] = {
	["Bagnon"] = false,
	["BigWigs"] = false,
	["ChatBubbles"] = true,
	["DBM"] = false,
	["Recount"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["Texture"] = "KkthnxUI",
	["WeakAuras"] = false,
}

-- Tooltip
C["Tooltip"] = {
	["CursorAnchor"] = false,
	["Enable"] = true,
	["FontOutline"] = false,
	["FontSize"] = 12,
	["GuildRanks"] = false,
	["HealthbarHeight"] = 10,
	["HealthBarText"] = true,
	["Icons"] = false,
	["InspectInfo"] = true,
	["ItemQualityBorder"] = true,
	["PlayerTitles"] = false,
	["SpellID"] = true,
	["Texture"] = "KkthnxUI",
}

-- Unitframe
C["Unitframe"] = {
	["CastbarHeight"] = 20,
	["CastbarIcon"] = true,
	["CastbarLatency"] = true,
	["Castbars"] = true,
	["CastbarWidth"] = 214,
	["CombatFade"] = false,
	["CombatText"] = true,
	["DebuffsOnTop"] = true,
	["DecimalLength"] = 1,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["FontSize"] = 12,
	["GlobalCooldown"] = false,
	["OnlyShowPlayerDebuff"] = false,
	["OORAlpha"] = 0.40,
	["Party"] = true,
	["PartyAsRaid"] = false,
	["PowerPredictionBar"] = true,
	["PvPText"] = true,
	["ShowArena"] = true,
	["ShowBoss"] = true,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["TargetHighlight"] = false,
	["Texture"] = "KkthnxUI",
	["ThreatPercent"] = false,
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits",
		},
		["Value"] = "DefaultPortraits",
	},
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Metric"] = "METRIC",
			["Chinese"] = "CHINESE",
			["Korean"] = "KOREAN",
			["German"] = "GERMAN",
			["Default"] = "DEFAULT",
		},
		["Value"] = "DEFAULT",
	},
}

C["Partyframe"] = {
	["TESTING"] = 0,
}

-- Raidframe
C["Raidframe"] = {
	["AuraDebuffIconSize"] = 22,
	["AuraWatch"] = true,
	["AuraWatchIconSize"] = 6,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["Height"] = 30,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["Outline"] = false,
	["RaidGroups"] = 5,
	["RaidUtility"] = true,
	["ShowMouseoverHighlight"] = true,
	["ShowNotHereTimer"] = true,
	["ShowRolePrefix"] = false,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["TargetHighlight"] = false,
	["Texture"] = "KkthnxUI",
	["Width"] = 60,
	["RaidLayout"] = {
		["Options"] = {
			[DAMAGE] = "Damage",
			[HEALER] = "Healer",
		},
		["Value"] = "Damage",
	},
	["GroupBy"] = {
		["Options"] = {
			["Group"] = "GROUP",
			["Class"] = "CLASS",
			["Role"] = "ROLE",
		},
		["Value"] = "GROUP",
	},
}

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["SmallWorldMap"] = true,
	["WorldMapPlus"] = false,
}