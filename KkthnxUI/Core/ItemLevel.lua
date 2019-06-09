local K = unpack(select(2, ...))

local _G = _G
local next, math_max, table_wipe = next, math.max, table.wipe
local select, tonumber = select, tonumber
local string_format = string.format
local table_insert = table.insert

local ENCHANTED_TOOLTIP_LINE = _G.ENCHANTED_TOOLTIP_LINE
local GetAverageItemLevel = _G.GetAverageItemLevel
local GetCVarBool = _G.GetCVarBool
local GetInspectSpecialization = _G.GetInspectSpecialization
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetItemInfo = _G.GetItemInfo
local ITEM_LEVEL = _G.ITEM_LEVEL
local KkthnxUI_ScanTooltipTextLeft1 = _G.KkthnxUI_ScanTooltipTextLeft1
local RETRIEVING_ITEM_INFO = _G.RETRIEVING_ITEM_INFO
local UnitIsUnit = _G.UnitIsUnit

local MATCH_ITEM_LEVEL = ITEM_LEVEL:gsub("%%d", "(%%d+)")
local MATCH_ENCHANT = ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.+)")
local X2_INVTYPES, X2_EXCEPTIONS, ARMOR_SLOTS = {
	INVTYPE_2HWEAPON = true,
	INVTYPE_RANGEDRIGHT = true,
	INVTYPE_RANGED = true,
	}, {
	[2] = 19, -- wands, use INVTYPE_RANGEDRIGHT, but are 1H
}, {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}

function K.InspectGearSlot(line, lineText, enchantText, enchantColors, iLvl, itemLevelColors)
	local lr, lg, lb = line:GetTextColor()
	local tr, tg, tb = KkthnxUI_ScanTooltipTextLeft1:GetTextColor()
	local itemLevel = lineText and lineText:match(MATCH_ITEM_LEVEL)
	local enchant = lineText:match(MATCH_ENCHANT)
	if enchant then
		enchantText = string.utf8sub(enchant, 1, 18)
		enchantColors = {lr, lg, lb}
	end

	if itemLevel then
		iLvl = tonumber(itemLevel)
		itemLevelColors = {tr, tg, tb}
	end

	return iLvl, itemLevelColors, enchantText, enchantColors
end

function K.GetGearSlotInfo(unit, slot, deepScan)
	K.ScanTooltipTextures(true)
	K.ScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetInventoryItem(unit, slot)
	K.ScanTooltip:Show()

	local iLvl, enchantText, enchantColors, itemLevelColors, gems
	if deepScan then
		gems = K.ScanTooltipTextures(nil, true)
		for x = 1, K.ScanTooltip:NumLines() do
			local line = _G["KkthnxUI_ScanTooltipTextLeft"..x]
			if line then
				local lineText = line:GetText()
				if x == 1 and lineText == RETRIEVING_ITEM_INFO then
					return "tooSoon"
				else
					iLvl, itemLevelColors, enchantText, enchantColors = K.InspectGearSlot(line, lineText, enchantText, enchantColors, iLvl, itemLevelColors)
				end
			end
		end
	else
		local firstLine = _G.KkthnxUI_ScanTooltipTextLeft1:GetText()
		if firstLine == RETRIEVING_ITEM_INFO then
			return "tooSoon"
		end

		local colorblind = GetCVarBool("colorblindmode") and 4 or 3
		for x = 2, colorblind do
			local line = _G["KkthnxUI_ScanTooltipTextLeft"..x]
			if line then
				local lineText = line:GetText()
				local itemLevel = lineText and lineText:match(MATCH_ITEM_LEVEL)
				if itemLevel then
					iLvl = tonumber(itemLevel)
				end
			end
		end
	end

	K.ScanTooltip:Hide()
	return iLvl, enchantText, deepScan and gems, enchantColors, itemLevelColors
end

-- Credit ls & Acidweb
function K.CalculateAverageItemLevel(iLevelDB, unit)
	local spec = GetInspectSpecialization(unit)
	local isOK, total, link = true, 0

	if not spec or spec == 0 then
		isOK = false
	end

	-- Armor
	for _, id in next, ARMOR_SLOTS do
		link = GetInventoryItemLink(unit, id)
		if link then
			local cur = iLevelDB[id]
			if cur and cur > 0 then
				total = total + cur
			end
		elseif GetInventoryItemTexture(unit, id) then
			isOK = false
		end
	end

	-- Main hand
	local mainItemLevel, mainQuality, mainEquipLoc, mainItemClass, mainItemSubClass, _ = 0
	link = GetInventoryItemLink(unit, 16)
	if link then
		mainItemLevel = iLevelDB[16]
		_, _, mainQuality, _, _, _, _, _, mainEquipLoc, _, _, mainItemClass, mainItemSubClass = GetItemInfo(link)
	elseif GetInventoryItemTexture(unit, 16) then
		isOK = false
	end

	-- Off hand
	local offItemLevel, offEquipLoc = 0
	link = GetInventoryItemLink(unit, 17)
	if link then
		offItemLevel = iLevelDB[17]
		_, _, _, _, _, _, _, _, offEquipLoc = GetItemInfo(link)
	elseif GetInventoryItemTexture(unit, 17) then
		isOK = false
	end

	if mainItemLevel and offItemLevel then
		if (mainQuality == 6) or (not offEquipLoc and X2_INVTYPES[mainEquipLoc] and X2_EXCEPTIONS[mainItemClass] ~= mainItemSubClass and spec ~= 72) then
			mainItemLevel = math_max(mainItemLevel, offItemLevel)
			total = total + mainItemLevel * 2
		else
			total = total + mainItemLevel + offItemLevel
		end
	end

	-- at the beginning of an arena match no info might be available,
	-- so despite having equipped gear a person may appear naked
	if total == 0 then
		isOK = false
	end

	return isOK and string_format("%0.2f", K.Round(total / 16, 2))
end

function K.GetPlayerItemLevel()
	return string_format("%0.2f", K.Round((select(2, GetAverageItemLevel())), 2))
end

local iLevelDB = {}
function K.GetUnitItemLevel(unit)
	if UnitIsUnit("player", unit) then
		return K.GetPlayerItemLevel()
	end

	table_wipe(iLevelDB)
	local tryAgain
	for i = 1, 17 do
		if i ~= 4 then
			local iLvl = K.GetGearSlotInfo(unit, i)
			if iLvl == "tooSoon" then
				if not tryAgain then tryAgain = {} end
				table_insert(tryAgain, i)
			else
				iLevelDB[i] = iLvl
			end
		end
	end

	if tryAgain then
		return "tooSoon", unit, tryAgain, iLevelDB
	end

	return K.CalculateAverageItemLevel(iLevelDB, unit)
end