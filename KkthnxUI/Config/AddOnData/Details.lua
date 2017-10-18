local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- Wow API
local _detalhes_global = _G._detalhes_global

-- GLOBALS: _detalhes

function K.LoadDetailsProfile()
	if _detalhes_global then
		table_wipe(_detalhes_global)
	end

	_detalhes_global["__profiles"]["KkthnxUI"] = {
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
		["use_row_animations"] = false,
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
			["fontsize"] = 10,
			["background"] = {
				0.196, -- [1]
				0.196, -- [2]
				0.196, -- [3]
				0.8697, -- [4]
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
			["fontface"] = "Friz Quadrata TT",
			["border_color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				0, -- [4]
			},
			["border_texture"] = "Blizzard Tooltip",
			["anchor_offset"] = {
				0, -- [1]
				0, -- [2]
			},
			["menus_bg_texture"] = "Interface\\SPELLBOOK\\Spellbook-Page-1",
			["maximize_method"] = 1,
			["border_size"] = 16,
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
			["menus"] = "Bui Prototype",
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
			["ROGUE"] = {
				0.49609375, -- [1]
				0.7421875, -- [2]
				0, -- [3]
				0.25, -- [4]
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
			["SHAMAN"] = {
				0.25, -- [1]
				0.49609375, -- [2]
				0.25, -- [3]
				0.5, -- [4]
			},
			["Alliance"] = {
				0.49609375, -- [1]
				0.7421875, -- [2]
				0.75, -- [3]
				1, -- [4]
			},
			["ENEMY"] = {
				0, -- [1]
				0.25, -- [2]
				0.75, -- [3]
				1, -- [4]
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
			["WARLOCK"] = {
				0.7421875, -- [1]
				0.98828125, -- [2]
				0.25, -- [3]
				0.5, -- [4]
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
		["segments_panic_mode"] = false,
		["window_clamp"] = {
			-8, -- [1]
			0, -- [2]
			21, -- [3]
			-14, -- [4]
		},
		["standard_skin"] = {
			["show_statusbar"] = false,
			["backdrop_texture"] = "Details Ground",
			["color"] = {
				1, -- [1]
				1, -- [2]
				1, -- [3]
				1, -- [4]
			},
			["menu_anchor"] = {
				16, -- [1]
				2, -- [2]
				["side"] = 2,
			},
			["bg_r"] = 0.3294,
			["skin"] = "ElvUI Frame Style",
			["following"] = {
				["bar_color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
				["enabled"] = false,
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
			["micro_displays_locked"] = true,
			["bg_b"] = 0.3294,
			["tooltip"] = {
				["n_abilities"] = 3,
				["n_enemies"] = 3,
			},
			["desaturated_menu"] = false,
			["switch_tank_in_combat"] = false,
			["switch_all_roles_in_combat"] = false,
			["instance_button_anchor"] = {
				-27, -- [1]
				1, -- [2]
			},
			["bg_alpha"] = 0.51,
			["attribute_text"] = {
				["enabled"] = true,
				["shadow"] = true,
				["side"] = 1,
				["text_color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
					0.7, -- [4]
				},
				["custom_text"] = "{name}",
				["text_face"] = "FORCED SQUARE",
				["anchor"] = {
					-19, -- [1]
					5, -- [2]
				},
				["show_timer"] = {
					true, -- [1]
					true, -- [2]
					true, -- [3]
				},
				["enable_custom_text"] = false,
				["text_size"] = 12,
			},
			["libwindow"] = {
			},
			["menu_alpha"] = {
				["enabled"] = false,
				["onleave"] = 1,
				["ignorebars"] = false,
				["iconstoo"] = true,
				["onenter"] = 1,
			},
			["stretch_button_side"] = 1,
			["micro_displays_side"] = 2,
			["switch_healer_in_combat"] = false,
			["strata"] = "LOW",
			["hide_in_combat_type"] = 1,
			["statusbar_info"] = {
				["alpha"] = 1,
				["overlay"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
			},
			["switch_tank"] = false,
			["hide_in_combat_alpha"] = 0,
			["switch_all_roles_after_wipe"] = false,
			["menu_icons"] = {
				true, -- [1]
				true, -- [2]
				true, -- [3]
				true, -- [4]
				true, -- [5]
				false, -- [6]
				["space"] = -2,
				["shadow"] = false,
			},
			["switch_damager"] = false,
			["show_sidebars"] = true,
			["window_scale"] = 1,
			["bars_grow_direction"] = 1,
			["row_info"] = {
				["textR_outline"] = false,
				["spec_file"] = "Interface\\AddOns\\Details\\images\\spec_icons_normal",
				["textL_outline"] = false,
				["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
				["textL_outline_small"] = true,
				["textL_enable_custom_text"] = false,
				["fixed_text_color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
				},
				["space"] = {
					["right"] = -2,
					["left"] = 1,
					["between"] = 1,
				},
				["texture_background_class_color"] = false,
				["textL_outline_small_color"] = {
					0, -- [1]
					0, -- [2]
					0, -- [3]
					1, -- [4]
				},
				["font_face_file"] = "Interface\\Addons\\Details\\fonts\\FORCED SQUARE.ttf",
				["textL_custom_text"] = "{data1}. {data3}{data2}",
				["font_size"] = 10,
				["height"] = 14,
				["texture_file"] = "Interface\\AddOns\\Details\\images\\bar_skyline",
				["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small_alpha",
				["texture_custom_file"] = "Interface\\",
				["texture_background_file"] = "Interface\\AddOns\\Details\\images\\bar_background",
				["use_spec_icons"] = true,
				["textR_enable_custom_text"] = false,
				["models"] = {
					["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
					["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
					["upper_alpha"] = 0.5,
					["lower_enabled"] = false,
					["lower_alpha"] = 0.1,
					["upper_enabled"] = false,
				},
				["fixed_texture_color"] = {
					0, -- [1]
					0, -- [2]
					0, -- [3]
				},
				["textL_show_number"] = true,
				["fixed_texture_background_color"] = {
					0, -- [1]
					0, -- [2]
					0, -- [3]
					0.339636147022247, -- [4]
				},
				["backdrop"] = {
					["enabled"] = false,
					["texture"] = "Details BarBorder 2",
					["color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["size"] = 4,
				},
				["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
				["texture"] = "Skyline",
				["textR_outline_small"] = true,
				["percent_type"] = 1,
				["textR_show_data"] = {
					true, -- [1]
					true, -- [2]
					true, -- [3]
				},
				["texture_background"] = "DGround",
				["alpha"] = 0.8,
				["textR_class_colors"] = false,
				["textR_outline_small_color"] = {
					0, -- [1]
					0, -- [2]
					0, -- [3]
					1, -- [4]
				},
				["no_icon"] = false,
				["textL_class_colors"] = false,
				["texture_custom"] = "",
				["font_face"] = "FORCED SQUARE",
				["texture_class_colors"] = true,
				["start_after_icon"] = false,
				["fast_ps_update"] = false,
				["textR_separator"] = ",",
				["textR_bracket"] = "(",
			},
			["grab_on_top"] = false,
			["hide_icon"] = true,
			["switch_damager_in_combat"] = false,
			["row_show_animation"] = {
				["anim"] = "Fade",
				["options"] = {
				},
			},
			["bars_sort_direction"] = 1,
			["auto_current"] = true,
			["toolbar_side"] = 1,
			["bg_g"] = 0.3294,
			["menu_anchor_down"] = {
				16, -- [1]
				-2, -- [2]
			},
			["hide_in_combat"] = false,
			["auto_hide_menu"] = {
				["left"] = false,
				["right"] = false,
			},
			["menu_icons_size"] = 0.899999976158142,
			["plugins_grow_direction"] = 1,
			["wallpaper"] = {
				["overlay"] = {
					0.999997794628143, -- [1]
					0.999997794628143, -- [2]
					0.999997794628143, -- [3]
					0.799998223781586, -- [4]
				},
				["width"] = 266.000061035156,
				["texcoord"] = {
					0.0480000019073486, -- [1]
					0.298000011444092, -- [2]
					0.630999984741211, -- [3]
					0.755999984741211, -- [4]
				},
				["enabled"] = true,
				["anchor"] = "all",
				["height"] = 225.999984741211,
				["alpha"] = 0.800000071525574,
				["texture"] = "Interface\\AddOns\\Details\\images\\skins\\elvui",
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
			["hide_out_of_combat"] = false,
			["skin_custom"] = "",
			["ignore_mass_showhide"] = false,
			["bars_inverted"] = false,
		},
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
			["PALADIN"] = {
				0.96, -- [1]
				0.55, -- [2]
				0.73, -- [3]
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
			["ENEMY"] = {
				0.94117, -- [1]
				0, -- [2]
				0.0196, -- [3]
				1, -- [4]
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
			["WARLOCK"] = {
				0.58, -- [1]
				0.51, -- [2]
				0.79, -- [3]
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
			["ROGUE"] = {
				1, -- [1]
				0.96, -- [2]
				0.41, -- [3]
			},
			["PET"] = {
				0.3, -- [1]
				0.4, -- [2]
				0.5, -- [3]
			},
		},
		["total_abbreviation"] = 2,
		["report_schema"] = 1,
		["overall_clear_newboss"] = true,
		["font_sizes"] = {
			["menus"] = 10,
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
						["y"] = -452.999885559082,
						["x"] = 650.000244140625,
						["w"] = 200.000061035156,
						["h"] = 123.999969482422,
					},
					["solo"] = {
						["y"] = 2,
						["x"] = 1,
						["w"] = 300,
						["h"] = 200,
					},
				},
				["hide_in_combat_type"] = 1,
				["backdrop_texture"] = "Details Ground",
				["color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
					1, -- [4]
				},
				["menu_anchor"] = {
					16, -- [1]
					2, -- [2]
					["side"] = 2,
				},
				["__snapV"] = false,
				["__snapH"] = false,
				["bg_r"] = 0.3294,
				["row_show_animation"] = {
					["anim"] = "Fade",
					["options"] = {
					},
				},
				["plugins_grow_direction"] = 1,
				["hide_out_of_combat"] = false,
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
				["bars_sort_direction"] = 1,
				["show_statusbar"] = false,
				["bars_grow_direction"] = 1,
				["menu_anchor_down"] = {
					16, -- [1]
					-2, -- [2]
				},
				["tooltip"] = {
					["n_abilities"] = 3,
					["n_enemies"] = 3,
				},
				["StatusBarSaved"] = {
					["center"] = "DETAILS_STATUSBAR_PLUGIN_CLOCK",
					["right"] = "DETAILS_STATUSBAR_PLUGIN_PDPS",
					["options"] = {
						["DETAILS_STATUSBAR_PLUGIN_PDPS"] = {
							["textColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
							},
							["textXMod"] = 0,
							["textFace"] = "Accidental Presidency",
							["textStyle"] = 2,
							["textAlign"] = 0,
							["textSize"] = 10,
							["textYMod"] = 1,
						},
						["DETAILS_STATUSBAR_PLUGIN_PSEGMENT"] = {
							["textColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
							},
							["segmentType"] = 2,
							["textXMod"] = 0,
							["textFace"] = "Accidental Presidency",
							["textAlign"] = 0,
							["textStyle"] = 2,
							["textSize"] = 10,
							["textYMod"] = 1,
						},
						["DETAILS_STATUSBAR_PLUGIN_CLOCK"] = {
							["textColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								1, -- [4]
							},
							["textStyle"] = 2,
							["textFace"] = "Accidental Presidency",
							["textAlign"] = 0,
							["textXMod"] = 6,
							["timeType"] = 1,
							["textSize"] = 10,
							["textYMod"] = 1,
						},
					},
					["left"] = "DETAILS_STATUSBAR_PLUGIN_PSEGMENT",
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
				["attribute_text"] = {
					["show_timer"] = {
						true, -- [1]
						true, -- [2]
						true, -- [3]
					},
					["shadow"] = true,
					["side"] = 1,
					["text_color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						0.7, -- [4]
					},
					["custom_text"] = "{name}",
					["text_face"] = "Bui Prototype",
					["anchor"] = {
						-2, -- [1]
						3, -- [2]
					},
					["text_size"] = 10,
					["enable_custom_text"] = false,
					["enabled"] = true,
				},
				["__locked"] = true,
				["menu_alpha"] = {
					["enabled"] = false,
					["onenter"] = 1,
					["iconstoo"] = true,
					["ignorebars"] = false,
					["onleave"] = 1,
				},
				["switch_damager_in_combat"] = false,
				["micro_displays_locked"] = true,
				["switch_tank_in_combat"] = false,
				["strata"] = "LOW",
				["grab_on_top"] = false,
				["__snap"] = {
					[3] = 2,
				},
				["switch_tank"] = false,
				["hide_in_combat_alpha"] = 0,
				["switch_all_roles_after_wipe"] = false,
				["menu_icons"] = {
					true, -- [1]
					true, -- [2]
					true, -- [3]
					true, -- [4]
					true, -- [5]
					false, -- [6]
					["space"] = -2,
					["shadow"] = false,
				},
				["switch_damager"] = false,
				["micro_displays_side"] = 2,
				["statusbar_info"] = {
					["alpha"] = 1,
					["overlay"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
					},
				},
				["window_scale"] = 1,
				["libwindow"] = {
					["y"] = 25.0000705718994,
					["x"] = -209.999877929687,
					["point"] = "BOTTOMRIGHT",
				},
				["desaturated_menu"] = true,
				["bars_inverted"] = false,
				["hide_icon"] = false,
				["switch_healer_in_combat"] = false,
				["bg_alpha"] = 0,
				["auto_current"] = true,
				["toolbar_side"] = 1,
				["bg_g"] = 0.3294,
				["skin"] = "ElvUI Frame Style",
				["hide_in_combat"] = false,
				["posicao"] = {
					["normal"] = {
						["y"] = -452.999885559082,
						["x"] = 650.000244140625,
						["w"] = 200.000061035156,
						["h"] = 123.999969482422,
					},
					["solo"] = {
						["y"] = 2,
						["x"] = 1,
						["w"] = 300,
						["h"] = 200,
					},
				},
				["menu_icons_size"] = 0.899999976158142,
				["ignore_mass_showhide"] = false,
				["wallpaper"] = {
					["enabled"] = false,
					["texture"] = "Interface\\AddOns\\Details\\images\\skins\\elvui",
					["texcoord"] = {
						0.0480000019073486, -- [1]
						0.298000011444092, -- [2]
						0.630999984741211, -- [3]
						0.755999984741211, -- [4]
					},
					["overlay"] = {
						0.999997794628143, -- [1]
						0.999997794628143, -- [2]
						0.999997794628143, -- [3]
						0.799998223781586, -- [4]
					},
					["anchor"] = "all",
					["height"] = 225.999984741211,
					["alpha"] = 0.800000071525574,
					["width"] = 266.000061035156,
				},
				["stretch_button_side"] = 1,
				["auto_hide_menu"] = {
					["left"] = true,
					["right"] = false,
				},
				["show_sidebars"] = false,
				["row_info"] = {
					["textR_outline"] = false,
					["spec_file"] = "Interface\\AddOns\\Details\\images\\spec_icons_normal",
					["textL_outline"] = false,
					["textR_outline_small"] = true,
					["textL_outline_small"] = true,
					["percent_type"] = 1,
					["fixed_text_color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
					},
					["space"] = {
						["right"] = 0,
						["left"] = 0,
						["between"] = 2,
					},
					["texture_background_class_color"] = false,
					["start_after_icon"] = false,
					["font_face_file"] = "Interface\\AddOns\\ElvUI_BenikUI\\media\\fonts\\PROTOTYPE.TTF",
					["textL_custom_text"] = "{data1}. {data3}{data2}",
					["font_size"] = 10,
					["texture_custom_file"] = "Interface\\",
					["texture_file"] = "Interface\\AddOns\\ElvUI_BenikUI\\media\\textures\\BuiOnePixel.tga",
					["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small_alpha",
					["use_spec_icons"] = true,
					["models"] = {
						["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
						["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
						["upper_alpha"] = 0.5,
						["lower_enabled"] = false,
						["lower_alpha"] = 0.1,
						["upper_enabled"] = false,
					},
					["textR_bracket"] = "(",
					["textR_enable_custom_text"] = false,
					["backdrop"] = {
						["enabled"] = false,
						["size"] = 4,
						["color"] = {
							0, -- [1]
							0, -- [2]
							0, -- [3]
							1, -- [4]
						},
						["texture"] = "Details BarBorder 2",
					},
					["fixed_texture_color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
					},
					["textL_show_number"] = true,
					["fixed_texture_background_color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						0.339636147022247, -- [4]
					},
					["texture_custom"] = "",
					["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
					["texture"] = "BuiOnePixel",
					["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
					["textL_enable_custom_text"] = false,
					["textR_class_colors"] = false,
					["textL_class_colors"] = true,
					["textR_outline_small_color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["texture_background"] = "BuiEmpty",
					["alpha"] = 0.8,
					["no_icon"] = false,
					["textR_show_data"] = {
						true, -- [1]
						true, -- [2]
						true, -- [3]
					},
					["textL_outline_small_color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["font_face"] = "Bui Prototype",
					["texture_class_colors"] = true,
					["texture_background_file"] = "Interface\\AddOns\\ElvUI_BenikUI\\media\\textures\\Empty.tga",
					["fast_ps_update"] = false,
					["textR_separator"] = ",",
					["height"] = 14,
				},
				["bg_b"] = 0.3294,
			}, -- [1]
			{
				["__pos"] = {
					["normal"] = {
						["y"] = -452.999885559082,
						["x"] = 852.000122070313,
						["w"] = 204.000091552734,
						["h"] = 123.999969482422,
					},
					["solo"] = {
						["y"] = 2,
						["x"] = 1,
						["w"] = 300,
						["h"] = 200,
					},
				},
				["hide_in_combat_type"] = 1,
				["backdrop_texture"] = "Details Ground",
				["color"] = {
					1, -- [1]
					1, -- [2]
					1, -- [3]
					1, -- [4]
				},
				["menu_anchor"] = {
					16, -- [1]
					2, -- [2]
					["side"] = 2,
				},
				["__snapV"] = false,
				["__snapH"] = false,
				["bg_r"] = 0.3294,
				["row_show_animation"] = {
					["anim"] = "Fade",
					["options"] = {
					},
				},
				["plugins_grow_direction"] = 1,
				["hide_out_of_combat"] = false,
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
				["bars_sort_direction"] = 1,
				["show_statusbar"] = false,
				["bars_grow_direction"] = 1,
				["menu_anchor_down"] = {
					16, -- [1]
					-2, -- [2]
				},
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
							["textFace"] = "FORCED SQUARE",
							["textAlign"] = 0,
							["textStyle"] = 2,
							["textSize"] = 10,
							["textColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								0.7, -- [4]
							},
						},
						["DETAILS_STATUSBAR_PLUGIN_THREAT"] = {
							["isHidden"] = false,
							["textStyle"] = 2,
							["textYMod"] = 1,
							["segmentType"] = 2,
							["textXMod"] = 0,
							["textFace"] = "FORCED SQUARE",
							["textAlign"] = 0,
							["textSize"] = 10,
							["textColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								0.7, -- [4]
							},
						},
						["DETAILS_STATUSBAR_PLUGIN_CLOCK"] = {
							["textColor"] = {
								1, -- [1]
								1, -- [2]
								1, -- [3]
								0.7, -- [4]
							},
							["textXMod"] = 6,
							["textFace"] = "FORCED SQUARE",
							["textAlign"] = 0,
							["textStyle"] = 2,
							["timeType"] = 1,
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
				["attribute_text"] = {
					["show_timer"] = {
						true, -- [1]
						true, -- [2]
						true, -- [3]
					},
					["shadow"] = true,
					["side"] = 1,
					["text_color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
						0.7, -- [4]
					},
					["custom_text"] = "{name}",
					["text_face"] = "Bui Prototype",
					["anchor"] = {
						-2, -- [1]
						3, -- [2]
					},
					["text_size"] = 10,
					["enable_custom_text"] = false,
					["enabled"] = true,
				},
				["__locked"] = true,
				["menu_alpha"] = {
					["enabled"] = false,
					["onenter"] = 1,
					["iconstoo"] = true,
					["ignorebars"] = false,
					["onleave"] = 1,
				},
				["switch_damager_in_combat"] = false,
				["micro_displays_locked"] = true,
				["switch_tank_in_combat"] = false,
				["strata"] = "LOW",
				["grab_on_top"] = false,
				["__snap"] = {
					1, -- [1]
				},
				["switch_tank"] = false,
				["hide_in_combat_alpha"] = 0,
				["switch_all_roles_after_wipe"] = false,
				["menu_icons"] = {
					true, -- [1]
					true, -- [2]
					true, -- [3]
					true, -- [4]
					true, -- [5]
					false, -- [6]
					["space"] = -2,
					["shadow"] = false,
				},
				["switch_damager"] = false,
				["micro_displays_side"] = 2,
				["statusbar_info"] = {
					["alpha"] = 1,
					["overlay"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
					},
				},
				["window_scale"] = 1,
				["libwindow"] = {
					["y"] = 25.0000705718994,
					["x"] = -5.9998779296875,
					["point"] = "BOTTOMRIGHT",
				},
				["desaturated_menu"] = true,
				["bars_inverted"] = false,
				["hide_icon"] = false,
				["switch_healer_in_combat"] = false,
				["bg_alpha"] = 0,
				["auto_current"] = true,
				["toolbar_side"] = 1,
				["bg_g"] = 0.3294,
				["skin"] = "ElvUI Frame Style",
				["hide_in_combat"] = false,
				["posicao"] = {
					["normal"] = {
						["y"] = -452.999885559082,
						["x"] = 852.000122070313,
						["w"] = 204.000091552734,
						["h"] = 123.999969482422,
					},
					["solo"] = {
						["y"] = 2,
						["x"] = 1,
						["w"] = 300,
						["h"] = 200,
					},
				},
				["menu_icons_size"] = 0.899999976158142,
				["ignore_mass_showhide"] = false,
				["wallpaper"] = {
					["enabled"] = false,
					["texture"] = "Interface\\AddOns\\Details\\images\\skins\\elvui",
					["texcoord"] = {
						0.0480000019073486, -- [1]
						0.298000011444092, -- [2]
						0.630999984741211, -- [3]
						0.755999984741211, -- [4]
					},
					["overlay"] = {
						0.999997794628143, -- [1]
						0.999997794628143, -- [2]
						0.999997794628143, -- [3]
						0.799998223781586, -- [4]
					},
					["anchor"] = "all",
					["height"] = 225.999984741211,
					["alpha"] = 0.800000071525574,
					["width"] = 266.000061035156,
				},
				["stretch_button_side"] = 1,
				["auto_hide_menu"] = {
					["left"] = true,
					["right"] = false,
				},
				["show_sidebars"] = false,
				["row_info"] = {
					["textR_outline"] = false,
					["spec_file"] = "Interface\\AddOns\\Details\\images\\spec_icons_normal",
					["textL_outline"] = false,
					["textR_outline_small"] = true,
					["textL_outline_small"] = true,
					["percent_type"] = 1,
					["fixed_text_color"] = {
						1, -- [1]
						1, -- [2]
						1, -- [3]
					},
					["space"] = {
						["right"] = 0,
						["left"] = 0,
						["between"] = 2,
					},
					["texture_background_class_color"] = false,
					["start_after_icon"] = false,
					["font_face_file"] = "Interface\\AddOns\\ElvUI_BenikUI\\media\\fonts\\PROTOTYPE.ttf",
					["textL_custom_text"] = "{data1}. {data3}{data2}",
					["font_size"] = 10,
					["texture_custom_file"] = "Interface\\",
					["texture_file"] = "Interface\\AddOns\\ElvUI_BenikUI\\media\\textures\\BuiOnePixel.tga",
					["icon_file"] = "Interface\\AddOns\\Details\\images\\classes_small_alpha",
					["use_spec_icons"] = true,
					["models"] = {
						["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
						["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
						["upper_alpha"] = 0.5,
						["lower_enabled"] = false,
						["lower_alpha"] = 0.1,
						["upper_enabled"] = false,
					},
					["textR_bracket"] = "(",
					["textR_enable_custom_text"] = false,
					["backdrop"] = {
						["enabled"] = false,
						["size"] = 4,
						["color"] = {
							0, -- [1]
							0, -- [2]
							0, -- [3]
							1, -- [4]
						},
						["texture"] = "Details BarBorder 2",
					},
					["fixed_texture_color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
					},
					["textL_show_number"] = true,
					["fixed_texture_background_color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						0.339636147022247, -- [4]
					},
					["texture_custom"] = "",
					["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
					["texture"] = "BuiOnePixel",
					["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
					["textL_enable_custom_text"] = false,
					["textR_class_colors"] = false,
					["textL_class_colors"] = true,
					["textR_outline_small_color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["texture_background"] = "BuiEmpty",
					["alpha"] = 0.8,
					["no_icon"] = false,
					["textR_show_data"] = {
						true, -- [1]
						true, -- [2]
						true, -- [3]
					},
					["textL_outline_small_color"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
						1, -- [4]
					},
					["font_face"] = "Bui Prototype",
					["texture_class_colors"] = true,
					["texture_background_file"] = "Interface\\AddOns\\ElvUI_BenikUI\\media\\textures\\Empty.tga",
					["fast_ps_update"] = false,
					["textR_separator"] = ",",
					["height"] = 14,
				},
				["bg_b"] = 0.3294,
			}, -- [2]
		},
	}
	_detalhes:ApplyProfile("KkthnxUI")
end