local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")
local TT = K:GetModule("Tooltip")

-- LUA LOCALS
local _G = _G

local pairs = pairs
local ipairs = ipairs
local select = select
local next = next
local type = type
local tonumber = tonumber

local math_floor = math.floor

local strsub = string.sub
local strmatch = string.match
local strupper = string.upper
local gsub = string.gsub

local tinsert = table.insert
local wipe = wipe

-- WOW API LOCALS
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GameTooltip = GameTooltip

local UnitGUID = UnitGUID
local UnitExists = UnitExists
local UnitClass = UnitClass

local GetInventoryItemID = GetInventoryItemID
local GetInventoryItemLink = GetInventoryItemLink
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetCurrentGuildBankTab = GetCurrentGuildBankTab
local GetGuildBankItemLink = GetGuildBankItemLink

local IsSpellKnown = IsSpellKnown
local GetInspectSpecialization = GetInspectSpecialization

local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
local EquipmentManager_GetItemInfoByLocation = EquipmentManager_GetItemInfoByLocation

local INVSLOT_FIRST_EQUIPPED = INVSLOT_FIRST_EQUIPPED
local INVSLOT_LAST_EQUIPPED = INVSLOT_LAST_EQUIPPED
local INVSLOT_BODY = INVSLOT_BODY
local INVSLOT_TABARD = INVSLOT_TABARD
local INVSLOT_MAINHAND = INVSLOT_MAINHAND
local INVSLOT_OFFHAND = INVSLOT_OFFHAND
local EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION = EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION

local C_Item = C_Item
local C_Spell = C_Spell
local C_Timer = C_Timer
local C_TooltipInfo = C_TooltipInfo
local C_AddOns = C_AddOns
local Item = Item
local ItemLocation = ItemLocation

local C_AzeriteEmpoweredItem_IsPowerSelected = C_AzeriteEmpoweredItem.IsPowerSelected

-- GetItemInfo COMPAT
local _GetItemInfo = GetItemInfo
local C_Item_GetItemInfo = C_Item and C_Item.GetItemInfo

local function GetItemInfoCompat(item)
	if _GetItemInfo then
		return _GetItemInfo(item)
	end
	if C_Item_GetItemInfo then
		return C_Item_GetItemInfo(item)
	end
end

local C_Item_GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant

-- GLOBAL STRINGS
local ITEM_LEVEL = ITEM_LEVEL

-- SPELL INFO COMPAT
local GetSpellInfo
do
	local Classic_GetSpellInfo = _G.GetSpellInfo
	local C_Spell_GetSpellInfo = C_Spell and C_Spell.GetSpellInfo

	if C_Spell_GetSpellInfo then
		GetSpellInfo = function(spell)
			if not spell then
				return
			end

			local info = C_Spell_GetSpellInfo(spell)
			if not info then
				return
			end

			return info.name, info.rank, info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID, info.originalIconID
		end
	else
		GetSpellInfo = Classic_GetSpellInfo
	end
end

-- SLOTS
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

local function GetSlotDisplayName(slotToken)
	if not slotToken then
		return ""
	end

	local key = strupper(slotToken) .. "SLOT"
	local name = _G[key]
	if name and name ~= "" then
		return name
	end

	return gsub(slotToken, "(%l)(%u)", "%1 %2")
end

-- ANCHORS
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

