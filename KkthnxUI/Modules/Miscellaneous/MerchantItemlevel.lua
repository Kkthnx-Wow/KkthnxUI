local K = unpack(select(2, ...))
local Module = K:NewModule("MerchantItemlevel")

local _G = _G

local GetItemInfo = _G.GetItemInfo
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantNumItems = _G.GetMerchantNumItems
local hooksecurefunc = _G.hooksecurefunc
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON
local MERCHANT_ITEMS_PER_PAGE = _G.MERCHANT_ITEMS_PER_PAGE
local GetItemQualityColor = _G.GetItemQualityColor

function Module:MerchantItemlevel()
	local numItems = GetMerchantNumItems()

	for i = 1, MERCHANT_ITEMS_PER_PAGE do
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i

		if index > numItems then
			return
		end

		local button = _G["MerchantItem" .. i .. "ItemButton"]
		if button and button:IsShown() then
			if not button.text then
				button.text = button:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
				button.text:SetPoint("TOPLEFT", 2, -2)
			else
				button.text:SetText("")
			end

			local itemLink = GetMerchantItemLink(index)
			if itemLink then
				local _, _, quality, itemlevel, _, _, _, _, _, _, _, itemClassID = GetItemInfo(itemLink)
				if (itemlevel and itemlevel > 1) and (quality and quality > 1) and (itemClassID == LE_ITEM_CLASS_WEAPON or itemClassID == LE_ITEM_CLASS_ARMOR) then
					button.text:SetText(itemlevel)
					button.text:SetTextColor(GetItemQualityColor(quality))
				end
			end
		end
	end
end

hooksecurefunc("MerchantFrame_UpdateMerchantInfo", Module.MerchantItemlevel)