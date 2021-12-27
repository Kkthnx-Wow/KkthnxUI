local K = unpack(KkthnxUI)
local Module = K:GetModule("Tooltip")

-- Sourced: AlreadyKnown (villiv)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local math_ceil = _G.math.ceil
local mod = _G.mod
local string_find = _G.string.find
local string_format = _G.string.format
local string_match = _G.string.match

local BUYBACK_ITEMS_PER_PAGE = _G.BUYBACK_ITEMS_PER_PAGE or 12
local COLLECTED = _G.COLLECTED
local C_PetJournal_GetNumCollectedInfo = _G.C_PetJournal.GetNumCollectedInfo
local CreateFrame = _G.CreateFrame
local GetBuybackItemInfo = _G.GetBuybackItemInfo
local GetBuybackItemLink = _G.GetBuybackItemLink
local GetCurrentGuildBankTab = _G.GetCurrentGuildBankTab
local GetGuildBankItemInfo = _G.GetGuildBankItemInfo
local GetGuildBankItemLink = _G.GetGuildBankItemLink
local GetItemInfo = _G.GetItemInfo
local GetMerchantItemInfo = _G.GetMerchantItemInfo
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantNumItems = _G.GetMerchantNumItems
local GetNumBuybackItems = _G.GetNumBuybackItems
local HybridScrollFrame_GetButtons = _G.HybridScrollFrame_GetButtons
local ITEM_SPELL_KNOWN = _G.ITEM_SPELL_KNOWN
local LE_ITEM_CLASS_BATTLEPET = _G.LE_ITEM_CLASS_BATTLEPET
local LE_ITEM_CLASS_CONSUMABLE = _G.LE_ITEM_CLASS_CONSUMABLE
local LE_ITEM_CLASS_ITEM_ENHANCEMENT = _G.LE_ITEM_CLASS_ITEM_ENHANCEMENT
local LE_ITEM_CLASS_MISCELLANEOUS = _G.LE_ITEM_CLASS_MISCELLANEOUS
local LE_ITEM_CLASS_RECIPE = _G.LE_ITEM_CLASS_RECIPE
local MAX_GUILDBANK_SLOTS_PER_TAB = _G.MAX_GUILDBANK_SLOTS_PER_TAB or 98
local MERCHANT_ITEMS_PER_PAGE = _G.MERCHANT_ITEMS_PER_PAGE or 10
local NUM_SLOTS_PER_GUILDBANK_GROUP = _G.NUM_SLOTS_PER_GUILDBANK_GROUP or 14
local SetItemButtonTextureVertexColor = _G.SetItemButtonTextureVertexColor
local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc

local COLOR = {r = .1, g = 1, b = .1}
local knowables = {
	[LE_ITEM_CLASS_CONSUMABLE] = true,
	[LE_ITEM_CLASS_ITEM_ENHANCEMENT] = true,
	[LE_ITEM_CLASS_MISCELLANEOUS] = true,
	[LE_ITEM_CLASS_RECIPE] = true,
}
local knowns = {}

local function isPetCollected(speciesID)
	if not speciesID or speciesID == 0 then
		return
	end

	local numOwned = C_PetJournal_GetNumCollectedInfo(speciesID)
	if numOwned > 0 then
		return true
	end
end

local function IsAlreadyKnown(link, index)
	if not link then
		return
	end

	local linkType, linkID = string_match(link, "|H(%a+):(%d+)")
	linkID = tonumber(linkID)

	if linkType == "battlepet" then
		return isPetCollected(linkID)
	elseif linkType == "item" then
		local name, _, _, level, _, _, _, _, _, _, _, itemClassID = GetItemInfo(link)
		if not name then
			return
		end

		if itemClassID == LE_ITEM_CLASS_BATTLEPET and index then
			local speciesID = K.ScanTooltip:SetGuildBankItem(GetCurrentGuildBankTab(), index)
			return isPetCollected(speciesID)
		elseif Module.ConduitData[linkID] and Module.ConduitData[linkID] >= level then
			return true
		else
			if knowns[link] then
				return true
			end

			if not knowables[itemClassID] then
				return
			end

			K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
			K.ScanTooltip:SetHyperlink(link)
			for i = 1, K.ScanTooltip:NumLines() do
				local text = _G["KKUI_ScanTooltipTextLeft"..i]:GetText() or ""
				if string_find(text, COLLECTED) or text == ITEM_SPELL_KNOWN then
					knowns[link] = true
					return true
				end
			end
		end
	end
