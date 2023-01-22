local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Bags")

local _G = _G
local table_wipe = _G.table.wipe

local C_Container_GetContainerItemEquipmentSetInfo = _G.C_Container.GetContainerItemEquipmentSetInfo
local C_Container_GetContainerItemInfo = _G.C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = _G.C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = _G.C_Container.UseContainerItem
local C_Timer_After = _G.C_Timer.After
local IsShiftKeyDown = _G.IsShiftKeyDown

local stop = true -- a flag used to stop the selling process
local cache = {} -- a table used to store items that have already been processed
local errorText = _G.ERR_VENDOR_DOESNT_BUY -- error message for when the vendor doesn't buy certain items

local function startSelling()
	-- if the stop flag is set, exit the function
	if stop then
		return
	end

	-- loop through all bags
	for bag = 0, 4 do
		-- loop through all slots in the current bag
		for slot = 1, C_Container_GetContainerNumSlots(bag) do
			-- if the stop flag is set, exit the function
			if stop then
				return
			end

			-- get information about the item in the current slot
			local info = C_Container_GetContainerItemInfo(bag, slot)
			if info then
				local quality, link, noValue, itemID = info.quality, info.hyperlink, info.hasNoValue, info.itemID
				local isInSet = C_Container_GetContainerItemEquipmentSetInfo(bag, slot)
				-- check if the item meets the criteria for selling
				if link and not noValue and not isInSet and not Module:IsPetTrashCurrency(itemID) and (quality == 0 or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID]) and not cache["b" .. bag .. "s" .. slot] then
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
