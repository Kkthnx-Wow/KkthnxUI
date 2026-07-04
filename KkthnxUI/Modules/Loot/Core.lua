--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Replaces the default Blizzard loot frame with a streamlined version.
-- - Design: Intercepts LOOT_OPENED and creates a custom, movable list of loot slots.
-- - Events: LOOT_OPENED, LOOT_CLOSED, LOOT_SLOT_CLEARED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Loot")

-- PERF: Localize global functions and environment for faster lookups in high-frequency loot events.
local math_max = math.max
local table_insert = table.insert

local _G = _G
local CloseLoot = _G.CloseLoot
local CreateFrame = _G.CreateFrame
local CursorOnUpdate = _G.CursorOnUpdate
local CursorUpdate = _G.CursorUpdate
local GameTooltip = _G.GameTooltip
local GetCursorPosition = _G.GetCursorPosition
local GetCVarBool = _G.GetCVarBool
local GetLootSlotInfo = _G.GetLootSlotInfo
local GetLootSlotLink = _G.GetLootSlotLink
local GetNumLootItems = _G.GetNumLootItems
local IsFishingLoot = _G.IsFishingLoot
local IsModifiedClick = _G.IsModifiedClick
local LootSlot = _G.LootSlot
local LootSlotHasItem = _G.LootSlotHasItem
local MasterLooterFrame_Show = _G.MasterLooterFrame_Show
local MasterLooterFrame_UpdatePlayers = _G.MasterLooterFrame_UpdatePlayers
local ResetCursor = _G.ResetCursor
local StaticPopup_Hide = _G.StaticPopup_Hide
local UIParent = _G.UIParent
local UnitIsDead = _G.UnitIsDead
local UnitIsFriend = _G.UnitIsFriend
local UnitName = _G.UnitName
local hooksecurefunc = _G.hooksecurefunc
local ipairs = _G.ipairs
local next = _G.next
local select = _G.select
local string_gsub = _G.string.gsub

local IsSecret = K.IsSecret
local NotSecret = K.NotSecret
local SetPlainText = K.SetPlainText

-- REASON: Constants used for loot quality coloring and quest item identification.
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS
local TEXTURE_ITEM_QUEST_BANG = _G.TEXTURE_ITEM_QUEST_BANG
local LOOT = _G.LOOT

-- Cache Blizzard frames
local LootFrameRef = _G.LootFrame
local MasterLooterFrameRef = _G.MasterLooterFrame

local iconSize, lootFrame, lootFrameHolder = 38
local COIN_TEXTURE_IDS = {
	[133784] = true,
	[133785] = true,
	[133786] = true,
	[133787] = true,
	[133788] = true,
	[133789] = true,
}

-- SECRET (12.0): FontStrings fed secret text (UnitName, loot item names) can return a
-- secret number from GetStringWidth; arithmetic on that throws. Fail closed to 0.
local function SafeStringWidth(fontString)
	local width = fontString:GetStringWidth()
	if IsSecret(width) then
		return 0
	end
	return width or 0
end

-- REASON: FastLoot bridge (Retail-only). Adjusts the visibility without closing the session.
function Module:SetLootFrameSuppressed(isSuppressed)
	-- WARNING: DO NOT :Hide() lootFrame here; its OnHide calls CloseLoot()
	if lootFrame then
		lootFrame:SetAlpha(isSuppressed and 0 or 1)
		lootFrame:EnableMouse(not isSuppressed)
	end
end

local function slotOnEnter(slot)
	local slotID = slot:GetID()
	if LootSlotHasItem(slotID) then
		GameTooltip:SetOwner(slot, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slotID)
		CursorUpdate(slot)
	end

	slot.drop:Show()
	slot.drop:SetVertexColor(1, 1, 0)
end

local function slotOnLeave(slot)
	if slot.quality and NotSecret(slot.quality) and slot.quality > 1 then
		local color = ITEM_QUALITY_COLORS[slot.quality]
		slot.drop:SetVertexColor(color.r, color.g, color.b)
	else
		slot.drop:Hide()
	end

	GameTooltip:Hide()
	ResetCursor()
