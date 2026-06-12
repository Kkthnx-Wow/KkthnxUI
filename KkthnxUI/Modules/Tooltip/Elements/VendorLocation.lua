--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Shows vendor turn-in locations for special barter/curio items and supports Ctrl-click waypoints.
-- - Design: Event-driven tooltip/item-click hooks, with a small curated lookup table and cached map names.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Tooltip")

local _G = _G
local hooksecurefunc = _G.hooksecurefunc
local IsControlKeyDown = _G.IsControlKeyDown
local InCombatLockdown = _G.InCombatLockdown
local string_format = _G.string.format

local C_Map_GetAreaInfo = _G.C_Map and _G.C_Map.GetAreaInfo
local C_Map_GetMapInfo = _G.C_Map and _G.C_Map.GetMapInfo
local C_Map_CanSetUserWaypointOnMap = _G.C_Map and _G.C_Map.CanSetUserWaypointOnMap
local C_Map_OpenWorldMap = _G.C_Map and _G.C_Map.OpenWorldMap
local C_Map_SetUserWaypoint = _G.C_Map and _G.C_Map.SetUserWaypoint
local C_SuperTrack_SetSuperTrackedUserWaypoint = _G.C_SuperTrack and _G.C_SuperTrack.SetSuperTrackedUserWaypoint
local Enum = _G.Enum
local GameTooltip = _G.GameTooltip
local GetItemInfoFromHyperlink = _G["GetItemInfoFromHyperlink"]
local TooltipDataProcessor = _G["TooltipDataProcessor"]
local UiMapPoint = _G["UiMapPoint"]

local WAYPOINT_ICON = "|A:waypoint-mappin-minimap-untracked:20:20:-2:-1|a "

local vendorData = {
	-- The War Within: Midnight-era barter tokens
	[264882] = { npc = 259722, name = "Andra", map = 2393, x = 0.418, y = 0.666, noteOnly = true }, -- Finery Funds
	[267051] = { npc = 255473, name = "Maren Silverwing", map = 2393, x = 0.48, y = 0.492, noteOnly = true }, -- Dark Particle
	[259361] = { name = "Abandoned Ritual Skull", note = L["Inside the Cave"], map = 2437, x = 0.444, y = 0.436 }, -- Vile Essence
	[245937] = { npc = 245976, name = "Deminos Darktrance", map = 2444, x = 0.388, y = 0.816, noteOnly = true }, -- Void-Tainted Remains
	[248944] = { npc = 249098, name = "Balaak the Twice-Exiled", map = 2444, x = 0.536, y = 0.52, noteOnly = true }, -- Ethereal Energy

	-- The War Within
	[225557] = { npc = 226205, name = "Cendvin", map = 2248, x = 0.744, y = 0.452 }, -- Sizzling Cinderpollen
	[212493] = { npc = 225166, name = "Middles", map = 2214, x = 0.4336, y = 0.352, noteOnly = true }, -- Odd Glob of Wax
	[224642] = { npc = 216164, name = "Gnawbles", map = 2214, x = 0.436, y = 0.352 }, -- Firelight Ruby
	[238920] = { sub = 15335, name = "Morgaen's Tears", map = 2215, x = 0.282, y = 0.56 }, -- Radiant Emblem of Service
	[227673] = { npc = 226994, name = "Blair Bass", map = 2346, x = 0.342, y = 0.716 }, -- "Gold" Fish
	[233246] = { npc = 234776, name = "Angelo Rustbin", map = 2346, x = 0.258, y = 0.381, noteOnly = true }, -- Gunk-Covered Thingy
	[234741] = {
		entries = { -- Miscellaneous Mechanica
			{ npc = 228286, name = "Skedgit Cinderbangs", map = 2346, x = 0.432, y = 0.828, label = L["Mount"] },
			{ npc = 236411, name = "Ditty Fuzeboy", map = 2346, x = 0.354, y = 0.412, label = L["Pet"] },
		},
	},
	[245510] = { npc = 245348, name = "Ba'choso", map = 2371, x = 0.42, y = 0.224 }, -- Loombeast Silk

	-- Dragonflight
	[205188] = { npc = 204693, name = "Ponzo", map = 2133, x = 0.58, y = 0.538 }, -- Barter Boulder
	[204715] = { npc = 203602, name = "Spinsoa", map = 2133, x = 0.558, y = 0.554 }, -- Unearthed Fragrant Coin
	[211376] = { npc = 212797, name = "Talisa Whisperbloom", map = 2200, x = 0.498, y = 0.62 }, -- Seedbloom

	-- Class Set Curios
	[249367] = { npc = 254436, name = "Kirana", map = 2424, x = 0.556, y = 0.878, noteOnly = true }, -- Chiming Void Curio
	[237602] = { npc = 248304, name = "Acquirer Ba'theom", map = 2371, x = 0.42, y = 0.224, noteOnly = true }, -- Hungering Void Curio
	[228819] = { npc = 231824, name = "Kari Bridgeblaster", note = L["Second Floor"], sub = 15388, map = 2346, x = 0.439, y = 0.498 }, -- Excessively Bejeweled Curio
	[225634] = { npc = 227003, name = "Kir'xal", map = 2216, x = 0.566, y = 0.458, noteOnly = true }, -- Web-Wrapped Curio
	[210947] = { npc = 213278, name = "Kirasztia", map = 2200, x = 0.366, y = 0.334, noteOnly = true }, -- Flame-Warped Curio
	[206046] = { npc = 205675, name = "Kaitalla", map = 2133, x = 0.52, y = 0.256, noteOnly = true }, -- Void-Touched Curio
}

