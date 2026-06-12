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

local date = date
local strfind = string.find
local string_format = string.format

local math_floor = math.floor

local table_sort = table.sort
local table_wipe = table.wipe

local _G = _G
local C_Map = C_Map
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_NamePlate_GetNamePlates = C_NamePlate and C_NamePlate.GetNamePlates
local C_SuperTrack_SetSuperTrackedUserWaypoint = C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint
local C_Texture_GetAtlasInfo = C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = C_VignetteInfo.GetVignettePosition
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local GetCVar = GetCVar
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local PlaySound = PlaySound
local SetCVar = SetCVar
local SetPortraitTexture = SetPortraitTexture
local UIParent = UIParent
local UIErrorsFrame = UIErrorsFrame
local UnitGUID = UnitGUID
local UNKNOWN = _G["UNKNOWN"] or "Unknown"
local UiMapPoint = _G["UiMapPoint"]
local UiMapPoint_CreateFromCoordinates = UiMapPoint and UiMapPoint.CreateFromCoordinates

-- NOTE: Internal tuning constants for deduplication and performance.
local DEFAULT_RARE_COOLDOWN = 15 -- seconds: per-rare cooldown (stops redundant alerts).
local RARE_CACHE_RETENTION = 120 -- seconds: maximum age of an entry in the dedupe cache.
local RARE_CACHE_MAX = 256 -- maximum number of entries before aggressive pruning.
local RARE_POPUP_DURATION = 12 -- seconds: how long the popup remains visible.
local RARE_SOUND_THROTTLE = 5 -- seconds: stops sound bursts when several rares appear at once.
local UIERRORS_THROTTLE = 1.0 -- seconds: global throttle for UIErrorsFrame messages.
local LASTSIG_GUARD = 0.30 -- seconds: guard against double-registered event callbacks.
local RARE_SOUNDKIT_ID = 37881 -- Sound: UI_Rare_Vignette_Found
local BACKGROUND_SOUND_CVAR = "Sound_EnableSoundWhenGameIsInBG"

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
local lastSoundAt = 0
local rarePopup
local bgSoundSaved
local bgRestoreTimer

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
	-- REASON: Treasure/lore objects also use vignette atlases; exclude them so they are not announced as rares.
	if strfind(atlas, "VignetteLoot") or strfind(atlas, "vignetteloot") or strfind(atlas, "loreobject") then
		return false
	end
	return strfind(atlas, "Vignette", 1, true) or strfind(atlas, "vignette", 1, true) or atlas == "nazjatar-nagaevent"
end

local function GetVignetteNpcID(info)
	return info and info.objectGUID and K.GetNPCID(info.objectGUID)
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

-- PERF: Pre-allocated sort buffer — reused across PruneCache calls instead of allocating
-- a new table each time the cache overflows.
local pruneSortBuf = {}

