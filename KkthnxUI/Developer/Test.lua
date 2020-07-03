local K, C = unpack(select(2, ...))
local Module = K:NewModule("AutoQuestLoot")

local _G = _G
local string_find = _G.string.find

local GetCVar = _G.GetCVar
local GetLootSlotInfo =_G.GetLootSlotInfo
local GetNumLootItems =_G.GetNumLootItems
local GetNumQuestLeaderBoards =_G.GetNumQuestLeaderBoards
local GetNumQuestLogEntries =_G.GetNumQuestLogEntries
local GetQuestLogLeaderBoard =_G.GetQuestLogLeaderBoard
local LootSlot = _G.LootSlot

local coinTextureIDs = {
	[133784] = true,
	[133785] = true,
	[133786] = true,
	[133787] = true,
	[133788] = true,
	[133789] = true
}

function Module:CreateAutoQuestLoot()
	for questIndex = 1, GetNumQuestLogEntries() do
		for boardIndex = 1, GetNumQuestLeaderBoards(questIndex) do
			local leaderboardTxt, boardItemType, isDone = GetQuestLogLeaderBoard(boardIndex, questIndex)
			if not isDone and boardItemType == "item" then
				local _, _, _, _, itemName = string_find(leaderboardTxt, "([%d]+)%s*/%s*([%d]+)%s*(.*)%s*")
				if itemName then
					for lootIndex = 1, GetNumLootItems() do
						local _, lootName, _, _, _, _, isQuestItem, questId, isActive = GetLootSlotInfo(lootIndex)
						if (questId and not isActive) then
							LootSlot(lootIndex)
						elseif (questId or isQuestItem) then
							LootSlot(lootIndex)
						elseif lootName == itemName then
							LootSlot(lootIndex)
						end
					end
				end
			end
		end
	end

	for lootIndex = 1, GetNumLootItems() do
		local lootIcon = GetLootSlotInfo(lootIndex)
		if coinTextureIDs[lootIcon] then
			print(coinTextureIDs)
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