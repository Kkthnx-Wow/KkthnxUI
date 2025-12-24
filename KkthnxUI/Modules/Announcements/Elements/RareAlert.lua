local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- WoW / Lua locals
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Texture_GetAtlasInfo = C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = C_VignetteInfo.GetVignettePosition
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime
local UIErrorsFrame = UIErrorsFrame
local PlaySound = PlaySound
local date = date
local format = string.format
local strfind = string.find
local pairs = pairs
local table_wipe = table.wipe

-- Cache recently alerted vignettes with timestamps to avoid spam
local RareAlertCache = {} -- table<vignetteGUID|id, lastAlertTime>
local RARE_ALERT_TTL = 90
local RARE_ALERT_MAX = 256
local nextGlobalAlertAt = 0

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

local function IsUsefulAtlas(info)
	local atlas = info and info.atlasName
	if not atlas then
		return false
	end
	return strfind(atlas, "Vignette", 1, true) or strfind(atlas, "vignette", 1, true) or atlas == "nazjatar-nagaevent"
end

local function PruneCache(now)
	local pruned = 0
	for key, ts in pairs(RareAlertCache) do
		if (now - (ts or 0)) > RARE_ALERT_TTL then
			RareAlertCache[key] = nil
			pruned = pruned + 1
		end
	end
	-- If nothing pruned, hard reset to keep memory bounded
	if pruned == 0 then
		table_wipe(RareAlertCache)
	end
end

-- IMPORTANT: event handlers receive (event, ...) from K:RegisterEvent
function Module.RareAlert_Update(_, id)
	if not id or isIgnoredIDs[id] then
		return
	end

	-- If configured: only alert in open world
	if C["Announcements"].AlertOnlyInWorld and Module.RareInstType ~= "none" then
		return
	end

	local info = C_VignetteInfo_GetVignetteInfo(id)
	if not info or not IsUsefulAtlas(info) then
		return
	end

	local key = info.vignetteGUID or id
	local now = GetTime()

	local last = RareAlertCache[key]
	if last and (now - last) < RARE_ALERT_TTL then
		return
	end

	local atlasInfo = C_Texture_GetAtlasInfo(info.atlasName)
	if not atlasInfo then
		return
	end

	local tex = K.GetTextureStrByAtlas(atlasInfo)
	if not tex then
		return
	end

	local vignetteName = info.name or ""

	-- Global throttle for UIErrorsFrame spam
	if now >= nextGlobalAlertAt then
		UIErrorsFrame:AddMessage(K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. "[" .. vignetteName .. "]" .. K.SystemColor .. "!")
		nextGlobalAlertAt = now + 1.0
	end

	-- Chat alert
	if C["Announcements"].AlertInChat then
		local currentTime = (C.Chat and C.Chat.TimestampFormat == 1) and (K.GreyColor .. "[" .. date("%H:%M:%S") .. "]") or ""
		local nameString = vignetteName

		local mapID = C_Map_GetBestMapForUnit("player")
		local position = mapID and C_VignetteInfo_GetVignettePosition(info.vignetteGUID, mapID)
		if position then
			local x, y = position:GetXY()
			nameString = format(Module.RareString, mapID, x * 10000, y * 10000, vignetteName, x * 100, y * 100, "")
		end

		K.Print(currentTime .. K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. (nameString or "") .. K.SystemColor .. "!")
	end

	-- Sound (optional toggle if you have it; otherwise always play when an alert fires)
	--if C["Announcements"].RareSound then
	PlaySound(37881, "Master")
	--end

	-- Record + bounded cache
	RareAlertCache[key] = now

	-- Prune only when it grows too large
	local count = 0
	for _ in pairs(RareAlertCache) do
		count = count + 1
		if count > RARE_ALERT_MAX then
			PruneCache(now)
			break
		end
	end
end

function Module.RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	Module.RareInstType = instanceType or "none"

	-- Optional: ignore specific “fronts/scenarios” entirely to avoid noise
	local shouldIgnore = (instID and isIgnoredZone[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6))
	if shouldIgnore then
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	else
		K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	end
end

function Module:CreateRareAnnounce()
	Module.RareString = "|Hworldmap:%d:%d:%d|h[%s (%.1f, %.1f)%s]|h|r"

	if C["Announcements"].RareAlert then
		Module.RareAlert_CheckInstance()
		K:RegisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	else
		table_wipe(RareAlertCache)
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
		K:UnregisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	end
end
