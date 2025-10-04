local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Lua/WoW API locals
local gsub = string.gsub
local strlower = string.lower
local format = string.format
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_GetContainerItemID = C_Container.GetContainerItemID
local C_Container_GetContainerItemLink = C_Container.GetContainerItemLink
local C_Item_IsItemKeystoneByID = C_Item.IsItemKeystoneByID
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG
local SendChatMessage = SendChatMessage
local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local ipairs = ipairs

-- Small cache table for last-known keystone
local keystoneCache = { mapID = 0, level = 0 }

-- Fast bag scan for keystone link
local function GetKeystoneLink()
	for bag = 0, NUM_BAG_SLOTS do
		local numSlots = C_Container_GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local itemID = C_Container_GetContainerItemID(bag, slot)
			if itemID and C_Item_IsItemKeystoneByID(itemID) then
				return C_Container_GetContainerItemLink(bag, slot)
			end
		end
	end
end

-- Decide channel: instance if LFG, else party
local function SendToGroup(message)
	if IsPartyLFG() then
		SendChatMessage(message, "INSTANCE_CHAT")
	elseif IsInGroup() then
		SendChatMessage(message, "PARTY")
	end
end

-- Announce when keystone changes after chest or item change
function Module:AnnounceKeystone(event)
	if not C["Announcements"].KeystoneAlert then
		return
	end

	local mapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local level = C_MythicPlus_GetOwnedKeystoneLevel()

	if event == "PLAYER_ENTERING_WORLD" then
		keystoneCache.mapID = mapID or 0
		keystoneCache.level = level or 0
		return
	end

	if event == "CHALLENGE_MODE_COMPLETED" or event == "ITEM_CHANGED" then
		if (mapID or 0) ~= keystoneCache.mapID or (level or 0) ~= keystoneCache.level then
			keystoneCache.mapID = mapID or 0
			keystoneCache.level = level or 0

			local link = GetKeystoneLink()
			if link then
				-- Prefer a localized format string; fallback to template replacement
				local template = L["My new keystone is %s"] or "My new keystone is %s"
				local message = format(template, link)
				SendToGroup(message)
			end
		end
	end
end

-- Respond to !keys in party/party leader/guild
function Module:OnKeystoneQuery(event, text)
	if not C["Announcements"].KeystoneAlert then
		return
	end
	if not text or strlower(text) ~= "!keys" then
		return
	end

	local link = GetKeystoneLink()
	if not link then
		return
	end

	if event == "CHAT_MSG_PARTY" or event == "CHAT_MSG_PARTY_LEADER" then
		SendChatMessage(link, "PARTY")
	elseif event == "CHAT_MSG_GUILD" then
		SendChatMessage(link, "GUILD")
	end
end

-- Public setup toggler
function Module:CreateKeystoneAnnounce()
	-- Avoid duplicates or conflicts
	if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("MythicKeyReporter") then
		-- Ensure clean state
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.AnnounceKeystone)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", self.AnnounceKeystone)
		K:UnregisterEvent("ITEM_CHANGED", self.AnnounceKeystone)
		K:UnregisterEvent("CHAT_MSG_PARTY", self.OnKeystoneQuery)
		K:UnregisterEvent("CHAT_MSG_PARTY_LEADER", self.OnKeystoneQuery)
		K:UnregisterEvent("CHAT_MSG_GUILD", self.OnKeystoneQuery)
		return
	end

	if C["Announcements"].KeystoneAlert then
		K:RegisterEvent("PLAYER_ENTERING_WORLD", self.AnnounceKeystone)
		K:RegisterEvent("CHALLENGE_MODE_COMPLETED", self.AnnounceKeystone)
		K:RegisterEvent("ITEM_CHANGED", self.AnnounceKeystone)
		K:RegisterEvent("CHAT_MSG_PARTY", self.OnKeystoneQuery)
		K:RegisterEvent("CHAT_MSG_PARTY_LEADER", self.OnKeystoneQuery)
		K:RegisterEvent("CHAT_MSG_GUILD", self.OnKeystoneQuery)
	else
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.AnnounceKeystone)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", self.AnnounceKeystone)
		K:UnregisterEvent("ITEM_CHANGED", self.AnnounceKeystone)
		K:UnregisterEvent("CHAT_MSG_PARTY", self.OnKeystoneQuery)
		K:UnregisterEvent("CHAT_MSG_PARTY_LEADER", self.OnKeystoneQuery)
		K:UnregisterEvent("CHAT_MSG_GUILD", self.OnKeystoneQuery)
	end
end
