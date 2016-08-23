local K, C, L, _ = select(2, ...):unpack()
if C.Misc.AutoSellGrays and C.Misc.SellMisc ~= true then return end

--[[
	The best way to add or delete item is to go at www.wowhead.com, search for a item.
	Example: Raw Longjaw Mud Snapper -> http://www.wowhead.com/item=6289
	Take the number ID at the end of the URL, and add it to the list
]]--

K.MerchantFilter = {
	[6289] = true, -- RAW LONGJAW MUD SNAPPER
	[6291] = true, -- RAW BRILLIANT SMALLFISH
	[6308] = true, -- RAW BRISTLE WHISKER CATFISH
	[6309] = true, -- 17 POUND CATFISH
	[6310] = true, -- 19 POUND CATFISH
	[41808] = true, -- BONESCALE SNAPPER
	[42336] = true, -- BLOODSTONE BAND
	[42337] = true, -- SUN ROCK RING
	[43244] = true, -- CRYSTAL CITRINE NECKLACE
	[43571] = true, -- SEWER CARP
	[43572] = true, -- MAGIC EATER
}