end

local function slotOnClick(slot)
	local frame = _G.LootFrame
	frame.selectedQuality = slot.quality
	frame.selectedItemName = slot.name:GetText()
	frame.selectedTexture = slot.icon:GetTexture()
	frame.selectedLootButton = slot:GetName()
	frame.selectedSlot = slot:GetID()

	if IsModifiedClick() then
		_G.HandleModifiedItemClick(GetLootSlotLink(LootFrameRef.selectedSlot))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		LootSlot(LootFrameRef.selectedSlot)
	end
end

local function slotOnShow(slot)
	if GameTooltip:IsOwned(slot) then
		GameTooltip:SetOwner(slot, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot:GetID())
		CursorOnUpdate(slot)
	end
end

local function frameOnHide()
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	CloseLoot()

	if _G.MasterLooterFrame then
		_G.MasterLooterFrame:Hide()
	end
end

local function anchorSlots(frame)
	-- REASON: Dynamically stacks loot buttons vertically. The frame height is adjusted based on the
	-- number of visible items to provide a compact, clean interface.
	local shownSlots = 0

	for _, slot in next, frame.slots do
		if slot:IsShown() then
			shownSlots = shownSlots + 1
			slot:SetPoint("TOP", lootFrame, 4, (-8 + iconSize) - (shownSlots * iconSize))
		end
	end

	frame:SetHeight(math_max(shownSlots * iconSize + 10, 20))
end

