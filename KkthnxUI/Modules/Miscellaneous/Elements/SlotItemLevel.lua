local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")
local TT = K:GetModule("Tooltip")

-- Basic Lua functions
local pairs = pairs
local select = select
local next = next
local type = type

-- Unit and item information functions
local UnitGUID = UnitGUID
local GetItemInfo = C_Item.GetItemInfo
local GetSpellInfo = C_Spell.GetSpellInfo
local GetContainerItemLink = C_Container.GetContainerItemLink
local GetInventoryItemLink = GetInventoryItemLink
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

-- Equipment management functions
local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
local EquipmentManager_GetItemInfoByLocation = EquipmentManager_GetItemInfoByLocation

-- Azerite power functions
local C_AzeriteEmpoweredItem_IsPowerSelected = C_AzeriteEmpoweredItem.IsPowerSelected

local inspectSlots = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand",
	"SecondaryHand",
}

function Module:GetSlotAnchor(index)
	if not index then
		return
	end

	if index <= 5 or index == 9 or index == 15 then
		return "BOTTOMLEFT", 40, 20
	elseif index == 16 then
		return "BOTTOMRIGHT", -40, 2
	elseif index == 17 then
		return "BOTTOMLEFT", 40, 2
	else
		return "BOTTOMRIGHT", -40, 20
	end
end

function Module:CreateItemTexture(slot, relF, x, y)
	local icon = slot:CreateTexture()
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	icon.bg = CreateFrame("Frame", nil, slot)
	icon.bg:SetAllPoints(icon)
	icon.bg:SetFrameLevel(3)
	icon.bg:CreateBorder()
	icon.bg:Hide()

	return icon
end

function Module:ItemString_Expand()
	self:SetWidth(0)
end

function Module:ItemString_Collapse()
	self:SetWidth(120)
end

function Module:CreateItemString(frame, strType)
	if frame.fontCreated then
		return
	end

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType .. slot .. "Slot"]
			slotFrame.iLvlText = K.CreateFontString(slotFrame, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
			slotFrame.iLvlText:ClearAllPoints()
			slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)

			local relF, x, y = Module:GetSlotAnchor(index)
			slotFrame.enchantText = K.CreateFontString(slotFrame, 11)
			slotFrame.enchantText:ClearAllPoints()
			slotFrame.enchantText:SetPoint(relF, slotFrame, x, y)
			slotFrame.enchantText:SetJustifyH(strsub(relF, 7))
			slotFrame.enchantText:SetWidth(120)
			slotFrame.enchantText:EnableMouse(true)
			slotFrame.enchantText:HookScript("OnEnter", Module.ItemString_Expand)
			slotFrame.enchantText:HookScript("OnLeave", Module.ItemString_Collapse)
			slotFrame.enchantText:HookScript("OnShow", Module.ItemString_Collapse)

			for i = 1, 10 do
				local offset = (i - 1) * 20 + 5
				local iconX = x > 0 and x + offset or x - offset
				local iconY = index > 15 and 20 or 2
				slotFrame["textureIcon" .. i] = Module:CreateItemTexture(slotFrame, relF, iconX, iconY)
			end
		end
	end

	frame.fontCreated = true
end

local azeriteSlots = {
	[1] = true,
	[3] = true,
	[5] = true,
}

local locationCache = {}
local function GetSlotItemLocation(id)
	if not azeriteSlots[id] then
		return
	end

	local itemLocation = locationCache[id]
	if not itemLocation then
		itemLocation = ItemLocation:CreateFromEquipmentSlot(id)
		locationCache[id] = itemLocation
	end
	return itemLocation
end

function Module:ItemLevel_UpdateTraits(button, id, link)
	if not C["Misc"].AzeriteTraits then
		return
	end

	local empoweredItemLocation = GetSlotItemLocation(id)
	if not empoweredItemLocation then
		return
	end

	local allTierInfo = TT:Azerite_UpdateTier(link)
	if not allTierInfo then
		return
	end

	for i = 1, 2 do
		local powerIDs = allTierInfo[i] and allTierInfo[i].azeritePowerIDs
		if not powerIDs or powerIDs[1] == 13 then
			break
		end

		for _, powerID in pairs(powerIDs) do
			local selected = C_AzeriteEmpoweredItem_IsPowerSelected(empoweredItemLocation, powerID)
			if selected then
				local spellID = TT:Azerite_PowerToSpell(powerID)
				local name, _, icon = GetSpellInfo(spellID)
				local texture = button["textureIcon" .. i]
				if name and texture then
					texture:SetTexture(icon)
					texture.bg:Show()
				end
			end
		end
	end
