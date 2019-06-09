local K, C = unpack(select(2, ...))
local Module = K:NewModule("ChatDelayGMOTD")

local _G = _G
local pairs = pairs
local string_len = string.len
local string_split = string.split
local table_insert = table.insert
local table_remove = table.remove

local CHAT_FRAMES = _G.CHAT_FRAMES
local ChatFrame_SystemEventHandler = _G.ChatFrame_SystemEventHandler
local ChatTypeGroup = _G.ChatTypeGroup
local CreateFrame = _G.CreateFrame
local GetGuildRosterMOTD = _G.GetGuildRosterMOTD
local GUILD_MOTD_TEMPLATE = _G.GUILD_MOTD_TEMPLATE
local IsInGuild = _G.IsInGuild

local function applyChatFrameSEH(...)
	return ChatFrame_SystemEventHandler(...)
end

table_remove(ChatTypeGroup.GUILD, 2)
function Module:DelayGMOTD()
	local delay, checks, delayFrame, chat = 0, 0, CreateFrame("Frame")
	table_insert(ChatTypeGroup.GUILD, 2, "GUILD_MOTD")
	delayFrame:SetScript("OnUpdate", function(df, elapsed)
		delay = delay + elapsed
		if delay < 5 then
			return
		end

		local msg = GetGuildRosterMOTD()
		if msg and string_len(msg) > 0 then
			for _, frame in pairs(CHAT_FRAMES) do
				chat = _G[frame]
				if chat and chat:IsEventRegistered("CHAT_MSG_GUILD") then
					applyChatFrameSEH(chat, "GUILD_MOTD", msg)
					chat:RegisterEvent("GUILD_MOTD")
				end
			end
			df:SetScript("OnUpdate", nil)
		else -- 5 seconds can be too fast for the API response. let's try once every 5 seconds (max 5 checks).
			delay, checks = 0, checks + 1
			if checks >= 5 then
				df:SetScript("OnUpdate", nil)
			end
		end
	end)
end

function Module:OnEnable()
	if IsInGuild() then
		if C["Chat"].DelayGMOTD then
			self:DelayGMOTD()

			local a, b = string_split(":", GUILD_MOTD_TEMPLATE)
			if a and b then
				GUILD_MOTD_TEMPLATE = "|cffffffff"..a.."|r:"..b
			end
		end
	end
end