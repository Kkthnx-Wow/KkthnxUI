--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Renames chat channel prefixes, adds custom timestamps, and formats system messages.
-- - Design: Hooks AddMessage on all chat frames to apply non-tainting string rewrites.
-- - Events: CHAT_MSG_SYSTEM
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to minimize lookup overhead.
-- local _G = _G
-- local BetterDate = _G.BetterDate
-- local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime.GetCurrentCalendarTime
-- local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
-- local GetCVar = _G.GetCVar
-- local GetCVarBool = _G.GetCVarBool
-- local INTERFACE_ACTION_BLOCKED = _G.INTERFACE_ACTION_BLOCKED
-- local date = _G.date
-- local rawget = _G.rawget
-- local string_find = string.find
-- local string_gsub = string.gsub
-- local table_insert = table.insert
-- local time = time
-- local tonumber = tonumber

local gsub, strfind, strmatch, format, strsub, strlen, strupper = string.gsub, string.find, string.match, string.format, string.sub, string.len, string.upper
local tostring = tostring
local BetterDate, time, date, GetCVarBool = BetterDate, time, date, GetCVarBool
local RemoveExtraSpaces = RemoveExtraSpaces
local INTERFACE_ACTION_BLOCKED = INTERFACE_ACTION_BLOCKED
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local colon = HEADER_COLON
local isCN = strlen(colon) > 1

-- ---------------------------------------------------------------------------
-- Timestamp helpers
-- ---------------------------------------------------------------------------
local timestampFormat = {
	[2] = "[%I:%M %p] ",
	[3] = "[%I:%M:%S %p] ",
	[4] = "[%H:%M] ",
	[5] = "[%H:%M:%S] ",
}

local function GetCurrentTime()
	-- REASON: Use local time by default or realm/server time when the user prefers it.
	local locTime = time()
	local realmTime = not GetCVarBool("timeMgrUseLocalTime") and C_DateAndTime_GetCurrentCalendarTime()
	if realmTime then
		realmTime.day = realmTime.monthDay
		realmTime.min = realmTime.minute
		realmTime.sec = date("%S") -- no sec value for realm time
		realmTime = time(realmTime)
	end

	return locTime, realmTime
end

-- ---------------------------------------------------------------------------
-- Author logo helper
-- ---------------------------------------------------------------------------
local function AddAuthorLogo(link, unitName)
	-- REASON: Decorate known developer names with a small author badge.
	if unitName and K.Devs[unitName] then
		return "|T" .. C["Media"].Textures.LogoSmallTexture .. ":12:24|t" .. link
	end
	return link
end

-- ---------------------------------------------------------------------------
-- Channel abbreviation data
-- ---------------------------------------------------------------------------
local LEADERSHIP = {
	PartyLeader = strmatch(CHAT_PARTY_LEADER_GET, "|h%[(.-)%]|h"),
	PartyGuide = strmatch(CHAT_PARTY_GUIDE_GET, "|h%[(.-)%]|h"),
	RaidLeader = strmatch(CHAT_RAID_LEADER_GET, "|h%[(.-)%]|h"),
	InstLeader = strmatch(CHAT_INSTANCE_CHAT_LEADER_GET, "|h%[(.-)%]|h"),
}

local CHANNEL_ABBR = {
	PARTY = {
		abbr = "P",
		leaders = {
			[LEADERSHIP.PartyLeader] = "PL",
			[LEADERSHIP.PartyGuide] = "PG",
		},
	},
	RAID = {
		abbr = "R",
		leaders = {
			[LEADERSHIP.RaidLeader] = "RL",
		},
	},
	INSTANCE_CHAT = {
		abbr = "I",
		leaders = {
			[LEADERSHIP.InstLeader] = "IL",
		},
	},
	GUILD = { abbr = "G" },
	OFFICER = { abbr = "O" },
}

local CHANNEL_ABBR_LOCALES = {
	PARTY = {
		abbr = L["PartyAbbr"],
		leaders = {
			[LEADERSHIP.PartyLeader] = L["PartyLeaderAbbr"],
			[LEADERSHIP.PartyGuide] = L["PartyGuideAbbr"],
		},
	},
	RAID = {
		abbr = L["RaidAbbr"],
		leaders = {
			[LEADERSHIP.RaidLeader] = L["RaidLeaderAbbr"],
		},
	},
	INSTANCE_CHAT = {
		abbr = L["InstAbbr"],
		leaders = {
			[LEADERSHIP.InstLeader] = L["InstLeaderAbbr"],
		},
	},
	GUILD = { abbr = L["GuildAbbr"] },
	OFFICER = { abbr = L["OfficerAbbr"] },
}

