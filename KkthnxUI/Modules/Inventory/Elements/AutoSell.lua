--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automates selling of junk items and custom-listed items.
-- - Design: Greys via C_MerchantFrame.SellAllJunkItems (native, untainted).
--   Custom junk uses a throttled UseContainerItem sweep (SecretArguments =
--   AllowedWhenUntainted — never fire from a tainted path / mid-combat bags).
-- - Events: MERCHANT_SHOW, MERCHANT_CLOSED, UI_ERROR_MESSAGE
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

local table_wipe = table.wipe

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local C_MerchantFrame = C_MerchantFrame
local C_TransmogCollection_GetItemInfo = C_TransmogCollection.GetItemInfo
local IsShiftKeyDown = IsShiftKeyDown
local InCombatLockdown = InCombatLockdown
local math_floor = math.floor
local pcall = pcall

local autoSellStop = true
local sellCache = {}
local errorText = ERR_VENDOR_DOESNT_BUY
-- One UseContainerItem per tick — server rate-limits bulk sells.
local SELL_DELAY = 0.2

local toSell = {}
local sellIndex = 1
local updateAutoSell

local function startSelling()
	if autoSellStop then
		return
	end

	-- UseContainerItem is AllowedWhenUntainted only — never from combat lockdown.
	if InCombatLockdown() then
		autoSellStop = true
		K:UnregisterEvent("UI_ERROR_MESSAGE", updateAutoSell)
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
					local safeToSell = true
					if info.hyperlink then
						local hasTransmogInfo = C_TransmogCollection_GetItemInfo(info.hyperlink)
						if hasTransmogInfo and K.IsUnknownTransmog(bag, slot) then
							safeToSell = false
						end
					end
					if safeToSell then
						sellCache[key] = true
						-- pcall: if the execution path is tainted, stop instead of spam FORBIDDEN.
						local ok = pcall(C_Container_UseContainerItem, bag, slot)
						if not ok then
							autoSellStop = true
							K:UnregisterEvent("UI_ERROR_MESSAGE", updateAutoSell)
							return
						end
						K.Delay(SELL_DELAY, startSelling)
						return
					end
				end
			end
		end
	end
end

updateAutoSell = function(event, ...)
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

		-- Native bulk sell for greys — no UseContainerItem, no taint surface.
		if C_MerchantFrame and C_MerchantFrame.SellAllJunkItems then
			local disabled = C_MerchantFrame.IsSellAllJunkEnabled and not C_MerchantFrame.IsSellAllJunkEnabled()
			if not disabled then
				pcall(C_MerchantFrame.SellAllJunkItems)
			end
		end

		-- Custom junk list only (greys already handled natively when available).
		local charDB = K.GetCharVars()
		local customJunk = charDB and charDB.CustomJunkList
		local nativeGreys = C_MerchantFrame and C_MerchantFrame.SellAllJunkItems
		for bag = 0, 5 do
			local numSlots = C_Container_GetContainerNumSlots(bag)
			for slot = 1, numSlots do
				local info = C_Container_GetContainerItemInfo(bag, slot)
				if info and info.hyperlink and not info.isLocked and not info.hasNoValue then
					local isCustom = customJunk and customJunk[info.itemID]
					local isGrey = info.quality == 0
					-- Skip greys when SellAllJunkItems already cleared them.
					local wantSell = isCustom or (isGrey and not nativeGreys)
					if wantSell and not Module:IsPetTrashCurrency(info.itemID) then
						local hasTransmogInfo = C_TransmogCollection_GetItemInfo(info.hyperlink)
						if not (hasTransmogInfo and K.IsUnknownTransmog(bag, slot)) then
							toSell[#toSell + 1] = (bag * 100 + slot)
						end
					end
				end
			end
		end

		if #toSell > 0 then
			K:RegisterEvent("UI_ERROR_MESSAGE", updateAutoSell)
			startSelling()
		end
	elseif (event == "UI_ERROR_MESSAGE" and arg == errorText) or event == "MERCHANT_CLOSED" then
		autoSellStop = true
		K:UnregisterEvent("UI_ERROR_MESSAGE", updateAutoSell)
	end
end

function Module:CreateAutoSell()
	K:RegisterEvent("MERCHANT_SHOW", updateAutoSell)
	K:RegisterEvent("MERCHANT_CLOSED", updateAutoSell)
end

function Module:SetAutoSellEnabled(enabled)
	if enabled then
		K:RegisterEvent("MERCHANT_SHOW", updateAutoSell)
		K:RegisterEvent("MERCHANT_CLOSED", updateAutoSell)
	else
		autoSellStop = true
		K:UnregisterEvent("MERCHANT_SHOW", updateAutoSell)
		K:UnregisterEvent("MERCHANT_CLOSED", updateAutoSell)
		K:UnregisterEvent("UI_ERROR_MESSAGE", updateAutoSell)
	end
end
