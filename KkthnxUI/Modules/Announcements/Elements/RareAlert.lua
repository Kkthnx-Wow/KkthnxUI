-- RareAlert.lua
-- Robust rare vignette announcements with stable dedupe + cooldown + safe event registration.

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Lua locals (cache globals)
local pairs = pairs
local tostring = tostring
local tonumber = tonumber
local type = type

local date = date
local strfind = string.find
local string_format = string.format

local math_floor = math.floor

local table_sort = table.sort
local table_wipe = table.wipe

-- WoW API locals (cache globals)
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Texture_GetAtlasInfo = C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = C_VignetteInfo.GetVignettePosition
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime
local PlaySound = PlaySound
local UIErrorsFrame = UIErrorsFrame

-- Tuning
local DEFAULT_RARE_COOLDOWN = 15 -- seconds: per-rare cooldown (stops doubles)
local RARE_CACHE_RETENTION = 120 -- seconds: how long we keep entries around for pruning
local RARE_CACHE_MAX = 256 -- maximum number of cache entries before pruning
local UIERRORS_THROTTLE = 1.0 -- seconds: global UIErrorsFrame throttle
local LASTSIG_GUARD = 0.30 -- seconds: last-ditch spam guard (handles double-registered callbacks)

-- Ignore lists (as provided)
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

-- State
local RareAlertCache = {} -- table<string, number>
local RareCacheSize = 0
local nextGlobalAlertAt = 0

local lastSig, lastSigAt = nil, 0

-- Helpers
local function GetRareCooldown()
	-- Optional: if you later add a config slider, it can live here.
	-- Supports: C.Announcements.RareCooldown or C["Announcements"].RareCooldown
	local a = C and C.Announcements
	local c = a and a.RareCooldown or (C and C["Announcements"] and C["Announcements"].RareCooldown)
	local v = tonumber(c)
	if v and v > 0 then
		return v
	end
	return DEFAULT_RARE_COOLDOWN
end

local function IsUsefulAtlas(info)
	local atlas = info and info.atlasName
	if not atlas then
		return false
	end
	-- Some servers use different casing; match both.
	return strfind(atlas, "Vignette", 1, true) or strfind(atlas, "vignette", 1, true) or atlas == "nazjatar-nagaevent"
end

local function RoundCoord01ToInt(x01)
	-- x01/y01 are 0..1. Convert to "percent * 10" (0.1% increments) as an int.
	-- ex: 0.5762 -> 57.6% => 576
	return math_floor((x01 * 1000) + 0.5)
end

local function BuildDedupKey(id, info, mapID, x01, y01, name)
	-- Most stable across weird id/guid behavior: map + name + rounded coords.
	if mapID and x01 and y01 and name and name ~= "" then
		local xi = RoundCoord01ToInt(x01)
		local yi = RoundCoord01ToInt(y01)
		return "M:" .. mapID .. ":N:" .. name .. ":X:" .. xi .. ":Y:" .. yi
	end

	-- Fallback: use GUID if present.
	local guid = info and info.vignetteGUID
	if guid then
		return "G:" .. guid
	end

	-- Final fallback: event arg.
	return "I:" .. tostring(id)
end

local function CacheSet(key, now)
	if RareAlertCache[key] == nil then
		RareCacheSize = RareCacheSize + 1
	end
	RareAlertCache[key] = now
end

local function CacheRemove(key)
	if RareAlertCache[key] ~= nil then
		RareAlertCache[key] = nil
		RareCacheSize = RareCacheSize - 1
	end
end

