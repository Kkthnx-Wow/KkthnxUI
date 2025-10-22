local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Chat")

local string_find, string_gsub = string.find, string.gsub
local BetterDate = BetterDate
local INTERFACE_ACTION_BLOCKED = INTERFACE_ACTION_BLOCKED
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime

local NUM_CHAT_WINDOWS = rawget(_G or {}, "NUM_CHAT_WINDOWS") or 10

local CHAT_WHISPER_INFORM_GET_T = rawget(_G or {}, "CHAT_WHISPER_INFORM_GET")
local CHAT_WHISPER_GET_T = rawget(_G or {}, "CHAT_WHISPER_GET")
local CHAT_BN_WHISPER_INFORM_GET_T = rawget(_G or {}, "CHAT_BN_WHISPER_INFORM_GET")
local CHAT_BN_WHISPER_GET_T = rawget(_G or {}, "CHAT_BN_WHISPER_GET")
local CHAT_SAY_GET_T = rawget(_G or {}, "CHAT_SAY_GET")
local CHAT_YELL_GET_T = rawget(_G or {}, "CHAT_YELL_GET")

local CHAT_GUILD_GET_T = rawget(_G or {}, "CHAT_GUILD_GET")
local CHAT_OFFICER_GET_T = rawget(_G or {}, "CHAT_OFFICER_GET")
local CHAT_RAID_GET_T = rawget(_G or {}, "CHAT_RAID_GET")
local CHAT_RAID_WARNING_GET_T = rawget(_G or {}, "CHAT_RAID_WARNING_GET")
local CHAT_RAID_LEADER_GET_T = rawget(_G or {}, "CHAT_RAID_LEADER_GET")
local CHAT_PARTY_GET_T = rawget(_G or {}, "CHAT_PARTY_GET")
local CHAT_PARTY_LEADER_GET_T = rawget(_G or {}, "CHAT_PARTY_LEADER_GET")
local CHAT_PARTY_GUIDE_GET_T = rawget(_G or {}, "CHAT_PARTY_GUIDE_GET")
local CHAT_INSTANCE_CHAT_GET_T = rawget(_G or {}, "CHAT_INSTANCE_CHAT_GET")
local CHAT_INSTANCE_CHAT_LEADER_GET_T = rawget(_G or {}, "CHAT_INSTANCE_CHAT_LEADER_GET")

local CHAT_FLAG_AFK_T = rawget(_G or {}, "CHAT_FLAG_AFK")
local CHAT_FLAG_DND_T = rawget(_G or {}, "CHAT_FLAG_DND")
local CHAT_FLAG_GM_T = rawget(_G or {}, "CHAT_FLAG_GM")

local timestampFormat = {
	[2] = "[%I:%M %p] ",
	[3] = "[%I:%M:%S %p] ",
	[4] = "[%H:%M] ",
	[5] = "[%H:%M:%S] ",
}

local IsDeveloper = K.isDeveloper
local WhisperColorEnabled = C["Chat"].WhisperColor
local TimestampFormat = C["Chat"].TimestampFormat

local function GetCurrentTime()
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

-- Non-tainting chat prefix rewrites (avoid mutating Blizzard globals)
local rewritePatterns
local function escapeForPattern(s)
	return (s:gsub("([%%%^%$%(%)%.%[%]%*%+%-%?])", "%%%1"))
end

local function buildTemplatePattern(template)
	-- Anchor at start so we only rewrite the leading prefix once
	local esc = "^" .. escapeForPattern(template)
	-- Replace %s placeholders with non-greedy capture to tolerate links/names
	esc = esc:gsub("%%%%s", "(.-)")
	return esc
end

