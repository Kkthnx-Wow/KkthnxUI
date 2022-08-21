local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local _G = _G

local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER or 0
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local IsAddOnLoaded = _G.IsAddOnLoaded
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS or 4

function Module:SetupAutoKeystone()
	for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = GetContainerNumSlots(container)
		for slot = 1, slots do
			local itemID = select(10, GetContainerItemInfo(container, slot))
			if itemID then
				-- print("itemID", itemID) -- Debug
				local classID, subClassID = select(12, GetItemInfo(itemID))
				if classID and subClassID then
					-- print("classID", classID) -- Debug
					-- print("subClassID", subClassID) -- Debug
					if classID == 5 and subClassID == 1 then
						return UseContainerItem(container, slot)
					end
					break -- We found what we want STOP!
				end
			end
		end
	end
end

function Module.LoadAutoKeystone(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		_G.ChallengesKeystoneFrame:HookScript("OnShow", Module.SetupAutoKeystone)

		K:UnregisterEvent(event, Module.LoadAutoKeystone)
	end
end

function Module:CreateAutoKeystone()
	if not C["Automation"].AutoKeystone or IsAddOnLoaded("AngryKeystones") then
		return
	end

	K:RegisterEvent("ADDON_LOADED", Module.LoadAutoKeystone)
end
