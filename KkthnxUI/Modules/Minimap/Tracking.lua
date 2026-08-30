--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Minimap/Tracking.lua
	Purpose:
		The minimap right-click context menu: a Tracking submenu of live toggles
		plus calendar and stopwatch shortcuts, built with the modern MenuUtil
		descriptor API. Left-click still pings the map.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local Module = K:GetModule("Minimap")

local _G = _G
local ToggleCalendar = _G.ToggleCalendar
local ToggleTimeManager = _G.ToggleTimeManager
local C_Minimap = _G.C_Minimap

local Minimap = _G.Minimap

-- Toggle one tracking type by index using the verified C_Minimap API.
local function IsTracking(index)
	local info = C_Minimap and C_Minimap.GetTrackingInfo(index)
	return info and info.active
end
-- Toggle through MinimapUtil, the way Blizzard's own tracking menu does. Some
-- filters (a handful of gathering and quest trackings) are backed by a saved
-- setting, so a plain C_Minimap.SetTracking is re-asserted from that setting and
-- the toggle appears to revert (GitHub #135). MinimapUtil syncs the setting too.
local function SetTracking(index)
	local util = _G.MinimapUtil
	if util and util.SetTrackingFilterByFilterIndex then
		util.SetTrackingFilterByFilterIndex(index, not IsTracking(index))
	elseif C_Minimap and C_Minimap.SetTracking then
		C_Minimap.SetTracking(index, not IsTracking(index))
	end
end

-- Build the right-click context menu.
local function BuildMenu(_, root)
	root:CreateTitle(_G.MINIMAP_LABEL or "Minimap")

	if C_Minimap and C_Minimap.GetNumTrackingTypes then
		local tracking = root:CreateButton(_G.TRACKING or "Tracking")
		for i = 1, C_Minimap.GetNumTrackingTypes() do
			local info = C_Minimap.GetTrackingInfo(i)
			if info and info.name and info.name ~= "" then
				tracking:CreateCheckbox(info.name, IsTracking, SetTracking, i)
			end
		end
	end

	root:CreateButton(_G.CALENDAR_VIEW_EVENT or "Calendar", function()
		if ToggleCalendar then
			ToggleCalendar()
		end
	end)
	root:CreateButton(_G.TIMEMANAGER_TITLE or "Stopwatch", function()
		if ToggleTimeManager then
			ToggleTimeManager()
		end
	end)
end

-- Right-click opens our context menu, left-click pings as normal.
local function OnMouseUp(self, button)
	if button == "RightButton" then
		if _G.MenuUtil and _G.MenuUtil.CreateContextMenu then
			_G.MenuUtil.CreateContextMenu(self, BuildMenu)
		elseif _G.MinimapCluster and _G.MinimapCluster.Tracking and _G.MinimapCluster.Tracking.Button then
			_G.MinimapCluster.Tracking.Button:OpenMenu()
		end
	elseif Minimap.OnClick then
		Minimap:OnClick(button)
	end
end

function Module:SetupClickMenu()
	Minimap:SetScript("OnMouseUp", OnMouseUp)
end
