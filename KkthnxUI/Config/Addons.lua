local K, C, L = select(2, ...):unpack()

local print = print
local ReloadUI = ReloadUI
local wipe = table.wipe

local UploadMSBT = function()
	if MSBTProfiles_SavedVars then table.wipe(MSBTProfiles_SavedVars) end
	if MSBT_SavedMedia then table.wipe(MSBT_SavedMedia) end
	MSBTProfiles_SavedVars = {
		["profiles"] = {
			["Default"] = {
				["powerThrottleDuration"] = 5,
				["normalOutlineIndex"] = 2,
				["partialColoringDisabled"] = true,
				["alwaysShowQuestItems"] = false,
				["hideFullOverheals"] = true,
				["normalFontSize"] = 16,
				["scrollAreas"] = {
					["Incoming"] = {
						["scrollHeight"] = 250,
						["offsetX"] = -215,
						["animationStyle"] = "Straight",
						["behavior"] = "MSBT_NORMAL",
						["offsetY"] = 151,
						["skillIconsDisabled"] = true,
						["direction"] = "Up",
					},
					["Outgoing"] = {
						["scrollHeight"] = 250,
						["offsetX"] = 174,
						["animationStyle"] = "Straight",
						["behavior"] = "MSBT_NORMAL",
						["offsetY"] = 151,
						["skillIconsDisabled"] = true,
						["direction"] = "Up",
					},
					["Notification"] = {
						["offsetX"] = -176,
						["offsetY"] = 201,
					},
					["Static"] = {
						["offsetX"] = -7,
						["offsetY"] = -33,
					},
				},
				["soundsDisabled"] = true,
				["hideMergeTrailer"] = true,
				["triggers"] = {
					["MSBT_TRIGGER_RIPOSTE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_KILL_SHOT"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_DECIMATION"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_BACKLASH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_OVERPOWER"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_SWORD_AND_BOARD"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_RAMPAGE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_RIME"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_THE_ART_OF_WAR"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_RUNE_STRIKE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_PREDATORS_SWIFTNESS"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_ECLIPSE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_TASTE_FOR_BLOOD"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_LOW_HEALTH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_LOCK_AND_LOAD"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_TIDAL_WAVES"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_VIPER_STING"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_NIGHTFALL"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_HOT_STREAK"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_LOW_MANA"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_SUDDEN_DEATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_IMPACT"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_OWLKIN_FRENZY"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_BRAIN_FREEZE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_ERADICATION"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_LOW_PET_HEALTH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_KILLING_MACHINE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_PVP_TRINKET"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_MISSILE_BARRAGE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_VICTORY_RUSH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_BLOODSURGE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_CLEARCASTING"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_MOLTEN_CORE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_FINGERS_OF_FROST"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_COUNTER_ATTACK"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_HAMMER_OF_WRATH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_REVENGE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_EXECUTE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_FROSTBITE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MAELSTROM_WEAPON"] = {
						["disabled"] = true,
					},
				},
				["regenAbilitiesDisabled"] = true,
				["critFontName"] = "KkthnxUI_Damage",
				["hotThrottleDuration"] = 5,
				["critOutlineIndex"] = 2,
				["animationSpeed"] = 140,
				["skillIconsDisabled"] = true,
				["dotThrottleDuration"] = 5,
				["creationVersion"] = "5.4.75",
				["critFontSize"] = 16,
				["hideSkills"] = true,
				["events"] = {
					["NOTIFICATION_COMBAT_ENTER"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_PC_KILLING_BLOW"] = {
						["disabled"] = true,
						["fontSize"] = false,
					},
					["NOTIFICATION_MONEY"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_DEBUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_LOOT"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SOUL_SHARD_CREATED"] = {
						["disabled"] = true,
						["fontSize"] = false,
					},
					["OUTGOING_EVADE"] = {
						["fontSize"] = 16,
					},
					["NOTIFICATION_SKILL_GAIN"] = {
						["disabled"] = true,
					},
					["INCOMING_HEAL_CRIT"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["OUTGOING_HEAL_CRIT"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_DEBUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_EXPERIENCE_GAIN"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONSTER_EMOTE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_COMBAT_LEAVE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_FULL"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["NOTIFICATION_ENEMY_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_EXTRA_ATTACK"] = {
						["disabled"] = true,
						["fontSize"] = false,
					},
					["NOTIFICATION_COOLDOWN"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["NOTIFICATION_ITEM_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_GAIN"] = {
						["disabled"] = true,
					},
					["PET_OUTGOING_EVADE"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_HONOR_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_DEBUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_NPC_KILLING_BLOW"] = {
						["fontSize"] = false,
					},
				},
				["cooldownThreshold"] = 60,
				["hideNames"] = true,
				["normalFontName"] = "KkthnxUI_Normal",
				["healThreshold"] = 1000,
				["qualityExclusions"] = {
					true, -- [1]
				},
			},
		},
	}
	MSBT_SavedMedia = {
		["fonts"] = {
			["KkthnxUI"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\KkthnxUI_Normal.ttf",
		},
		["sounds"] = {
		},
	}
end

-- SKADA SETTINGS
local UploadSkada = function()
	if SkadaDB then table.wipe(SkadaDB) end
	SkadaDB = {
		["profiles"] = {
			["Default"] = {
				["windows"] = {
					{
						["barheight"] = 15,
						["barslocked"] = true,
						["y"] = 7,
						["x"] = -332,
						["point"] = "BOTTOMRIGHT",
						["mode"] = "DPS",
						["bartexture"] = "KkthnxUI_StatusBar",
						["barwidth"] = 222,
						["barspacing"] = 1,
						["background"] = {
							["height"] = 80,
							["color"] = {
								["a"] = 0,
							},
						},
						["barfont"] = "KkthnxUI_Normal",
						["title"] = {
							["font"] = "KkthnxUI_Normal",
							["fontsize"] = 12,
							["height"] = 14,
							["texture"] = "KkthnxUI_StatusBar",
						},
					}, -- [1]
				},
				["icon"] = {
					["hide"] = true,
				},
			},
		},
	}
end

-- OUF_ABU SETTINGS
local UploadAbu = function()
	if oUFAbuSettings then table.wipe(oUFAbuSettings) end
	oUFAbuSettings = {
		["Default"] = {
			["useAuraTimer"] = false,
			["target"] = {
				["debuffPos"] = "TOP",
				["buffPos"] = "BOTTOM",
				["style"] = "fat",
				["position"] = "CENTER/294/-175",
				["cbposition"] = "CENTER/0/-175",
			},
			["classPortraits"] = true,
			["player"] = {
				["style"] = "fat",
				["position"] = "CENTER/-294/-175",
				["cbposition"] = "CENTER/0/-206",
			},
			["arena"] = {
				["position"] = "RIGHT/-274/148",
			},
			["TextNameColor"] = {
				1.0, -- [1]
				0.82, -- [2]
				0.0, -- [3]
			},
			["party"] = {
				["style"] = "fat",
			},
			["focus"] = {
				["style"] = "fat",
				["position"] = "LEFT/439/32",
				["cbposition"] = "LEFT/441/-39",
			},
			["fontBigSize"] = 0.900000005960465,
			["classBar"] = {
				[577] = {
					["spellID"] = 0,
					["r"] = 0,
					["g"] = 0,
					["b"] = 0,
				},
			},
			["boss"] = {
				["position"] = "RIGHT/-274/166",
			},
			["pet"] = {
				["cbshow"] = false,
				["style"] = "fat",
				["position"] = "BOTTOM/-240/200",
			},
			["fontBig"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\Normal.ttf",
			["fontNormalSize"] = 0.900000005960465,
			["fontNormal"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\Normal.ttf",
			["focustarget"] = {
				["style"] = "fat",
			},
			["frameColor"] = {
				0.752941176470588, -- [1]
				0.764705882352941, -- [2]
				0.752941176470588, -- [3]
			},
			["borderType"] = "abu",
			["statusbar"] = "Interface\\TargetingFrame\\UI-StatusBar",
			["targettarget"] = {
				["style"] = "fat",
			},
		},
	}
end

StaticPopupDialogs.SETTINGS_ALL = {
	text = L.Popup.SettingsAll,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		if K.CheckAddOn("DBM-Core") and C.Skins.DBM then K.UploadDBM() end
		if K.CheckAddOn("MikScrollingBattleText") then UploadMSBT() end
		if K.CheckAddOn("Skada") then UploadSkada() end
		if K.CheckAddOn("oUF_Abu") then UploadAbu() end
		ReloadUI()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

SlashCmdList.SETTINGS = function(msg)
	if msg == "dbm" then
		if K.CheckAddOn("DBM-Core") then
			if C.Skins.DBM == true then
				StaticPopup_Show("SETTINGS_DBM")
			else
				print("|cffffff00"..L.Info.SkinDisabled1.."DBM"..L.Info.SkinDisabled2.."|r")
			end
		else
			print("|cffffff00DBM"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "msbt" then
		if K.CheckAddOn("MikScrollingBattleText") then
			UploadMSBT()
			ReloadUI()
		else
			print("|cffffff00MSBT"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "skada" then
		if K.CheckAddOn("Skada") then
			UploadSkada()
			ReloadUI()
		else
			print("|cffffff00Skada"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "abu" then
		if K.CheckAddOn("oUF_Abu") then
			UploadAbu()
			ReloadUI()
		else
			print("|cffffff00oUF_Abu"..L.Info.NotInstalled.."|r")
		end
	elseif msg == "all" then
		StaticPopup_Show("SETTINGS_ALL")
	else
		print("|cffffff00"..L.Info.SettingsDBM.."|r")
		print("|cffffff00"..L.Info.SettingsMSBT.."|r")
		print("|cffffff00"..L.Info.SettingsSKADA.."|r")
		print("|cffffff00"..L.Info.SettingsAbu.."|r")
		print("|cffffff00"..L.Info.SettingsALL.."|r")
	end
end
SLASH_SETTINGS1 = "/settings"