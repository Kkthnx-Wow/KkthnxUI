local K, C = unpack(select(2, ...))
local Module = K:NewModule("Skins")

local _G = _G
local table_wipe = _G.table.wipe

local IsAddOnLoaded = _G.IsAddOnLoaded

C.defaultThemes = {}
C.themes = {}

function Module:LoadDefaultSkins()
	if IsAddOnLoaded("AuroraClassic") or IsAddOnLoaded("Aurora") then
		return
	end

	-- Reskin Blizzard UIs
	for _, func in pairs(C.defaultThemes) do
		func()
	end
	table_wipe(C.defaultThemes)

	if not C["Skins"].BlizzardFrames then
		return
	end

	for addonName, func in pairs(C.themes) do
		local isLoaded, isFinished = IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			func()
			C.themes[addonName] = nil
		end
	end

	K:RegisterEvent("ADDON_LOADED", function(_, addonName)
		local func = C.themes[addonName]
		if func then
			func()
			C.themes[addonName] = nil
		end
	end)
end

function Module:OnEnable()
	Module:LoadDefaultSkins()

	-- Add Skins
	-- self:ReskinBigWigs()
	self:ReskinDeadlyBossMods()
	-- self:ReskinSkada()
end

function Module:LoadWithAddOn(addonName, value, func)
	local function loadFunc(event, addon)
		if not C["Skins"][value] then
			return
		end

		if event == "PLAYER_ENTERING_WORLD" then
			K:UnregisterEvent(event, loadFunc)
			if IsAddOnLoaded(addonName) then
				func()
				K:UnregisterEvent("ADDON_LOADED", loadFunc)
			end
		elseif event == "ADDON_LOADED" and addon == addonName then
			func()
			K:UnregisterEvent(event, loadFunc)
		end
	end

	K:RegisterEvent("PLAYER_ENTERING_WORLD", loadFunc)
	K:RegisterEvent("ADDON_LOADED", loadFunc)
end