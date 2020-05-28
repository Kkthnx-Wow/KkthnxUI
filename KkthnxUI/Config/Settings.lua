local _, C = unpack(select(2, ...))

local _G = _G

local GUILD = _G.GUILD
local IsAddOnLoaded = _G.IsAddOnLoaded
local NONE = _G.NONE
local PLAYER = _G.PLAYER

-- Actionbar
C["ActionBar"] = {
	["Cooldowns"] = true,
	["Count"] = true,
	["DecimalCD"] = true,
	["DefaultButtonSize"] = 34,
	["Enable"] = true,
	["FadeRightBar"] = false,
	["FadeRightBar2"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["MicroBar"] = true,
	["MicroBarMouseover"] = false,
	["OverrideWA"] = false,
	["RightButtonSize"] = 34,
	["StancePetSize"] = 30,
	["Layout"] = {
		["Options"] = {
			["Mainbar 2x3x4"] = "3x4 Boxed arrangement",
			["Mainbar 3x12"] = "Default Style",
			["Mainbar 4x12"] = "Four Stacked",
		},
		["Value"] = "Default Style"
	},
}

-- Announcements
C["Announcements"] = {
	["ItemAlert"] = false,
	["PullCountdown"] = true,
	["RareAlert"] = false,
	["SaySapped"] = false,
	["Interrupt"] = {
		["Options"] = {
			["Disabled"] = "NONE",
			["Emote"] = "EMOTE",
			["Party Only"] = "PARTY",
			["Party/Raid"] = "RAID",
			["Raid Only"] = "RAID_ONLY",
			["Say"] = "SAY",
			["Yell"] = "YELL"
		},
		["Value"] = "PARTY"
	},
	-- ["Dispell"] = {
	-- 	["Options"] = {
	-- 		["Disabled"] = "NONE",
	-- 		["Emote"] = "EMOTE",
	-- 		["Party Only"] = "PARTY",
	-- 		["Party/Raid"] = "RAID",
	-- 		["Raid Only"] = "RAID_ONLY",
	-- 		["Say"] = "SAY",
	-- 		["Yell"] = "YELL"
	-- 	},
	-- 	["Value"] = "PARTY"
	-- },
}

-- Automation
C["Automation"] = {
	-- ["AutoReward"] = false,
	["AutoBlockStrangerInvites"] = false,
	["AutoCollapse"] = false,
	["AutoDeclineDuels"] = false,
	["AutoDeclinePetDuels"] = false,
	["AutoDisenchant"] = false,
	["AutoInvite"] = false,
	["AutoQuest"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectThank"] = false,
	["AutoScreenshot"] = false,
	["AutoSetRole"] = false,
	["AutoTabBinder"] = false,
	["BlockMovies"] = false,
	["NoBadBuffs"] = false,
	["WhisperInvite"] = "inv+",
}

C["Inventory"] = {
	["AutoSell"] = true,
	["BagBar"] = true,
	["BagBarMouseover"] = false,
	["BagsWidth"] = 12,
	["BagsiLvl"] = true,
	["BankWidth"] = 14,
	["DeleteButton"] = true,
	["Enable"] = true,
	["FilterJunk"] = false,
	["FilterMount"] = false,
	["GatherEmpty"] = false,
	["IconSize"] = 34,
	["ItemFilter"] = true,
	["ItemSetFilter"] = false,
	["QuestItemFilter"] = false,
	["ScrapIcon"] = true,
	["ShowNewItem"] = true,
	["TradeGoodsFilter"] = false,
	["UpgradeIcon"] = true,
	["AutoRepair"] = {
		["Options"] = {
			[NONE] = 0,
			[GUILD] = 1,
			[PLAYER] = 2,
		},
		["Value"] = 2
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
	["Statue"] = true,
	["Totems"] = true,
}

-- Chat
C["Chat"] = {
	["Background"] = false,
	["ChatItemLevel"] = true,
	["Enable"] = true,
	["EnableFilter"] = true,
	["Fading"] = true,
	["FadingTimeFading"] = 3,
	["FadingTimeVisible"] = 20,
	["LootIcons"] = false,
	["OldChatNames"] = false,
	["PhasingAlert"] = true,
	["TabsMouseover"] = true,
	["WhisperColor"] = true,
	["WhisperSound"] = true,
	["TimestampFormat"] = {
		["Options"] = {
			["Disable"] = 1,
			["03:27 PM"] = 2,
			["03:27:32 PM"] = 3,
			["15:27"] = 4,
			["15:27:32"] = 5,
		},
		["Value"] = 1
	},
}

-- DataBars
C["DataBars"] = {
	["AzeriteColor"] = {.901, .8, .601},
	["Enable"] = true,
	["ExperienceColor"] = {0, 0.4, 1, .8},
	["Height"] = 14,
	["HonorColor"] = {240/255, 114/255, 65/255},
	["MouseOver"] = false,
	["RestedColor"] = {1, 0, 1, 0.2},
	["Text"] = true,
	["TrackHonor"] = false,
	["Width"] = 180,
}

-- Datatext
C["DataText"] = {
	["Currency"] = true,
	["Friends"] = true,
	["Guild"] = true,
	["System"] = true,
	["Talents"] = true,
	["Time"] = true,
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
	["AutoScale"] = true,
	["ColorTextures"] = false,
	["DisableTutorialButtons"] = false,
	["FontSize"] = 12,
	["HideErrors"] = true,
	["MoveBlizzardFrames"] = false,
	["ReplaceBlizzardFonts"] = true,
	["TexturesColor"] = {0.9, 0.9, 0.9},
	["UIScale"] = 0.71111,
	["VersionCheck"] = true,
	["Welcome"] = true,
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Standard: b/m/k"] = 1,
			["Asian: y/w"] = 2,
			["Full Digits"] = 3,
		},
		["Value"] = 1
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
	["Enable"] = true,
	["ResetZoom"] = false,
	["ResetZoomTime"] = 4,
	["ShowGarrison"] = true,
	["ShowRecycleBin"] = true,
	["Size"] = 180,
	["LocationText"] = {
		["Options"] = {
			["Always Display"] = "SHOW",
			["Hide"] = "Hide",
			["Minimap Mouseover"] = "MOUSEOVER",
		},
		["Value"] = "MOUSEOVER"
	},
	["BlipTexture"] = {
		["Options"] = {
			["Blizzard"] = "Interface\\MiniMap\\ObjectIconsAtlas",
			["Charmed"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Charmed",
			["Nandini"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Nandini-New",
		},
		["Value"] = "Interface\\MiniMap\\ObjectIconsAtlas"
	},
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["ColorPicker"] = false,
	["EnchantmentScroll"] = false,
	["EnhancedFriends"] = false,
	["GemEnchantInfo"] = false,
	["ImprovedStats"] = false,
	["ItemLevel"] = false,
	["KillingBlow"] = false,
	["NoTalkingHead"] = false,
	["PvPEmote"] = false,
	["ShowWowHeadLinks"] = false,
	["SlotDurability"] = false,
	["TradeTabs"] = false,
}

C["Nameplate"] = {
	["AKSProgress"] = false,
	["AuraSize"] = 22,
	-- ["ClassIcon"] = false,
	["CustomColor"] = {0, 0.8, 0.3},
	["CustomUnitColor"] = true,
	["Distance"] = 42,
	["DPSRevertThreat"] = false,
	["Enable"] = true,
	["ExplosivesScale"] = false,
	["FriendlyCC"] = false,
	["FullHealth"] = false,
	["HealthTextSize"] = 10,
	["HostileCC"] = true,
	["InsecureColor"] = {1, 0, 0},
	["InsideView"] = true,
	["MaxAuras"] = 5,
	["MaxPowerGlow"] = false,
	["MinAlpha"] = 0.35,
	["MinScale"] = 1,
	["NameplateClassPower"] = true,
	["NameTextSize"] = 10,
	["OffTankColor"] = {0.2, 0.7, 0.5},
	["PlateHeight"] = 9,
	["PlateWidth"] = 134,
	["PPHeight"] = 5,
	["PPHideOOC"] = true,
	["PPIconSize"] = 32,
	["PPPHeight"] = 6,
	["PPPowerText"] = true,
	["QuestIndicator"] = true,
	["SecureColor"] = {1, 0, 1},
	["ShowPlayerPlate"] = false,
	["Smooth"] = false,
	["TankMode"] = false,
	["TargetIndicatorColor"] = {1, 1, 0},
	["TransColor"] = {1, 0.8, 0},
	["VerticalSpacing"] = 0.7,
	["TargetIndicator"] = {
		["Options"] = {
			["Disable"] = 1,
			["Top Arrow"] = 2,
			["Right Arrow"] = 3,
			["Border Glow"] = 4,
			["Top Arrow + Glow"] = 5,
			["Right Arrow + Glow"] = 6,
		},
		["Value"] = 4
	},
}

C["PulseCooldown"] = {
	["AnimScale"] = 1.5,
	["Enable"] = false,
	["HoldTime"] = 0.5,
	["Size"] = 75,
	["Sound"] = false,
	["Threshold"] = 3,
}

-- Skins
C["Skins"] = {
	["Bartender4"] = false,
	["BigWigs"] = false,
	["ChatBubbles"] = true,
	["DBM"] = false,
	["Details"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["TalkingHeadBackdrop"] = true,
	["WeakAuras"] = false,
}

-- Tooltip
C["Tooltip"] = {
	["AzeriteArmor"] = false,
	["ClassColor"] = false,
	["CombatHide"] = false,
	-- ["CorruptionRank"] = false,
	["Cursor"] = false,
	["FactionIcon"] = false,
	["HideJunkGuild"] = true,
	["HideRank"] = true,
	["HideRealm"] = true,
	["HideTitle"] = true,
	["Icons"] = true,
	["LFDRole"] = false,
	["ShowIDs"] = false,
	["SpecLevelByShift"] = true,
	["TargetBy"] = true,
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
	["HealPredictionTextures"] = "Blank",
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
	["CastbarLatency"] = true,
	["Castbars"] = true,
	["ClassResources"] = true,
	["CombatFade"] = false,
	["CombatText"] = false,
	["DebuffHighlight"] = true,
	["Enable"] = true,
	["GlobalCooldown"] = false,
	["HideTargetofTarget"] = false,
	["OnlyShowPlayerDebuff"] = false,
	["PlayerBuffs"] = false,
	["PlayerCastbarHeight"] = 24,
	["PlayerCastbarWidth"] = 260,
	["PlayerDeBuffs"] = false,
	["PlayerPowerPrediction"] = true,
	["PortraitTimers"] = false,
	["PvPIndicator"] = true,
	["ResurrectSound"] = false,
	["ShowHealPrediction"] = true,
	["ShowPlayerLevel"] = true,
	["ShowPlayerName"] = false,
	["Smooth"] = false,
	["Stagger"] = true,
	["Swingbar"] = false,
	["SwingbarTimer"] = false,
	["TargetBuffs"] = true,
	["TargetCastbarHeight"] = 24,
	["TargetCastbarWidth"] = 260,
	["TargetDebuffs"] = true,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
	},
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits"
		},
		["Value"] = "DefaultPortraits"
	},
}

C["Party"] = {
	["Castbars"] = false,
	["Enable"] = true,
	["PortraitTimers"] = false,
	["ShowBuffs"] = true,
	["ShowHealPrediction"] = true,
	-- ["ShowPet"] = false,
	["ShowPlayer"] = true,
	-- ["ShowTarget"] = false,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
}

C["Boss"] = {
	["Castbars"] = true,
	["Enable"] = true,
	["Smooth"] = false,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
}

C["Arena"] = {
	["Castbars"] = true,
	["Enable"] = true,
	["Smooth"] = false,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
}

-- Raidframe
C["Raid"] = {
	["AuraDebuffIconSize"] = 22,
	["AuraDebuffs"] = true,
	["AuraWatch"] = true,
	["AuraWatchIconSize"] = 11,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Height"] = 40,
	["HorizonRaid"] = true,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["NumGroups"] = 6,
	["RaidUtility"] = true,
	["ReverseRaid"] = false,
	["ShowHealPrediction"] = true,
	["ShowNotHereTimer"] = true,
	["ShowTeamIndex"] = false,
	["Smooth"] = false,
	["SpecRaidPos"] = false,
	["TargetHighlight"] = false,
	["Width"] = 66,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
	["HealthFormat"] = {
        ["Options"] = {
			["Disable HP"] = 1,
			["Health Percentage"] = 2,
			["Health Remaining"] = 3,
			["Health Lost"] = 4,
        },
        ["Value"] = 1
    },
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