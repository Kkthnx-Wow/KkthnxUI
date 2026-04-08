--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Announces rare vignettes (vignette icons on minimap) to chat and UI.
-- - Design: Implements stable deduplication and per-rare cooldowns using rounded coordinates.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache Lua and WoW API globals for frequent vignette processing.
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

local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Texture_GetAtlasInfo = C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = C_VignetteInfo.GetVignettePosition
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime
local PlaySound = PlaySound
local UIErrorsFrame = UIErrorsFrame

-- NOTE: Internal tuning constants for deduplication and performance.
local DEFAULT_RARE_COOLDOWN = 15 -- seconds: per-rare cooldown (stops redundant alerts).
local RARE_CACHE_RETENTION = 120 -- seconds: maximum age of an entry in the dedupe cache.
local RARE_CACHE_MAX = 256 -- maximum number of entries before aggressive pruning.
local UIERRORS_THROTTLE = 1.0 -- seconds: global throttle for UIErrorsFrame messages.
local LASTSIG_GUARD = 0.30 -- seconds: guard against double-registered event callbacks.

-- ---------------------------------------------------------------------------
-- IGNORE LISTS
-- ---------------------------------------------------------------------------

local isIgnoredZone = {
	[1153] = true, -- Horde Garrison
	[1159] = true, -- Alliance Garrison
	[1803] = true, -- Seething Shore
	[1876] = true, -- Horde Arathi Highlands (Front)
	[1943] = true, -- Alliance Arathi Highlands (Front)
	[2111] = true, -- Darkshore (Front)
}

local isIgnoredIDs = {
	[6149] = true, -- Onyxia Egg
	[6699] = true, -- Delvish Treasures (Delves)
}

local RareAlertCache = {}
local RareCacheSize = 0
local nextGlobalAlertAt = 0

local lastSig, lastSigAt = nil, 0

-- ---------------------------------------------------------------------------
-- HELPERS
-- ---------------------------------------------------------------------------

local function GetRareCooldown()
	local cooldown = C["Announcements"].RareCooldown
	return (cooldown and cooldown > 0) and cooldown or DEFAULT_RARE_COOLDOWN
end

local function IsUsefulAtlas(info)
	local atlas = info and info.atlasName
	if not atlas then
		return false
	end
	-- REASON: Only process atlas names that explicitly represent vignettes or special events.
	return strfind(atlas, "Vignette", 1, true) or strfind(atlas, "vignette", 1, true) or atlas == "nazjatar-nagaevent"
end

-- REASON: Convert 0-1 coordinates into integers with 0.1% precision for stable hash keys.
local function RoundCoord01ToInt(x01)
	return math_floor((x01 * 1000) + 0.5)
end

-- REASON: Build a stable key for deduplication.
-- Preferred method is MapID + Rounded Coords + Name to handle GUID instability on some servers.
local function BuildDedupKey(id, info, mapID, x01, y01, name)
	if mapID and x01 and y01 and name and name ~= "" then
		local xi = RoundCoord01ToInt(x01)
		local yi = RoundCoord01ToInt(y01)
		return "M:" .. mapID .. ":N:" .. name .. ":X:" .. xi .. ":Y:" .. yi
	end

	local guid = info and info.vignetteGUID
	if guid then
		return "G:" .. guid
	end

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

-- REASON: Periodic cleanup to prevent the memory used by the dedupe table from growing indefinitely.
local function PruneCache(now)
	for key, ts in pairs(RareAlertCache) do
		if (now - (ts or 0)) > RARE_CACHE_RETENTION then
			CacheRemove(key)
		end
	end

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

-- ---------------------------------------------------------------------------
-- EVENT LOGIC
-- ---------------------------------------------------------------------------

function Module.RareAlert_Update(_, id)
	if not id then
		return
	end

	-- REASON: Minimize noise by ignoring world vignettes while inside instances if configured.
	if C and C["Announcements"] and C["Announcements"].AlertOnlyInWorld and Module.RareInstType ~= "none" then
		return
	end

	local info = C_VignetteInfo_GetVignetteInfo(id)
	if not info or not IsUsefulAtlas(info) then
		return
	end

	if info.vignetteID and isIgnoredIDs[info.vignetteID] then
		return
	end

	local now = GetTime()
	local cooldown = GetRareCooldown()
	local vignetteName = info.name or ""

	local mapID = C_Map_GetBestMapForUnit("player")
	local x01, y01

	-- REASON: Attempt to fetch real-world coordinates for the vignette to improve deduplication accuracy.
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

	-- PERF: Enforce per-rare cooldown.
	local last = RareAlertCache[dedupKey]
	if last and (now - last) < cooldown then
		return
	end

	-- NOTE: High-speed guard for double-registered events firing in the same frame.
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

	-- REASON: Output to world UI frame with global throttling.
	if now >= nextGlobalAlertAt then
		UIErrorsFrame:AddMessage(K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. "[" .. vignetteName .. "]" .. K.SystemColor .. "!")
		nextGlobalAlertAt = now + UIERRORS_THROTTLE
	end

	-- REASON: Output to chat console with optional map coordinates link.
	if C and C["Announcements"] and C["Announcements"].AlertInChat then
		local currentTime = ""
		if C.Chat and C.Chat.TimestampFormat == 1 then
			currentTime = K.GreyColor .. "[" .. date("%H:%M:%S") .. "]"
		end

		local nameString = vignetteName
		if mapID and x01 and y01 then
			-- NOTE: Uses custom worldmap hyperlink format for clickable coordinates.
			nameString = string_format(Module.RareString, mapID, math_floor(x01 * 10000), math_floor(y01 * 10000), vignetteName, x01 * 100, y01 * 100, "")
		end

		K.Print(currentTime .. K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. (nameString or "") .. K.SystemColor .. "!")
	end

	PlaySound(37881, "Master") -- Sound: UI_Rare_Vignette_Found

	CacheSet(dedupKey, now)
	if RareCacheSize > RARE_CACHE_MAX then
		PruneCache(now)
	end
end

-- ---------------------------------------------------------------------------
-- INSTANCE MANAGEMENT
-- ---------------------------------------------------------------------------

function Module.RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	Module.RareInstType = instanceType or "none"

	-- NOTE: Automatically suppress alerts in specific noise-heavy scenarios or garrisons.
	local shouldIgnore = (instID and isIgnoredZone[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6))

	if shouldIgnore then
		if Module.RareAlertRegistered then
			K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
			Module.RareAlertRegistered = nil
		end
	else
		if not Module.RareAlertRegistered then
			K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
			Module.RareAlertRegistered = true
		end
	end
end

-- ---------------------------------------------------------------------------
-- REGISTRATION
-- ---------------------------------------------------------------------------

function Module:CreateRareAnnounce()
	-- NOTE: Template for worldmap hyperlinks used in chat alerts.
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
