local _, C = unpack(KkthnxUI)

local _G = _G

local DISABLE = _G.DISABLE
local EMOTE = _G.EMOTE
local GUILD = _G.GUILD
local NONE = _G.NONE
local PARTY = _G.PARTY
local PLAYER = _G.PLAYER
local RAID = _G.RAID
local SAY = _G.SAY
local YELL = _G.YELL

local BlipMedia = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\"
local ChatMedia = "Interface\\AddOns\\KkthnxUI\\Media\\Chat\\"

-- Actionbar
C["ActionBar"] = {
	["Bar1Font"] = 12,
	["Bar1Num"] = 12,
	["Bar1PerRow"] = 12,
	["Bar1Size"] = 34,
	["Bar2Font"] = 12,
	["Bar2Num"] = 12,
	["Bar2PerRow"] = 12,
	["Bar2Size"] = 34,
	["Bar3Font"] = 12,
	["Bar3Num"] = 12,
	["Bar3PerRow"] = 12,
	["Bar3Size"] = 34,
	["Bar4Fader"] = false,
	["Bar4Font"] = 12,
	["Bar4Num"] = 12,
	["Bar4PerRow"] = 1,
	["Bar4Size"] = 32,
	["Bar5Fader"] = true,
	["Bar5Font"] = 12,
	["Bar5Num"] = 12,
	["Bar5PerRow"] = 1,
	["Bar5Size"] = 32,
	["BarPetFont"] = 12,
	["BarPetNum"] = 10,
	["BarPetPerRow"] = 10,
	["BarPetSize"] = 26,
	["BarStanceFont"] = 12,
	["BarStancePerRow"] = 10,
	["BarStanceSize"] = 30,
	["BarXFader"] = false,
	["Cooldowns"] = true,
	["Count"] = true,
	["CustomBar"] = false,
	["CustomBarButtonSize"] = 34,
	["CustomBarNumButtons"] = 12,
	["CustomBarNumPerRow"] = 12,
	["Enable"] = true,
	["FadeCustomBar"] = false,
	["FadeMicroBar"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["MicroBar"] = true,
	["MMSSTH"] = 60,
	["OverrideWA"] = false,
	["PetBar"] = true,
	["Scale"] = 1,
	["StanceBar"] = true,
	["TenthTH"] = 3,
	["VehButtonSize"] = 34,
}

-- Announcements
C["Announcements"] = {
	["AlertInChat"] = false,
	["AlertInWild"] = false,
	["KeystoneAlert"] = false,
	["BrokenAlert"] = false,
	["DispellAlert"] = false,
	["HealthAlert"] = false,
	["InstAlertOnly"] = true,
	["InterruptAlert"] = false,
	["ItemAlert"] = false,
	["KillingBlow"] = false,
	["OnlyCompleteRing"] = false,
	["OwnDispell"] = true,
	["OwnInterrupt"] = true,
	["PullCountdown"] = true,
	["PvPEmote"] = false,
	["QuestNotifier"] = false,
	["QuestProgress"] = false,
	["RareAlert"] = false,
	["ResetInstance"] = true,
	["SaySapped"] = false,
	["AlertChannel"] = {
		["Options"] = {
			[EMOTE] = 6,
			[PARTY .. " / " .. RAID] = 2,
			[PARTY] = 1,
			[RAID] = 3,
			[SAY] = 4,
			[YELL] = 5,
		},
		["Value"] = 2,
	},
}

-- Automation
C["Automation"] = {
	["AutoKeystone"] = false,
	["AutoBlockStrangerInvites"] = false,
	["AutoCollapse"] = false,
	["AutoDeclineDuels"] = false,
	["AutoDeclinePetDuels"] = false,
	["AutoGoodbye"] = false,
	["AutoInvite"] = false,
	["AutoOpenItems"] = false,
	["AutoPartySync"] = false,
	["AutoQuest"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectThank"] = false,
	["AutoReward"] = false,
	["AutoScreenshot"] = false,
	["AutoSetRole"] = false,
	["AutoSkipCinematic"] = false,
	["AutoSummon"] = false,
	["NoBadBuffs"] = false,
	["WhisperInvite"] = "inv+",
}

C["Inventory"] = {
	["AutoSell"] = true,
	["BagBar"] = true,
	["BagBarMouseover"] = false,
	["BagsBindOnEquip"] = false,
	["BagsItemLevel"] = false,
	["BagsPerRow"] = 6,
	["BagsWidth"] = 10,
	["BankPerRow"] = 10,
	["BankWidth"] = 12,
	["DeleteButton"] = true,
	["Enable"] = true,
	["FilterAnima"] = true,
	["FilterAzerite"] = false,
	["FilterCollection"] = true,
	["FilterConsumable"] = true,
	["FilterCustom"] = true,
	["FilterEquipSet"] = false,
	["FilterEquipment"] = true,
	["FilterGoods"] = false,
	["FilterJunk"] = true,
	["FilterLegendary"] = true,
	["FilterQuest"] = true,
	["FilterRelic"] = false,
	["GatherEmpty"] = false,
	["IconSize"] = 34,
	["ItemFilter"] = true,
	["PetTrash"] = true,
	["ReverseSort"] = false,
	["ShowNewItem"] = true,
	["SpecialBagsColor"] = false,
	["UpgradeIcon"] = true,
	["AutoRepair"] = {
		["Options"] = {
			[NONE] = 0,
			[GUILD] = 1,
			[PLAYER] = 2,
		},
		["Value"] = 2,
	},
}

-- Buffs & Debuffs
C["Auras"] = {
	["BuffSize"] = 30,
	["BuffsPerRow"] = 16,
	["DebuffSize"] = 34,
	["DebuffsPerRow"] = 16,
	["Enable"] = true,
	["HideBlizBuff"] = false,
	["Reminder"] = false,
	["ReverseBuffs"] = false,
	["ReverseDebuffs"] = false,
	["TotemSize"] = 32,
	["Totems"] = true,
	["VerticalTotems"] = false,
}

-- Chat
C["Chat"] = {
	["BlockSpammer"] = true,
	["Background"] = true,
	["BlockAddonAlert"] = false,
	["BlockStranger"] = false,
	["ChatFilterList"] = "%*",
	["ChatFilterWhiteList"] = "",
	["ChatItemLevel"] = true,
	["ChatMenu"] = true,
	["Emojis"] = false,
	["Enable"] = true,
	["EnableFilter"] = true,
	["Fading"] = true,
	["FadingTimeVisible"] = 100,
	["FilterMatches"] = 1,
	["Freedom"] = true,
	["Height"] = 150,
	["Lock"] = true,
	["LogMax"] = 0,
	["OldChatNames"] = false,
	["RoleIcons"] = false,
	["Sticky"] = false,
	["WhisperColor"] = true,
	["Width"] = 392,
	["TimestampFormat"] = {
		["Options"] = {
			["Disable"] = 1,
			["03:27 PM"] = 2,
			["03:27:32 PM"] = 3,
			["15:27"] = 4,
			["15:27:32"] = 5,
		},
		["Value"] = 1,
	},
}

-- Datatext
C["DataText"] = {
	["Coords"] = false,
	["Friends"] = false,
	["Gold"] = false,
	["Guild"] = false,
	["GuildSortBy"] = 1,
	["GuildSortOrder"] = true,
	["HideText"] = false,
	["IconColor"] = { 102 / 255, 157 / 255, 255 / 255 },
	["Latency"] = true,
	["Location"] = true,
	["System"] = true,
	["Time"] = true,
}

C["AuraWatch"] = {
	["Enable"] = true,
	["ClickThrough"] = false,
	["IconScale"] = 1,
	["DeprecatedAuras"] = false,
	["QuakeRing"] = false,
	["InternalCD"] = {},
	["AuraList"] = {
		["Switcher"] = {},
		["IgnoreSpells"] = {},
	},
}

-- General
C["General"] = {
	["AutoScale"] = true,
	["ColorTextures"] = false,
	["MinimapIcon"] = false,
	["MissingTalentAlert"] = true,
	["MoveBlizzardFrames"] = false,
	["NoErrorFrame"] = false,
	["NoTutorialButtons"] = false,
	["TexturesColor"] = { 1, 1, 1 },
	["UIScale"] = 0.71111,
	["UseGlobal"] = false,
	["VersionCheck"] = true,
	["Texture"] = "KkthnxUI",
	["SmoothAmount"] = 0.25,
	["BorderStyle"] = {
		["Options"] = {
			["KkthnxUI"] = "KkthnxUI",
			["AzeriteUI"] = "AzeriteUI",
			["KkthnxUI_Pixel"] = "KkthnxUI_Pixel",
			["KkthnxUI_Blank"] = "KkthnxUI_Blank",
		},
		["Value"] = "KkthnxUI",
	},
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Standard: b/m/k"] = 1,
			["Asian: y/w"] = 2,
			["Full Digits"] = 3,
		},
		["Value"] = 1,
	},
	["Profiles"] = {
		["Options"] = {},
	},
}

