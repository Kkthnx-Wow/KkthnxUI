--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/ItemInfo.lua
	Purpose:
		Show item level on gear tooltips. Retail prints it in the tooltip corner
		already, so this only fills the gap on older flavours (TBC Anniversary and
		friends) where the stock item tooltip leaves it off. Equippable gear only,
		since an item level on a potion is just noise.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- Retail already shows item level on item tooltips, so only run elsewhere.
if K.Client and K.Client.IsRetail then
	return
end

local Module = K:GetModule("Tooltip")

local _G = _G
local IsSecret = K.IsSecret
local GetItemInfo = (C_Item and C_Item.GetItemInfo) or _G.GetItemInfo
local GetDetailedItemLevelInfo = (C_Item and C_Item.GetDetailedItemLevelInfo) or _G.GetDetailedItemLevelInfo

-- Bags carry an equip location too, so skip them along with the empty string.
local function IsGear(equipLoc)
	return equipLoc and equipLoc ~= "" and equipLoc ~= "INVTYPE_BAG"
end

local function AddItemLevel(tt)
	if tt:IsForbidden() then
		return
	end
	local _, link = tt:GetItem()
	if not link then
		return
	end

	local _, _, quality, iLevel, _, _, _, _, equipLoc = GetItemInfo(link)
	if not IsGear(equipLoc) then
		return
	end

	local ilvl = (GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(link)) or iLevel
	if not ilvl or IsSecret(ilvl) or ilvl <= 0 then
		return
	end

	local r, g, b = 1, 1, 1
	if quality and C_Item and C_Item.GetItemQualityColor then
		local qr, qg, qb = C_Item.GetItemQualityColor(quality)
		if qr then
			r, g, b = qr, qg, qb
		end
	end

	-- Label in grey, value in the item's quality colour, to match our other lines.
	tt:AddDoubleLine(_G.ITEM_LEVEL_ABBR or "Item Level", ilvl, 0.6, 0.6, 0.6, r, g, b)
	tt:Show()
end

function Module:SetupItemLevel()
	if not C.Tooltip.ShowItemInfo then
		return
	end
	if not (TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType) then
		return
	end

	local watched = {
		[_G.GameTooltip] = true,
		[_G.ItemRefTooltip] = true,
		[_G.ShoppingTooltip1] = true,
		[_G.ShoppingTooltip2] = true,
	}

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt)
		if watched[tt] then
			AddItemLevel(tt)
		end
	end)
end
