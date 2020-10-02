local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format
local table_wipe = _G.table.wipe

local date = _G.date
local C_VignetteInfo_GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo
local GetAtlasInfo = _G.GetAtlasInfo
local GetInstanceInfo = _G.GetInstanceInfo

local RareAlertCache = {}
local isIgnored = {
	[1153] = true, -- Horde Fortress
	[1159] = true, -- Alliance fortress
	[1803] = true, -- Yongquan Beach
	[1876] = true, -- Tribal torrent
	[1943] = true, -- Alliance Rapids
	[2111] = true, -- Black coast front
}

function Module:RareAlert_Update(id)
	if id and not RareAlertCache[id] then
		local info = C_VignetteInfo_GetVignetteInfo(id)
        if not info then
            return
        end

		local filename, width, height, txLeft, txRight, txTop, txBottom = GetAtlasInfo(info.atlasName)
        if not filename then
            return
        end

		local atlasWidth = width / (txRight-txLeft)
		local atlasHeight = height / (txBottom-txTop)
		local tex = string_format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", filename, 0, 0, atlasWidth, atlasHeight, atlasWidth * txLeft, atlasWidth * txRight, atlasHeight * txTop, atlasHeight * txBottom)

		UIErrorsFrame:AddMessage(K.SystemColor..tex..L["Rare Spotted"]..K.InfoColor.."["..(info.name or "").."]"..K.SystemColor.."!")
		local currrentTime = C["Chat"].TimestampFormat.Value == 1 and K.GreyColor.."["..date("%H:%M:%S").."]" or ""
		K.Print(currrentTime..K.SystemColor..tex..L["Rare Spotted"]..K.InfoColor.."["..(info.name or "").."]"..K.SystemColor.."!")

		RareAlertCache[id] = true
	end

    if #RareAlertCache > 666 then
        table_wipe(RareAlertCache)
    end
end

function Module:RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	if (instID and isIgnored[instID]) or (instanceType == "scenario" and (maxPlayers == 3 or maxPlayers == 6)) then
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	else
		K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	end
end

function Module:CreateRareAnnounce()
	if C["Announcements"].RareAlert then
		self:RareAlert_CheckInstance()
		K:RegisterEvent("PLAYER_ENTERING_WORLD", self.RareAlert_CheckInstance)
	else
		table_wipe(RareAlertCache)
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", self.RareAlert_Update)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.RareAlert_CheckInstance)
	end
end