local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

-- Locals for speed
local table_wipe = table.wipe
local string_format = string.format
local debugprofilestop = debugprofilestop

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local C_TransmogCollection_GetItemInfo = C_TransmogCollection.GetItemInfo
local IsShiftKeyDown = IsShiftKeyDown

-- Editable list: items that should NEVER be auto-sold
-- Add itemIDs here as [itemID] = true
-- Example: Delver's Bounty (shown in screenshot) → itemID 227784
local DoNotSell = {
	[227784] = true, -- Delver's Bounty (TWW S1)
}

local autoSellStop = true -- Selling loop guard
local sellCache = {} -- Numeric-key cache (bag*100+slot) for processed items this session
local errorText = ERR_VENDOR_DOESNT_BUY

-- Lightweight profiling
local AutoSellProfile = { enabled = false, scans = 0, sold = 0, totalMs = 0 }

function Module:AutoSellProfileSetEnabled(enabled)
	AutoSellProfile.enabled = not not enabled
	AutoSellProfile.scans = 0
	AutoSellProfile.sold = 0
	AutoSellProfile.totalMs = 0
end

function Module:AutoSellProfileDump()
	if AutoSellProfile.enabled then
		K.Print(string_format("[AutoSell] scans=%d sold=%d time=%.2fms", AutoSellProfile.scans, AutoSellProfile.sold, AutoSellProfile.totalMs))
	else
		K.Print("[AutoSell] profiling disabled")
	end
end

local function startSelling()
	if autoSellStop then
		return
	end

	local t0
	if AutoSellProfile.enabled then
		t0 = debugprofilestop()
	end

	local charDB = KkthnxUIDB and KkthnxUIDB.Variables and KkthnxUIDB.Variables[K.Realm] and KkthnxUIDB.Variables[K.Realm][K.Name]
	local customJunk = charDB and charDB.CustomJunkList

	for bag = 0, 5 do
		local numSlots = C_Container_GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			if autoSellStop then
				return
			end

			local info = C_Container_GetContainerItemInfo(bag, slot)
			if info then
				-- Numeric cache key to avoid string allocations
				local key = bag * 100 + slot
				if not sellCache[key] and info.hyperlink and not info.isLocked and not info.hasNoValue and not DoNotSell[info.itemID] and (info.quality == 0 or (customJunk and customJunk[info.itemID])) and not Module:IsPetTrashCurrency(info.itemID) and (not C_TransmogCollection_GetItemInfo(info.hyperlink) or not K.IsUnknownTransmog(bag, slot)) then
					sellCache[key] = true
					C_Container_UseContainerItem(bag, slot)
					if AutoSellProfile.enabled then
						AutoSellProfile.sold = AutoSellProfile.sold + 1
					end
					K.Delay(0.15, startSelling)
					return
				end
			end
		end
	end

	if AutoSellProfile.enabled and t0 then
		AutoSellProfile.scans = AutoSellProfile.scans + 1
		AutoSellProfile.totalMs = AutoSellProfile.totalMs + (debugprofilestop() - t0)
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
