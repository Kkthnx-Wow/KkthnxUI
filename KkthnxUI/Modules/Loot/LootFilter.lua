local K, C, L = unpack(select(2, ...))
if C.Loot.LootFilter ~= true then return end

-- Better loot filter
-- 0 = Poor, 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Epic, 5 = Legendary, 6 = Artifact, 7 = Heirloom
local minRarity = 3
function lootfilter(self,event,msg)
	if not string.match(msg,"Hbattlepet") then
		local itemID = select(3, string.find(msg, "item:(%d+):"))
		local itemRarity = select(3, GetItemInfo(itemID))

		if (itemRarity < minRarity) and (string.find(msg, "receives") or string.find(msg, "gets") or string.find(msg, "creates")) then
			return true
		else
			return false
		end
	else
		return false
	end

end
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", lootfilter)