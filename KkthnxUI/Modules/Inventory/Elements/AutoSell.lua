local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

local table_wipe = table.wipe

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local C_TransmogCollection_GetItemInfo = C_TransmogCollection.GetItemInfo
local IsShiftKeyDown = IsShiftKeyDown

local autoSellStop = true -- Flag to stop the selling process
local sellCache = {} -- Table to store items that have already been processed
local errorText = ERR_VENDOR_DOESNT_BUY -- Error message for when the vendor doesn't buy certain items

local function startSelling()
	if autoSellStop then
		return
	end

	for bag = 0, 5 do
		for slot = 1, C_Container_GetContainerNumSlots(bag) do
			if autoSellStop then
				return
			end

			local info = C_Container_GetContainerItemInfo(bag, slot)
			if info and not sellCache["b" .. bag .. "s" .. slot] and info.hyperlink and not info.hasNoValue and (info.quality == 0 or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[info.itemID]) and (not Module:IsPetTrashCurrency(info.itemID)) and (not C_TransmogCollection_GetItemInfo(info.hyperlink) or not K.IsUnknownTransmog(bag, slot)) then
				sellCache["b" .. bag .. "s" .. slot] = true
				C_Container_UseContainerItem(bag, slot)
				K.Delay(0.15, startSelling)
				return
			end
		end
	end
end

local function updateAutoSell(event, ...)
	if not C["Inventory"].AutoSell then
		return
	end

	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then
			return
		end

		autoSellStop = false
		table_wipe(sellCache)
		startSelling()
		K:RegisterEvent("UI_ERROR_MESSAGE", updateAutoSell)
	elseif (event == "UI_ERROR_MESSAGE" and arg == errorText) or event == "MERCHANT_CLOSED" then
		autoSellStop = true
		K:UnregisterEvent("UI_ERROR_MESSAGE")
	end
end

function Module:CreateAutoSell()
	K:RegisterEvent("MERCHANT_SHOW", updateAutoSell)
	K:RegisterEvent("MERCHANT_CLOSED", updateAutoSell)
end
