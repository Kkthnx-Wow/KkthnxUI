local K, C = unpack(select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G
local string_format = _G.string.format
local table_wipe = _G.table.wipe
local string_match = _G.string.match
local table_insert = _G.table.insert

local GetSpellInfo = _G.GetSpellInfo
local C_AzeriteEmpoweredItem_GetPowerInfo = _G.C_AzeriteEmpoweredItem.GetPowerInfo
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = _G.C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_AzeriteEmpoweredItem_GetAllTierInfoByItemID = _G.C_AzeriteEmpoweredItem.GetAllTierInfoByItemID
local IsAddOnLoaded = _G.IsAddOnLoaded

local tipList, powerList, powerCache, tierCache = {}, {}, {}, {}

local iconString = "|T%s:18:22:0:0:64:64:5:59:5:59"
local function getIconString(icon, known)
	if known then
		return string_format(iconString..":255:255:255|t", icon)
	else
		return string_format(iconString..":120:120:120|t", icon)
	end
end

function Module:Azerite_ScanTooltip()
	table_wipe(tipList)
	table_wipe(powerList)

	for i = 9, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		local text = line:GetText()
		local powerName = text and string_match(text, "%- (.+)")
		if powerName then
			table_insert(tipList, i)
			powerList[i] = powerName
		end
	end
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

function Module:Azerite_UpdateItem()
	local link = select(2, self:GetItem())
    if not link then
        return
	end

	local allTierInfo = Module:Azerite_UpdateTier(link)
	if not allTierInfo then
		return
	end

	Module.Azerite_ScanTooltip(self)
	if #tipList == 0 then
		return
	end

    local index = 1
	for i = 1, #allTierInfo do
		local powerIDs = allTierInfo[i].azeritePowerIDs
		if powerIDs[1] == 13 then
			break
		end

		local lineIndex = tipList[index]
		if not lineIndex then
			break
		end

		local tooltipText = ""
		for _, id in ipairs(powerIDs) do
			local spellID = Module:Azerite_PowerToSpell(id)
			if not spellID then
				break
			end

			local name, _, icon = GetSpellInfo(spellID)
			local found = name == powerList[lineIndex]
			if found then
				tooltipText = tooltipText.." "..getIconString(icon, true)
			else
				tooltipText = tooltipText.." "..getIconString(icon)
			end
		end

		if tooltipText ~= "" then
			local line = _G[self:GetName().."TextLeft"..lineIndex]
			-- if C["Tooltip"].OnlyArmorIcons then
			-- 	line:SetText(tooltipText)
			-- 	_G[self:GetName().."TextLeft"..lineIndex+1]:SetText("")
			-- else
				line:SetText(line:GetText().."\n "..tooltipText)
			--end
		end

		index = index + 1
	end
end

function Module:CreateTooltipAzerite()
    if not C["Tooltip"].AzeriteArmor then
        return
    end

    if IsAddOnLoaded("AzeriteTooltip") then
        return
    end

	GameTooltip:HookScript("OnTooltipSetItem", Module.Azerite_UpdateItem)
	ItemRefTooltip:HookScript("OnTooltipSetItem", Module.Azerite_UpdateItem)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", Module.Azerite_UpdateItem)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", Module.Azerite_UpdateItem)
	GameTooltipTooltip:HookScript("OnTooltipSetItem", Module.Azerite_UpdateItem)
end