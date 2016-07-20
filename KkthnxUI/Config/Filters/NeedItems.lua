local K, C, L, _ = select(2, ...):unpack()
if C.Loot.AutoGreed ~= true then return end

--	The best way to add or delete item is to go at www.wowhead.com, search for a item.
--	Example: Amani Hex Stick -> http://www.wowhead.com/item=33865
--	Take the number ID at the end of the URL, and add it to the list
K.NeedLoot = {
	33865,	-- Amani Hex Stick
	68729,	-- Elementium Lockbox
}