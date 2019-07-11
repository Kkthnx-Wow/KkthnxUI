local K, C = unpack(select(2, ...))

local _G = _G

local DAMAGE = _G.DAMAGE
local DISABLE = _G.DISABLE
local GUILD = _G.GUILD
local GetCurrentRegion = _G.GetCurrentRegion
local HEALER = _G.HEALER
local ITEM_QUALITY2_DESC = _G.ITEM_QUALITY2_DESC
local ITEM_QUALITY3_DESC = _G.ITEM_QUALITY3_DESC
local ITEM_QUALITY4_DESC = _G.ITEM_QUALITY4_DESC
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local NONE = _G.NONE
local PLAYER = _G.PLAYER

-- Actionbar
C["ActionBar"] = {
	["Bar2Fade"] = false,
	["Bar3Fade"] = false,
	["Bar4Fade"] = false,
	["Bar5Fade"] = false,
	["ButtonSize"] = 34,
	["Cooldowns"] = true,
	["Count"] = true,
	["DecimalCD"] = true,
	["DisableStancePages"] = K.Class == "DRUID",
	["Enable"] = true,
	["EquipBorder"] = true,
	["Hotkey"] = true,
	["Macro"] = true,
	["MicroBar"] = true,
	["MicroBarMouseover"] = false,
	["OverrideWA"] = false,
	["PetFade"] = false,
	["StanceFade"] = false,
	["Style"] = {
		["Options"] = {
			["Default Style"] = 1,
			["RightBar1 on Side"] = 2,
			["RightBar1 3x4"] = 3,
			["Mainbar 3x12"] = 4,
			["Combine MainSidebars"] = 5
		},
		Value = 4
	},
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
	["AutoDisenchant"] = false,
	["AutoInvite"] = false,
	["AutoQuest"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectThank"] = false,
	["AutoReward"] = false,
	["AutoTabBinder"] = false,
	["BlockMovies"] = false,
	["DeclinePetDuel"] = false,
	["DeclinePvPDuel"] = false,
	["ScreenShot"] = false,
	["WhisperInvite"] = "inv",
}

C["Inventory"] = {
	["AutoSell"] = true,
	["BagBar"] = true,
	["BagBarMouseover"] = false,
	["BagColumns"] = 10,
	["BankColumns"] = 17,
	["BindText"] = true,
	["ButtonSize"] = 32,
	["ButtonSpace"] = 6,
	["DetailedReport"] = false,
	["Enable"] = true,
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
	["BuffSize"] = 30,
	["BuffsPerRow"] = 16,
	["DebuffSize"] = 34,
	["DebuffsPerRow"] = 16,
	["Enable"] = true,
	["Reminder"] = false,
	["ReverseBuffs"] = false,
	["ReverseDebuffs"] = false,
}

-- Chat
C["Chat"] = {
	["Background"] = false,
	["BackgroundAlpha"] = 0.25,
	["Enable"] = true,
	["Fading"] = true,
	["FadingTimeFading"] = 3,
	["FadingTimeVisible"] = 20,
	["Filter"] = true,
	["Height"] = 149,
	["QuickJoin"] = false,
	["RemoveRealmNames"] = true,
	["ScrollByX"] = 3,
	["ShortenChannelNames"] = true,
	["TabsMouseover"] = true,
	["VoiceOverlay"] = true,
	["WhisperSound"] = true,
	["Width"] = 410
}

-- DataBars
C["DataBars"] = {
	["AzeriteColor"] = {.901, .8, .601},
	["Enable"] = true,
	["ExperienceColor"] = {0, 0.4, 1, .8},
	["Height"] = 12,
	["HonorColor"] = {240/255, 114/255, 65/255},
	["MouseOver"] = false,
	["RestedColor"] = {1, 0, 1, 0.2},
	["Text"] = true,
	["TrackHonor"] = false,
	["Width"] = 180,
}

-- Datatext
C["DataText"] = {
	["Battleground"] = true,
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
	["MaxTestIcon"] = 5,
	["PvPSize"] = 60,
	["ShowTooltip"] = false,
	["TestMode"] = false,
}

-- General
C["General"] = {
	["ColorTextures"] = false,
	["DisableTutorialButtons"] = false,
	["FixGarbageCollect"] = true,
	["FontSize"] = 12,
	["LagTolerance"] = false,
	["MoveBlizzardFrames"] = false,
	["ReplaceBlizzardFonts"] = true,
	["TexturesColor"] = {0.9, 0.9, 0.9},
	["Welcome"] = true,
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
	["AutoQuality"] = {
		["Options"] = {
			["|cffA335EE"..ITEM_QUALITY4_DESC.."|r"] = 4,
			["|cff0070DD"..ITEM_QUALITY3_DESC.."|r"] = 3,
			["|cff1EFF00"..ITEM_QUALITY2_DESC.."|r"] = 2
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

C["Nameplates"] = {
	["CastHeight"] = 2,
	["Clamp"] = false,
	["ClassResource"] = true,
	["Combat"] = false,
	["Distance"] = 40,
	["Enable"] = true,
	["HealthValue"] = true,
	["Height"] = 12,
	["NazjatarFollowerXP"] = false,
	["NonTargetAlpha"] = 0.35,
	["OverlapH"] = 1.2,
	["OverlapV"] = 1.2,
	["QuestIcon"] = false,
	["SelectedScale"] = 1,
	["Smooth"] = false,
	["Threat"] = false,
	["ThreatPercent"] = false,
	["Totems"] = false,
	["TrackAuras"] = true,
	["Width"] = 140,
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
	["Details"] = false,
	["Hekili"] = false,
	["ResetDetails"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["TalkingHeadBackdrop"] = true,
	["WeakAuras"] = false,
}

-- Tooltip
C["Tooltip"] = {
	["AzeriteArmor"] = false,
	["CursorAnchor"] = false,
	["CursorAnchorX"] = 0,
	["CursorAnchorY"] = 0,
	["Enable"] = true,
	["FontOutline"] = false,
	["FontSize"] = 12,
	["GuildRanks"] = false,
	["HealthbarHeight"] = 9,
	["HealthBarText"] = true,
	["HideInCombat"] = false,
	["Icons"] = false,
	["InspectInfo"] = true,
	["ItemQualityBorder"] = true,
	["NpcID"] = false,
	["PlayerRoles"] = false,
	["PlayerTitles"] = false,
	["ShowMount"] = false,
	["SpellID"] = true,
	["TargetInfo"] = false,
}

-- Fonts
C["UIFonts"] = {
	["ActionBarsFonts"] = "KkthnxUI Outline",
	["AuraFonts"] = "KkthnxUI Outline",
	["ChatFonts"] = "KkthnxUI",
	["DataBarsFonts"] = "KkthnxUI",
	["DataTextFonts"] = "KkthnxUI",
	["FilgerFonts"] = "KkthnxUI",
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
	["CastClassColor"] = true,
	["CastReactionColor"] = true,
	["CastbarHeight"] = 20,
	["CastbarIcon"] = true,
	["CastbarLatency"] = true,
	["CastbarWidth"] = 226,
	["Castbars"] = true,
	["ClassResource"] = true,
	["CombatFade"] = false,
	["DebuffHighlight"] = true,
	["DebuffsOnTop"] = true,
	["DecimalLength"] = 1,
	["Enable"] = true,
	["GlobalCooldown"] = false,
	["HideTargetofTarget"] = false,
	["MouseoverHighlight"] = true,
	["OnlyShowPlayerDebuff"] = false,
	["PlayerBuffs"] = false,
	["PortraitTimers"] = false,
	["PowerPredictionBar"] = true,
	["ShowPortrait"] = true,
	["Smooth"] = false,
	["ThreatPercent"] = false,
	["TotemBar"] = true,
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
	},
	["PlayerHealthFormat"] = {
		["Options"] = {
			["Current"] = "[KkthnxUI:HealthCurrent]",
			["Percent"] = "[KkthnxUI:HealthPercent]",
			["Current / Percent"] = "[KkthnxUI:HealthCurrent-Percent]",
		},
		["Value"] = "[KkthnxUI:HealthCurrent]"
	},
	["TargetHealthFormat"] = {
		["Options"] = {
			["Current"] = "[KkthnxUI:HealthCurrent]",
			["Percent"] = "[KkthnxUI:HealthPercent]",
			["Current / Percent"] = "[KkthnxUI:HealthCurrent-Percent]",
		},
		["Value"] = "[KkthnxUI:HealthCurrent-Percent]"
	}
}

C["Party"] = {
	["CastbarIcon"] = true,
	["Castbars"] = false,
	["Enable"] = true,
	["MouseoverHighlight"] = true,
	["PortraitTimers"] = false,
	["ShowBuffs"] = true,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["TargetHighlight"] = false,
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
	["Smooth"] = false,
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
	["Smooth"] = false,
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
	["AuraWatchIconSize"] = 11,
	["AuraWatchTexture"] = true,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Height"] = 40,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["MaxUnitPerColumn"] = 10,
	["RaidUtility"] = true,
	["ShowGroupText"] = true,
	["ShowMouseoverHighlight"] = true,
	["ShowNotHereTimer"] = true,
	["ShowRolePrefix"] = false,
	["Smooth"] = false,
	["TargetHighlight"] = false,
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

if not IsAddOnLoaded("QuestNotifier") then
	C["QuestNotifier"] = {
		["Enable"] = IsAddOnLoaded("QuestNotifier") and false,
		["OnlyCompleteRing"] = false,
		["QuestProgress"] = false,
	}
end

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["SmallWorldMap"] = true,
	["WorldMapPlus"] = false,
}