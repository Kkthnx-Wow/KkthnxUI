--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/Loot.lua
	Purpose:
		Our own compact loot window in place of the stock pick-up list. Each item is
		one clean row: a quality bordered icon, the name in its quality colour, a
		stack count, a coin and quest marker where they belong, and the window edge
		lit to the best item in the pile. It follows the loot-under-mouse setting,
		moves with a mover, and closes itself the way the default window does.

		Only the manual list is replaced. Group loot rolls (need, greed, pass) stay
		on the game's own roll frames.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("Loot")

local _G = _G
local next = next
local max = math.max
local gsub = string.gsub

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GetCursorPosition = GetCursorPosition
local UIParent = UIParent

local CloseLoot = CloseLoot
local GetNumLootItems = GetNumLootItems
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local LootSlot = LootSlot
local IsFishingLoot = IsFishingLoot
local IsModifiedClick = IsModifiedClick
local HandleModifiedItemClick = HandleModifiedItemClick
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local CursorUpdate = CursorUpdate
local CursorOnUpdate = CursorOnUpdate
local ResetCursor = ResetCursor
local StaticPopup_Hide = StaticPopup_Hide
local GetCVarBool = C_CVar and C_CVar.GetCVarBool
local GetItemQualityColor = C_Item and C_Item.GetItemQualityColor
local IsSecret = K.IsSecret

local QUEST_BANG = TEXTURE_ITEM_QUEST_BANG
local BAG_ICON = 136511 -- Interface\PaperDoll\UI-PaperDoll-Slot-Bag, used for an empty pile

local frame

-- Border and text colour for an item quality. Common and unknown fall back to our
-- own border colour so a row never shows a bare black edge.
local function QualityColor(quality)
	local common = Enum.ItemQuality and Enum.ItemQuality.Common or 1
	if quality and not IsSecret(quality) and quality > common and GetItemQualityColor then
		local r, g, b = GetItemQualityColor(quality)
		if r then
			return r, g, b
		end
	end
	local c = C.General.BorderColor
	return c[1], c[2], c[3]
end

-- ---------------------------------------------------------------------------
-- Row scripts
-- ---------------------------------------------------------------------------