end

-- merchant frame
local function Hook_UpdateMerchantInfo()
	local numItems = GetMerchantNumItems()
	for i = 1, MERCHANT_ITEMS_PER_PAGE do
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i
		if index > numItems then
			return
		end

		local button = _G["MerchantItem"..i.."ItemButton"]
		if button and button:IsShown() then
			local _, _, _, _, numAvailable, isUsable = GetMerchantItemInfo(index)
			if isUsable and IsAlreadyKnown(GetMerchantItemLink(index)) then
				local r, g, b = COLOR.r, COLOR.g, COLOR.b
				if numAvailable == 0 then
					r, g, b = r * 0.5, g * 0.5, b * 0.5
				end
				SetItemButtonTextureVertexColor(button, r, g, b)
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateMerchantInfo", Hook_UpdateMerchantInfo)

local function Hook_UpdateBuybackInfo()
	local numItems = GetNumBuybackItems()
	for index = 1, BUYBACK_ITEMS_PER_PAGE do
		if index > numItems then
			return
		end

		local button = _G["MerchantItem"..index.."ItemButton"]
		if button and button:IsShown() then
			local _, _, _, _, _, isUsable = GetBuybackItemInfo(index)
			if isUsable and IsAlreadyKnown(GetBuybackItemLink(index)) then
				SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateBuybackInfo", Hook_UpdateBuybackInfo)

local function Hook_UpdateAuctionHouse(self)
	local numResults = self.getNumEntries()
	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame)
	local buttonCount = buttons and #buttons or 0
	local offset = self:GetScrollOffset()
	for i = 1, buttonCount do
		local visible = i + offset <= numResults
		local button = buttons[i]
		if visible then
			if button.rowData.itemKey.itemID then
				local itemLink
				if button.rowData.itemKey.itemID == 82800 then -- BattlePet
					itemLink = string_format("|Hbattlepet:%d::::::|h[Dummy]|h", button.rowData.itemKey.battlePetSpeciesID)
				else -- Normal item
					itemLink = string_format("|Hitem:%d", button.rowData.itemKey.itemID)
				end

				if itemLink and IsAlreadyKnown(itemLink) then
					-- Highlight
					button.SelectedHighlight:Show()
					button.SelectedHighlight:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
					button.SelectedHighlight:SetAlpha(0.25)
					-- Icon
					button.cells[2].Icon:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
					button.cells[2].IconBorder:SetVertexColor(COLOR.r, COLOR.g, COLOR.b)
				else
					-- Highlight
					button.SelectedHighlight:SetVertexColor(1, 1, 1)
					-- Icon
					button.cells[2].Icon:SetVertexColor(1, 1, 1)
					button.cells[2].IconBorder:SetVertexColor(1, 1, 1)
				end
			end
		end
	end
end

-- guild bank frame
local function GuildBankFrame_Update(self)
	if self.mode ~= "bank" then
		return
	end

	local button, index, column, texture, locked
	local tab = GetCurrentGuildBankTab()
	for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB do
		index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
		if index == 0 then
			index = NUM_SLOTS_PER_GUILDBANK_GROUP
		end

		column = math_ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
		button = self.Columns[column].Buttons[index]
		if button and button:IsShown() then
			texture, _, locked = GetGuildBankItemInfo(tab, i)
			if texture and not locked then
				if IsAlreadyKnown(GetGuildBankItemLink(tab, i), i) then
					SetItemButtonTextureVertexColor(button, COLOR.r, COLOR.g, COLOR.b)
				else
					SetItemButtonTextureVertexColor(button, 1, 1, 1)
				end
			end
		end
	end
end

local hookCount = 0
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, addon)
	if addon == "Blizzard_AuctionHouseUI" then
		hooksecurefunc(AuctionHouseFrame.BrowseResultsFrame.ItemList, "RefreshScrollFrame", Hook_UpdateAuctionHouse)
		hookCount = hookCount + 1
	elseif addon == "Blizzard_GuildBankUI" then
		hooksecurefunc(GuildBankFrame, "Update", GuildBankFrame_Update)
		hookCount = hookCount + 1
	end

	if hookCount >= 2 then
		eventFrame:UnregisterEvent(event)
	end
end)
