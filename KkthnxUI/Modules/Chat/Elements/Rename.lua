--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Renames chat channel prefixes, adds custom timestamps, and formats system messages.
-- - Design: Hooks ChatFrame_AddMessageEventFilter to format messages before they hit AddMessage.
-- - Events: CHAT_MSG_SYSTEM and all other chat events
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Chat")

local _G = _G
local gsub, strfind, strmatch, format, strsub, strlen, strupper = string.gsub, string.find, string.match, string.format, string.sub, string.len, string.upper
local tostring, tonumber = tostring, tonumber
local ipairs = ipairs
local pairs = pairs
local BetterDate, time, date, GetCVarBool, GetTime = BetterDate, time, date, GetCVarBool, GetTime
local RemoveExtraSpaces = RemoveExtraSpaces
local INTERFACE_ACTION_BLOCKED = INTERFACE_ACTION_BLOCKED
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local C_ChatInfo = C_ChatInfo
local ChatFrameUtil = ChatFrameUtil
local ChatTypeInfo = ChatTypeInfo
local FCFManager_ShouldSuppressMessage = FCFManager_ShouldSuppressMessage or function()
	return false
end
local GetBNPlayerLink = GetBNPlayerLink
local GetPlayerLink = GetPlayerLink
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local FlashClientIcon = FlashClientIcon
local ChatFrameConstants = ChatFrameConstants or {}
local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter

-- API Fallbacks for older WoW clients (e.g. WotLK)
local GetChatCategory = ChatFrameUtil and ChatFrameUtil.GetChatCategory or _G.ChatHistory_GetChatCategory or _G.Chat_GetChatCategory or function(chatType)
	return chatType
end
local GetDecoratedSenderName = ChatFrameUtil and ChatFrameUtil.GetDecoratedSenderName or _G.GetColoredName or function(_, _, sender)
	return sender
end
local GetPFlag = ChatFrameUtil and ChatFrameUtil.GetPFlag or function()
	return ""
end
local ResolvePrefixedChannelName = ChatFrameUtil and ChatFrameUtil.ResolvePrefixedChannelName or _G.Chat_ResolvePrefixedChannelName or function(channelString)
	return channelString
end
local SetLastTellTarget = ChatFrameUtil and ChatFrameUtil.SetLastTellTarget or _G.ChatEdit_SetLastTellTarget or function() end
local FlashTabIfNotShown = ChatFrameUtil and ChatFrameUtil.FlashTabIfNotShown or _G.FCF_FlashTabIfNotShown or function() end
local ReplaceIconAndGroupExpressions = C_ChatInfo and C_ChatInfo.ReplaceIconAndGroupExpressions or function(msg)
	return msg
end

local colon = HEADER_COLON
local isCN = strlen(colon) > 1

-- Timestamp
local timestampFormat = {
	[2] = "[%I:%M %p] ",
	[3] = "[%I:%M:%S %p] ",
	[4] = "[%H:%M] ",
	[5] = "[%H:%M:%S] ",
}

local function GetCurrentTime()
	local locTime = time()
	local realmTime = not GetCVarBool("timeMgrUseLocalTime") and C_DateAndTime_GetCurrentCalendarTime()
	if realmTime then
		realmTime.day = realmTime.monthDay
		realmTime.min = realmTime.minute
		realmTime.sec = tonumber(date("%S")) -- no sec value for realm time
		realmTime = time(realmTime)
	end

	return locTime, realmTime
end

-- Channel name abbr
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
	if C["Chat"].ChannelAbbr == 1 then
		return
	end

	if linkType ~= "channel" then
		return
	end

	if channel == "channel" then
		return prefix .. "[" .. channelID .. "]|h"
	end

	local channels = C["Chat"].ChannelAbbr == 2 and CHANNEL_ABBR or CHANNEL_ABBR_LOCALES
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

-- Kill colon before message
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

local cnPattern = "(|Hplayer[^]]*:([^:]+):[^]]*%]|h.-)" .. colon .. "%s"

local function KillCNColon(link, tag)
	if cnColonChannels[tag] then
		return link .. ": "
	end
end

local function convertLink(text, value)
	return "|Hurl:" .. tostring(value) .. "|h" .. K.InfoColor .. text .. "|r|h"
end

local function highlightURL(_, url)
	return " " .. convertLink("[" .. url .. "]", url) .. " "
end

-- FCFManager_GetChatTarget clone (safeguard)
local function GetChatTarget(chatGroup, playerTarget, channelTarget)
	if chatGroup == "CHANNEL" then
		return tostring(channelTarget)
	elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
		return playerTarget and strsub(playerTarget, 1, 2) ~= "|K" and strupper(playerTarget) or playerTarget
	end
end

