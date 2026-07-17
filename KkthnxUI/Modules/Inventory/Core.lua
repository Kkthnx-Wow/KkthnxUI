--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Bags module entry — sorting, layout anchors, enable/disable.
-- - Design: cargBags bootstrap in Elements/BagInit.lua; widgets in BagWidgets.lua.
-- - Events: TRADE_SHOW, TRADE_CLOSED, GET_ITEM_INFO_RECEIVED (registered in BagInit).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Bags")

local _G = _G
local C_Container_GetContainerItemInfo = _G.C_Container.GetContainerItemInfo
local GetContainerNumSlots = _G.C_Container.GetContainerNumSlots
local ipairs = _G.ipairs
local pairs = _G.pairs
local pcall = _G.pcall
local PickupContainerItem = _G.C_Container.PickupContainerItem
local table_wipe = _G.table.wipe
local tostring = _G.tostring
local type = _G.type

Module._sortCache = Module._sortCache or {}

-- ---------------------------------------------------------------------------
-- Sorting & Anchoring
-- ---------------------------------------------------------------------------
function Module:ReverseSort()
	for bagID = 0, 4 do
		local numSlots = GetContainerNumSlots(bagID)
		for slotID = 1, numSlots do
			local info = C_Container_GetContainerItemInfo(bagID, slotID)
			local texture = info and info.iconFileID
			local locked = info and info.isLocked
			local bagCache = Module._sortCache[bagID]
			if (slotID <= numSlots / 2) and texture and not locked and not (bagCache and bagCache[slotID]) then
				PickupContainerItem(bagID, slotID)
				PickupContainerItem(bagID, numSlots + 1 - slotID)
				if not Module._sortCache[bagID] then
					Module._sortCache[bagID] = {}
				end
				Module._sortCache[bagID][slotID] = true
			end
		end
	end

	Module.Bags.isSorting = false
	Module:UpdateAllBags()
end

local anchorCache = {}

local function hasReagentBag(name)
	if name == "BagReagent" and GetContainerNumSlots(5) == 0 then
		return false
	end
	return true
end

function Module:UpdateBagsAnchor(parent, bags)
	table_wipe(anchorCache)

	local currentIndex = 1
	local perRow = C["Inventory"].BagsPerRow
	anchorCache[currentIndex] = parent

	for i = 1, #bags do
		local bagFrame = bags[i]
		if bagFrame:GetHeight() > 45 and hasReagentBag(bagFrame.name) then
			bagFrame:Show()
			currentIndex = currentIndex + 1

			bagFrame:ClearAllPoints()
			if (currentIndex - 1) % perRow == 0 then
				bagFrame:SetPoint("BOTTOMRIGHT", anchorCache[currentIndex - perRow], "BOTTOMLEFT", -6, 0)
			else
				bagFrame:SetPoint("BOTTOMLEFT", anchorCache[currentIndex - 1], "TOPLEFT", 0, 6)
			end
			anchorCache[currentIndex] = bagFrame
		else
			bagFrame:Hide()
		end
	end
end

function Module:UpdateBankAnchor(parent, bags)
	table_wipe(anchorCache)

	local currentIndex = 1
	local perRow = C["Inventory"].BankPerRow
	anchorCache[currentIndex] = parent

	for i = 1, #bags do
		local bagFrame = bags[i]
		if bagFrame:GetHeight() > 45 then
			bagFrame:Show()
			currentIndex = currentIndex + 1

			bagFrame:ClearAllPoints()
			if currentIndex <= perRow then
				bagFrame:SetPoint("BOTTOMLEFT", anchorCache[currentIndex - 1], "TOPLEFT", 0, 6)
			elseif currentIndex == perRow + 1 then
				bagFrame:SetPoint("TOPLEFT", anchorCache[currentIndex - 1], "TOPRIGHT", 6, 0)
			elseif (currentIndex - 1) % perRow == 0 then
				bagFrame:SetPoint("TOPLEFT", anchorCache[currentIndex - perRow], "TOPRIGHT", 6, 0)
			else
				bagFrame:SetPoint("TOPLEFT", anchorCache[currentIndex - 1], "BOTTOMLEFT", 0, -6)
			end
			anchorCache[currentIndex] = bagFrame
		else
			bagFrame:Hide()
		end
	end
end

function Module:SetInventoryEnabled(enabled)
	if enabled then
		if not self.initComplete then
			self:InitBags()
		end

		if not self.initComplete then
			if self.initConflict then
				K.Print("|cff3c9bedKkthnxUI:|r Custom inventory disabled — " .. self.initConflict .. " is loaded.")
			end
			return
		end

		if self.Bags then
			self.Bags:Show()
		end

		local bagBar = _G.KKUI_BagBar
		if bagBar then
			bagBar:Show()
		end

		self:UpdateBagAnchor()
		return
	end

	if self.Bags then
		if self.Bags:IsShown() and _G.ToggleAllBags then
			_G.ToggleAllBags()
		end
		self.Bags:Hide()
	end

	if self.Bags and self.Bags.contByName then
		for _, container in pairs(self.Bags.contByName) do
			container:Hide()
		end
	end

	local bagBar = _G.KKUI_BagBar
	if bagBar then
		bagBar:Hide()
	end

	if Module._bagEventsRegistered then
		K:UnregisterEvent("TRADE_SHOW", Module.OpenBags)
		K:UnregisterEvent("TRADE_CLOSED", Module.CloseBags)
		K:UnregisterEvent("GET_ITEM_INFO_RECEIVED", Module.OnBagItemInfoReceived)
		Module._bagEventsRegistered = nil
	end
end

function Module:OnEnable()
	local loadInventoryModules = {
		"CreateInventoryBar",
		"CreateAutoRepair",
		"CreateAutoSell",
		"CreateAutoWarbandGold",
	}

	for _, funcName in ipairs(loadInventoryModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	if C["Inventory"].Enable then
		Module:InitBags()
	end
end
