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
local _G = _G
local BetterDate = _G.BetterDate
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime.GetCurrentCalendarTime
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local INTERFACE_ACTION_BLOCKED = _G.INTERFACE_ACTION_BLOCKED
local date = _G.date
local rawget = _G.rawget
local string_find = string.find
local string_gsub = string.gsub
local table_insert = table.insert
local time = time
local tonumber = tonumber

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local NUM_CHAT_WINDOWS = rawget(_G, "NUM_CHAT_WINDOWS") or 10
local rewritePatterns

-- REASON: Safely retrieve Blizzard strings without triggering taint or leaking globals.
local CHAT_BN_WHISPER_GET_T = rawget(_G, "CHAT_BN_WHISPER_GET")
local CHAT_BN_WHISPER_INFORM_GET_T = rawget(_G, "CHAT_BN_WHISPER_INFORM_GET")
local CHAT_FLAG_AFK_T = rawget(_G, "CHAT_FLAG_AFK")
local CHAT_FLAG_DND_T = rawget(_G, "CHAT_FLAG_DND")
local CHAT_FLAG_GM_T = rawget(_G, "CHAT_FLAG_GM")
local CHAT_GUILD_GET_T = rawget(_G, "CHAT_GUILD_GET")
local CHAT_INSTANCE_CHAT_GET_T = rawget(_G, "CHAT_INSTANCE_CHAT_GET")
local CHAT_INSTANCE_CHAT_LEADER_GET_T = rawget(_G, "CHAT_INSTANCE_CHAT_LEADER_GET")
local CHAT_OFFICER_GET_T = rawget(_G, "CHAT_OFFICER_GET")
local CHAT_PARTY_GET_T = rawget(_G, "CHAT_PARTY_GET")
local CHAT_PARTY_GUIDE_GET_T = rawget(_G, "CHAT_PARTY_GUIDE_GET")
local CHAT_PARTY_LEADER_GET_T = rawget(_G, "CHAT_PARTY_LEADER_GET")
local CHAT_RAID_GET_T = rawget(_G, "CHAT_RAID_GET")
local CHAT_RAID_LEADER_GET_T = rawget(_G, "CHAT_RAID_LEADER_GET")
local CHAT_RAID_WARNING_GET_T = rawget(_G, "CHAT_RAID_WARNING_GET")
local CHAT_SAY_GET_T = rawget(_G, "CHAT_SAY_GET")
local CHAT_WHISPER_GET_T = rawget(_G, "CHAT_WHISPER_GET")
local CHAT_WHISPER_INFORM_GET_T = rawget(_G, "CHAT_WHISPER_INFORM_GET")
local CHAT_YELL_GET_T = rawget(_G, "CHAT_YELL_GET")

local TIMESTAMP_FORMATS = {
	[2] = "[%I:%M %p] ",
	[3] = "[%I:%M:%S %p] ",
	[4] = "[%H:%M] ",
	[5] = "[%H:%M:%S] ",
}

-- ---------------------------------------------------------------------------
-- Utility Functions
-- ---------------------------------------------------------------------------
local function getCurrentTime()
	-- REASON: Returns both local and realm time to support diverse timestamp configurations.
	local locTime = time()
	local realmCalendar = not GetCVarBool("timeMgrUseLocalTime") and C_DateAndTime_GetCurrentCalendarTime()

	local realmTime
	if realmCalendar then
		realmTime = time({
			year = realmCalendar.year,
			month = realmCalendar.month,
			day = realmCalendar.monthDay,
			hour = realmCalendar.hour,
			min = realmCalendar.minute,
			sec = tonumber(date("%S")),
		})
	end

	return locTime, realmTime
end

local function escapeForPattern(text)
	-- REASON: Escapes magic characters to allow safe use of Blizzard strings in Lua patterns.
	return (string_gsub(text, "([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1"))
end

local function buildTemplatePattern(template)
	-- REASON: Anchors at start and captures %s to allow non-tainting replacement of chat prefixes.
	local pattern = "^" .. escapeForPattern(template)
	pattern = string_gsub(pattern, "%%%%s", "(.-)")
	return pattern
end

