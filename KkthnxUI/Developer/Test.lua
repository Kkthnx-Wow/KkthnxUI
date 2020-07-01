local K, C, L = unpack(select(2, ...))

if not K.isDeveloper then
	return
end

local Module = K:NewModule("AutoQuestLoot")

local _G = _G
local string_find = _G.string.find

local GetCVar = _G.GetCVar
local GetLootSlotInfo =_G.GetLootSlotInfo
local GetNumLootItems =_G.GetNumLootItems
local GetNumQuestLeaderBoards =_G.GetNumQuestLeaderBoards
local GetNumQuestLogEntries =_G.GetNumQuestLogEntries
local GetQuestLogLeaderBoard =_G.GetQuestLogLeaderBoard

local function isInTable(item, table)
	for key, value in pairs(table) do
		if value == item then
			return key
		end
	end

	return false
end

function Module:CreateAutoQuestLoot()
	for questIndex = 1, GetNumQuestLogEntries() do
		for boardIndex = 1, GetNumQuestLeaderBoards(questIndex) do
			local leaderboardTxt, boardItemType, isDone = GetQuestLogLeaderBoard(boardIndex, questIndex)
			if not isDone and boardItemType == "item" then
				local _, _, _, _, itemName = string_find(leaderboardTxt, "([%d]+)%s*/%s*([%d]+)%s*(.*)%s*")
				if itemName then
					for lootIndex = 1, GetNumLootItems() do
						local _, lootName = GetLootSlotInfo(lootIndex)
						if lootName == itemName then
							LootSlot(lootIndex)
						end
					end
				end
			end
		end
	end

	for lootIndex = 1, GetNumLootItems() do
		local lootIcon = GetLootSlotInfo(lootIndex)
		if isInTable(lootIcon, {133789, 133788, 133787, 133786, 133785, 133784}) then
			LootSlot(lootIndex)
		end
	end
end

function Module:OnEnable()
	if GetCVar("AutoLootDefault") == "1" or not C["Loot"].OnlyLootQuestItems then
		return
	end

	K:RegisterEvent("LOOT_OPENED", self.CreateAutoQuestLoot)
end