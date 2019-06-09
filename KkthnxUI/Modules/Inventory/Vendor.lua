local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Vendor", "AceEvent-3.0", "AceTimer-3.0")

-- Sourced: ElvUI

local _G = _G
local select = _G.select
local string_format = _G.string.format
local table_remove = _G.table.remove
local table_insert = _G.table.insert
local table_maxn = _G.table.maxn
local unpack = _G.unpack

local CanGuildBankRepair = _G.CanGuildBankRepair
local CanMerchantRepair = _G.CanMerchantRepair
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney
local GetItemInfo = _G.GetItemInfo
local GetRepairAllCost = _G.GetRepairAllCost
local IsShiftKeyDown = _G.IsShiftKeyDown
local RepairAllItems = _G.RepairAllItems
local UnitFactionGroup = _G.UnitFactionGroup

do -- Auto Repair Functions
	local STATUS, TYPE, COST, POSS
	function Module:AttemptAutoRepair(playerOverride)
		STATUS, TYPE, COST, POSS = "", C["Inventory"].AutoRepair.Value, GetRepairAllCost()

		if POSS and COST > 0 then
			-- This check evaluates to true even if the guild bank has 0 gold, so we add an override
			if TYPE == "GUILD" and (playerOverride or (not CanGuildBankRepair() or COST > GetGuildBankWithdrawMoney())) then
				TYPE = "PLAYER"
			end

			RepairAllItems(TYPE == "GUILD")

			-- Delay this a bit so we have time to catch the outcome of first repair attempt
			K.Delay(0.5, Module.AutoRepairOutput)
		end
	end

	function Module:AutoRepairOutput()
		if TYPE == "GUILD" then
			if STATUS == "GUILD_REPAIR_FAILED" then
				Module:AttemptAutoRepair(true) -- Try using player money instead
			else
				K.Print(L["Inventory"].GuildRepair..K.FormatMoney(COST))
			end
		elseif TYPE == "PLAYER" then
			if STATUS == "PLAYER_REPAIR_FAILED" then
				K.Print(L["Inventory"].NotEnoughMoney)
			else
				K.Print(L["Inventory"].RepairCost..K.FormatMoney(COST))
			end
		end
	end

	function Module:UI_ERROR_MESSAGE(_, messageType)
		if messageType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
			STATUS = "GUILD_REPAIR_FAILED"
		elseif messageType == LE_GAME_ERR_NOT_ENOUGH_MONEY then
			STATUS = "PLAYER_REPAIR_FAILED"
		end
	end
end

function Module:VendorGrays(delete)
	if Module.SellFrame:IsShown() then
		return
	end

	if (not MerchantFrame or not MerchantFrame:IsShown()) and not delete then
		K.Print(L["Inventory"].NotatVendor)
		return
	end

	for bag = 0, 4, 1 do
		for slot = 1, GetContainerNumSlots(bag), 1 do
			local itemID = GetContainerItemID(bag, slot)
			if itemID then
				local _, link, rarity, _, _, itype, _, _, _, _, itemPrice = GetItemInfo(itemID)

				if (rarity and rarity == 0) and (itype and itype ~= "Quest") and (itemPrice and itemPrice > 0) then
					table_insert(Module.SellFrame.Info.itemList, {bag,slot,itemPrice,link})
				end
			end
		end
	end

	if (not Module.SellFrame.Info.itemList) then
		return
	end

	if (table_maxn(Module.SellFrame.Info.itemList) < 1) then
		return
	end

	-- Resetting stuff
	Module.SellFrame.Info.delete = delete or false
	Module.SellFrame.Info.ProgressTimer = 0
	Module.SellFrame.Info.SellInterval = 0.2
	Module.SellFrame.Info.ProgressMax = table_maxn(Module.SellFrame.Info.itemList)
	Module.SellFrame.Info.goldGained = 0
	Module.SellFrame.Info.itemsSold = 0

	Module.SellFrame.statusbar:SetValue(0)
	Module.SellFrame.statusbar:SetMinMaxValues(0, Module.SellFrame.Info.ProgressMax)
	Module.SellFrame.statusbar.ValueText:SetText("0 / "..Module.SellFrame.Info.ProgressMax)

	-- Time to sell
	Module.SellFrame:Show()
end

function Module:UI_ERROR_MESSAGE(_, messageType)
	if messageType == LE_GAME_ERR_GUILD_NOT_ENOUGH_MONEY then
		autoRepairStatus = "GUILD_REPAIR_FAILED"
	elseif messageType == LE_GAME_ERR_NOT_ENOUGH_MONEY then
		autoRepairStatus = "PLAYER_REPAIR_FAILED"
	end
end

function Module:MERCHANT_CLOSED()
	self:UnregisterEvent("UI_ERROR_MESSAGE")
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:UnregisterEvent("MERCHANT_CLOSED")

	Module.SellFrame:Hide()

	table.wipe(Module.SellFrame.Info.itemList)
	Module.SellFrame.Info.delete = false
	Module.SellFrame.Info.ProgressTimer = 0
	Module.SellFrame.Info.SellInterval = 0.2
	Module.SellFrame.Info.ProgressMax = 0
	Module.SellFrame.Info.goldGained = 0
	Module.SellFrame.Info.itemsSold = 0
end

