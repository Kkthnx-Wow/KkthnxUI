local K, C, L = select(2, ...):unpack()

-- ACTIONBAR OPTIONS
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
	["SelfCast"] = false,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["StanceBarMouseover"] = true,
	["ToggleMode"] = true,
}
-- ANNOUNCEMENTS OPTIONS
C["Announcements"] = {
	["BadGear"] = false,
	["Interrupt"] = false,
	["PullCountdown"] = true,
	["SaySapped"] = false,
	["Spells"] = false,
	["SpellsFromAll"] = false,
}
-- AUTOMATION OPTIONS
C["Automation"] = {
	["AutoCollapse"] = true,
	["AutoInvite"] = false,
	["DeclineDuel"] = false,
	["LoggingCombat"] = false,
	["Resurrection"] = false,
	["ScreenShot"] = false,
	["TabBinder"] = false,
}
-- BAG OPTIONS
C["Bags"] = {
	["Enable"] = true,
	["ButtonSize"] = 32,
	["Spacing"] = 4,
	["ItemsPerRow"] = 11,
	["PulseNewItem"] = true,
	["BagFilter"] = false,
}
-- BLIZZARD OPTIONS
C["Blizzard"] = {
	["ClassColor"] = true,
	["ColorTextures"] = false,
	["EasyDelete"] = false,
	["ReplaceBlizzardFonts"] = true,
	["ReputationGain"] = false,
	["TexturesColor"] = {K.Color.r, K.Color.g, K.Color.b, 1},
	["VehicleMouseover"] = false,
}
-- BUFFS & DEBUFFS OPTIONS
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
-- CHAT OPTIONS
C["Chat"] = {
	["DamageMeterSpam"] = false,
	["Enable"] = true,
	["Fading"] = true,
	["Filter"] = true,
	["Height"] = 150,
	["LinkBrackets"] = true,
	["LinkColor"] = {0.08, 1, 0.36},
	["Outline"] = false,
	["ScrollByX"] = 3,
	["Spam"] = false,
	["TabsMouseover"] = true,
	["TabsOutline"] = false,
	["WhispSound"] = true,
	["Width"] = 370,
}
-- COOLDOWN OPTIONS
C["Cooldown"] = {
	["Enable"] = true,
	["FontSize"] = 18,
	["Threshold"] = 3,
}
-- Plugins
-- C["Plguins"] = {
-- 	 ["Example"] = true,
-- }
-- Datatext
C["DataText"] = {
	["Location"] = true,
	["System"] = true,
	["Time"] = true,
	["Time24Hr"] = false,
	["LocalTime"] = true,
	["Battleground"] = true,
}
-- FILGER OPTIONS
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
-- GENERAL OPTIONS
C["General"] = {
	["AutoScale"] = true,
	["BubbleBackdrop"] = false,
	["BubbleFontSize"] = 12,
	["CustomLagTolerance"] = false,
	["TranslateMessage"] = true,
	["UIScale"] = 0.71,
	["WelcomeMessage"] = true,
}
-- LOOT OPTIONS
C["Loot"] = {
	["ConfirmDisenchant"] = false,
	["AutoGreed"] = false,
	["LootFilter"] = true,
	["IconSize"] = 30,
	["Enable"] = true,
	["GroupLoot"] = true,
	["Width"] = 222,
}
-- MINIMAP OPTIONS
C["Minimap"] = {
	["CollectButtons"] = true,
	["Enable"] = true,
	["Garrison"] = true,
	["Ping"] = true,
	["Size"] = 150,
}
-- MISCELLANEOUS OPTIONS
C["Misc"] = {
	["AFKCamera"] = false,
	["AlreadyKnown"] = false,
	["Armory"] = false,
	["AutoRepair"] = true,
	["AutoSellGrays"] = true,
	["BGSpam"] = false,
	["ColorPicker"] = false,
	["DurabilityWarninig"] = false,
	["EnhancedMail"] = true,
	["Errors"] = true,
	["InviteKeyword"] = "inv",
	["ItemLevel"] = true,
	["MoveBlizzard"] = false,
	["SellMisc"] = true,
	["SlotDurability"] = false,
	["UseGuildRepair"] = false,
}
C["Nameplates"] = {
	["Enable"] = true,
	["Height"] = 11,
	["Width"] = 120,
	["AdditionalHeight"] = 0,
	["AdditionalWidth"] = 0,
	["Combat"] = false,
	["HealthValue"] = true,
	["CastbarName"] = false,
	["EnhancedThreat"] = true,
	["ClassIcons"] = false,
	["NameAbbreviate"] = true,
	["GoodColor"] = {0.2, 0.8, 0.2},
	["NearColor"] = {1, 1, 0},
	["BadColor"] = {1, 0, 0},
	["TrackAuras"] = true,
	["AurasSize"] = 18,
	["HealerIcon"] = false,
}
-- PULSECD OPTIONS
C["PulseCD"] = {
	["Enable"] = false,
	["Size"] = 75,
	["Sound"] = false,
	["AnimationScale"] = 1.5,
	["HoldTime"] = 0,
	["Threshold"] = 3,
}
-- SKINS OPTIONS
C["Skins"] = {
	["CLCRet"] = false,
	["ChatBubble"] = true,
	["DBM"] = false,
	["DBMMove"] = false,
	["MinimapButtons"] = true,
	["Recount"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["WeakAuras"] = false,
}
-- TOOLTIP OPTIONS
C["Tooltip"] = {
	["Achievements"] = false,
	["Cursor"] = false,
	["Enable"] = true,
	["HealthValue"] = true,
	["HyperLink"] = false,
	["InstanceLock"] = false,
	["ItemCount"] = false,
	["ItemIcon"] = false,
	["ShowSpec"] = true,
	["SpellID"] = false,
}
-- UNITFRAME OPTIONS
C["Unitframe"] = {
	["BuilderSpender"] = true,
	["CastbarSafeZoneColor"] = {.8, 0.4, 0, 1},
	["Castbars"] = true,
	["ClassColor"] = true,
	["ClassPortraits"] = false,
	["ClickThrough"] = false,
	["CombatText"] = true,
	["Enable"] = true,
	["FlatClassPortraits"] = false,
	["FocusButton"] = "2",
	["FocusCastbarHeight"] = 20,
	["FocusCastbarWidth"] = 180,
	["FocusModifier"] = "NONE",
	["Party"] = true,
	-- ["PartyInRaid"] = false, -- So shit.
	["PlayerCastbarHeight"] = 18,
	["PlayerCastbarWidth"] = 200,
	["PlayerDebuffsOnly"] = true,
	["PortraitTimer"] = true,
	["PowerPredictionBar"] = true,
	["PowerUseAtlas"] = true,
	["Scale"] = 1,
	["ShowArena"] = true,
	["ShowBoss"] = true,
	["Style"] = "fat",
	["TargetCastbarHeight"] = 18,
	["TargetCastbarWidth"] = 200,
	["TextHealthColor"] = {.9, .9, .9},
	["TextNameColor"] = {1, 0.82, 0, 1},
	["TextPowerColor"] = {.9, .9, .9},
	["ThreatGlow"] = true,
	["ThreatValue"] = false,
	-- Plugins
	["ArtifactBar"] = true,
	["ExperienceBar"] = true,
	["ReputationBar"] = true,
}
C["Partyframe"] = { -- Could add this as its own in the future.
	["PartyInRaid"] = false,
	["Enable"] = true,
	["Scale"] = 1,
}
-- Raidframe Options
C["Raidframe"] = {
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Height"] = 40,
	["HorizontalHealthBars"] = false,
	["IconSize"] = 22,
	["IndicatorSize"] = 7,
	["MainTankFrames"] = true,
	["ManabarHorizontal"] = false,
	["ManabarShow"] = true,
	["MaxUnitPerColumn"] = 8,
	["Scale"] = 1,
	["ShowMouseoverHighlight"] = true,
	["ShowNotHereTimer"] = true,
	["ShowResurrectText"] = true,
	["ShowRolePrefix"] = false,
	["ShowThreatText"] = false,
	["RaidAsParty"] = false,
	["Width"] = 42,
}
-- WORLDMAP OPTIONS
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["SmallWorldMap"] = true,
	["FogOfWar"] = false,
}
