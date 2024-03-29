local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

local string_find = string.find
local string_format = string.format
local table_wipe = table.wipe

local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Texture_GetAtlasInfo = C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = C_VignetteInfo.GetVignettePosition
local GetInstanceInfo = GetInstanceInfo
local UIErrorsFrame = UIErrorsFrame
local date = date

local RareAlertCache = {}
local isIgnoredZone = {
	[1153] = true, -- Horde Fortress
	[1159] = true, -- Alliance fortress
	[1803] = true, -- Yongquan Beach
	[1876] = true, -- Tribal torrent
	[1943] = true, -- Alliance Rapids
	[2111] = true, -- Black coast front
}

local isIgnoredIDs = { -- todo: add option for this
	[5485] = true,
}

local function isUsefulAtlas(info)
	local atlas = info.atlasName
	if atlas then
		return string_find(atlas, "[Vv]ignette") or (atlas == "nazjatar-nagaevent")
	end
end

function Module:RareAlert_Update(id)
	if not id or RareAlertCache[id] then
		return
	end

	local info = C_VignetteInfo_GetVignetteInfo(id)
	if not info or not isUsefulAtlas(info) or isIgnoredIDs[info.vignetteID] then
		return
	end

	-- Use the vignetteGUID and name from the payload to get more information about the vignette
	local vignetteGUID = info.vignetteGUID
	local vignetteName = info.name

	local atlasInfo = C_Texture_GetAtlasInfo(info.atlasName)
	if not atlasInfo then
		return
	end

	local tex = K.GetTextureStrByAtlas(atlasInfo)
	if not tex then
		return
	end

	UIErrorsFrame:AddMessage(K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. "[" .. (vignetteName or "") .. "]" .. K.SystemColor .. "!")

	if C["Announcements"].AlertInChat then
		local currrentTime = C["Chat"].TimestampFormat.Value == 1 and K.GreyColor .. "[" .. date("%H:%M:%S") .. "]" or ""
		local mapID = C_Map_GetBestMapForUnit("player")
		local position = mapID and C_VignetteInfo_GetVignettePosition(vignetteGUID, mapID)
		local nameString = ""
		if position then
			local x, y = position:GetXY()
			nameString = string_format(Module.RareString, mapID, x * 10000, y * 10000, info.name, x * 100, y * 100, "")
		end
		K.Print(currrentTime .. K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. (nameString or vignetteName or "") .. K.SystemColor .. "!")
	end

	-- Add a choice in sounds the user can pick from. Have the community vote on 5 sounds???
	if not C["Announcements"].AlertInWild or Module.RareInstType == "none" then
		PlaySound(37881, "master")
	end

	RareAlertCache[id] = true

	if #RareAlertCache > 666 then
		table_wipe(RareAlertCache)
	end
end

function Module:RareAlert_CheckInstance()
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
end

function Module:CreateRareAnnounce()
	Module.RareString = "|Hworldmap:%d+:%d+:%d+|h[%s (%.1f, %.1f)%s]|h|r"

	if C["Announcements"].RareAlert then
		Module:RareAlert_CheckInstance()
		K:RegisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	else
		table_wipe(RareAlertCache)
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
		K:UnregisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	end
end
