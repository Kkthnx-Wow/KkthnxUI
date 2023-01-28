local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Chat")

local string_find = string.find
local string_gsub = string.gsub

local BetterDate = BetterDate
local INTERFACE_ACTION_BLOCKED = INTERFACE_ACTION_BLOCKED
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime

local timestampFormat = {
	[2] = "[%I:%M %p] ",
	[3] = "[%I:%M:%S %p] ",
	[4] = "[%H:%M] ",
	[5] = "[%H:%M:%S] ",
}

-- Get the current time in both local and realm time
-- @return locTime the current local time
-- @return realmTime the current realm time
local function GetCurrentTime()
	-- Get the current local time
	local locTime = time()

	-- Check if the realm time is being used instead of local time
	local realmTime = not GetCVarBool("timeMgrUseLocalTime") and C_DateAndTime_GetCurrentCalendarTime()

	-- If realm time is being used, format the time values to match the format of the local time
	if realmTime then
		realmTime.day = realmTime.monthDay
		realmTime.min = realmTime.minute
		realmTime.sec = date("%S") -- no sec value for realm time, so use the current sec value
		realmTime = time(realmTime)
	end

	return locTime, realmTime
end

function Module:SetupChannelNames(text, ...)
	-- Block the text if it's an interface action blocked message and the player is not a developer
	if string_find(text, INTERFACE_ACTION_BLOCKED) and not K.isDeveloper then
		return
	end

	-- Get the color values for the text
	local r, g, b = ...

	-- Check if whisper color is enabled and adjust the color of whispers
	if C["Chat"].WhisperColor and string_find(text, L["To"] .. " |H[BN]*player.+%]") then
		r, g, b = r * 0.7, g * 0.7, b * 0.7
	end

	-- Add timestamp to the text
	if C["Chat"].TimestampFormat.Value > 1 then
		local locTime, realmTime = GetCurrentTime()

		-- Remove the default timestamp
		local defaultTimestamp = GetCVar("showTimestamps")
		if defaultTimestamp == "none" then
			defaultTimestamp = nil
		end
		local oldTimeStamp = defaultTimestamp and gsub(BetterDate(defaultTimestamp, locTime), "%[([^]]*)%]", "%%[%1%%]")
		if oldTimeStamp then
			text = gsub(text, oldTimeStamp, "")
		end

		-- Add the custom timestamp
		local timeStamp = BetterDate(K.GreyColor .. timestampFormat[C["Chat"].TimestampFormat.Value] .. "|r", realmTime or locTime)
		text = timeStamp .. text
	end

	-- Check if the old chat names format is enabled
	if C["Chat"].OldChatNames then
		-- Use the old format for the chat names
		return self.oldAddMsg(self, text, r, g, b)
	else
		-- Use the new format for the chat names
		return self.oldAddMsg(self, string_gsub(text, "|h%[(%d+)%..-%]|h", "|h[%1]|h"), r, g, b)
	end
end

function Module:CreateChatRename()
	for i = 1, _G.NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame" .. i]
			chatFrame.oldAddMsg = chatFrame.AddMessage
			chatFrame.AddMessage = Module.SetupChannelNames
		end
	end

	-- Online/Offline
	_G.ERR_FRIEND_ONLINE_SS = string_gsub(_G.ERR_FRIEND_ONLINE_SS, "%]%|h", "]|h|cff00c957")
	_G.ERR_FRIEND_OFFLINE_S = string_gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "%%s|cffff7f50")

	-- Whisper
	_G.CHAT_WHISPER_INFORM_GET = L["To"] .. " %s "
	_G.CHAT_WHISPER_GET = L["From"] .. " %s "
	_G.CHAT_BN_WHISPER_INFORM_GET = L["To"] .. " %s "
	_G.CHAT_BN_WHISPER_GET = L["From"] .. " %s "

	-- Say/Yell
	_G.CHAT_SAY_GET = "%s "
	_G.CHAT_YELL_GET = "%s "

	if C["Chat"].OldChatNames then
		return
	end

	-- Guild
	_G.CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h %s "
	_G.CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[O]|h %s "

	-- Raid
	_G.CHAT_RAID_GET = "|Hchannel:RAID|h[R]|h %s "
	_G.CHAT_RAID_WARNING_GET = "[RW] %s "
	_G.CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[RL]|h %s "

	-- Party
	_G.CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h %s "
	_G.CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|h[PL]|h %s "
	_G.CHAT_PARTY_GUIDE_GET = "|Hchannel:PARTY|h[PG]|h %s "

	-- Instance
	_G.CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE|h[I]|h %s "
	_G.CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE|h[IL]|h %s "

	-- Flags
	_G.CHAT_FLAG_AFK = "[AFK] "
	_G.CHAT_FLAG_DND = "[DND] "
	_G.CHAT_FLAG_GM = "[GM] "
end
