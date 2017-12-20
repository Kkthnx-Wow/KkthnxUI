local _G = _G

local K, C = _G.unpack(_G.select(2, ...))

C["Developer"] = {
	["Debug"] = false,
}

-- Actionbar
C["ActionBar"] = {
	["AddNewSpells"] = true,
	["BottomBars"] = 2,
	["ButtonSize"] = 34,
	["ButtonSpace"] = 6,
	["Enable"] = true,
	["EquipBorder"] = false,
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
	["RightBarsMouseover"] = true,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["StanceBarMouseover"] = true,
	["ToggleMode"] = true,
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
	["AutoCollapse"] = true,
	["AutoInvite"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectCombat"] = true,
	["AutoResurrectThank"] = false,
	["DeclinePetDuel"] = false,
	["DeclinePvPDuel"] = false,
	["ScreenShot"] = false,
}

C["Bags"] = {
	["BagColumns"] = 10,
	["BankColumns"] = 17,
	["ButtonSize"] = 27,
	["ButtonSpace"] = 3,
	["Enable"] = true,
	["ItemLevel"] = false,
}

-- Buffs & Debuffs
C["Auras"] = {
	["Enable"] = true,
	["ButtonSize"] = 30,
	["ButtonSpace"] = 6,
	["ButtonPerRow"] = 12,
}

-- Chat
C["Chat"] = {
	["Enable"] = true,
	["Fading"] = true,
	["WhisperSound"] = true,
	["FadingTimeFading"] = 3,
	["FadingTimeVisible"] = 20,
	["Height"] = 140,
	["LinkBrackets"] = true,
	["LinkColor"] = {0.08, 1, 0.36},
	["MessageFilter"] = false,
	["Font"] = "KkthnxUI",
	["ScrollByX"] = 3,
	["SpamFilter"] = false,
	["TabsMouseover"] = true,
	["TabsOutline"] = false,
	["Width"] = 400,
	["BubbleBackdrop"] = {
		["Options"] = {
			["Show Backdrop"] = "Backdrop",
			["Hide Backdrop"] = "NoBackdrop",
			["Disabled"] = "Disabled",
		},
		["Value"] = "Backdrop",
	},
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
	-- Artifact
	-- ["ArtifactColor"] = {.901, .8, .601},
	["ArtifactEnable"] = true,
	-- ["ArtifactFade"] = false,
	["ArtifactHeight"] = 12,
	["ArtifactWidth"] = 164,
	-- Experience
	-- ["ExperienceColor"] = {0, 0.4, 1, .8},
	["ExperienceEnable"] = true,
	-- ["ExperienceFade"] = false,
	["ExperienceHeight"] = 12,
	-- ["ExperienceRestedColor"] = {1, 0, 1, 0.2},
	["ExperienceWidth"] = 164,
	-- Honor
	-- ["HonorColor"] = {240/255, 114/255, 65/255},
	["HonorEnable"] = true,
	-- ["HonorFade"] = false,
	["HonorHeight"] = 12,
	["HonorWidth"] = 164,
	-- Reputation
	["ReputationEnable"] = true,
	-- ["ReputationFade"] = false,
	["ReputationHeight"] = 12,
	["ReputationWidth"] = 164,
	-- Info text for all bars
	-- ["InfoText"] = false,
	["Outline"] = false,
	["Texture"] = "KkthnxUI",
}

-- Datatext
C["DataText"] = {
	["Battleground"] = true,
	["LocalTime"] = true,
	["Outline"] = false,
	["System"] = true,
	["Time24Hr"] = false,
}

-- Errors
C["Error"] = {
	["Black"] = true,
	["Combat"] = false,
	["White"] = false,
}

-- General
C["General"] = {
	["AutoScale"] = true,
	["BubbleFontSize"] = 12,
	["ColorTextures"] = false,
	["ConfigButton"] = true,
	["DisableTutorialButtons"] = false,
	["Font"] = "KkthnxUI",
	["FontSize"] = 12,
	["ReplaceBlizzardFonts"] = true,
	["SpellTolerance"] = false,
	["TaintLog"] = false,
	["TalkingHeadWidth"] = 570,
	["TalkingHeadHeight"] = 155,
	["Texture"] = "KkthnxUI",
	["TexturesColor"] = {0.31, 0.31, 0.31},
	["ToggleButton"] = true,
	["UIScale"] = 0.71111111111111,
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Metric"] = "METRIC",
			["Chinese"] = "CHINESE",
			["Korean"] = "KOREAN",
			["German"] = "GERMAN",
			["Default"] = "DEFAULT",
		},
		["Value"] = "Default",
	},
}

