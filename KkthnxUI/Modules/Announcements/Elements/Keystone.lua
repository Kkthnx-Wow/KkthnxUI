local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

local _G = _G
local gsub = _G.gsub

local C_Item_IsItemKeystoneByID = _G.C_Item.IsItemKeystoneByID
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = _G.C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = _G.C_MythicPlus.GetOwnedKeystoneLevel
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerNumSlots = _G.GetContainerNumSlots
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS or 4

local keystoneCache = {}

function Module.SetupKeystoneAnnounce(event)
	local mapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus_GetOwnedKeystoneLevel()

	if event == "PLAYER_ENTERING_WORLD" then
		K.Print("SetupKeystoneAnnounce", event)
		keystoneCache.mapID = mapID
		keystoneCache.keystoneLevel = keystoneLevel
	elseif event == "CHALLENGE_MODE_COMPLETED" then
		K.Print("SetupKeystoneAnnounce", event)
		if keystoneCache.mapID ~= mapID or keystoneCache.keystoneLevel ~= keystoneLevel then
			keystoneCache.mapID = mapID
			keystoneCache.keystoneLevel = keystoneLevel
			for bagIndex = 0, NUM_BAG_SLOTS do
				for slotIndex = 1, GetContainerNumSlots(bagIndex) do
					local itemID = GetContainerItemID(bagIndex, slotIndex)
					if itemID and C_Item_IsItemKeystoneByID(itemID) then
						local message = gsub("My new keystone is %keystone%.", "%%keystone%%", GetContainerItemLink(bagIndex, slotIndex))
						SendChatMessage(message, "PARTY")
					end
				end
			end
		end
	end
end

function Module.PEWKeystoneAnnounce()
	C_Timer.After(2, Module.SetupKeystoneAnnounce)
end

function Module.CMCKeystoneAnnounce()
	C_Timer.After(2, Module.SetupKeystoneAnnounce)
end

function Module:CreateKeystoneAnnounce()
	if not C["Announcements"].KeystoneAlert then
		return
	end

	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.PEWKeystoneAnnounce)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.CMCKeystoneAnnounce)
end
