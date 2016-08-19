local K, C, L, _ = select(2, ...):unpack()

-- MEDIA OPTIONS
C["Media"] = {
	["Backdrop_Color"] = {5/255, 5/255, 5/255, 0.8},
	["Blank"] = [[Interface\AddOns\KkthnxUI\Media\Textures\Blank]],
	["Blank_Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
	["Blizz"] = [[Interface\Tooltips\UI-Tooltip-Border]],
	["Border_Color"] = {255/255, 255/255, 255/255, 1},
	["Border_Glow"] = [[Interface\AddOns\KkthnxUI\Media\Border\Border_Glow.tga]],
	["Combat_Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
	["Combat_Font_Size"] = 16,
	["Combat_Font_Size_Style"] = "OUTLINE" or "THINOUTLINE",
	["Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	["Font_Size"] = 12,
	["Font_Style"] = "OUTLINE" or "THINOUTLINE",
	["Glow"] = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
	["Overlay_Color"] = {0/255, 0/255, 0/255, 0.8},
	["Proc_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
	["Texture"] = [[Interface\TargetingFrame\UI-StatusBar]],
	["Warning_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
	["Whisp_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
}
-- ACTIONBAR OPTIONS
C["ActionBar"] = {
	["BottomBars"] = 3,
	["ButtonSize"] = 36,
	["ButtonSpace"] = 4,
	["Enable"] = true,
	["EquipBorder"] = false,
	["HideHighlight"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["OutOfMana"] = {128/255, 128/255, 255/255},
	["OutOfRange"] = {204/255, 26/255, 26/255},
	["PetBarHide"] = false,
	["PetBarHorizontal"] = false,
	["RightBars"] = 2,
	["SelfCast"] = false,
	["ShowGrid"] = true,
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
	["SellGreyRepair"] = false,
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
	["DarkTextures"] = false,
	["DarkTexturesColor"] = {77/255, 77/255, 77/255},
	["Durability"] = true,
	["MoveAchievements"] = true,
	["Reputations"] = true,
}
-- BUFFS & DEBUFFS OPTIONS
C["Aura"] = {
	["Enable"] = true,
	["BuffSize"] = 36,
	["CastBy"] = false,
	["ClassColorBorder"] = false,
	["Timer"] = true,
}
-- CHAT OPTIONS
C["Chat"] = {
	["CombatLog"] = true,
	["DamageMeterSpam"] = false,
	["Enable"] = true,
	["Filter"] = true,
	["Height"] = 150,
	["Outline"] = false,
	["Spam"] = false,
	["FadeTime"] = 20,
	["Sticky"] = true,
	["TabsMouseover"] = true,
	["TabsOutline"] = false,
	["WhispSound"] = true,
	["Width"] = 400,
}
-- COOLDOWN OPTIONS
C["Cooldown"] = {
	["Enable"] = true,
	["FontSize"] = 20,
	["Threshold"] = 3,
}
-- ERROR OPTIONS
C["Error"] = {
	["Black"] = true,
	["White"] = false,
	["Combat"] = false,
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
}
-- MISCELLANEOUS OPTIONS
C["Misc"] = {
	["AFKCamera"] = false,
	["AlreadyKnown"] = false,
	["Armory"] = false,
	["BGSpam"] = false,
	["DurabilityWarninig"] = false,
	["EnhancedMail"] = true,
	["InviteKeyword"] = "inv",
	["ItemLevel"] = false,
	["MoveBlizzard"] = false,
}
-- NAMEPLATE OPTIONS
C["Nameplate"] = {
	["AdditionalHeight"] = 0,
	["AdditionalWidth"] = 0,
	["AuraSize"] = 20,
	["BadColor"] = {1, 0, 0},
	["ClassIcons"] = false,
	["Combat"] = false,
	["Enable"] = true,
	["EnhanceThreat"] = false,
	["GoodColor"] = {0.2, 0.8, 0.2},
	["HealthValue"] = true,
	["Height"] = 9,
	["NameAbbreviate"] = true,
	["NearColor"] = {1, 1, 0},
	["CastBarName"] = true,
	["Auras"] = false,
	["Width"] = 120,
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
	["HideCombat"] = false,
	["HideButtons"] = false,
	["InstanceLock"] = false,
	["ItemCount"] = false,
	["ItemIcon"] = false,
	["QualityBorder"] = false,
	["RaidIcon"] = false,
	["Rank"] = false,
	["SpellID"] = false,
	["Talents"] = false,
	["Target"] = true,
	["Title"] = true,
	["WhoTargetting"] = false,
}
-- UNITFRAME OPTIONS
C["Unitframe"] = {
	["ComboFrame"] = false,
	["SmoothBars"] = false,
	["AuraOffsetY"] = 3,
	["BetterPowerColors"] = false,
	["CastBarScale"] = 1.2,
	["ClassHealth"] = false,
	["ClassIcon"] = false,
	["CombatFeedback"] = false,
	["Enable"] = true,
	["EnhancedFrames"] = false,
	["GroupNumber"] = false,
	["PvPIcon"] = true,
	["LargeAuraSize"] = 20,
	["Outline"] = false,
	["PercentHealth"] = false,
	["Scale"] = 1.2,
	["SmallAuraSize"] = 16,
}