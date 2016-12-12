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
	["Spells"] = false,
	["SpellsFromAll"] = false,
}

-- Automation
C["Automation"] = {
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
	["BagColumns"] = 10,
	["BankColumns"] = 17,
	["ButtonSize"] = 38,
	["ButtonSpace"] = 0,
	["Enable"] = true,
	["ItemLevel"] = false,
}

-- Blizzard
C["Blizzard"] = {
	["ClassColor"] = true,
	["ColorTextures"] = false,
	["ReplaceBlizzardFonts"] = true,
	["ReputationGain"] = false,
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
	["DamageMeterSpam"] = false,
	["Enable"] = true,
	["Fading"] = true,
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
}

-- Plugins
C["Plugins"] = {
	["Example"] = true,
}

-- Datatext
C["DataText"] = {
	["Location"] = true,
	["System"] = true,
	["Time"] = true,
	["Time24Hr"] = false,
	["LocalTime"] = true,
	["Battleground"] = true,
	["BottomBar"] = true,
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
	["BubbleBackdrop"] = false,
	["BubbleFontSize"] = 12,
	["CustomLagTolerance"] = false,
	["DisableTutorialButtons"] = false,
	["ShowConfigButton"] = true,
	["TranslateMessage"] = true,
	["UIScale"] = 0.71,
	["WelcomeMessage"] = true,
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
	["Ping"] = true,
	["Size"] = 150,
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
	["Errors"] = true,
	["HideTalkingHead"] = false,
	["InviteKeyword"] = "inv",
	["ItemLevel"] = true,
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
	["OffTankColor"] = {0, 0.5, 1},
	["NameAbbreviate"] = true,
	["NearColor"] = {1, 1, 0},
	["Spiral"] = true,
	["TotemIcons"] = false,
	["Timer"] = true,
	["TrackAuras"] = true,
	["Width"] = 120,
}

-- PulseCD
C["PulseCD"] = {
	["Enable"] = false,
	["Size"] = 75,
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
	["ItemLevel"] = false,
	["SpellID"] = false,
	["Talents"] = false,
}

-- Unitframe
C["Unitframe"] = {
	["Castbars"] = true,
	["CastbarSafeZoneColor"] = {.8, 0.4, 0},
	["ClassColor"] = true,
	["ClassPortraits"] = false,
	["CombatText"] = true,
	["Enable"] = true,
	["FlatClassPortraits"] = false,
	["FocusCastbarHeight"] = 20,
	["FocusCastbarWidth"] = 180,
	["GCDBar"] = false,
	["IconPlayer"] = "NONE",
	["IconTarget"] = "NONE",
	["Party"] = true,
	["PlayerCastbarHeight"] = 18,
	["PlayerCastbarWidth"] = 200,
	["PlayerDebuffsOnly"] = true,
	["PortraitTimer"] = true,
	["PowerPredictionBar"] = true,
	["Scale"] = 1,
	["ShowArena"] = true,
	["ShowBoss"] = true,
	["ShowPlayer"] = true,
	["Style"] = "fat",
	["SwingBar"] = false,
	["TargetCastbarHeight"] = 18,
	["TargetCastbarWidth"] = 200,
	["TextHealthColor"] = {.9, .9, .9},
	["TextNameColor"] = {1, 0.82, 0},
	["TextPowerColor"] = {.9, .9, .9},
	["ThreatGlow"] = true,
	["ThreatValue"] = false,
}

C["Partyframe"] = { -- Could add this as its own in the future.
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
	["RaidAsParty"] = false,
	["Scale"] = 1,
	["ShowMouseoverHighlight"] = true,
	["ShowNotHereTimer"] = true,
	["ShowResurrectText"] = true,
	["ShowRolePrefix"] = false,
	["ShowThreatText"] = false,
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