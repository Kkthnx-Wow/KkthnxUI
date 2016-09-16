local K, C, L, _ = select(2, ...):unpack()

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
	["OutOfMana"] = {0.1, 0.3, 1.0, 1},
	["OutOfRange"] = {0.8, 0.1, 0.1, 1},
	["PetBarHide"] = false,
	["PetBarHorizontal"] = false,
	["RightBars"] = 2,
	["SelfCast"] = false,
	["SplitBars"] = false,
	["StanceBarHide"] = false,
	["StanceBarHorizontal"] = true,
	["ToggleMode"] = true,
}
-- ANNOUNCEMENTS OPTIONS
C["Announcements"] = {
	["BadGear"] = false,
	["Feasts"] = false,
	["Interrupt"] = false,
	["Portals"] = false,
	["PullCountdown"] = true,
	["SaySapped"] = false,
	["Spells"] = false,
	["SpellsFromAll"] = false,
	["Toys"] = false,
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
C["Bag"] = {
	["BagColumns"] = 10,
	["BankColumns"] = 17,
	["ButtonSize"] = 38,
	["ButtonSpace"] = 0,
	["Enable"] = true,
	["ItemLevel"] = true,
}
-- BLIZZARD OPTIONS
C["Blizzard"] = {
	["Capturebar"] = true,
	["ClassColor"] = true,
	["ColorTextures"] = false,
	["TexturesColor"] = {K.Color.r, K.Color.g, K.Color.b, 1},
	["Durability"] = true,
	["MoveAchievements"] = true,
	["Reputations"] = true,
}
-- STATS OPTIONS
C["Stats"] = {
	["Battleground"] = true,
	["System"] = true,
	["Location"] = true,
}
-- BUFFS & DEBUFFS OPTIONS
C["Aura"] = {
	["BuffSize"] = 36,
	["CastBy"] = false,
	["ClassColorBorder"] = false,
	["Enable"] = true,
	["Timer"] = true,
}
-- CHAT OPTIONS
C["Chat"] = {
	["CombatLog"] = true,
	["DamageMeterSpam"] = false,
	["Enable"] = true,
	["Filter"] = true,
	["Height"] = 150,
	["LinkBrackets"] = true,
	["LinkColor"] = {0.08, 1, 0.36},
	["Outline"] = false,
	["ScrollByX"] = 3,
	["Spam"] = false,
	["Sticky"] = true,
	["TabsMouseover"] = true,
	["TabsOutline"] = false,
	["TimeColor"] = {1, 1, 0},
	["WhispSound"] = true,
	["Width"] = 400,
}
-- COOLDOWN OPTIONS
C["Cooldown"] = {
	["Enable"] = true,
	["FontSize"] = 18,
	["Threshold"] = 3,
}
-- ERROR OPTIONS
C["Error"] = {
	["Black"] = true,
	["White"] = false,
	["Combat"] = false,
}
-- EXPERIENCE / REPUTATION / ARTIFACT OPTIONS
C["Experience"] = {
	["XP"] = true,
	["Artifact"] = true,
	["XPHeight"] = 8,
	["XPWidth"] = 142,
	["ArtifactHeight"] = 8,
	["ArtifactWidth"] = 142,
	["XPClassColor"] = false,
}
-- FILGER OPTIONS
C["Filger"] = {
	["BuffsSize"] = 37,
	["CooldownSize"] = 30,
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
	["ReplaceBlizzardFonts"] = true,
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
	["Ping"] = true,
	["Size"] = 150,
	["Invert"] = false,
}
-- MISCELLANEOUS OPTIONS
C["Misc"] = {
	["AFKCamera"] = false,
	["AlreadyKnown"] = false,
	["Armory"] = false,
	["AutoRepair"] = true,
	["AutoSellGrays"] = true,
	["BGSpam"] = false,
	["DurabilityWarninig"] = false,
	["EnhancedMail"] = true,
	["InviteKeyword"] = "inv",
	["ItemLevel"] = false,
	["ColorPicker"] = false,
	["MoveBlizzard"] = false,
	["SellMisc"] = true,
	["UseGuildRepair"] = false,
}
C["Nameplate"] = {
	["Enable"] = true,
	["Width"] = 110,
	["Height"] = 6,
	["CastHeight"] = 4,
	-- ["AbbreviateLongNames"] = true,
	["ShowRealmName"] = false,
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
	["Spy"] = false,
	["ChatBubble"] = true,
	["CLCRet"] = false,
	["DBM"] = false,
	["MinimapButtons"] = true,
	["Recount"] = false,
	["Skada"] = false,
	["WeakAuras"] = false,
}
-- TOOLTIP OPTIONS
C["Tooltip"] = {
	["Achievements"] = false,
	["ArenaExperience"] = false,
	["Cursor"] = false,
	["Enable"] = true,
	["HealthValue"] = true,
	["InstanceLock"] = false,
	["ItemIcon"] = false,
	["ShowSpec"] = true,
}
-- UNITFRAME OPTIONS
C["Unitframe"] = {
	["AuraOffsetY"] = 3,
	["BetterPowerColors"] = false,
	["CastBarScale"] = 1.2,
	["ClassHealth"] = false,
	["ClassIcon"] = false,
	["ClassResources"] = false,
	["CombatFeedback"] = false,
	["FlatClassIcons"] = false,
	["Enable"] = true,
	["EnhancedFrames"] = false,
	["GroupNumber"] = false,
	["LargeAuraSize"] = 20,
	["Outline"] = false,
	["PercentHealth"] = false,
	["PvPIcon"] = true,
	["Scale"] = 1.2,
	["SmallAuraSize"] = 16,
	["SmoothBars"] = false,
}
-- WORLDMAP OPTIONS
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["SmallWorldMap"] = true,
}