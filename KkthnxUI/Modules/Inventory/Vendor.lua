local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Vendor", "AceEvent-3.0", "AceTimer-3.0")

-- Sourced: ElvUI

local _G = _G
local select = _G.select
local string_format = string.format
local table_remove = table.remove
local table_insert = table.insert
local table_maxn = table.maxn
local unpack = _G.unpack

local C_Timer_After = _G.C_Timer.After
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

local autoRepairStatus
local function AttemptAutoRepair(playerOverride)
	autoRepairStatus = ""
	local autoRepair = C["Inventory"].AutoRepair.Value
	local cost, possible = GetRepairAllCost()
	local withdrawLimit = GetGuildBankWithdrawMoney()
	-- This check evaluates to true even if the guild bank has 0 gold, so we add an override
	if autoRepair == "GUILD" and ((not CanGuildBankRepair() or cost > withdrawLimit) or playerOverride) then
		autoRepair = "PLAYER"
	end

	if cost > 0 then
		if possible then
			RepairAllItems(autoRepair == "GUILD")
			-- Delay this a bit so we have time to catch the outcome of first repair attempt
			C_Timer_After(0.5, function()
				if autoRepair == "GUILD" then
					if autoRepairStatus == "GUILD_REPAIR_FAILED" then
						AttemptAutoRepair(true) -- Try using player money instead
					else
						K.Print("Your items have been repaired using guild bank funds for: " .. K.FormatMoney(cost))
					end
				elseif autoRepair == "PLAYER" then
					if autoRepairStatus == "PLAYER_REPAIR_FAILED" then
						K.Print("You don't have enough money to repair.")
					else
						K.Print("Your items have been repaired for: " .. K.FormatMoney(cost))
					end
				end
			end)
		end
	end
end

local function VendorGrays()
	if Module.SellFrame:IsShown() then
		return
	end

	local link, rarity, itype, itemPrice, itemID, _
	for bag = 0, 4, 1 do
		for slot = 1, GetContainerNumSlots(bag), 1 do
			itemID = GetContainerItemID(bag, slot)
			if itemID then
				_, link, rarity, _, _, itype, _, _, _, _, itemPrice = GetItemInfo(itemID)

				if (rarity and rarity == 0) and (itype and itype ~= "Quest") then
					table_insert(Module.SellFrame.Info.itemList, {bag, slot, itemPrice, link})
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

	--Resetting stuff
	Module.SellFrame.Info.ProgressTimer = 0
	Module.SellFrame.Info.SellInterval = 0.2
	Module.SellFrame.Info.ProgressMax = table_maxn(Module.SellFrame.Info.itemList)
	Module.SellFrame.Info.goldGained = 0
	Module.SellFrame.Info.itemsSold = 0

	Module.SellFrame.statusbar:SetValue(0)
	Module.SellFrame.statusbar:SetMinMaxValues(0, Module.SellFrame.Info.ProgressMax)
	Module.SellFrame.statusbar.ValueText:SetText("0 / "..Module.SellFrame.Info.ProgressMax)

	--Time to sell
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

	local bag, slot,itemPrice, link = unpack(item)
	local goldGained, stackPrice, _ = 0
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
			K.Print(("Vendored gray items for: %s"):format(K.FormatMoney(Module.SellFrame.Info.goldGained)))
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
	Module.SellFrame.title:SetText("Vendoring Grays")

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
		C_Timer_After(0.5, VendorGrays)
	end

	local autoRepair = C["Inventory"].AutoRepair.Value
	if IsShiftKeyDown() or autoRepair == "NONE" or not CanMerchantRepair() then
		return
	end

	-- Prepare to catch "not enough money" messages
	self:RegisterEvent("UI_ERROR_MESSAGE")
	-- Use this to unregister events afterwards
	self:RegisterEvent("MERCHANT_CLOSED")

	AttemptAutoRepair()
end

function Module:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW")

	-- Creating vendor grays frame
	Module:CreateSellFrame()
end