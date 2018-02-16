local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- GLOBALS: SkadaDB, Skada

function K.LoadSkadaProfile()
	if SkadaDB then
		table_wipe(SkadaDB)
	end

	SkadaDB = {
		["profiles"] = {
			["Default"] = {
				["showself"] = false,
				["autostop"] = true,
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
				["hidedisables"] = false,
				["onlykeepbosses"] = true,
			},
		},
	}
	Skada.db:SetProfile("Default") -- Automatically set the profile
end