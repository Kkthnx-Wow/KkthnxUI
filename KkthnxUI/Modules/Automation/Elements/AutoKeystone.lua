local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local NUM_BAG_SLOTS = NUM_BAG_SLOTS or 4

local function isKeystone(itemID)
	local class, subclass = select(6, C_Item.GetItemInfo(itemID))
	return class == "Gem" and subclass == "Artifact Relic"
end

local function useKeystone()
	for container = 0, NUM_BAG_SLOTS - 1 do
		for slot = 1, C_Container.GetContainerNumSlots(container) do
			local itemID = C_Container.GetContainerItemID(container, slot)
			if itemID and isKeystone(itemID) then
				C_Container.UseContainerItem(container, slot)
				return true -- Keystone found and used, exit loop
			end
		end
	end
	return false -- No keystone found
end

function Module:SetupAutoKeystone()
	if useKeystone() then
		K.Print(L["Keystone used from bag"])
	end
end

function Module:LoadAutoKeystone(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		ChallengesKeystoneFrame:HookScript("OnShow", function()
			self:SetupAutoKeystone()
		end)
		K:UnregisterEvent(event, self.LoadAutoKeystone)
	end
end

function Module:CreateAutoKeystone()
	if C_AddOns.IsAddOnLoaded("AngryKeystones") or not C["Automation"].AutoKeystone then
		return
	end

	K:RegisterEvent("ADDON_LOADED", self.LoadAutoKeystone, self)
end
