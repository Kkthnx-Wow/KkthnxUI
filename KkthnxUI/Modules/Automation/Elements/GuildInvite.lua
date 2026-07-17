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

local IsSecret = K.IsSecret
local NotSecret = K.NotSecret
local UNKNOWN = _G.UNKNOWN
local date = _G.date

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local guildMemberCache = {}
local guildCacheDirty = true

-- ---------------------------------------------------------------------------
-- Trust Checks
-- ---------------------------------------------------------------------------
local function normalizeName(name)
	if not name or IsSecret(name) then
		return nil
	end

	return string_lower(Ambiguate(name, "none"))
end

local function safeName(name)
	return (name and NotSecret(name)) and name or UNKNOWN
end

-- ---------------------------------------------------------------------------
-- Stats (account-wide)
-- ---------------------------------------------------------------------------
-- REASON: KkthnxUI has a single account-wide SavedVariables global (KkthnxUIDB,
-- per KkthnxUI.toc) rather than a separate per-purpose "global vars" helper, so
-- stats are stored directly on it under their own namespaced key.
-- BUGFIX: this block was originally placed near the top of the file (right
-- after the IsSecret/NotSecret locals), before safeName existed yet in the
-- source — recordBlocked referenced a (duplicate) safeNameForStats function
-- that Lua would have resolved as an undeclared global at that point, not the
-- later local. Moved here, after safeName, and reusing it directly instead.
local function ensureStatsTable()
	_G.KkthnxUIDB = _G.KkthnxUIDB or {}
	_G.KkthnxUIDB.GuildInviteStats = _G.KkthnxUIDB.GuildInviteStats or {
		totalBlocked = 0,
		totalAllowed = 0,
		lastBlocked = nil,
	}
	return _G.KkthnxUIDB.GuildInviteStats
end

local function recordAllowed()
	local stats = ensureStatsTable()
	stats.totalAllowed = (stats.totalAllowed or 0) + 1
end

local function recordBlocked(inviter, guildName)
	local stats = ensureStatsTable()
	stats.totalBlocked = (stats.totalBlocked or 0) + 1
	stats.lastBlocked = {
		player = safeName(inviter),
		guild = safeName(guildName),
		time = date("%Y-%m-%d %H:%M:%S"),
	}
end

function Module:PrintGuildInviteStats()
	local stats = ensureStatsTable()
	K.Print(string_format(L["Guild Invite Stats: Blocked %d, Allowed %d"], stats.totalBlocked or 0, stats.totalAllowed or 0))
	if stats.lastBlocked then
		K.Print(string_format(L["Last blocked: %s to <%s> (%s)"], stats.lastBlocked.player, stats.lastBlocked.guild, stats.lastBlocked.time or "?"))
	else
		K.Print(L["Last blocked: none yet."])
	end
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
	local cfg = C["Automation"]
	if cfg.AutoDeclineGuildInvitesFromFriends and (isCharacterFriend(target) or isBattleNetFriend(target)) then
		return true
	end
	if cfg.AutoDeclineGuildInvitesFromGuild and isCurrentGuildMember(target) then
		return true
	end
	return false
end

-- ---------------------------------------------------------------------------
-- Popup / Blizzard Option Handling
-- ---------------------------------------------------------------------------
local function hideGuildInvitePopup()
	local guildInviteFrame = _G.GuildInviteFrame
	if guildInviteFrame and guildInviteFrame:IsShown() then
		if StaticPopupSpecial_Hide then
			StaticPopupSpecial_Hide(guildInviteFrame)
		else
			guildInviteFrame:Hide()
		end
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
	if not target then
		return
	end
	if isTrustedInviter(target) then
		recordAllowed()
		return
	end

	DeclineGuild()
	hideGuildInvitePopup()
	C_Timer_After(0, hideGuildInvitePopup)

	local cfg = C["Automation"]
	if cfg.AutoDeclineGuildInvitesSound then
		PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON, "Master")
	end

	recordBlocked(inviter, guildName)
	if cfg.AutoDeclineGuildInvitesAnnounce then
		K.Print(string_format(L["Declined a guild invite from %s to join <%s>."], safeName(inviter), safeName(guildName)))
	end
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