end

-- Define enchantable item types
local IsEnchantableSlots = {
	INVTYPE_CHEST = true,
	INVTYPE_ROBE = true,
	INVTYPE_LEGS = true,
	INVTYPE_FEET = true,
	INVTYPE_WRIST = true,
	INVTYPE_FINGER = true,
	INVTYPE_CLOAK = true,
	INVTYPE_WEAPON = true,
	INVTYPE_2HWEAPON = true,
	INVTYPE_WEAPONMAINHAND = true,
	INVTYPE_RANGED = true,
	INVTYPE_RANGEDRIGHT = true,
	INVTYPE_WEAPONOFFHAND = true,
}

-- Helper to handle offhand enchantability logic
local function IsOffhandEnchantable(unit, slot)
	local offHandItemLink = GetInventoryItemLink(unit, slot)
	if offHandItemLink then
		local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(offHandItemLink))
		return itemEquipLoc ~= "INVTYPE_HOLDABLE" and itemEquipLoc ~= "INVTYPE_SHIELD"
	end
	return false
end

-- Main function to check if a slot can be enchanted
function Module:CanEnchantSlot(unit, slot)
	-- Handle offhand logic explicitly
	if slot == INVSLOT_OFFHAND then
		return IsOffhandEnchantable(unit, slot)
	end

	-- Check general enchantable slots
	local itemLink = GetInventoryItemLink(unit, slot)
	if itemLink then
		local itemEquipLoc = select(4, C_Item.GetItemInfoInstant(itemLink))
		return IsEnchantableSlots[itemEquipLoc] or false
	end

	return false
end

function Module:ItemLevel_UpdateInfo(slotFrame, info, quality)
	local infoType = type(info)
	local level
	if infoType == "table" then
		level = info.iLvl
	else
		level = info
	end

	if level and level > 1 and quality and quality > 1 then
		local color = K.QualityColors[quality]
		slotFrame.iLvlText:SetText(level)
		slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
	end

	if infoType == "table" then
		local enchant = info.enchantText
		if enchant then
			slotFrame.enchantText:SetText(enchant)
			slotFrame.enchantText:SetTextColor(0, 1, 0) -- Set text color to green for normal enchant
		elseif Module:CanEnchantSlot("player", slotFrame:GetID()) then
			slotFrame.enchantText:SetText(NO .. " " .. ENSCRIBE)
			slotFrame.enchantText:SetTextColor(1, 0, 0) -- Set text color to red for missing enchant
		end

		local gemStep, essenceStep = 1, 1
		for i = 1, 10 do
			local texture = slotFrame["textureIcon" .. i]
			local bg = texture.bg
			local gem = info.gems and info.gems[gemStep]
			local color = info.gemsColor and info.gemsColor[gemStep]
			local essence = not gem and (info.essences and info.essences[essenceStep])
			if gem then
				texture:SetTexture(gem)
				if color then
					bg.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
				else
					bg.KKUI_Border:SetVertexColor(1, 1, 1)
				end
				bg:Show()

				gemStep = gemStep + 1
			elseif essence and next(essence) then
				local r = essence[4]
				local g = essence[5]
				local b = essence[6]
				if r and g and b then
					bg.KKUI_Border:SetVertexColor(r, g, b)
				else
					bg.KKUI_Border:SetVertexColor(1, 1, 1)
				end

				local selected = essence[1]
				texture:SetTexture(selected)
				bg:Show()

				essenceStep = essenceStep + 1
			end
		end
	end
end

function Module:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
	K.Delay(0.1, function()
		local quality = select(3, GetItemInfo(link))
		local info = K.GetItemLevel(link, unit, index, C["Misc"].GemEnchantInfo)
		if info == "tooSoon" then
			return
		end
		Module:ItemLevel_UpdateInfo(slotFrame, info, quality)
	end)
end

