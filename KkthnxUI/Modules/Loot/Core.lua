local K, C, L = unpack(KkthnxUI)
local Module = K:NewModule("Loot")

local _G = _G
local unpack = unpack
local tinsert = tinsert
local next = next
local max = max

local CloseLoot = CloseLoot
local CreateFrame = CreateFrame
local CursorOnUpdate = CursorOnUpdate
local CursorUpdate = CursorUpdate
local GameTooltip = GameTooltip
local GetCursorPosition = GetCursorPosition
local GetCVarBool = GetCVarBool
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetNumLootItems = GetNumLootItems
local IsFishingLoot = IsFishingLoot
local IsModifiedClick = IsModifiedClick
local LootSlotHasItem = LootSlotHasItem
local ResetCursor = ResetCursor
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitName = UnitName
local LootSlot = LootSlot

local StaticPopup_Hide = StaticPopup_Hide
local MasterLooterFrame_Show = MasterLooterFrame_Show
local MasterLooterFrame_UpdatePlayers = MasterLooterFrame_UpdatePlayers

local hooksecurefunc = hooksecurefunc
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG
local LOOT = LOOT

local iconSize, lootFrame, lootFrameHolder = 36

local coinTextureIDs = {
	[133784] = true,
	[133785] = true,
	[133786] = true,
	[133787] = true,
	[133788] = true,
	[133789] = true,
}

local function SlotEnter(slot)
	local id = slot:GetID()
	if LootSlotHasItem(id) then
		GameTooltip:SetOwner(slot, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(id)
		CursorUpdate(slot)
	end

	slot.drop:Show()
	slot.drop:SetVertexColor(1, 1, 0)
end

local function SlotLeave(slot)
	if slot.quality and (slot.quality > 1) then
		local color = ITEM_QUALITY_COLORS[slot.quality]
		slot.drop:SetVertexColor(color.r, color.g, color.b)
	else
		slot.drop:Hide()
	end

	GameTooltip:Hide()
	ResetCursor()
end

local function SlotClick(slot)
	local frame = _G.LootFrame
	frame.selectedQuality = slot.quality
	frame.selectedItemName = slot.name:GetText()
	frame.selectedTexture = slot.icon:GetTexture()
	frame.selectedLootButton = slot:GetName()
	frame.selectedSlot = slot:GetID()

	if IsModifiedClick() then
		_G.HandleModifiedItemClick(GetLootSlotLink(frame.selectedSlot))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(frame.selectedSlot)
	end
end

local function SlotShow(slot)
	if GameTooltip:IsOwned(slot) then
		GameTooltip:SetOwner(slot, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot:GetID())
		CursorOnUpdate(slot)
	end
end

local function FrameHide()
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	CloseLoot()

	if _G.MasterLooterFrame then
		_G.MasterLooterFrame:Hide()
	end
end

local function AnchorSlots(frame)
	local shownSlots = 0

	for _, slot in next, frame.slots do
		if slot:IsShown() then
			shownSlots = shownSlots + 1

			slot:SetPoint("TOP", lootFrame, 4, (-8 + iconSize) - (shownSlots * iconSize))
		end
	end

	frame:SetHeight(max(shownSlots * iconSize + 10, 20))
end

local function CreateSlot(id)
	local size = (iconSize - 6)

	local slot = CreateFrame("Button", "KKUI_LootSlot" .. id, lootFrame)
	slot:SetPoint("LEFT", 8, 0)
	slot:SetPoint("RIGHT", -8, 0)
	slot:SetHeight(size)
	slot:SetID(id)

	slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	slot:SetScript("OnEnter", SlotEnter)
	slot:SetScript("OnLeave", SlotLeave)
	slot:SetScript("OnClick", SlotClick)
	slot:SetScript("OnShow", SlotShow)

	local iconFrame = CreateFrame("Frame", nil, slot)
	iconFrame:SetSize(size, size)
	iconFrame:SetPoint("RIGHT", slot)
	iconFrame:CreateBorder()
	slot.iconFrame = iconFrame

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(unpack(K.TexCoords))
	icon:SetAllPoints()
	slot.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:SetJustifyH("RIGHT")
	count:SetPoint("BOTTOMRIGHT", iconFrame, -2, 2)
	count:SetFontObject(K.UIFontOutline)
	count:SetText(1)
	slot.count = count

	local name = slot:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", slot)
	name:SetPoint("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
	name:SetFontObject(K.UIFontOutline)
	slot.name = name

	local drop = slot:CreateTexture(nil, "ARTWORK")
	drop:SetTexture([[Interface\QuestFrame\UI-QuestLogTitleHighlight]])
	drop:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	drop:SetPoint("RIGHT", slot)
	drop:SetAllPoints(slot)
	drop:SetAlpha(0.3)
	slot.drop = drop

	local questTexture = iconFrame:CreateTexture(nil, "OVERLAY")
	questTexture:SetAllPoints()
	questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
	questTexture:SetTexCoord(unpack(K.TexCoords))
	slot.questTexture = questTexture

	lootFrame.slots[id] = slot
	return slot
end

function Module:LOOT_SLOT_CLEARED(id)
	if not lootFrame:IsShown() then
		return
	end

	local slot = lootFrame.slots[id]
	if slot then
		slot:Hide()
	end

	AnchorSlots(lootFrame)
end

function Module:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	lootFrame:Hide()

	for _, slot in next, lootFrame.slots do
		slot:Hide()
	end
end

function Module:LOOT_OPENED(_, autoloot)
	lootFrame:Show()

	if not lootFrame:IsShown() then
		CloseLoot(not autoloot)
	end

	if IsFishingLoot() then
		lootFrame.title:SetText(L["Fishy Loot"])
	elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
		lootFrame.title:SetText(UnitName("target"))
	else
		lootFrame.title:SetText(LOOT)
	end

	lootFrame:ClearAllPoints()

	-- Blizzard uses strings here
	if GetCVarBool("lootUnderMouse") then
		local scale = lootFrame:GetEffectiveScale()
		local x, y = GetCursorPosition()

		lootFrame:SetPoint("TOPLEFT", _G.UIParent, "BOTTOMLEFT", (x / scale) - 40, (y / scale) + 20)
		lootFrame:GetCenter()
		lootFrame:Raise()
	else
		lootFrame:SetPoint("TOPLEFT", lootFrameHolder, "TOPLEFT")
	end

	local max_quality, max_width = 0, 0
	local numItems = GetNumLootItems()
	if numItems > 0 then
		for i = 1, numItems do
			local slot = lootFrame.slots[i] or CreateSlot(i)
			local textureID, item, count, _, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality or 0]

			if coinTextureIDs[textureID] then
				item = item:gsub("\n", ", ")
			end

			if count and (count > 1) then
				slot.count:SetText(count)
				slot.count:Show()
			else
				slot.count:Hide()
			end

			if quality and (quality > 1) then
				slot.drop:SetVertexColor(color.r, color.g, color.b)
				slot.iconFrame.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
				slot.drop:Show()
			else
				K.SetBorderColor(slot.iconFrame.KKUI_Border)
				slot.drop:Hide()
			end

			slot.quality = quality
			slot.name:SetText(item)
			slot.name:SetTextColor(color.r, color.g, color.b)
			slot.icon:SetTexture(textureID)

			max_width = max(max_width, slot.name:GetStringWidth())

			if quality then
				max_quality = max(max_quality, quality)
			end

			local questTexture = slot.questTexture
			if questId and not isActive then
				questTexture:Show()
				K.LibCustomGlow.ButtonGlow_Start(slot.iconFrame)
			elseif questId or isQuestItem then
				questTexture:Hide()
				K.LibCustomGlow.ButtonGlow_Start(slot.iconFrame)
			else
				questTexture:Hide()
				K.LibCustomGlow.ButtonGlow_Stop(slot.iconFrame)
			end

			-- Check for FasterLooting scripts or w/e (if bag is full)
			if textureID then
				slot:Enable()
				slot:Show()
			end
		end
	else
		local slot = lootFrame.slots[1] or CreateSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L["Empty Slot"])
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture()

		max_width = max(max_width, slot.name:GetStringWidth())

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end

	AnchorSlots(lootFrame)

	local color = ITEM_QUALITY_COLORS[max_quality]
	lootFrame.KKUI_Border:SetVertexColor(color.r, color.g, color.b, 0.8)
	lootFrame:SetWidth(max(max_width + 60, lootFrame.title:GetStringWidth() + 5))
