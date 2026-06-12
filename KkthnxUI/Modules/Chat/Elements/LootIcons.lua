--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Adds item icons to loot messages in the chat frame.
-- - Design: Uses a chat message filter to parse item links and prepend the item's icon texture.
-- - Events: CHAT_MSG_LOOT
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local C_Item_GetItemIconByID = C_Item.GetItemIconByID
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local string_gsub = string.gsub

local string_format = string.format

-- ---------------------------------------------------------------------------
-- Loot Icons Logic
-- ---------------------------------------------------------------------------
local function Icon(link)
	local texture = C_Item_GetItemIconByID(link)
	if not texture then
		return link
	end
	return string_format("\124T%s:12:12:0:0:64:64:5:59:5:59\124t%s", texture, link)
end

local function AddLootIcons(_, _, message, ...)
	message = string_gsub(message, "(\124c%x+\124Hitem:.-\124h\124r)", Icon)
	return false, message, ...
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateLootIcons()
	-- REASON: Setup loot icons in chat frame messages if enabled.
	if not C["Chat"].LootIcons then
		return
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", AddLootIcons)
end
