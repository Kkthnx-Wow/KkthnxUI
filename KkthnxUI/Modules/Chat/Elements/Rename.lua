local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Chat")

local _G = _G
local string_find = _G.string.find
local string_gsub = _G.string.gsub
-- local string_match = _G.string.match

local BetterDate = _G.BetterDate
local INTERFACE_ACTION_BLOCKED = _G.INTERFACE_ACTION_BLOCKED
local time = _G.time

local timestampFormat = {
	[2] = "[%I:%M %p] ",
	[3] = "[%I:%M:%S %p] ",
	[4] = "[%H:%M] ",
	[5] = "[%H:%M:%S] ",
}

function Module:SetupChannelNames(text, ...)
	if string_find(text, INTERFACE_ACTION_BLOCKED) and not K.isDeveloper then
		return
	end

	local r, g, b = ...
	if C["Chat"].WhisperColor and string_find(text, L["To"].." |H[BN]*player.+%]") then
		r, g, b = r * 0.7, g * 0.7, b * 0.7
	end

	-- Dev logo -- Need to make a better logo
	-- local unitName = string_match(text, "|Hplayer:([^|:]+)")
	-- if unitName and K.Devs[unitName] then
	-- 	text = string_gsub(text, "(|Hplayer.+)", "|T".."Interface\\AddOns\\KkthnxUI\\Media\\Chat\\KKUI"..":12:24|t%1")
	-- end

	-- Timestamp
	if C["Chat"].TimestampFormat.Value > 1 then
		local currentTime = time()
		local oldTimeStamp = _G.CHAT_TIMESTAMP_FORMAT and string_gsub(BetterDate(_G.CHAT_TIMESTAMP_FORMAT, currentTime), "%[([^]]*)%]", "%%[%1%%]")
		if oldTimeStamp then
			text = string_gsub(text, oldTimeStamp, "")
		end

		local timeStamp = BetterDate(K.GreyColor..timestampFormat[C["Chat"].TimestampFormat.Value].."|r", currentTime)
		text = timeStamp..text
	end

	if C["Chat"].OldChatNames then
		text = string_gsub(text, "|h%[(%d+)%. 大脚世界频道%]|h", "|h%[%1%. 世界%]|h")
		text = string_gsub(text, "|h%[(%d+)%. 大腳世界頻道%]|h", "|h%[%1%. 世界%]|h")
		return self.oldAddMsg(self, text, r, g, b)
	else
		return self.oldAddMsg(self, string_gsub(text, "|h%[(%d+)%..-%]|h", "|h[%1]|h"), r, g, b)
	end
end

function Module:CreateChatRename()
	for i = 1, _G.NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame"..i]
			chatFrame.oldAddMsg = chatFrame.AddMessage
			chatFrame.AddMessage = Module.SetupChannelNames
		end
	end

	-- Online/Offline
	_G.ERR_FRIEND_ONLINE_SS = string_gsub(_G.ERR_FRIEND_ONLINE_SS, "%]%|h", "]|h|cff00c957")
	_G.ERR_FRIEND_OFFLINE_S = string_gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "%%s|cffff7f50")

	-- Whisper
	_G.CHAT_WHISPER_INFORM_GET = L["To"].." %s "
	_G.CHAT_WHISPER_GET = L["From"].." %s "
	_G.CHAT_BN_WHISPER_INFORM_GET = L["To"].." %s "
	_G.CHAT_BN_WHISPER_GET = L["From"].." %s "

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