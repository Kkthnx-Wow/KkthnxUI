--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Bag button that finds/destroys the cheapest vendor-sellable item.
-- - Design: Left-click prompts StaticPopup; right-click reports only. Re-verify
--   bag/slot on accept so a shuffle between prompt and confirm can't delete wrong.
--   Vendor sell price + stackCount have no SecretReturns (Resources 12.0.7).
-- - Events: BAG_UPDATE_DELAYED (retry until BagItemSearchBox exists)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Bags")

local select = select
local unpack = unpack
local format = string.format
local CreateFrame = CreateFrame

local C_Container = C_Container
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_PickupContainerItem = C_Container.PickupContainerItem
local C_Item_GetItemInfo = C_Item.GetItemInfo
local DeleteCursorItem = DeleteCursorItem
local GameTooltip = GameTooltip
local StaticPopupDialogs = StaticPopupDialogs
local StaticPopup_Show = StaticPopup_Show

local BACKPACK_CONTAINER = BACKPACK_CONTAINER
local NUM_BAG_SLOTS = NUM_BAG_SLOTS

local FILTER_KEYS = {
	[Enum.ItemClass.Consumable] = "DeleteCheapestFilterConsumable",
	[Enum.ItemClass.Container] = "DeleteCheapestFilterContainer",
	[Enum.ItemClass.Weapon] = "DeleteCheapestFilterWeapon",
	[Enum.ItemClass.Armor] = "DeleteCheapestFilterArmor",
	[Enum.ItemClass.Reagent] = "DeleteCheapestFilterReagent",
	[Enum.ItemClass.Tradegoods] = "DeleteCheapestFilterTradeskill",
	[Enum.ItemClass.Questitem] = "DeleteCheapestFilterQuest",
}

local GOBLIN_ICON = 463874
local BUTTON_ATLAS = {
	normal = "common-button-tertiary-square-normal",
	pushed = "common-button-tertiary-square-pressed",
	hover = "common-button-tertiary-square-hover",
}

local button
local eventsRegistered = false

local function AtlasOK(name)
	return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name) ~= nil
end

local function IsFiltered(link)
	local classID = select(12, C_Item_GetItemInfo(link))
	if not classID then
		return false
	end
	local key = FILTER_KEYS[classID]
	return key ~= nil and C["Inventory"][key]
end

local function FindCheapest()
	local bestLink, bestValue, bestCount, bestBag, bestSlot

	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		for slot = 1, C_Container_GetContainerNumSlots(bag) do
			local info = C_Container_GetContainerItemInfo(bag, slot)
			if info and not info.hasNoValue and info.hyperlink then
				local sellPrice = select(11, C_Item_GetItemInfo(info.hyperlink))
				-- sellPrice / stackCount: no SecretReturns in Resources 12.0.7.
				if sellPrice and sellPrice > 0 and not IsFiltered(info.hyperlink) then
					local count = info.stackCount or 1
					local total = sellPrice
					if count > 1 then
						total = sellPrice * count
					end

					if not bestValue or total < bestValue then
						bestLink, bestValue, bestCount, bestBag, bestSlot = info.hyperlink, total, count, bag, slot
					end
				end
			end
		end
	end

	return bestLink, bestValue, bestCount, bestBag, bestSlot
end

local function ReportCheapest()
	local link, value, count = FindCheapest()
	if not (link and value) then
		K.Print(L["No sellable items were found in your bags."])
		return
	end
	if count and count > 1 then
		K.Print(format(L["Cheapest item: %s x%d, worth %s."], link, count, K.FormatMoney(value)))
	else
		K.Print(format(L["Cheapest item: %s, worth %s."], link, K.FormatMoney(value)))
	end
end

StaticPopupDialogs["KKUI_DELETE_CHEAPEST"] = {
	text = L["Delete the cheapest item in your bags?"] .. "|n|n%s",
	button1 = _G.YES,
	button2 = _G.NO,
	OnAccept = function(_, data)
		if not (data and data.bag and data.slot) then
			return
		end
		-- Re-verify the slot still holds the same item before destroying it.
		local info = C_Container_GetContainerItemInfo(data.bag, data.slot)
		if not info or info.hyperlink ~= data.link then
			K.Print(L["The item moved before it could be deleted - nothing was destroyed."])
			return
		end
		C_Container_PickupContainerItem(data.bag, data.slot)
		DeleteCursorItem()
		if data.count and data.count > 1 then
			K.Print(format(L["Deleted %s x%d, worth %s."], data.link, data.count, K.FormatMoney(data.value)))
		else
			K.Print(format(L["Deleted %s, worth %s."], data.link, K.FormatMoney(data.value)))
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	showAlert = true,
	preferredIndex = 3,
}

