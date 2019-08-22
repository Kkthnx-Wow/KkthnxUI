local K, _, L = unpack(select(2, ...))
local Module = K:NewModule("VersionCheck")

local _G = _G
local gsub = _G.gsub
local tonumber = _G.tonumber

local C_ChatInfo_RegisterAddonMessagePrefix = _G.C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = _G.C_ChatInfo.SendAddonMessage
local CreateFrame = _G.CreateFrame
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetRealmName = _G.GetRealmName
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local IsInRaid = _G.IsInRaid
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE
local SendChatMessage = _G.SendChatMessage
local StaticPopup_Show = _G.StaticPopup_Show
local UnitName = _G.UnitName

local Version = tonumber(GetAddOnMetadata("KkthnxUI", "Version"))
local MyName = UnitName("player") .. "-" .. GetRealmName()
MyName = gsub(MyName, "%s+", "")

local function UIVersionCheck(event, prefix, message, _, sender)
	if (event == "CHAT_MSG_ADDON") then
		if (prefix ~= "KkthnxUIVersion") or (sender == MyName) then
			return
		end

		if (tonumber(message) > Version) then -- We Recieved A Higher Version, We"re Outdated. :(
			StaticPopup_Show("KKTHNXUI_OUTDATED")
			K.Print(L["Miscellaneous"].UIOutdated)
			K:UnregisterEvent("CHAT_MSG_ADDON", UIVersionCheck)
		end
	else
		-- Tell Everyone What Version We Use.
		local Channel

		if IsInRaid() then
			Channel = (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"
		elseif IsInGroup() then
			Channel = (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"
		elseif IsInGuild() then
			Channel = "GUILD"
		end

		if Channel then -- Putting a small delay on the call just to be certain it goes out.
			K.Delay(4, C_ChatInfo_SendAddonMessage, "KkthnxUIVersion", Version, Channel)
		end
	end
end

function Module:OnEnable()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", UIVersionCheck)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", UIVersionCheck)
	K:RegisterEvent("CHAT_MSG_ADDON", UIVersionCheck)

	C_ChatInfo_RegisterAddonMessagePrefix("KkthnxUIVersion")
end

-- Whisper UI Version
local whisperKkthnxUIVersion = CreateFrame("Frame")
whisperKkthnxUIVersion:RegisterEvent("CHAT_MSG_WHISPER")
whisperKkthnxUIVersion:RegisterEvent("CHAT_MSG_BN_WHISPER")
whisperKkthnxUIVersion:SetScript("OnEvent", function(_, event, text, name, ...)
	if text:lower():match("ui_version") then
		if event == "CHAT_MSG_WHISPER" then
			SendChatMessage("KkthnxUI" .. K.Version, "WHISPER", nil, name)
		elseif event == "CHAT_MSG_BN_WHISPER" then
			BNSendWhisper(select(11, ...), "KkthnxUI" .. K.Version)
		end
	end
end)