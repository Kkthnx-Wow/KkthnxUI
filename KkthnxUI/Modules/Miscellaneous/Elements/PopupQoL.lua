--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Reduce common popup friction.
-- - Design: Live-toggleable hooks for toasts, purchases, tradeables, stack buys.
-- - Events: MERCHANT_SHOW, LOOT_BIND_CONFIRM, EQUIP_BIND_TRADEABLE_CONFIRM, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local floor = math.floor
local min = math.min
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local StaticPopupDialogs = _G.StaticPopupDialogs
local StaticPopup_Show = _G.StaticPopup_Show
local StaticPopup_Hide = _G.StaticPopup_Hide
local BuyMerchantItem = _G.BuyMerchantItem
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetMerchantItemCostItem = _G.GetMerchantItemCostItem
local GetMoney = _G.GetMoney
local ConfirmLootSlot = _G.ConfirmLootSlot
local EquipPendingItem = _G.EquipPendingItem
local SellCursorItem = _G.SellCursorItem
local CursorHasItem = _G.CursorHasItem
local UIParent = _G.UIParent
local MerchantFrame = _G.MerchantFrame
local EventToastManagerFrame = _G.EventToastManagerFrame
local C_Item = _G.C_Item
local C_MerchantFrame = _G.C_MerchantFrame
local MAX_ITEM_COST = _G.MAX_ITEM_COST
local YES = _G.YES
local NO = _G.NO

local applied = {}
local toastHooked
local originalEnterPurchase
local stackBuySkipCache = {}
local origMerchantModifiedClick

local function isEnabled()
	return C["Misc"].PopupQoL
end

local function option(key)
	return C["Misc"][key]
end

local function SetPopupFlag(dialogName, field, value)
	local dialog = StaticPopupDialogs and StaticPopupDialogs[dialogName]
	if dialog then
		dialog[field] = value
	end
end

local function ApplyEscapeGuards()
	SetPopupFlag("PARTY_INVITE", "hideOnEscape", nil)
	SetPopupFlag("CONFIRM_SUMMON", "hideOnEscape", nil)
	SetPopupFlag("AREA_SPIRIT_HEAL", "hideOnEscape", nil)
	SetPopupFlag("CAMP", "hideOnEscape", nil)
	applied.escapeGuards = true
end

local function OnToastDisplay(frame)
	if not isEnabled() or not option("PopupClickThroughToasts") then
		return
	end
	frame:EnableMouse(false)
	local toast = frame.currentDisplayingToast
	if toast then
		toast:EnableMouse(false)
		if toast.TitleTextMouseOverFrame then
			toast.TitleTextMouseOverFrame:EnableMouse(false)
		end
		if toast.SubTitleMouseOverFrame then
			toast.SubTitleMouseOverFrame:EnableMouse(false)
		end
	end
end

local function HookToasts()
	if toastHooked or not EventToastManagerFrame then
		return
	end
	hooksecurefunc(EventToastManagerFrame, "DisplayToast", OnToastDisplay)
	toastHooked = true
end

local function ApplyEnterPurchase()
	if not StaticPopupDialogs or applied.enterPurchase then
		return
	end
	local dialog = StaticPopupDialogs.CONFIRM_PURCHASE_NONREFUNDABLE_ITEM
	if dialog then
		originalEnterPurchase = dialog.enterClicksFirstButton
		dialog.enterClicksFirstButton = true
		applied.enterPurchase = true
	end
end

local function RestoreEnterPurchase()
	if not applied.enterPurchase or not StaticPopupDialogs then
		return
	end
	local dialog = StaticPopupDialogs.CONFIRM_PURCHASE_NONREFUNDABLE_ITEM
	if dialog then
		dialog.enterClicksFirstButton = originalEnterPurchase
	end
	applied.enterPurchase = nil
end

local function ConfirmLoot(_, lootSlot)
	ConfirmLootSlot(lootSlot)
end

