--[[-----------------------------------------------------------------------------
-- Live GUI refresh for bag / bank layout and display toggles.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

local STATUS_KEYS = {
	ColorUnusableItems = true,
	BagsBindOnEquip = true,
	BagsItemLevel = true,
	PetTrash = true,
	ItemFilter = true,
	GatherEmpty = true,
	iLvlToShow = true,
	ShowNewItem = true,
}

local BAG_BAR_KEYS = {
	BagBarSize = true,
	GrowthDirection = true,
	SortDirection = true,
	JustBackpack = true,
	BagBarMouseover = true,
}

local function OnInventorySetting(configPath)
	local key = configPath:match("^Inventory%.(.+)$")
	if not key then
		return
	end

	if STATUS_KEYS[key] then
		Module:UpdateBagStatus()
	elseif BAG_BAR_KEYS[key] then
		if Module.SetSizeAndPositionBagBar then
			Module:SetSizeAndPositionBagBar()
		end
	elseif key == "ReverseSort" then
		Module:UpdateSortOrder()
	elseif key == "GatherEmpty" or key:sub(1, 6) == "Filter" then
		Module:UpdateBagStatus()
	elseif key == "BagsPerRow" or key == "BankPerRow" or key == "BagsWidth" or key == "BankWidth" then
		Module:UpdateBagAnchor()
	elseif key == "IconSize" then
		Module:UpdateBagSize()
	elseif key == "BagBar" then
		if Module.UpdateBagBar then
			Module:UpdateBagBar()
		end
	elseif key == "Enable" then
		Module:SetInventoryEnabled(C["Inventory"].Enable)
	end
end

K:RegisterSettingPrefixCallback("Inventory.", OnInventorySetting)
