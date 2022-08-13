local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Tooltip")

local _G = _G
local select = _G.select
local string_format = _G.string.format
local string_find = _G.string.find
local string_match = _G.string.match
local tonumber = _G.tonumber

local GetItemInfo = _G.GetItemInfo
local GetItemInfoFromHyperlink = _G.GetItemInfoFromHyperlink

local DOMI_RANK_STRING = "%s (%d/5)"
local nameCache = {}

Module.DomiRankData = {}
Module.DomiIndexData = {}
Module.DomiDataByGroup = {
	[1] = {
		[187079] = 1, -- Zed Shard
		[187292] = 2, -- Shard of Ominous Zed
		[187301] = 3, -- Desolate Zed Shard
		[187310] = 4, -- Premonition Zed Shard
		[187320] = 5, -- Omen Zed Shard
	},
	[2] = {
		[187076] = 1, -- Fragment of Oz
		[187291] = 2, -- Ominous Oz Shard
		[187300] = 3, -- Fragment of Desolate Oz
		[187309] = 4, -- Premonition Oz Shard
		[187319] = 5, -- Omen Shards
	},
	[3] = {
		[187073] = 1, -- Deeds Shard
		[187290] = 2, -- Ominous Dizzy Shard
		[187299] = 3, -- Desolate Dizzy Shard
		[187308] = 4, -- Premonition Deeds Fragment
		[187318] = 5, -- Omen Dizzy Fragment
	},
	[4] = {
		[187071] = 1, -- shard of Tyre
		[187289] = 2, -- Ominous Tyr Shard
		[187298] = 3, -- Desolate Tyr Fragment
		[187307] = 4, -- Premonition Tyre Fragment
		[187317] = 5, -- Omen Tell Shard
	},
	[5] = {
		[187065] = 1, -- Kiel Fragment
		[187288] = 2, -- Ominous Kiel Fragment
		[187297] = 3, -- Desolate Kiel Fragment
		[187306] = 4, -- Premonition Kiel Fragment
		[187316] = 5, -- Omen Kiel Fragment
	},
	[6] = {
		[187063] = 1, -- Kerr fragment
		[187287] = 2, -- Ominous Kerr Fragment
		[187296] = 3, -- Desolate Kerr Shard
		[187305] = 4, -- Premonition Kerr Fragment
		[187315] = 5, -- Omen Kerr Fragment
	},
	[7] = {
		[187061] = 1, -- Rever Fragment
		[187286] = 2, -- Ominous Rever Fragment
		[187295] = 3, -- Desolate Rever Fragment
		[187304] = 4, -- Premonition Rever Fragment
		[187314] = 5, -- Omen Rever Fragment
	},
	[8] = {
		[187059] = 1, -- Yas Fragment
		[187285] = 2, -- Shard of Ominous Yass
		[187294] = 3, -- Desolate Yass Fragment
		[187303] = 4, -- Premonition Yas Fragment
		[187313] = 5, -- Omen Yas Fragment
	},
	[9] = {
		[187057] = 1, -- Baker Fragment
		[187284] = 2, -- Ominous Baker Fragment
		[187293] = 3, -- Desolate Baker Shard
		[187302] = 4, -- Premonition Baker Fragment
		[187312] = 5, -- Omen Baker Fragment
	},
}

local domiTextureIDs = {
	[457655] = true,
	[1003591] = true,
	[1392550] = true,
}

for index, value in pairs(Module.DomiDataByGroup) do
	for itemID, rank in pairs(value) do
		Module.DomiRankData[itemID] = rank
		Module.DomiIndexData[itemID] = index
	end
end

function Module:GetDomiName(itemID)
	local name = nameCache[itemID]
	if not name then
		name = GetItemInfo(itemID)
		nameCache[itemID] = name
	end

	return name
end

function Module:Domination_UpdateText(name, rank)
	local tex = _G[self:GetName() .. "Texture1"]
	local texture = tex and tex:IsShown() and tex:GetTexture()
	if texture and domiTextureIDs[texture] then
		local textLine = select(2, tex:GetPoint())
		local text = textLine and textLine:GetText()
		if text then
			textLine:SetText(text .. "|n" .. string_format(DOMI_RANK_STRING, name, rank))
		end
	end
end

function Module:Domination_CheckStatus()
	local _, link = self:GetItem()
	if not link then
		return
	end

	local itemID = GetItemInfoFromHyperlink(link)
	local rank = itemID and Module.DomiRankData[itemID]

	if rank then
		-- Domi rank on gems
		local textLine = _G[self:GetName() .. "TextLeft2"]
		local text = textLine and textLine:GetText()
		if text and string_find(text, "|cFF66BBFF") then
			textLine:SetFormattedText(DOMI_RANK_STRING, text, rank)
		end
	else
		-- Domi rank on gears
		local gemID = string_match(link, "item:%d+:%d*:(%d*):")
		itemID = tonumber(gemID)
		rank = itemID and Module.DomiRankData[itemID]
		if rank then
			local name = Module:GetDomiName(itemID)
			Module.Domination_UpdateText(self, name, rank)
		end
	end
end

function Module:CreateDominationRank()
	if not C["Tooltip"].DominationRank then
		return
	end

	GameTooltip:HookScript("OnTooltipSetItem", Module.Domination_CheckStatus)
	ItemRefTooltip:HookScript("OnTooltipSetItem", Module.Domination_CheckStatus)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", Module.Domination_CheckStatus)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", Module.Domination_CheckStatus)
end
