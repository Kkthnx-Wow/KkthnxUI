local _, C = unpack(select(2, ...))

-- Actionbar
C["ActionBar"] = {
	["AddNewSpells"] = true,
	["BottomBars"] = 2,
	["ButtonSize"] = 34,
	["ButtonSpace"] = 6,
	["Enable"] = true,
	["Grid"] = true,
	["HideHighlight"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["OutOfMana"] = {0.5, 0.5, 1.0},
	["OutOfRange"] = {0.8, 0.1, 0.1},
	["PetBarHide"] = false,
	["PetBarHorizontal"] = false,
	["PetBarMouseover"] = false,
	["RightBars"] = 1,
	["RightBarsMouseover"] = false,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["StanceBarMouseover"] = false,
	["ToggleMode"] = true,
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
	["AutoSellMisc"] = true,
	["BagColumns"] = 10,
	["BagFilter"] = false,
	["BankColumns"] = 17,
	["ButtonSize"] = 32,
	["ButtonSpace"] = 6,
	["Enable"] = true,
	["ItemLevel"] = false,
	["JunkIcon"] = true,
	["PulseNewItem"] = false,
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
			["Time"] = "TIME",
			["Name"] = "NAME",
		},
		["Value"] = "TIME",
	},
}

-- Chat
C["Chat"] = {
	["Enable"] = true,
	["Fading"] = true,
	["FadingTimeFading"] = 3,
	["FadingTimeVisible"] = 20,
	["Font"] = "KkthnxUI",
	["Height"] = 140,
	["LinkBrackets"] = true,
	["LinkColor"] = {0.08, 1, 0.36},
	["MessageFilter"] = false,
	["QuickJoin"] = false,
	["RemoveRealmNames"] = true,
	["ScrollByX"] = 3,
	["ShortenChannelNames"] = true,
	["SpamFilter"] = false,
	["TabsMouseover"] = true,
	["TabsOutline"] = false,
	["WhisperSound"] = true,
	["Width"] = 400,
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

-- Errors
C["Error"] = {
	["Black"] = true,
	["Combat"] = false,
	["White"] = false,
}

C["Filger"] = {
	["BuffSize"] = 37,
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
	["AutoRoll"] = false,
	["Enable"] = true,
	["FastLoot"] = false,
	["GroupLoot"] = true,
	["Texture"] = "KkthnxUI",
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
	["EnhancedPvpMessages"] = false,
	["ItemLevel"] = false,
	["KillingBlow"] = false,
	["NoBanner"] = false,
	["PvPEmote"] = false,
	["SlotDurability"] = false,
}

-- Nameplates
C["Nameplates"] = {
	["AurasSize"] = 24,
	["BadColor"] = {1, 0, 0},
	["CastbarName"] = true,
	["CastUnitReaction"] = true,
	["Clamp"] = false,
	["Distance"] = 40,
	["Enable"] = true,
	["EnhancedThreat"] = false,
	["FontSize"] = 12,
	["GoodColor"] = {0.2, 0.8, 0.2},
	["HealerIcon"] = false,
	["HealthValue"] = true,
	["Height"] = 16,
	["NameAbbreviate"] = false,
	["NearColor"] = {1, 1, 0},
	["OffTankColor"] = {0, 0.5, 1},
	["OORAlpha"] = 0.40,
	["Outline"] = false,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
	["ThreatPercent"] = false,
	["TotemIcons"] = false,
	["TrackAuras"] = true,
	["Width"] = 132,
}

-- Skins
C["Quests"] = {
	["AutoCollapse"] = false,
	["AutoReward"] = false,
	["Arena"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "COLLAPSED",
	},
	["Raid"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "COLLAPSED",
	},
	["Orderhall"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL",
	},
	["Garrison"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL",
	},
	["Dungeon"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL",
	},
	["Combat"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
			[NONE] = "NONE",
		},
		["Value"] = "NONE",
	},
	["Battleground"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "COLLAPSED",
	},
	["Scenario"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL",
	},
	["Rested"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL",
	},
}

-- Skins
C["Skins"] = {
	["Bagnon"] = false,
	["BigWigs"] = false,
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
	["CastbarTicks"] = false,
	["CastbarWidth"] = 214,
	["CastClassColor"] = true,
	["CastReactionColor"] = true,
	["CombatText"] = true,
	["DebuffsOnTop"] = true,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["FontSize"] = 12,
	["GlobalCooldown"] = false,
	["NameAbbreviate"] = false,
	["OnlyShowPlayerDebuff"] = false,
	["OORAlpha"] = 0.40,
	["Outline"] = false,
	["Party"] = true,
	["PowerPredictionBar"] = true,
	["PvPText"] = true,
	["Scale"] = 1,
	["ShowArena"] = true,
	["ShowBoss"] = true,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
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

-- Raidframe
C["Raidframe"] = {
	["AuraDebuffIconSize"] = 22,
	["AuraWatch"] = true,
	["AuraWatchIconSize"] = 6,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["Height"] = 40,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["MaxUnitPerColumn"] = 10,
	["Outline"] = false,
	["RaidTools"] = true,
	["RaidUtility"] = true,
	["Scale"] = 1,
	["ShowMouseoverHighlight"] = true,
	["ShowNotHereTimer"] = true,
	["ShowRolePrefix"] = false,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
	["Width"] = 56,
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