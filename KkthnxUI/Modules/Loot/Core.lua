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
local string_format = string.format
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
local HandleModifiedItemClick = _G.HandleModifiedItemClick
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
	if slot.quality and (slot.quality > 1) then
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

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:SetJustifyH("RIGHT")
	count:SetPoint("BOTTOMRIGHT", iconFrame, -2, 2)
	count:SetFontObject(K.UIFontOutline)
	count:SetFont(select(1, count:GetFont()), slotSize / 2.5, select(3, count:GetFont()))
	count:SetText(1)
	slot.count = count

	local name = slot:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", slot)
	name:SetPoint("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
	name:SetFontObject(K.UIFontOutline)
	name:SetFont(select(1, name:GetFont()), slotSize / 2.5, select(3, name:GetFont()))
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

function Module:LOOT_SLOT_CLEARED(slotID)
	if not lootFrame:IsShown() then
		return
	end

	local slot = lootFrame.slots[slotID]
	if slot then
		slot:Hide()
	end

	anchorSlots(lootFrame)
end

function Module:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	lootFrame:Hide()

	for _, slot in next, lootFrame.slots do
		slot:Hide()
	end

	-- FastLoot bridge
	if self.FastLoot_OnLootClosed then
		self:FastLoot_OnLootClosed()
	end
end

function Module:LOOT_OPENED(_, isAutoLoot)
	-- REASON: Main handler for opening the custom loot frame.
	lootFrame:Show()

	-- REASON: FastLoot bridge: allow FasterLoot.lua to lock autoloot state or suppress the frame
	-- based on user interaction or automated looting settings.
	if self.FastLoot_OnLootOpened then
		self:FastLoot_OnLootOpened(isAutoLoot)
	end

	if not lootFrame:IsShown() then
		CloseLoot(not isAutoLoot)
	end

	if IsFishingLoot() then
		lootFrame.title:SetText(L["Fishy Loot"])
	elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
		lootFrame.title:SetText(UnitName("target"))
	else
		lootFrame.title:SetText(LOOT)
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
			local color = ITEM_QUALITY_COLORS[quality or 0]

			if COIN_TEXTURE_IDS[textureID] then
				item = item:gsub("\n", ", ")
			end

			if itemCount and (itemCount > 1) then
				slot.count:SetText(itemCount)
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

			maxWidth = math_max(maxWidth, slot.name:GetStringWidth())

			if quality then
				maxQuality = math_max(maxQuality, quality)
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

		slot.name:SetText(L["Empty Slot"])
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture()

		maxWidth = math_max(maxWidth, slot.name:GetStringWidth())

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end

	anchorSlots(lootFrame)

	local color = ITEM_QUALITY_COLORS[maxQuality]
	lootFrame.KKUI_Border:SetVertexColor(color.r, color.g, color.b, 0.8)
	lootFrame:SetWidth(math_max(maxWidth + 60, lootFrame.title:GetStringWidth() + 5))
end

function Module:OPEN_MASTER_LOOT_LIST()
	MasterLooterFrame_Show(LootFrameRef.selectedLootButton)
end

function Module:UPDATE_MASTER_LOOT_LIST()
	if LootFrameRef.selectedLootButton then
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
	if LootFrameRef then
		lootFrame:SetFrameStrata(LootFrameRef:GetFrameStrata())
	end
	lootFrame:SetToplevel(true)
	lootFrame.title = lootFrame:CreateFontString(nil, "OVERLAY")
	lootFrame.title:SetFontObject(K.UIFontOutline)
	lootFrame.title:SetFont(select(1, lootFrame.title:GetFont()), 13, select(3, lootFrame.title:GetFont()))
	lootFrame.title:SetPoint("BOTTOMLEFT", lootFrame, "TOPLEFT", 0, 5)
	lootFrame.slots = {}
	lootFrame:SetScript("OnHide", frameOnHide)

	-- Expose for other Loot submodules (FasterLoot.lua)
	self.lootFrame = lootFrame
	self.lootFrameHolder = lootFrameHolder

	K:RegisterEvent("LOOT_OPENED", Module.LOOT_OPENED)
	K:RegisterEvent("LOOT_SLOT_CLEARED", Module.LOOT_SLOT_CLEARED)
	K:RegisterEvent("LOOT_CLOSED", Module.LOOT_CLOSED)
	K:RegisterEvent("OPEN_MASTER_LOOT_LIST", Module.OPEN_MASTER_LOOT_LIST)
	K:RegisterEvent("UPDATE_MASTER_LOOT_LIST", Module.UPDATE_MASTER_LOOT_LIST)

	K.Mover(lootFrameHolder, "LootFrame", "LootFrame", { "TOPLEFT", 418, -186 })

	if LootFrameRef then
		LootFrameRef:UnregisterAllEvents()
	end
	table_insert(_G.UISpecialFrames, "KKUI_LootFrame")

	if MasterLooterFrameRef then
		hooksecurefunc(MasterLooterFrameRef, "Hide", MasterLooterFrameRef.ClearAllPoints)
	end

	local loadLootModules = {
		"CreateAutoConfirm",
		"CreateAutoGreed",
		"CreateFasterLoot",
		"CreateGroupLoot",
	}

	for _, funcName in ipairs(loadLootModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