-- REASON: Periodic cleanup to prevent the memory used by the dedupe table from growing indefinitely.
local function PruneCache(now)
	for key, ts in pairs(RareAlertCache) do
		if (now - (ts or 0)) > RARE_CACHE_RETENTION then
			CacheRemove(key)
		end
	end

	if RareCacheSize > RARE_CACHE_MAX then
		-- PERF: Wipe the reusable sort buffer rather than creating a new table each call.
		table_wipe(pruneSortBuf)
		for key, ts in pairs(RareAlertCache) do
			pruneSortBuf[#pruneSortBuf + 1] = { key, ts or 0 }
		end

		table_sort(pruneSortBuf, function(a, b)
			return a[2] < b[2]
		end)

		local removeCount = RareCacheSize - RARE_CACHE_MAX
		for i = 1, removeCount do
			local k = pruneSortBuf[i] and pruneSortBuf[i][1]
			if k then
				CacheRemove(k)
			end
		end
	end
end

local function RestoreBackgroundSound()
	if bgSoundSaved ~= nil then
		SetCVar(BACKGROUND_SOUND_CVAR, bgSoundSaved)
		bgSoundSaved = nil
	end
	bgRestoreTimer = nil
end

local function PlayRareAlertSound(now)
	if not C["Announcements"].RareAlertSound or (now - lastSoundAt) < RARE_SOUND_THROTTLE then
		return
	end

	if C["Announcements"].RareAlertSoundInBackground then
		local currentValue = GetCVar(BACKGROUND_SOUND_CVAR)
		if currentValue ~= "1" and bgSoundSaved == nil then
			bgSoundSaved = currentValue
			SetCVar(BACKGROUND_SOUND_CVAR, "1")
		end
		if bgSoundSaved ~= nil then
			if bgRestoreTimer then
				bgRestoreTimer:Cancel()
			end
			bgRestoreTimer = C_Timer.NewTimer(5, RestoreBackgroundSound)
		end
	end

	PlaySound(RARE_SOUNDKIT_ID, "Master")
	lastSoundAt = now
end

local function SetTrackedWaypoint(mapID, x01, y01)
	if not (mapID and x01 and y01) then
		return false
	end

	local TomTom = _G["TomTom"]
	if TomTom and TomTom.AddWaypoint then
		TomTom:AddWaypoint(mapID, x01, y01, { title = rarePopup and rarePopup.rareName, from = "KkthnxUI", persistent = false, crazy = true })
		return true
	end

	if C_Map and C_Map.SetUserWaypoint and UiMapPoint_CreateFromCoordinates then
		if C_Map.ClearUserWaypoint then
			C_Map.ClearUserWaypoint()
		end
		C_Map.SetUserWaypoint(UiMapPoint_CreateFromCoordinates(mapID, x01, y01))
		if C_SuperTrack_SetSuperTrackedUserWaypoint then
			C_SuperTrack_SetSuperTrackedUserWaypoint(true)
		end
		return true
	end

	return false
end

local function RarePopup_Hide()
	if not rarePopup then
		return
	end
	if rarePopup.hideTimer then
		rarePopup.hideTimer:Cancel()
		rarePopup.hideTimer = nil
	end
	if InCombatLockdown() then
		rarePopup.pendingHide = true
		return
	end
	rarePopup.pendingHide = nil
	rarePopup:Hide()
end

local function RarePopup_FlushPending()
	if rarePopup and rarePopup.pendingHide then
		rarePopup.pendingHide = nil
		rarePopup:Hide()
	end
end

local function RarePopup_PreClick(self)
	self.prevUseKeyDown = GetCVar("ActionButtonUseKeyDown")
	if self.prevUseKeyDown ~= "0" then
		SetCVar("ActionButtonUseKeyDown", "0")
	end
end

local function RarePopup_PostClick(self, button)
	if self.prevUseKeyDown and self.prevUseKeyDown ~= "0" then
		SetCVar("ActionButtonUseKeyDown", self.prevUseKeyDown)
	end
	self.prevUseKeyDown = nil

	local popupFrame = self:GetParent()
	if button == "LeftButton" and SetTrackedWaypoint(popupFrame.mapID, popupFrame.x01, popupFrame.y01) then
		K.Print(K.InfoColor .. string_format(L["Rare Alert Tracking"], popupFrame.rareName or UNKNOWN))
	end

	RarePopup_Hide()
end

local function RarePopup_UpdateMacro(popupFrame, name)
	if not (popupFrame and popupFrame.secure) or InCombatLockdown() then
		return
	end

	local macro = ""
	if C["Announcements"].RareAlertClickToTarget and name and name ~= "" and name ~= UNKNOWN then
		macro = "/cleartarget\n/targetexact " .. name
	end
	popupFrame.secure:SetAttribute("macrotext", macro)
end

local function GetUnitForGUID(guid)
	if not guid then
		return
	end

	if UnitGUID("target") == guid then
		return "target"
	end
	if UnitGUID("mouseover") == guid then
		return "mouseover"
	end

	if C_NamePlate_GetNamePlates then
		local plates = C_NamePlate_GetNamePlates()
		for i = 1, #plates do
			local token = plates[i].namePlateUnitToken
			if token and UnitGUID(token) == guid then
				return token
			end
		end
	end
end

local function RarePopup_SetIcon(popupFrame, atlas, guid)
	local unit = GetUnitForGUID(guid)
	if unit and SetPortraitTexture then
		popupFrame.icon:SetTexCoord(0, 1, 0, 1)
		SetPortraitTexture(popupFrame.icon, unit)
	else
		popupFrame.icon:SetTexture(nil)
		popupFrame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		popupFrame.icon:SetAtlas(atlas or "VignetteKill")
	end
end

local function CreateRarePopup()
	if rarePopup then
		return rarePopup
	end

	local popupFrame = CreateFrame("Button", "KKUI_RareAlertPopup", UIParent, "BackdropTemplate")
	popupFrame:SetSize(268, 66)
	popupFrame:SetFrameStrata("HIGH")
	popupFrame:Hide()
	popupFrame:CreateBorder()

	popupFrame.icon = popupFrame:CreateTexture(nil, "ARTWORK")
	popupFrame.icon:SetSize(44, 44)
	popupFrame.icon:SetPoint("LEFT", popupFrame, "LEFT", 10, 0)
	popupFrame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	popupFrame.title = K.CreateFontString(popupFrame, 14, "", "OUTLINE", false, "LEFT", 62, 12)
	popupFrame.title:SetPoint("RIGHT", popupFrame, "RIGHT", -24, 0)
	popupFrame.title:SetJustifyH("LEFT")
	popupFrame.title:SetWordWrap(false)

	popupFrame.coords = K.CreateFontString(popupFrame, 11, "", "", false, "LEFT", 62, -6)
	popupFrame.coords:SetTextColor(0.7, 0.7, 0.7)

	popupFrame.hint = K.CreateFontString(popupFrame, 10, L["Rare Alert Click Hint"], "", false, "LEFT", 62, -22)
	popupFrame.hint:SetTextColor(0.5, 0.78, 1)

	local secure = CreateFrame("Button", nil, popupFrame, "SecureActionButtonTemplate")
	secure:SetAllPoints(popupFrame)
	secure:SetFrameLevel(popupFrame:GetFrameLevel() + 1)
	secure:RegisterForClicks("AnyUp")
	secure:SetAttribute("type1", "macro")
	secure:SetScript("PreClick", RarePopup_PreClick)
	secure:SetScript("PostClick", RarePopup_PostClick)
	popupFrame.secure = secure

	local close = CreateFrame("Button", nil, popupFrame, "UIPanelCloseButton")
	close:SetSize(22, 22)
	close:SetPoint("TOPRIGHT", popupFrame, "TOPRIGHT", 1, 1)
	close:SetFrameLevel(secure:GetFrameLevel() + 1)
	close:SetScript("OnClick", RarePopup_Hide)
	close:SkinCloseButton()
	popupFrame.close = close

	popupFrame.mover = K.Mover(popupFrame, "RareAlertPopup", "RareAlertPopup", { "TOP", UIParent, "TOP", 0, -240 }, popupFrame:GetSize())

	rarePopup = popupFrame
	return popupFrame
end

local function ShowRarePopup(atlas, name, mapID, x01, y01, guid)
	if not C["Announcements"].RareAlertPopup or InCombatLockdown() then
		return
	end

	local popupFrame = CreateRarePopup()
	popupFrame.rareName = name
	popupFrame.mapID = mapID
	popupFrame.x01 = x01
	popupFrame.y01 = y01
	popupFrame.title:SetText(name or UNKNOWN)
	RarePopup_SetIcon(popupFrame, atlas, guid)
	RarePopup_UpdateMacro(popupFrame, name)

	if mapID and x01 and y01 then
		popupFrame.coords:SetFormattedText("(%.1f, %.1f)", x01 * 100, y01 * 100)
		popupFrame.hint:SetText(C["Announcements"].RareAlertClickToTarget and L["Rare Alert Click Target Track Hint"] or L["Rare Alert Click Hint"])
	else
		popupFrame.coords:SetText("")
		popupFrame.hint:SetText(C["Announcements"].RareAlertClickToTarget and L["Rare Alert Click Target Hint"] or "")
	end

	popupFrame.pendingHide = nil
	popupFrame:Show()
	if popupFrame.hideTimer then
		popupFrame.hideTimer:Cancel()
	end
	popupFrame.hideTimer = C_Timer.NewTimer(RARE_POPUP_DURATION, RarePopup_Hide)
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
	local npcID = GetVignetteNpcID(info)
	if npcID and isIgnoredIDs[npcID] then
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

	ShowRarePopup(info.atlasName, vignetteName, mapID, x01, y01, info.objectGUID)
	PlayRareAlertSound(now)

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
		K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.RareAlert_CheckInstance)
		K:RegisterEvent("PLAYER_REGEN_ENABLED", RarePopup_FlushPending)
		if C["Announcements"].RareAlertPopup and not InCombatLockdown() then
			CreateRarePopup()
		end
	else
		table_wipe(RareAlertCache)
		RareCacheSize = 0
		Module.RareAlertRegistered = nil
		lastSig, lastSigAt = nil, 0
		nextGlobalAlertAt = 0
		lastSoundAt = 0
		RarePopup_Hide()
		if bgRestoreTimer then
			bgRestoreTimer:Cancel()
		end
		RestoreBackgroundSound()

		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
		K:UnregisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.RareAlert_CheckInstance)
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", RarePopup_FlushPending)
	end
end
