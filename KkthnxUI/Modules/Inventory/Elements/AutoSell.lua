local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Bags")

local _G = _G
local string_format = _G.string.format
local table_wipe = _G.table.wipe

local C_Timer_After = _G.C_Timer.After
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetItemInfo = _G.GetItemInfo
local IsShiftKeyDown = _G.IsShiftKeyDown

local sellCount, stop, cache = 0, true, {}
local errorText = _G.ERR_VENDOR_DOESNT_BUY

local function stopSelling(tell)
	stop = true
	if sellCount > 0 and tell then
		K.Print(string_format("%s%s", K.SystemColor..L["Vendored Items"], K.FormatMoney(sellCount)))
	end
	sellCount = 0
end

local function startSelling()
	if stop then
		return
	end

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			if stop then
				return
			end

			local link = GetContainerItemLink(bag, slot)
			if link then
				local price = select(11, GetItemInfo(link))
				local _, count, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(bag, slot)
				if (quality == 0 or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID]) and price and price > 0 and not cache["b"..bag.."s"..slot] then
					sellCount = sellCount + price*count
					cache["b"..bag.."s"..slot] = true
					_G.UseContainerItem(bag, slot)
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
	elseif event == "UI_ERROR_MESSAGE" and arg == errorText then
		stopSelling(false)
	elseif event == "MERCHANT_CLOSED" then
		stopSelling(true)
	end
end

function Module:CreateAutoSell()
	K:RegisterEvent("MERCHANT_SHOW", updateSelling)
	K:RegisterEvent("MERCHANT_CLOSED", updateSelling)
end