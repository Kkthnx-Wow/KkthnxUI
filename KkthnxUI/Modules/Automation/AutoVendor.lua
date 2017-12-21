local _G = _G
local K, C, L = _G.unpack(_G.select(2, ...))
local Module = K:NewModule("KkthnxUI_AutoSell", "AceEvent-3.0", "AceTimer-3.0")

-- Lua WoW
local math_floor = math.floor
local C_Timer_NewTicker = _G.C_Timer.NewTicker

-- Declarations
local IterationCount, totalPrice = 500, 0
local SellJunkTicker, mBagID, mBagSlot

-- Function to stop selling
local function StopSelling()
	if SellJunkTicker then
		SellJunkTicker:Cancel()
	end

	Module:UnregisterEvent("ITEM_LOCKED")
	Module:UnregisterEvent("ITEM_UNLOCKED")
end

-- Vendor function
local function StartSelling()
	-- Variables
	local SoldCount, Rarity, ItemPrice = 0, 0, 0
	local CurrentItemLink, void

	-- Traverse bags and sell grey items
	for BagID = 0, 4 do
		for BagSlot = 1, _G.GetContainerNumSlots(BagID) do
			CurrentItemLink = _G.GetContainerItemLink(BagID, BagSlot)
			if CurrentItemLink then
				void, void, Rarity, void, void, void, void, void, void, void, ItemPrice = _G.GetItemInfo(CurrentItemLink)
				local void, itemCount = _G.GetContainerItemInfo(BagID, BagSlot)
				if Rarity == 0 and ItemPrice ~= 0 then
					SoldCount = SoldCount + 1
					if MerchantFrame:IsShown() then
						-- If merchant frame is open, vendor the item
						_G.UseContainerItem(BagID, BagSlot)
						-- Perform actions on first iteration
						if SellJunkTicker._remainingIterations == IterationCount then
							-- Calculate total price
							totalPrice = totalPrice + (ItemPrice * itemCount)
							-- Store first sold bag slot for analysis
							if SoldCount == 1 then
								mBagID, mBagSlot = BagID, BagSlot
							end
						end
					else
						-- If merchant frame is not open, stop selling
						StopSelling()
						return
					end
				end
			end
		end
	end

	-- Stop selling if no items were sold for this iteration or iteration limit was reached
	if SoldCount == 0 or SellJunkTicker and SellJunkTicker._remainingIterations == 1 then
		StopSelling()
		if C["Misc"].SellJunkSummary and totalPrice > 0 then
			local gold, silver, copper = math_floor(totalPrice/10000) or 0, math_floor((totalPrice%10000)/100) or 0, totalPrice%100
			K.Print("Sold junk for:".." |cffffffff"..gold..L.Miscellaneous.Gold_Short.." |cffffffff"..silver..L.Miscellaneous.Silver_Short.." |cffffffff"..copper..L.Miscellaneous.Copper_Short..".")
			-- K.Print("Sold junk for" .. " " .. GetCoinText(totalPrice) .. ".")
		end
	end
end

function Module:OnEvent(event)
	if C["Misc"].AutoSell ~= true then return end

	if event == "MERCHANT_SHOW" then
		-- Reset variables
		totalPrice, mBagID, mBagSlot = 0, -1, -1
		-- Do nothing if shift key is held down
		if _G.IsShiftKeyDown() then return end
		-- Sell grey items using ticker (ends when all grey items are sold or iteration count reached)
		SellJunkTicker = C_Timer_NewTicker(0.2, StartSelling, IterationCount)
		self:RegisterEvent("ITEM_LOCKED", StartSelling)
		self:RegisterEvent("ITEM_UNLOCKED", StartSelling)
	elseif event == "ITEM_LOCKED" then
		self:UnregisterEvent("ITEM_LOCKED")
	elseif event == "ITEM_UNLOCKED" then
		self:UnregisterEvent("ITEM_UNLOCKED")
		-- Check whether vendor refuses to buy items
		if mBagID and mBagSlot and mBagID ~= -1 and mBagSlot ~= -1 then
			local texture, count, locked = _G.GetContainerItemInfo(mBagID, mBagSlot)
			if count and not locked then
				-- Item has been unlocked but still not sold so stop selling
				StopSelling()
			end
		end
	elseif event == "MERCHANT_CLOSED" then
		-- If merchant frame is closed, stop selling
		StopSelling()
	end
end

function Module:OnEnable()
	if C["Misc"].AutoSell ~= true then return end
	self:RegisterEvent("MERCHANT_SHOW", "OnEvent")
	self:RegisterEvent("MERCHANT_CLOSED", "OnEvent")
end

function Module:OnDisable()
	self:UnregisterEvent("MERCHANT_SHOW")
	self:UnregisterEvent("MERCHANT_CLOSED")
end