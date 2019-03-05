local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("VignetteAlert", "AceEvent-3.0")

if K.CheckAddOnState("VignetteAnnouncer") or K.CheckAddOnState("SilverDragon") then
	return
end

local _G = _G
local string_find = string.find
local string_format = string.format
local string_match = string.match

local BetterDate = _G.BetterDate
local C_VignetteInfo_GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo
local C_VignetteInfo_GetVignettePosition = _G.C_VignetteInfo.GetVignettePosition
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local GetAtlasInfo = _G.GetAtlasInfo
local GetInstanceInfo = _G.GetInstanceInfo
local GetTime = _G.GetTime
local PlaySound = _G.PlaySound
local time = _G.time

local recent = {}

local IsGarrison = {
	[1152] = true,
	[1153] = true,
	[1154] = true,
	[1158] = true,
	[1159] = true,
	[1160] = true,
	[1330] = true,
	[1331] = true,
}

local AtlasWhitelist = {
	["VignetteKill"] = true,
	["VignetteLoot"] = true,
	["VignetteEvent"] = true,
}

local function FormatAtlasString(str)
	local filename, width, height, txLeft, txRight, txTop, txBottom = GetAtlasInfo(str)
	local size = 16

	if (not filename) then
		return
	end

	local atlasWidth = width / (txRight - txLeft)
	local atlasHeight = height / (txBottom - txTop)
	local pxLeft = atlasWidth * txLeft
	local pxRight = atlasWidth * txRight
	local pxTop = atlasHeight * txTop
	local pxBottom = atlasHeight * txBottom

	return string.format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", filename, size, size, atlasWidth, atlasHeight, pxLeft, pxRight, pxTop, pxBottom)
end

function Module:VIGNETTE_MINIMAP_UPDATED(_, id)
	if not id then
		return
	end

	local vInfo = C_VignetteInfo_GetVignetteInfo(id)
	if not vInfo then
		return
	end

	local now = GetTime()
	local name, onMinimap, atlasName, vignetteID = vInfo.name, vInfo.onMinimap, vInfo.atlasName, vInfo.vignetteID
	local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	if onMinimap and not (IsGarrison[instanceID] or string_find(name,"Aguri") or name == "") then
		if recent[vignetteID] and now - recent[vignetteID] < 400 then recent[vignetteID] = now
			return
		end
		recent[vignetteID] = now

		if not AtlasWhitelist[atlasName] then
			return
		end

		local msg
		if not name then
			name = vignetteID
		end

		local mapID = C_Map.GetBestMapForUnit("player")
		local vignettePosition, x, y = C_VignetteInfo_GetVignettePosition(id, mapID)
		if vignettePosition then
			x = tonumber(string_format("%.2f", vignettePosition.x))
			y = tonumber(string_format("%.2f", vignettePosition.y))
		end

		PlaySound(3175, "Master")

		if C["DataText"].Time24Hr == true then
			msg = FormatAtlasString(atlasName).." |cffFFFFFF"..name.."|r "..L["Maps"].Spotted ..BetterDate(CHAT_TIMESTAMP_FORMAT or "%H:%M", time())
		elseif C["DataText"].LocalTime == true then
			msg = FormatAtlasString(atlasName).." |cffFFFFFF"..name.."|r "..L["Maps"].Spotted ..BetterDate(CHAT_TIMESTAMP_FORMAT or "%I:%M", time())
		end

		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
		if msg then
			if vignettePosition then
				DEFAULT_CHAT_FRAME:AddMessage(msg.."|cff85DBF3|HVAN:"..x.." "..y.." "..mapID.." "..name.."|h ["..x..", "..y.."]|h|r")
			else
				DEFAULT_CHAT_FRAME:AddMessage(msg)
			end
		end
	end
end

function Module:OnEnable()
	if C["Minimap"].VignetteAlert ~= true then
		return
	end

	local SetHyperlink = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(data, ...)
		if (data):sub(1, 3) == "VAN" then
			local x, y, mapID, name = string_match(data, "(%d+.%d+) (%d+.%d+) (%d+) %s?(.*)")
			if TomTom and K.CheckAddOnState("TomTom") then
				TomTom:AddWaypoint(tonumber(mapID), tonumber(x), tonumber(y), {title = name,})
			else
				print(L["Maps"].TomTom)
			end
		else
			SetHyperlink(self, data, ...)
		end
	end

	self:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
end