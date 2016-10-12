local K, C, L = select(2, ...):unpack()

local Inventory = K.Inventory
local BagFilter = CreateFrame("Frame")
local Link
local TrashList = "\n\nTrash List:\n" -- 6.0 localize me

BagFilter.Trash = {
	32902, -- Bottled Nethergon Energy
	32905, -- Bottled Nethergon Vapor
	32897, -- Mark of the Illidari
}

function BagFilter:OnEvent(event)
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			Link = select(7, GetContainerItemInfo(bag, slot))

			for i = 1, #self.Trash do
				if (Link and (GetItemInfo(Link) == GetItemInfo(self.Trash[i]))) then
					PickupContainerItem(bag, slot)
					DeleteCursorItem()
				end
			end
		end
	end
end

function BagFilter:Enable()
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:SetScript("OnEvent", self.OnEvent)
end

Inventory.BagFilter = BagFilter
BagFilter:RegisterEvent("PLAYER_LOGIN")
BagFilter:SetScript("OnEvent", BagFilter.Enable)
