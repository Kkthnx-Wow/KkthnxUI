local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Localize WoW API functions
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Texture_GetAtlasInfo = C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = C_VignetteInfo.GetVignettePosition
local GetInstanceInfo = GetInstanceInfo
local UIErrorsFrame = UIErrorsFrame
local PlaySound = PlaySound
local date = date
local format = string.format
local strfind = string.find
local print = print
local debugprofilestop = debugprofilestop
local table_wipe = table.wipe

-- Cache for rare alerts and ignored zones
-- Cache recently alerted vignettes with timestamps to avoid spam
local RareAlertCache = {} -- table<vignetteGUID|id, lastAlertTime>
local rareCacheSize = 0
local RARE_ALERT_TTL = 90 -- seconds to suppress repeats for the same vignette
local RARE_ALERT_MAX = 256 -- hard cap before a soft cleanup
local nextGlobalAlertAt = 0 -- global throttle to avoid bursts
local isIgnoredZone = {
	[1153] = true, -- 部落要塞
	[1159] = true, -- 联盟要塞
	[1803] = true, -- 涌泉海滩
	[1876] = true, -- 部落激流堡
	[1943] = true, -- 联盟激流堡
	[2111] = true, -- 黑海岸前线
}
local isIgnoredIDs = {
	[6149] = true, -- 奥妮克希亚龙蛋
	[6699] = true, -- 错放的奇珍，地下堡
}

-- Helper function to determine if the vignette atlas is useful
local function isUsefulAtlas(info)
	local atlas = info.atlasName
	if not atlas then
		return
	end
	return strfind(atlas, "Vignette", 1, true) or strfind(atlas, "vignette", 1, true) or atlas == "nazjatar-nagaevent"
end

-- Lightweight profiling helpers (opt-in via C["General"].DebugProfiling)
local kkuiProfileMarks = {}
local function KKUI_ProfileStart(key)
	if not (C and C["General"] and C["General"].DebugProfiling) then
		return
	end
	kkuiProfileMarks[key] = debugprofilestop()
end

local function KKUI_ProfileEnd(key)
	if not (C and C["General"] and C["General"].DebugProfiling) then
		return
	end
	local startTime = kkuiProfileMarks[key]
	if startTime then
		local elapsed = debugprofilestop() - startTime
		kkuiProfileMarks[key] = nil
		print("|cFF99CCFFKkthnxUI|r:", key, format("%.2f ms", elapsed))
	end
end

-- Function to handle rare alerts
function Module:RareAlert_Update(id)
	KKUI_ProfileStart("RareAlert_Update")
	if not id then
		KKUI_ProfileEnd("RareAlert_Update")
		return
	end

	local info = C_VignetteInfo_GetVignetteInfo(id)
	if not info or not isUsefulAtlas(info) or isIgnoredIDs[id] then
		KKUI_ProfileEnd("RareAlert_Update")
		return
	end

	-- Anti-spam: suppress repeats of the same vignette within TTL
	local now = GetTime()
	local last = RareAlertCache[info.vignetteGUID or id]
	if last and (now - last) < RARE_ALERT_TTL then
		KKUI_ProfileEnd("RareAlert_Update")
		return
	end

	local vignetteName = info.name
	local atlasInfo = C_Texture_GetAtlasInfo(info.atlasName)
	if not atlasInfo then
		return
	end

	local tex = K.GetTextureStrByAtlas(atlasInfo)
	if not tex then
		KKUI_ProfileEnd("RareAlert_Update")
		return
	end

	-- Global throttle (UIErrorsFrame can be spammed by rapid vignette updates)
	if now >= nextGlobalAlertAt then
		UIErrorsFrame:AddMessage(K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. "[" .. (vignetteName or "") .. "]" .. K.SystemColor .. "!")
		nextGlobalAlertAt = now + 1.0
	end

	-- Chat alert if enabled
	if C["Announcements"].AlertInChat then
		local currentTime = C["Chat"].TimestampFormat == 1 and K.GreyColor .. "[" .. date("%H:%M:%S") .. "]" or ""
		local mapID = C_Map_GetBestMapForUnit("player")
		local position = mapID and C_VignetteInfo_GetVignettePosition(info.vignetteGUID, mapID)
		local nameString = vignetteName

		if position then
			local x, y = position:GetXY()
			nameString = format(Module.RareString, mapID, x * 10000, y * 10000, info.name, x * 100, y * 100, "")
		end

		K.Print(currentTime .. K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. (nameString or "") .. K.SystemColor .. "!")
	end

	-- Play sound if enabled and not in an ignored instance (follows existing semantics)
	if not C["Announcements"].AlertInWild or Module.RareInstType == "none" then
		PlaySound(37881, "Master")
	end

	-- Record seen time and perform lightweight cleanup
	RareAlertCache[info.vignetteGUID or id] = now
	rareCacheSize = rareCacheSize + 1

	-- Limit the size of the cache to prevent overflow
	if rareCacheSize > RARE_ALERT_MAX then
		local pruned = 0
		for key, ts in pairs(RareAlertCache) do
			if (now - (ts or 0)) > RARE_ALERT_TTL then
				RareAlertCache[key] = nil
				pruned = pruned + 1
			end
		end
		if pruned == 0 then
			-- Fallback: full reset to keep memory bounded
			table_wipe(RareAlertCache)
		else
			rareCacheSize = rareCacheSize - pruned
		end
	end
	KKUI_ProfileEnd("RareAlert_Update")
end

-- Function to check the instance type for rare alerts and register/unregister events accordingly
function Module:RareAlert_CheckInstance()
	KKUI_ProfileStart("RareAlert_CheckInstance")
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	local shouldIgnore = (instID and isIgnoredZone[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6))

	if shouldIgnore then
		if Module.RareInstType ~= "none" then
			K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
			Module.RareInstType = "none"
		end
	else
		if Module.RareInstType ~= instanceType then
			K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
			Module.RareInstType = instanceType
		end
	end
	KKUI_ProfileEnd("RareAlert_CheckInstance")
end

-- Function to set up rare alerts
function Module:CreateRareAnnounce()
	Module.RareString = "|Hworldmap:%d:%d:%d|h[%s (%.1f, %.1f)%s]|h|r"

	if C["Announcements"].RareAlert then
		Module:RareAlert_CheckInstance()
		K:RegisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	else
		-- Clear cache on zone change
		table_wipe(RareAlertCache)
		rareCacheSize = 0
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
		K:UnregisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	end
end