-- TEXTURE HELPERS
function Module:CreateItemTexture(slot, point, x, y)
	local icon = slot:CreateTexture(nil, "OVERLAY")
	icon:SetPoint(point, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	icon.bg = CreateFrame("Frame", nil, slot)
	icon.bg:SetAllPoints(icon)
	icon.bg:SetFrameLevel(3)
	icon.bg:CreateBorder()
	icon.bg:Hide()

	return icon
end

-- ITEM STRING (HOVER EXPAND)
local function ItemString_OnEnter(self)
	self:SetWidth(0)
end

local function ItemString_OnLeave(self)
	self:SetWidth(120)
end

-- MISSING ENCHANT INDICATOR
local MISSING_ENCHANT_ICON_SIZE = 12
local MISSING_ENCHANT_ICON_DX_LEFT = 4
local MISSING_ENCHANT_ICON_DX_RIGHT = -4
local MISSING_ENCHANT_ICON_DY = 2

local MissingEnchantOffsets = {
	[16] = { dx = -4, dy = -2 }, -- MainHand example
	[17] = { dx = 4, dy = -2 }, -- OffHand example
}

local function MissingEnchant_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	local slotName = self.KKUI_SlotName
	if slotName and slotName ~= "" then
		GameTooltip:AddLine("Missing Enchant: " .. slotName, 1, 0.1, 0.1)
	else
		GameTooltip:AddLine("Missing Enchant", 1, 0.1, 0.1)
	end

	GameTooltip:Show()
end

local function MissingEnchant_OnLeave()
	GameTooltip:Hide()
end

function Module:GetMissingEnchantAnchor(index, point, x, y)
	local dx = (x and x > 0) and MISSING_ENCHANT_ICON_DX_LEFT or MISSING_ENCHANT_ICON_DX_RIGHT
	local dy = MISSING_ENCHANT_ICON_DY

	local o = index and MissingEnchantOffsets[index]
	if o then
		if o.dx ~= nil then
			dx = o.dx
		end
		if o.dy ~= nil then
			dy = o.dy
		end
	end

	return point, (x or 0) + dx, (y or 0) + dy
end

function Module:EnsureMissingEnchantIcon(slotFrame, slotToken, point, x, y)
	local tex = slotFrame.noEnchantTexture
	if not tex then
		tex = slotFrame:CreateTexture(nil, "OVERLAY")
		tex:SetSize(MISSING_ENCHANT_ICON_SIZE, MISSING_ENCHANT_ICON_SIZE)
		tex:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		tex:Hide()

		local hit = CreateFrame("Frame", nil, slotFrame)
		hit:SetAllPoints(tex)
		hit:SetFrameLevel(slotFrame:GetFrameLevel())
		hit:CreateBorder()
		hit:EnableMouse(true)
		hit:SetScript("OnEnter", MissingEnchant_OnEnter)
		hit:SetScript("OnLeave", MissingEnchant_OnLeave)
		hit:Hide()

		tex.bg = hit
		slotFrame.noEnchantTexture = tex
	end

	tex.bg.KKUI_SlotName = GetSlotDisplayName(slotToken)

	tex:ClearAllPoints()
	tex:SetPoint(point, slotFrame, x, y)
	tex.bg:SetAllPoints(tex)

	return tex
end

-- CREATE STRINGS/ICONS ON SLOTS
function Module:CreateItemString(frame, strType)
	if frame.fontCreated then
		return
	end

	for index, slot in ipairs(inspectSlots) do
		if index ~= 4 then
			local slotFrame = _G[strType .. slot .. "Slot"]

			slotFrame.iLvlText = K.CreateFontString(slotFrame, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
			slotFrame.iLvlText:ClearAllPoints()
			slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)

			local point, x, y = Module:GetSlotAnchor(index)

			slotFrame.enchantText = K.CreateFontString(slotFrame, 11)
			slotFrame.enchantText:ClearAllPoints()
			slotFrame.enchantText:SetPoint(point, slotFrame, x, y)
			slotFrame.enchantText:SetJustifyH(strsub(point, 7))
			slotFrame.enchantText:SetWidth(120)
			slotFrame.enchantText:EnableMouse(true)
			slotFrame.enchantText:HookScript("OnEnter", ItemString_OnEnter)
			slotFrame.enchantText:HookScript("OnLeave", ItemString_OnLeave)
			slotFrame.enchantText:HookScript("OnShow", ItemString_OnLeave)

			local ePoint, eX, eY = Module:GetMissingEnchantAnchor(index, point, x, y)
			Module:EnsureMissingEnchantIcon(slotFrame, slot, ePoint, eX, eY)

			for i = 1, 10 do
				local offset = (i - 1) * 20 + 5
				local iconX = x > 0 and x + offset or x - offset
				local iconY = index > 15 and 20 or 2
				slotFrame["textureIcon" .. i] = Module:CreateItemTexture(slotFrame, point, iconX, iconY)
			end
		end
	end

	frame.fontCreated = true
end

-- AZERITE TRAITS
local azeriteSlots = {
	[1] = true,
	[3] = true,
	[5] = true,
}

-- CACHE
local locationCache = {}
local itemCache = {}
local ITEM_CACHE_MAX_SIZE = 500
local itemCacheSize = 0

local function ClearCaches()
	wipe(locationCache)
	wipe(itemCache)
	itemCacheSize = 0
end

local function GetSlotItemLocation(id)
	if not azeriteSlots[id] then
		return
	end

	local loc = locationCache[id]
	if not loc then
		loc = ItemLocation:CreateFromEquipmentSlot(id)
		locationCache[id] = loc
	end
	return loc
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
			if C_AzeriteEmpoweredItem_IsPowerSelected(empoweredItemLocation, powerID) then
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

-- ENCHANTABLE SLOTS
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

local function IsOffhandEnchantable(unit, slot)
	local link = GetInventoryItemLink(unit, slot)
	if link then
		local itemEquipLoc = select(4, C_Item_GetItemInfoInstant(link))
		return itemEquipLoc ~= "INVTYPE_HOLDABLE" and itemEquipLoc ~= "INVTYPE_SHIELD"
	end
	return false
end

function Module:CanEnchantSlot(unit, slot)
	if slot == INVSLOT_OFFHAND then
		return IsOffhandEnchantable(unit, slot)
	end

	local link = GetInventoryItemLink(unit, slot)
	if link then
		local itemEquipLoc = select(4, C_Item_GetItemInfoInstant(link))
		return IsEnchantableSlots[itemEquipLoc] or false
	end

	return false
end

-- UPDATE SLOT DISPLAY
function Module:ItemLevel_UpdateInfo(slotFrame, info, quality)
	local infoType = type(info)
	local level = (infoType == "table") and info.iLvl or info

	if level and level > 1 and quality and quality > 1 then
		local color = K.QualityColors[quality]
		slotFrame.iLvlText:SetText(level)
		slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
	else
		slotFrame.iLvlText:SetText("")
	end

	if infoType ~= "table" then
		return
	end

	-- ENCHANT TEXT / MISSING ENCHANT ICON
	local enchant = info.enchantText
	if enchant and enchant ~= "" then
		slotFrame.enchantText:SetText(enchant)
		slotFrame.enchantText:SetTextColor(0, 1, 0)

		slotFrame.noEnchantTexture:Hide()
		slotFrame.noEnchantTexture.bg:Hide()
	elseif Module:CanEnchantSlot("player", slotFrame:GetID()) then
		slotFrame.enchantText:SetText("")

		slotFrame.noEnchantTexture:SetTexture("Interface\\Icons\\inv_enchant_formulasuperior_01")
		slotFrame.noEnchantTexture:SetVertexColor(1, 0.1, 0.1, 1)
		slotFrame.noEnchantTexture:SetDesaturated(true)
		slotFrame.noEnchantTexture:Show()

		-- if slotFrame.noEnchantTexture.bg and slotFrame.noEnchantTexture.bg.KKUI_Border then
		-- 	slotFrame.noEnchantTexture.bg.KKUI_Border:SetVertexColor(1, 0.1, 0.1)
		-- end
		slotFrame.noEnchantTexture.bg:Show()
	else
		slotFrame.enchantText:SetText("")
		slotFrame.noEnchantTexture:Hide()
		slotFrame.noEnchantTexture.bg:Hide()
	end

	-- GEMS / ESSENCES
	local gemStep, essenceStep = 1, 1
	for i = 1, 10 do
		local texture = slotFrame["textureIcon" .. i]
		local bg = texture.bg

		local gem = info.gems and info.gems[gemStep]
		local color = info.gemsColor and info.gemsColor[gemStep]
		local essence = (not gem) and (info.essences and info.essences[essenceStep])

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
			local r, g, b = essence[4], essence[5], essence[6]
			if r and g and b then
				bg.KKUI_Border:SetVertexColor(r, g, b)
			else
				bg.KKUI_Border:SetVertexColor(1, 1, 1)
			end

			texture:SetTexture(essence[1])
			bg:Show()

			essenceStep = essenceStep + 1
		else
			texture:SetTexture(nil)
			bg:Hide()
		end
	end
end

function Module:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
	C_Timer.After(0.1, function()
		local quality = select(3, GetItemInfoCompat(link))
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

	for index, slot in ipairs(inspectSlots) do
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
				local quality = select(3, GetItemInfoCompat(link))
				local info = K.GetItemLevel(link, unit, index, C["Misc"].GemEnchantInfo)

				if info == "tooSoon" then
					Module:ItemLevel_RefreshInfo(link, unit, index, slotFrame)
				else
					Module:ItemLevel_UpdateInfo(slotFrame, info, quality)
				end

				if strType == "Character" then
					Module:ItemLevel_UpdateTraits(slotFrame, index, link)
				end
			else
				slotFrame.noEnchantTexture:Hide()
				slotFrame.noEnchantTexture.bg:Hide()
			end
		end
	end
end

-- PLAYER_EQUIPMENT_CHANGED can fire in bursts (swap sets, multi-slot updates).
-- Coalesce to a single update to keep spikes down.
local queuedPlayerILvlUpdate = false
local function UpdatePlayerItemLevelNow()
	queuedPlayerILvlUpdate = false
	Module:ItemLevel_SetupLevel(CharacterFrame, "Character", "player")
end

local function QueuePlayerItemLevelUpdate()
	if queuedPlayerILvlUpdate then
		return
	end

	queuedPlayerILvlUpdate = true
	C_Timer.After(0.05, UpdatePlayerItemLevelNow)
end

-- AVG ITEM LEVEL (INSPECT)
local itemsTable = {}

local function CalculateAverageItemLevel(unit, fontstring)
	if not fontstring then
		return
	end

	fontstring:Hide()
	wipe(itemsTable)

	local mainhandEquipLoc, offhandEquipLoc

	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then
			local itemID = GetInventoryItemID(unit, slot)
			local itemLink = GetInventoryItemLink(unit, slot)

			if itemLink or itemID then
				local item = itemLink and Item:CreateFromItemLink(itemLink) or Item:CreateFromItemID(itemID)
				tinsert(itemsTable, item)

				local equipLoc = select(4, C_Item_GetItemInfoInstant(itemLink or itemID))
				if slot == INVSLOT_MAINHAND then
					mainhandEquipLoc = equipLoc
				elseif slot == INVSLOT_OFFHAND then
					offhandEquipLoc = equipLoc
				end
			end
		end
	end

	local numSlots = (mainhandEquipLoc and offhandEquipLoc) and 16 or 15

	local _, className = UnitClass(unit)
	if className == "WARRIOR" then
		local isFury
		if unit == "player" then
			isFury = IsSpellKnown(46917) -- Titan's Grip
		else
			isFury = GetInspectSpecialization and (GetInspectSpecialization(unit) == 72)
		end

		if isFury then
			numSlots = 16
		end
	end

	local totalLevel = 0
	for i = 1, #itemsTable do
		local itemLevel = itemsTable[i]:GetCurrentItemLevel()
		if itemLevel then
			totalLevel = totalLevel + itemLevel
		end
	end

	fontstring:SetFormattedText(ITEM_LEVEL, totalLevel / numSlots)
	fontstring:Show()
end

function Module:ItemLevel_UpdateInspect(...)
	local guid = ...
	local InspectFrame = _G.InspectFrame
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		Module:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)

		if not InspectFrame.AvgItemLevelText then
			local InspectModelFrame = _G.InspectModelFrame
			if InspectModelFrame then
				InspectFrame.AvgItemLevelText = K.CreateFontString(InspectModelFrame, 12, "", "OUTLINE", false, "BOTTOM", 0, 46)
			end
		end

		if InspectFrame.AvgItemLevelText then
			CalculateAverageItemLevel(InspectFrame.unit or "target", InspectFrame.AvgItemLevelText)
		end

		local InspectModelFrameControlFrame = _G.InspectModelFrameControlFrame
		if InspectModelFrameControlFrame then
			InspectModelFrameControlFrame:HookScript("OnShow", InspectModelFrameControlFrame.Hide)
		end
	end
end

-- FLYOUT
local function Flyout_Update(button, bag, slot, quality)
	if not button.iLvl then
		button.iLvl = K.CreateFontString(button, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end

	if quality and quality <= 1 then
		button.iLvl:SetText("")
		return
	end

	local link, level
	if bag then
		link = C_Container.GetContainerItemLink(bag, slot)
		level = K.GetItemLevel(link, bag, slot)
	else
		link = GetInventoryItemLink("player", slot)
		level = K.GetItemLevel(link, "player", slot)
	end

	local color = K.QualityColors[quality or 0]
	button.iLvl:SetText(level or "")
	button.iLvl:SetTextColor(color.r, color.g, color.b)
end

local function Flyout_Setup(button)
	if button.iLvl then
		button.iLvl:SetText("")
	end

	local location = button.location
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
			Flyout_Update(button, bag, slot, quality)
		else
			Flyout_Update(button, nil, slot, quality)
		end
	else
		local itemLocation = button:GetItemLocation()
		local quality = itemLocation and C_Item.GetItemQuality(itemLocation)
		if itemLocation and itemLocation:IsBagAndSlot() then
			local bag, slot = itemLocation:GetBagAndSlot()
			Flyout_Update(button, bag, slot, quality)
		elseif itemLocation and itemLocation:IsEquipmentSlot() then
			local slot = itemLocation:GetEquipmentSlot()
			Flyout_Update(button, nil, slot, quality)
		end
	end
end

-- SCRAPPING
local function Scrapping_Update(button)
	if not button.iLvl then
		button.iLvl = K.CreateFontString(button, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end

	if not button.itemLink then
		button.iLvl:SetText("")
		return
	end

	local quality = 1
	if button.itemLocation and button.item and not button.item:IsItemEmpty() and button.item:GetItemName() then
		quality = button.item:GetItemQuality()
	end

	local level = K.GetItemLevel(button.itemLink)
	if level then
		local color = K.QualityColors[quality]
		button.iLvl:SetText(level)
		button.iLvl:SetTextColor(color.r, color.g, color.b)
	else
		button.iLvl:SetText("")
	end
end

local function Scrapping_Setup(frame)
	if not frame or not frame.ItemSlots then
		return
	end

	for button in frame.ItemSlots.scrapButtons:EnumerateActive() do
		if button and not button.iLvlHooked then
			hooksecurefunc(button, "RefreshIcon", Scrapping_Update)
			button.iLvlHooked = true
		end
	end
end

local function Scrapping_OnAddonLoaded(event, addon)
	if addon == "Blizzard_ScrappingMachineUI" then
		local ScrappingMachineFrame = _G.ScrappingMachineFrame
		if ScrappingMachineFrame then
			hooksecurefunc(ScrappingMachineFrame, "SetupScrapButtonPool", Scrapping_Setup)
			Scrapping_Setup(ScrappingMachineFrame)
		end

		K:UnregisterEvent(event, Scrapping_OnAddonLoaded)
	end
end

-- MERCHANT / TRADE
local function Merchant_UpdateQuality(button, link)
	if not button or not button.GetName then
		return
	end

	if not button.iLvl then
		button.iLvl = K.CreateFontString(_G[button:GetName() .. "ItemButton"], 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end

	local quality = link and select(3, GetItemInfoCompat(link)) or nil
	if quality and quality > 1 then
		local level = K.GetItemLevel(link)
		local color = K.QualityColors[quality]
		button.iLvl:SetText(level or "")
		button.iLvl:SetTextColor(color.r, color.g, color.b)
	else
		button.iLvl:SetText("")
	end
end

local function Trade_UpdatePlayerItem(index)
	local button = _G["TradePlayerItem" .. index]
	local link = GetTradePlayerItemLink(index)
	Merchant_UpdateQuality(button, link)
end

local function Trade_UpdateTargetItem(index)
	local button = _G["TradeRecipientItem" .. index]
	local link = GetTradeTargetItemLink(index)
	Merchant_UpdateQuality(button, link)
end

-- CHAT LINK REPLACE
local chatModule = K:GetModule("Chat")

local function AddToItemCache(link, modLink)
	if itemCacheSize >= ITEM_CACHE_MAX_SIZE then
		wipe(itemCache)
		itemCacheSize = 0
	end

	itemCache[link] = modLink
	itemCacheSize = itemCacheSize + 1
end

local function ReplaceItemLink(link, name)
	if not chatModule or not link then
		return
	end

	local modLink = itemCache[link]
	if not modLink then
		local itemLevel = K.GetItemLevel(link)
		if itemLevel then
			modLink = gsub(link, "|h%[(.-)%]|h", "|h(" .. itemLevel .. chatModule.IsItemHasGem(link) .. ")" .. name .. "|h")
			AddToItemCache(link, modLink)
		end
	end

	return modLink
end

local function GuildNews_ReplaceText(button)
	if not button or not button.text or not button.text.GetText then
		return
	end

	local newText = gsub(button.text:GetText(), "(|Hitem:%d+:.-|h%[(.-)%]|h)", ReplaceItemLink)
	if newText then
		button.text:SetText(newText)
	end
end

-- LOOT
local lootChildrenTable = {}

local function Loot_Update(scrollBox)
	if not scrollBox or not scrollBox.ScrollTarget then
		return
	end

	local numChildren = scrollBox.ScrollTarget:GetNumChildren()
	if numChildren == 0 then
		return
	end

	wipe(lootChildrenTable)
	local temp = { scrollBox.ScrollTarget:GetChildren() }
	for i = 1, numChildren do
		lootChildrenTable[i] = temp[i]
	end

	for i = 1, numChildren do
		local button = lootChildrenTable[i]
		if button and button.Item and button.GetElementData then
			if not button.iLvl then
				button.iLvl = K.CreateFontString(button.Item, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
			end

			local slotIndex = button:GetSlotIndex()
			local quality = select(5, GetLootSlotInfo(slotIndex))
			if quality and quality > 1 then
				local level = K.GetItemLevel(GetLootSlotLink(slotIndex))
				local color = K.QualityColors[quality]
				button.iLvl:SetText(level or "")
				button.iLvl:SetTextColor(color.r, color.g, color.b)
			else
				button.iLvl:SetText("")
			end
		end
	end
end

-- GUILD BANK
local NUM_SLOTS_PER_GUILDBANK_GROUP = 14
local PET_CAGE = 82800

local function GuildBank_OnAddonLoaded(event, addon)
	if addon ~= "Blizzard_GuildBankUI" then
		return
	end

	hooksecurefunc(_G.GuildBankFrame, "Update", function(self)
		if self.mode ~= "bank" then
			return
		end

		local tab = GetCurrentGuildBankTab()
		local numColumns = #self.Columns
		local totalSlots = numColumns * NUM_SLOTS_PER_GUILDBANK_GROUP

		for i = 1, totalSlots do
			local index = ((i - 1) % NUM_SLOTS_PER_GUILDBANK_GROUP) + 1
			local column = math_floor((i - 1) / NUM_SLOTS_PER_GUILDBANK_GROUP) + 1
			local button = self.Columns[column].Buttons[index]

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
							local speciesID = data.battlePetSpeciesID
							if speciesID and speciesID > 0 then
								level = data.battlePetLevel
								quality = data.battlePetBreedQuality
							end
						end
					else
						level = K.GetItemLevel(link)
						quality = select(3, GetItemInfoCompat(link))
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
					button.iLvl:SetText("")
				end
			end
		end
	end)

	K:UnregisterEvent(event, GuildBank_OnAddonLoaded)
end

-- INIT
function Module.CreateSlotItemLevel()
	if not C["Misc"].ItemLevel then
		return
	end

	if C_AddOns.IsAddOnLoaded("SimpleItemLevel") then
		return
	end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", QueuePlayerItemLevelUpdate)
	K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", QueuePlayerItemLevelUpdate)

	-- iLvl on InspectFrame
	K:RegisterEvent("INSPECT_READY", Module.ItemLevel_UpdateInspect)

	-- iLvl on FlyoutButtons
	hooksecurefunc("EquipmentFlyout_UpdateItems", function()
		for _, button in pairs(EquipmentFlyoutFrame.buttons) do
			if button:IsShown() then
				Flyout_Setup(button)
			end
		end
	end)

	-- iLvl on ScrappingMachineFrame
	K:RegisterEvent("ADDON_LOADED", Scrapping_OnAddonLoaded)

	-- iLvl on MerchantFrame
	hooksecurefunc("MerchantFrameItem_UpdateQuality", Merchant_UpdateQuality)

	-- iLvl on TradeFrame
	hooksecurefunc("TradeFrame_UpdatePlayerItem", Trade_UpdatePlayerItem)
	hooksecurefunc("TradeFrame_UpdateTargetItem", Trade_UpdateTargetItem)

	-- iLvl on GuildNews
	hooksecurefunc("GuildNewsButton_SetText", GuildNews_ReplaceText)

	-- iLvl on LootFrame
	if LootFrame and LootFrame.ScrollBox then
		hooksecurefunc(LootFrame.ScrollBox, "Update", Loot_Update)
	end

	-- iLvl on GuildBankFrame
	K:RegisterEvent("ADDON_LOADED", GuildBank_OnAddonLoaded)

	-- Clear caches on logout
	K:RegisterEvent("PLAYER_LOGOUT", ClearCaches)
end

Module:RegisterMisc("GearInfo", Module.CreateSlotItemLevel)
