--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Highlights known recipes, mounts, and pets in various merchant and bank frames.
-- - Design: Hooks Merchant, Guild Bank, and Auction House frames to apply a green tint to already collected items.
-- - Events: ADD_CHART_ITEM_INFO (simulated), ADDON_LOADED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local math_ceil = _G.math.ceil
local string_format = _G.string.format
local select = _G.select
local string_find = _G.string.find
local string_match = _G.string.match
local tonumber = _G.tonumber

local _G = _G
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_Item_GetItemInfo = _G.C_Item.GetItemInfo
local C_MerchantFrame_GetItemInfo = _G.C_MerchantFrame.GetItemInfo
local C_PetJournal_GetNumCollectedInfo = _G.C_PetJournal.GetNumCollectedInfo
local C_TooltipInfo_GetGuildBankItem = _G.C_TooltipInfo.GetGuildBankItem
local C_TooltipInfo_GetHyperlink = _G.C_TooltipInfo.GetHyperlink
local GetBuybackItemInfo = _G.GetBuybackItemInfo
local GetBuybackItemLink = _G.GetBuybackItemLink
local GetCurrentGuildBankTab = _G.GetCurrentGuildBankTab
local GetGuildBankItemInfo = _G.GetGuildBankItemInfo
local GetGuildBankItemLink = _G.GetGuildBankItemLink
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantNumItems = _G.GetMerchantNumItems
local GetNumBuybackItems = _G.GetNumBuybackItems
local SetItemButtonDesaturated = _G.SetItemButtonDesaturated
local SetItemButtonTextureVertexColor = _G.SetItemButtonTextureVertexColor
local hooksecurefunc = _G.hooksecurefunc

-- SG: Localize Constants
local BUYBACK_ITEMS_PER_PAGE = _G.BUYBACK_ITEMS_PER_PAGE
local COLLECTED = _G.COLLECTED
local ITEM_SPELL_KNOWN = _G.ITEM_SPELL_KNOWN
local MAX_GUILDBANK_SLOTS_PER_TAB = _G.MAX_GUILDBANK_SLOTS_PER_TAB or 98
local NUM_SLOTS_PER_GUILDBANK_GROUP = _G.NUM_SLOTS_PER_GUILDBANK_GROUP or 14

local KNOWABLE_CLASSES = {
	[_G.Enum.ItemClass.Consumable] = true,
	[_G.Enum.ItemClass.Recipe] = true,
	[_G.Enum.ItemClass.Miscellaneous] = true,
	[_G.Enum.ItemClass.ItemEnhancement] = true,
}

local KNOWN_ITEMS_CACHE = {}

local function isPetSpeciesCollected(speciesID)
	if not speciesID or speciesID == 0 then
		return
	end
	local numOwned = C_PetJournal_GetNumCollectedInfo(speciesID)
	return numOwned > 0
end

-- REASON: Determines if an item is already known by checking pet journal collection or scanning tooltip data for "Already Known" strings.
local function isItemAlreadyKnown(link, index)
	if not link then
		return
	end

	local linkType, linkID = string_match(link, "|H(%a+):(%d+)")
	linkID = tonumber(linkID)

	if linkType == "battlepet" then
		return isPetSpeciesCollected(linkID)
	elseif linkType == "item" then
		local name, _, _, _, _, _, _, _, _, _, _, itemClassID = C_Item_GetItemInfo(link)
		if not name then
			return
		end

		if itemClassID == _G.Enum.ItemClass.Battlepet and index then
			local data = C_TooltipInfo_GetGuildBankItem(GetCurrentGuildBankTab(), index)
			if data then
				return data.battlePetSpeciesID and isPetSpeciesCollected(data.battlePetSpeciesID)
			end
		else
			if KNOWN_ITEMS_CACHE[link] then
				return true
			end
			if not KNOWABLE_CLASSES[itemClassID] then
				return
			end

			local data = C_TooltipInfo_GetHyperlink(link, nil, nil, true)
			if data then
				for i = 1, #data.lines do
					local lineData = data.lines[i]
					local text = lineData and lineData.leftText
					if text then
						-- REASON: Checking for Blizzard's standard "Already Known" and "Collected" localization strings.
						if string_find(text, COLLECTED) or text == ITEM_SPELL_KNOWN then
							KNOWN_ITEMS_CACHE[link] = true
							return true
						end
					end
				end
			end
		end
	end
end

-- REASON: Injects "Already Known" coloring into the standard Merchant UI.
function Module:Merchant()
	local merchantItemsPerPage = _G.MERCHANT_ITEMS_PER_PAGE
	local merchantFrame = _G.MerchantFrame
	local totalMerchantItems = GetMerchantNumItems()

	for i = 1, merchantItemsPerPage do
		local merchantIndex = (merchantFrame.page - 1) * merchantItemsPerPage + i
		if merchantIndex > totalMerchantItems then
			return
		end

		local merchantButton = _G["MerchantItem" .. i .. "ItemButton"]
		if merchantButton and merchantButton:IsShown() then
			local itemInfo = C_MerchantFrame_GetItemInfo(merchantIndex)
			local availableStock, canUseItem = itemInfo.numAvailable, itemInfo.isUsable
			if canUseItem and isItemAlreadyKnown(GetMerchantItemLink(merchantIndex)) then
				local r, g, b = 0, 1, 0
				if availableStock == 0 then
					r, g, b = r * 0.5, g * 0.5, b * 0.5
				end
				SetItemButtonTextureVertexColor(merchantButton, 0.9 * r, 0.9 * g, 0.9 * b)
			else
				local iconTexture = _G["MerchantItem" .. i .. "ItemButtonIconTexture"]
				if iconTexture then
					iconTexture:SetDesaturated(false)
				end
			end
		end
	end
