local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

-- Localize WoW API functions
local strlower = string.lower
local SendChatMessage = SendChatMessage
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Item_IsItemKeystoneByID = C_Item.IsItemKeystoneByID
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG

-- Constants and variables
local keystoneCache = {}
local messageHistory = {}
local messageInterval = 10
local channelMapping = {
	["CHAT_MSG_PARTY"] = "PARTY",
	["CHAT_MSG_PARTY_LEADER"] = "PARTY",
	["CHAT_MSG_GUILD"] = "GUILD",
}

local function CheckBeforeSend(text, channel)
	local key = text .. "_" .. channel
	for k, v in pairs(messageHistory) do
		if time() > v + messageInterval then
			messageHistory[k] = nil
		end
	end

	if messageHistory[key] and time() < messageHistory[key] + messageInterval then
		return false
	end

	messageHistory[key] = time()
	return true
end

local function SendMessage(text, channel)
	if CheckBeforeSend(text, channel) then
		SendChatMessage(text, channel)
	end
end

-- Helper function to get keystone link
local function GetKeystoneLink()
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container_GetContainerNumSlots(bagIndex) do
			local itemInfo = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
			if itemInfo and C_Item_IsItemKeystoneByID(itemInfo.itemID) then
				return itemInfo.hyperlink
			end
		end
	end
end

-- Main function to handle keystone announcements
local function GetNewKeystone(_, event)
	if not C["Announcements"].KeystoneAlert then
		return
	end

	local mapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus_GetOwnedKeystoneLevel()

	if event == "PLAYER_ENTERING_WORLD" then
		keystoneCache.mapID = mapID
		keystoneCache.keystoneLevel = keystoneLevel
	elseif event == "CHALLENGE_MODE_COMPLETED" or event == "ITEM_CHANGED" then
		if keystoneCache.mapID ~= mapID or keystoneCache.keystoneLevel ~= keystoneLevel then
			keystoneCache.mapID = mapID
			keystoneCache.keystoneLevel = keystoneLevel

			local link = GetKeystoneLink()
			if link then
				local message = string.gsub("My new keystone is %keystone%.", "%%keystone%%", link)
				if IsPartyLFG() then
					SendChatMessage(message, "INSTANCE_CHAT")
				elseif IsInGroup() then
					SendChatMessage(message, "PARTY")
				end
			end
		end
	end
end

local function SendKeystoneLink(_, channelType, text)
	if not C["Announcements"].KeystoneAlert or strlower(text) ~= "!keys" then
		return
	end

	local channel = channelMapping[channelType]
	if channel then
		local link = GetKeystoneLink()
		if link then
			SendMessage(link, channel)
		end
	end
end

-- Function to set up the keystone announcement system
function Module:CreateKeystoneAnnounce()
	if C_AddOns.IsAddOnLoaded("MythicKeyReporter") or not C["Announcements"].KeystoneAlert then
		for _, event in ipairs({
			"CHAT_MSG_PARTY",
			"CHAT_MSG_PARTY_LEADER",
			"CHAT_MSG_GUILD",
			"ITEM_CHANGED",
			"PLAYER_ENTERING_WORLD",
			"CHALLENGE_MODE_COMPLETED",
		}) do
			K:UnregisterEvent(event, GetNewKeystone)
		end
		return
	end

	K:RegisterEvent("CHAT_MSG_PARTY", function(...)
		SendKeystoneLink("PARTY", ...)
	end)
	K:RegisterEvent("CHAT_MSG_PARTY_LEADER", function(...)
		SendKeystoneLink("PARTY", ...)
	end)
	K:RegisterEvent("CHAT_MSG_GUILD", function(...)
		SendKeystoneLink("GUILD", ...)
	end)
	K:RegisterEvent("ITEM_CHANGED", function()
		K.Delay(0.5, GetNewKeystone)
	end)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		K.Delay(2, GetNewKeystone)
	end)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", function()
		K.Delay(2, GetNewKeystone)
	end)
end
