local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Loot")

local tinsert = tinsert
local next = next
local max = max
local ipairs = ipairs
local string_format = string.format
local debugprofilestop = debugprofilestop

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
local UIParent = UIParent

local StaticPopup_Hide = StaticPopup_Hide
local MasterLooterFrame_Show = MasterLooterFrame_Show
local MasterLooterFrame_UpdatePlayers = MasterLooterFrame_UpdatePlayers

local hooksecurefunc = hooksecurefunc
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local TEXTURE_ITEM_QUEST_BANG = TEXTURE_ITEM_QUEST_BANG
local LOOT = LOOT

-- Cache frequently used K helpers
-- Avoid caching K helpers at file scope to prevent lifecycle issues

-- Cache Blizzard frames
local LootFrameRef = _G.LootFrame
local MasterLooterFrameRef = _G.MasterLooterFrame

local iconSize, lootFrame, lootFrameHolder = 38

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
		-- Only protect the tooltip operations that can cause taint
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
	local frame = LootFrame
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
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	icon:SetAllPoints()
	slot.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:SetJustifyH("RIGHT")
	count:SetPoint("BOTTOMRIGHT", iconFrame, -2, 2)
	count:SetFontObject(K.UIFontOutline)
	count:SetFont(select(1, count:GetFont()), size / 2.5, select(3, count:GetFont()))
	count:SetText(1)
	slot.count = count

	local name = slot:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", slot)
	name:SetPoint("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
	name:SetFontObject(K.UIFontOutline)
	name:SetFont(select(1, name:GetFont()), size / 2.5, select(3, name:GetFont()))
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
	questTexture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
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
	local t0
	if Module._lootProfile and Module._lootProfile.enabled then
		t0 = debugprofilestop()
	end

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
				K.ShowOverlayGlow(slot.iconFrame)
			elseif questId or isQuestItem then
				questTexture:Hide()
				K.ShowOverlayGlow(slot.iconFrame)
			else
				questTexture:Hide()
				K.HideOverlayGlow(slot.iconFrame)
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

	if Module._lootProfile and Module._lootProfile.enabled and t0 then
		local dt = debugprofilestop() - t0
		local p = Module._lootProfile
		p.runs = p.runs + 1
		p.totalMs = p.totalMs + dt
	end
end

function Module:OPEN_MASTER_LOOT_LIST()
	MasterLooterFrame_Show(LootFrameRef.selectedLootButton)
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
	if LootFrameRef then
		lootFrame:SetFrameStrata(LootFrameRef:GetFrameStrata())
	end
	lootFrame:SetToplevel(true)
	lootFrame.title = lootFrame:CreateFontString(nil, "OVERLAY")
	lootFrame.title:SetFontObject(K.UIFontOutline)
	lootFrame.title:SetFont(select(1, lootFrame.title:GetFont()), 13, select(3, lootFrame.title:GetFont()))
	lootFrame.title:SetPoint("BOTTOMLEFT", lootFrame, "TOPLEFT", 0, 5)
	lootFrame.slots = {}
	lootFrame:SetScript("OnHide", FrameHide) -- mimic LootFrame_OnHide, mostly

	K:RegisterEvent("LOOT_OPENED", Module.LOOT_OPENED)
	K:RegisterEvent("LOOT_SLOT_CLEARED", Module.LOOT_SLOT_CLEARED)
	K:RegisterEvent("LOOT_CLOSED", Module.LOOT_CLOSED)
	K:RegisterEvent("OPEN_MASTER_LOOT_LIST", Module.OPEN_MASTER_LOOT_LIST)
	K:RegisterEvent("UPDATE_MASTER_LOOT_LIST", Module.UPDATE_MASTER_LOOT_LIST)

	K.Mover(lootFrameHolder, "LootFrame", "LootFrame", { "TOPLEFT", 418, -186 })

	if LootFrameRef then
		LootFrameRef:UnregisterAllEvents()
	end
	tinsert(_G.UISpecialFrames, "KKUI_LootFrame")

	-- fix blizzard setpoint connection bs
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

-- Lightweight profiling management
function Module:LootProfileSetEnabled(enabled)
	self._lootProfile = self._lootProfile or { enabled = false, runs = 0, totalMs = 0 }
	local p = self._lootProfile
	p.enabled = not not enabled
	p.runs = 0
	p.totalMs = 0
end

function Module:LootProfileDump()
	local p = self._lootProfile
	if p and p.enabled then
		K.Print(string_format("[Loot] runs=%d time=%.2fms", p.runs, p.totalMs))
	else
		K.Print("[Loot] profiling disabled")
	end
end
