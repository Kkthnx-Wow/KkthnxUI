local K, C = unpack(select(2, ...))

local _G = _G

local DAMAGE = _G.DAMAGE
local DEFAULT = _G.DEFAULT
local DISABLE = _G.DISABLE
local GUILD = _G.GUILD
local GetCurrentRegion = _G.GetCurrentRegion
local HEALER = _G.HEALER
local HIDE = _G.HIDE
local ITEM_QUALITY2_DESC = _G.ITEM_QUALITY2_DESC
local ITEM_QUALITY3_DESC = _G.ITEM_QUALITY3_DESC
local ITEM_QUALITY4_DESC = _G.ITEM_QUALITY4_DESC
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local MINIMIZE = _G.MINIMIZE
local NONE = _G.NONE
local PLAYER = _G.PLAYER

-- Actionbar
C["ActionBar"] = {
	["AddNewSpells"] = true,
	["BottomBars"] = 2,
	["ButtonSize"] = 34,
	["ButtonSpace"] = 6,
	["Cooldowns"] = true,
	["DisableStancePages"] = K.Class == "DRUID", -- don't need a stealth bar for druids
	["Enable"] = true,
	["EquipBorder"] = true,
	["Font"] = "KkthnxUI Outline",
	["Hotkey"] = true,
	["Macro"] = true,
	["MicroBar"] = false,
	["MicroBarMouseover"] = false,
	["OutOfMana"] = {0.5, 0.5, 1.0},
	["OutOfRange"] = {0.8, 0.1, 0.1},
	["PetBarHide"] = false,
	["PetBarHorizontal"] = false,
	["PetMouseover"] = false,
	["RightBars"] = 1,
	["RightMouseover"] = false,
	["ShowGrid"] = true,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["StanceMouseover"] = false,
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
	},
}

-- Automation
C["Automation"] = {
	["AutoCollapse"] = false,
	["AutoInvite"] = false,
	["AutoQuest"] = true,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectThank"] = false,
	["AutoReward"] = false,
	["BlockMovies"] = false,
	["DeclinePetDuel"] = false,
	["DeclinePvPDuel"] = false,
	["ScreenShot"] = false,
	-- AutoCollapse Features
	["Rested"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL"
	},

	["Garrison"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL"
	},

	["Orderhall"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL"
	},

	["Battleground"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "COLLAPSED"
	},

	["Arena"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "COLLAPSED"
	},

	["Dungeon"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL"
	},

	["Scenario"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "FULL"
	},

	["Raid"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
		},
		["Value"] = "COLLAPSED"
	},

	["Combat"] = {
		["Options"] = {
			[DEFAULT] = "FULL",
			[MINIMIZE] = "COLLAPSED",
			[HIDE] = "HIDE",
			[NONE] = "NONE",
		},
		["Value"] = "NONE"
	}
}

C["Inventory"] = {
	["AutoSell"] = true,
	["BagColumns"] = 10,
	["BankColumns"] = 17,
	["BindText"] = true,
	["ButtonSize"] = 32,
	["ButtonSpace"] = 6,
	["DetailedReport"] = false,
	["Enable"] = true,
	["Font"] = "KkthnxUI Outline",
	["ItemLevel"] = false,
	["ItemLevelThreshold"] = 10,
	["JunkIcon"] = true,
	["PulseNewItem"] = false,
	["ReverseLoot"] = false,
	["SortInverted"] = false,
	["AutoRepair"] = {
		["Options"] = {
			[NONE] = "NONE",
			[GUILD] = "GUILD",
			[PLAYER] = "PLAYER",
		},
		["Value"] = "PLAYER"
	},
}

-- Buffs & Debuffs
C["Auras"] = {
	["Enable"] = true,
	["FadeThreshold"] = 5,
	["Font"] = "KkthnxUI Outline",
	["HorizontalSpacing"] = 6,
	["MaxWraps"] = 3,
	["SeperateOwn"] = 1,
	["Size"] = 32,
	["VerticalSpacing"] = 20,
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
	["VoiceOverlay"] = true,
	["FadingTimeFading"] = 3,
	["FadingTimeVisible"] = 20,
	["Filter"] = false,
	["Font"] = "KkthnxUI",
	["Height"] = 149,
	["QuickJoin"] = false,
	["RemoveRealmNames"] = true,
	["ScrollByX"] = 3,
	["ShortenChannelNames"] = true,
	["TabsMouseover"] = true,
	["WhisperSound"] = true,
	["Width"] = 410
}