function Module:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then
		return
	end

	Module:CreateItemString(frame, strType)

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType .. slot .. "Slot"]
			slotFrame.iLvlText:SetText("")
			slotFrame.enchantText:SetText("")
			for i = 1, 10 do
				local texture = slotFrame["textureIcon" .. i]
				texture:SetTexture(nil)
				texture.bg:Hide()
			end

			local link = GetInventoryItemLink(unit, index)
			if link then
				local quality = select(3, GetItemInfo(link))
				local info = K.GetItemLevel(link, unit, index, C["Misc"].GemEnchantInfo)
				if info == "tooSoon" then
					Module:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
				else
					Module:ItemLevel_UpdateInfo(slotFrame, info, quality)
				end

				if strType == "Character" then
					Module:ItemLevel_UpdateTraits(slotFrame, index, link)
				end
			end
		end
	end
end

function Module:ItemLevel_UpdatePlayer()
	Module:ItemLevel_SetupLevel(CharacterFrame, "Character", "player")
end

local function CalculateAverageItemLevel(unit, fontstring)
	if not fontstring then
		return
	end

	fontstring:Hide()
	-- Create a table to store item objects
	local items = {}

	-- Initialize variables for equipment locations
	local mainhandEquipLoc, offhandEquipLoc

	-- Iterate through equipped slots
	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		-- Exclude shirt and tabard slots
		if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then
			-- Retrieve item ID and item link for the slot
			local itemID = GetInventoryItemID(unit, slot)
			local itemLink = GetInventoryItemLink(unit, slot)

			-- Check if item ID or item link is valid
			if itemLink or itemID then
				-- Create an item object based on item link or ID
				local item = itemLink and Item:CreateFromItemLink(itemLink) or Item:CreateFromItemID(itemID)

				-- Add item to the table
				table.insert(items, item)

				-- Update mainhand and offhand equipment locations
				local equipLoc = select(4, C_Item.GetItemInfoInstant(itemLink or itemID))
				if slot == INVSLOT_MAINHAND then
					mainhandEquipLoc = equipLoc
				elseif slot == INVSLOT_OFFHAND then
					offhandEquipLoc = equipLoc
				end
			end
		end
	end

	-- Determine the number of equipment slots
	local numSlots = mainhandEquipLoc and offhandEquipLoc and 16 or 15

	-- Adjust number of slots for Fury Warriors
	if select(2, UnitClass(unit)) == "WARRIOR" then
		local isFuryWarrior
		if unit == "player" then
			isFuryWarrior = IsSpellKnown(46917) -- Titan's Grip
		else
			isFuryWarrior = _G.GetInspectSpecialization and GetInspectSpecialization(unit) == 72 -- Fury specialization ID
		end

		-- Adjust number of slots if the unit is a Fury Warrior
		if isFuryWarrior then
			numSlots = 16
		end
	end

	-- Calculate total item level
	local totalLevel = 0
	for _, item in ipairs(items) do
		-- Check if the item has a valid item level
		local itemLevel = item:GetCurrentItemLevel()
		if itemLevel then
			-- Increment total item level
			totalLevel = totalLevel + itemLevel
		end
	end

	fontstring:SetFormattedText(ITEM_LEVEL, totalLevel / numSlots)
	fontstring:Show()
end

-- Update the inspect frame with item level and average item level
function Module:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		Module:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)

		-- Display the average item level text on the inspect frame
		if not InspectFrame.AvgItemLevelText then
			InspectFrame.AvgItemLevelText = K.CreateFontString(InspectModelFrame, 12, "", "OUTLINE", false, "BOTTOM", 0, 46)
		end
		CalculateAverageItemLevel(InspectFrame.unit or "target", InspectFrame.AvgItemLevelText)
		InspectModelFrameControlFrame:HookScript("OnShow", InspectModelFrameControlFrame.Hide)
	end
end

