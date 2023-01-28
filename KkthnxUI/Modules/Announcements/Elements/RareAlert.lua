local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

local string_find = _G.string.find
local string_format = _G.string.format
local table_wipe = _G.table.wipe

local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Texture_GetAtlasInfo = _G.C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = _G.C_VignetteInfo.GetVignettePosition
local GetInstanceInfo = _G.GetInstanceInfo
local UIErrorsFrame = _G.UIErrorsFrame
local date = _G.date

local RareAlertCache = {}
local isIgnoredZone = {
	[1153] = true, -- Horde Fortress
	[1159] = true, -- Alliance fortress
	[1803] = true, -- Yongquan Beach
	[1876] = true, -- Tribal torrent
	[1943] = true, -- Alliance Rapids
	[2111] = true, -- Black coast front
}

local function isUsefulAtlas(info)
	local atlas = info.atlasName
	if atlas then
		return string_find(atlas, "[Vv]ignette") or (atlas == "nazjatar-nagaevent")
	end
end

function Module:RareAlert_Update(id)
	if id and not RareAlertCache[id] then
		local info = C_VignetteInfo_GetVignetteInfo(id)
		if not info or not isUsefulAtlas(info) then
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

		-- stylua: ignore
		UIErrorsFrame:AddMessage(K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. "[" .. (info.name or "") .. "]" .. K.SystemColor .. "!")

		if C["Announcements"].AlertInChat then
			local currrentTime = C["Chat"].TimestampFormat.Value == 1 and K.GreyColor .. "[" .. date("%H:%M:%S") .. "]" or ""
			local nameString
			local mapID = C_Map_GetBestMapForUnit("player")
			local position = mapID and C_VignetteInfo_GetVignettePosition(info.vignetteGUID, mapID)
			if position then
				local x, y = position:GetXY()
				-- stylua: ignore
				nameString = string_format(Module.RareString, mapID, x * 10000, y * 10000, info.name, x * 100, y * 100, "")
			end
			-- stylua: ignore
			K.Print(currrentTime .. K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. (nameString or info.name or "") .. K.SystemColor .. "!")
		end

		-- Add a choice in sounds the user can pick from. Have the community vote on 5 sounds???
		if Module.RareInstType == "none" then
			PlaySound(37881, "master")
		end
		-- Add a choice in sounds the user can pick from. Have the community vote on 5 sounds???
		if not C["Announcements"].AlertInWild or Module.RareInstType == "none" then
			PlaySound(37881, "master")
		end

		RareAlertCache[id] = true
	end

	if #RareAlertCache > 666 then
		table_wipe(RareAlertCache)
	end
end

function Module:RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	if (instID and isIgnoredZone[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6)) then
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	else
		K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	end
	Module.RareInstType = instanceType
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
