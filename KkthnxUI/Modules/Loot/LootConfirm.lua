local K, C = unpack(select(2, ...))
local Module = K:NewModule("AutoLootConfirm", "AceEvent-3.0")
local GroupLoot = K:GetModule("GroupLoot")

local _G = _G
local select = select
local string_match = string.match
local tonumber = tonumber

local CloseLoot = _G.CloseLoot
local ConfirmLootRoll = _G.ConfirmLootRoll
local ConfirmLootSlot = _G.ConfirmLootSlot
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo
local GetLootRollItemInfo = _G.GetLootRollItemInfo
local GetLootRollItemLink = _G.GetLootRollItemLink
local GetMaxPlayerLevel = _G.GetMaxPlayerLevel
local GetNumLootItems = _G.GetNumLootItems
local hooksecurefunc = _G.hooksecurefunc
local IsEquippableItem = _G.IsEquippableItem
local IsXPUserDisabled = _G.IsXPUserDisabled
local LOOT_ROLL_TYPE_DISENCHANT = _G.LOOT_ROLL_TYPE_DISENCHANT
local LOOT_ROLL_TYPE_GREED = _G.LOOT_ROLL_TYPE_GREED
local RollOnLoot = _G.RollOnLoot
local UnitLevel = _G.UnitLevel

-- GLOBALS: KkthnxUIConfig, UIParent

Module.PlayerLevel = 0
Module.MaxPlayerLevel = 0

function Module:HandleEvent(event, ...)
	if not C["Loot"].AutoConfirm then
		return
	end

	if event == "CONFIRM_LOOT_ROLL" or event == "CONFIRM_DISENCHANT_ROLL" then
		local arg1, arg2 = ...
		ConfirmLootRoll(arg1, arg2)
	elseif event == "LOOT_OPENED" or event == "LOOT_BIND_CONFIRM" then
		local count = GetNumLootItems()
		if count == 0 then CloseLoot() return end
		for numslot = 1, count do
			ConfirmLootSlot(numslot)
		end
	end
end

function Module:PLAYER_LEVEL_UP(event, level)
	Module.PlayerLevel = level
end

function Module:HandleRoll(event, id)
	if not (C["Loot"].AutoGreed or C["Loot"].AutoDisenchant) then
		return
	end

	local _, name, _, quality, _, _, _, disenchant = GetLootRollItemInfo(id)
	local link = GetLootRollItemLink(id)
	local itemID = tonumber(string_match(link, "item:(%d+)"))

	if itemID == 43102 or itemID == 52078 or itemID == 140222 or itemID == 33865 or itemID == 124124 then
		RollOnLoot(id, LOOT_ROLL_TYPE_GREED)
	end

	if IsXPUserDisabled() then
		Module.MaxPlayerLevel = Module.PlayerLevel
	end

	if (C["Loot"].ByLevel and Module.PlayerLevel < C["Loot"].Level) and Module.PlayerLevel ~= Module.MaxPlayerLevel then
		return
	end

	if C["Loot"].ByLevel then
		if IsEquippableItem(link) then
			local _, _, _, ilvl, _, _, _, _, slot = GetItemInfo(link)
			local itemLink = GetInventoryItemLink("player", slot)
			local matchItemLevel = itemLink and select(4, GetItemInfo(itemLink)) or 1
			if quality ~= 7 and matchItemLevel < ilvl then
				return
			end
		end
	end

	if quality <= C["Loot"].AutoQuality then
		if C["Loot"].AutoDisenchant and disenchant then
			RollOnLoot(id, 3)
		else
			RollOnLoot(id, 2)
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("PLAYER_LEVEL_UP")

	Module.MaxPlayerLevel = GetMaxPlayerLevel()
	Module.PlayerLevel = UnitLevel("player")

	self:RegisterEvent("CONFIRM_DISENCHANT_ROLL", "HandleEvent")
	self:RegisterEvent("CONFIRM_LOOT_ROLL", "HandleEvent")
	self:RegisterEvent("LOOT_OPENED", "HandleEvent")
	self:RegisterEvent("LOOT_BIND_CONFIRM", "HandleEvent")
	hooksecurefunc(GroupLoot, "START_LOOT_ROLL", function(self, event, id)
		Module:HandleRoll(event, id)
	end)
end