function Module:ItemLevel_FlyoutUpdate(bag, slot, quality)
	if not self.iLvl then
		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end

	if quality and quality <= 1 then
		return
	end

	local link, level
	if bag then
		link = GetContainerItemLink(bag, slot)
		level = K.GetItemLevel(link, bag, slot)
	else
		link = GetInventoryItemLink("player", slot)
		level = K.GetItemLevel(link, "player", slot)
	end

	local color = K.QualityColors[quality or 0]
	self.iLvl:SetText(level)
	self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function Module:ItemLevel_FlyoutSetup()
	if self.iLvl then
		self.iLvl:SetText("")
	end

	local location = self.location
	if not location then
		return
	end

	if tonumber(location) then
		if location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
			return
		end

		local _, _, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
		if voidStorage then
			return
		end
		local quality = select(13, EquipmentManager_GetItemInfoByLocation(location))
		if bags then
			Module.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
		else
			Module.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
		end
	else
		local itemLocation = self:GetItemLocation()
		local quality = itemLocation and C_Item.GetItemQuality(itemLocation)
		if itemLocation:IsBagAndSlot() then
			local bag, slot = itemLocation:GetBagAndSlot()
			Module.ItemLevel_FlyoutUpdate(self, bag, slot, quality)
		elseif itemLocation:IsEquipmentSlot() then
			local slot = itemLocation:GetEquipmentSlot()
			Module.ItemLevel_FlyoutUpdate(self, nil, slot, quality)
		end
	end
end

function Module:ItemLevel_ScrappingUpdate()
	if not self.iLvl then
		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end
	if not self.itemLink then
		self.iLvl:SetText("")
		return
	end

	local quality = 1
	if self.itemLocation and not self.item:IsItemEmpty() and self.item:GetItemName() then
		quality = self.item:GetItemQuality()
	end
	local level = K.GetItemLevel(self.itemLink)
	local color = K.QualityColors[quality]
	self.iLvl:SetText(level)
	self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function Module:ItemLevel_ScrappingSetup()
	for button in self.ItemSlots.scrapButtons:EnumerateActive() do
		if button and not button.iLvl then
			hooksecurefunc(button, "RefreshIcon", Module.ItemLevel_ScrappingUpdate)
		end
	end
end

function Module.ItemLevel_ScrappingShow(event, addon)
	if addon == "Blizzard_ScrappingMachineUI" then
		hooksecurefunc(ScrappingMachineFrame, "SetupScrapButtonPool", Module.ItemLevel_ScrappingSetup)

		K:UnregisterEvent(event, Module.ItemLevel_ScrappingShow)
	end
end

