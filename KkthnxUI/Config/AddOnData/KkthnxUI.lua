local K = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = _G.table.wipe

-- GLOBALS: KkthnxUIData

local KkthnxUIData = _G.KkthnxUIData
local KkthnxUIConfigShared = _G.KkthnxUIConfigShared

function K.LoadKkthnxUIProfile()
	if KkthnxUIData then
		table_wipe(KkthnxUIData)
	end

	if KkthnxUIConfigShared then
		table_wipe(KkthnxUIConfigShared)
	end

	_G.KkthnxUIData = {
		["Default"] = {
			["KkthnxUI"] = {
				["AutoQuest"] = false,
				["AutoInvite"] = false,
				["Mover"] = {
				},
				["BindType"] = 1,
				["LockUIScale"] = true,
				["Version"] = "9.03",
				["UIScale"] = 0.71111,
				["Chat"] = {
					["Frame1"] = {
						"BOTTOMLEFT", -- [1]
						"BOTTOMLEFT", -- [2]
						3, -- [3]
						3, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame5"] = {
						"BOTTOMLEFT", -- [1]
						"BOTTOMLEFT", -- [2]
						100, -- [3]
						100, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame6"] = {
						"BOTTOMLEFT", -- [1]
						"BOTTOMLEFT", -- [2]
						100, -- [3]
						100, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame8"] = {
						"BOTTOMLEFT", -- [1]
						"BOTTOMLEFT", -- [2]
						100, -- [3]
						100, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame4"] = {
						"BOTTOMLEFT", -- [1]
						"BOTTOMLEFT", -- [2]
						100, -- [3]
						100, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame9"] = {
						"BOTTOMLEFT", -- [1]
						"BOTTOMLEFT", -- [2]
						100, -- [3]
						100, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame7"] = {
						"BOTTOMLEFT", -- [1]
						"BOTTOMLEFT", -- [2]
						100, -- [3]
						100, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame3"] = {
						"TOPLEFT", -- [1]
						"TOPLEFT", -- [2]
						0, -- [3]
						0, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame2"] = {
						"TOPLEFT", -- [1]
						"TOPLEFT", -- [2]
						0, -- [3]
						-24.0000171661377, -- [4]
						410, -- [5]
						149, -- [6]
					},
					["Frame10"] = {
						"BOTTOMLEFT", -- [1]
						"BOTTOMLEFT", -- [2]
						100, -- [3]
						100, -- [4]
						410, -- [5]
						149, -- [6]
					},
				},
				["WatchedMovies"] = {
				},
				["InstallComplete"] = true,
				["RevealWorldMap"] = true,
			},
		},
	}

	_G.KkthnxUIConfigShared = {
		["Default"] = {
			["KkthnxUI"] = {
				["Inventory"] = {
					["PulseNewItem"] = true,
					["ItemLevel"] = true,
					["AutoRepair"] = {
						["Options"] = {
							["Player"] = "PLAYER",
							["Guild"] = "GUILD",
							["None"] = "NONE",
						},
						["Value"] = "GUILD",
					},
				},
				["Misc"] = {
					["PvPEmote"] = true,
					["SlotDurability"] = true,
					["EnhancedFriends"] = true,
					["NoTalkingHead"] = true,
					["InspectInfo"] = true,
					["ImprovedStats"] = true,
					["AFKCamera"] = true,
					["ColorPicker"] = true,
					["KillingBlow"] = true,
					["CharacterInfo"] = true,
					["ProfessionTabs"] = true,
				},
				["General"] = {
					["MoveBlizzardFrames"] = true,
					["PortraitStyle"] = {
						["Options"] = {
							["3D Portraits"] = "ThreeDPortraits",
							["New Class Portraits"] = "NewClassPortraits",
							["Class Portraits"] = "ClassPortraits",
							["Default Portraits"] = "DefaultPortraits",
						},
						["Value"] = "ThreeDPortraits",
					},
					["LagTolerance"] = true,
					["DisableTutorialButtons"] = true,
				},
				["Minimap"] = {
					["VignetteAlert"] = true,
					["ResetZoom"] = true,
				},
				["Party"] = {
					["Smooth"] = true,
					["Castbars"] = true,
					["TargetHighlight"] = true,
					["PortraitTimers"] = true,
				},
				["Loot"] = {
					["FastLoot"] = true,
					["AutoConfirm"] = true,
					["AutoGreed"] = true,
					["AutoDisenchant"] = true,
				},
				["Automation"] = {
					["AutoQuest"] = true,
					["AutoResurrect"] = true,
					["AutoResurrectThank"] = true,
					["AutoReward"] = true,
					["WhisperInvite"] = 1234,
					["ScreenShot"] = true,
					["AutoInvite"] = true,
					["AutoDisenchant"] = true,
					["DeclinePvPDuel"] = true,
					["AutoCollapse"] = true,
					["BlockMovies"] = true,
					["AutoTabBinder"] = true,
					["DeclinePetDuel"] = true,
					["AutoRelease"] = true,
				},
				["Skins"] = {
					["Details"] = true,
				},
				["Raid"] = {
					["TargetHighlight"] = true,
					["ManabarShow"] = true,
					["ShowRolePrefix"] = true,
					["Smooth"] = true,
				},
				["Filger"] = {
					["Enable"] = true,
					["DisableCD"] = true,
					["Expiration"] = true,
					["DisablePvP"] = true,
				},
				["Tooltip"] = {
					["AzeriteArmor"] = true,
					["ShowMount"] = true,
					["PlayerRoles"] = true,
					["TargetInfo"] = true,
					["Icons"] = true,
					["NpcID"] = true,
				},
				["Announcements"] = {
					["SaySapped"] = true,
				},
				["Unitframe"] = {
					["OnlyShowPlayerDebuff"] = true,
					["SwingbarTimer"] = true,
					["GlobalCooldown"] = true,
					["PortraitTimers"] = true,
					["PlayerBuffs"] = true,
					["PlayerHealthFormat"] = {
						["Options"] = {
							["Current"] = "[KkthnxUI:HealthCurrent]",
							["Percent"] = "[KkthnxUI:HealthPercent]",
							["Current / Percent"] = "[KkthnxUI:HealthCurrent-Percent]",
						},
						["Value"] = "[KkthnxUI:HealthCurrent-Percent]",
					},
					["Swingbar"] = true,
					["Smooth"] = true,
				},
				["Auras"] = {
					["Reminder"] = true,
				},
				["WorldMap"] = {
					["WorldMapPlus"] = true,
				},
				["Nameplates"] = {
					["Clamp"] = true,
					["HealthFormat"] = {
						["Options"] = {
							["Current"] = "[KkthnxUI:HealthCurrent]",
							["Percent"] = "[KkthnxUI:HealthPercent]",
							["Current / Percent"] = "[KkthnxUI:HealthCurrent-Percent]",
						},
						["Value"] = "[KkthnxUI:HealthCurrent-Percent]",
					},
					["Smooth"] = true,
					["Width"] = 146,
				},
				["Arena"] = {
					["Smooth"] = true,
				},
				["Chat"] = {
					["Background"] = true,
				},
				["Boss"] = {
					["Smooth"] = true,
				},
			},
		},
	}
end

-- K:RegisterChatCommand("kkprofile", K.LoadKkthnxUIProfile)