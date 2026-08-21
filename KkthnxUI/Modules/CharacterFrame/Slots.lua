--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/CharacterFrame/Slots.lua
	Purpose:
		Behaviour for the ItemButtonTemplate equipment slots the layout XML lays
		out. The icon, cooldown, and coloured quality ring come from Blizzard's own
		item-button helpers so the slots look native, while equipping and tooltips
		are wired here through PickupInventoryItem. Shared by the character and
		inspect windows, so the unit is read from the module rather than hard coded.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

if K.Client and K.Client.IsRetail then
	return
end

local Module = K:GetModule("CharacterFrame")

local _G = _G
local GameTooltip = GameTooltip
local PickupInventoryItem = PickupInventoryItem
local GetInventorySlotInfo = GetInventorySlotInfo
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemCooldown = GetInventoryItemCooldown
local SetItemButtonTexture = SetItemButtonTexture
local SetItemButtonQuality = SetItemButtonQuality
local CooldownFrame_Set = CooldownFrame_Set
local InCombatLockdown = InCombatLockdown

-- Which unit this sheet is showing. Character is always the player, inspect will
-- set Module.unit before it refreshes.
local function SheetUnit()
	return Module.unit or "player"
end

-- Wire one native ItemButton slot, keyed by its base slot name.
function Module:StyleSlot(button, base)
	local id, emptyTexture = GetInventorySlotInfo(base .. "Slot")
	button.slotID = id
	button.emptyTexture = emptyTexture
	button.Cooldown = button.Cooldown or _G[(button:GetName() or "") .. "Cooldown"]

	button:RegisterForDrag("LeftButton")
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	local function pickup()
		if InCombatLockdown() then
			return
		end
		-- Inspect is read only, so only the player's own slots equip.
		if SheetUnit() == "player" then
			PickupInventoryItem(button.slotID)
		end
	end
	button:SetScript("OnClick", pickup)
	button:SetScript("OnReceiveDrag", pickup)

	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		local hasItem = GameTooltip:SetInventoryItem(SheetUnit(), self.slotID)
		if not hasItem then
			GameTooltip:SetText(_G.EMPTY or "Empty")
		end
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function Module:UpdateSlot(button)
	local unit = SheetUnit()
	local texture = GetInventoryItemTexture(unit, button.slotID)

	-- Native icon: the equipped item, or the slot's own empty silhouette.
	SetItemButtonTexture(button, texture or button.emptyTexture)

	-- Native coloured quality ring, cleared on an empty slot.
	if SetItemButtonQuality then
		local quality = texture and GetInventoryItemQuality(unit, button.slotID) or nil
		SetItemButtonQuality(button, quality, GetInventoryItemLink(unit, button.slotID))
	end

	-- Cooldown swipe (trinkets, on-use items).
	if button.Cooldown then
		local start, duration, enable = GetInventoryItemCooldown(unit, button.slotID)
		CooldownFrame_Set(button.Cooldown, start, duration, enable)
	end
end