end

function Module:OPEN_MASTER_LOOT_LIST()
	MasterLooterFrame_Show(_G.LootFrame.selectedLootButton)
end

function Module:UPDATE_MASTER_LOOT_LIST()
	if _G.LootFrame.selectedLootButton then
		MasterLooterFrame_UpdatePlayers()
	end
end

function Module:OnEnable()
	if not C["Loot"].Enable then
		return
	end

	lootFrameHolder = CreateFrame("Frame", "KKUI_LootFrameHolder", UIParent)
	lootFrameHolder:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 418, -186)
	lootFrameHolder:SetSize(150, 22)

	lootFrame = CreateFrame("Button", "KKUI_LootFrame", lootFrameHolder)
	lootFrame:Hide()
	lootFrame:SetClampedToScreen(true)
	lootFrame:SetPoint("TOPLEFT")
	lootFrame:SetSize(256, 64)
	lootFrame:CreateBorder()
	lootFrame:SetFrameStrata(_G.LootFrame:GetFrameStrata())
	lootFrame:SetToplevel(true)
	lootFrame.title = lootFrame:CreateFontString(nil, "OVERLAY")
	lootFrame.title:SetFontObject(K.UIFontOutline)
	lootFrame.title:SetPoint("BOTTOMLEFT", lootFrame, "TOPLEFT", 0, 3)
	lootFrame.slots = {}
	lootFrame:SetScript("OnHide", FrameHide) -- mimic LootFrame_OnHide, mostly

	K:RegisterEvent("LOOT_OPENED", Module.LOOT_OPENED)
	K:RegisterEvent("LOOT_SLOT_CLEARED", Module.LOOT_SLOT_CLEARED)
	K:RegisterEvent("LOOT_CLOSED", Module.LOOT_CLOSED)
	K:RegisterEvent("OPEN_MASTER_LOOT_LIST", Module.OPEN_MASTER_LOOT_LIST)
	K:RegisterEvent("UPDATE_MASTER_LOOT_LIST", Module.UPDATE_MASTER_LOOT_LIST)

	K.Mover(lootFrameHolder, "LootFrame", "LootFrame", { "TOPLEFT", 418, -186 })

	_G.LootFrame:UnregisterAllEvents()
	tinsert(_G.UISpecialFrames, "KKUI_LootFrame")

	-- fix blizzard setpoint connection bs
	hooksecurefunc(_G.MasterLooterFrame, "Hide", _G.MasterLooterFrame.ClearAllPoints)

	self:CreateAutoConfirm()
	self:CreateAutoGreed()
	self:CreateFasterLoot()
	self:CreateGroupLoot()
end