end

-- REASON: Injects "Already Known" coloring into the Merchant Buyback UI.
function Module:Buyback()
	local totalBuybackItems = GetNumBuybackItems()

	for index = 1, BUYBACK_ITEMS_PER_PAGE do
		if index > totalBuybackItems then
			return
		end

		local merchantButton = _G["MerchantItem" .. index .. "ItemButton"]
		if merchantButton and merchantButton:IsShown() then
			local canUseItem = select(6, GetBuybackItemInfo(index))
			if canUseItem and isItemAlreadyKnown(GetBuybackItemLink(index)) then
				local r, g, b = 0, 1, 0
				SetItemButtonTextureVertexColor(merchantButton, 0.9 * r, 0.9 * g, 0.9 * b)
			else
				local iconTexture = _G["MerchantItem" .. index .. "ItemButtonIconTexture"]
				if iconTexture then
					iconTexture:SetDesaturated(false)
				end
			end
		end
	end
end

-- REASON: Injects "Already Known" coloring into the Guild Bank UI slots.
function Module:GuildBank(guildBankFrame)
	if guildBankFrame.mode ~= "bank" then
		return
	end

	local currentTab = GetCurrentGuildBankTab()
	for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		local slotIndex = i % NUM_SLOTS_PER_GUILDBANK_GROUP
		if slotIndex == 0 then
			slotIndex = NUM_SLOTS_PER_GUILDBANK_GROUP
		end

		local columnIndex = math_ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
		local slotButton = guildBankFrame.Columns[columnIndex].Buttons[slotIndex]
		if slotButton and slotButton:IsShown() then
			local itemIcon, _, isItemLocked = GetGuildBankItemInfo(currentTab, i)
			if itemIcon and not isItemLocked then
				if isItemAlreadyKnown(GetGuildBankItemLink(currentTab, i), i) then
					local r, g, b = 0, 1, 0
					SetItemButtonTextureVertexColor(slotButton, r, g, b)
				else
					SetItemButtonTextureVertexColor(slotButton, 1, 1, 1)
					SetItemButtonDesaturated(slotButton, false)
				end
			end
		end
	end
end

-- REASON: Injects "Already Known" coloring into the new 10.0+ Auction House UI rows.
function Module:AuctionHouse(auctionHouseFrame)
	local scrollTarget = auctionHouseFrame.ScrollTarget
	for childIndex = 1, scrollTarget:GetNumChildren() do
		local rowFrame = select(childIndex, scrollTarget:GetChildren())
		if rowFrame.cells then
			local iconCell = rowFrame.cells[2]
			local itemDataKey = iconCell and iconCell.rowData and iconCell.rowData.itemKey
			if itemDataKey and itemDataKey.itemID then
				local auctionItemLink
				if itemDataKey.itemID == 82800 then -- REASON: Item ID 82800 is the placeholder for Battle Pets in the AH data structure.
					auctionItemLink = string_format("|Hbattlepet:%d::::::|h[Dummy]|h", itemDataKey.battlePetSpeciesID)
				else
					auctionItemLink = string_format("|Hitem:%d", itemDataKey.itemID)
				end

				if auctionItemLink and isItemAlreadyKnown(auctionItemLink) then
					local red, green, blue = 0, 1, 0
					rowFrame.SelectedHighlight:Show()
					rowFrame.SelectedHighlight:SetVertexColor(red, green, blue)
					rowFrame.SelectedHighlight:SetAlpha(0.25)
					iconCell.Icon:SetVertexColor(red, green, blue)
					iconCell.IconBorder:SetVertexColor(red, green, blue)
					iconCell.Icon:SetDesaturated(false)
				else
					rowFrame.SelectedHighlight:SetVertexColor(1, 1, 1)
					iconCell.Icon:SetVertexColor(1, 1, 1)
					iconCell.IconBorder:SetVertexColor(1, 1, 1)
					iconCell.Icon:SetDesaturated(false)
				end
			end
		end
	end
end

do
	local addonLoadHookCount = 0
	-- REASON: Listens for Blizzard UI modules to load so that custom hooks can be applied to frames like the Auction House and Guild Bank.
	function Module:ADDON_LOADED(addonEvent, addonName)
		if addonName == "Blizzard_AuctionHouseUI" then
			hooksecurefunc(_G.AuctionHouseFrame.BrowseResultsFrame.ItemList.ScrollBox, "Update", self.AuctionHouse)
			addonLoadHookCount = addonLoadHookCount + 1
		elseif addonName == "Blizzard_GuildBankUI" then
			hooksecurefunc(_G.GuildBankFrame, "Update", self.GuildBank)
			addonLoadHookCount = addonLoadHookCount + 1
		end

		if addonLoadHookCount == 2 then
			K:UnregisterEvent("ADDON_LOADED", self.ADDON_LOADED)
		end
	end
end

-- REASON: Main entry point for the "Already Known" module. Hooks Blizzard merchant functions and registers for addon loading events.
function Module:CreateAlreadyKnown()
	if C_AddOns_IsAddOnLoaded("AlreadyKnown") then
		return
	end

	hooksecurefunc("MerchantFrame_UpdateMerchantInfo", self.Merchant)
	hooksecurefunc("MerchantFrame_UpdateBuybackInfo", self.Buyback)
	K:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED)
end