function Module:ProgressQuickVendor()
	local item = Module.SellFrame.Info.itemList[1]

	-- No more to sell
	if not item then
		return nil, true
	end

	local bag, slot, itemPrice, link = unpack(item)
	local stackPrice = 0
	local stackCount = select(2, GetContainerItemInfo(bag, slot)) or 1

	if Module.SellFrame.Info.delete then
		PickupContainerItem(bag, slot)
		DeleteCursorItem()
	else
		stackPrice = (itemPrice or 0) * stackCount
		if C["Inventory"].DetailedReport and link then
			K.Print(string_format("%s|cFF00DDDDx%d|r %s", link, stackCount, K.FormatMoney(stackPrice)))
		end
		UseContainerItem(bag, slot)
	end

	table_remove(Module.SellFrame.Info.itemList, 1)

	return stackPrice
end

function Module:VendorGreys_OnUpdate(elapsed)
	Module.SellFrame.Info.ProgressTimer = Module.SellFrame.Info.ProgressTimer - elapsed
	if (Module.SellFrame.Info.ProgressTimer > 0) then
		return
	end
	Module.SellFrame.Info.ProgressTimer = Module.SellFrame.Info.SellInterval

	local goldGained, lastItem = Module:ProgressQuickVendor()
	if (goldGained) then
		Module.SellFrame.Info.goldGained = Module.SellFrame.Info.goldGained + goldGained
		Module.SellFrame.Info.itemsSold = Module.SellFrame.Info.itemsSold + 1
		Module.SellFrame.statusbar:SetValue(Module.SellFrame.Info.itemsSold)
		local timeLeft = (Module.SellFrame.Info.ProgressMax - Module.SellFrame.Info.itemsSold) * Module.SellFrame.Info.SellInterval
		Module.SellFrame.statusbar.ValueText:SetText(Module.SellFrame.Info.itemsSold.." / "..Module.SellFrame.Info.ProgressMax.." ( "..timeLeft.."s )")
	elseif lastItem then
		Module.SellFrame:Hide()
		if Module.SellFrame.Info.goldGained > 0 then
			K.Print((L["Inventory"].SoldTrash.."%s"):format(K.FormatMoney(Module.SellFrame.Info.goldGained)))
		end
	end
end

function Module:CreateSellFrame()
	local isAlliance = UnitFactionGroup("player") == "Alliance"

	Module.SellFrame = CreateFrame("Frame", "VendorGraysFrame", UIParent)
	Module.SellFrame:SetSize(200,40)
	Module.SellFrame:SetPoint("CENTER", UIParent)
	Module.SellFrame:CreateBorder()

	Module.SellFrame.title = Module.SellFrame:CreateFontString(nil, "OVERLAY")
	Module.SellFrame.title:FontTemplate(nil, 12, "")
	Module.SellFrame.title:SetPoint("TOP", Module.SellFrame, "TOP", 0, -2)
	Module.SellFrame.title:SetText(L["Inventory"].VendorGrays)

	Module.SellFrame.statusbar = CreateFrame("StatusBar", "VendorGraysFrameStatusbar", Module.SellFrame)
	Module.SellFrame.statusbar:SetSize(180, 16)
	Module.SellFrame.statusbar:SetPoint("BOTTOM", Module.SellFrame, "BOTTOM", 0, 4)
	Module.SellFrame.statusbar:SetStatusBarTexture(C["Media"].Texture)
	Module.SellFrame.statusbar:CreateBorder()

	if (isAlliance) then
		Module.SellFrame.statusbar:SetStatusBarColor(74/255, 84/255, 232/255)
	else
		Module.SellFrame.statusbar:SetStatusBarColor(229/255, 13/255, 18/255)
	end

	Module.SellFrame.statusbar.anim = CreateAnimationGroup(Module.SellFrame.statusbar)
	Module.SellFrame.statusbar.anim.progress = Module.SellFrame.statusbar.anim:CreateAnimation("Progress")
	Module.SellFrame.statusbar.anim.progress:SetSmoothing("Out")
	Module.SellFrame.statusbar.anim.progress:SetDuration(.3)

	Module.SellFrame.statusbar.ValueText = Module.SellFrame.statusbar:CreateFontString(nil, "OVERLAY")
	Module.SellFrame.statusbar.ValueText:FontTemplate(nil, 12, "")
	Module.SellFrame.statusbar.ValueText:SetPoint("CENTER", Module.SellFrame.statusbar)
	Module.SellFrame.statusbar.ValueText:SetText("0 / 0 ( 0s )")

	Module.SellFrame.Info = {
		delete = false,
		ProgressTimer = 0,
		SellInterval = 0.2,
		ProgressMax = 0,
		goldGained = 0,
		itemsSold = 0,
		itemList = {},
	}

	Module.SellFrame:SetScript("OnUpdate", Module.VendorGreys_OnUpdate)
	Module.SellFrame:Hide()
end

function Module:MERCHANT_SHOW()
	if C["Inventory"].AutoSell then
		K.Delay(0.5, Module.VendorGrays, Module)
	end

	if C["Inventory"].AutoRepair.Value == "NONE" or IsShiftKeyDown() or not CanMerchantRepair() then
		return
	end

	-- Prepare to catch "not enough money" messages
	self:RegisterEvent("UI_ERROR_MESSAGE")
	-- Use this to unregister events afterwards
	self:RegisterEvent("MERCHANT_CLOSED")

	Module:AttemptAutoRepair()
end

function Module:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW")
	self:CreateSellFrame()
	self:RegisterEvent("MERCHANT_CLOSED")
end