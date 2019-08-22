local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local unpack = _G.unpack

local BAG_ITEM_QUALITY_COLORS = _G.BAG_ITEM_QUALITY_COLORS
local CreateFrame = _G.CreateFrame
local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = _G.EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION or 4294967293
local EquipmentManager_GetItemInfoByLocation = _G.EquipmentManager_GetItemInfoByLocation
local EquipmentManager_UnpackLocation = _G.EquipmentManager_UnpackLocation
local GetContainerItemLink = _G.GetContainerItemLink
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetItemInfo = _G.GetItemInfo
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

function Module:GetSlotAnchor(index)
	if not index then return end

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
	icon.bg:SetFrameLevel(3)
	icon.bg:CreateBorder()
	icon.bg:Hide()

	return icon
end

function Module:CreateItemString(frame, strType)
	if frame.fontCreated then
		return
	end

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText = K.CreateFontString(slotFrame, 12)

			slotFrame.iLvlText:ClearAllPoints()
			slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)

			local relF, x, y = Module:GetSlotAnchor(index)
			slotFrame.enchantText = K.CreateFontString(slotFrame, 12)
			slotFrame.enchantText:ClearAllPoints()
			slotFrame.enchantText:SetPoint(relF, slotFrame, x, y)
			slotFrame.enchantText:SetTextColor(0, 1, 0)

			for i = 1, 5 do
				local offset = (i-1)*18 + 5
				local iconX = x > 0 and x+offset or x-offset
				local iconY = index > 15 and 20 or 2
				slotFrame["textureIcon"..i] = Module:CreateItemTexture(slotFrame, relF, iconX, iconY)
			end
		end
	end

	frame.fontCreated = true
end

function Module:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then
		return
	end

	Module:CreateItemString(frame, strType)

	for index, slot in pairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType..slot.."Slot"]
			slotFrame.iLvlText:SetText("")
			slotFrame.enchantText:SetText("")

			for i = 1, 5 do
				local texture = slotFrame["textureIcon"..i]
				texture:SetTexture(nil)
				texture.bg:Hide()
			end

			local link = GetInventoryItemLink(unit, index)
			if link then
				local quality = select(3, GetItemInfo(link))
				local level, enchant, gems, essences = K.GetItemLevel(link, unit, index, C["Misc"].GemEnchantInfo)

				if level and level > 1 and quality then
					local color = BAG_ITEM_QUALITY_COLORS[quality]
					slotFrame.iLvlText:SetText(level)
					slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
				end

				if enchant then
					slotFrame.enchantText:SetText(enchant)
				end

				for i = 1, 5 do
					local texture = slotFrame["textureIcon"..i]
					if gems and next(gems) then
						local index, gem = next(gems)
						texture:SetTexture(gem)
						texture.bg:Show()

						gems[index] = nil
					elseif essences and next(essences) then
						local index, essence = next(essences)
						local selected = essence[1]
						texture:SetTexture(selected)
						texture.bg:Show()

						essences[index] = nil
					end
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
	if _G.InspectFrame and _G.InspectFrame.unit and UnitGUID(_G.InspectFrame.unit) == guid then
		Module:ItemLevel_SetupLevel(_G.InspectFrame, "Inspect", _G.InspectFrame.unit)
	end
end

function Module:ItemLevel_FlyoutUpdate(bag, slot, quality)
	if not self.iLvl then
		self.iLvl = K.CreateFontString(self, 12, "", false, "BOTTOMLEFT", 1, 1)
	end

	local link, level
	if bag then
		link = GetContainerItemLink(bag, slot)
		level = K.GetItemLevel(link, bag, slot)
	else
		link = GetInventoryItemLink("player", slot)
		level = K.GetItemLevel(link, "player", slot)
	end

	local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
	self.iLvl:SetText(level)
	self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function Module:ItemLevel_FlyoutSetup()
	local location = self.location
	if not location or location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
		if self.iLvl then self.iLvl:SetText("") end
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
end

function Module:ItemLevel_ScrappingUpdate()
	if not self.iLvl then
		self.iLvl = K.CreateFontString(self, 12, "", false, "BOTTOMLEFT", 1, 1)
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
	local color = BAG_ITEM_QUALITY_COLORS[quality]
	self.iLvl:SetText(level)
	self.iLvl:SetTextColor(color.r, color.g, color.b)
end

function Module.ItemLevel_ScrappingShow(event, addon)
	if addon == "Blizzard_ScrappingMachineUI" then
		for button in pairs(_G.ScrappingMachineFrame.ItemSlots.scrapButtons.activeObjects) do
			hooksecurefunc(button, "RefreshIcon", Module.ItemLevel_ScrappingUpdate)
		end

		K:UnregisterEvent(event, Module.ItemLevel_ScrappingShow)
	end
end

function Module:CreateSlotItemLevel()
	if not C["Misc"].ItemLevel then
		return
	end

	-- iLvl on CharacterFrame
	_G.CharacterFrame:HookScript("OnShow", Module.ItemLevel_UpdatePlayer)
	K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", Module.ItemLevel_UpdatePlayer)

	-- iLvl on InspectFrame
	K:RegisterEvent("INSPECT_READY", self.ItemLevel_UpdateInspect)

	-- iLvl on FlyoutButtons
	hooksecurefunc("EquipmentFlyout_DisplayButton", self.ItemLevel_FlyoutSetup)

	-- iLvl on ScrappingMachineFrame
	K:RegisterEvent("ADDON_LOADED", self.ItemLevel_ScrappingShow)
end