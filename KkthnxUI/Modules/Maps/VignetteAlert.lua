local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("VignetteAlert", "AceEvent-3.0")

if not Module then
	return
end

local _G = _G
local string_format = string.format
local select = select
local print = print
local table_wipe = table.wipe

local PlaySound = _G.PlaySound
local GetAtlasInfo = _G.GetAtlasInfo
local GetInstanceInfo = _G.GetInstanceInfo
local C_VignetteInfo_GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo

local RareAlertInWild = false

local cache = {}
local isIgnored = {
	[1153] = true,
	[1159] = true,
	[1803] = true,
	[1876] = true,
	[1943] = true,
	[2111] = true,
}

function Module:RareAlert_Update(id)
	if id and not cache[id] then
		local instType = select(2, GetInstanceInfo())
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

		UIErrorsFrame:AddMessage("|cff99ccff"..L["Maps"].RareFound..tex..(info.name or ""))
		local currrentTime = "|cff808080".."["..date("%H:%M:%S").."]|r"
		print(currrentTime.." -> ".."|cff99ccff"..L["Maps"].RareFound..tex..(info.name or ""))

		if not RareAlertInWild or instType == "none" then
			PlaySound(23404, "master")
		end

		cache[id] = true
	end

	if #cache > 666 then
		table_wipe(cache)
	end
end

function Module:RareAlert_CheckInstance()
	local _, instanceType, _, _, maxPlayers, _, _, instID = GetInstanceInfo()
	if (instID and isIgnored[instID]) or (instanceType == "scenario" and maxPlayers == 3) then
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	else
		K:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", Module.RareAlert_Update)
	end
end

function Module:RareAlert()
	if K.CheckAddOnState("VignetteAnnouncer") or K.CheckAddOnState("SilverDragon") then
		return
	end

	if C["Minimap"].VignetteAlert then
		self:RareAlert_CheckInstance()
		K:RegisterEvent("PLAYER_ENTERING_WORLD", self.RareAlert_CheckInstance)
	else
		table_wipe(cache)
		K:UnregisterEvent("VIGNETTE_MINIMAP_UPDATED", self.RareAlert_Update)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.RareAlert_CheckInstance)
	end
end

function Module:OnEnable()
	self:RareAlert()
end