-- Loot
C["Loot"] = {
	["AutoConfirm"] = false,
	["AutoGreed"] = false,
	["Enable"] = true,
	["FastLoot"] = false,
	["GroupLoot"] = true,
}

-- Minimap
C["Minimap"] = {
	["Calendar"] = true,
	["EasyVolume"] = false,
	["Enable"] = true,
	["MailPulse"] = true,
	["QueueStatusText"] = false,
	["ShowRecycleBin"] = true,
	["Size"] = 190,
	["RecycleBinPosition"] = {
		["Options"] = {
			["BottomLeft"] = 1,
			["BottomRight"] = 2,
			["TopLeft"] = 3,
			["TopRight"] = 4,
		},
		["Value"] = "BottomLeft",
	},
	["LocationText"] = {
		["Options"] = {
			["Always Display"] = "SHOW",
			["Hide"] = "Hide",
			["Minimap Mouseover"] = "MOUSEOVER",
		},
		["Value"] = "MOUSEOVER",
	},
	["BlipTexture"] = {
		["Options"] = {
			["Default"] = "Interface\\MiniMap\\ObjectIconsAtlas",
			["Blank"] = BlipMedia .. "Blip-Blank",
			["Blizzard Big R"] = BlipMedia .. "Blip-BlizzardBigR",
			["Blizzard Big"] = BlipMedia .. "Blip-BlizzardBig",
			["Charmed"] = BlipMedia .. "Blip-Charmed",
			["Glass Spheres"] = BlipMedia .. "Blip-GlassSpheres",
			["Nandini New"] = BlipMedia .. "Blip-Nandini-New",
			["Nandini"] = BlipMedia .. "Blip-Nandini",
			["SolidSpheres"] = BlipMedia .. "Blip-SolidSpheres",
		},
		["Value"] = "Interface\\MiniMap\\ObjectIconsAtlas",
	},
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["AutoBubbles"] = false,
	["ColorPicker"] = false,
	["EasyMarking"] = false,
	["EnhancedFriends"] = false,
	["EnhancedMail"] = false,
	["ExpRep"] = true,
	["GemEnchantInfo"] = false,
	["HideBanner"] = false,
	["HideBossEmote"] = false,
	["ImprovedStats"] = false,
	["ItemLevel"] = false,
	["MDGuildBest"] = false,
	["MaxCameraZoom"] = 2.6,
	["MuteSounds"] = true,
	["NoTalkingHead"] = false,
	["ParagonEnable"] = false,
	["QuestTool"] = false,
	["QueueTimers"] = false,
	["QuickJoin"] = false,
	["ShowWowHeadLinks"] = false,
	["SlotDurability"] = false,
	["TradeTabs"] = false,
	["ShowMarkerBar"] = {
		["Options"] = {
			["Grids"] = 1,
			["Horizontal"] = 2,
			["Vertical"] = 3,
			[DISABLE] = 4,
		},
		["Value"] = 4,
	},
}

