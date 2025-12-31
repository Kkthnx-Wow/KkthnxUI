local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

-- Locals for speed
local table_wipe = table.wipe
local string_format = string.format

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local C_TransmogCollection_GetItemInfo = C_TransmogCollection.GetItemInfo
local IsShiftKeyDown = IsShiftKeyDown
local math_floor = math.floor

local autoSellStop = true -- Selling loop guard
local sellCache = {} -- Numeric-key cache (bag*100+slot) for processed items this session
local errorText = ERR_VENDOR_DOESNT_BUY
local SELL_DELAY = 0.2

-- Precomputed sell list to avoid rescanning all bags every step (store numeric key bag*100+slot)
local toSell = {}
local sellIndex = 1

local function startSelling()
	if autoSellStop then
		return
	end

	local total = #toSell
	while sellIndex <= total do
		if autoSellStop then
			return
		end
		local entryKey = toSell[sellIndex]
		sellIndex = sellIndex + 1
		if entryKey then
			local bag = math_floor(entryKey / 100)
			local slot = entryKey - bag * 100
			local info = C_Container_GetContainerItemInfo(bag, slot)
			if info and not info.isLocked and not info.hasNoValue then
				local key = bag * 100 + slot
				if not sellCache[key] then
					-- Re-validate transmog safety before selling
					local safeToSell = true
					if info.hyperlink then
						local hasTransmogInfo = C_TransmogCollection_GetItemInfo(info.hyperlink)
						if hasTransmogInfo and K.IsUnknownTransmog(bag, slot) then
							safeToSell = false
						end
					end
					if not safeToSell then
						-- skip this entry, continue to next
					else
						sellCache[key] = true
						C_Container_UseContainerItem(bag, slot)
						K.Delay(SELL_DELAY, startSelling)
						return
					end
				end
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
		table_wipe(toSell)
		sellIndex = 1

		-- Build a list of candidates once to avoid repeated full rescans
		local charDB = KkthnxUIDB and KkthnxUIDB.Variables and KkthnxUIDB.Variables[K.Realm] and KkthnxUIDB.Variables[K.Realm][K.Name]
		local customJunk = charDB and charDB.CustomJunkList
		for bag = 0, 5 do
			local numSlots = C_Container_GetContainerNumSlots(bag)
			for slot = 1, numSlots do
				local info = C_Container_GetContainerItemInfo(bag, slot)
				if info and info.hyperlink and not info.isLocked and not info.hasNoValue then
					local isJunk = (info.quality == 0) or (customJunk and customJunk[info.itemID])
					if isJunk and not Module:IsPetTrashCurrency(info.itemID) then
						-- Always check transmog info; skip if unknown appearance
						local hasTransmogInfo = C_TransmogCollection_GetItemInfo(info.hyperlink)
						if not (hasTransmogInfo and K.IsUnknownTransmog(bag, slot)) then
							toSell[#toSell + 1] = (bag * 100 + slot)
						end
					end
				end
			end
		end

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
