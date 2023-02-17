local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

local gsub = gsub

local C_Item_IsItemKeystoneByID = C_Item.IsItemKeystoneByID
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel
local GetContainerItemID = GetContainerItemID
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local NUM_BAG_SLOTS = NUM_BAG_SLOTS or 4

local keystoneCache = {}

function Module.SetupKeystoneAnnounce(event)
	-- Get the current mapID and keystoneLevel for the player
	local mapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	local keystoneLevel = C_MythicPlus_GetOwnedKeystoneLevel()

	-- Check if the event is "PLAYER_ENTERING_WORLD"
	if event == "PLAYER_ENTERING_WORLD" then
		-- K.Print("SetupKeystoneAnnounce", event)
		-- Set the initial values for keystoneCache table
		keystoneCache.mapID = mapID
		keystoneCache.keystoneLevel = keystoneLevel
	-- Check if the event is "CHALLENGE_MODE_COMPLETED"
	elseif event == "CHALLENGE_MODE_COMPLETED" then
		-- K.Print("SetupKeystoneAnnounce", event)
		-- Check if the mapID or keystoneLevel has changed from previous value
		if keystoneCache.mapID ~= mapID or keystoneCache.keystoneLevel ~= keystoneLevel then
			keystoneCache.mapID = mapID
			keystoneCache.keystoneLevel = keystoneLevel
			-- Iterate through all the bags and slots of player's inventory
			for bagIndex = 0, NUM_BAG_SLOTS do
				for slotIndex = 1, GetContainerNumSlots(bagIndex) do
					local itemID = GetContainerItemID(bagIndex, slotIndex)
					-- Check if item is a keystone
					if itemID and C_Item_IsItemKeystoneByID(itemID) then
						-- Construct the message using the item link
						local message = gsub("My new keystone is %keystone%.", "%%keystone%%", GetContainerItemLink(bagIndex, slotIndex))
						-- Send the message to party
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
