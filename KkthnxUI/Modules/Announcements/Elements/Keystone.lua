local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

local gsub = gsub

local GetContainerItemID = GetContainerItemID
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots

local C_Item_IsItemKeystoneByID = C_Item.IsItemKeystoneByID
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel

local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local cache = {}

function Module:SetupKeystoneAnnounce(event)
	local mapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus_GetOwnedKeystoneLevel()

	if event == "PLAYER_ENTERING_WORLD" then
		print(event)
		cache.mapID = mapID
		cache.keystoneLevel = keystoneLevel
	elseif event == "CHALLENGE_MODE_COMPLETED" then
		print(event)
		if cache.mapID ~= mapID or cache.keystoneLevel ~= keystoneLevel then
			cache.mapID = mapID
			cache.keystoneLevel = keystoneLevel
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

function Module:CreateKeystoneAnnounce()
	if not C["Announcements"].KeystoneAlert then
		return
	end

	K:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		C_Timer.After(2, Module.SetupKeystoneAnnounce)
	end)

	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", function()
		C_Timer.After(2, Module.SetupKeystoneAnnounce)
	end)
end