function Module:ItemLevel_UpdateMerchant(link)
	if not self.iLvl then
		self.iLvl = K.CreateFontString(_G[self:GetName() .. "ItemButton"], 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end
	local quality = link and select(3, GetItemInfo(link)) or nil
	if quality and quality > 1 then
		local level = K.GetItemLevel(link)
		local color = K.QualityColors[quality]
		self.iLvl:SetText(level)
		self.iLvl:SetTextColor(color.r, color.g, color.b)
	else
		self.iLvl:SetText("")
	end
end

function Module.ItemLevel_UpdateTradePlayer(index)
	local button = _G["TradePlayerItem" .. index]
	local link = GetTradePlayerItemLink(index)
	Module.ItemLevel_UpdateMerchant(button, link)
end

function Module.ItemLevel_UpdateTradeTarget(index)
	local button = _G["TradeRecipientItem" .. index]
	local link = GetTradeTargetItemLink(index)
	Module.ItemLevel_UpdateMerchant(button, link)
end

local itemCache = {}
local chatModule = K:GetModule("Chat")

function Module.ItemLevel_ReplaceItemLink(link, name)
	if not chatModule then
		return
	end

	if not link then
		return
	end

	local modLink = itemCache[link]
	if not modLink then
		local itemLevel = K.GetItemLevel(link)
		if itemLevel then
			modLink = gsub(link, "|h%[(.-)%]|h", "|h(" .. itemLevel .. chatModule.IsItemHasGem(link) .. ")" .. name .. "|h")
			itemCache[link] = modLink
		end
	end
	return modLink
end

function Module:ItemLevel_ReplaceGuildNews()
	local newText = gsub(self.text:GetText(), "(|Hitem:%d+:.-|h%[(.-)%]|h)", Module.ItemLevel_ReplaceItemLink)
	if newText then
		self.text:SetText(newText)
	end
end

function Module:ItemLevel_UpdateLoot()
	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())
		if button and button.Item and button.GetElementData then
			if not button.iLvl then
				button.iLvl = K.CreateFontString(button.Item, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
			end
			local slotIndex = button:GetSlotIndex()
			local quality = select(5, GetLootSlotInfo(slotIndex))
			if quality and quality > 1 then
				local level = K.GetItemLevel(GetLootSlotLink(slotIndex))
				local color = K.QualityColors[quality]
				button.iLvl:SetText(level)
				button.iLvl:SetTextColor(color.r, color.g, color.b)
			else
				button.iLvl:SetText("")
			end
		end
	end
end

local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local PET_CAGE = 82800

function Module.ItemLevel_GuildBankShow(event, addon)
	if addon == "Blizzard_GuildBankUI" then
		hooksecurefunc(_G.GuildBankFrame, "Update", function(self)
			if self.mode == "bank" then
				local tab = GetCurrentGuildBankTab()
				local button, index, column
				for i = 1, #self.Columns * NUM_SLOTS_PER_GUILDBANK_GROUP do
					index = mod(i, NUM_SLOTS_PER_GUILDBANK_GROUP)
					if index == 0 then
						index = NUM_SLOTS_PER_GUILDBANK_GROUP
					end
					column = ceil((i - 0.5) / NUM_SLOTS_PER_GUILDBANK_GROUP)
					button = self.Columns[column].Buttons[index]

					if button and button:IsShown() then
						local link = GetGuildBankItemLink(tab, i)
						if link then
							if not button.iLvl then
								button.iLvl = K.CreateFontString(button, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
							end

							local level, quality
							local itemID = tonumber(strmatch(link, "Hitem:(%d+):"))

							if itemID == PET_CAGE then
								local data = C_TooltipInfo.GetGuildBankItem(tab, i)
								if data then
									local speciesID, petLevel, breedQuality = data.battlePetSpeciesID, data.battlePetLevel, data.battlePetBreedQuality
									if speciesID and speciesID > 0 then
										level, quality = petLevel, breedQuality
									end
								end
							else
								level = K.GetItemLevel(link)
								quality = select(3, GetItemInfo(link))
							end

							if level and quality then
								local color = K.QualityColors[quality]
								button.iLvl:SetText(level)
								button.iLvl:SetTextColor(color.r, color.g, color.b)

								if button.KKUI_Border and itemID == PET_CAGE then
									button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
								end
							else
								button.iLvl:SetText("")
							end
						elseif button.iLvl then
							button.iLvl:SetText("") -- Clear the FontString if the slot is empty
						end
					end
				end
			end
		end)

		K:UnregisterEvent(event, Module.ItemLevel_GuildBankShow)
	end
end

function Module:CreateSlotItemLevel()
	if not C["Misc"].ItemLevel then
		return
	end

	if C_AddOns.IsAddOnLoaded("SimpleItemLevel") then
		return
	end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", Module.ItemLevel_UpdatePlayer)
	K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", Module.ItemLevel_UpdatePlayer)

	-- iLvl on InspectFrame
	K:RegisterEvent("INSPECT_READY", Module.ItemLevel_UpdateInspect)

	-- iLvl on FlyoutButtons
	hooksecurefunc("EquipmentFlyout_UpdateItems", function()
		for _, button in pairs(EquipmentFlyoutFrame.buttons) do
			if button:IsShown() then
				Module.ItemLevel_FlyoutSetup(button)
			end
		end
	end)

	-- iLvl on ScrappingMachineFrame
	K:RegisterEvent("ADDON_LOADED", Module.ItemLevel_ScrappingShow)

	-- iLvl on MerchantFrame
	hooksecurefunc("MerchantFrameItem_UpdateQuality", Module.ItemLevel_UpdateMerchant)

	-- iLvl on TradeFrame
	hooksecurefunc("TradeFrame_UpdatePlayerItem", Module.ItemLevel_UpdateTradePlayer)
	hooksecurefunc("TradeFrame_UpdateTargetItem", Module.ItemLevel_UpdateTradeTarget)

	-- iLvl on GuildNews
	hooksecurefunc("GuildNewsButton_SetText", Module.ItemLevel_ReplaceGuildNews)

	-- iLvl on LootFrame
	hooksecurefunc(LootFrame.ScrollBox, "Update", Module.ItemLevel_UpdateLoot)

	-- iLvl on GuildBankFrame
	K:RegisterEvent("ADDON_LOADED", Module.ItemLevel_GuildBankShow)
end

Module:RegisterMisc("GearInfo", Module.CreateSlotItemLevel)
