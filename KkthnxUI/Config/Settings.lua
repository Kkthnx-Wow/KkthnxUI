local _, C = unpack(select(2, ...))

local _G = _G

local DAMAGE = _G.DAMAGE
local HEALER = _G.HEALER
local ITEM_QUALITY2_DESC = _G.ITEM_QUALITY2_DESC
local ITEM_QUALITY3_DESC = _G.ITEM_QUALITY3_DESC
local ITEM_QUALITY4_DESC = _G.ITEM_QUALITY4_DESC
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL

-- Actionbar
C["ActionBar"] = {
	["AddNewSpells"] = true,
	["BottomBars"] = 2,
	["ButtonSize"] = 34,
	["ButtonSpace"] = 6,
	["DisableStancePages"] = false,
	["Enable"] = true,
	["EquipBorder"] = true,
	["Font"] = "KkthnxUI Outline",
	["HideHighlight"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["OutOfMana"] = {0.5, 0.5, 1.0},
	["OutOfRange"] = {0.8, 0.1, 0.1},
	["PetBarHide"] = false,
	["PetBarHorizontal"] = false,
	["RightBars"] = 1,
	["ShowGrid"] = true,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["ToggleMode"] = true,
}

C["MinimapButtons"] = {
	["EnableBar"] = false,
	["BarMouseOver"] = false,
	["ButtonSpacing"] = 6,
	["ButtonsPerRow"] = 1,
	["IconSize"] = 18
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
			["Say Chat"] = "SAY"
		},
		["Value"] = "PARTY"
	}
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
	["ScreenShot"] = false
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
	["Font"] = "KkthnxUI",
	["ItemLevel"] = false,
	["ItemLevelThreshold"] = 10,
	["JunkIcon"] = true,
	["PulseNewItem"] = false,
	["SortInverted"] = true,
	["UseGuildRepairFunds"] = false
}

-- Buffs & Debuffs
C["Auras"] = {
	["Enable"] = true,
	["FadeThreshold"] = 5,
	["Font"] = "KkthnxUI",
	["HorizontalSpacing"] = 6,
	["MaxWraps"] = 3,
	["SeperateOwn"] = 1,
	["Size"] = 32,
	["VerticalSpacing"] = 16,
	["WrapAfter"] = 12,
	["GrowthDirection"] = {
		["Options"] = {
			["Down Left"] = "DOWN_LEFT",
			["Down Right"] = "DOWN_RIGHT",
			["Left Down"] = "LEFT_DOWN",
			["Left Up"] = "LEFT_UP",
			["Right Down"] = "RIGHT_DOWN",
			["Right Up"] = "RIGHT_UP",
			["Up Left"] = "UP_LEFT",
			["Up Right"] = "UP_RIGHT"
		},
		["Value"] = "LEFT_DOWN"
	},
	["SortDir"] = {
		["Options"] = {
			["Ascending"] = "+",
			["Descending"] = "-"
		},
		["Value"] = "-"
	},
	["SortMethod"] = {
		["Options"] = {
			["Index"] = "INDEX",
			["Name"] = "NAME",
			["Time"] = "TIME"
		},
		["Value"] = "TIME"
	}
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
	["Width"] = 410
}

-- Cooldown
C["Cooldown"] = {
	["Days"] = {0.4, 0.4, 1},
	["Enable"] = true,
	["Expiring"] = {1, 0, 0},
	["ExpiringDuration"] = 3.5,
	["Font"] = "KkthnxUI",
	["FontSize"] = 17,
	["Hours"] = {0.4, 1, 1},
	["Minutes"] = {1, 1, 1},
	["Seconds"] = {1, 1, 0},
	["Threshold"] = 3,
}

-- DataBars
C["DataBars"] = {
	["AzeriteColor"] = {.901, .8, .601},
	["AzeriteEnable"] = true,
	["AzeriteHeight"] = 12,
	["AzeriteWidth"] = 164,
	["ExperienceColor"] = {0, 0.4, 1, .8},
	["ExperienceEnable"] = true,
	["ExperienceHeight"] = 12,
	["ExperienceRestedColor"] = {1, 0, 1, 0.2},
	["ExperienceWidth"] = 164,
	["Font"] = "KkthnxUI",
	["HonorColor"] = {240 / 255, 114 / 255, 65 / 255},
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
	["Font"] = "KkthnxUI",
	["LocalTime"] = true,
	["Outline"] = false,
	["System"] = true,
	["Time"] = true,
	["Time24Hr"] = false
}

C["Filger"] = {
	["Bars"] = false,
	["BuffSize"] = 36,
	["CooldownSize"] = 30,
	["DisableCD"] = false,
	["Enable"] = true, -- Something is causing a mass fps drop.
	["Font"] = "KkthnxUI",
	["MaxTestIcon"] = 5,
	["PvPSize"] = 60,
	["ShowTooltip"] = false,
	["TestMode"] = false,
	["Texture"] = "KkthnxUI"
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
	["TaintLog"] = false,
	["Texture"] = "KkthnxUI",
	["TexturesColor"] = {0.9, 0.9, 0.9},
	["UIScale"] = 0.69
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
	["Font"] = "KkthnxUI",
	["Level"] = MAX_PLAYER_LEVEL,
	["Texture"] = "KkthnxUI",
	["AutoQuality"] = {
		["Options"] = {
			["|cffA335EE" .. ITEM_QUALITY4_DESC .. "|r"] = 4,
			["|cff0070DD" .. ITEM_QUALITY3_DESC .. "|r"] = 3,
			["|cff1EFF00" .. ITEM_QUALITY2_DESC .. "|r"] = 2
		},
		["Value"] = 2
	}
}