local function SlotEnter(slot)
	local id = slot:GetID()
	if GetNumLootItems() >= id then
		GameTooltip:SetOwner(slot, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(id)
		CursorUpdate(slot)
	end
	slot.hover:Show()
end

local function SlotLeave(slot)
	slot.hover:Hide()
	GameTooltip:Hide()
	ResetCursor()
end

local function SlotUpdate(slot)
	if GameTooltip:IsOwned(slot) then
		GameTooltip:SetOwner(slot, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot:GetID())
		CursorOnUpdate(slot)
	end
end

local function SlotClick(slot)
	local id = slot:GetID()
	if IsModifiedClick() then
		HandleModifiedItemClick(GetLootSlotLink(id))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(id)
	end
end

-- ---------------------------------------------------------------------------
-- Rows
-- ---------------------------------------------------------------------------

local function CreateSlot(id)
	local size = C.Loot.IconSize
	local slot = CreateFrame("Button", "KKUI_LootSlot" .. id, frame)
	slot:SetHeight(size)
	slot:SetPoint("LEFT", 6, 0)
	slot:SetPoint("RIGHT", -6, 0)
	slot:SetID(id)
	slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	slot:SetScript("OnEnter", SlotEnter)
	slot:SetScript("OnLeave", SlotLeave)
	slot:SetScript("OnShow", SlotUpdate)
	slot:SetScript("OnClick", SlotClick)

	-- A soft full-row highlight that only shows on hover.
	local hover = slot:CreateTexture(nil, "BACKGROUND")
	hover:SetAllPoints()
	hover:SetColorTexture(1, 1, 1, 0.08)
	hover:Hide()
	slot.hover = hover

	-- Icon on the left, with our quality border.
	local iconFrame = CreateFrame("Frame", nil, slot)
	iconFrame:SetSize(size, size)
	iconFrame:SetPoint("LEFT")
	K.CreateBorder(iconFrame)
	slot.iconFrame = iconFrame

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon:SetPoint("TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", -1, 1)
	slot.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	K.SetFont(count, 12, K.FontOutlineStyle())
	count:SetJustifyH("RIGHT")
	count:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", -2, 2)
	slot.count = count

	local quest = iconFrame:CreateTexture(nil, "OVERLAY")
	quest:SetTexture(QUEST_BANG)
	quest:SetPoint("TOPLEFT", 1, -1)
	quest:SetPoint("BOTTOMRIGHT", -1, 1)
	quest:Hide()
	slot.quest = quest

	local name = slot:CreateFontString(nil, "OVERLAY")
	K.SetFont(name, 13, K.FontOutlineStyle())
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", iconFrame, "RIGHT", 8, 0)
	name:SetPoint("RIGHT", slot, "RIGHT", -4, 0)
	name:SetNonSpaceWrap(false)
	name:SetWordWrap(false)
	slot.name = name

	frame.slots[id] = slot
	return slot
end

-- Stack the shown rows top to bottom and size the window to fit them.
local function AnchorSlots()
	local size = C.Loot.IconSize
	local shown = 0
	for _, slot in next, frame.slots do
		if slot:IsShown() then
			shown = shown + 1
			slot:ClearAllPoints()
			slot:SetPoint("LEFT", 6, 0)
			slot:SetPoint("RIGHT", -6, 0)
			slot:SetPoint("TOP", frame, "TOP", 0, -6 - (shown - 1) * (size + 4))
		end
	end
	frame:SetHeight(max(shown * (size + 4) + 8, size + 8))
end

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------

function Module:LOOT_OPENED(_, autoLoot)
	frame:Show()
	if not frame:IsShown() then
		CloseLoot(not autoLoot)
		return
	end

	if IsFishingLoot() then
		frame.title:SetText(L["Fishy Loot"] or "Fishy Loot")
	elseif UnitName("target") and not UnitIsFriend("player", "target") and UnitIsDead("target") then
		frame.title:SetText(UnitName("target"))
	else
		frame.title:SetText(LOOT or "Loot")
	end

	-- Open at the cursor when the game's loot-under-mouse setting or ours asks for
	-- it, otherwise sit on the mover.
	frame:ClearAllPoints()
	if C.Loot.UnderMouse or (GetCVarBool and GetCVarBool("lootUnderMouse")) then
		local scale = frame:GetEffectiveScale()
		local x, y = GetCursorPosition()
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (x / scale) - 40, (y / scale) + 20)
		frame:Raise()
	elseif frame.KKUI_Mover then
		frame:SetPoint("TOPLEFT", frame.KKUI_Mover, "TOPLEFT")
	end

	local widest, best = 0, 0
	local numItems = GetNumLootItems()
	if numItems > 0 then
		for i = 1, numItems do
			local slot = frame.slots[i] or CreateSlot(i)
			local texture, item, quantity, _, quality, _, isQuestItem, questID, isActive, isCoin = GetLootSlotInfo(i)
			local r, g, b = QualityColor(quality)

			-- Coin loot arrives as multi-line text, flatten it to one row.
			if isCoin and type(item) == "string" then
				item = gsub(item, "\n", ", ")
			end

			slot.icon:SetTexture(texture)
			slot.name:SetText(item or "")
			slot.name:SetTextColor(r, g, b)
			slot.iconFrame.KKUI_Border:SetVertexColor(r, g, b)

			slot.count:SetShown(quantity and quantity > 1)
			slot.count:SetText(quantity and quantity > 1 and quantity or "")

			-- A quest item that starts a quest shows the bang, plain quest items just
			-- keep the quality edge.
			slot.quest:SetShown(questID and not isActive and true or false)
			if questID or isQuestItem then
				slot.iconFrame.KKUI_Border:SetVertexColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])
			end

			widest = max(widest, slot.name:GetStringWidth())
			if quality and not IsSecret(quality) then
				best = max(best, quality)
			end

			slot:Enable()
			slot:Show()
		end
	else
		-- Nothing to take (a full bag, or an empty pile). Show one disabled row.
		local slot = frame.slots[1] or CreateSlot(1)
		local r, g, b = QualityColor(0)
		slot.icon:SetTexture(BAG_ICON)
		slot.iconFrame.KKUI_Border:SetVertexColor(r, g, b)
		slot.name:SetText(L["Nothing to loot"] or "Nothing to loot")
		slot.name:SetTextColor(r, g, b)
		slot.count:Hide()
		slot.quest:Hide()
		widest = max(widest, slot.name:GetStringWidth())
		slot:Disable()
		slot:Show()
	end

	AnchorSlots()
	frame:SetWidth(max(widest + C.Loot.IconSize + 40, C.Loot.Width))

	-- Light the window edge to the best quality in the pile.
	if frame.KKUI_Border then
		local r, g, b = QualityColor(best)
		frame.KKUI_Border:SetVertexColor(r, g, b)
	end
end

function Module:LOOT_SLOT_CLEARED(_, id)
	if not frame:IsShown() then
		return
	end
	local slot = frame.slots[id]
	if slot then
		slot:Hide()
	end
	AnchorSlots()
end

function Module:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	frame:Hide()
	for _, slot in next, frame.slots do
		slot:Hide()
	end
end

-- ---------------------------------------------------------------------------
-- Enable
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	if not C.Loot.Enable then
		return
	end

	frame = CreateFrame("Frame", "KKUI_LootFrame", UIParent)
	frame:SetSize(C.Loot.Width, C.Loot.IconSize + 8)
	frame:SetClampedToScreen(true)
	frame:SetToplevel(true)
	frame:SetFrameStrata("HIGH")
	frame:Hide()
	K.CreateGradientBackground(frame, 0.95)
	K.CreateBorder(frame)
	frame.slots = {}

	local title = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 13, K.FontOutlineStyle())
	title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 2, 4)
	frame.title = title

	frame:SetScript("OnHide", function()
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		CloseLoot()
	end)

	-- Move it like a bag window and register it with the mover system so the spot
	-- survives a reload and resets from the Move UI panel.
	K.CreateMover(frame, "LootFrame", L["Loot Frame"] or "Loot Frame", { "TOPLEFT", UIParent, "TOPLEFT", 420, -240 }, C.Loot.Width, C.Loot.IconSize + 8)
	if K.EnableFrameDrag then
		K.EnableFrameDrag(frame)
	end

	-- Take the loot events off the stock window and onto ours. Escape still closes
	-- our window because it is registered as a special frame.
	if _G.LootFrame then
		_G.LootFrame:UnregisterAllEvents()
	end
	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_CLOSED")

	tinsert(_G.UISpecialFrames, "KKUI_LootFrame")
end
