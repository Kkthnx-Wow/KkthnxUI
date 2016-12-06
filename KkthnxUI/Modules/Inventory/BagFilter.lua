local K, C, L = select(2, ...):unpack()
if C.Bags.BagFilter ~= true then return end

-- Lua API
local select = select

-- Wow API
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetItemInfo = GetItemInfo

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PickupContainerItem, DeleteCursorItem

local BagFilter = CreateFrame("Frame")
local Link

BagFilter.Trash = {
	32902, -- Bottled Nethergon Energy
	32905, -- Bottled Nethergon Vapor
	32897, -- Mark of the Illidari
}

BagFilter:RegisterEvent("PLAYER_LOGIN")
BagFilter:RegisterEvent("CHAT_MSG_LOOT")
BagFilter:SetScript("OnEvent", function(self, event)
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			Link = select(7, GetContainerItemInfo(bag, slot))

			for i = 1, #BagFilter.Trash do
				if (Link and (GetItemInfo(Link) == GetItemInfo(BagFilter.Trash[i]))) then
					PickupContainerItem(bag, slot)
					DeleteCursorItem()
				end
			end
		end
	end
end)