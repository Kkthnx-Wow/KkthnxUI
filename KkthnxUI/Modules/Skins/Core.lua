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
local type = _G.type
local xpcall = _G.xpcall

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local table_wipe = _G.table.wipe

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

	local errorHandler = geterrorhandler()
	for addonName, skinFunction in pairs(skinList) do
		local isLoaded, isFinished = C_AddOns_IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			if type(skinFunction) == "function" then
				xpcall(skinFunction, errorHandler)
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

	-- FIX: Cache once — geterrorhandler() was being called on every single skin in the loop.
	local errorHandler = geterrorhandler()

	-- FIX: ipairs instead of pairs — C.defaultThemes is an ordered array built with tinsert.
	-- pairs doesn't guarantee insertion order, so skins that depend on others could run
	-- out of sequence and produce nil-reference errors.
	for _, defaultSkinFunction in ipairs(C.defaultThemes) do
		xpcall(defaultSkinFunction, errorHandler)
	end
	table_wipe(C.defaultThemes)

	if not C["Skins"].BlizzardFrames then
		table_wipe(C.themes)
	end

	Module:LoadSkins(C.themes)
	Module:LoadSkins(C.otherSkins)

	-- FIX: Guard against double-registration. LoadDefaultSkins should only run once, but
	-- if called again (e.g. on profile reload) this prevents stacking ADDON_LOADED handlers
	-- that would fire each skin function multiple times.
	if self._addonLoadedRegistered then
		return
	end
	self._addonLoadedRegistered = true

	K:RegisterEvent("ADDON_LOADED", function(_, addonName)
		-- FIX: Cache per-event instead of calling geterrorhandler() twice per addon load.
		local eh = geterrorhandler()

		local blizzardSkinFunction = C.themes[addonName]
		if blizzardSkinFunction then
			xpcall(blizzardSkinFunction, eh)
			C.themes[addonName] = nil
		end

		local otherSkinFunction = C.otherSkins[addonName]
		if otherSkinFunction then
			xpcall(otherSkinFunction, eh)
			C.otherSkins[addonName] = nil
		end
	end)
end

function Module:OnEnable()
	local loadSkinModules = {
		"LoadDefaultSkins",

		"ReskinBartender4",
		"ReskinNekometer",
		"ReskinButtonForge",
		"ReskinChocolateBar",
		"ReskinDeadlyBossMods",
		"ReskinDominos",
		"ReskinRareScanner",
		"ReskinSimulationcraft",
	}

	-- FIX: Use xpcall with a cached error handler instead of pcall + _G.error().
	-- The old pattern caught errors then re-raised them via error(), which stopped the
	-- entire loop — every skin after the failing one would silently never load.
	-- xpcall passes failures to the error handler and lets the loop continue.
	local errorHandler = geterrorhandler()
	local self_ = self
	for _, funcName in ipairs(loadSkinModules) do
		local func = self[funcName]
		if type(func) == "function" then
			xpcall(function()
				func(self_)
			end, errorHandler)
		end
	end
end

local function ApplyFontSize(fontObject, size)
	if not fontObject or not fontObject.SetFont then
		return
	end

	local font, _, style = KkthnxUIFont:GetFont()
	fontObject:SetFont(font, size, style or "")
end

function Module:UpdateQuestFonts()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local size = C["Skins"].QuestFontSize or 11
	local questFonts = {
		_G.QuestFont,
		_G.QuestFont_Shadow_Small,
		_G.QuestFont_Shadow_Huge,
		_G.QuestFont_Large,
		_G.QuestFont_Huge,
		_G.QuestFont_Super_Huge,
	}

	for i = 1, #questFonts do
		ApplyFontSize(questFonts[i], size)
	end
end

function Module:UpdateObjectiveFonts()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local size = C["Skins"].ObjectiveFontSize or 12
	local objectiveFonts = {
		_G.ObjectiveTrackerFont12,
		_G.ObjectiveTrackerLineFont,
		_G.GameFontNormalMed2,
	}

	for i = 1, #objectiveFonts do
		ApplyFontSize(objectiveFonts[i], size)
	end
end