local function PromptDeleteCheapest()
	local link, value, count, bag, slot = FindCheapest()
	if not (link and bag and slot) then
		K.Print(L["No sellable items were found in your bags."])
		return
	end
	StaticPopup_Show("KKUI_DELETE_CHEAPEST", link, nil, { link = link, value = value, count = count, bag = bag, slot = slot })
end

local function Button_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(L["Delete Cheapest Item"], 1, 1, 1)
	GameTooltip:AddLine(L["Left-click: destroy the cheapest sellable item in your bags."], 1, 0.82, 0, true)
	GameTooltip:AddLine(L["Right-click: show the cheapest item without deleting it."], 1, 0.82, 0, true)
	GameTooltip:Show()
end

local function Button_OnLeave()
	GameTooltip:Hide()
end

local function Button_OnClick(_, mouseButton)
	if mouseButton == "RightButton" then
		ReportCheapest()
	else
		PromptDeleteCheapest()
	end
end

local function CreateButton()
	if button then
		return true
	end
	local searchBox = _G.BagItemSearchBox
	if not searchBox then
		return false
	end

	-- Parented to BagItemSearchBox so it follows combined bags / backpack layouts.
	button = CreateFrame("Button", "KKUI_DeleteCheapestButton", searchBox)
	button:SetSize(26, 24)
	button:SetPoint("TOPLEFT", searchBox, "TOPLEFT", -34, 1)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	if AtlasOK(BUTTON_ATLAS.normal) then
		button:SetNormalAtlas(BUTTON_ATLAS.normal)
		if AtlasOK(BUTTON_ATLAS.pushed) then
			button:SetPushedAtlas(BUTTON_ATLAS.pushed)
		end
		if AtlasOK(BUTTON_ATLAS.hover) then
			button:SetHighlightAtlas(BUTTON_ATLAS.hover)
		end

		local icon = button:CreateTexture(nil, "OVERLAY")
		local function PlaceIcon(dx, dy)
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", 4 + dx, -4 + dy)
			icon:SetPoint("BOTTOMRIGHT", -4 + dx, 4 + dy)
		end
		PlaceIcon(0, 0)
		icon:SetTexture(GOBLIN_ICON)
		icon:SetTexCoord(unpack(K.TexCoords))
		button.icon = icon

		button:SetScript("OnMouseDown", function()
			PlaceIcon(1, -1)
		end)
		button:SetScript("OnMouseUp", function()
			PlaceIcon(0, 0)
		end)
	else
		button:SetNormalTexture(GOBLIN_ICON)
		local normal = button:GetNormalTexture()
		if normal then
			normal:SetTexCoord(unpack(K.TexCoords))
		end
		button:SetPushedTexture(GOBLIN_ICON)
		local pushed = button:GetPushedTexture()
		if pushed then
			pushed:SetTexCoord(unpack(K.TexCoords))
			pushed:SetVertexColor(0.8, 0.8, 0.8)
		end
		button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD")
	end

	button:SetScript("OnEnter", Button_OnEnter)
	button:SetScript("OnLeave", Button_OnLeave)
	button:SetScript("OnClick", Button_OnClick)
	return true
end

local function OnBagUpdateDelayed()
	if CreateButton() and button then
		button:Show()
		K:UnregisterEvent("BAG_UPDATE_DELAYED", OnBagUpdateDelayed)
		eventsRegistered = false
	end
end

function Module:CreateDeleteCheapest()
	if not C["Inventory"].DeleteCheapest then
		if eventsRegistered then
			K:UnregisterEvent("BAG_UPDATE_DELAYED", OnBagUpdateDelayed)
			eventsRegistered = false
		end
		if button then
			button:Hide()
		end
		return
	end

	if CreateButton() and button then
		button:Show()
		return
	end

	if not eventsRegistered then
		eventsRegistered = true
		K:RegisterEvent("BAG_UPDATE_DELAYED", OnBagUpdateDelayed)
	end
end
