local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Skins")

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local table_wipe = table.wipe

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

-- Function to load default skins
function Module:LoadDefaultSkins()
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
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
