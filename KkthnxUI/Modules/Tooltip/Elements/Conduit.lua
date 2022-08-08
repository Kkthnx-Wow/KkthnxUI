local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Tooltip")

local _G = _G
local pairs = _G.pairs
local select = _G.select

local C_Soulbinds_GetConduitCollection = _G.C_Soulbinds.GetConduitCollection
local C_Soulbinds_IsItemConduitByItemInfo = _G.C_Soulbinds.IsItemConduitByItemInfo
local GetItemInfo = _G.GetItemInfo
local GetItemInfoFromHyperlink = _G.GetItemInfoFromHyperlink

local COLLECTED_STRING = " |cffff0000(" .. _G.COLLECTED .. ")|r"

Module.ConduitData = {}

function Module:Conduit_UpdateCollection()
	for i = 0, 2 do
		local collectionData = C_Soulbinds_GetConduitCollection(i)
		for _, value in pairs(collectionData) do
			Module.ConduitData[value.conduitItemID] = value.conduitItemLevel
		end
	end
end

function Module:Conduit_CheckStatus()
	local _, link = self:GetItem()
	if not link then
		return
	end

	if not C_Soulbinds_IsItemConduitByItemInfo(link) then
		return
	end

	local itemID = GetItemInfoFromHyperlink(link)
	local level = select(4, GetItemInfo(link))
	local knownLevel = itemID and Module.ConduitData[itemID]

	if knownLevel and level and knownLevel >= level then
		local textLine = _G[self:GetName() .. "TextLeft1"]
		local text = textLine and textLine:GetText()
		if text and text ~= "" then
			textLine:SetText(text .. COLLECTED_STRING)
		end
	end
end

function Module:CreateConduitCollectionData()
	Module.Conduit_UpdateCollection()
	if not next(Module.ConduitData) then
		C_Timer.After(10, Module.Conduit_UpdateCollection) -- might be empty on fist load
	end
	K:RegisterEvent("SOULBIND_CONDUIT_COLLECTION_UPDATED", Module.Conduit_UpdateCollection)

	if not C["Tooltip"].ConduitInfo then
		return
	end

	GameTooltip:HookScript("OnTooltipSetItem", Module.Conduit_CheckStatus)
	ItemRefTooltip:HookScript("OnTooltipSetItem", Module.Conduit_CheckStatus)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", Module.Conduit_CheckStatus)
	GameTooltipTooltip:HookScript("OnTooltipSetItem", Module.Conduit_CheckStatus)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", Module.Conduit_CheckStatus)
end