-- ---------------------------------------------------------------------------
-- Rewrite Engine
-- ---------------------------------------------------------------------------
local function initRewritePatterns()
	-- REASON: Pre-calculates rewrite patterns only once to minimize per-message overhead.
	if rewritePatterns then
		return
	end

	rewritePatterns = {}

	-- Whisper prefixes
	if CHAT_WHISPER_INFORM_GET_T then
		table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_WHISPER_INFORM_GET_T), repl = (L["To"] .. " %1: ") })
	end
	if CHAT_WHISPER_GET_T then
		table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_WHISPER_GET_T), repl = (L["From"] .. " %1: ") })
	end
	if CHAT_BN_WHISPER_INFORM_GET_T then
		table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_BN_WHISPER_INFORM_GET_T), repl = (L["To"] .. " %1: ") })
	end
	if CHAT_BN_WHISPER_GET_T then
		table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_BN_WHISPER_GET_T), repl = (L["From"] .. " %1: ") })
	end

	-- Say / Yell prefixes
	if CHAT_SAY_GET_T then
		table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_SAY_GET_T), repl = "|Hchannel:SAY|h[S]|h %1: " })
	end
	if CHAT_YELL_GET_T then
		table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_YELL_GET_T), repl = "|Hchannel:YELL|h[Y]|h %1: " })
	end

	if not C["Chat"].OldChatNames then
		-- Channel tags
		if CHAT_GUILD_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_GUILD_GET_T), repl = "|Hchannel:GUILD|h[G]|h %1: " })
		end
		if CHAT_OFFICER_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_OFFICER_GET_T), repl = "|Hchannel:OFFICER|h[O]|h %1: " })
		end
		if CHAT_RAID_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_RAID_GET_T), repl = "|Hchannel:RAID|h[R]|h %1: " })
		end
		if CHAT_RAID_WARNING_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_RAID_WARNING_GET_T), repl = "[RW] %1: " })
		end
		if CHAT_RAID_LEADER_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_RAID_LEADER_GET_T), repl = "|Hchannel:RAID|h[RL]|h %1: " })
		end
		if CHAT_PARTY_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_PARTY_GET_T), repl = "|Hchannel:PARTY|h[P]|h %1: " })
		end
		if CHAT_PARTY_LEADER_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_PARTY_LEADER_GET_T), repl = "|Hchannel:PARTY|h[PL]|h %1: " })
		end
		if CHAT_PARTY_GUIDE_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_PARTY_GUIDE_GET_T), repl = "|Hchannel:PARTY|h[PG]|h %1: " })
		end
		if CHAT_INSTANCE_CHAT_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_INSTANCE_CHAT_GET_T), repl = "|Hchannel:INSTANCE|h[I]|h %1: " })
		end
		if CHAT_INSTANCE_CHAT_LEADER_GET_T then
			table_insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_INSTANCE_CHAT_LEADER_GET_T), repl = "|Hchannel:INSTANCE|h[IL]|h %1: " })
		end

		-- Flags
		if CHAT_FLAG_AFK_T then
			table_insert(rewritePatterns, { pattern = "^" .. escapeForPattern(CHAT_FLAG_AFK_T), repl = "[AFK]: " })
		end
		if CHAT_FLAG_DND_T then
			table_insert(rewritePatterns, { pattern = "^" .. escapeForPattern(CHAT_FLAG_DND_T), repl = "[DND]: " })
		end
		if CHAT_FLAG_GM_T then
			table_insert(rewritePatterns, { pattern = "^" .. escapeForPattern(CHAT_FLAG_GM_T), repl = "[GM]: " })
		end
	end
end

local function applyRewrites(text)
	-- REASON: Sequentially tests all rewrite patterns against the message text.
	initRewritePatterns()
	for i = 1, #rewritePatterns do
		local entry = rewritePatterns[i]
		local replaced, count = string_gsub(text, entry.pattern, entry.repl, 1)
		if count > 0 then
			return replaced
		end
	end
	return text
end

-- ---------------------------------------------------------------------------
-- AddMessage Processor
-- ---------------------------------------------------------------------------
function Module:SetupChannelNames(text, ...)
	-- REASON: Intercepts AddMessage to apply custom formatting (timestamps, renames, colors).
	if string_find(text, INTERFACE_ACTION_BLOCKED) and not K.isDeveloper then
		return
	end

	local r, g, b = ...
	-- REASON: Applies custom whisper coloring if enabled in the configuration.
	if C["Chat"].WhisperColor and string_find(text, L["To"] .. " |H[BN]*player.+%]") then
		r, g, b = 0.6274, 0.3231, 0.6274
	end

	if C["Chat"].TimestampFormat > 1 then
		local locTime, realmTime = getCurrentTime()
		local defaultTimestamp = GetCVar("showTimestamps")

		if defaultTimestamp == "none" then
			defaultTimestamp = nil
		end

		-- REASON: Strips Blizzard's default timestamps to avoid redundant dual-timestamps.
		local oldTimeStamp = defaultTimestamp and string_gsub(BetterDate(defaultTimestamp, locTime), "%[([^]]*)%]", "%%[%1%%]")
		if oldTimeStamp then
			text = string_gsub(text, oldTimeStamp, "")
		end

		local timeStamp = BetterDate(K.GreyColor .. TIMESTAMP_FORMATS[C["Chat"].TimestampFormat] .. "|r", realmTime or locTime)
		text = timeStamp .. text
	end

	-- WARNING: Non-tainting string rewrites are applied here to avoid mutating Blizzard's global strings.
	text = applyRewrites(text)

	if not C["Chat"].OldChatNames then
		text = string_gsub(text, "|h%[(%d+)%..-%]|h", "|h[%1]|h")
	end

	return self.oldAddMessage(self, text, r, g, b)
end

local function renameChatFrames()
	-- REASON: Injects our custom AddMessage handler into all active chat windows.
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame" .. i]
			if chatFrame and chatFrame.AddMessage ~= Module.SetupChannelNames then
				if not chatFrame.oldAddMessage then
					chatFrame.oldAddMessage = chatFrame.AddMessage
				end
				chatFrame.AddMessage = Module.SetupChannelNames
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateChatRename()
	-- REASON: Sets up global chat filters and initiates chat frame renaming.
	local COME = rawget(_G, "L_CHAT_COME_ONLINE") or "has come |cff298F00online|r."
	local GONE = rawget(_G, "L_CHAT_GONE_OFFLINE") or "has gone |cffff0000offline|r."

	local function systemFilter(_, _, msg, ...)
		-- REASON: Formats "friend came online/offline" messages for a cleaner aesthetic.
		msg = string_gsub(msg, "%%|Hplayer:([^|]+)%%|h%%[([^%%]]+)%%]%%|h has come online%%.", function(player, name)
			return "|Hplayer:" .. player .. "|h[" .. name .. "]|h " .. COME
		end)
		msg = string_gsub(msg, "%%[([^%%]]+)%%] has gone offline%%.", function(name)
			return "[" .. name .. "] " .. GONE
		end)
		return false, msg, ...
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", systemFilter)

	renameChatFrames()
end
