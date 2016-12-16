local K, C, L = unpack(select(2, ...))
if C.Misc.MerchantItemLevel ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local GetItemInfo = GetItemInfo
local GetMerchantItemLink = GetMerchantItemLink
local GetMerchantNumItems = GetMerchantNumItems

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: MERCHANT_ITEMS_PER_PAGE, MerchantFrame

-- Show item level for weapons and armor in merchant
local function MerchantItemlevel()
	local numItems = GetMerchantNumItems()

	for i = 1, MERCHANT_ITEMS_PER_PAGE do
		local index = (MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE + i
		if index > numItems then return end

		local button = _G["MerchantItem"..i.."ItemButton"]
		if button and button:IsShown() then
			if not button.text then
				button.text = button:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
				button.text:SetPoint("TOPLEFT", 2, -2)
				button.text:SetTextColor(1, 1, 0)
			else
				button.text:SetText("")
			end

			local itemLink = GetMerchantItemLink(index)
			if itemLink then
				local _, _, quality, itemlevel, _, _, _, _, _, _, _, itemClassID = GetItemInfo(itemLink)
				if (itemlevel and itemlevel > 1) and (quality and quality > 1) and (itemClassID == 2 or itemClassID == 4) then
					button.text:SetText(itemlevel)
				end
			end
		end
	end
end
hooksecurefunc("MerchantFrame_UpdateMerchantInfo", MerchantItemlevel)