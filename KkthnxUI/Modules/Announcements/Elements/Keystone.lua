local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

-- Localize WoW API functions
local strlower = string.lower
local GetTime = GetTime
local SendChatMessage = SendChatMessage
local C_Container_GetContainerItemID = C_Container.GetContainerItemID
local C_Container_GetContainerItemLink = C_Container.GetContainerItemLink
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Item_IsItemKeystoneByID = C_Item.IsItemKeystoneByID
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG

-- Constants and variables
local COOLDOWN_DURATION = 30
local lastKeystoneMessageTime = 0
local lastKeystoneLinkTime = 0
local keystoneCache = {}

-- Helper function to get keystone link
local function getKeystoneLink()
	for bagIndex = 0, NUM_BAG_SLOTS do
		for slotIndex = 1, C_Container_GetContainerNumSlots(bagIndex) do
			local itemID = C_Container_GetContainerItemID(bagIndex, slotIndex)
			if itemID and C_Item_IsItemKeystoneByID(itemID) then
				return C_Container_GetContainerItemLink(bagIndex, slotIndex)
			end
		end
	end
end

-- Helper function to send keystone link to a specific channel
local function sendKeystoneLink(channel)
	local link = getKeystoneLink()
	if link then
		SendChatMessage(link, channel)
	end
end

-- Main function to handle keystone announcements
function Module.Keystone(event)
	local mapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus_GetOwnedKeystoneLevel()

	if event == "PLAYER_ENTERING_WORLD" then
		keystoneCache.mapID = mapID
		keystoneCache.keystoneLevel = keystoneLevel
	elseif event == "CHALLENGE_MODE_COMPLETED" or event == "ITEM_CHANGED" then
		if keystoneCache.mapID ~= mapID or keystoneCache.keystoneLevel ~= keystoneLevel then
			keystoneCache.mapID = mapID
			keystoneCache.keystoneLevel = keystoneLevel

			local link = getKeystoneLink()
			if link then
				local message = string.gsub("My new keystone is %keystone%.", "%%keystone%%", link)
				K.Delay(1, function()
					if IsPartyLFG() then
						SendChatMessage(message, "INSTANCE_CHAT")
					elseif IsInGroup() then
						SendChatMessage(message, "PARTY")
					end
				end)
			end
		end
	end
end

function Module:KeystoneLink(channelType, _, text, sender)
	local currentTime = GetTime()
	if currentTime - lastKeystoneMessageTime < 1 then
		return
	end

	if currentTime - lastKeystoneLinkTime < COOLDOWN_DURATION then
		return
	end

	if strlower(text or "") == "!keys" then
		if channelType then
			lastKeystoneLinkTime = currentTime
			lastKeystoneMessageTime = GetTime()
			K.Delay(1, function()
				sendKeystoneLink(channelType)
			end)
		end
	end
end

-- Function to set up the keystone announcement system
function Module:CreateKeystoneAnnounce()
	if C_AddOns.IsAddOnLoaded("MythicKeyReporter") or not C["Announcements"].KeystoneAlert then
		K:UnregisterEvent("CHAT_MSG_PARTY", Module.KeystoneLink)
		K:UnregisterEvent("CHAT_MSG_PARTY_LEADER", Module.KeystoneLink)
		K:UnregisterEvent("CHAT_MSG_GUILD", Module.KeystoneLink)

		K:UnregisterEvent("ITEM_CHANGED", Module.Keystone)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.Keystone)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", Module.Keystone)
		return
	end

	K:RegisterEvent("CHAT_MSG_PARTY", function(...)
		Module:KeystoneLink("PARTY", ...)
	end)

	K:RegisterEvent("CHAT_MSG_PARTY_LEADER", function(...)
		Module:KeystoneLink("PARTY", ...)
	end)

	K:RegisterEvent("CHAT_MSG_GUILD", function(...)
		Module:KeystoneLink("GUILD", ...)
	end)

	K:RegisterEvent("ITEM_CHANGED", Module.Keystone)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Keystone)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.Keystone)
end