C["Nameplate"] = {
	["AKSProgress"] = false,
	["AuraSize"] = 26,
	["CastTarget"] = false,
	["CastbarGlow"] = true,
	["ClassAuras"] = true,
	["ClassIcon"] = false,
	["ColoredTarget"] = true,
	["CustomColor"] = { 0, 0.8, 0.3 },
	["CustomUnitColor"] = true,
	["CustomUnitList"] = "",
	["DPSRevertThreat"] = false,
	["Distance"] = 42,
	["Enable"] = true,
	["ExecuteRatio"] = 0,
	["ExplosivesScale"] = false,
	["FriendlyCC"] = false,
	["FullHealth"] = false,
	["HealthTextSize"] = 13,
	["HostileCC"] = true,
	["InsecureColor"] = { 1, 0, 0 },
	["InsideView"] = true,
	["MaxAuras"] = 5,
	["MinAlpha"] = 1,
	["MinScale"] = 1,
	["NameOnly"] = true,
	["NameTextSize"] = 13,
	["NameplateClassPower"] = true,
	["OffTankColor"] = { 0.2, 0.7, 0.5 },
	["PPGCDTicker"] = true,
	["PPHeight"] = 8,
	["PPHideOOC"] = true,
	["PPIconSize"] = 32,
	["PPOnFire"] = false,
	["PPPHeight"] = 6,
	["PPPowerText"] = true,
	["PPWidth"] = 175,
	["PlateAuras"] = true,
	["PlateHeight"] = 13,
	["PlateWidth"] = 184,
	["PowerUnitList"] = "",
	["QuestIndicator"] = true,
	["SecureColor"] = { 1, 0, 1 },
	["SelectedScale"] = 1.1,
	["ShowPlayerPlate"] = false,
	["Smooth"] = false,
	["TankMode"] = false,
	["TargetColor"] = { 0, 0.6, 1 },
	["TargetIndicatorColor"] = { 1, 1, 0 },
	["TransColor"] = { 1, 0.8, 0 },
	["VerticalSpacing"] = 0.7,
	["AuraFilter"] = {
		["Options"] = {
			["White & Black List"] = 1,
			["List & Player"] = 2,
			["List & Player & CCs"] = 3,
		},
		["Value"] = 3,
	},
	["TargetIndicator"] = {
		["Options"] = {
			["Disable"] = 1,
			["Top Arrow"] = 2,
			["Right Arrow"] = 3,
			["Border Glow"] = 4,
			["Top Arrow + Glow"] = 5,
			["Right Arrow + Glow"] = 6,
		},
		["Value"] = 4,
	},
	["TargetIndicatorTexture"] = {
		["Options"] = {
			["Blue Arrow 2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow2:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\BlueArrow2]],
			["Blue Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\BlueArrow]],
			["Neon Blue Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonBlueArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonBlueArrow]],
			["Neon Green Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonGreenArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonGreenArrow]],
			["Neon Pink Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPinkArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonPinkArrow]],
			["Neon Red Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonRedArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonRedArrow]],
			["Neon Purple Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPurpleArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonPurpleArrow]],
			["Purple Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\PurpleArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\PurpleArrow]],
			["Red Arrow 2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow2.tga:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedArrow2]],
			["Red Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedArrow]],
			["Red Chevron Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedChevronArrow]],
			["Red Chevron Arrow2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow2:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedChevronArrow2]],
		},
		["Value"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonBlueArrow]],
	},
}

-- Skins
C["Skins"] = {
	["Bartender4"] = false,
	["BigWigs"] = false,
	["BlizzardFrames"] = true,
	["ButtonForge"] = false,
	["ChatBubbleAlpha"] = 0.9,
	["ChatBubbles"] = true,
	["ChocolateBar"] = false,
	["DeadlyBossMods"] = false,
	["Details"] = false,
	["Dominos"] = false,
	["Hekili"] = false,
	["RareScanner"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["TalkingHeadBackdrop"] = true,
	["TellMeWhen"] = false,
	["TitanPanel"] = false,
	["WeakAuras"] = false,

	["ObjectiveFontSize"] = 12,
	["QuestFontSize"] = 11,
}

-- Tooltip
C["Tooltip"] = {
	["ClassColor"] = false,
	["CombatHide"] = false,
	["ConduitInfo"] = false,
	["Cursor"] = false,
	["DominationRank"] = false,
	["Enable"] = true,
	["FactionIcon"] = false,
	["HideJunkGuild"] = true,
	["HideRank"] = true,
	["HideRealm"] = true,
	["HideTitle"] = true,
	["Icons"] = true,
	["LFDRole"] = false,
	["MDScore"] = true,
	["ShowIDs"] = false,
	["ShowMount"] = false,
	["SpecLevelByShift"] = true,
	["TargetBy"] = true,
}

-- Unitframe
C["Unitframe"] = {
	["AllTextScale"] = 1, -- Testing

	["AdditionalPower"] = false,
	["AutoAttack"] = true,
	["CastClassColor"] = false,
	["CastReactionColor"] = false,
	["CastbarLatency"] = true,
	["ClassResources"] = true,
	["CombatFade"] = false,
	["CombatText"] = false,
	["DebuffHighlight"] = true,
	["Enable"] = true,
	["FCTOverHealing"] = false,
	["GlobalCooldown"] = true,
	["HotsDots"] = true,
	["OnlyShowPlayerDebuff"] = false,

	-- Player
	["PlayerBuffs"] = false,
	["PlayerBuffsPerRow"] = 7,
	["PlayerCastbar"] = true,
	["PlayerCastbarHeight"] = 26,
	["PlayerCastbarIcon"] = true,
	["PlayerCastbarWidth"] = 268,
	["PlayerDebuffs"] = false,
	["PlayerDebuffsPerRow"] = 6,
	["PlayerHealthHeight"] = 32,
	["PlayerHealthWidth"] = 180,
	["PlayerPowerHeight"] = 14,
	["PlayerPowerPrediction"] = true,

	["PvPIndicator"] = true,
	["ResurrectSound"] = false,
	["ShowHealPrediction"] = true,
	["ShowPlayerLevel"] = true,
	["Smooth"] = false,
	["Stagger"] = true,
	["Swingbar"] = false,
	["SwingbarTimer"] = false,

	-- Target
	["TargetHealthHeight"] = 32,
	["TargetHealthWidth"] = 180,
	["TargetPowerHeight"] = 14,
	["TargetBuffs"] = true,
	["TargetBuffsPerRow"] = 7,
	["TargetCastbar"] = true,
	["TargetCastbarIcon"] = true,
	["TargetCastbarHeight"] = 30,
	["TargetCastbarWidth"] = 268,
	["TargetDebuffs"] = true,
	["TargetDebuffsPerRow"] = 6,

	-- Focus
	["FocusBuffs"] = true,
	["FocusCastbar"] = true,
	["FocusCastbarHeight"] = 24,
	["FocusCastbarIcon"] = true,
	["FocusCastbarWidth"] = 208,
	["FocusDebuffs"] = true,
	["FocusHealthHeight"] = 32,
	["FocusHealthWidth"] = 180,
	["FocusPowerHeight"] = 14,

	-- TargetOfTarget
	["TargetTargetHealthHeight"] = 16,
	["TargetTargetHealthWidth"] = 90,
	["TargetTargetPowerHeight"] = 8,
	["HideTargetOfTargetLevel"] = false,
	["HideTargetOfTargetName"] = false,
	["HideTargetofTarget"] = false,

	-- Pet
	["PetHealthHeight"] = 16,
	["PetHealthWidth"] = 90,
	["PetPowerHeight"] = 8,
	["HidePetLevel"] = false,
	["HidePetName"] = false,
	["HidePet"] = false,

	-- FocusTarget
	["FocusTargetHealthHeight"] = 16,
	["FocusTargetHealthWidth"] = 90,
	["FocusTargetPowerHeight"] = 8,
	["HideFocusTargetLevel"] = false,
	["HideFocusTargetName"] = false,
	["HideFocusTarget"] = false,

	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class",
	},
	["PortraitStyle"] = {
		["Options"] = {
			["Overlay Portrait"] = "OverlayPortrait",
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits",
			["No Portraits"] = "NoPortraits",
		},
		["Value"] = "DefaultPortraits",
	},
}

C["Party"] = {
	["CastbarIcon"] = false,
	["Castbars"] = false,
	["Enable"] = true,
	["HealthHeight"] = 20,
	["HealthWidth"] = 134,
	["PortraitTimers"] = false,
	["PowerHeight"] = 10,
	["ShowBuffs"] = true,
	["ShowHealPrediction"] = true,
	["ShowPartySolo"] = false,
	["ShowPet"] = false,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class",
	},
}

C["Boss"] = {
	["CastbarIcon"] = true,
	["Castbars"] = true,
	["Enable"] = true,
	["Smooth"] = false,
	["HealthHeight"] = 20,
	["HealthWidth"] = 134,
	["PowerHeight"] = 10,
	["YOffset"] = 54,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class",
	},
}

C["Arena"] = {
	["CastbarIcon"] = true,
	["Castbars"] = true,
	["Enable"] = true,
	["Smooth"] = false,
	["HealthHeight"] = 20,
	["HealthWidth"] = 134,
	["PowerHeight"] = 10,
	["YOffset"] = 54,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class",
	},
}

-- Raidframe
C["Raid"] = {
	["DebuffWatch"] = true,
	["DebuffWatchDefault"] = true,
	["DesaturateBuffs"] = false,
	["Enable"] = true,
	["Height"] = 44,
	["HorizonRaid"] = false,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["NumGroups"] = 6,
	["RaidUtility"] = true,
	["ReverseRaid"] = false,
	["ShowHealPrediction"] = true,
	["ShowNotHereTimer"] = true,
	["ShowRaidSolo"] = false,
	["ShowTeamIndex"] = false,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["Width"] = 70,
	["RaidBuffsStyle"] = {
		["Options"] = {
			["Aura Track"] = "Aura Track",
			["Standard"] = "Standard",
			["None"] = "None",
		},
		["Value"] = "Aura Track",
	},
	["RaidBuffs"] = {
		["Options"] = {
			["Only my buffs"] = "Self",
			["Only castable buffs"] = "Castable",
			["All buffs"] = "All",
		},
		["Value"] = "Self",
	},
	["AuraTrack"] = true,
	["AuraTrackIcons"] = true,
	["AuraTrackSpellTextures"] = true,
	["AuraTrackThickness"] = 5,

	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class",
	},
	["HealthFormat"] = {
		["Options"] = {
			["Disable HP"] = 1,
			["Health Percentage"] = 2,
			["Health Remaining"] = 3,
			["Health Lost"] = 4,
		},
		["Value"] = 1,
	},
}

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["MapRevealGlow"] = true,
	["MapRevealGlowColor"] = { 0.7, 0.7, 0.7 },
	["SmallWorldMap"] = true,
}