-- DataBars
C["DataBars"] = {
	["AzeriteColor"] = {0.901, 0.8, 0.601},
	["Enable"] = true,
	["ExperienceColor"] = {0.6, 0.3, 0.8},
	["Font"] = "KkthnxUI",
	["Height"] = 10,
	["MouseOver"] = false,
	["RestedColor"] = {0.0, 0.4, 1.0, 0.8},
	["Text"] = false,
	["Texture"] = "KkthnxUI",
	["TrackHonor"] = false,
	["Width"] = 180,
}

-- Datatext
C["DataText"] = {
	["Battleground"] = true,
	["Font"] = "KkthnxUI",
	["LocalTime"] = true,
	["System"] = true,
	["Time"] = true,
	["Time24Hr"] = GetCurrentRegion() ~= 1
}

C["Filger"] = {
	["BuffSize"] = 36,
	["CooldownSize"] = 30,
	["DisableCD"] = false,
	["DisablePvP"] = false,
	["Expiration"] = false,
	["Enable"] = false,
	["Font"] = "KkthnxUI",
	["MaxTestIcon"] = 5,
	["PvPSize"] = 60,
	["ShowTooltip"] = false,
	["TestMode"] = false,
	["Texture"] = "KkthnxUI"
}

-- General
C["General"] = {
	--["AutoScale"] = true,
	["ColorTextures"] = false,
	["DisableTutorialButtons"] = false,
	["FixGarbageCollect"] = true,
	["Font"] = "KkthnxUI",
	["FontSize"] = 12,
	["LagTolerance"] = false,
	["MoveBlizzardFrames"] = false,
	["ReplaceBlizzardFonts"] = true,
	["Texture"] = "KkthnxUI",
	["TexturesColor"] = {0.9, 0.9, 0.9},
	--["UIScale"] = 0.7111111111,
	["Welcome"] = true,

	["Scaling"] = {
		["Options"] = {
			["Pixel Perfection"] = "Pixel Perfection",
			["Smallest"] = "Smallest",
			["Small"] = "Small",
			["Medium"] = "Medium",
			["Large"] = "Large",
			["Oversize"] = "Oversize",
		},

		["Value"] = "Pixel Perfection",
	},

}

C["HealthPrediction"] = {
	["Absorbs"] = {1, 1, 0, 0.25},
	["HealAbsorbs"] = {1, 0, 0, 0.25},
	["Others"] = {0, 1, 0, 0.25},
	["Personal"] = {0, 1, 0.5, 0.25},
	["Texture"] = "Blank",
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
	["GarrisonLandingPage"] = true,
	["ResetZoom"] = false,
	["ResetZoomTime"] = 4,
	["Size"] = 180,
	["VignetteAlert"] = false,
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["BattlegroundSpam"] = false,
	["CharacterInfo"] = false,
	["ColorPicker"] = false,
	["EnhancedFriends"] = false,
	["ImprovedStats"] = false,
	["InspectInfo"]	= false,
	["KillingBlow"] = false,
	["NoTalkingHead"] = false,
	["ProfessionTabs"] = false,
	["PvPEmote"] = false,
	["SlotDurability"] = false,
}

