local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local NUM_BAG_SLOTS = NUM_BAG_SLOTS or 4

local function isKeystone(itemID)
	-- Use GetItemInfo to get the item's class and subclass IDs
	local _, _, _, _, _, _, _, _, _, _, _, classID, subClassID = GetItemInfo(itemID)
	return classID == 5 and subClassID == 1
end

local function useKeystone()
	-- Loop through all bags and slots to find a Keystone
	for container = 0, NUM_BAG_SLOTS do
		local slots = GetContainerNumSlots(container)
		for slot = 1, slots do
			local itemID = GetContainerItemID(container, slot)
			if itemID and isKeystone(itemID) then
				-- Use the Keystone and return true to indicate success
				UseContainerItem(container, slot)
				return true
			end
		end
	end

	-- Return false if no Keystone was found
	return false
end

function Module:SetupAutoKeystone()
	if useKeystone() then
		K.Print("Used Keystone from bag")
	end
end

function Module:LoadAutoKeystone(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		ChallengesKeystoneFrame:HookScript("OnShow", self.SetupAutoKeystone)
		K:UnregisterEvent(event, self.LoadAutoKeystone)
	end
end

function Module:CreateAutoKeystone()
	-- Check if the AngryKeystones addon is loaded or the AutoKeystone option is disabled
	if IsAddOnLoaded("AngryKeystones") or not C["Automation"].AutoKeystone then
		return
	end

	-- Register the ADDON_LOADED event to check for the ChallengesUI addon
	K:RegisterEvent("ADDON_LOADED", self.LoadAutoKeystone, self)
end