-- Dedup cache: prevent double-processing when addons like WhisperPop
-- re-invoke event filters manually after WoW already processed them
local processedLines = {}
local processedCount = 0
local PROCESSED_LINES_MAX = 200

-- Chat event filter: format message, respect window settings, use correct colors
local function ChatMsgFilter(self, event, msg, sender, language, channelString, target, flags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, senderGUID, bnSenderID, isMobile, isSubtitle, hideSenderInLetterbox, suppressRaidIcons)
	-- SECRET (12.0): chat payload can be opaque under messaging lockdown.
	if not msg or K.IsSecret(msg) then
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
			table.wipe(processedLines)
			processedCount = 0
		end
	end

	-- Per-window visibility check
	local chatType = strsub(event, 10)
	local chatGroup = GetChatCategory(chatType)
	local channelLength = strlen(channelString)
	local chatTarget

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
		chatTarget = GetChatTarget(chatGroup, sender, channelIndex)
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

	local coloredName = GetDecoratedSenderName(event, msg, sender, language, channelString, target, flags, zoneChannelID, channelIndex, channelBaseName, languageID, lineID, senderGUID, bnSenderID, isMobile)
	local pflag = GetPFlag(flags, zoneChannelID, channelIndex)

	local playerLink
	if chatType == "BN_WHISPER" or chatType == "BN_WHISPER_INFORM" then
		playerLink = GetBNPlayerLink(sender, "[" .. coloredName .. "]", bnSenderID, lineID, chatGroup, 0)
	else
		playerLink = GetPlayerLink(sender, "[" .. coloredName .. "]", lineID, chatGroup, 0)
	end

	msg = gsub(msg, "%%", "%%%%")
	msg = ReplaceIconAndGroupExpressions(msg, suppressRaidIcons)
	msg = RemoveExtraSpaces(msg)

	local outMsg = format(formatKey .. msg, pflag .. playerLink)

	-- Add channel prefix for custom channels
	if channelLength > 0 then
		local channelName = ResolvePrefixedChannelName(channelString)
		if channelName then
			outMsg = "|Hchannel:channel:" .. (channelIndex or 0) .. "|h[" .. channelName .. "]|h " .. outMsg
		end
	end

	-- Apply timestamp
	if C["Chat"].TimestampFormat > 1 then
		local locTime, realmTime = GetCurrentTime()
		local timeStamp = BetterDate(K.GreyColor .. timestampFormat[C["Chat"].TimestampFormat] .. "|r", realmTime or locTime)
		outMsg = timeStamp .. outMsg
	end

	if isCN then
		outMsg = gsub(outMsg, cnPattern, KillCNColon)
	end
	outMsg = gsub(outMsg, matchPattern, AbbrChannelName)

	-- Apply custom whisper coloring
	if C["Chat"].WhisperColor and (chatType == "WHISPER_INFORM" or chatType == "BN_WHISPER_INFORM") then
		info = { r = 0.6274, g = 0.3231, b = 0.6274, id = info.id }
	end

	self:AddMessage(outMsg, info.r, info.g, info.b, info.id)

	-- Fix whisper reply
	if chatType == "WHISPER" or chatType == "BN_WHISPER" then
		SetLastTellTarget(sender, chatType)
		if not self.tellTimer or (GetTime() > self.tellTimer) then
			if SOUNDKIT and SOUNDKIT.TELL_MESSAGE then
				PlaySound(SOUNDKIT.TELL_MESSAGE)
			else
				PlaySound(3081) -- fallback to standard tell sound ID
			end
		end
		self.tellTimer = GetTime() + (ChatFrameConstants.WhisperSoundAlertCooldown or 0)
		if FlashClientIcon then
			FlashClientIcon()
		end
	end
	FlashTabIfNotShown(self, info, chatType, chatGroup, chatTarget)

	return true
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateChatRename()
	-- REASON: Sets up global chat filters and initiates chat frame renaming.
	local COME = rawget(_G, "L_CHAT_COME_ONLINE") or "has come |cff298F00online|r."
	local GONE = rawget(_G, "L_CHAT_GONE_OFFLINE") or "has gone |cffff0000offline|r."

	local function systemFilter(_, _, msg, ...)
		-- SECRET (12.0): CHAT_MSG_SYSTEM text can be locked down; gsub throws.
		if not msg or K.IsSecret(msg) then
			return
		end
		-- REASON: Formats "friend came online/offline" messages for a cleaner aesthetic.
		msg = gsub(msg, "%%|Hplayer:([^|]+)%%|h%%[([^%%]]+)%%]%%|h has come online%%.", function(player, name)
			return "|Hplayer:" .. player .. "|h[" .. name .. "]|h " .. COME
		end)
		msg = gsub(msg, "%%[([^%%]]+)%%] has gone offline%%.", function(name)
			return "[" .. name .. "] " .. GONE
		end)
		return false, msg, ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", systemFilter)

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
