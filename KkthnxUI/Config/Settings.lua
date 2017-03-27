local K, C, L = unpack(select(2, ...))

-- Actionbar
C["ActionBar"] = {
	["BottomBars"] = 3,
	["ButtonSize"] = 36,
	["ButtonSpace"] = 4,
	["Enable"] = true,
	["EquipBorder"] = false,
	["Grid"] = true,
	["HideHighlight"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["OutOfMana"] = {25/255, 77/255, 255/255},
	["OutOfRange"] = {204/255, 26/255, 26/255},
	["PetBarHide"] = false,
	["PetBarHorizontal"] = false,
	["PetBarMouseover"] = false,
	["RightBars"] = 2,
	["RightBarsMouseover"] = true,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["StanceBarMouseover"] = true,
	["ToggleMode"] = true,
}

-- Announcements
C["Announcements"] = {
	["Interrupt"] = false,
	["PullCountdown"] = true,
	["SaySapped"] = false,
}

-- Automation
C["Automation"] = {
	["AutoCollapse"] = true,
	["AutoInvite"] = false,
	["DeclineDuel"] = false,
	["Resurrection"] = false,
	["ScreenShot"] = false,
}

-- Bag
C["Bags"] = {
	["ButtonSize"] = 32,
	["Enable"] = true,
	["InsertLeftToRight"] = true,
	["ItemsPerRow"] = 11,
	["SortRightToLeft"] = false,
	["Spacing"] = 4,
}

-- Blizzard
C["Blizzard"] = {
	["ColorTextures"] = false,
	["RaidTools"] = true,
	["ReplaceBlizzardFonts"] = true,
	["ReputationGain"] = false,
	["TalkingHeadScale"] = 1,
	["TexturesColor"] = {0.31, 0.31, 0.31},
}

-- Buffs & Debuffs
C["Auras"] = {
	["Enable"] = true,
	["Consolidate"] = false,
	["Flash"] = false,
	["HideBuffs"] = false,
	["HideDebuffs"] = false,
	["Animation"] = false,
	["BuffsPerRow"] = 12,
	["CastBy"] = false,
}

-- Chat
C["Chat"] = {
	["BubbleBackdrop"] = false,
	["DamageMeterSpam"] = false,
	["Enable"] = true,
	["Fading"] = true,
	["FadingTimeFading"] = 3,
	["FadingTimeVisible"] = 20,
	["Height"] = 150,
	["LinkBrackets"] = true,
	["LinkColor"] = {0.08, 1, 0.36},
	["MessageFilter"] = false,
	["Outline"] = false,
	["ScrollByX"] = 3,
	["SpamFilter"] = false,
	["TabsMouseover"] = true,
	["TabsOutline"] = false,
	["WhispSound"] = true,
	["Width"] = 370,
}

-- Cooldown
C["Cooldown"] = {
	["Enable"] = true,
	["FontSize"] = 18,
	["Threshold"] = 3,
}

-- DataBars
C["DataBars"] = {
	-- Artifact
	["ArtifactColor"] = {230/255, 204/255, 128/255},
	["ArtifactEnable"] = true,
	["ArtifactFade"] = false,
	["ArtifactHeight"] = 8,
	["ArtifactWidth"] = 142,
	-- Experience
	["ExperienceColor"] = {23/255, 152/255, 251/255},
	["ExperienceEnable"] = true,
	["ExperienceFade"] = false,
	["ExperienceHeight"] = 8,
	["ExperienceRestedColor"] = {46/255, 172/255, 52/255},
	["ExperienceWidth"] = 142,
	-- Honor
	["HonorColor"] = {220/255, 68/255, 54/255},
	["HonorEnable"] = true,
	["HonorFade"] = false,
	["HonorHeight"] = 8,
	["HonorWidth"] = 142,
	-- Reputation
	["ReputationEnable"] = true,
	["ReputationFade"] = false,
	["ReputationHeight"] = 8,
	["ReputationWidth"] = 142,
	-- Info text for all bars
	["InfoText"] = false,
}

-- Datatext
C["DataText"] = {
	["Battleground"] = true,
	["LocalTime"] = true,
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
	["DisableTutorialButtons"] = false,
	["TaintLog"] = false,
	["ToggleButton"] = true,
	["UIScale"] = 0.71,
	["UseBlizzardFonts"] = false,
	["UseFlatTextures"] = false,
	["WelcomeMessage"] = true,
}

-- Loot
C["Loot"] = {
	["ConfirmDisenchant"] = false,
	["AutoGreed"] = false,
	["IconSize"] = 30,
	["Enable"] = true,
	["GroupLoot"] = true,
	["Width"] = 222,
}

-- Minimap
C["Minimap"] = {
	["Calendar"] = true,
	["CollectButtons"] = true,
	["Enable"] = true,
	["FadeButtons"] = true,
	["Garrison"] = true,
	["ResetZoom"] = false,
	["ResetZoomTime"] = 3,
	["Size"] = 150,
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["AutoRepair"] = true,
	["AutoSellGrays"] = true,
	["BGSpam"] = false,
	["ColorPicker"] = false,
	["CombatState"] = false,
	["EnhancedPvpMessages"] = false,
	["InviteKeyword"] = "inv",
	["ItemLevel"] = false,
	["NoBanner"] = false,
	["PvPEmote"] = false,
	["SellMisc"] = true,
	["SlotDurability"] = false,
	["UseGuildRepair"] = false,
}

-- Nameplates
C["Nameplates"] = {
	["AdditionalSize"] = 0,
	["AurasSize"] = 26,
	["BadColor"] = {1, 0, 0},
	["CastbarName"] = true,
	["CastUnitReaction"] = false,
	["Clamp"] = false,
	["Distance"] = 40,
	["Enable"] = true,
	["EnhancedThreat"] = true,
	["GoodColor"] = {0.2, 0.8, 0.2},
	["HealerIcon"] = false,
	["HealthValue"] = true,
	["Height"] = 16,
	["NameAbbreviate"] = true,
	["NearColor"] = {1, 1, 0},
	["OffTankColor"] = {0, 0.5, 1},
	["Smooth"] = false,
	["TotemIcons"] = false,
	["TrackAuras"] = true,
	["Width"] = 130,
}

-- Skins
C["Skins"] = {
	["BigWigs"] = false,
	["ChatBubble"] = true,
	["DBM"] = false,
	["DBMMove"] = false,
	["MinimapButtons"] = true,
	["Recount"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["WeakAuras"] = false,
}

-- Tooltip
C["Tooltip"] = {
	["Achievements"] = false,
	["Cursor"] = false,
	["Enable"] = true,
	["HealthValue"] = true,
	["ItemCount"] = false,
	["ItemIcon"] = false,
	["Rank"] = true,
	["SpellID"] = false,
	["Talents"] = false,
}

-- Unitframe
C["Unitframe"] = {
	["CastbarHeight"] = 18,
	["CastbarIcon"] = false,
	["CastbarLatency"] = true,
	["Castbars"] = true,
	["CastbarTicks"] = false,
	["CastbarWidth"] = 200,
	["CastClassColor"] = false,
	["CastUnitReaction"] = false,
	["ColorHealth"] = false,
	["ClassPortraits"] = false,
	["CombatText"] = true,
	["Enable"] = true,
	["GCDBar"] = false,
	["Party"] = true,
	["PlayerDebuffsOnly"] = true,
	["PortraitTimer"] = true,
	["PowerPredictionBar"] = true,
	["Scale"] = 1,
	["ShowArena"] = true,
	["ShowBoss"] = true,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["Style"] = "fat",
	["ThreatGlow"] = true,
	["ThreatValue"] = false,
}

C["UnitframePlugins"] = {
	["AdditionalPower"] = true,
	["ArcaneCharges"] = true,
	["HarmonyBar"] = true,
	["HolyPowerBar"] = true,
	["InsanityBar"] = true,
	["RuneFrame"] = true,
	["ShardsBar"] = true,
	["StaggerBar"] = true,
	["TotemsFrame"] = true,
	["OORAlpha"] = 0.60,
	-- Unitframe Text
	["player"] = {
		["HealthTag"] = "NUMERIC",
		["PowerTag"] = "PERCENT",
	},
	["pet"] = {
		["HealthTag"] = "MINIMAL",
		["PowerTag"] = "DISABLE",
	},
	["target"] = {
		["HealthTag"] = "BOTH",
		["PowerTag"] = "PERCENT",
		["buffPos"] = "BOTTOM",
		["debuffPos"] = "TOP",
	},
	["targettarget"] = {
		["enableAura"] = false,
		["HealthTag"] = "DISABLE",
	},
	["focus"] = {
		["HealthTag"] = "BOTH",
		["PowerTag"] = "PERCENT",
		["buffPos"] = "NONE",
		["debuffPos"] = "BOTTOM",
	},
	["focustarget"] = {
		["enableAura"] = false,
		["HealthTag"] = "DISABLE",
	},
	["party"] = {
		["HealthTag"] = "MINIMAL",
		["PowerTag"] = "DISABLE",
	},
	["boss"] = {
		["HealthTag"] = "PERCENT",
		["PowerTag"] = "PERCENT",
	},
	["arena"] = {
		["HealthTag"] = "BOTH",
		["PowerTag"] = "PERCENT",
	},
}

C["Partyframe"] = {
	["Scale"] = 1,
	["Enable"] = true,
	["ShowPlayer"] = true,
	["RaidAsParty"] = false,
}

-- Raidframe
C["Raidframe"] = {
	["AuraWatch"] = true,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Height"] = 40,
	["IconSize"] = 22,
	["MainTankFrames"] = true,
	["ManabarShow"] = true,
	["MaxUnitPerColumn"] = 10,
	["RaidAsParty"] = false,
	["Scale"] = 1,
	["ShowMouseoverHighlight"] = true,
	["ShowNotHereTimer"] = true,
	["ShowResurrectText"] = true,
	["ShowRolePrefix"] = false,
	["ShowThreatText"] = false,
	["Smooth"] = false,
	["Width"] = 56,
}

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["SmallWorldMap"] = true,
}