local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Bags")

local table_wipe = table.wipe

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local C_Timer_After = C_Timer.After
local C_TransmogCollection_GetItemInfo = C_TransmogCollection.GetItemInfo
local IsShiftKeyDown = IsShiftKeyDown

local stop = true -- a flag used to stop the selling process
local cache = {} -- a table used to store items that have already been processed
local errorText = ERR_VENDOR_DOESNT_BUY -- error message for when the vendor doesn't buy certain items

local function startSelling()
	-- if the stop flag is set, exit the function
	if stop then
		return
	end

	-- loop through all bags
	for bag = 0, 5 do
		-- loop through all slots in the current bag
		for slot = 1, C_Container_GetContainerNumSlots(bag) do
			-- if the stop flag is set, exit the function
			if stop then
				return
			end

			-- get information about the item in the current slot
			local info = C_Container_GetContainerItemInfo(bag, slot)
			if info then
				if not cache["b" .. bag .. "s" .. slot] and info.hyperlink and not info.hasNoValue and (info.quality == 0 or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[info.itemID]) and (not Module:IsPetTrashCurrency(info.itemID)) and (not C_TransmogCollection_GetItemInfo(info.hyperlink) or not K.IsUnknownTransmog(bag, slot)) then
					cache["b" .. bag .. "s" .. slot] = true
					C_Container_UseContainerItem(bag, slot)
					C_Timer_After(0.15, startSelling)
					return
				end
			end
		end
	end
end

local function updateSelling(event, ...)
	-- exit if AutoSell feature is not enabled
	if not C["Inventory"].AutoSell then
		return
	end

	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		-- exit if shift key is pressed
		if IsShiftKeyDown() then
			return
		end

		-- set stop flag to false and clear cache table
		stop = false
		table_wipe(cache)
		-- start selling items
		startSelling()
		-- register for error messages and merchant close events
		K:RegisterEvent("UI_ERROR_MESSAGE", updateSelling)
	elseif event == "UI_ERROR_MESSAGE" and arg == errorText or event == "MERCHANT_CLOSED" then
		-- set stop flag to true
		stop = true
	end
end

function Module:CreateAutoSell()
	K:RegisterEvent("MERCHANT_SHOW", updateSelling)
	K:RegisterEvent("MERCHANT_CLOSED", updateSelling)
end
