--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays item levels, enchantments, and gems/essences on character and inspection frame slots.
-- - Design: Hooks into character and inspect frames to inject custom font strings and icons based on item data.
-- - Events: PLAYER_EQUIPMENT_CHANGED, INSPECT_READY, ADDON_LOADED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

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
local format = string.format

local _G = _G
local C_Item_GetItemGem = _G.C_Item.GetItemGem
local C_Item_GetItemInfoInstant = _G.C_Item.GetItemInfoInstant
local C_PaperDollInfo = _G.C_PaperDollInfo
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
local hooksecurefunc = _G.hooksecurefunc
local IsSpellKnown = _G.IsSpellKnown
local ItemObject = _G.Item
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID
local GameTooltip = _G.GameTooltip

-- Icon crop for KKUI borders (Init.lua K.TexCoords). SetTexture can reset this — reapply after every paint.
local ICON_L, ICON_R, ICON_T, ICON_B = K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4]

local function ApplyOverlayIconTexture(iconTexture, file)
	iconTexture:SetTexture(file)
	if file then
		iconTexture:SetTexCoord(ICON_L, ICON_R, ICON_T, ICON_B)
	end
end

local NotSecret = K.NotSecret

-- Midnight enchant slots: Wrist/Back removed; Head/Shoulder back. Indices = inventory slot ids.
local ENCHANTABLE_SLOTS = {
	[1] = true, -- Head
	[3] = true, -- Shoulder
	[5] = true, -- Chest
	[7] = true, -- Legs
	[8] = true, -- Feet
	[11] = true, -- Finger 1
	[12] = true, -- Finger 2
	[16] = true, -- Main Hand
	[17] = true, -- Off Hand (shields/holdables skipped at scan time)
}

local MISSING_ENCHANT_ICON = 134400 -- inv_misc_questionmark

-- SG: Constants
local ITEM_LEVEL_STRING = _G.ITEM_LEVEL
local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = _G.EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION
local INVSLOT_MAINHAND = _G.INVSLOT_MAINHAND
local INVSLOT_OFFHAND = _G.INVSLOT_OFFHAND
local INVSLOT_FIRST_EQUIPPED = _G.INVSLOT_FIRST_EQUIPPED
local INVSLOT_LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED
local INVSLOT_BODY = _G.INVSLOT_BODY
local INVSLOT_TABARD = _G.INVSLOT_TABARD

-- REASON: Retail item info via C_Item namespace.
local function getItemInfoCompat(itemIdentifier)
	if _G.C_Item and _G.C_Item.GetItemInfo then
		return _G.C_Item.GetItemInfo(itemIdentifier)
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

