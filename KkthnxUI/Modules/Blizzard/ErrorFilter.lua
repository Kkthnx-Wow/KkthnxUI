local K = unpack(select(2, ...))
local Module = K:NewModule("ErrorFilter", "AceEvent-3.0")

-- Set messages to allow
Module.Filter = {
	[INVENTORY_FULL] = true,
	[ERR_INV_FULL] = true,
	[ERR_ITEM_MAX_COUNT] = true,
	[ERR_LOOT_MASTER_INV_FULL] = true,
	[ERR_LOOT_MASTER_OTHER] = true,
	[ERR_LOOT_MASTER_UNIQUE_ITEM] = true,
	[ERR_NOT_ENOUGH_MONEY] = true,
	[ERR_PARTY_LFG_BOOT_DUNGEON_COMPLETE] = true,
	[ERR_PARTY_LFG_BOOT_IN_COMBAT] = true,
	[ERR_PARTY_LFG_BOOT_IN_PROGRESS] = true,
	[ERR_PARTY_LFG_BOOT_LIMIT] = true,
	[ERR_PARTY_LFG_BOOT_LOOT_ROLLS] = true,
	[ERR_PARTY_LFG_TELEPORT_IN_COMBAT] = true,
	[ERR_PET_SPELL_DEAD] = true,
	[ERR_PLAYER_DEAD] = true,
	[ERR_QUEST_LOG_FULL] = true,
	[ERR_RAID_GROUP_ONLY] = true,
	[SPELL_FAILED_IN_COMBAT_RES_LIMIT_REACHED] = true,
}

function Module:OnEvent(_, msg)
	if self.Filter[msg] then
		UIErrorsFrame:AddMessage(msg, 1, 0, 0)
	end
end

function Module:OnEnable()
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE", "OnEvent")
	self:RegisterEvent("UI_ERROR_MESSAGE", "OnEvent")
end