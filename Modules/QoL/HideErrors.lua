--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/HideErrors.lua
	Purpose:
		Quiet the red error text in the middle of the screen ("Not enough rage",
		"Ability is not ready yet") and keep the few that matter: full bags, a full
		quest log, being dead, and the group kick messages.

		The error frame is not modified. It is told to stop listening for error
		messages, and this file listens in its place and hands the allowed ones
		back through AddMessage. Turning the option off and reloading restores the
		stock behaviour.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret
local UIErrorsFrame = UIErrorsFrame
local find = string.find

-- Messages that stay. Built when the feature starts so the globals are read once.
local keep = {}

local function BuildKeepList()
	for _, message in ipairs({
		_G.ERR_INV_FULL,
		_G.ERR_QUEST_LOG_FULL,
		_G.ERR_RAID_GROUP_ONLY,
		_G.ERR_PET_SPELL_DEAD,
		_G.ERR_PLAYER_DEAD,
		_G.ERR_PARTY_LFG_BOOT_LIMIT,
		_G.ERR_PARTY_LFG_BOOT_DUNGEON_COMPLETE,
		_G.ERR_PARTY_LFG_BOOT_IN_COMBAT,
		_G.ERR_PARTY_LFG_BOOT_IN_PROGRESS,
		_G.ERR_PARTY_LFG_BOOT_LOOT_ROLLS,
		_G.ERR_PARTY_LFG_TELEPORT_IN_COMBAT,
		_G.SPELL_FAILED_TARGET_NO_POCKETS,
		_G.ERR_ALREADY_PICKPOCKETED,
	}) do
		keep[message] = true
	end
end

-- The "not eligible to kick" line is a format string, so it is matched as a
-- pattern. Built once, with the format's own placeholder turned into a wildcard.
local notEligible

local function IsKept(message)
	if keep[message] then
		return true
	end
	return notEligible and find(message, notEligible) ~= nil
end

local function OnError(_, _, _, message)
	if not message or IsSecret(message) then
		return
	end
	if IsKept(message) then
		UIErrorsFrame:AddMessage(message, 1, 0.1, 0.1, 1)
	end
end

function Module:SetupHideErrors()
	BuildKeepList()
	if _G.ERR_PARTY_LFG_BOOT_NOT_ELIGIBLE_S then
		-- Escape the pattern characters, then turn the %s placeholder into a wildcard.
		local escaped = _G.ERR_PARTY_LFG_BOOT_NOT_ELIGIBLE_S:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
		notEligible = "^" .. escaped:gsub("%%s", ".+") .. "$"
	end

	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
	self:RegisterEvent("UI_ERROR_MESSAGE", OnError)
end