local function ApplyLootConfirm()
	if applied.lootConfirm then
		return
	end
	if UIParent then
		UIParent:UnregisterEvent("LOOT_BIND_CONFIRM")
	end
	K:RegisterEvent("LOOT_BIND_CONFIRM", ConfirmLoot)
	applied.lootConfirm = true
end

local function RestoreLootConfirm()
	if not applied.lootConfirm then
		return
	end
	K:UnregisterEvent("LOOT_BIND_CONFIRM", ConfirmLoot)
	if UIParent then
		UIParent:RegisterEvent("LOOT_BIND_CONFIRM")
	end
	applied.lootConfirm = nil
end

local function ConfirmTradeableEquip(_, inventorySlot)
	if not InCombatLockdown() then
		EquipPendingItem(inventorySlot)
	end
end

local function ApplyEquipConfirm()
	if applied.equipConfirm then
		return
	end
	if UIParent then
		UIParent:UnregisterEvent("EQUIP_BIND_TRADEABLE_CONFIRM")
	end
	K:RegisterEvent("EQUIP_BIND_TRADEABLE_CONFIRM", ConfirmTradeableEquip)
	applied.equipConfirm = true
end

local function RestoreEquipConfirm()
	if not applied.equipConfirm then
		return
	end
	K:UnregisterEvent("EQUIP_BIND_TRADEABLE_CONFIRM", ConfirmTradeableEquip)
	if UIParent then
		UIParent:RegisterEvent("EQUIP_BIND_TRADEABLE_CONFIRM")
	end
	applied.equipConfirm = nil
end

local function ConfirmTradeableSell()
	if CursorHasItem() then
		SellCursorItem()
	end
end

local function ApplySellConfirm()
	if applied.sellConfirm or not MerchantFrame then
		return
	end
	MerchantFrame:UnregisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")
	K:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL", ConfirmTradeableSell)
	applied.sellConfirm = true
end

local function RestoreSellConfirm()
	if not applied.sellConfirm then
		return
	end
	K:UnregisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL", ConfirmTradeableSell)
	if MerchantFrame then
		MerchantFrame:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")
	end
	applied.sellConfirm = nil
end

local function GetMaxPurchasableStack(index)
	local maxStack = GetMerchantItemMaxStack(index)
	if not maxStack or maxStack <= 1 then
		return maxStack
	end
	if not C_MerchantFrame or not C_MerchantFrame.GetItemInfo then
		return maxStack
	end
	local info = C_MerchantFrame.GetItemInfo(index)
	if not info then
		return maxStack
	end

	local canAfford = maxStack
	if info.price and info.price > 0 then
		local money = GetMoney()
		if K.NotSecret(money) then
			canAfford = floor(money / (info.price / info.stackCount))
		end
	end

	if info.hasExtendedCost then
		for i = 1, MAX_ITEM_COST do
			local _, itemValue, costItemLink, currencyName = GetMerchantItemCostItem(index, i)
			if costItemLink and not currencyName and itemValue and itemValue > 0 then
				local myCount = C_Item.GetItemCount(costItemLink, false, false, true)
				canAfford = min(canAfford, floor(myCount / (itemValue / info.stackCount)))
			end
		end
	end

	return min(maxStack, canAfford)
end

local function BuyMerchantStack(button, index, quantity)
	if quantity <= 0 then
		return
	end
	if button.extendedCost or button.showNonrefundablePrompt then
		if _G.MerchantFrame_ConfirmExtendedItemCost then
			_G.MerchantFrame_ConfirmExtendedItemCost(button, quantity)
			return
		end
	elseif button.price and _G.MERCHANT_HIGH_PRICE_COST and button.price >= _G.MERCHANT_HIGH_PRICE_COST then
		if _G.MerchantFrame_ConfirmHighCostItem then
			_G.MerchantFrame_ConfirmHighCostItem(button, quantity)
			return
		end
	end
	BuyMerchantItem(index, quantity)
end

local function BuildStackBuyPopupData(button, index, itemLink, quantity)
	if _G.MerchantFrame_GetProductInfo then
		local popupData = _G.MerchantFrame_GetProductInfo(button)
		popupData.count = quantity
		popupData.button = button
		return popupData
	end
	return {
		link = itemLink,
		index = index,
		count = quantity,
		button = button,
		useLinkForItemInfo = true,
	}