-- Loot
C["Loot"] = {
	["AutoRoll"] = false,
	["Enable"] = true,
	["GroupLoot"] = true,
	["Texture"] = "KkthnxUI",
}

-- Minimap
C["Minimap"] = {
	["Calendar"] = true,
	["CollectButtons"] = true,
	["Enable"] = true,
	["InstanceOnlyNumber"] = false,
	["ResetZoom"] = false,
	["ResetZoomTime"] = 4,
	["Size"] = 170,
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["AutoRepair"] = true,
	["AutoReward"] = false,
	["AutoSell"] = true,
	["BattlegroundSpam"] = false,
	["ColorPicker"] = false,
	["EnhancedPvpMessages"] = false,
	["ItemLevel"] = false,
	["KillingBlow"] = false,
	["NoBanner"] = false,
	["PvPEmote"] = false,
	["SlotDurability"] = false,
	["UseGuildRepairFunds"] = false,
}

-- Nameplates
C["Nameplates"] = {
	["AurasSize"] = 26,
	["BadColor"] = {1, 0, 0},
	["CastbarName"] = true,
	["CastUnitReaction"] = true,
	["Clamp"] = false,
	["Distance"] = 40,
	["Enable"] = true,
	["EnhancedThreat"] = false,
	["FontSize"] = 13,
	["GoodColor"] = {0.2, 0.8, 0.2},
	["HealerIcon"] = false,
	["HealthValue"] = true,
	["Height"] = 18,
	["NameAbbreviate"] = true,
	["NearColor"] = {1, 1, 0},
	["OffTankColor"] = {0, 0.5, 1},
	["Outline"] = false,
	["SelectedScale"] = 1.180,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
	["TotemIcons"] = false,
	["TrackAuras"] = true,
	["Width"] = 140,
}

-- Skins
C["Skins"] = {
	["Bagnon"] = false,
	["BigWigs"] = false,
	["DBM"] = false,
	["Recount"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["WeakAuras"] = false,
	["Texture"] = "KkthnxUI",
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
	["Enable"] = true,
	["Font"] = "KkthnxUI",
	["FontSize"] = 13,
	["GCDBar"] = false,
	["OORAlpha"] = 0.40,
	["Outline"] = false,
	["Party"] = true,
	["PortraitTimer"] = true,
	["PowerPredictionBar"] = true,
	["Scale"] = 1,
	["ShowArena"] = true,
	["ShowBoss"] = true,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
	-- Portrait Styles 3
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits",
		},
		["Value"] = "DefaultPortraits",
	},
}

-- We keep this private. For now.
C["UnitframePlugins"] = {
	["OORAlpha"] = 0.60,
}

-- Raidframe
C["Raidframe"] = {
	["AuraWatch"] = true,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Height"] = 40,
	["IconSize"] = 22,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["MaxUnitPerColumn"] = 10,
	["Outline"] = false,
	["RaidAsParty"] = false,
	["RaidTools"] = true,
	["RaidUtility"] = true,
	["Scale"] = 1,
	["Scale"] = 1,
	["ShowMouseoverHighlight"] = true,
	["ShowNotHereTimer"] = true,
	["ShowRolePrefix"] = false,
	["Smooth"] = false,
	["SmoothSpeed"] = 3,
	["Texture"] = "KkthnxUI",
	["Width"] = 56,
}

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["SmallWorldMap"] = true,
}