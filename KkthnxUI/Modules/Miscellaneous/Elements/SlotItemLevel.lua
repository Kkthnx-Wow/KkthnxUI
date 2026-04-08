--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays item levels, enchantments, and gems/essences on character and inspection frame slots.
-- - Design: Hooks into character and inspect frames to inject custom font strings and icons based on item data.
-- - Events: PLAYER_EQUIPMENT_CHANGED, INSPECT_READY, ADDON_LOADED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")
local TooltipModule = K:GetModule("Tooltip")

-- PERF: Localize global functions and environment for faster lookups.
local ipairs = _G.ipairs
local math_floor = _G.math.floor
local next = _G.next
local pairs = _G.pairs
local select = _G.select
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local string_sub = _G.string.sub
local string_upper = _G.string.upper
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local type = _G.type

local _G = _G
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_AzeriteEmpoweredItem_IsPowerSelected = _G.C_AzeriteEmpoweredItem.IsPowerSelected
local C_Item_GetItemInfoInstant = _G.C_Item.GetItemInfoInstant
local C_Spell_GetSpellInfo = _G.C_Spell.GetSpellInfo
local C_Spell_GetSpellName = _G.C_Spell.GetSpellName
local CreateFrame = _G.CreateFrame
local GetCurrentGuildBankTab = _G.GetCurrentGuildBankTab
local GetGuildBankItemLink = _G.GetGuildBankItemLink
local GetInspectSpecialization = _G.GetInspectSpecialization
local GetInventoryItemID = _G.GetInventoryItemID
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetLootSlotInfo = _G.GetLootSlotInfo
local GetLootSlotLink = _G.GetLootSlotLink
local GetTradePlayerItemLink = _G.GetTradePlayerItemLink
local GetTradeTargetItemLink = _G.GetTradeTargetItemLink
local HookSecureFunc = _G.hooksecurefunc
local IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local IsSpellKnown = _G.IsSpellKnown
local ItemLocation = _G.ItemLocation
local ItemObject = _G.Item
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID

-- SG: Constants
local ITEM_LEVEL_STRING = _G.ITEM_LEVEL
local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = _G.EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION
local INVSLOT_MAINHAND = _G.INVSLOT_MAINHAND
local INVSLOT_OFFHAND = _G.INVSLOT_OFFHAND
local INVSLOT_FIRST_EQUIPPED = _G.INVSLOT_FIRST_EQUIPPED
local INVSLOT_LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED
local INVSLOT_BODY = _G.INVSLOT_BODY
local INVSLOT_TABARD = _G.INVSLOT_TABARD

-- REASON: Fallback logic for retrieving item info across different WoW versions/expansions.
local function getItemInfoCompat(itemIdentifier)
	local getItemInfoFunc = _G.C_Item and _G.C_Item.GetItemInfo or _G.GetItemInfo
	if getItemInfoFunc then
		return getItemInfoFunc(itemIdentifier)
	end
end

-- REASON: Wrapper for retrieving spell info with fallback for older API versions.
local function getSpellInfoWrapper(spellIdentifier)
	if not spellIdentifier then
		return
	end

	if C_Spell_GetSpellInfo then
		local spellInfoData = C_Spell_GetSpellInfo(spellIdentifier)
		if not spellInfoData then
			return
		end
		return spellInfoData.name, spellInfoData.rank, spellInfoData.iconID, spellInfoData.castTime, spellInfoData.minRange, spellInfoData.maxRange, spellInfoData.spellID, spellInfoData.originalIconID
	else
		return _G.GetSpellInfo(spellIdentifier)
	end
end