end

StaticPopupDialogs["KKUI_BUY_STACK"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	hasItemFrame = true,
	hideOnEscape = true,
	timeout = 0,
	whileDead = true,
	preferredIndex = 3,
	OnAccept = function(_, data)
		if type(data) ~= "table" or not data.index then
			return
		end
		local index = data.index
		local quantity = data.count or GetMaxPurchasableStack(index) or GetMerchantItemMaxStack(index)
		if not quantity or quantity <= 0 then
			return
		end
		if data.button then
			BuyMerchantStack(data.button, index, quantity)
		else
			BuyMerchantItem(index, quantity)
		end
		if data.link then
			stackBuySkipCache[data.link] = true
		end
	end,
}

local function OnMerchantItemModifiedClick(self, button)
	if isEnabled()
		and option("PopupAltStackBuy")
		and button == "RightButton"
		and IsAltKeyDown()
		and MerchantFrame
		and MerchantFrame.selectedTab == 1
	then
		local index = self:GetID()
		local itemLink = GetMerchantItemLink(index)
		if itemLink then
			local quantity = GetMaxPurchasableStack(index)
			if quantity and quantity > 1 then
				if stackBuySkipCache[itemLink] then
					BuyMerchantStack(self, index, quantity)
					return
				end
				local popupData = BuildStackBuyPopupData(self, index, itemLink, quantity)
				StaticPopup_Show("KKUI_BUY_STACK", L["Stack Buying Check"], nil, popupData)
				return
			end
		end
	end
	if origMerchantModifiedClick then
		origMerchantModifiedClick(self, button)
	end
end

local function InstallStackBuyHook()
	if applied.stackBuyHook or not _G.MerchantItemButton_OnModifiedClick then
		return
	end
	origMerchantModifiedClick = _G.MerchantItemButton_OnModifiedClick
	_G.MerchantItemButton_OnModifiedClick = OnMerchantItemModifiedClick
	applied.stackBuyHook = true
end

local function RestoreStackBuyHook()
	if not applied.stackBuyHook then
		return
	end
	if origMerchantModifiedClick then
		_G.MerchantItemButton_OnModifiedClick = origMerchantModifiedClick
		origMerchantModifiedClick = nil
	end
	StaticPopup_Hide("KKUI_BUY_STACK")
	applied.stackBuyHook = nil
end

local function OnMerchantShow()
	if isEnabled() and option("PopupAltStackBuy") then
		InstallStackBuyHook()
	end
end

local function ApplyAll()
	if not isEnabled() then
		return
	end

	ApplyEscapeGuards()
	HookToasts()

	if option("PopupAutoConfirmLoot") then
		ApplyLootConfirm()
	end
	if option("PopupAutoConfirmTradeableEquip") then
		ApplyEquipConfirm()
	end
	if option("PopupAutoConfirmTradeableSell") then
		ApplySellConfirm()
	end
	if option("PopupEnterAcceptPurchase") then
		ApplyEnterPurchase()
	end
	if option("PopupAltStackBuy") then
		InstallStackBuyHook()
	end
end

local function RestoreAll()
	RestoreLootConfirm()
	RestoreEquipConfirm()
	RestoreSellConfirm()
	RestoreEnterPurchase()
	RestoreStackBuyHook()
end

function Module:CreatePopupQoL()
	if not isEnabled() then
		RestoreAll()
		K:UnregisterEvent("MERCHANT_SHOW", OnMerchantShow)
		return
	end

	K:RegisterEvent("MERCHANT_SHOW", OnMerchantShow)
	ApplyAll()
end

function Module:UpdatePopupQoL()
	RestoreAll()
	self:CreatePopupQoL()
	local loot = K:GetModule("Loot")
	if loot and loot.CreateAutoConfirm then
		loot:CreateAutoConfirm()
	end
end

Module:RegisterMisc("PopupQoL", Module.CreatePopupQoL)
