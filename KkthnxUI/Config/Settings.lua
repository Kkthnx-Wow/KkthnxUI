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
	["OutOfMana"] = {25/255, 77/255, 255/255, 1},
	["OutOfRange"] = {204/255, 26/255, 26/255, 1},
	["PetBarHide"] = false,
	["PetBarHorizontal"] = false,
	["PetBarMouseover"] = false,
	["RightBars"] = 2,
	["RightBarsMouseover"] = true,
	["SelfCast"] = false,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["StanceBarMouseover"] = true,
	["ToggleMode"] = true,
}

-- Announcements
C["Announcements"] = {
	["BadGear"] = false,
	["Interrupt"] = false,
	["PullCountdown"] = true,
	["SaySapped"] = false,
	["SayThanks"] = false,
	["Spells"] = false,
	["SpellsFromAll"] = false,
}

-- Automation
C["Automation"] = {
	["AcceptQuest"] = false,
	["AutoCollapse"] = true,
	["AutoInvite"] = false,
	["DeclineDuel"] = false,
	["LoggingCombat"] = false,
	["Resurrection"] = false,
	["ScreenShot"] = false,
	["TabBinder"] = false,
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
	["ClassColor"] = true,
	["ColorTextures"] = false,
	["HideTalkingHead"] = false,
	["RaidTools"] = true,
	["ReplaceBlizzardFonts"] = true,
	["ReputationGain"] = false,
	["TalkingHeadScale"] = 1,
	["TexturesColor"] = {K.Color.r, K.Color.g, K.Color.b},
	["VehicleMouseover"] = false,
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
	["Background"] = false,
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
	["ArtifactColor"] = {229/255, 204/255, 127/255},
	["ArtifactEnable"] = true,
	["ArtifactFade"] = false,
	["ArtifactHeight"] = 8,
	["ArtifactWidth"] = 142,
	-- Experience
	["ExperienceColor"] = {0/255, 144/255, 255/255},
	["ExperienceEnable"] = true,
	["ExperienceFade"] = false,
	["ExperienceHeight"] = 8,
	["ExperienceRestedColor"] = {75/255, 175/255, 76/255},
	["ExperienceWidth"] = 142,
	-- Honor
	["HonorColor"] = {222/255, 22/255, 22/255},
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

-- Filger
C["Filger"] = {
	["BuffsSize"] = 37,
	["CooldownSize"] = 30,
	["DisableCD"] = true,
	["Enable"] = true,
	["MaxTestIcon"] = 5,
	["PvPSize"] = 60,
	["ShowTooltip"] = false,
	["TestMode"] = false,
}

-- General
C["General"] = {
	["AutoScale"] = true,
	["BubbleFontSize"] = 12,
	["CustomLagTolerance"] = false,
	["DisableTutorialButtons"] = false,
	["UseFlatTextures"] = false,
	["TranslateMessage"] = true,
	["UIScale"] = 0.71,
	["UseBlizzardFonts"] = false,
	["WelcomeMessage"] = true,
	["ToggleButton"] = true,
}

-- Loot
C["Loot"] = {
	["ConfirmDisenchant"] = false,
	["AutoGreed"] = false,
	["LootFilter"] = true,
	["IconSize"] = 30,
	["Enable"] = true,
	["GroupLoot"] = true,
	["Width"] = 222,
}

-- Minimap
C["Minimap"] = {
	["CollectButtons"] = true,
	["Enable"] = true,
	["FadeButtons"] = true,
	["Garrison"] = true,
	["Calendar"] = true,
	["Ping"] = true,
	["Size"] = 150,
	["ShowConfigButton"] = true,
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["AlreadyKnown"] = false,
	["Armory"] = false,
	["AutoRepair"] = true,
	["AutoSellGrays"] = true,
	["BGSpam"] = false,
	["ColorPicker"] = false,
	["EnhancedMail"] = true,
	["InviteKeyword"] = "inv",
	["ItemLevel"] = false,
	["MerchantItemLevel"] = false,
	["MoveBlizzard"] = false,
	["NoBanner"] = false,
	["SellMisc"] = true,
	["SlotDurability"] = false,
	["UseGuildRepair"] = false,
}

-- Nameplates
C["Nameplates"] = {
	["AdditionalHeight"] = 0,
	["AdditionalWidth"] = 0,
	["AurasSize"] = 26,
	["BadColor"] = {1, 0, 0},
	["CastbarName"] = false,
	["CastUnitReaction"] = false,
	["Clamp"] = false,
	["ClassIcons"] = false,
	["Combat"] = false,
	["Distance"] = 40,
	["Enable"] = true,
	["EnhancedThreat"] = true,
	["GoodColor"] = {0.2, 0.8, 0.2},
	["HealerIcon"] = false,
	["HealthValue"] = true,
	["Height"] = 11,
	["NameAbbreviate"] = true,
	["NearColor"] = {1, 1, 0},
	["OffTankColor"] = {0, 0.5, 1},
	["Smooth"] = false,
	["Spiral"] = true,
	["Timer"] = true,
	["TotemIcons"] = false,
	["TrackAuras"] = true,
	["Width"] = 120,
}

-- PulseCD
C["PulseCD"] = {
	["Enable"] = false,
	["Size"] = 76,
	["Sound"] = false,
	["AnimationScale"] = 1.5,
	["HoldTime"] = 0,
	["Threshold"] = 3,
}

C["RaidCD"] = {
	["Enable"] = true,
	["Height"] = 15,
	["Width"] = 186,
	["UpWards"] = false,
	["Expiration"] = false,
	["ShowSelf"] = true,
	["ShowIcon"] = true,
	["ShowInRaid"] = true,
	["ShowInParty"] = true,
	["ShowInArena"] = true,
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
	["HyperLink"] = false,
	["InstanceLock"] = false,
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
	["ClassColor"] = true,
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
	["SwingBar"] = false,
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
	["AuraWatchTimers"] = true,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Height"] = 40,
	["HorizontalHealthBars"] = false,
	["IconSize"] = 22,
	["IndicatorSize"] = 7,
	["MainTankFrames"] = true,
	["ManabarHorizontal"] = false,
	["ManabarShow"] = true,
	["MaxUnitPerColumn"] = 10,
	["PvPDebuffs"] = false,
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
	["FogOfWar"] = false,
}