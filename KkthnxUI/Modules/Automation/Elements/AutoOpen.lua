local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Performance optimizations
local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerItemLink = C_Container.GetContainerItemLink
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local InCombatLockdown = InCombatLockdown
local OPENING = OPENING

-- Frame state tracking
local openFrames = {
	bank = false,
	guildBank = false,
	mail = false,
	merchant = false,
}

-- Helper functions to manage frame states
local function FrameOpened(frameType)
	openFrames[frameType] = true
end

local function FrameClosed(frameType)
	openFrames[frameType] = false
end

-- Check if any blocking frames are open
local function IsBlockingFrameOpen()
	return openFrames.bank or openFrames.mail or openFrames.merchant
end

-- Enhanced bag scanning with better performance
local function ScanBagsForOpenableItems()
	if IsBlockingFrameOpen() then
		return false
	end

	-- Handle combat lockdown
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", ScanBagsForOpenableItems)
		return false
	end

	local itemOpened = false

	-- Scan bags efficiently
	for bag = 0, 4 do
		local numSlots = C_Container_GetContainerNumSlots(bag)
		if numSlots > 0 then
			for slot = 1, numSlots do
				local itemInfo = C_Container_GetContainerItemInfo(bag, slot)
				if itemInfo and itemInfo.hasLoot and not itemInfo.isLocked and C.AutoOpenItems[itemInfo.itemID] then
					local itemLink = C_Container_GetContainerItemLink(bag, slot)
					K.Print(K.SystemColor .. OPENING .. ":|r " .. (itemLink or "Unknown Item"))
					C_Container_UseContainerItem(bag, slot)
					itemOpened = true
					break -- Only open one item per scan to avoid spam
				end
			end
			if itemOpened then
				break
			end
		end
	end

	return itemOpened
end

-- Main bag update handler
local function BagDelayedUpdate(event)
	-- Unregister combat event if we're out of combat
	if event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", ScanBagsForOpenableItems)
	end

	ScanBagsForOpenableItems()
end

-- Event handlers with improved organization
local eventHandlers = {
	BANKFRAME_OPENED = function()
		FrameOpened("bank")
	end,
	BANKFRAME_CLOSED = function()
		FrameClosed("bank")
	end,
	GUILDBANKFRAME_OPENED = function()
		FrameOpened("guildBank")
	end,
	GUILDBANKFRAME_CLOSED = function()
		FrameClosed("guildBank")
	end,
	MAIL_SHOW = function()
		FrameOpened("mail")
	end,
	MAIL_CLOSED = function()
		FrameClosed("mail")
	end,
	MERCHANT_SHOW = function()
		FrameOpened("merchant")
	end,
	MERCHANT_CLOSED = function()
		FrameClosed("merchant")
	end,
	BAG_UPDATE_DELAYED = BagDelayedUpdate,
}

-- Register/Unregister events based on config
function Module:CreateAutoOpenItems()
	if C["Automation"].AutoOpenItems then
		for event, handler in pairs(eventHandlers) do
			K:RegisterEvent(event, handler)
		end
	else
		for event, handler in pairs(eventHandlers) do
			K:UnregisterEvent(event, handler)
		end
		-- Clean up any pending combat events
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", ScanBagsForOpenableItems)
	end
end
