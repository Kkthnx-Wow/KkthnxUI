--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Central orchestration for the Skins module.
-- - Design: Registers and loads skins for Blizzard UI and external addons.
-- - Events: ADDON_LOADED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Skins")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local geterrorhandler = _G.geterrorhandler
local ipairs = _G.ipairs
local next = _G.next
local pairs = _G.pairs
local pcall = _G.pcall
local type = _G.type
local xpcall = _G.xpcall

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local table_wipe = _G.table.wipe
local tostring = _G.tostring

-- REASON: Store themes in C namespace for cross-module accessibility.
C.defaultThemes = {}
C.themes = {}
C.otherSkins = {}

-- REASON: Provide a hook for external modules to register their own skins.
function Module:RegisterSkin(addonName, skinFunction)
	C.otherSkins[addonName] = skinFunction
end

-- REASON: Iteratively load skins for addons that are confirmed as loaded.
function Module:LoadSkins(skinList)
	if not next(skinList) then
		return
	end

	for addonName, skinFunction in pairs(skinList) do
		local isLoaded, isFinished = C_AddOns_IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			if type(skinFunction) == "function" then
				skinFunction()
			end
			skinList[addonName] = nil
		end
	end
end

-- REASON: Initialize default and registered skins, and setup listener for future addon loads.
function Module:LoadDefaultSkins()
	-- WARNING: Abort if other skinning engines are detected to avoid conflicts/double-skinning.
	if C_AddOns_IsAddOnLoaded("AuroraClassic") or C_AddOns_IsAddOnLoaded("Aurora") then
		return
	end

	for _, defaultSkinFunction in pairs(C.defaultThemes) do
		xpcall(defaultSkinFunction, geterrorhandler())
	end
	table_wipe(C.defaultThemes)

	if not C["Skins"].BlizzardFrames then
		table_wipe(C.themes)
	end

	Module:LoadSkins(C.themes)
	Module:LoadSkins(C.otherSkins)

	K:RegisterEvent("ADDON_LOADED", function(_, addonName)
		local blizzardSkinFunction = C.themes[addonName]
		if blizzardSkinFunction then
			xpcall(blizzardSkinFunction, geterrorhandler())
			C.themes[addonName] = nil
		end

		local otherSkinFunction = C.otherSkins[addonName]
		if otherSkinFunction then
			xpcall(otherSkinFunction, geterrorhandler())
			C.otherSkins[addonName] = nil
		end
	end)
end

function Module:OnEnable()
	local loadSkinModules = {
		"LoadDefaultSkins",

		"ReskinBartender4",
		"ReskinNekometer",
		-- "ReskinBigWigs",
		"ReskinButtonForge",
		"ReskinChocolateBar",
		"ReskinDeadlyBossMods",
		"ReskinDominos",
		"ReskinRareScanner",
		"ReskinSimulationcraft",
	}

	for _, funcName in ipairs(loadSkinModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				_G.error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