-- Minimap
C["Minimap"] = {
	["Calendar"] = true,
	["Enable"] = true,
	["ResetZoom"] = false,
	["ResetZoomTime"] = 4,
	["Size"] = 170
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
	["Combat"] = false,
	["Distance"] = 40,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["GoodColor"] = {0.2, 0.8, 0.2},
	["HealthValue"] = true,
	["Height"] = 20,
	["NearColor"] = {1, 1, 0},
	["OffTankColor"] = {0, 0.5, 1},
	["SelectedScale"] = 1,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
	["Threat"] = false,
	["Width"] = 138
}

-- Quests
C["Quests"] = {
	["AutoCollapse"] = false,
	["AutoReward"] = false
}

-- Skins
C["Skins"] = {
	["Bagnon"] = false,
	["BigWigs"] = false,
	["ChatBubbles"] = true,
	["DBM"] = false,
	["Font"] = "KkthnxUI",
	["Recount"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["Texture"] = "KkthnxUI",
	["WeakAuras"] = false
}

-- Tooltip
C["Tooltip"] = {
	["CursorAnchor"] = false,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["FontOutline"] = false,
	["FontSize"] = 12,
	["GuildRanks"] = false,
	["HealthBarText"] = true,
	["HealthbarHeight"] = 10,
	["Icons"] = false,
	["InspectInfo"] = true,
	["ItemQualityBorder"] = true,
	["PlayerTitles"] = false,
	["SpellID"] = true,
	["Texture"] = "KkthnxUI"
}

-- Unitframe
C["Unitframe"] = {
	["CastbarHeight"] = 20,
	["CastbarIcon"] = true,
	["CastbarLatency"] = true,
	["CastbarWidth"] = 214,
	["Castbars"] = true,
	["CombatFade"] = false,
	["CombatText"] = true,
	["DebuffsOnTop"] = true,
	["CastbarTicksWidth"] = 2,
	["CastbarTicksColor"] = {0, 0, 0, 0.8},
	["DecimalLength"] = 1,
	["CastbarTicks"] = false,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["GlobalCooldown"] = false,
	["OORAlpha"] = 0.40,
	["OnlyShowPlayerDebuff"] = false,
	["PowerPredictionBar"] = true,
	["PvPText"] = true,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
	["ThreatPercent"] = false,
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits"
		},
		["Value"] = "DefaultPortraits"
	},
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Metric"] = "METRIC",
			["Chinese"] = "CHINESE",
			["Korean"] = "KOREAN",
			["German"] = "GERMAN",
			["Default"] = "DEFAULT"
		},
		["Value"] = "DEFAULT"
	}
}

C["Party"] = {
	["Font"] = "KkthnxUI",
	["OORAlpha"] = 0.40,
	["Enable"] = true,
	["PartyAsRaid"] = false,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["TargetHighlight"] = false,
	["Texture"] = "KkthnxUI",
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits"
		},
		["Value"] = "DefaultPortraits"
	},
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Metric"] = "METRIC",
			["Chinese"] = "CHINESE",
			["Korean"] = "KOREAN",
			["German"] = "GERMAN",
			["Default"] = "DEFAULT"
		},
		["Value"] = "DEFAULT"
	}
}

C["Arena"] = {
	["Font"] = "KkthnxUI",
	["Enable"] = true,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Castbars"] = true,
	["Texture"] = "KkthnxUI",
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Metric"] = "METRIC",
			["Chinese"] = "CHINESE",
			["Korean"] = "KOREAN",
			["German"] = "GERMAN",
			["Default"] = "DEFAULT"
		},
		["Value"] = "DEFAULT"
	}
}

C["Boss"] = {
	["Font"] = "KkthnxUI",
	["OORAlpha"] = 0.40,
	["Enable"] = true,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Castbars"] = true,
	["Texture"] = "KkthnxUI",
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits"
		},
		["Value"] = "DefaultPortraits"
	},
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Metric"] = "METRIC",
			["Chinese"] = "CHINESE",
			["Korean"] = "KOREAN",
			["German"] = "GERMAN",
			["Default"] = "DEFAULT"
		},
		["Value"] = "DEFAULT"
	}
}

-- Raidframe
C["Raid"] = {
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
	["RaidGroups"] = 14,
	["RaidUtility"] = true,
	["ShowMouseoverHighlight"] = true,
	["ShowNotHereTimer"] = true,
	["ShowRolePrefix"] = false,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["TargetHighlight"] = false,
	["Texture"] = "KkthnxUI",
	["Width"] = 66,
	["RaidLayout"] = {
		["Options"] = {
			[DAMAGE] = "Damage",
			[HEALER] = "Healer"
		},
		["Value"] = "Damage"
	},
	["GroupBy"] = {
		["Options"] = {
			["Group"] = "GROUP",
			["Class"] = "CLASS",
			["Role"] = "ROLE"
		},
		["Value"] = "GROUP"
	}
}

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["SmallWorldMap"] = true,
	["WorldMapPlus"] = false,
}
