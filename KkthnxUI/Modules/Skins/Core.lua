local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Skins")

local table_wipe = table.wipe

local IsAddOnLoaded = IsAddOnLoaded

-- Tables to store default themes, registered themes and other skins
C.defaultThemes = {}
C.themes = {}
C.otherSkins = {}

-- Function to register a skin for an external addon
function Module:RegisterSkin(addonName, skinFunction)
	C.otherSkins[addonName] = skinFunction
end

-- Function to load skins from a given list
function Module:LoadSkins(skinList)
	-- Check if the list is empty
	if not next(skinList) then
		return
	end

	-- Iterate through the list of skins
	for addonName, skinFunction in pairs(skinList) do
		local isLoaded, isFinished = IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			-- Call the skin function if the addon is loaded
			skinFunction()
			skinList[addonName] = nil
		end
	end
end

-- Function to load default skins
function Module:LoadDefaultSkins()
	-- Return if either Aurora or AuroraClassic is loaded
	if IsAddOnLoaded("AuroraClassic") or IsAddOnLoaded("Aurora") then
		return
	end

	-- Load default themes
	for _, defaultSkinFunction in pairs(C.defaultThemes) do
		defaultSkinFunction()
	end
	table_wipe(C.defaultThemes)

	-- Don't load Blizzard frame skins if the option is disabled
	if not C["Skins"].BlizzardFrames then
		table_wipe(C.themes)
	end

	-- Load skins for Blizzard frames and other addons
	Module:LoadSkins(C.themes)
	Module:LoadSkins(C.otherSkins)

	-- Register an event to load skins when addons are loaded
	K:RegisterEvent("ADDON_LOADED", function(_, addonName)
		-- Load skin for a Blizzard frame
		local blizzardSkinFunction = C.themes[addonName]
		if blizzardSkinFunction then
			blizzardSkinFunction()
			C.themes[addonName] = nil
		end

		-- Load skin for an external addon
		local otherSkinFunction = C.otherSkins[addonName]
		if otherSkinFunction then
			otherSkinFunction()
			C.otherSkins[addonName] = nil
		end
	end)
end

function Module:OnEnable()
	-- Add Skins
	local loadSkinModules = {
		"LoadDefaultSkins",

		"ReskinBartender4",
		-- "ReskinBigWigs",
		"ReskinButtonForge",
		"ReskinChocolateBar",
		"ReskinDeadlyBossMods",
		"ReskinDominos",
		"ReskinRareScanner",
		"ReskinSimulationcraft",
	}

	for _, funcName in ipairs(loadSkinModules) do
		pcall(self[funcName], self)
	end
end
