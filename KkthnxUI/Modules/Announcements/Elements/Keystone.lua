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
function Module:Keystone(event)
	local currentTime = GetTime()
	if currentTime - lastKeystoneMessageTime < COOLDOWN_DURATION then
		return
	end
	lastKeystoneMessageTime = currentTime

	local mapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus_GetOwnedKeystoneLevel()

	if Module.keystoneCache.mapID ~= mapID or Module.keystoneCache.keystoneLevel ~= keystoneLevel then
		Module.keystoneCache.mapID = mapID
		Module.keystoneCache.keystoneLevel = keystoneLevel

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

-- Function to handle keystone link requests
function Module:KeystoneLink(message, sender)
	local currentTime = GetTime()
	if currentTime - lastKeystoneLinkTime < COOLDOWN_DURATION then
		return
	end
	lastKeystoneLinkTime = currentTime

	if strlower(sender) == "!keys" then
		local channel
		if message == "CHAT_MSG_PARTY" or message == "CHAT_MSG_PARTY_LEADER" then
			channel = "PARTY"
		elseif message == "CHAT_MSG_GUILD" then
			channel = "GUILD"
		elseif message == "CHAT_MSG_OFFICER" then
			channel = "OFFICER"
		end

		if channel then
			K.Delay(1, function()
				sendKeystoneLink(channel)
			end)
		end
	end
end

-- Function to set up the keystone announcement system
function Module:CreateKeystoneAnnounce()
	-- Check if MythicKeyReporter is loaded or if KeystoneAlert is disabled
	if C_AddOns.IsAddOnLoaded("MythicKeyReporter") or not C["Announcements"].KeystoneAlert then
		-- Unregister events if the feature is disabled
		K:UnregisterEvent("CHAT_MSG_PARTY", Module.KeystoneLink)
		K:UnregisterEvent("CHAT_MSG_PARTY_LEADER", Module.KeystoneLink)
		K:UnregisterEvent("CHAT_MSG_GUILD", Module.KeystoneLink)
		K:UnregisterEvent("CHAT_MSG_OFFICER", Module.KeystoneLink)
		K:UnregisterEvent("ITEM_CHANGED", Module.Keystone)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.Keystone)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", Module.Keystone)
		return
	end

	-- Initialize keystone cache
	Module.keystoneCache = Module.keystoneCache or {}

	-- Register events if the feature is enabled
	K:RegisterEvent("CHAT_MSG_PARTY", Module.KeystoneLink)
	K:RegisterEvent("CHAT_MSG_PARTY_LEADER", Module.KeystoneLink)
	K:RegisterEvent("CHAT_MSG_GUILD", Module.KeystoneLink)
	K:RegisterEvent("CHAT_MSG_OFFICER", Module.KeystoneLink)
	K:RegisterEvent("ITEM_CHANGED", Module.Keystone)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Keystone)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.Keystone)
end