local function onGemIconEnter(hitFrame)
	if not hitFrame.gemLink then
		return
	end
	GameTooltip:SetOwner(hitFrame, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink(hitFrame.gemLink)
	GameTooltip:Show()
end

local function onGemIconLeave()
	GameTooltip:Hide()
end

function Module:createSlotIconTexture(parentSlotFrame, anchorPoint, offsetX, offsetY)
	-- Icon owns size/crop; border is a sibling wrap (NDui ReskinIcon / pre-hitframe KKUI).
	-- Hitframe-as-parent + inset made the Blizzard chrome show inside our border.
	local iconTexture = parentSlotFrame:CreateTexture(nil, "OVERLAY", nil, 7)
	iconTexture:SetPoint(anchorPoint, offsetX, offsetY)
	iconTexture:SetSize(14, 14)
	iconTexture:SetTexCoord(ICON_L, ICON_R, ICON_T, ICON_B)

	-- 7th arg "" skips KKUI_Background so the fill never paints over the gem.
	iconTexture.bg = CreateFrame("Frame", nil, parentSlotFrame)
	iconTexture.bg:SetAllPoints(iconTexture)
	iconTexture.bg:SetFrameLevel(parentSlotFrame:GetFrameLevel() + 3)
	iconTexture.bg:CreateBorder(nil, nil, nil, nil, nil, nil, "")
	iconTexture.bg:EnableMouse(true)
	iconTexture.bg:SetScript("OnEnter", onGemIconEnter)
	iconTexture.bg:SetScript("OnLeave", onGemIconLeave)
	iconTexture.bg:Hide()

	return iconTexture
end

local function assertGemOverlayLevel(parentSlotFrame, iconTexture)
	if not (parentSlotFrame and iconTexture and iconTexture.bg) then
		return
	end
	iconTexture.bg:SetFrameLevel(parentSlotFrame:GetFrameLevel() + 3)
end

local function assertMissingOverlayLevel(parentSlotFrame, missingIcon)
	if not (parentSlotFrame and missingIcon and missingIcon.bg) then
		return
	end
	missingIcon.bg:SetFrameLevel(parentSlotFrame:GetFrameLevel() + 4)
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
	GameTooltip:SetOwner(hitFrame, "ANCHOR_RIGHT")
	GameTooltip:SetText(format(L["Missing Enchant: %s"], hitFrame.KKUI_SlotName or ""), 1, 0.2, 0.2)
	GameTooltip:Show()
end

local function onMissingEnchantIconLeave()
	GameTooltip:Hide()
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
		enchantIcon = parentSlotFrame:CreateTexture(nil, "OVERLAY", nil, 7)
		enchantIcon:SetSize(MISSING_ENCHANT_ICON_SIZE, MISSING_ENCHANT_ICON_SIZE)
		ApplyOverlayIconTexture(enchantIcon, MISSING_ENCHANT_ICON)
		enchantIcon:Hide()

		local bg = CreateFrame("Frame", nil, parentSlotFrame)
		bg:SetAllPoints(enchantIcon)
		bg:SetFrameLevel(parentSlotFrame:GetFrameLevel() + 4)
		bg:CreateBorder(nil, nil, nil, nil, nil, nil, "")
		bg:EnableMouse(true)
		bg:SetScript("OnEnter", onMissingEnchantIconEnter)
		bg:SetScript("OnLeave", onMissingEnchantIconLeave)
		bg:Hide()

		enchantIcon.bg = bg
		parentSlotFrame.noEnchantTexture = enchantIcon
	end

	enchantIcon.bg.KKUI_SlotName = getInventorySlotDisplayName(slotToken)
	enchantIcon:ClearAllPoints()
	enchantIcon:SetPoint(anchorPoint, parentSlotFrame, offsetX, offsetY)
	enchantIcon.bg:SetAllPoints(enchantIcon)
	assertMissingOverlayLevel(parentSlotFrame, enchantIcon)

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
				-- Only enchantable slots get the missing marker (NexEnhance pattern).
				if ENCHANTABLE_SLOTS[slotIndex] then
					Module:ensureMissingEnchantIcon(slotFrame, slotToken, enchantPoint, enchantOffsetX, enchantOffsetY)
				end

				for i = 1, 10 do
					local horizontalOffset = (i - 1) * 18 + 5
					local iconOffsetX = offsetX > 0 and offsetX + horizontalOffset or offsetX - horizontalOffset
					local iconOffsetY = slotIndex > 15 and 20 or 2
					slotFrame["textureIcon" .. i] = Module:createSlotIconTexture(slotFrame, anchorPoint, iconOffsetX, iconOffsetY)
				end
			end
		end
	end

	parentFrame.fontCreated = true
end

local function isOffhandEnchantable(targetUnit, slotIndex)
	local itemLink = GetInventoryItemLink(targetUnit, slotIndex)
	if itemLink then
		local equipLocation = select(4, C_Item_GetItemInfoInstant(itemLink))
		-- Shields / off-hand frills don't take weapon enchants.
		return equipLocation ~= "INVTYPE_HOLDABLE" and equipLocation ~= "INVTYPE_SHIELD"
	end
	return false
end

function Module:isSlotEnchantable(targetUnit, slotIndex)
	if not ENCHANTABLE_SLOTS[slotIndex] then
		return false
	end
	if slotIndex == INVSLOT_OFFHAND then
		return isOffhandEnchantable(targetUnit, slotIndex)
	end
	return GetInventoryItemLink(targetUnit, slotIndex) ~= nil
end

local function shouldFullScanGemsEnchants()
	return C["Misc"].GemEnchantInfo or C["Misc"].MissingEnchant
end

-- REASON: Updates the item level text and iconography (enchantments, gems) for a specific gear slot.
function Module:updateSlotItemLevelDisplay(parentSlotFrame, gearLevelInfo, itemQuality, itemLink, targetUnit)
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

	local showGemsEnchants = C["Misc"].GemEnchantInfo
	local enchantTextContent = gearLevelInfo.enchantText
	local hasEnchant = enchantTextContent and enchantTextContent ~= ""

	if showGemsEnchants and hasEnchant then
		-- Blizzard prefixes some lines "Source - EnchantName"; strip the noise.
		parentSlotFrame.enchantText:SetText((enchantTextContent:gsub("^.-%s%-%s", "")))
		parentSlotFrame.enchantText:SetTextColor(0, 1, 0)
	else
		parentSlotFrame.enchantText:SetText("")
	end

	local missingIcon = parentSlotFrame.noEnchantTexture
	if missingIcon then
		local showMissing = C["Misc"].MissingEnchant
			and Module:isSlotEnchantable(targetUnit or "player", parentSlotFrame:GetID())
			and not hasEnchant
		if showMissing then
			ApplyOverlayIconTexture(missingIcon, MISSING_ENCHANT_ICON)
			missingIcon:SetVertexColor(1, 0.2, 0.2, 1)
			missingIcon:SetDesaturated(false)
			assertMissingOverlayLevel(parentSlotFrame, missingIcon)
			missingIcon:Show()
			missingIcon.bg:Show()
		else
			missingIcon:Hide()
			missingIcon.bg:Hide()
		end
	end

	local currentGemIndex, currentEssenceIndex = 1, 1
	for i = 1, 10 do
		local slotIconTexture = parentSlotFrame["textureIcon" .. i]
		local iconBackgroundFrame = slotIconTexture.bg

		local gemTextureID = showGemsEnchants and gearLevelInfo.gems and gearLevelInfo.gems[currentGemIndex]
		local gemColorData = gearLevelInfo.gemsColor and gearLevelInfo.gemsColor[currentGemIndex]
		local essenceData = showGemsEnchants and (not gemTextureID) and (gearLevelInfo.essences and gearLevelInfo.essences[currentEssenceIndex])

		if gemTextureID then
			ApplyOverlayIconTexture(slotIconTexture, gemTextureID)
			iconBackgroundFrame.gemLink = itemLink and C_Item_GetItemGem and select(2, C_Item_GetItemGem(itemLink, currentGemIndex)) or nil
			if gemColorData then
				iconBackgroundFrame.KKUI_Border:SetVertexColor(gemColorData.r, gemColorData.g, gemColorData.b)
			else
				iconBackgroundFrame.KKUI_Border:SetVertexColor(1, 1, 1)
			end
			assertGemOverlayLevel(parentSlotFrame, slotIconTexture)
			iconBackgroundFrame:Show()
			currentGemIndex = currentGemIndex + 1
		elseif essenceData and next(essenceData) then
			local colorR, colorG, colorB = essenceData[4], essenceData[5], essenceData[6]
			if colorR and colorG and colorB then
				iconBackgroundFrame.KKUI_Border:SetVertexColor(colorR, colorG, colorB)
			else
				iconBackgroundFrame.KKUI_Border:SetVertexColor(1, 1, 1)
			end

			ApplyOverlayIconTexture(slotIconTexture, essenceData[1])
			iconBackgroundFrame.gemLink = nil
			assertGemOverlayLevel(parentSlotFrame, slotIconTexture)
			iconBackgroundFrame:Show()
			currentEssenceIndex = currentEssenceIndex + 1
		else
			ApplyOverlayIconTexture(slotIconTexture, nil)
			iconBackgroundFrame.gemLink = nil
			iconBackgroundFrame:Hide()
		end
	end
end

function Module:refreshSlotItemLevelDisplay(itemLink, targetUnit, slotIndex, parentSlotFrame, fullScan)
	_G.C_Timer.After(0.1, function()
		if not UnitExists(targetUnit) then
			return
		end
		local liveLink = GetInventoryItemLink(targetUnit, slotIndex) or itemLink
		if not liveLink then
			return
		end
		local itemQuality = select(3, getItemInfoCompat(liveLink))
		local gearLevelInfo = K.GetItemLevel(liveLink, targetUnit, slotIndex, fullScan)
		Module:updateSlotItemLevelDisplay(parentSlotFrame, gearLevelInfo, itemQuality, liveLink, targetUnit)
	end)
end

function Module:setupGearItemLevelDisplay(parentFrame, prefixName, targetUnit)
	if not UnitExists(targetUnit) then
		return
	end

	Module:createSlotItemLevelStrings(parentFrame, prefixName)
	local fullScan = shouldFullScanGemsEnchants()

	for slotIndex, slotToken in ipairs(INVENTORY_SLOT_NAMES) do
		if slotIndex ~= 4 then
			local slotFrame = _G[prefixName .. slotToken .. "Slot"]
			if slotFrame then
				slotFrame.iLvlText:SetText("")
				slotFrame.enchantText:SetText("")

				if slotFrame.noEnchantTexture then
					slotFrame.noEnchantTexture:Hide()
					slotFrame.noEnchantTexture.bg:Hide()
				end

				for i = 1, 10 do
					local iconTexture = slotFrame["textureIcon" .. i]
					ApplyOverlayIconTexture(iconTexture, nil)
					iconTexture.bg.gemLink = nil
					iconTexture.bg:Hide()
				end

				local itemLink = GetInventoryItemLink(targetUnit, slotIndex)
				if itemLink then
					local itemQuality = select(3, getItemInfoCompat(itemLink))
					-- Quality nil = tooltip cache still warming; retry shortly (old "tooSoon" path was dead).
					if not itemQuality then
						Module:refreshSlotItemLevelDisplay(itemLink, targetUnit, slotIndex, slotFrame, fullScan)
					else
						local gearLevelInfo = K.GetItemLevel(itemLink, targetUnit, slotIndex, fullScan)
						Module:updateSlotItemLevelDisplay(slotFrame, gearLevelInfo, itemQuality, itemLink, targetUnit)
					end
				end
			end
		end
	end
end

function Module:RefreshGearItemLevelOverlays()
	if not C["Misc"].ItemLevel then
		return
	end

	if _G.CharacterFrame and _G.CharacterFrame:IsShown() then
		Module:setupGearItemLevelDisplay(_G.CharacterFrame, "Character", "player")
	end

	local inspectFrame = _G.InspectFrame
	if inspectFrame and inspectFrame:IsShown() and inspectFrame.unit and UnitExists(inspectFrame.unit) then
		Module:setupGearItemLevelDisplay(inspectFrame, "Inspect", inspectFrame.unit)
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
-- Prefer Blizzard's inspect average when available; fall back to manual scan.
local function calculateAverageGearLevel(targetUnit, displayFontString)
	if not displayFontString then
		return
	end

	displayFontString:Hide()

	if C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
		local equippedItemLevel = C_PaperDollInfo.GetInspectItemLevel(targetUnit)
		if equippedItemLevel and NotSecret(equippedItemLevel) then
			displayFontString:SetFormattedText(ITEM_LEVEL_STRING, equippedItemLevel)
			displayFontString:Show()
			return
		end
	end

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
	local countedSlots = 0
	for i = 1, #gearItemListTable do
		local itemLevelValue = gearItemListTable[i]:GetCurrentItemLevel()
		if itemLevelValue then
			totalGearItemLevel = totalGearItemLevel + itemLevelValue
			countedSlots = countedSlots + 1
		end
	end

	if countedSlots == 0 then
		return
	end

	displayFontString:SetFormattedText(ITEM_LEVEL_STRING, totalGearItemLevel / totalScannedSlots)
	displayFontString:Show()
end

-- COMPAT: Dot syntax (not colon). K:RegisterEvent dispatches func(event, ...), so
-- INSPECT_READY passes (event, targetGUID) and the leading event must be ignored.
function Module.updateInspectFrameGearInfo(_, targetGUID)
	local inspectFrame = _G.InspectFrame
	if not (inspectFrame and inspectFrame.unit) then
		return
	end

	-- UnitGUID / event guid can be secret in instances; comparing secrets throws.
	local inspectGUID = UnitGUID(inspectFrame.unit)
	if not (NotSecret(inspectGUID) and NotSecret(targetGUID) and inspectGUID == targetGUID) then
		return
	end

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
			hooksecurefunc(scrappingButton, "RefreshIcon", onScrappingButtonUpdate)
			scrappingButton.iLvlHooked = true
		end
	end
end

local function onScrappingMachineLoaded(eventName, addonName)
	if addonName == "Blizzard_ScrappingMachineUI" then
		local machineFrame = _G.ScrappingMachineFrame
		if machineFrame then
			hooksecurefunc(machineFrame, "SetupScrapButtonPool", setupScrappingGearDisplay)
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
			modifiedChatLink = _G.gsub(itemLinkStr, "|h%[(.-)%]|h", "|h(" .. itemLevelValue .. ChatModule:GetItemGemInfo(itemLinkStr) .. ")" .. itemNameText .. "|h")
			addItemToGearLevelCache(itemLinkStr, modifiedChatLink)
		end
	end

	return modifiedChatLink
end

function Module.onGuildNewsTextUpdate(newsButton)
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

	hooksecurefunc(_G.GuildBankFrame, "Update", function(self)
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

	-- Live GUI re-fires this; only install hooks once, then refresh open frames.
	if Module._gearInfoHooksInstalled then
		Module:RefreshGearItemLevelOverlays()
		return
	end
	Module._gearInfoHooksInstalled = true

	_G.CharacterFrame:HookScript("OnShow", queuePlayerGearItemLevelUpdate)
	K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", queuePlayerGearItemLevelUpdate)

	K:RegisterEvent("INSPECT_READY", Module.updateInspectFrameGearInfo)

	hooksecurefunc("EquipmentFlyout_UpdateItems", function()
		for _, flyoutButton in pairs(_G.EquipmentFlyoutFrame.buttons) do
			if flyoutButton:IsShown() then
				setupFlyoutGearDisplay(flyoutButton)
			end
		end
	end)

	K:RegisterEvent("ADDON_LOADED", onScrappingMachineLoaded)

	hooksecurefunc("MerchantFrameItem_UpdateQuality", updateMerchantItemQuality)

	hooksecurefunc("TradeFrame_UpdatePlayerItem", updateTradePlayerItemLevel)
	hooksecurefunc("TradeFrame_UpdateTargetItem", updateTradeTargetItemLevel)

	hooksecurefunc("GuildNewsButton_SetText", Module.onGuildNewsTextUpdate)

	if _G.LootFrame and _G.LootFrame.ScrollBox then
		hooksecurefunc(_G.LootFrame.ScrollBox, "Update", onLootScrollUpdate)
	end

	K:RegisterEvent("ADDON_LOADED", onGuildBankLoaded)

	K:RegisterEvent("PLAYER_LOGOUT", function()
		table_wipe(gearLevelChatCache)
	end)

	Module:RefreshGearItemLevelOverlays()
end

Module:RegisterMisc("GearInfo", Module.createImprovedSlotItemLevelDisplay)
