local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Bags")

local _G = _G
local table_wipe = _G.table.wipe

local C_Container_GetContainerItemEquipmentSetInfo = _G.C_Container.GetContainerItemEquipmentSetInfo
local C_Container_GetContainerItemInfo = _G.C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = _G.C_Container.GetContainerNumSlots
local C_Timer_After = _G.C_Timer.After
local IsShiftKeyDown = _G.IsShiftKeyDown

local stop = true
local cache = {}
local errorText = _G.ERR_VENDOR_DOESNT_BUY

local function startSelling()
	if stop then
		return
	end

	for bag = 0, 4 do
		for slot = 1, C_Container_GetContainerNumSlots(bag) do
			if stop then
				return
			end

			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info then
				local quality, link, noValue, itemID = info.quality, info.hyperlink, info.hasNoValue, info.itemID
				local isInSet = C_Container_GetContainerItemEquipmentSetInfo(bag, slot)
				if link and not noValue and not isInSet and not Module:IsPetTrashCurrency(itemID) and (quality == 0 or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID]) and not cache["b" .. bag .. "s" .. slot] then
					cache["b" .. bag .. "s" .. slot] = true
					C_Container.UseContainerItem(bag, slot)
					C_Timer_After(0.15, startSelling)
					return
				end
			end
		end
	end
end

local function updateSelling(event, ...)
	if not C["Inventory"].AutoSell then
		return
	end

	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then
			return
		end

		stop = false
		table_wipe(cache)
		startSelling()
		K:RegisterEvent("UI_ERROR_MESSAGE", updateSelling)
	elseif event == "UI_ERROR_MESSAGE" and arg == errorText or event == "MERCHANT_CLOSED" then
		stop = true
	end
end

function Module:CreateAutoSell()
	K:RegisterEvent("MERCHANT_SHOW", updateSelling)
	K:RegisterEvent("MERCHANT_CLOSED", updateSelling)
end
