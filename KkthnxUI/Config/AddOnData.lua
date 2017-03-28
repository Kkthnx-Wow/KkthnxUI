local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local print = print
local table_wipe = table.wipe

-- Wow API
local BugGrabberDB = _G.BugGrabberDB
local BugSackDB = _G.BugSackDB
local BugSackLDBIconDB = _G.BugSackLDBIconDB
local DBT_AllPersistentOptions = _G.DBT_AllPersistentOptions
local MSBT_SavedMedia = _G.MSBT_SavedMedia
local MSBTProfiles_SavedVars = _G.MSBTProfiles_SavedVars
local ReloadUI = _G.ReloadUI
local SkadaDB = _G.SkadaDB
local StaticPopup_Show = _G.StaticPopup_Show

-- BugGrabber Profile
local function UploadBugGrabber()
	if BugGrabberDB then table_wipe(BugGrabberDB) end
	BugGrabberDB = {
		["stopnag"] = 50001,
		["throttle"] = true,
		["limit"] = 50,
		["errors"] = {},
		["save"] = false,
		["session"] = 1,
	}
end

-- BugSack Profile
local function UploadBugSack()
	if BugSackDB then table_wipe(BugSackDB) end
	if BugSackLDBIconDB then table_wipe(BugSackLDBIconDB) end
	BugSackDB = {
		["fontSize"] = "GameFontHighlight",
		["auto"] = false,
		["soundMedia"] = "BugSack: Fatality",
		["mute"] = true,
		["chatframe"] = false,
	}
	BugSackLDBIconDB = {
		["hide"] = false,
	}
end