local function initRewritePatterns()
	if rewritePatterns then
		return
	end

	rewritePatterns = {}

	-- Whisper prefixes
	if CHAT_WHISPER_INFORM_GET_T then
		table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_WHISPER_INFORM_GET_T), repl = (L["To"] .. " %1 ") })
	end
	if CHAT_WHISPER_GET_T then
		table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_WHISPER_GET_T), repl = (L["From"] .. " %1 ") })
	end
	if CHAT_BN_WHISPER_INFORM_GET_T then
		table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_BN_WHISPER_INFORM_GET_T), repl = (L["To"] .. " %1 ") })
	end
	if CHAT_BN_WHISPER_GET_T then
		table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_BN_WHISPER_GET_T), repl = (L["From"] .. " %1 ") })
	end

	-- Say / Yell prefixes
	if CHAT_SAY_GET_T then
		table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_SAY_GET_T), repl = "|Hchannel:SAY|h[S]|h %1 " })
	end
	if CHAT_YELL_GET_T then
		table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_YELL_GET_T), repl = "|Hchannel:YELL|h[Y]|h %1 " })
	end

	if not C["Chat"].OldChatNames then
		-- Channel tags
		if CHAT_GUILD_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_GUILD_GET_T), repl = "|Hchannel:GUILD|h[G]|h %1 " })
		end
		if CHAT_OFFICER_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_OFFICER_GET_T), repl = "|Hchannel:OFFICER|h[O]|h %1 " })
		end
		if CHAT_RAID_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_RAID_GET_T), repl = "|Hchannel:RAID|h[R]|h %1 " })
		end
		if CHAT_RAID_WARNING_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_RAID_WARNING_GET_T), repl = "[RW] %1 " })
		end
		if CHAT_RAID_LEADER_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_RAID_LEADER_GET_T), repl = "|Hchannel:RAID|h[RL]|h %1 " })
		end
		if CHAT_PARTY_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_PARTY_GET_T), repl = "|Hchannel:PARTY|h[P]|h %1 " })
		end
		if CHAT_PARTY_LEADER_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_PARTY_LEADER_GET_T), repl = "|Hchannel:PARTY|h[PL]|h %1 " })
		end
		if CHAT_PARTY_GUIDE_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_PARTY_GUIDE_GET_T), repl = "|Hchannel:PARTY|h[PG]|h %1 " })
		end
		if CHAT_INSTANCE_CHAT_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_INSTANCE_CHAT_GET_T), repl = "|Hchannel:INSTANCE|h[I]|h %1 " })
		end
		if CHAT_INSTANCE_CHAT_LEADER_GET_T then
			table.insert(rewritePatterns, { pattern = buildTemplatePattern(CHAT_INSTANCE_CHAT_LEADER_GET_T), repl = "|Hchannel:INSTANCE|h[IL]|h %1 " })
		end
		-- Flags
		if CHAT_FLAG_AFK_T then
			table.insert(rewritePatterns, { pattern = "^" .. escapeForPattern(CHAT_FLAG_AFK_T), repl = "[AFK] " })
		end
		if CHAT_FLAG_DND_T then
			table.insert(rewritePatterns, { pattern = "^" .. escapeForPattern(CHAT_FLAG_DND_T), repl = "[DND] " })
		end
		if CHAT_FLAG_GM_T then
			table.insert(rewritePatterns, { pattern = "^" .. escapeForPattern(CHAT_FLAG_GM_T), repl = "[GM] " })
		end
	end
end

local function applyRewrites(text)
	initRewritePatterns()
	for i = 1, #rewritePatterns do
		local entry = rewritePatterns[i]
		local replaced, count = text:gsub(entry.pattern, entry.repl, 1)
		if count > 0 then
			return replaced
		end
	end
	return text
end

function Module:SetupChannelNames(text, ...)
	if string_find(text, INTERFACE_ACTION_BLOCKED) and not IsDeveloper then
		return
	end

	local r, g, b = ...
	if WhisperColorEnabled and string_find(text, L["To"] .. " |H[BN]*player.+%]") then
		r, g, b = 0.6274, 0.3231, 0.6274
	end

	if TimestampFormat > 1 then
		local locTime, realmTime = GetCurrentTime()
		local defaultTimestamp = GetCVar("showTimestamps")

		if defaultTimestamp == "none" then
			defaultTimestamp = nil
		end

		local oldTimeStamp = defaultTimestamp and string_gsub(BetterDate(defaultTimestamp, locTime), "%[([^]]*)%]", "%%[%1%%]")
		if oldTimeStamp then
			text = string_gsub(text, oldTimeStamp, "")
		end

		local timeStamp = BetterDate(K.GreyColor .. timestampFormat[TimestampFormat] .. "|r", realmTime or locTime)
		text = timeStamp .. text
	end

	-- Apply safe, non-tainting rewrites instead of mutating globals
	text = applyRewrites(text)

	if not C["Chat"].OldChatNames then
		text = string_gsub(text, "|h%[(%d+)%..-%]|h", "|h[%1]|h")
	end

	return self.oldAddMessage(self, text, r, g, b)
end

local function renameChatFrames()
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame" .. i]
			if chatFrame.AddMessage ~= Module.SetupChannelNames then
				if not chatFrame.oldAddMessage then
					chatFrame.oldAddMessage = chatFrame.AddMessage
				end
				chatFrame.AddMessage = Module.SetupChannelNames
			end
		end
	end
end

function Module:CreateChatRename()
	-- Friend online/offline message overrides (localized if globals exist)
	local COME = rawget(_G, "L_CHAT_COME_ONLINE") or "has come |cff298F00online|r."
	local GONE = rawget(_G, "L_CHAT_GONE_OFFLINE") or "has gone |cffff0000offline|r."
	_G.ERR_FRIEND_ONLINE_SS = "|Hplayer:%s|h[%s]|h " .. COME
	_G.ERR_FRIEND_OFFLINE_S = "[%s] " .. GONE

	renameChatFrames()
end
