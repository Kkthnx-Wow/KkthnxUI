--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Append crafting reagent counts to item tooltips.
-- - Design: TooltipDataProcessor item post-call; schematic via GetRecipeSchematic.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Tooltip")

local floor = math.floor
local format = string.format
local ipairs = ipairs
local tonumber = tonumber
local hooksecurefunc = hooksecurefunc

local GetItemSpell = C_Item.GetItemSpell
local GetItemNameByID = C_Item.GetItemNameByID
local GetItemIconByID = C_Item.GetItemIconByID
local GetItemCount = C_Item.GetItemCount
local GetItemInfoInstant = C_Item.GetItemInfoInstant
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local GetRecipeSchematic = C_TradeSkillUI and C_TradeSkillUI.GetRecipeSchematic
local TooltipDataProcessor = TooltipDataProcessor
local GameTooltip = GameTooltip
local Enum = Enum
local ITEMS = _G.ITEMS

local HEADER = L["Crafting Reagents"]
local ICON_COORD = "0:0:64:64:5:59:5:59"
local CACHE_LIMIT = 200

local IGNORED_ITEMS = {
	[254267] = true, -- Fragmented Memento of Epoch Challenges
}

local QUANTITY_OVERRIDE = {
	[404592] = { [204340] = 30 },
	[428667] = { [211297] = 2 },
	[467635] = { [230905] = 2 },
	[468717] = { [231757] = 2 },
	[1283168] = { [268650] = 5 },
}

local reagentCache = {}
local reagentCacheCount = 0

local function CacheSet(key, value)
	if reagentCache[key] == nil then
		if reagentCacheCount >= CACHE_LIMIT then
			wipe(reagentCache)
			reagentCacheCount = 0
		end
		reagentCacheCount = reagentCacheCount + 1
	end
	reagentCache[key] = value
end

local function TooltipHasLine(tip, matchText)
	if not tip or not matchText then
		return false
	end
	for i = 1, tip:NumLines() do
		local fs = _G[tip:GetName() .. "TextLeft" .. i]
		local text = fs and fs:GetText()
		if text and K.NotSecret(text) and text == matchText then
			return true
		end
	end
	return false
end

local function ResolveReagents(itemID)
	if reagentCache[itemID] ~= nil then
		return reagentCache[itemID] or nil
	end

	if not GetRecipeSchematic then
		CacheSet(itemID, false)
		return
	end

	local _, _, _, _, _, classID = GetItemInfoInstant(itemID)
	local _, spellID = GetItemSpell(itemID)
	if not spellID or classID == 8 then
		CacheSet(itemID, false)
		return
	end

	local schematic = GetRecipeSchematic(spellID, false)
	if not schematic or not schematic.reagentSlotSchematics then
		CacheSet(itemID, false)
		return
	end

	local recipeID = schematic.recipeID
	local reagents = {}
	for _, slot in ipairs(schematic.reagentSlotSchematics) do
		if slot.required and slot.reagents and slot.reagents[1] then
			local first = slot.reagents[1]
			local entry = { quantityRequired = slot.quantityRequired or 1 }
			if first.itemID then
				entry.itemID = first.itemID
				local overrides = QUANTITY_OVERRIDE[recipeID]
				if overrides and overrides[first.itemID] then
					entry.quantityRequired = overrides[first.itemID]
				end
			elseif first.currencyID then
				entry.currencyID = first.currencyID
			else
				entry = nil
			end
			if entry then
				reagents[#reagents + 1] = entry
			end
		end
	end

	if #reagents == 0 then
		CacheSet(itemID, false)
		return
	end

	local info = {
		reagents = reagents,
		outputItemID = schematic.outputItemID,
	}
	CacheSet(itemID, info)
	return info
end

local function AppendReagents(tip, itemID)
	if not tip or tip:IsForbidden() or IGNORED_ITEMS[itemID] then
		return
	end
	if not C["Tooltip"].ItemReagents then
		return
	end
	if TooltipHasLine(tip, HEADER) then
		return
	end

	local info = ResolveReagents(itemID)
	if not info then
		return
	end

	local needsRefresh
	local maxOutput
	local multiple = #info.reagents > 1

	tip:AddLine(" ")
	tip:AddLine(HEADER, 1, 0.82, 0)

	for _, reagent in ipairs(info.reagents) do
		local name, count, icon
		local need = reagent.quantityRequired

		if reagent.itemID then
			name = GetItemNameByID(reagent.itemID)
			if not name or name == "" then
				needsRefresh = true
				name = format("%s %d", ITEMS or "Item", reagent.itemID)
			end
			count = GetItemCount(reagent.itemID, true, false, true, true)
			icon = GetItemIconByID(reagent.itemID)
			if multiple and reagent.itemID == itemID then
				name = "* " .. name
			end
		elseif reagent.currencyID then
			local currencyInfo = GetCurrencyInfo(reagent.currencyID)
			if currencyInfo then
				name = currencyInfo.name
				count = currencyInfo.quantity
				icon = currencyInfo.iconFileID
			end
		end

		if name then
			local qtyText = (count ~= nil and need ~= nil) and format("%s/%s", count, need) or nil
			if icon then
				name = format("|T%s:14:14:%s|t %s", icon, ICON_COORD, name)
			end
			if qtyText then
				if count >= need then
					tip:AddDoubleLine(name, qtyText, 1, 1, 1, 1, 1, 1)
					local batches = floor(count / need)
					if maxOutput then
						maxOutput = (batches < maxOutput) and batches or maxOutput
					else
						maxOutput = batches
					end
				else
					tip:AddDoubleLine(name, qtyText, 1, 0.125, 0.125, 1, 0.125, 0.125)
					maxOutput = 0
				end
			else
				tip:AddLine(name, 1, 1, 1)
			end
		end
	end

	if maxOutput and maxOutput > 1 and info.outputItemID then
		tip:AddLine(" ")
		tip:AddLine(format(L["Can Create Multiple Item Format"], maxOutput), 1, 0.82, 0, true)
	end

	if needsRefresh then
		C_Timer.After(0, function()
			if tip:IsShown() and not tip:IsForbidden() then
				-- Names may still be loading; user can re-hover.
			end
		end)
	end

	tip:Show()
end

function Module:CreateItemReagents()
	if Module._itemReagentsSetup then
		return
	end
	if not (TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType) then
		return
	end
	Module._itemReagentsSetup = true

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tip, data)
		if not C["Tooltip"].Enable or not C["Tooltip"].ItemReagents or tip:IsForbidden() then
			return
		end
		local id = data and data.id
		if id then
			AppendReagents(tip, id)
		end
	end)

	if GameTooltip.SetHyperlink then
		hooksecurefunc(GameTooltip, "SetHyperlink", function(tip, link)
			if not C["Tooltip"].Enable or not C["Tooltip"].ItemReagents or tip:IsForbidden() or not link then
				return
			end
			local id = tonumber(link:match("item:(%d+)"))
			if id then
				AppendReagents(tip, id)
			end
		end)
	end
end
