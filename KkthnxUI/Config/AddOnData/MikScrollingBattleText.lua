local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- Wow API
local MSBTProfiles_SavedVars = _G.MSBTProfiles_SavedVars

-- GLOBALS: MikSBT

function K.LoadMSBTProfile()
	if MSBTProfiles_SavedVars then
		table_wipe(MSBTProfiles_SavedVars)
	end
	
	MSBTProfiles_SavedVars["profiles"]["KkthnxUI"] = {
		["scrollAreas"] = {
			["Incoming"] = {
				["behavior"] = "MSBT_NORMAL",
				["offsetY"] = -161,
				["offsetX"] = -330,
				["animationStyle"] = "Straight",
			},
			["Outgoing"] = {
				["direction"] = "Up",
				["offsetX"] = 287,
				["behavior"] = "MSBT_NORMAL",
				["offsetY"] = -161,
				["animationStyle"] = "Straight",
			},
			["Static"] = {
				["offsetX"] = -21,
				["offsetY"] = -231,
			},
		},
		["normalFontName"] = "KkthnxUI_Damage",
		["critFontName"] = "KkthnxUI_Damage",
		["creationVersion"] = MikSBT.VERSION.."."..MikSBT.SVN_REVISION,
	}
	MikSBT.Profiles.SelectProfile("KkthnxUI") -- Automatically set the profile
end