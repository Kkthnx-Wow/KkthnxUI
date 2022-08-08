local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local _G = _G
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local IsAddOnLoaded = _G.IsAddOnLoaded
local CursorHasItem = _G.CursorHasItem
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS or 4

function Module:SetupAutoKeystone()
	for container = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots = GetContainerNumSlots(container)
		for slot = 1, slots do
			local _, _, _, _, _, _, slotLink = GetContainerItemInfo(container, slot)
			if slotLink and slotLink:match("|Hkeystone:") then
				PickupContainerItem(container, slot)
				if CursorHasItem() then
					C_ChallengeMode.SlotKeystone()
					-- CloseAllBags() -- Idk if we want to force close the bags on the user.
					break
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
	if IsAddOnLoaded("AutoKeystone") or IsAddOnLoaded("QuickKeystone") then
		K.Print("already provides an auomation module for keystone. You can find this module in Automation > AutoKeystone")
	end

	if not C["Automation"].AutoKeystone or IsAddOnLoaded("AngryKeystones") then
		return
	end

	K:RegisterEvent("ADDON_LOADED", Module.LoadAutoKeystone)
end
