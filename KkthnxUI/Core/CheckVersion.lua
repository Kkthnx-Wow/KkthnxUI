local K, C, L = select(2, ...):unpack()

local select, tostring = select, tostring
local gsub = string.gsub
local CreateFrame = CreateFrame
local SendAddonMessage = SendAddonMessage
local UnitName = UnitName
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local SendChatMessage = SendChatMessage
local BNSendWhisper = BNSendWhisper

local MyName = UnitName("player") .. "-" .. GetRealmName()
MyName = gsub(MyName, "%s+", "")

local Version = tostring(GetAddOnMetadata("KkthnxUI", "Version"))

local OnEvent = function(self, event, prefix, message, channel, sender)
	if (event == "CHAT_MSG_ADDON") then
		if (prefix ~= "KkthnxUI") or (sender == MyName) then
			return
		end

		if (tostring(message) > Version) then
			K.Print(L.Misc.UIOutdated)

			self:UnregisterEvent("CHAT_MSG_ADDON")
		end
	elseif (event == "GUILD_ROSTER_UPDATE") then
		if (IsInGuild()) then
			K.Delay(3, SendAddonMessage, "KkthnxUI", Version, "GUILD")
		end
	else
		local Channel

		if (IsInRaid()) then
			Channel = (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"
		elseif (IsInGroup()) then
			Channel = (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"
		end

		if (Channel) then
			K.Delay(3, SendAddonMessage, "KkthnxUI", Version, Channel)
		end
	end
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
EventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
EventFrame:RegisterEvent("CHAT_MSG_ADDON")
EventFrame:SetScript("OnEvent", OnEvent)

RegisterAddonMessagePrefix("KkthnxUI")

local OnWhisper = function(self, event, text, name, ...)
	if (text:lower():match("ui_version")) then
		if (event == "CHAT_MSG_WHISPER") then
			SendChatMessage(K.UIName .. " " .. K.Version, "WHISPER", nil, name)
		elseif (event == "CHAT_MSG_BN_WHISPER") then
			BNSendWhisper(select(11, ...), K.UIName .. " " .. K.Version)
		end
	end
end

local WhisperFrame = CreateFrame("Frame")
WhisperFrame:RegisterEvent("CHAT_MSG_WHISPER")
WhisperFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")
WhisperFrame:SetScript("OnEvent", OnWhisper)
