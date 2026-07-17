--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Auto-enable repair and mailbox minimap tracking.
-- - Design: Event-driven; toggles C_Minimap tracking indices when durability/mail changes.
-- - Events: UPDATE_INVENTORY_DURABILITY, UPDATE_PENDING_MAIL, PLAYER_ENTERING_WORLD
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local pairs = pairs
local INVENTORY_ALERT_STATUS_SLOTS = _G.INVENTORY_ALERT_STATUS_SLOTS
local GetInventoryAlertStatus = _G.GetInventoryAlertStatus
local HasNewMail = _G.HasNewMail
local MINIMAP_TRACKING_REPAIR = _G.MINIMAP_TRACKING_REPAIR
local MINIMAP_TRACKING_MAILBOX = _G.MINIMAP_TRACKING_MAILBOX
local C_Minimap = _G.C_Minimap

local trackingIndexByName = {}
local eventsRegistered = false

local function isEnabled()
	return C["Automation"].SmartTracking ~= false
end

local function resolveTrackingIndex(name)
	if trackingIndexByName[name] then
		return trackingIndexByName[name]
	end
	if not C_Minimap or not C_Minimap.GetNumTrackingTypes then
		return
	end
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local info = C_Minimap.GetTrackingInfo(index)
		if info and info.name == name then
			trackingIndexByName[name] = index
			return index
		end
	end
end

local function updateRepairTracking()
	if not isEnabled() then
		return
	end
	local worst = 0
	for slot in pairs(INVENTORY_ALERT_STATUS_SLOTS) do
		local status = GetInventoryAlertStatus(slot)
		if status and status > worst then
			worst = status
		end
	end
	local index = resolveTrackingIndex(MINIMAP_TRACKING_REPAIR)
	if index then
		C_Minimap.SetTracking(index, worst > 0)
	end
end

local function updateMailTracking()
	if not isEnabled() then
		return
	end
	local index = resolveTrackingIndex(MINIMAP_TRACKING_MAILBOX)
	if index then
		C_Minimap.SetTracking(index, HasNewMail())
	end
end

local function onEnteringWorld()
	updateRepairTracking()
	updateMailTracking()
end

function Module:CreateSmartTracking()
	if not isEnabled() then
		if eventsRegistered then
			K:UnregisterEvent("UPDATE_INVENTORY_DURABILITY", updateRepairTracking)
			K:UnregisterEvent("UPDATE_PENDING_MAIL", updateMailTracking)
			K:UnregisterEvent("PLAYER_ENTERING_WORLD", onEnteringWorld)
			eventsRegistered = false
		end
		return
	end

	if eventsRegistered then
		onEnteringWorld()
		return
	end

	eventsRegistered = true
	K:RegisterEvent("UPDATE_INVENTORY_DURABILITY", updateRepairTracking)
	K:RegisterEvent("UPDATE_PENDING_MAIL", updateMailTracking)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", onEnteringWorld)
	onEnteringWorld()
end