local INVENTORY_SLOT_NAMES = {
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

local function getInventorySlotDisplayName(slotToken)
	if not slotToken then
		return ""
	end

	local slotKey = string_upper(slotToken) .. "SLOT"
	local localizedName = _G[slotKey]
	if localizedName and localizedName ~= "" then
		return localizedName
	end

	return string_gsub(slotToken, "(%l)(%u)", "%1 %2")
end

function Module:getInventorySlotAnchor(slotIndex)
	if not slotIndex then
		return
	end

	if slotIndex <= 5 or slotIndex == 9 or slotIndex == 15 then
		return "BOTTOMLEFT", 40, 20
	elseif slotIndex == 16 then
		return "BOTTOMRIGHT", -40, 2
	elseif slotIndex == 17 then
		return "BOTTOMLEFT", 40, 2
	else
		return "BOTTOMRIGHT", -40, 20
	end
end

function Module:createSlotIconTexture(parentSlotFrame, anchorPoint, offsetX, offsetY)
	local iconTexture = parentSlotFrame:CreateTexture(nil, "OVERLAY")
	iconTexture:SetPoint(anchorPoint, offsetX, offsetY)
	iconTexture:SetSize(14, 14)
	iconTexture:SetTexCoord(_G.unpack(K.TexCoords))

	iconTexture.bg = CreateFrame("Frame", nil, parentSlotFrame)
	iconTexture.bg:SetAllPoints(iconTexture)
	iconTexture.bg:SetFrameLevel(101)
	iconTexture.bg:CreateBorder()
	iconTexture.bg:Hide()

	return iconTexture
end

local function onItemStringEnter(stringFrame)
	stringFrame:SetWidth(0)
end

local function onItemStringLeave(stringFrame)
	stringFrame:SetWidth(120)
end

-- SG: Missing Enchant Indicator Constants
local MISSING_ENCHANT_ICON_SIZE = 14
local MISSING_ENCHANT_ICON_DX_LEFT = 5
local MISSING_ENCHANT_ICON_DX_RIGHT = -5
local MISSING_ENCHANT_ICON_DY = 2

local MISSING_ENCHANT_OFFSETS = {
	[16] = { dx = -4, dy = -2 },
	[17] = { dx = 4, dy = -2 },
}

local function onMissingEnchantIconEnter(hitFrame)
	_G.GameTooltip:SetOwner(hitFrame, "ANCHOR_RIGHT")

	local slotDisplayName = hitFrame.KKUI_SlotName
	if slotDisplayName and slotDisplayName ~= "" then
		_G.GameTooltip:AddLine("Missing Enchant: " .. slotDisplayName, 1, 0.1, 0.1)
	else
		_G.GameTooltip:AddLine("Missing Enchant", 1, 0.1, 0.1)
	end

	_G.GameTooltip:Show()
end

local function onMissingEnchantIconLeave()
	_G.GameTooltip:Hide()
end

function Module:getMissingEnchantAnchor(slotIndex, anchorPoint, offsetX, offsetY)
	local dx = (offsetX and offsetX > 0) and MISSING_ENCHANT_ICON_DX_LEFT or MISSING_ENCHANT_ICON_DX_RIGHT
	local dy = MISSING_ENCHANT_ICON_DY

	local offsetData = slotIndex and MISSING_ENCHANT_OFFSETS[slotIndex]
	if offsetData then
		if offsetData.dx ~= nil then
			dx = offsetData.dx
		end
		if offsetData.dy ~= nil then
			dy = offsetData.dy
		end
	end

	return anchorPoint, (offsetX or 0) + dx, (offsetY or 0) + dy
end

function Module:ensureMissingEnchantIcon(parentSlotFrame, slotToken, anchorPoint, offsetX, offsetY)
	local enchantIcon = parentSlotFrame.noEnchantTexture
	if not enchantIcon then
		enchantIcon = parentSlotFrame:CreateTexture(nil, "OVERLAY")
		enchantIcon:SetSize(MISSING_ENCHANT_ICON_SIZE, MISSING_ENCHANT_ICON_SIZE)
		enchantIcon:SetTexCoord(_G.unpack(K.TexCoords))
		enchantIcon:Hide()

		local hitFrame = CreateFrame("Frame", nil, parentSlotFrame)
		hitFrame:SetAllPoints(enchantIcon)
		hitFrame:SetFrameLevel(parentSlotFrame:GetFrameLevel())
		hitFrame:CreateBorder()
		hitFrame:EnableMouse(true)
		hitFrame:SetScript("OnEnter", onMissingEnchantIconEnter)
		hitFrame:SetScript("OnLeave", onMissingEnchantIconLeave)
		hitFrame:Hide()

		enchantIcon.bg = hitFrame
		parentSlotFrame.noEnchantTexture = enchantIcon
	end

	enchantIcon.bg.KKUI_SlotName = getInventorySlotDisplayName(slotToken)
	enchantIcon:ClearAllPoints()
	enchantIcon:SetPoint(anchorPoint, parentSlotFrame, offsetX, offsetY)
	enchantIcon.bg:SetAllPoints(enchantIcon)

	return enchantIcon
end

function Module:createSlotItemLevelStrings(parentFrame, prefixName)
	if parentFrame.fontCreated then
		return
	end

	for slotIndex, slotToken in ipairs(INVENTORY_SLOT_NAMES) do
		if slotIndex ~= 4 then
			local slotFrame = _G[prefixName .. slotToken .. "Slot"]
			if slotFrame then
				slotFrame.iLvlText = K.CreateFontString(slotFrame, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
				slotFrame.iLvlText:ClearAllPoints()
				slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)

				local anchorPoint, offsetX, offsetY = Module:getInventorySlotAnchor(slotIndex)

				slotFrame.enchantText = K.CreateFontString(slotFrame, 11)
				slotFrame.enchantText:ClearAllPoints()
				slotFrame.enchantText:SetPoint(anchorPoint, slotFrame, offsetX, offsetY)
				slotFrame.enchantText:SetJustifyH(string_sub(anchorPoint, 7))
				slotFrame.enchantText:SetWidth(120)
				slotFrame.enchantText:EnableMouse(true)
				slotFrame.enchantText:HookScript("OnEnter", onItemStringEnter)
				slotFrame.enchantText:HookScript("OnLeave", onItemStringLeave)
				slotFrame.enchantText:HookScript("OnShow", onItemStringLeave)

				local enchantPoint, enchantOffsetX, enchantOffsetY = Module:getMissingEnchantAnchor(slotIndex, anchorPoint, offsetX, offsetY)
				Module:ensureMissingEnchantIcon(slotFrame, slotToken, enchantPoint, enchantOffsetX, enchantOffsetY)

				for i = 1, 10 do
					local horizontalOffset = (i - 1) * 20 + 5
					local iconOffsetX = offsetX > 0 and offsetX + horizontalOffset or offsetX - horizontalOffset
					local iconOffsetY = slotIndex > 15 and 20 or 2
					slotFrame["textureIcon" .. i] = Module:createSlotIconTexture(slotFrame, anchorPoint, iconOffsetX, iconOffsetY)
				end
			end
		end
	end

	parentFrame.fontCreated = true
end

-- SG: Azerite Trait Detection Logic
local AZERITE_SLOTS = {
	[1] = true,
	[3] = true,
	[5] = true,
}

local slotLocationCache = {}
local function getInventorySlotItemLocation(slotIndex)
	if not AZERITE_SLOTS[slotIndex] then
		return
	end

	local itemLoc = slotLocationCache[slotIndex]
	if not itemLoc then
		itemLoc = ItemLocation:CreateFromEquipmentSlot(slotIndex)
		slotLocationCache[slotIndex] = itemLoc
	end
	return itemLoc
end

-- REASON: Scans Azerite gear for selected powers and displays corresponding spell icons on the gear slot.
function Module:updateAzeriteTraitIcons(parentSlotFrame, slotIndex, itemLink)
	if not C["Misc"].AzeriteTraits then
		return
	end

	local empoweredItemLocation = getInventorySlotItemLocation(slotIndex)
	if not empoweredItemLocation then
		return
	end

	local tierPowerInfo = TooltipModule:Azerite_UpdateTier(itemLink)
	if not tierPowerInfo then
		return
	end

	for i = 1, 2 do
		local azeritePowerIDs = tierPowerInfo[i] and tierPowerInfo[i].azeritePowerIDs
		if not azeritePowerIDs or azeritePowerIDs[1] == 13 then
			break
		end

		for _, powerID in pairs(azeritePowerIDs) do
			if C_AzeriteEmpoweredItem_IsPowerSelected(empoweredItemLocation, powerID) then
				local azeriteSpellID = TooltipModule:Azerite_PowerToSpell(powerID)
				local spellNameText, _, spellIconID = getSpellInfoWrapper(azeriteSpellID)
				local traitIconTexture = parentSlotFrame["textureIcon" .. i]
				if spellNameText and traitIconTexture then
					traitIconTexture:SetTexture(spellIconID)
					traitIconTexture.bg:Show()
				end
			end
		end
	end
end

-- SG: Enchantable Slot List
local ENCHANT_TARGET_SLOTS = {
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

local function isOffhandEnchantable(targetUnit, slotIndex)
	local itemLink = GetInventoryItemLink(targetUnit, slotIndex)
	if itemLink then
		local equipLocation = select(4, C_Item_GetItemInfoInstant(itemLink))
		return equipLocation ~= "INVTYPE_HOLDABLE" and equipLocation ~= "INVTYPE_SHIELD"
	end
	return false
end

function Module:isSlotEnchantable(targetUnit, slotIndex)
	if slotIndex == INVSLOT_OFFHAND then
		return isOffhandEnchantable(targetUnit, slotIndex)
	end

	local itemLink = GetInventoryItemLink(targetUnit, slotIndex)
	if itemLink then
		local equipLocation = select(4, C_Item_GetItemInfoInstant(itemLink))
		return ENCHANT_TARGET_SLOTS[equipLocation] or false
	end

	return false
end

-- REASON: Updates the item level text and iconography (enchantments, gems) for a specific gear slot.
function Module:updateSlotItemLevelDisplay(parentSlotFrame, gearLevelInfo, itemQuality)
	local infoType = type(gearLevelInfo)
	local itemLevelValue = (infoType == "table") and gearLevelInfo.iLvl or gearLevelInfo

	if itemLevelValue and itemLevelValue > 1 and itemQuality and itemQuality > 1 then
		local qualityColorData = K.QualityColors[itemQuality]
		parentSlotFrame.iLvlText:SetText(itemLevelValue)
		parentSlotFrame.iLvlText:SetTextColor(qualityColorData.r, qualityColorData.g, qualityColorData.b)
	else
		parentSlotFrame.iLvlText:SetText("")
	end

	if infoType ~= "table" then
		return
	end

	local enchantTextContent = gearLevelInfo.enchantText
	if enchantTextContent and enchantTextContent ~= "" then
		parentSlotFrame.enchantText:SetText(enchantTextContent)
		parentSlotFrame.enchantText:SetTextColor(0, 1, 0)

		parentSlotFrame.noEnchantTexture:Hide()
		parentSlotFrame.noEnchantTexture.bg:Hide()
	elseif Module:isSlotEnchantable("player", parentSlotFrame:GetID()) then
		parentSlotFrame.enchantText:SetText("")

		parentSlotFrame.noEnchantTexture:SetTexture("Interface\\Icons\\inv_enchant_formulasuperior_01")
		parentSlotFrame.noEnchantTexture:SetVertexColor(1, 0.1, 0.1, 1)
		parentSlotFrame.noEnchantTexture:SetDesaturated(true)
		parentSlotFrame.noEnchantTexture:Show()
		parentSlotFrame.noEnchantTexture.bg:Show()
	else
		parentSlotFrame.enchantText:SetText("")
		parentSlotFrame.noEnchantTexture:Hide()
		parentSlotFrame.noEnchantTexture.bg:Hide()
	end

	local currentGemIndex, currentEssenceIndex = 1, 1
	for i = 1, 10 do
		local slotIconTexture = parentSlotFrame["textureIcon" .. i]
		local iconBackgroundFrame = slotIconTexture.bg

		local gemTextureID = gearLevelInfo.gems and gearLevelInfo.gems[currentGemIndex]
		local gemColorData = gearLevelInfo.gemsColor and gearLevelInfo.gemsColor[currentGemIndex]
		local essenceData = (not gemTextureID) and (gearLevelInfo.essences and gearLevelInfo.essences[currentEssenceIndex])

		if gemTextureID then
			slotIconTexture:SetTexture(gemTextureID)
			if gemColorData then
				iconBackgroundFrame.KKUI_Border:SetVertexColor(gemColorData.r, gemColorData.g, gemColorData.b)
			else
				iconBackgroundFrame.KKUI_Border:SetVertexColor(1, 1, 1)
			end
			iconBackgroundFrame:Show()
			currentGemIndex = currentGemIndex + 1
		elseif essenceData and next(essenceData) then
			local colorR, colorG, colorB = essenceData[4], essenceData[5], essenceData[6]
			if colorR and colorG and colorB then
				iconBackgroundFrame.KKUI_Border:SetVertexColor(colorR, colorG, colorB)
			else
				iconBackgroundFrame.KKUI_Border:SetVertexColor(1, 1, 1)
			end

			slotIconTexture:SetTexture(essenceData[1])
			iconBackgroundFrame:Show()
			currentEssenceIndex = currentEssenceIndex + 1
		else
			slotIconTexture:SetTexture(nil)
			iconBackgroundFrame:Hide()
		end
	end
end

function Module:refreshSlotItemLevelDisplay(itemLink, targetUnit, slotIndex, parentSlotFrame)
	_G.C_Timer.After(0.1, function()
		local itemQuality = select(3, getItemInfoCompat(itemLink))
		local gearLevelInfo = K.GetItemLevel(itemLink, targetUnit, slotIndex, C["Misc"].GemEnchantInfo)
		if gearLevelInfo == "tooSoon" then
			return
		end
		Module:updateSlotItemLevelDisplay(parentSlotFrame, gearLevelInfo, itemQuality)
	end)
end

function Module:setupGearItemLevelDisplay(parentFrame, prefixName, targetUnit)
	if not UnitExists(targetUnit) then
		return
	end

	Module:createSlotItemLevelStrings(parentFrame, prefixName)

	for slotIndex, slotToken in ipairs(INVENTORY_SLOT_NAMES) do
		if slotIndex ~= 4 then
			local slotFrame = _G[prefixName .. slotToken .. "Slot"]
			if slotFrame then
				slotFrame.iLvlText:SetText("")
				slotFrame.enchantText:SetText("")

				for i = 1, 10 do
					local iconTexture = slotFrame["textureIcon" .. i]
					iconTexture:SetTexture(nil)
					iconTexture.bg:Hide()
				end

				local itemLink = GetInventoryItemLink(targetUnit, slotIndex)
				if itemLink then
					local itemQuality = select(3, getItemInfoCompat(itemLink))
					local gearLevelInfo = K.GetItemLevel(itemLink, targetUnit, slotIndex, C["Misc"].GemEnchantInfo)

					if gearLevelInfo == "tooSoon" then
						Module:refreshSlotItemLevelDisplay(itemLink, targetUnit, slotIndex, slotFrame)
					else
						Module:updateSlotItemLevelDisplay(slotFrame, gearLevelInfo, itemQuality)
					end

					if prefixName == "Character" then
						Module:updateAzeriteTraitIcons(slotFrame, slotIndex, itemLink)
					end
				else
					slotFrame.noEnchantTexture:Hide()
					slotFrame.noEnchantTexture.bg:Hide()
				end
			end
		end
	end
end

-- REASON: Coalesces rapid equipment change events to prevent excessive UI updates and performance spikes.
local isPlayerGearUpdateQueued = false
local function updatePlayerGearItemLevelNow()
	isPlayerGearUpdateQueued = false
	Module:setupGearItemLevelDisplay(_G.CharacterFrame, "Character", "player")
end

local function queuePlayerGearItemLevelUpdate()
	if isPlayerGearUpdateQueued then
		return
	end

	isPlayerGearUpdateQueued = true
	_G.C_Timer.After(0.05, updatePlayerGearItemLevelNow)
end

local gearItemListTable = {}
-- REASON: Manually calculates the average item level of a unit (player or target) for display on the inspection window.
local function calculateAverageGearLevel(targetUnit, displayFontString)
	if not displayFontString then
		return
	end

	displayFontString:Hide()
	table_wipe(gearItemListTable)

	local mainHandEquipLoc, offHandEquipLoc
	for slotIndex = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		if slotIndex ~= INVSLOT_BODY and slotIndex ~= INVSLOT_TABARD then
			local itemIDValue = GetInventoryItemID(targetUnit, slotIndex)
			local itemLinkStr = GetInventoryItemLink(targetUnit, slotIndex)

			if itemLinkStr or itemIDValue then
				local gearItemObject = itemLinkStr and ItemObject:CreateFromItemLink(itemLinkStr) or ItemObject:CreateFromItemID(itemIDValue)
				table_insert(gearItemListTable, gearItemObject)

				local equipLocation = select(4, C_Item_GetItemInfoInstant(itemLinkStr or itemIDValue))
				if slotIndex == INVSLOT_MAINHAND then
					mainHandEquipLoc = equipLocation
				elseif slotIndex == INVSLOT_OFFHAND then
					offHandEquipLoc = equipLocation
				end
			end
		end
	end

	local totalScannedSlots = (mainHandEquipLoc and offHandEquipLoc) and 16 or 15
	local _, classFilename = UnitClass(targetUnit)
	if classFilename == "WARRIOR" then
		local isFurySpecialization
		if targetUnit == "player" then
			isFurySpecialization = IsSpellKnown(46917) -- Titan's Grip
		else
			isFurySpecialization = GetInspectSpecialization and (GetInspectSpecialization(targetUnit) == 72)
		end

		if isFurySpecialization then
			totalScannedSlots = 16
		end
	end

	local totalGearItemLevel = 0
	for i = 1, #gearItemListTable do
		local itemLevelValue = gearItemListTable[i]:GetCurrentItemLevel()
		if itemLevelValue then
			totalGearItemLevel = totalGearItemLevel + itemLevelValue
		end
	end

	displayFontString:SetFormattedText(ITEM_LEVEL_STRING, totalGearItemLevel / totalScannedSlots)
	displayFontString:Show()
end

function Module:updateInspectFrameGearInfo(targetGUID)
	local inspectFrame = _G.InspectFrame
	if inspectFrame and inspectFrame.unit and UnitGUID(inspectFrame.unit) == targetGUID then
		Module:setupGearItemLevelDisplay(inspectFrame, "Inspect", inspectFrame.unit)

		if not inspectFrame.AvgItemLevelText then
			local inspectModelFrame = _G.InspectModelFrame
			if inspectModelFrame then
				inspectFrame.AvgItemLevelText = K.CreateFontString(inspectModelFrame, 12, "", "OUTLINE", false, "BOTTOM", 0, 46)
			end
		end

		if inspectFrame.AvgItemLevelText then
			calculateAverageGearLevel(inspectFrame.unit or "target", inspectFrame.AvgItemLevelText)
		end

		local modelControlFrame = _G.InspectModelFrameControlFrame
		if modelControlFrame then
			modelControlFrame:HookScript("OnShow", modelControlFrame.Hide)
		end
	end
end

local function onFlyoutButtonUpdate(flyoutButton, bagIndex, slotIndex, itemQuality)
	if not flyoutButton.iLvl then
		flyoutButton.iLvl = K.CreateFontString(flyoutButton, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end

	if itemQuality and itemQuality <= 1 then
		flyoutButton.iLvl:SetText("")
		return
	end

	local itemLinkStr, itemLevelValue
	if bagIndex then
		itemLinkStr = _G.C_Container.GetContainerItemLink(bagIndex, slotIndex)
		itemLevelValue = K.GetItemLevel(itemLinkStr, bagIndex, slotIndex)
	else
		itemLinkStr = GetInventoryItemLink("player", slotIndex)
		itemLevelValue = K.GetItemLevel(itemLinkStr, "player", slotIndex)
	end

	local qualityColorData = K.QualityColors[itemQuality or 0]
	flyoutButton.iLvl:SetText(itemLevelValue or "")
	flyoutButton.iLvl:SetTextColor(qualityColorData.r, qualityColorData.g, qualityColorData.b)
end

local function setupFlyoutGearDisplay(flyoutButton)
	if flyoutButton.iLvl then
		flyoutButton.iLvl:SetText("")
	end

	local flyoutLocation = flyoutButton.location
	if not flyoutLocation then
		return
	end

	if tonumber(flyoutLocation) then
		if flyoutLocation >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
			return
		end

		local _, _, isBags, isVoidStorage, slotIndex, bagIndex = _G.EquipmentManager_UnpackLocation(flyoutLocation)
		if isVoidStorage then
			return
		end

		local itemQuality = select(13, _G.EquipmentManager_GetItemInfoByLocation(flyoutLocation))
		if isBags then
			onFlyoutButtonUpdate(flyoutButton, bagIndex, slotIndex, itemQuality)
		else
			onFlyoutButtonUpdate(flyoutButton, nil, slotIndex, itemQuality)
		end
	else
		local itemLocationObject = flyoutButton:GetItemLocation()
		local itemQuality = itemLocationObject and _G.C_Item.GetItemQuality(itemLocationObject)
		if itemLocationObject and itemLocationObject:IsBagAndSlot() then
			local bagIndex, slotIndex = itemLocationObject:GetBagAndSlot()
			onFlyoutButtonUpdate(flyoutButton, bagIndex, slotIndex, itemQuality)
		elseif itemLocationObject and itemLocationObject:IsEquipmentSlot() then
			local slotIndex = itemLocationObject:GetEquipmentSlot()
			onFlyoutButtonUpdate(flyoutButton, nil, slotIndex, itemQuality)
		end
	end
end

local function onScrappingButtonUpdate(scrappingButton)
	if not scrappingButton.iLvl then
		scrappingButton.iLvl = K.CreateFontString(scrappingButton, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end

	if not scrappingButton.itemLink then
		scrappingButton.iLvl:SetText("")
		return
	end

	local itemQuality = 1
	if scrappingButton.itemLocation and scrappingButton.item and not scrappingButton.item:IsItemEmpty() and scrappingButton.item:GetItemName() then
		itemQuality = scrappingButton.item:GetItemQuality()
	end

	local itemLevelValue = K.GetItemLevel(scrappingButton.itemLink)
	if itemLevelValue then
		local qualityColorData = K.QualityColors[itemQuality]
		scrappingButton.iLvl:SetText(itemLevelValue)
		scrappingButton.iLvl:SetTextColor(qualityColorData.r, qualityColorData.g, qualityColorData.b)
	else
		scrappingButton.iLvl:SetText("")
	end
end

local function setupScrappingGearDisplay(scrappingFrame)
	if not scrappingFrame or not scrappingFrame.ItemSlots then
		return
	end

	for scrappingButton in scrappingFrame.ItemSlots.scrapButtons:EnumerateActive() do
		if scrappingButton and not scrappingButton.iLvlHooked then
			HookSecureFunc(scrappingButton, "RefreshIcon", onScrappingButtonUpdate)
			scrappingButton.iLvlHooked = true
		end
	end
end

local function onScrappingMachineLoaded(eventName, addonName)
	if addonName == "Blizzard_ScrappingMachineUI" then
		local machineFrame = _G.ScrappingMachineFrame
		if machineFrame then
			HookSecureFunc(machineFrame, "SetupScrapButtonPool", setupScrappingGearDisplay)
			setupScrappingGearDisplay(machineFrame)
		end
		K:UnregisterEvent(eventName, onScrappingMachineLoaded)
	end
end

local function updateMerchantItemQuality(merchantButton, itemLinkStr)
	if not merchantButton or not merchantButton.GetName then
		return
	end

	if not merchantButton.iLvl then
		merchantButton.iLvl = K.CreateFontString(_G[merchantButton:GetName() .. "ItemButton"], 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end

	local itemQuality = itemLinkStr and select(3, getItemInfoCompat(itemLinkStr)) or nil
	if itemQuality and itemQuality > 1 then
		local itemLevelValue = K.GetItemLevel(itemLinkStr)
		local qualityColorData = K.QualityColors[itemQuality]
		merchantButton.iLvl:SetText(itemLevelValue or "")
		merchantButton.iLvl:SetTextColor(qualityColorData.r, qualityColorData.g, qualityColorData.b)
	else
		merchantButton.iLvl:SetText("")
	end
end

local function updateTradePlayerItemLevel(itemIndex)
	local tradeButton = _G["TradePlayerItem" .. itemIndex]
	local itemLinkStr = GetTradePlayerItemLink(itemIndex)
	updateMerchantItemQuality(tradeButton, itemLinkStr)
end

local function updateTradeTargetItemLevel(itemIndex)
	local tradeButton = _G["TradeRecipientItem" .. itemIndex]
	local itemLinkStr = GetTradeTargetItemLink(itemIndex)
	updateMerchantItemQuality(tradeButton, itemLinkStr)
end

local ChatModule = K:GetModule("Chat")
local gearLevelChatCache = {}
local gearCacheItemCount = 0

local function addItemToGearLevelCache(itemLinkStr, modifiedChatLink)
	if gearCacheItemCount >= 500 then
		table_wipe(gearLevelChatCache)
		gearCacheItemCount = 0
	end

	gearLevelChatCache[itemLinkStr] = modifiedChatLink
	gearCacheItemCount = gearCacheItemCount + 1
end

local function replaceChatLinkWithItemLevel(itemLinkStr, itemNameText)
	if not ChatModule or not itemLinkStr then
		return
	end

	local modifiedChatLink = gearLevelChatCache[itemLinkStr]
	if not modifiedChatLink then
		local itemLevelValue = K.GetItemLevel(itemLinkStr)
		if itemLevelValue then
			modifiedChatLink = _G.gsub(itemLinkStr, "|h%[(.-)%]|h", "|h(" .. itemLevelValue .. ChatModule.IsItemHasGem(itemLinkStr) .. ")" .. itemNameText .. "|h")
			addItemToGearLevelCache(itemLinkStr, modifiedChatLink)
		end
	end

	return modifiedChatLink
end

function Module:onGuildNewsTextUpdate(newsButton)
	if not newsButton or not newsButton.text or not newsButton.text.GetText then
		return
	end

	local updatedNewsText = _G.gsub(newsButton.text:GetText(), "(|Hitem:%d+:.-|h%[(.-)%]|h)", replaceChatLinkWithItemLevel)
	if updatedNewsText then
		newsButton.text:SetText(updatedNewsText)
	end
end

local lootButtonTable = {}
local function onLootScrollUpdate(scrollBoxFrame)
	if not scrollBoxFrame or not scrollBoxFrame.ScrollTarget then
		return
	end

	local childCountCount = scrollBoxFrame.ScrollTarget:GetNumChildren()
	if childCountCount == 0 then
		return
	end

	table_wipe(lootButtonTable)
	local scrollTargetChildren = { scrollBoxFrame.ScrollTarget:GetChildren() }
	for i = 1, childCountCount do
		lootButtonTable[i] = scrollTargetChildren[i]
	end

	for i = 1, childCountCount do
		local lootButton = lootButtonTable[i]
		if lootButton and lootButton.Item and lootButton.GetElementData then
			if not lootButton.iLvl then
				lootButton.iLvl = K.CreateFontString(lootButton.Item, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
			end

			local lootSlotIndex = lootButton:GetSlotIndex()
			local itemQuality = select(5, GetLootSlotInfo(lootSlotIndex))
			if itemQuality and itemQuality > 1 then
				local itemLevelValue = K.GetItemLevel(GetLootSlotLink(lootSlotIndex))
				local qualityColorData = K.QualityColors[itemQuality]
				lootButton.iLvl:SetText(itemLevelValue or "")
				lootButton.iLvl:SetTextColor(qualityColorData.r, qualityColorData.g, qualityColorData.b)
			else
				lootButton.iLvl:SetText("")
			end
		end
	end
end

local GUILD_BANK_SLOTS_PER_COLUMN = 14
local PET_CAGE_ITEM_ID = 82800

-- REASON: Injects item levels for standard gear and battle-pet levels for caged pets within the guild bank columns.
local function onGuildBankLoaded(eventName, addonName)
	if addonName ~= "Blizzard_GuildBankUI" then
		return
	end

	HookSecureFunc(_G.GuildBankFrame, "Update", function(self)
		if self.mode ~= "bank" then
			return
		end

		local currentBankTab = GetCurrentGuildBankTab()
		local columnCount = #self.Columns
		local totalBankSlots = columnCount * GUILD_BANK_SLOTS_PER_COLUMN

		for i = 1, totalBankSlots do
			local slotIndexInColumn = ((i - 1) % GUILD_BANK_SLOTS_PER_COLUMN) + 1
			local columnIndex = math_floor((i - 1) / GUILD_BANK_SLOTS_PER_COLUMN) + 1
			local itemButton = self.Columns[columnIndex].Buttons[slotIndexInColumn]

			if itemButton and itemButton:IsShown() then
				local itemLinkStr = GetGuildBankItemLink(currentBankTab, i)
				if itemLinkStr then
					if not itemButton.iLvl then
						itemButton.iLvl = K.CreateFontString(itemButton, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
					end

					local itemLevelStr, itemQualityID
					local itemIDValue = tonumber(string_match(itemLinkStr, "Hitem:(%d+):"))

					if itemIDValue == PET_CAGE_ITEM_ID then
						local bankItemData = _G.C_TooltipInfo.GetGuildBankItem(currentBankTab, i)
						if bankItemData then
							local petSpeciesID = bankItemData.battlePetSpeciesID
							if petSpeciesID and petSpeciesID > 0 then
								itemLevelStr = bankItemData.battlePetLevel
								itemQualityID = bankItemData.battlePetBreedQuality
							end
						end
					else
						itemLevelStr = K.GetItemLevel(itemLinkStr)
						itemQualityID = select(3, getItemInfoCompat(itemLinkStr))
					end

					if itemLevelStr and itemQualityID then
						local qualityColorData = K.QualityColors[itemQualityID]
						itemButton.iLvl:SetText(itemLevelStr)
						itemButton.iLvl:SetTextColor(qualityColorData.r, qualityColorData.g, qualityColorData.b)

						if itemButton.KKUI_Border and itemIDValue == PET_CAGE_ITEM_ID then
							itemButton.KKUI_Border:SetVertexColor(qualityColorData.r, qualityColorData.g, qualityColorData.b)
						end
					else
						itemButton.iLvl:SetText("")
					end
				elseif itemButton.iLvl then
					itemButton.iLvl:SetText("")
				end
			end
		end
	end)

	K:UnregisterEvent(eventName, onGuildBankLoaded)
end

function Module:createImprovedSlotItemLevelDisplay()
	if not C["Misc"].ItemLevel then
		return
	end

	if C_AddOns.IsAddOnLoaded("SimpleItemLevel") then
		return
	end

	_G.CharacterFrame:HookScript("OnShow", queuePlayerGearItemLevelUpdate)
	K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", queuePlayerGearItemLevelUpdate)

	K:RegisterEvent("INSPECT_READY", Module.updateInspectFrameGearInfo)

	HookSecureFunc("EquipmentFlyout_UpdateItems", function()
		for _, flyoutButton in pairs(_G.EquipmentFlyoutFrame.buttons) do
			if flyoutButton:IsShown() then
				setupFlyoutGearDisplay(flyoutButton)
			end
		end
	end)

	K:RegisterEvent("ADDON_LOADED", onScrappingMachineLoaded)

	HookSecureFunc("MerchantFrameItem_UpdateQuality", updateMerchantItemQuality)

	HookSecureFunc("TradeFrame_UpdatePlayerItem", updateTradePlayerItemLevel)
	HookSecureFunc("TradeFrame_UpdateTargetItem", updateTradeTargetItemLevel)

	HookSecureFunc("GuildNewsButton_SetText", Module.onGuildNewsTextUpdate)

	if _G.LootFrame and _G.LootFrame.ScrollBox then
		HookSecureFunc(_G.LootFrame.ScrollBox, "Update", onLootScrollUpdate)
	end

	K:RegisterEvent("ADDON_LOADED", onGuildBankLoaded)

	K:RegisterEvent("PLAYER_LOGOUT", function()
		table_wipe(slotLocationCache)
		table_wipe(gearLevelChatCache)
	end)
end

Module:RegisterMisc("GearInfo", Module.createImprovedSlotItemLevelDisplay)
