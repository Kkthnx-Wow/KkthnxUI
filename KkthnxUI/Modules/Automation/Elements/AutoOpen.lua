local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Cache functions for performance
local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerItemLink = C_Container.GetContainerItemLink
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local OPENING = OPENING

local openFrames = {
	bank = false,
	guildBank = false,
	mail = false,
	merchant = false,
}

-- Helper functions to set frame status
local function FrameOpened(frameType)
	openFrames[frameType] = true
end

local function FrameClosed(frameType)
	openFrames[frameType] = false
end

-- Handles auto-opening items based on conditions
local function BagDelayedUpdate(event)
	if openFrames.bank or openFrames.mail or openFrames.merchant then
		return
	end

	-- Handle combat lockdown
	if InCombatLockdown() then
		if event ~= "PLAYER_REGEN_ENABLED" then
			-- Register the event only if it’s not already registered
			K:RegisterEvent("PLAYER_REGEN_ENABLED", BagDelayedUpdate)
		end
		return
	end

	-- Unregister PLAYER_REGEN_ENABLED after leaving combat
	if event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", BagDelayedUpdate)
	end

	-- Loop through bags and check for items to open
	for bag = 0, 4 do
		for slot = 0, C_Container_GetContainerNumSlots(bag) do
			local cInfo = C_Container_GetContainerItemInfo(bag, slot)
			if cInfo and cInfo.hasLoot and not cInfo.isLocked and C.AutoOpenItems[cInfo.itemID] then
				K.Print(K.SystemColor .. OPENING .. ":|r " .. C_Container_GetContainerItemLink(bag, slot))
				C_Container_UseContainerItem(bag, slot)
				break
			end
		end
	end
end

-- Event handlers
local events = {
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
		for event, func in pairs(events) do
			K:RegisterEvent(event, func)
		end
	else
		for event, func in pairs(events) do
			K:UnregisterEvent(event, func)
		end
	end
end
