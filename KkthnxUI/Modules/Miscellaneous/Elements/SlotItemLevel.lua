local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")

local _G = _G
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local type = _G.type

local C_AzeriteEmpoweredItem_GetAllTierInfoByItemID = _G.C_AzeriteEmpoweredItem.GetAllTierInfoByItemID
local C_AzeriteEmpoweredItem_GetPowerInfo = _G.C_AzeriteEmpoweredItem.GetPowerInfo
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = _G.C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_AzeriteEmpoweredItem_IsPowerSelected = _G.C_AzeriteEmpoweredItem.IsPowerSelected
local C_Timer_After = _G.C_Timer.After
local EquipmentManager_GetItemInfoByLocation = _G.EquipmentManager_GetItemInfoByLocation
local EquipmentManager_UnpackLocation = _G.EquipmentManager_UnpackLocation
local GetContainerItemLink = _G.GetContainerItemLink
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo
local GetSpellInfo = _G.GetSpellInfo
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID
local hooksecurefunc = _G.hooksecurefunc

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

local azeriteSlots = {
	[1] = true,
	[3] = true,
	[5] = true,
}

local locationCache = {}
local powerCache = {}
local tierCache = {}

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
	local icon = slot:CreateTexture(nil, "ARTWORK")
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(unpack(K.TexCoords))

	icon.bg = CreateFrame("Frame", nil, slot)
	icon.bg:SetPoint("TOPLEFT", icon, -1, 1)
	icon.bg:SetPoint("BOTTOMRIGHT", icon, 1, -1)
	icon.bg:SetFrameLevel(slot:GetFrameLevel())
	icon.bg:CreateBorder(nil, nil, 10, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	icon.bg:Hide()

	return icon
end

function Module:CreateItemString(frame, strType)
	if frame.fontCreated then
		return
	end

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType .. slot .. "Slot"]
			slotFrame.iLvlText = K.CreateFontString(slotFrame, 12, "", "OUTLINE")
			slotFrame.iLvlText:ClearAllPoints()
			slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)

			local relF, x, y = Module:GetSlotAnchor(index)
			slotFrame.enchantText = K.CreateFontString(slotFrame, 12, "", "OUTLINE")
			slotFrame.enchantText:ClearAllPoints()
			slotFrame.enchantText:SetPoint(relF, slotFrame, x, y)
			slotFrame.enchantText:SetTextColor(0, 1, 0)

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

function Module:Azerite_UpdateTier(link)
	if not C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(link) then
		return
	end

	local allTierInfo = tierCache[link]
	if not allTierInfo then
		allTierInfo = C_AzeriteEmpoweredItem_GetAllTierInfoByItemID(link)
		tierCache[link] = allTierInfo
	end

	return allTierInfo
end

function Module:Azerite_PowerToSpell(id)
	local spellID = powerCache[id]
	if not spellID then
		local powerInfo = C_AzeriteEmpoweredItem_GetPowerInfo(id)
		if powerInfo and powerInfo.spellID then
			spellID = powerInfo.spellID
			powerCache[id] = spellID
		end
	end
	return spellID
end

function Module:ItemLevel_UpdateTraits(button, id, link)
	local empoweredItemLocation = GetSlotItemLocation(id)
	if not empoweredItemLocation then
		return
	end

	local allTierInfo = Module:Azerite_UpdateTier(link)
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
				local spellID = Module:Azerite_PowerToSpell(powerID)
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
			slotFrame.enchantText:SetText(string.utf8sub(enchant, 1, 18))
		end

		local gemStep, essenceStep = 1, 1
		for i = 1, 10 do
			local texture = slotFrame["textureIcon" .. i]
			local bg = texture.bg
			local gem = info.gems and info.gems[gemStep]
			local essence = not gem and (info.essences and info.essences[essenceStep])
			if gem then
				texture:SetTexture(gem)
				bg.KKUI_Border:SetVertexColor(1, 1, 1)
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
	C_Timer_After(5, function()
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

function Module:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		Module:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)
	end
end

function Module:ItemLevel_FlyoutUpdate(bag, slot, quality)
	if not self.iLvl then
		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 1)
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
		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 1)
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

function Module.ItemLevel_ScrappingShow(event, addon)
	if addon == "Blizzard_ScrappingMachineUI" then
		for button in pairs(ScrappingMachineFrame.ItemSlots.scrapButtons.activeObjects) do
			hooksecurefunc(button, "RefreshIcon", Module.ItemLevel_ScrappingUpdate)
		end

		K:UnregisterEvent(event, Module.ItemLevel_ScrappingShow)
	end
end

local itemCache = {}
local CHAT = K:GetModule("Chat")

function Module.ItemLevel_ReplaceItemLink(link, name)
	if not link then
		return
	end

	local modLink = itemCache[link]
	if not modLink then
		local itemLevel = K.GetItemLevel(link)
		if itemLevel then
			modLink = gsub(link, "|h%[(.-)%]|h", "|h(" .. itemLevel .. CHAT.IsItemHasGem(link) .. ")" .. name .. "|h")
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

function Module:CreateSlotItemLevel()
	if not C["Misc"].ItemLevel then
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

	-- iLvl on GuildNews
	hooksecurefunc("GuildNewsButton_SetText", Module.ItemLevel_ReplaceGuildNews)
end

Module:RegisterMisc("SlotItemLevel", Module.CreateSlotItemLevel)
