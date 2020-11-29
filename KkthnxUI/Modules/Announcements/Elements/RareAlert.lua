local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_find = _G.string.find
local string_format = _G.string.format
local table_wipe = _G.table.wipe

local C_Texture_GetAtlasInfo = _G.C_Texture.GetAtlasInfo
local C_VignetteInfo_GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo
local GetInstanceInfo = _G.GetInstanceInfo
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
		return string_find(atlas, "[Vv]ignette")
	end
end

function Module:RareAlert_Update(id)
	if id and not RareAlertCache[id] then
		local info = C_VignetteInfo_GetVignetteInfo(id)
		if not info or not isUsefulAtlas(info) then
			return
		end

		local atlasInfo = C_Texture_GetAtlasInfo(info.atlasName)
		if not atlasInfo then return end

		local file, width, height, txLeft, txRight, txTop, txBottom = atlasInfo.file, atlasInfo.width, atlasInfo.height, atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord
		if not file then
			return
		end

		local atlasWidth = width / (txRight-txLeft)
		local atlasHeight = height / (txBottom-txTop)
		local tex = string_format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", file, 0, 0, atlasWidth, atlasHeight, atlasWidth * txLeft, atlasWidth * txRight, atlasHeight * txTop, atlasHeight * txBottom)

		UIErrorsFrame:AddMessage(K.SystemColor..tex..L["Rare Spotted"]..K.InfoColor.."["..(info.name or "").."]"..K.SystemColor.."!")
		if C["Announcements"].AlertInChat then
			local currrentTime = C["Chat"].TimestampFormat.Value == 1 and K.GreyColor.."["..date("%H:%M:%S").."]" or ""
			K.Print(currrentTime..K.SystemColor..tex..L["Rare Spotted"]..K.InfoColor.."["..(info.name or "").."]"..K.SystemColor.."!")
		end

		if Module.RareInstType == "none" then
			PlaySound(23404, "master")
		end

		if not C["Announcements"].AlertInWild or Module.RareInstType == "none" then
			PlaySound(23404, "master")
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
	if C["Announcements"].RareAlert then
		Module:RareAlert_CheckInstance()
		K:RegisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	else
		table_wipe(RareAlertCache)
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
		K:UnregisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	end
end