local function PruneCache(now)
	-- 1) Remove expired
	for key, ts in pairs(RareAlertCache) do
		if (now - (ts or 0)) > RARE_CACHE_RETENTION then
			CacheRemove(key)
		end
	end

	-- 2) Still too big? Drop oldest until under max.
	if RareCacheSize > RARE_CACHE_MAX then
		local tmp = {}
		for key, ts in pairs(RareAlertCache) do
			tmp[#tmp + 1] = { key, ts or 0 }
		end

		table_sort(tmp, function(a, b)
			return a[2] < b[2]
		end)

		local removeCount = RareCacheSize - RARE_CACHE_MAX
		for i = 1, removeCount do
			local k = tmp[i] and tmp[i][1]
			if k then
				CacheRemove(k)
			end
		end
	end
end

-- Event: VIGNETTE_MINIMAP_UPDATED
function Module.RareAlert_Update(_, id)
	if not id then
		return
	end

	-- Only ignore numeric IDs (string GUIDs shouldn't be checked against numeric table)
	if type(id) == "number" and isIgnoredIDs[id] then
		return
	end

	-- If configured: only alert in open world
	if C and C["Announcements"] and C["Announcements"].AlertOnlyInWorld and Module.RareInstType ~= "none" then
		return
	end

	local info = C_VignetteInfo_GetVignetteInfo(id)
	if not info or not IsUsefulAtlas(info) then
		return
	end

	local now = GetTime()
	local cooldown = GetRareCooldown()

	local vignetteName = info.name or ""

	-- Try to compute a stable position-based key
	local mapID = C_Map_GetBestMapForUnit("player")
	local x01, y01

	do
		local guid = info.vignetteGUID
		if mapID and guid then
			local position = C_VignetteInfo_GetVignettePosition(guid, mapID)
			if position then
				x01, y01 = position:GetXY()
			end
		end
	end

	local dedupKey = BuildDedupKey(id, info, mapID, x01, y01, vignetteName)

	-- Per-rare cooldown (actual anti-double / anti-spam)
	local last = RareAlertCache[dedupKey]
	if last and (now - last) < cooldown then
		return
	end

	-- Last-ditch guard: identical signature repeating instantly (covers double registration)
	if dedupKey == lastSig and (now - lastSigAt) < LASTSIG_GUARD then
		return
	end
	lastSig, lastSigAt = dedupKey, now

	local atlasInfo = C_Texture_GetAtlasInfo(info.atlasName)
	if not atlasInfo then
		return
	end

	local tex = K.GetTextureStrByAtlas(atlasInfo)
	if not tex then
		return
	end

	-- UIErrorsFrame alert (global throttle to avoid spam)
	if now >= nextGlobalAlertAt then
		UIErrorsFrame:AddMessage(K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. "[" .. vignetteName .. "]" .. K.SystemColor .. "!")
		nextGlobalAlertAt = now + UIERRORS_THROTTLE
	end

	-- Chat alert
	if C and C["Announcements"] and C["Announcements"].AlertInChat then
		local currentTime = ""
		if C.Chat and C.Chat.TimestampFormat == 1 then
			currentTime = K.GreyColor .. "[" .. date("%H:%M:%S") .. "]"
		end

		local nameString = vignetteName
		if mapID and x01 and y01 then
			nameString = string_format(Module.RareString, mapID, x01 * 10000, y01 * 10000, vignetteName, x01 * 100, y01 * 100, "")
		end

		K.Print(currentTime .. K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. (nameString or "") .. K.SystemColor .. "!")
	end

	PlaySound(37881, "Master")

	-- Record + prune
	CacheSet(dedupKey, now)
	if RareCacheSize > RARE_CACHE_MAX then
		PruneCache(now)
	end
end

-- Instance guard: enable/disable vignette updates in ignored content
function Module.RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	Module.RareInstType = instanceType or "none"

	-- Optional: ignore specific “fronts/scenarios” entirely to avoid noise
	local shouldIgnore = (instID and isIgnoredZone[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6))

	if shouldIgnore then
		if Module.RareAlertRegistered then
			K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
			Module.RareAlertRegistered = nil
		end
	else
		-- Guard against accidental double-registration
		if not Module.RareAlertRegistered then
			K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
			Module.RareAlertRegistered = true
		end
	end
end

-- Entry point
function Module:CreateRareAnnounce()
	Module.RareString = "|Hworldmap:%d:%d:%d|h[%s (%.1f, %.1f)%s]|h|r"

	if C and C["Announcements"] and C["Announcements"].RareAlert then
		Module.RareAlert_CheckInstance()
		K:RegisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	else
		table_wipe(RareAlertCache)
		RareCacheSize = 0
		Module.RareAlertRegistered = nil
		lastSig, lastSigAt = nil, 0
		nextGlobalAlertAt = 0

		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
		K:UnregisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	end
end
