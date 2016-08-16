local K, C, L, _ = select(2, ...):unpack()

local tonumber = tonumber
local lower, match = string.lower, string.match
local print = print
local GetNumPartyMembers = GetNumPartyMembers
local GetNumRaidMembers = GetNumRaidMembers
local CreateFrame = CreateFrame

-- CHECK OUTDATED UI VERSION
local check = function(self, event, prefix, message, channel, sender)
	if event == "CHAT_MSG_ADDON" then
		if prefix ~= "KkthnxUIVersion" or sender == K.Name then return end
		if tonumber(message) ~= nil and tonumber(message) > tonumber(K.Version) then
			print("|cffff0000"..L_MISC_UI_OUTDATED.."|r")
			self:UnregisterEvent("CHAT_MSG_ADDON")
		end
	else
		if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
			SendAddonMessage("KkthnxUIVersion", tonumber(K.Version), "INSTANCE_CHAT")
		elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
			SendAddonMessage("KkthnxUIVersion", tonumber(K.Version), "RAID")
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
			SendAddonMessage("KkthnxUIVersion", tonumber(K.Version), "PARTY")
		elseif IsInGuild() then
			SendAddonMessage("KkthnxUIVersion", tonumber(K.Version), "GUILD")
		end
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:SetScript("OnEvent", check)
RegisterAddonMessagePrefix("KkthnxUIVersion")

-- WHISPER UI VERSION
local Whisper = CreateFrame("Frame")
Whisper:RegisterEvent("CHAT_MSG_Whisper")
Whisper:RegisterEvent("CHAT_MSG_BN_Whisper")
Whisper:SetScript("OnEvent", function(self, event, text, name, ...)
	if text:lower():match("ui_version") or text:lower():match("уи_версия") then
		if event == "CHAT_MSG_Whisper" then
			SendChatMessage("KkthnxUI "..K.Version, "Whisper", nil, name)
		elseif event == "CHAT_MSG_BN_Whisper" then
			BNSendWhisper(select(11, ...), "KkthnxUI "..K.Version)
		end
	end
end)