local matchPattern = "(|H(%w+):?([^:]+):?(%d*)|h)%[(.-)%]|h"

local function AbbrChannelName(prefix, linkType, channel, channelID, channelName)
	-- REASON: Rewrite Blizzard channel links using shorter localized abbreviations.
	if C["Chat"].ChannelAbbreviation == 1 then
		return
	end

	if linkType ~= "channel" then
		return
	end

	if channel == "channel" then
		return prefix .. "[" .. channelID .. "]|h"
	end

	local channels = C["Chat"].ChannelAbbreviation == 2 and CHANNEL_ABBR or CHANNEL_ABBR_LOCALES
	local data = channels[channel]
	if not data then
		return prefix .. "[" .. channelName .. "]|h"
	end

	local abbr = data.abbr
	local isLeader = data.leaders and data.leaders[channelName]
	if isLeader then
		abbr = isLeader
	end

	return prefix .. "[" .. abbr .. "]|h"
end

-- ---------------------------------------------------------------------------
-- Colon removal helpers
-- ---------------------------------------------------------------------------
local channels = {
	SAY = not isCN,
	YELL = not isCN,
	WHISPER = not isCN,
	GUILD = not isCN,
	OFFICER = not isCN,
	CHANNEL = not isCN,
	PARTY = true,
	RAID = true,
	INSTANCE_CHAT = not isCN,
}

local cnColonChannels = {
	SAY = true,
	YELL = true,
	WHISPER = true,
	GUILD = true,
	OFFICER = true,
	CHANNEL = true,
	PARTY = true,
	RAID = true,
	INSTANCE_CHAT = true,
}

local cnPattern = "(|Hplayer[^]]*:([^:]+):[^]]*%].-)" .. colon .. "%s"
local enPattern = "(|Hplayer[^]]*:([^:]+):[^]]*%].-):%s"

local function KillColon(link, tag)
	if channels[tag] then
		return link .. " "
	end
end

local function KillCNColon(link, tag)
	if cnColonChannels[tag] then
		return link .. " "
	end
end

local function convertLink(text, value)
	return "|Hurl:" .. tostring(value) .. "|h" .. K.InfoColor .. text .. "|r|h"
end

local function highlightURL(_, url)
	return " " .. convertLink("[" .. url .. "]", url) .. " "
end

-- ---------------------------------------------------------------------------
-- Chat target helper
-- ---------------------------------------------------------------------------
-- FCFManager_GetChatTarget clone (safeguard)
local function GetChatTarget(chatGroup, playerTarget, channelTarget)
	-- REASON: Mirror Blizzard's target selection logic for chat frame suppression.
	if chatGroup == "CHANNEL" then
		return tostring(channelTarget)
	elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
		return playerTarget and strsub(playerTarget, 1, 2) ~= "|K" and strupper(playerTarget) or playerTarget
	end
end

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
-- Dedup cache: prevent double-processing when addons like WhisperPop
-- re-invoke event filters manually after WoW already processed them,
-- which would cause self:AddMessage to be called twice -> duplicate messages.
local processedLines = {}
local processedCount = 0
local PROCESSED_LINES_MAX = 200

