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

-- Cache for rare alerts and ignored zones
local RareAlertCache = {}
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
	return atlas and (atlas:find("[Vv]ignette") or atlas == "nazjatar-nagaevent")
end

-- Function to handle rare alerts
function Module:RareAlert_Update(id)
	if not id or RareAlertCache[id] then
		return
	end

	local info = C_VignetteInfo_GetVignetteInfo(id)
	if not info or not isUsefulAtlas(info) or isIgnoredIDs[id] then
		return
	end

	local vignetteName = info.name
	local atlasInfo = C_Texture_GetAtlasInfo(info.atlasName)
	if not atlasInfo then
		return
	end

	local tex = K.GetTextureStrByAtlas(atlasInfo)
	if not tex then
		return
	end

	-- Show UI error message for rare spotting
	UIErrorsFrame:AddMessage(K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. "[" .. (vignetteName or "") .. "]" .. K.SystemColor .. "!")

	-- Chat alert if enabled
	if C["Announcements"].AlertInChat then
		local currentTime = C["Chat"].TimestampFormat.Value == 1 and K.GreyColor .. "[" .. date("%H:%M:%S") .. "]" or ""
		local mapID = C_Map_GetBestMapForUnit("player")
		local position = mapID and C_VignetteInfo_GetVignettePosition(info.vignetteGUID, mapID)
		local nameString = vignetteName

		if position then
			local x, y = position:GetXY()
			nameString = string.format(Module.RareString, mapID, x * 10000, y * 10000, info.name, x * 100, y * 100, "")
		end

		K.Print(currentTime .. K.SystemColor .. tex .. L["Rare Spotted"] .. K.InfoColor .. (nameString or "") .. K.SystemColor .. "!")
	end

	-- Play sound if enabled and not in an instance
	if not C["Announcements"].AlertInWild or Module.RareInstType == "none" then
		PlaySound(37881, "master")
	end

	RareAlertCache[id] = true

	-- Limit the size of the cache to prevent overflow
	if #RareAlertCache > 666 then
		table.wipe(RareAlertCache)
	end
end

-- Function to check the instance type for rare alerts and register/unregister events accordingly
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

-- Function to set up rare alerts
function Module:CreateRareAnnounce()
	Module.RareString = "|Hworldmap:%d+:%d+:%d+|h[%s (%.1f, %.1f)%s]|h|r"

	if C["Announcements"].RareAlert then
		Module:RareAlert_CheckInstance()
		K:RegisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	else
		-- Clear cache and unregister events if rare alerts are disabled
		table.wipe(RareAlertCache)
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
		K:UnregisterEvent("UPDATE_INSTANCE_INFO", Module.RareAlert_CheckInstance)
	end
end
