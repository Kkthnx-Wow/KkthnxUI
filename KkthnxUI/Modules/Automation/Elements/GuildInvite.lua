--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Declines guild invites from strangers while allowing trusted sources.
-- - Design: Lets character friends, Battle.net friends, and current guild members through.
-- - Events: GUILD_INVITE_REQUEST, GUILD_ROSTER_UPDATE, PLAYER_GUILD_UPDATE
-----------------------------------------------------------------------------]]

local K, C, L = _G["KkthnxUI"][1], _G["KkthnxUI"][2], _G["KkthnxUI"][3]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions used by invite handling.
local Ambiguate = _G.Ambiguate
local BNGetNumFriends = _G.BNGetNumFriends
local C_BattleNet_GetFriendGameAccountInfo = _G.C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = _G.C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_GetFriendInfoByIndex = _G.C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetNumFriends = _G.C_FriendList.GetNumFriends
local C_GuildInfo_GuildRoster = _G.C_GuildInfo.GuildRoster
local C_Timer_After = _G.C_Timer.After
local DeclineGuild = _G.DeclineGuild
local GetAutoDeclineGuildInvites = _G.GetAutoDeclineGuildInvites
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetNumGuildMembers = _G.GetNumGuildMembers
local IsInGuild = _G.IsInGuild
local PlaySound = _G.PlaySound
local SetAutoDeclineGuildInvites = _G.SetAutoDeclineGuildInvites
local StaticPopup_Hide = _G["StaticPopup_Hide"]
local StaticPopupSpecial_Hide = _G["StaticPopupSpecial_Hide"]
local string_format = _G.string.format
local string_lower = _G.string.lower
local table_wipe = _G.table.wipe

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local guildMemberCache = {}
local guildCacheDirty = true

-- ---------------------------------------------------------------------------
-- Trust Checks
-- ---------------------------------------------------------------------------
local function normalizeName(name)
	if not name then
		return
	end

	return string_lower(Ambiguate(name, "none"))
end

local function isCharacterFriend(target)
	if not target then
		return false
	end

	for index = 1, C_FriendList_GetNumFriends() do
		local info = C_FriendList_GetFriendInfoByIndex(index)
		if info and normalizeName(info.name) == target then
			return true
		end
	end

	return false
end

local function isBattleNetFriend(target)
	if not target then
		return false
	end

	for friendIndex = 1, BNGetNumFriends() do
		local numAccounts = C_BattleNet_GetFriendNumGameAccounts(friendIndex)
		for accountIndex = 1, numAccounts do
			local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(friendIndex, accountIndex)
			if gameAccountInfo and gameAccountInfo.clientProgram == "WoW" and normalizeName(gameAccountInfo.characterName) == target then
				return true
			end
		end
	end

	return false
end

local function rebuildGuildCache()
	table_wipe(guildMemberCache)

	if IsInGuild() then
		C_GuildInfo_GuildRoster()
		for index = 1, GetNumGuildMembers() do
			local normalized = normalizeName(GetGuildRosterInfo(index))
			if normalized then
				guildMemberCache[normalized] = true
			end
		end
	end

	guildCacheDirty = false
end

local function isCurrentGuildMember(target)
	if not target then
		return false
	end

	if guildCacheDirty then
		rebuildGuildCache()
	end

	return guildMemberCache[target] == true
end

local function isTrustedInviter(target)
	return isCharacterFriend(target) or isBattleNetFriend(target) or isCurrentGuildMember(target)
end

-- ---------------------------------------------------------------------------
-- Popup / Blizzard Option Handling
-- ---------------------------------------------------------------------------
local function hideGuildInvitePopup()
	local guildInviteFrame = _G["GuildInviteFrame"]
	if guildInviteFrame and guildInviteFrame:IsShown() then
		StaticPopupSpecial_Hide(guildInviteFrame)
	end
	StaticPopup_Hide("GUILD_INVITE")
end

local function isBlizzardAutoDeclineEnabled()
	local value = GetAutoDeclineGuildInvites()
	return value == 1 or value == "1" or value == true
end

local function suppressBlizzardAutoDecline()
	-- REASON: Blizzard's server-side block prevents GUILD_INVITE_REQUEST from firing.
	local charVars = K.GetCharVars()
	if charVars.AutoGuildInviteDeclinePrevious == nil then
		charVars.AutoGuildInviteDeclinePrevious = isBlizzardAutoDeclineEnabled() and 1 or 0
	end

	SetAutoDeclineGuildInvites(false)
end

local function restoreBlizzardAutoDecline()
	local charVars = K.GetCharVars()
	if charVars.AutoGuildInviteDeclinePrevious ~= nil then
		SetAutoDeclineGuildInvites(charVars.AutoGuildInviteDeclinePrevious == 1)
		charVars.AutoGuildInviteDeclinePrevious = nil
	end
end

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------
local function onGuildInvite(event, inviter, guildName)
	if not C["Automation"].AutoDeclineGuildInvites then
		return
	end

	local target = normalizeName(inviter)
	if not target or isTrustedInviter(target) then
		return
	end

	DeclineGuild()
	hideGuildInvitePopup()
	C_Timer_After(0, hideGuildInvitePopup)
	PlaySound(_G["SOUNDKIT"].IG_MAINMENU_OPTION_CHECKBOX_ON, "Master")

	K.Print(string_format(L["Declined a guild invite from %s to join <%s>."], inviter or _G["UNKNOWN"], guildName or _G["UNKNOWN"]))
end

local function onGuildRosterChanged()
	guildCacheDirty = true
	if not IsInGuild() then
		table_wipe(guildMemberCache)
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoDeclineGuildInvites()
	if C["Automation"].AutoDeclineGuildInvites then
		K:RegisterEvent("GUILD_INVITE_REQUEST", onGuildInvite)
		K:RegisterEvent("GUILD_ROSTER_UPDATE", onGuildRosterChanged)
		K:RegisterEvent("PLAYER_GUILD_UPDATE", onGuildRosterChanged)
		suppressBlizzardAutoDecline()
	else
		K:UnregisterEvent("GUILD_INVITE_REQUEST", onGuildInvite)
		K:UnregisterEvent("GUILD_ROSTER_UPDATE", onGuildRosterChanged)
		K:UnregisterEvent("PLAYER_GUILD_UPDATE", onGuildRosterChanged)
		restoreBlizzardAutoDecline()
	end
end
