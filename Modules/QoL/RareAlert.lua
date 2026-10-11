--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/RareAlert.lua
	Purpose:
		Say so when a rare or other unique creature shows up on the minimap: text
		in the middle of the screen, a sound, and a chat line with a clickable map
		link to where it is.

		Driven by the minimap vignette event, so nothing polls. Each creature is
		announced once per zone, and dead ones are ignored. Nothing is announced
		inside dungeons, raids, scenarios or battlegrounds, where the minimap is
		full of objectives rather than finds.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret
local IsInInstance = IsInInstance
local PlaySound = PlaySound
local format = string.format
local find = string.find
local wipe = wipe
local C_Map = C_Map
local C_VignetteInfo = C_VignetteInfo

-- Announced creatures, keyed by their object GUID, cleared on every zone change.
local announced = {}
local alert

local function Announce(info)
	local icon = format("|A:%s:16:16|a", info.atlasName)
	alert:Flash(format("%s %s", icon, info.name), 1, 0.82, 0.2)

	if C.QoL.RareAlertSound then
		PlaySound(_G.SOUNDKIT.RAID_WARNING, "Master")
	end

	if C.QoL.RareAlertChat then
		local mapID = C_Map.GetBestMapForUnit("player")
		local position = mapID and C_VignetteInfo.GetVignettePosition(info.vignetteGUID, mapID)
		local link = info.name
		if position then
			local x, y = position:GetXY()
			link = format("|Hworldmap:%d:%d:%d|h[%s (%.1f, %.1f)]|h", mapID, x * 10000, y * 10000, info.name, x * 100, y * 100)
		end
		K.Print("%s %s", icon, link)
	end
end

local function OnVignette(_, _, vignetteGUID, onMinimap)
	if not onMinimap or IsSecret(vignetteGUID) or IsInInstance() then
		return
	end
	local info = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
	if not info or info.isDead or not info.isUnique then
		return
	end
	local name, atlas, key = info.name, info.atlasName, info.objectGUID
	if not (name and atlas and key) or IsSecret(name) or IsSecret(atlas) or IsSecret(key) then
		return
	end
	-- Vignette atlases are all named so, which tells a find from a plain map icon.
	if not find(atlas, "[Vv]ignette") or announced[key] then
		return
	end
	announced[key] = true
	Announce(info)
end

function Module:SetupRareAlert()
	alert = self:RegisterAlert("RareAlert", L["Rare Alert"], "TOP", -150)
	self:RegisterEvent("VIGNETTE_MINIMAP_UPDATED", OnVignette)
	self:RegisterEvent("LOADING_SCREEN_DISABLED", function()
		wipe(announced)
	end)
end
