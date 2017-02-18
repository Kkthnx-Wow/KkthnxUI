local K, C, L = unpack(select(2, ...))

local _G = _G

local print = print
local table_wipe = table.wipe

local UploadMSBT = function()
	if MSBTProfiles_SavedVars then table_wipe(MSBTProfiles_SavedVars) end
	if MSBT_SavedMedia then table_wipe(MSBT_SavedMedia) end
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

local UploadDetails = function()
	if _detalhes_global then table_wipe(_detalhes_global) end
	_detalhes_global = {
		["tutorial"] = {
			["unlock_button"] = 0,
			["main_help_button"] = 8,
			["alert_frames"] = {
				false, -- [1]
				false, -- [2]
				false, -- [3]
				false, -- [4]
				false, -- [5]
				false, -- [6]
			},
			["version_announce"] = 0,
			["MEMORY_USAGE_ALERT1"] = true,
			["WINDOW_LOCK_UNLOCK1"] = true,
			["logons"] = 8,
			["OPTIONS_PANEL_OPENED"] = true,
			["ENCOUNTER_DETAILS_BALLON_TUTORIAL1"] = true,
			["ctrl_click_close_tutorial"] = false,
			["bookmark_tutorial"] = true,
			["STREAMER_PLUGIN_FIRSTRUN"] = true,
		},
		["realm_sync"] = true,
		["global_plugin_database"] = {
			["DETAILS_PLUGIN_ENCOUNTER_DETAILS"] = {
				["encounter_timers_bw"] = {
				},
				["encounter_timers_dbm"] = {
				},
			},
		},
		["report_where"] = "SAY",
		["always_use_profile_exception"] = {
		},
		["got_first_run"] = true,
		["details_auras"] = {
		},
		["savedTimeCaptures"] = {
		},
		["always_use_profile_name"] = "",
		["savedStyles"] = {
		},
		["report_pos"] = {
			1, -- [1]
			1, -- [2]
		},
		["latest_report_table"] = {
		},
		["__profiles"] = {
			["KkthnxUI"] = {
				["capture_real"] = {
					["heal"] = true,
					["spellcast"] = true,
					["miscdata"] = true,
					["aura"] = true,
					["energy"] = true,
					["damage"] = true,
				},
				["row_fade_in"] = {
					"in", -- [1]
					0.2, -- [2]
				},
				["player_details_window"] = {
					["scale"] = 1,
					["bar_texture"] = "Skyline",
					["skin"] = "ElvUI",
				},
				["numerical_system"] = 1,
				["use_row_animations"] = true,
				["report_heal_links"] = false,
				["remove_realm_from_name"] = true,
				["class_icons_small"] = "Interface\\AddOns\\Details\\images\\classes_small",
				["report_to_who"] = "",
				["overall_flag"] = 13,
				["profile_save_pos"] = true,
				["tooltip"] = {
					["header_statusbar"] = {
						0.3, -- [1]
						0.3, -- [2]
						0.3, -- [3]
						0.8, -- [4]
						false, -- [5]
						false, -- [6]
						"WorldState Score", -- [7]
					},
					["fontcolor_right"] = {
						1, -- [1]
						0.7, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["tooltip_max_targets"] = 2,
					["icon_size"] = {
						["W"] = 13,
						["H"] = 13,
					},
					["tooltip_max_pets"] = 2,
					["anchor_relative"] = "top",
					["abbreviation"] = 2,
					["anchored_to"] = 1,
					["show_amount"] = false,
					["header_text_color"] = {
						1, -- [1]
						0.9176, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["fontsize"] = 12,
					["background"] = {
						0.0235294117647059, -- [1]
						0.0235294117647059, -- [2]
						0.0235294117647059, -- [3]
						0.900000005960465, -- [4]
					},
					["submenu_wallpaper"] = true,
					["fontsize_title"] = 10,
					["icon_border_texcoord"] = {
						["B"] = 0.921875,
						["L"] = 0.078125,
						["T"] = 0.078125,
						["R"] = 0.921875,
					},
					["commands"] = {
					},
					["tooltip_max_abilities"] = 5,
					["fontface"] = "KkthnxUI_Normal",
					["border_color"] = {
						0.752941176470588, -- [1]
						0.752941176470588, -- [2]
						0.752941176470588, -- [3]
						1, -- [4]
					},
					["border_texture"] = "Blizzard Tooltip",
					["anchor_offset"] = {
						0, -- [1]
						0, -- [2]
					},
					["menus_bg_texture"] = "Interface\\SPELLBOOK\\Spellbook-Page-1",
					["maximize_method"] = 1,
					["border_size"] = 14,
					["fontshadow"] = false,
					["anchor_screen_pos"] = {
						507.7, -- [1]
						-350.5, -- [2]
					},
					["anchor_point"] = "bottom",
					["menus_bg_coords"] = {
						0.309777336120606, -- [1]
						0.924000015258789, -- [2]
						0.213000011444092, -- [3]
						0.279000015258789, -- [4]
					},
					["fontcolor"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						1, -- [4]
					},
					["menus_bg_color"] = {
						0.8, -- [1]
						0.8, -- [2]
						0.8, -- [3]
						0.2, -- [4]
					},
				},
				["ps_abbreviation"] = 3,
				["world_combat_is_trash"] = false,
				["update_speed"] = 0.300000011920929,
				["track_item_level"] = true,
				["windows_fade_in"] = {
					"in", -- [1]
					0.2, -- [2]
				},
				["instances_menu_click_to_open"] = false,
				["overall_clear_newchallenge"] = true,
				["time_type"] = 2,
				["instances_disable_bar_highlight"] = false,
				["trash_concatenate"] = false,
				["disable_stretch_from_toolbar"] = false,
				["disable_lock_ungroup_buttons"] = false,
				["memory_ram"] = 64,
				["disable_window_groups"] = false,
				["instances_suppress_trash"] = 0,
				["font_faces"] = {
					["menus"] = "KkthnxUI_Normal",
				},
				["segments_amount"] = 12,
				["report_lines"] = 5,
				["skin"] = "WoW Interface",
				["override_spellids"] = true,
				["use_battleground_server_parser"] = true,
				["default_bg_alpha"] = 0.5,
				["clear_ungrouped"] = true,
				["chat_tab_embed"] = {
					["enabled"] = false,
					["tab_name"] = "",
					["single_window"] = false,
				},
				["minimum_combat_time"] = 5,
				["animate_scroll"] = false,
				["cloud_capture"] = true,
				["damage_taken_everything"] = false,
				["scroll_speed"] = 2,
				["new_window_size"] = {
					["height"] = 130,
					["width"] = 320,
				},
				["memory_threshold"] = 3,
				["deadlog_events"] = 32,
				["class_specs_coords"] = {
					[62] = {
						0.251953125, -- [1]
						0.375, -- [2]
						0.125, -- [3]
						0.25, -- [4]
					},
					[63] = {
						0.375, -- [1]
						0.5, -- [2]
						0.125, -- [3]
						0.25, -- [4]
					},
					[250] = {
						0, -- [1]
						0.125, -- [2]
						0, -- [3]
						0.125, -- [4]
					},
					[251] = {
						0.125, -- [1]
						0.25, -- [2]
						0, -- [3]
						0.125, -- [4]
					},
					[252] = {
						0.25, -- [1]
						0.375, -- [2]
						0, -- [3]
						0.125, -- [4]
					},
					[253] = {
						0.875, -- [1]
						1, -- [2]
						0, -- [3]
						0.125, -- [4]
					},
					[254] = {
						0, -- [1]
						0.125, -- [2]
						0.125, -- [3]
						0.25, -- [4]
					},
					[255] = {
						0.125, -- [1]
						0.25, -- [2]
						0.125, -- [3]
						0.25, -- [4]
					},
					[66] = {
						0.125, -- [1]
						0.25, -- [2]
						0.25, -- [3]
						0.375, -- [4]
					},
					[257] = {
						0.5, -- [1]
						0.625, -- [2]
						0.25, -- [3]
						0.375, -- [4]
					},
					[258] = {
						0.6328125, -- [1]
						0.75, -- [2]
						0.25, -- [3]
						0.375, -- [4]
					},
					[259] = {
						0.75, -- [1]
						0.875, -- [2]
						0.25, -- [3]
						0.375, -- [4]
					},
					[260] = {
						0.875, -- [1]
						1, -- [2]
						0.25, -- [3]
						0.375, -- [4]
					},
					[577] = {
						0.25, -- [1]
						0.375, -- [2]
						0.5, -- [3]
						0.625, -- [4]
					},
					[262] = {
						0.125, -- [1]
						0.25, -- [2]
						0.375, -- [3]
						0.5, -- [4]
					},
					[581] = {
						0.375, -- [1]
						0.5, -- [2]
						0.5, -- [3]
						0.625, -- [4]
					},
					[264] = {
						0.375, -- [1]
						0.5, -- [2]
						0.375, -- [3]
						0.5, -- [4]
					},
					[265] = {
						0.5, -- [1]
						0.625, -- [2]
						0.375, -- [3]
						0.5, -- [4]
					},
					[266] = {
						0.625, -- [1]
						0.75, -- [2]
						0.375, -- [3]
						0.5, -- [4]
					},
					[267] = {
						0.75, -- [1]
						0.875, -- [2]
						0.375, -- [3]
						0.5, -- [4]
					},
					[268] = {
						0.625, -- [1]
						0.75, -- [2]
						0.125, -- [3]
						0.25, -- [4]
					},
					[269] = {
						0.875, -- [1]
						1, -- [2]
						0.125, -- [3]
						0.25, -- [4]
					},
					[270] = {
						0.75, -- [1]
						0.875, -- [2]
						0.125, -- [3]
						0.25, -- [4]
					},
					[70] = {
						0.251953125, -- [1]
						0.375, -- [2]
						0.25, -- [3]
						0.375, -- [4]
					},
					[102] = {
						0.375, -- [1]
						0.5, -- [2]
						0, -- [3]
						0.125, -- [4]
					},
					[71] = {
						0.875, -- [1]
						1, -- [2]
						0.375, -- [3]
						0.5, -- [4]
					},
					[103] = {
						0.5, -- [1]
						0.625, -- [2]
						0, -- [3]
						0.125, -- [4]
					},
					[72] = {
						0, -- [1]
						0.125, -- [2]
						0.5, -- [3]
						0.625, -- [4]
					},
					[104] = {
						0.625, -- [1]
						0.75, -- [2]
						0, -- [3]
						0.125, -- [4]
					},
					[73] = {
						0.125, -- [1]
						0.25, -- [2]
						0.5, -- [3]
						0.625, -- [4]
					},
					[64] = {
						0.5, -- [1]
						0.625, -- [2]
						0.125, -- [3]
						0.25, -- [4]
					},
					[105] = {
						0.75, -- [1]
						0.875, -- [2]
						0, -- [3]
						0.125, -- [4]
					},
					[65] = {
						0, -- [1]
						0.125, -- [2]
						0.25, -- [3]
						0.375, -- [4]
					},
					[256] = {
						0.375, -- [1]
						0.5, -- [2]
						0.25, -- [3]
						0.375, -- [4]
					},
					[261] = {
						0, -- [1]
						0.125, -- [2]
						0.375, -- [3]
						0.5, -- [4]
					},
					[263] = {
						0.25, -- [1]
						0.375, -- [2]
						0.375, -- [3]
						0.5, -- [4]
					},
				},
				["close_shields"] = false,
				["class_coords"] = {
					["HUNTER"] = {
						0, -- [1]
						0.25, -- [2]
						0.25, -- [3]
						0.5, -- [4]
					},
					["WARRIOR"] = {
						0, -- [1]
						0.25, -- [2]
						0, -- [3]
						0.25, -- [4]
					},
					["SHAMAN"] = {
						0.25, -- [1]
						0.49609375, -- [2]
						0.25, -- [3]
						0.5, -- [4]
					},
					["MAGE"] = {
						0.25, -- [1]
						0.49609375, -- [2]
						0, -- [3]
						0.25, -- [4]
					},
					["PET"] = {
						0.25, -- [1]
						0.49609375, -- [2]
						0.75, -- [3]
						1, -- [4]
					},
					["DRUID"] = {
						0.7421875, -- [1]
						0.98828125, -- [2]
						0, -- [3]
						0.25, -- [4]
					},
					["MONK"] = {
						0.5, -- [1]
						0.73828125, -- [2]
						0.5, -- [3]
						0.75, -- [4]
					},
					["DEATHKNIGHT"] = {
						0.25, -- [1]
						0.5, -- [2]
						0.5, -- [3]
						0.75, -- [4]
					},
					["MONSTER"] = {
						0, -- [1]
						0.25, -- [2]
						0.75, -- [3]
						1, -- [4]
					},
					["UNKNOW"] = {
						0.5, -- [1]
						0.75, -- [2]
						0.75, -- [3]
						1, -- [4]
					},
					["PRIEST"] = {
						0.49609375, -- [1]
						0.7421875, -- [2]
						0.25, -- [3]
						0.5, -- [4]
					},
					["ROGUE"] = {
						0.49609375, -- [1]
						0.7421875, -- [2]
						0, -- [3]
						0.25, -- [4]
					},
					["Alliance"] = {
						0.49609375, -- [1]
						0.7421875, -- [2]
						0.75, -- [3]
						1, -- [4]
					},
					["WARLOCK"] = {
						0.7421875, -- [1]
						0.98828125, -- [2]
						0.25, -- [3]
						0.5, -- [4]
					},
					["DEMONHUNTER"] = {
						0.73828126, -- [1]
						1, -- [2]
						0.5, -- [3]
						0.75, -- [4]
					},
					["Horde"] = {
						0.7421875, -- [1]
						0.98828125, -- [2]
						0.75, -- [3]
						1, -- [4]
					},
					["PALADIN"] = {
						0, -- [1]
						0.25, -- [2]
						0.5, -- [3]
						0.75, -- [4]
					},
					["UNGROUPPLAYER"] = {
						0.5, -- [1]
						0.75, -- [2]
						0.75, -- [3]
						1, -- [4]
					},
					["ENEMY"] = {
						0, -- [1]
						0.25, -- [2]
						0.75, -- [3]
						1, -- [4]
					},
				},
				["overall_clear_logout"] = false,
				["disable_alldisplays_window"] = false,
				["pvp_as_group"] = true,
				["force_activity_time_pvp"] = true,
				["windows_fade_out"] = {
					"out", -- [1]
					0.2, -- [2]
				},
				["death_tooltip_width"] = 300,
				["clear_graphic"] = true,
				["hotcorner_topleft"] = {
					["hide"] = false,
				},
				["segments_auto_erase"] = 1,
				["options_group_edit"] = true,
				["segments_amount_to_save"] = 5,
				["minimap"] = {
					["onclick_what_todo"] = 1,
					["radius"] = 160,
					["text_type"] = 1,
					["minimapPos"] = 220,
					["text_format"] = 3,
					["hide"] = false,
				},
				["instances_amount"] = 5,
				["max_window_size"] = {
					["height"] = 450,
					["width"] = 480,
				},
				["trash_auto_remove"] = true,
				["only_pvp_frags"] = false,
				["disable_stretch_button"] = false,
				["time_type_original"] = 2,
				["default_bg_color"] = 0.0941,
				["numerical_system_symbols"] = "auto",
				["segments_panic_mode"] = true,
				["window_clamp"] = {
					-8, -- [1]
					0, -- [2]
					21, -- [3]
					-14, -- [4]
				},
				["standard_skin"] = false,
				["row_fade_out"] = {
					"out", -- [1]
					0.2, -- [2]
				},
				["use_scroll"] = false,
				["class_colors"] = {
					["HUNTER"] = {
						0.67, -- [1]
						0.83, -- [2]
						0.45, -- [3]
					},
					["WARRIOR"] = {
						0.78, -- [1]
						0.61, -- [2]
						0.43, -- [3]
					},
					["ROGUE"] = {
						1, -- [1]
						0.96, -- [2]
						0.41, -- [3]
					},
					["MAGE"] = {
						0.41, -- [1]
						0.8, -- [2]
						0.94, -- [3]
					},
					["ARENA_YELLOW"] = {
						0.9, -- [1]
						0.9, -- [2]
						0, -- [3]
					},
					["UNGROUPPLAYER"] = {
						0.4, -- [1]
						0.4, -- [2]
						0.4, -- [3]
					},
					["DRUID"] = {
						1, -- [1]
						0.49, -- [2]
						0.04, -- [3]
					},
					["MONK"] = {
						0, -- [1]
						1, -- [2]
						0.59, -- [3]
					},
					["DEATHKNIGHT"] = {
						0.77, -- [1]
						0.12, -- [2]
						0.23, -- [3]
					},
					["PET"] = {
						0.3, -- [1]
						0.4, -- [2]
						0.5, -- [3]
					},
					["UNKNOW"] = {
						0.2, -- [1]
						0.2, -- [2]
						0.2, -- [3]
					},
					["PRIEST"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
					},
					["WARLOCK"] = {
						0.58, -- [1]
						0.51, -- [2]
						0.79, -- [3]
					},
					["PALADIN"] = {
						0.96, -- [1]
						0.55, -- [2]
						0.73, -- [3]
					},
					["ENEMY"] = {
						0.94117, -- [1]
						0, -- [2]
						0.0196, -- [3]
						1, -- [4]
					},
					["DEMONHUNTER"] = {
						0.64, -- [1]
						0.19, -- [2]
						0.79, -- [3]
					},
					["version"] = 1,
					["NEUTRAL"] = {
						1, -- [1]
						1, -- [2]
						0, -- [3]
					},
					["SHAMAN"] = {
						0, -- [1]
						0.44, -- [2]
						0.87, -- [3]
					},
					["ARENA_GREEN"] = {
						0.1, -- [1]
						0.85, -- [2]
						0.1, -- [3]
					},
				},
				["total_abbreviation"] = 2,
				["report_schema"] = 1,
				["overall_clear_newboss"] = true,
				["font_sizes"] = {
					["menus"] = 12,
				},
				["disable_reset_button"] = false,
				["data_broker_text"] = "",
				["instances_no_libwindow"] = false,
				["instances_segments_locked"] = false,
				["deadlog_limit"] = 16,
				["instances"] = {
					{
						["__pos"] = {
							["normal"] = {
								["y"] = -489.00004196167,
								["x"] = 430.001098632813,
								["w"] = 260.000244140625,
								["h"] = 95.9998474121094,
							},
							["solo"] = {
								["y"] = 2,
								["x"] = 1,
								["w"] = 300,
								["h"] = 200,
							},
						},
						["show_statusbar"] = false,
						["menu_icons_size"] = 1,
						["color"] = {
							0.333333333333333, -- [1]
							0.333333333333333, -- [2]
							0.333333333333333, -- [3]
							0, -- [4]
						},
						["menu_anchor"] = {
							16, -- [1]
							1, -- [2]
							["side"] = 2,
						},
						["bg_r"] = 0.0235294117647059,
						["switch_healer_in_combat"] = false,
						["switch_all_roles_after_wipe"] = false,
						["skin"] = "Minimalistic",
						["__was_opened"] = true,
						["following"] = {
							["enabled"] = false,
							["bar_color"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
							},
							["text_color"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
							},
						},
						["color_buttons"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							1, -- [4]
						},
						["switch_healer"] = false,
						["skin_custom"] = "",
						["grab_on_top"] = false,
						["hide_in_combat_type"] = 1,
						["menu_anchor_down"] = {
							16, -- [1]
							-3, -- [2]
						},
						["micro_displays_locked"] = true,
						["tooltip"] = {
							["n_abilities"] = 3,
							["n_enemies"] = 3,
						},
						["StatusBarSaved"] = {
							["center"] = "DETAILS_STATUSBAR_PLUGIN_CLOCK",
							["right"] = "DETAILS_STATUSBAR_PLUGIN_PDPS",
							["options"] = {
								["DETAILS_STATUSBAR_PLUGIN_PDPS"] = {
									["textYMod"] = 1,
									["textXMod"] = 0,
									["textFace"] = "Accidental Presidency",
									["textAlign"] = 0,
									["textStyle"] = 2,
									["textSize"] = 10,
									["textColor"] = {
										1, -- [1]
										1, -- [2]
										1, -- [3]
										1, -- [4]
									},
								},
								["DETAILS_STATUSBAR_PLUGIN_THREAT"] = {
									["isHidden"] = false,
									["textStyle"] = 2,
									["textYMod"] = 1,
									["segmentType"] = 2,
									["textXMod"] = 0,
									["textFace"] = "Accidental Presidency",
									["textAlign"] = 0,
									["textSize"] = 10,
									["textColor"] = {
										1, -- [1]
										1, -- [2]
										1, -- [3]
										1, -- [4]
									},
								},
								["DETAILS_STATUSBAR_PLUGIN_CLOCK"] = {
									["textColor"] = {
										1, -- [1]
										1, -- [2]
										1, -- [3]
										1, -- [4]
									},
									["textFace"] = "Accidental Presidency",
									["textXMod"] = 6,
									["textAlign"] = 0,
									["timeType"] = 1,
									["textStyle"] = 2,
									["textSize"] = 10,
									["textYMod"] = 1,
								},
							},
							["left"] = "DETAILS_STATUSBAR_PLUGIN_THREAT",
						},
						["total_bar"] = {
							["enabled"] = false,
							["only_in_group"] = true,
							["icon"] = "Interface\\ICONS\\INV_Sigil_Thorim",
							["color"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
							},
						},
						["switch_all_roles_in_combat"] = false,
						["instance_button_anchor"] = {
							-27, -- [1]
							1, -- [2]
						},
						["version"] = 3,
						["row_info"] = {
							["textR_outline"] = false,
							["spec_file"] = "Interface\\AddOns\\Details\\images\\spec_icons_normal",
							["textL_outline"] = false,
							["textR_outline_small"] = true,
							["textL_outline_small"] = true,
							["textL_enable_custom_text"] = false,
							["fixed_text_color"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
							},
							["space"] = {
								["right"] = 0,
								["left"] = 0,
								["between"] = 0,
							},
							["texture_background_class_color"] = false,
							["textL_outline_small_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["font_face_file"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\Normal.ttf",
							["textL_custom_text"] = "{data1}. {data3}{data2}",
							["font_size"] = 12,
							["height"] = 19,
							["texture_file"] = "Interface\\TargetingFrame\\UI-StatusBar",
							["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small_alpha",
							["textR_bracket"] = "(",
							["models"] = {
								["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
								["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
								["upper_alpha"] = 0.5,
								["lower_enabled"] = false,
								["lower_alpha"] = 0.1,
								["upper_enabled"] = false,
							},
							["use_spec_icons"] = false,
							["textR_enable_custom_text"] = false,
							["backdrop"] = {
								["enabled"] = false,
								["size"] = 12,
								["color"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									1, -- [4]
								},
								["texture"] = "Details BarBorder 2",
							},
							["fixed_texture_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
							},
							["textL_show_number"] = false,
							["start_after_icon"] = true,
							["texture_background_file"] = "Interface\\TargetingFrame\\UI-StatusBar",
							["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
							["fixed_texture_background_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								0.150228589773178, -- [4]
							},
							["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
							["textR_show_data"] = {
								true, -- [1]
								true, -- [2]
								true, -- [3]
							},
							["textR_class_colors"] = false,
							["textL_class_colors"] = false,
							["textR_outline_small_color"] = {
								0, -- [1]
								0, -- [2]
								0, -- [3]
								1, -- [4]
							},
							["texture_background"] = "KkthnxUI_StatusBar",
							["alpha"] = 1,
							["no_icon"] = false,
							["texture_custom"] = "",
							["percent_type"] = 1,
							["font_face"] = "KkthnxUI_Normal",
							["texture_class_colors"] = true,
							["texture"] = "KkthnxUI_StatusBar",
							["fast_ps_update"] = false,
							["textR_separator"] = ",",
							["texture_custom_file"] = "Interface\\",
						},
						["__locked"] = true,
						["menu_alpha"] = {
							["enabled"] = false,
							["onenter"] = 1,
							["iconstoo"] = true,
							["ignorebars"] = false,
							["onleave"] = 1,
						},
						["attribute_text"] = {
							["enabled"] = true,
							["shadow"] = false,
							["side"] = 1,
							["text_size"] = 12,
							["custom_text"] = "{name}",
							["text_face"] = "KkthnxUI_Normal",
							["anchor"] = {
								-18, -- [1]
								3, -- [2]
							},
							["text_color"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
							},
							["enable_custom_text"] = false,
							["show_timer"] = {
								true, -- [1]
								true, -- [2]
								true, -- [3]
							},
						},
						["show_sidebars"] = false,
						["row_show_animation"] = {
							["anim"] = "Fade",
							["options"] = {
							},
						},
						["strata"] = "LOW",
						["micro_displays_side"] = 2,
						["__snap"] = {
						},
						["ignore_mass_showhide"] = false,
						["hide_in_combat_alpha"] = 0,
						["plugins_grow_direction"] = 1,
						["menu_icons"] = {
							true, -- [1]
							true, -- [2]
							true, -- [3]
							true, -- [4]
							true, -- [5]
							false, -- [6]
							["space"] = -2,
							["shadow"] = true,
						},
						["switch_damager"] = false,
						["auto_hide_menu"] = {
							["left"] = false,
							["right"] = false,
						},
						["switch_damager_in_combat"] = false,
						["window_scale"] = 1,
						["bg_alpha"] = 0.900000005960465,
						["bars_grow_direction"] = 1,
						["statusbar_info"] = {
							["alpha"] = 0,
							["overlay"] = {
								0.333333333333333, -- [1]
								0.333333333333333, -- [2]
								0.333333333333333, -- [3]
							},
						},
						["hide_icon"] = true,
						["libwindow"] = {
							["y"] = 2.99997305870056,
							["x"] = -399.998779296875,
							["point"] = "BOTTOMRIGHT",
						},
						["bg_b"] = 0.0235294117647059,
						["auto_current"] = true,
						["toolbar_side"] = 1,
						["bg_g"] = 0.0235294117647059,
						["switch_tank_in_combat"] = false,
						["hide_in_combat"] = false,
						["posicao"] = {
							["normal"] = {
								["y"] = -489.00004196167,
								["x"] = 430.001098632813,
								["w"] = 260.000244140625,
								["h"] = 95.9998474121094,
							},
							["solo"] = {
								["y"] = 2,
								["x"] = 1,
								["w"] = 300,
								["h"] = 200,
							},
						},
						["backdrop_texture"] = "Blizzard Tooltip",
						["switch_tank"] = false,
						["wallpaper"] = {
							["enabled"] = false,
							["texcoord"] = {
								0, -- [1]
								1, -- [2]
								0, -- [3]
								0.7, -- [4]
							},
							["overlay"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
							},
							["anchor"] = "all",
							["height"] = 114.042518615723,
							["alpha"] = 0.5,
							["width"] = 283.000183105469,
						},
						["stretch_button_side"] = 1,
						["hide_out_of_combat"] = false,
						["bars_sort_direction"] = 1,
						["desaturated_menu"] = false,
						["bars_inverted"] = false,
					}, -- [1]
				},
			},
		},
		["always_use_profile"] = false,
		["lastUpdateWarning"] = 0,
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
	elseif msg == "all" then
		StaticPopup_Show("SETTINGS_ALL")
	else
		print("|cffffff00"..L.Info.SettingsDBM.."|r")
		print("|cffffff00"..L.Info.SettingsMSBT.."|r")
		print("|cffffff00"..L.Info.SettingsSKADA.."|r")
		print("|cffffff00"..L.Info.SettingsALL.."|r")
	end
end
SLASH_SETTINGS1 = "/settings"