-- MSBT Profile
local function UploadMSBT()
	if MSBTProfiles_SavedVars then table_wipe(MSBTProfiles_SavedVars) end
	if MSBT_SavedMedia then table_wipe(MSBT_SavedMedia) end
	_G.MSBTProfiles_SavedVars = {
		["profiles"] = {
			["KkthnxUI"] = {
				["critFontName"] = "KkthnxUI_Damage",
				["stickyCritsDisabled"] = true,
				["animationSpeed"] = 70,
				["normalFontSize"] = 14,
				["textShadowingDisabled"] = true,
				["creationVersion"] = "5.4.78",
				["critFontSize"] = 18,
				["critOutlineIndex"] = 2,
				["events"] = {
					["NOTIFICATION_PC_KILLING_BLOW"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONEY"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SHADOW_ORBS_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_LOOT"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SOUL_SHARD_CREATED"] = {
						["alwaysSticky"] = false,
					},
					["INCOMING_HEAL_CRIT"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ALT_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CHI_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_DEBUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ALT_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SHADOW_ORBS_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_HOLY_POWER_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONSTER_EMOTE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_PET_COOLDOWN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ENEMY_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_EXTRA_ATTACK"] = {
						["alwaysSticky"] = false,
						["disabled"] = true,
					},
					["NOTIFICATION_COOLDOWN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_HOLY_POWER_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CHI_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF"] = {
						["disabled"] = true,
					},
				},
				["hideFullOverheals"] = true,
				["scrollAreas"] = {
					["Notification"] = {
						["direction"] = "Up",
						["stickyDirection"] = "Up",
						["scrollWidth"] = 300,
						["offsetX"] = -150,
						["normalFontSize"] = 16,
						["critFontSize"] = 16,
						["offsetY"] = 60,
						["scrollHeight"] = 100,
						["stickyAnimationStyle"] = "Static",
					},
					["Incoming"] = {
						["direction"] = "Up",
						["behavior"] = "MSBT_NORMAL",
						["stickyBehavior"] = "MSBT_NORMAL",
						["stickyDirection"] = "Up",
						["scrollHeight"] = 150,
						["offsetX"] = -295,
						["scrollWidth"] = 130,
						["iconAlign"] = "Right",
						["offsetY"] = 10,
						["animationStyle"] = "Straight",
						["stickyAnimationStyle"] = "Static",
					},
					["Static"] = {
						["disabled"] = true,
						["offsetY"] = -65,
					},
					["Outgoing"] = {
						["direction"] = "Up",
						["stickyBehavior"] = "MSBT_NORMAL",
						["scrollWidth"] = 130,
						["stickyDirection"] = "Up",
						["scrollHeight"] = 150,
						["offsetX"] = 165,
						["behavior"] = "MSBT_NORMAL",
						["iconAlign"] = "Left",
						["offsetY"] = 10,
						["animationStyle"] = "Straight",
						["stickyAnimationStyle"] = "Static",
					},
				},
				["normalFontName"] = "KkthnxUI_Damage",
				["normalOutlineIndex"] = 2,
				["triggers"] = {
					["MSBT_TRIGGER_IMPACT"] = {
						["disabled"] = true,
					},
					["Custom2"] = {
						["message"] = "New Trigger",
						["alwaysSticky"] = true,
						["disabled"] = true,
					},
					["MSBT_TRIGGER_DECIMATION"] = {
						["disabled"] = true,
					},
					["Custom1"] = {
						["message"] = "New Trigger",
						["alwaysSticky"] = true,
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MAELSTROM_WEAPON"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BERSERK"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_OVERPOWER"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SWORD_AND_BOARD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHADOW_ORB"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_RIME"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_THE_ART_OF_WAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_VITAL_MISTS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_RUNE_STRIKE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MANA_TEA"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BLINDSIDE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_TASTE_FOR_BLOOD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_HEALTH"] = {
						["soundFile"] = "Omen: Aoogah!",
						["iconSkill"] = "3273",
						["mainEvents"] = "UNIT_HEALTH{unitID;;eq;;player;;threshold;;lt;;25}",
						["disabled"] = true,
					},
					["MSBT_TRIGGER_KILLING_MACHINE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOCK_AND_LOAD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_TIDAL_WAVES"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_MANA"] = {
						["mainEvents"] = "UNIT_MANA{unitID;;eq;;player;;threshold;;lt;;25}",
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ECLIPSE_LUNAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_FINGERS_OF_FROST"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_HOT_STREAK"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_NIGHTFALL"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LAVA_SURGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SUDDEN_DEATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_KILL_SHOT"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_OWLKIN_FRENZY"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ELUSIVE_BREW"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHOOTING_STARS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_PET_HEALTH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MOLTEN_CORE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ECLIPSE_SOLAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MISSILE_BARRAGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_VICTORY_RUSH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHADOW_INFUSION"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_CLEARCASTING"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BLOODSURGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_PREDATORS_SWIFTNESS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_EXECUTE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_HAMMER_OF_WRATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_REVENGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_POWER_GUARD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BRAIN_FREEZE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BACKLASH"] = {
						["disabled"] = true,
					},
				},
			},
			["Default"] = {
				["critFontName"] = "KkthnxUI_Damage",
				["stickyCritsDisabled"] = true,
				["animationSpeed"] = 70,
				["normalFontSize"] = 14,
				["textShadowingDisabled"] = true,
				["creationVersion"] = "5.4.78",
				["critFontSize"] = 18,
				["critOutlineIndex"] = 2,
				["events"] = {
					["NOTIFICATION_PC_KILLING_BLOW"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONEY"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SHADOW_ORBS_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_LOOT"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SOUL_SHARD_CREATED"] = {
						["alwaysSticky"] = false,
					},
					["INCOMING_HEAL_CRIT"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ALT_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CHI_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_DEBUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ALT_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SHADOW_ORBS_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_HOLY_POWER_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONSTER_EMOTE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_PET_COOLDOWN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ENEMY_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_EXTRA_ATTACK"] = {
						["alwaysSticky"] = false,
						["disabled"] = true,
					},
					["NOTIFICATION_COOLDOWN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_HOLY_POWER_CHANGE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CHI_FULL"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF"] = {
						["disabled"] = true,
					},
				},
				["hideFullOverheals"] = true,
				["scrollAreas"] = {
					["Notification"] = {
						["direction"] = "Up",
						["stickyDirection"] = "Up",
						["scrollWidth"] = 300,
						["offsetX"] = -150,
						["normalFontSize"] = 16,
						["critFontSize"] = 16,
						["offsetY"] = 60,
						["scrollHeight"] = 100,
						["stickyAnimationStyle"] = "Static",
					},
					["Incoming"] = {
						["direction"] = "Up",
						["behavior"] = "MSBT_NORMAL",
						["stickyBehavior"] = "MSBT_NORMAL",
						["stickyDirection"] = "Up",
						["scrollHeight"] = 150,
						["offsetX"] = -295,
						["scrollWidth"] = 130,
						["iconAlign"] = "Right",
						["offsetY"] = 10,
						["animationStyle"] = "Straight",
						["stickyAnimationStyle"] = "Static",
					},
					["Static"] = {
						["disabled"] = true,
						["offsetY"] = -65,
					},
					["Outgoing"] = {
						["direction"] = "Up",
						["stickyBehavior"] = "MSBT_NORMAL",
						["scrollWidth"] = 130,
						["stickyDirection"] = "Up",
						["scrollHeight"] = 150,
						["offsetX"] = 165,
						["behavior"] = "MSBT_NORMAL",
						["iconAlign"] = "Left",
						["offsetY"] = 10,
						["animationStyle"] = "Straight",
						["stickyAnimationStyle"] = "Static",
					},
				},
				["normalFontName"] = "KkthnxUI_Damage",
				["normalOutlineIndex"] = 2,
				["triggers"] = {
					["MSBT_TRIGGER_IMPACT"] = {
						["disabled"] = true,
					},
					["Custom2"] = {
						["message"] = "New Trigger",
						["alwaysSticky"] = true,
						["disabled"] = true,
					},
					["MSBT_TRIGGER_DECIMATION"] = {
						["disabled"] = true,
					},
					["Custom1"] = {
						["message"] = "New Trigger",
						["alwaysSticky"] = true,
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MAELSTROM_WEAPON"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BERSERK"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_OVERPOWER"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SWORD_AND_BOARD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHADOW_ORB"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_RIME"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_THE_ART_OF_WAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_VITAL_MISTS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_RUNE_STRIKE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MANA_TEA"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BLINDSIDE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_TASTE_FOR_BLOOD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_HEALTH"] = {
						["soundFile"] = "Omen: Aoogah!",
						["iconSkill"] = "3273",
						["mainEvents"] = "UNIT_HEALTH{unitID;;eq;;player;;threshold;;lt;;25}",
						["disabled"] = true,
					},
					["MSBT_TRIGGER_KILLING_MACHINE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOCK_AND_LOAD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_TIDAL_WAVES"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_MANA"] = {
						["mainEvents"] = "UNIT_MANA{unitID;;eq;;player;;threshold;;lt;;25}",
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ECLIPSE_LUNAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_FINGERS_OF_FROST"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_HOT_STREAK"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_NIGHTFALL"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LAVA_SURGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SUDDEN_DEATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_KILL_SHOT"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_OWLKIN_FRENZY"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ELUSIVE_BREW"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHOOTING_STARS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_LOW_PET_HEALTH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MOLTEN_CORE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_ECLIPSE_SOLAR"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MISSILE_BARRAGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_VICTORY_RUSH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_SHADOW_INFUSION"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_CLEARCASTING"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BLOODSURGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_PREDATORS_SWIFTNESS"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_EXECUTE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_HAMMER_OF_WRATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_REVENGE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_POWER_GUARD"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BRAIN_FREEZE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_BACKLASH"] = {
						["disabled"] = true,
					},
				},
			},
		},
	}
	_G.MSBT_SavedMedia = {
		["fonts"] = {
		},
		["sounds"] = {
		},
	}