-- Nameplates
C["Nameplates"] = {
	["BadColor"] = {0.78, 0.25, 0.25},
	["BadTransition"] = {235/255, 163/255, 40/255},
	["CastHeight"] = 2,
	["Clamp"] = false,
	["ClassIcons"] = true,
	["ClassResource"] = true,
	["Combat"] = false,
	["Distance"] = 40,
	["EliteIcon"] = true,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["GoodColor"] = {75/255, 175/255, 76/255},
	["GoodTransition"] = {218/255, 197/255, 92/255},
	["HealthValue"] = true,
	["Height"] = 16,
	["MarkHealers"] = false,
	["NonTargetAlpha"] = 0.35,
	["OverlapH"] = 1.2,
	["OverlapV"] = 1.2,
	["QuestIcon"] = true,
	["QuestIconSize"] = 16,
	["SelectedScale"] = 1,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["TankedByTankColor"] = {0.8, 0.1, 1},
	["TappedColor"] = {0.6, 0.6, 0.6},
	["TargetArrow"] = true,
	["Texture"] = "KkthnxUI",
	["Threat"] = false,
	["Totems"] = false,
	["TrackAuras"] = true,
	["Width"] = 136,
	["HealthFormat"] = {
		["Options"] = {
			["Current"] = "[KkthnxUI:HealthCurrent]",
			["Percent"] = "[KkthnxUI:HealthPercent]",
			["Current / Percent"] = "[KkthnxUI:HealthCurrent-Percent]",
		},
		["Value"] = "[KkthnxUI:HealthPercent]"
	},
	["ShowEnemyCombat"] = {
		["Options"] = {
			[DISABLE] = "DISABLED",
			["Toggle On In Combat"] = "TOGGLE_ON",
			["Toggle Off In Combat"] = "TOGGLE_OFF",

		},
		["Value"] = "DISABLED"
	},
	["ShowFriendlyCombat"] = {
		["Options"] = {
			[DISABLE] = "DISABLED",
			["Toggle On In Combat"] = "TOGGLE_ON",
			["Toggle Off In Combat"] = "TOGGLE_OFF",

		},
		["Value"] = "DISABLED"
	}
}

-- Skins
C["Skins"] = {
	["Bagnon"] = false,
	["BigWigs"] = false,
	["BlizzardBags"] = false,
	["ChatBubbles"] = true,
	["DBM"] = false,
	["Details"] =  false,
	["Font"] = "KkthnxUI",
	["Hekili"] = false,
	["ResetDetails"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["TalkingHeadBackdrop"] = true,
	["Texture"] = "KkthnxUI",
	["WeakAuras"] = false,
}

-- Tooltip
C["Tooltip"] = {
	["CursorAnchor"] = false,
	["CursorAnchorX"] = 0,
	["CursorAnchorY"] = 0,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["FontOutline"] = false,
	["FontSize"] = 12,
	["GuildRanks"] = false,
	["HealthBarText"] = true,
	["HealthbarHeight"] = 9,
	["Icons"] = false,
	["InspectInfo"] = true,
	["ItemQualityBorder"] = true,
	["NpcID"] = false,
	["PlayerRoles"] = false,
	["PlayerTitles"] = false,
	["ShowMount"] = false,
	["SpellID"] = true,
	["TargetInfo"] = false,
	["Texture"] = "KkthnxUI"
}

-- Unitframe
C["Unitframe"] = {
	["CastbarHeight"] = 20,
	["CastbarIcon"] = true,
	["CastbarLatency"] = true,
	["Castbars"] = true,
	["CastbarTicks"] = false,
	["CastbarTicksWidth"] = 2,
	["CastbarWidth"] = 226,
	["CastClassColor"] = true,
	["CastReactionColor"] = true,
	["ClassResource"] = true,
	["CombatFade"] = false,
	["DebuffsOnTop"] = true,
	["DecimalLength"] = 1,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["GlobalCooldown"] = false,
	["MouseoverHighlight"] = true,
	["OnlyShowPlayerDebuff"] = false,
	["PlayerBuffs"] = false,
	["PortraitTimers"] = false,
	["PowerPredictionBar"] = true,
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
	["CastbarIcon"] = true,
	["Castbars"] = false,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["MouseoverHighlight"] = true,
	["PartyAsRaid"] = false,
	["PortraitTimers"] = false,
	["ShowBuffs"] = true,
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
	["CastbarIcon"] = true,
	["Castbars"] = true,
	["DecimalLength"] = 1,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
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
	["CastbarHeight"] = 20,
	["CastbarIcon"] = true,
	["Castbars"] = true,
	["CastbarWidth"] = 214,
	["DecimalLength"] = 1,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
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

-- Raidframe
C["Raid"] = {
	["AuraDebuffIconSize"] = 22,
	["AuraWatch"] = true,
	["AuraWatchIconSize"] = 7,
	["AuraWatchTexture"] = true,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["Height"] = 40,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["MaxUnitPerColumn"] = 10,
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
	},
	["HealthFormat"] = {
		["Options"] = {
			["Deficit"] = "[KkthnxUI:HealthDeficit]",
			["Percent"] = "[KkthnxUI:HealthPercent]",
		},
		["Value"] = "[KkthnxUI:HealthDeficit]"
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