vendorData[204985] = vendorData[205188] -- Barter Brick shares Barter Boulder's vendor.

local mapNameCache = {}
local areaNameCache = {}

local function GetMapName(uiMapID)
	if not uiMapID then
		return
	end

	local cached = mapNameCache[uiMapID]
	if cached == nil then
		local info = C_Map_GetMapInfo and C_Map_GetMapInfo(uiMapID)
		cached = (info and info.name) or false
		mapNameCache[uiMapID] = cached
	end
	return cached or nil
end

local function GetAreaName(areaID)
	if not areaID then
		return
	end

	local cached = areaNameCache[areaID]
	if cached == nil then
		cached = (C_Map_GetAreaInfo and C_Map_GetAreaInfo(areaID)) or false
		areaNameCache[areaID] = cached
	end
	return cached or nil
end

local function FormatLocationLine(who, where, label)
	local text = where and where ~= "" and string_format("%s |cffffffff-|r %s", who, where) or who
	if label then
		text = label .. ": " .. text
	end
	return text
end

local function GetLocationText(entry)
	local mapName = GetMapName(entry.map)
	if entry.note then
		return FormatLocationLine(entry.note, (entry.sub and GetAreaName(entry.sub)) or mapName, entry.label)
	elseif entry.npc then
		return FormatLocationLine(entry.name or string_format("NPC %d", entry.npc), mapName, entry.label)
	elseif entry.sub then
		return FormatLocationLine(GetAreaName(entry.sub) or "", mapName, entry.label)
	end
end

local function AddLocationLine(tooltip, entry)
	local text = GetLocationText(entry)
	if text then
		tooltip:AddLine(text, 1, 0.82, 0, true)
	end
end

local function AddVendorLocation(tooltip, data)
	if not C["Tooltip"].VendorLocation or tooltip ~= GameTooltip or tooltip:IsForbidden() then
		return
	end

	local itemID = data and data.id
	local entry = itemID and vendorData[itemID]
	if not entry then
		return
	end

	tooltip:AddLine(" ")
	if entry.entries then
		for i = 1, #entry.entries do
			AddLocationLine(tooltip, entry.entries[i])
		end
	elseif not entry.noteOnly then
		AddLocationLine(tooltip, entry)
	end
	tooltip:AddLine(WAYPOINT_ICON .. L["Ctrl-Click to set a waypoint"], 0.098, 1, 0.098, true)
end

local function SetVendorWaypoint(uiMapID, x, y)
	if not (uiMapID and x and y and UiMapPoint and C_Map_SetUserWaypoint) then
		return
	end
	if C_Map_CanSetUserWaypointOnMap and not C_Map_CanSetUserWaypointOnMap(uiMapID) then
		return
	end

	C_Map_SetUserWaypoint(UiMapPoint.CreateFromCoordinates(uiMapID, x, y))
	if C_SuperTrack_SetSuperTrackedUserWaypoint then
		C_SuperTrack_SetSuperTrackedUserWaypoint(true)
	end
	if C["Tooltip"].VendorLocationOpenMap and C_Map_OpenWorldMap then
		C_Map_OpenWorldMap(uiMapID)
	end
end

local function HandleVendorModifiedClick(itemLink)
	if not C["Tooltip"].VendorLocation or not IsControlKeyDown() or not itemLink or InCombatLockdown() then
		return
	end

	local itemID = GetItemInfoFromHyperlink(itemLink)
	local entry = itemID and vendorData[itemID]
	if not entry then
		return
	end

	local destination = entry.entries and entry.entries[1] or entry
	SetVendorWaypoint(destination.map, destination.x, destination.y)
end

function Module:CreateVendorLocation()
	if not TooltipDataProcessor or not TooltipDataProcessor.AddTooltipPostCall then
		return
	end

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddVendorLocation)
	hooksecurefunc("HandleModifiedItemClick", HandleVendorModifiedClick)
end