end

-- Skada Profile
local function UploadSkada()
	if SkadaDB then table_wipe(SkadaDB) end
	_G.SkadaDB = {
		["profileKeys"] = {
			["Aceer - Stormreaver"] = "Default",
		},
		["profiles"] = {
			["Default"] = {
				["showself"] = false,
				["modules"] = {
					["notankwarnings"] = true,
				},
				["windows"] = {
					{
						["classicons"] = false,
						["barslocked"] = true,
						["y"] = 6,
						["barfont"] = "KkthnxUI_Normal",
						["title"] = {
							["color"] = {
								["a"] = 0,
								["b"] = 0.3,
								["g"] = 0.1,
								["r"] = 0.1,
							},
							["font"] = "KkthnxUI_Normal",
							["fontsize"] = 12,
							["height"] = 17,
							["texture"] = "KkthnxUI_StatusBar",
						},
						["point"] = "BOTTOMRIGHT",
						["barbgcolor"] = {
							["a"] = 0,
							["r"] = 0.3,
							["g"] = 0.3,
							["b"] = 0.3,
						},
						["barcolor"] = {
							["r"] = 0.05,
							["g"] = 0.05,
							["b"] = 0.05,
						},
						["barfontsize"] = 12,
						["smoothing"] = true,
						["mode"] = "DPS",
						["spark"] = false,
						["bartexture"] = "KkthnxUI_StatusBar",
						["barwidth"] = 200,
						["x"] = -300,
						["background"] = {
							["height"] = 152,
							["color"] = {
								["a"] = 0,
								["b"] = 0.5,
							},
						},
					}, -- [1]
				},
				["icon"] = {
					["hide"] = true,
				},
				["report"] = {
					["channel"] = "Guild",
				},
				["columns"] = {
					["Healing_Healing"] = false,
					["Damage_Damage"] = false,
				},
				["hidesolo"] = true,
				["versions"] = {
					["1.6.3"] = true,
					["1.6.4"] = true,
				},
				["hidedisables"] = false,
				["onlykeepbosses"] = true,
			},
		},
	}