local function createSlot(slotID)
	local slotSize = (iconSize - 6)

	local slot = CreateFrame("Button", "KKUI_LootSlot" .. slotID, lootFrame)
	slot:SetPoint("LEFT", 8, 0)
	slot:SetPoint("RIGHT", -8, 0)
	slot:SetHeight(slotSize)
	slot:SetID(slotID)

	slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	slot:SetScript("OnEnter", slotOnEnter)
	slot:SetScript("OnLeave", slotOnLeave)
	slot:SetScript("OnClick", slotOnClick)
	slot:SetScript("OnShow", slotOnShow)

	local iconFrame = CreateFrame("Frame", nil, slot)
	iconFrame:SetSize(slotSize, slotSize)
	iconFrame:SetPoint("RIGHT", slot)
	iconFrame:CreateBorder()
	slot.iconFrame = iconFrame

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(unpack(K.TexCoords))
	icon:SetAllPoints()
	slot.icon = icon

	local count = K.CreatePlainFS(iconFrame, slotSize / 2.5, "1", "OVERLAY")
	count:SetJustifyH("RIGHT")
	count:SetPoint("BOTTOMRIGHT", iconFrame, -2, 2)
	slot.count = count

	local name = K.CreatePlainFS(slot, slotSize / 2.5, nil, "OVERLAY")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", slot)
	name:SetPoint("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
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

	lootFrame.slots[slotID] = slot
	return slot
end

function Module.LOOT_SLOT_CLEARED(event, slotID)
	if not lootFrame:IsShown() then
		return
	end

	local slot = lootFrame.slots[slotID]
	if slot then
		slot:Hide()
	end

	anchorSlots(lootFrame)
end

function Module.LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	lootFrame:Hide()

	for _, slot in next, lootFrame.slots do
		slot:Hide()
	end

	-- FastLoot bridge
	if Module.FastLoot_OnLootClosed then
		Module:FastLoot_OnLootClosed()
	end
end

-- COMPAT: Dot syntax (not colon). K:RegisterEvent dispatches func(event, ...), so a colon
-- handler would bind `self` to "LOOT_OPENED" and shift isAutoLoot to nil.
function Module.LOOT_OPENED(_, isAutoLoot)
	-- REASON: Main handler for opening the custom loot frame.
	lootFrame:Show()

	-- REASON: FastLoot bridge: allow FasterLoot.lua to lock autoloot state or suppress the frame
	-- based on user interaction or automated looting settings.
	if Module.FastLoot_OnLootOpened then
		Module:FastLoot_OnLootOpened(isAutoLoot)
	end

	if not lootFrame:IsShown() then
		CloseLoot(not isAutoLoot)
	end

	if IsFishingLoot() then
		SetPlainText(lootFrame.title, L["Fishy Loot"])
	elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
		local targetName = UnitName("target")
		-- SECRET (12.0): corpse target names can be secret; route straight to SetText
		-- when readable, otherwise fall back so GetStringWidth stays safe later.
		SetPlainText(lootFrame.title, (targetName and NotSecret(targetName)) and targetName or LOOT)
	else
		SetPlainText(lootFrame.title, LOOT)
	end

	lootFrame:ClearAllPoints()

	if GetCVarBool("lootUnderMouse") then
		local scale = lootFrame:GetEffectiveScale()
		local cursorX, cursorY = GetCursorPosition()
		lootFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", (cursorX / scale) - 40, (cursorY / scale) + 20)
		lootFrame:GetCenter()
		lootFrame:Raise()
	else
		lootFrame:SetPoint("TOPLEFT", lootFrameHolder, "TOPLEFT")
	end

	local maxQuality, maxWidth = 0, 0
	local numItems = GetNumLootItems()
	if numItems > 0 then
		for i = 1, numItems do
			local slot = lootFrame.slots[i] or createSlot(i)
			local textureID, item, itemCount, _, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			local safeQuality = (quality and NotSecret(quality)) and quality or 0
			local color = ITEM_QUALITY_COLORS[safeQuality]

			if textureID and NotSecret(textureID) and COIN_TEXTURE_IDS[textureID] and item and NotSecret(item) then
				item = string_gsub(item, "\n", ", ")
			end

			if itemCount and NotSecret(itemCount) and itemCount > 1 then
				SetPlainText(slot.count, itemCount)
				slot.count:Show()
			else
				slot.count:Hide()
			end

			if safeQuality > 1 then
				slot.drop:SetVertexColor(color.r, color.g, color.b)
				slot.iconFrame.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
				slot.drop:Show()
			else
				K.SetBorderColor(slot.iconFrame.KKUI_Border)
				slot.drop:Hide()
			end

			slot.quality = safeQuality > 0 and safeQuality or nil
			SetPlainText(slot.name, item)
			slot.name:SetTextColor(color.r, color.g, color.b)
			slot.icon:SetTexture(textureID)

			maxWidth = math_max(maxWidth, SafeStringWidth(slot.name))

			if safeQuality > 0 then
				maxQuality = math_max(maxQuality, safeQuality)
			end

			local questTexture = slot.questTexture
			if questId and not isActive then
				questTexture:Show()
				K.ShowOverlayGlow(slot.iconFrame)
			elseif questId or isQuestItem then
				questTexture:Hide()
				K.ShowOverlayGlow(slot.iconFrame)
			else
				questTexture:Hide()
				K.HideOverlayGlow(slot.iconFrame)
			end

			if textureID then
				slot:Enable()
				slot:Show()
			end
		end
	else
		local slot = lootFrame.slots[1] or createSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		SetPlainText(slot.name, L["Empty Slot"])
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture()

		maxWidth = math_max(maxWidth, SafeStringWidth(slot.name))

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end

	anchorSlots(lootFrame)

	local color = ITEM_QUALITY_COLORS[maxQuality]
	lootFrame.KKUI_Border:SetVertexColor(color.r, color.g, color.b, 0.8)
	lootFrame:SetWidth(math_max(maxWidth + 60, SafeStringWidth(lootFrame.title) + 5))
end

function Module.OPEN_MASTER_LOOT_LIST(event)
	MasterLooterFrame_Show(LootFrameRef.selectedLootButton)
end

function Module.UPDATE_MASTER_LOOT_LIST(event)
	if LootFrameRef.selectedLootButton then
		MasterLooterFrame_UpdatePlayers()
	end
end

function Module:OnEnable()
	if C["Loot"].Enable then
		Module:InitLoot()
	end
end

function Module:InitLoot()
	if Module.lootInitialized then
		return
	end

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
	if LootFrameRef then
		lootFrame:SetFrameStrata(LootFrameRef:GetFrameStrata())
	end
	lootFrame:SetToplevel(true)
	lootFrame.title = K.CreatePlainFS(lootFrame, 13, nil, "OVERLAY")
	lootFrame.title:SetPoint("BOTTOMLEFT", lootFrame, "TOPLEFT", 0, 5)
	lootFrame.slots = {}
	lootFrame:SetScript("OnHide", frameOnHide)

	-- Expose for other Loot submodules (FasterLoot.lua)
	self.lootFrame = lootFrame
	self.lootFrameHolder = lootFrameHolder

	K.Mover(lootFrameHolder, "LootFrame", "LootFrame", { "TOPLEFT", 418, -186 })

	if MasterLooterFrameRef then
		hooksecurefunc(MasterLooterFrameRef, "Hide", MasterLooterFrameRef.ClearAllPoints)
	end

	table_insert(_G.UISpecialFrames, "KKUI_LootFrame")
	Module.lootInitialized = true
	Module:EnableLoot()
end

local function registerLootEvents()
	K:RegisterEvent("LOOT_OPENED", Module.LOOT_OPENED)
	K:RegisterEvent("LOOT_SLOT_CLEARED", Module.LOOT_SLOT_CLEARED)
	K:RegisterEvent("LOOT_CLOSED", Module.LOOT_CLOSED)
	K:RegisterEvent("OPEN_MASTER_LOOT_LIST", Module.OPEN_MASTER_LOOT_LIST)
	K:RegisterEvent("UPDATE_MASTER_LOOT_LIST", Module.UPDATE_MASTER_LOOT_LIST)
end

local function unregisterLootEvents()
	K:UnregisterEvent("LOOT_OPENED", Module.LOOT_OPENED)
	K:UnregisterEvent("LOOT_SLOT_CLEARED", Module.LOOT_SLOT_CLEARED)
	K:UnregisterEvent("LOOT_CLOSED", Module.LOOT_CLOSED)
	K:UnregisterEvent("OPEN_MASTER_LOOT_LIST", Module.OPEN_MASTER_LOOT_LIST)
	K:UnregisterEvent("UPDATE_MASTER_LOOT_LIST", Module.UPDATE_MASTER_LOOT_LIST)
end

function Module:DisableLoot()
	unregisterLootEvents()

	if Module.lootFrame then
		Module.lootFrame:Hide()
	end
	if lootFrameHolder then
		lootFrameHolder:Hide()
	end

	Module:CreateAutoConfirm()
	Module:CreateAutoGreed()
	Module:CreateFasterLoot()
	if Module.DisableGroupLoot then
		Module:DisableGroupLoot()
	end

	if LootFrameRef then
		LootFrameRef:RegisterEvent("LOOT_OPENED")
		LootFrameRef:RegisterEvent("LOOT_SLOT_CLEARED")
		LootFrameRef:RegisterEvent("LOOT_SLOT_CHANGED")
		LootFrameRef:RegisterEvent("LOOT_CLOSED")
	end
end

function Module:EnableLoot()
	if not Module.lootInitialized then
		Module:InitLoot()
		return
	end

	registerLootEvents()

	if lootFrameHolder then
		lootFrameHolder:Show()
	end

	if LootFrameRef then
		LootFrameRef:UnregisterAllEvents()
	end

	Module:CreateAutoConfirm()
	Module:CreateAutoGreed()
	Module:CreateFasterLoot()
	Module:CreateGroupLoot()
end

function Module:SetLootEnabled(enabled)
	if enabled then
		Module:EnableLoot()
	else
		Module:DisableLoot()
	end
end