-- ---------------------------------------------------------------------------
-- Chat filter callback
-- ---------------------------------------------------------------------------
local function ChatMsgFilter(self, event, msg, sender, language, channelString, target, flags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, senderGUID, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, suppressRaidIcons)
	-- REASON: Skip secret messages to avoid taint and invalid string processing.
	if K.IsSecretValue(msg) then
		return
	end

	if strfind(msg, INTERFACE_ACTION_BLOCKED) and not K.isDeveloper then
		return true
	end

	-- Dedup: skip if this message was already processed for this chat frame
	if lineID and lineID > 0 then
		local key = self:GetName() .. "_" .. lineID
		if processedLines[key] then
			return true
		end
		processedLines[key] = true
		processedCount = processedCount + 1
		if processedCount > PROCESSED_LINES_MAX then
			wipe(processedLines)
			processedCount = 0
		end
	end

	-- Per-window visibility check
	local chatType = strsub(event, 10)
	local chatGroup = ChatFrameUtil.GetChatCategory(chatType)
	local channelLength = strlen(channelString)

	-- For CHANNEL type: check self.channelList (mirrors Blizzard's logic in MessageEventHandler)
	-- For non-CHANNEL types: use FCFManager_ShouldSuppressMessage
	if chatType == "CHANNEL" then
		if channelLength > 0 then
			local found = false
			for index, value in pairs(self.channelList) do
				if channelLength > strlen(value) then
					if ((zoneChannelID > 0) and (self.zoneChannelList and self.zoneChannelList[index] == zoneChannelID)) or (strupper(value) == strupper(channelBaseName or "")) then
						found = true
						break
					end
				end
			end
			if not found then
				return true
			end
		end
	else
		local chatTarget = GetChatTarget(chatGroup, sender, channelIndex)
		if FCFManager_ShouldSuppressMessage(self, chatGroup, chatTarget) then
			return true
		end
	end

	-- Get correct color
	local info
	if chatType == "CHANNEL" and channelIndex and channelIndex > 0 then
		info = ChatTypeInfo["CHANNEL" .. channelIndex] or ChatTypeInfo[chatType]
	else
		info = ChatTypeInfo[chatType]
	end
	info = info or ChatTypeInfo["SYSTEM"]

	-- URL highlighting
	msg = gsub(msg, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	msg = gsub(msg, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlightURL)

	-- Build formatted message
	local formatKey = _G["CHAT_" .. chatType .. "_GET"]
	if not formatKey then
		return
	end

	local coloredName = ChatFrameUtil.GetDecoratedSenderName(event, msg, sender, language, channelString, target, flags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, senderGUID, bnSenderID, isMobile)
	local pflag = ChatFrameUtil.GetPFlag(flags, zoneChannelID, channelIndex)

	local playerLink
	if chatType == "BN_WHISPER" or chatType == "BN_WHISPER_INFORM" then
		playerLink = GetBNPlayerLink(sender, "[" .. coloredName .. "]", bnSenderID, lineID, chatGroup, 0)
	else
		playerLink = GetPlayerLink(sender, "[" .. coloredName .. "]", lineID, chatGroup, 0)
	end

	msg = gsub(msg, "%%", "%%%%")
	msg = C_ChatInfo.ReplaceIconAndGroupExpressions(msg, suppressRaidIcons)
	msg = RemoveExtraSpaces(msg)

	local outMsg = format(formatKey .. msg, pflag .. playerLink)

	-- Add channel prefix for custom channels
	if channelLength > 0 then
		local channelName = ChatFrameUtil.ResolvePrefixedChannelName(channelString)
		if channelName then
			outMsg = "|Hchannel:channel:" .. (channelIndex or 0) .. "|h[" .. channelName .. "]|h " .. outMsg
		end
	end

	-- Apply KkthnxUI modifications
	if C["Chat"].TimestampFormat > 1 then
		local locTime, realmTime = GetCurrentTime()
		local timeStamp = BetterDate(K.GreyColor .. timestampFormat[C["Chat"].TimestampFormat] .. "|r", realmTime or locTime)
		outMsg = timeStamp .. outMsg
	end

	outMsg = gsub(outMsg, "(|Hplayer:([^|:]+))", AddAuthorLogo)
	if isCN then
		outMsg = gsub(outMsg, cnPattern, KillCNColon)
	end
	outMsg = gsub(outMsg, enPattern, KillColon)
	outMsg = gsub(outMsg, matchPattern, AbbrChannelName)

	self:AddMessage(outMsg, info.r, info.g, info.b, info.id)

	return true
end

function Module:CreateChatRename()
	-- REASON: Register chat filters for all supported incoming message events.
	local events = {
		"CHAT_MSG_SAY",
		"CHAT_MSG_YELL",
		"CHAT_MSG_GUILD",
		"CHAT_MSG_OFFICER",
		"CHAT_MSG_PARTY",
		"CHAT_MSG_PARTY_LEADER",
		"CHAT_MSG_PARTY_GUIDE",
		"CHAT_MSG_RAID",
		"CHAT_MSG_RAID_LEADER",
		"CHAT_MSG_INSTANCE_CHAT",
		"CHAT_MSG_INSTANCE_CHAT_LEADER",
		"CHAT_MSG_WHISPER",
		"CHAT_MSG_WHISPER_INFORM",
		"CHAT_MSG_BN_WHISPER",
		"CHAT_MSG_BN_WHISPER_INFORM",
		"CHAT_MSG_CHANNEL",
		"CHAT_MSG_MONSTER_SAY",
	}
	for _, event in ipairs(events) do
		ChatFrame_AddMessageEventFilter(event, ChatMsgFilter)
	end
end