end

-- DBM Profile
local function UploadDBM()
	if DBT_AllPersistentOptions then table_wipe(DBT_AllPersistentOptions) end
	_G.DBT_AllPersistentOptions = {
		["Default"] = {
			["DBM"] = {
				["HugeTimerY"] = 300,
				["HugeBarXOffset"] = 0,
				["Scale"] = 1,
				["TimerX"] = 400,
				["TimerPoint"] = "CENTER",
				["HugeBarYOffset"] = 8,
				["HugeScale"] = 1,
				["HugeTimerPoint"] = "CENTER",
				["BarYOffset"] = 8,
				["HugeTimerX"] = -400,
				["TimerY"] = 300,
				["BarXOffset"] = 0,
			},
		},
	}
end

StaticPopupDialogs.SETTINGS_ALL = {
	text = L.Popup.SettingsAll,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		if K.CheckAddOn("DBM-Core") then UploadDBM() end
		if K.CheckAddOn("MikScrollingBattleText") then UploadMSBT() end
		if K.CheckAddOn("Skada") then UploadSkada() end
		ReloadUI()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

SlashCmdList.SETTINGS = function(msg)
	if msg == "bugsack" then
		if K.CheckAddOn("BugSack") then
			UploadBugSack()
			ReloadUI()
		else
			print("|cffffff00BugSack"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "buggrabber" then
		if K.CheckAddOn("!BugGrabber") then
			UploadBugGrabber()
			ReloadUI()
		else
			print("|cffffff00BugGrabber"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "dbm" then
		if (K.CheckAddOn("DBM-Core") and K.CheckAddOn("DBM-StatusBarTimers")) then
			UploadDBM()
			ReloadUI()
		else
			print("|cffffff00Deadly Boss Mods"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "msbt" then
		if K.CheckAddOn("MikScrollingBattleText") then
			UploadMSBT()
			ReloadUI()
		else
			print("|cffffff00MikScrollingBattleText"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "skada" then
		if K.CheckAddOn("Skada") then
			UploadSkada()
			ReloadUI()
		else
			print("|cffffff00Skada"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "all" then
		StaticPopup_Show("SETTINGS_ALL")
	else
		print("|cffffff00"..L.Info.SettingsDBM.."|r")
		print("|cffffff00"..L.Info.SettingsMSBT.."|r")
		print("|cffffff00"..L.Info.SettingsSKADA.."|r")
		print("|cffffff00"..L.Info.SettingsALL.."|r")
	end
end
_G.SLASH_SETTINGS1 = "/settings"