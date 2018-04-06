local K, C, L = unpack(select(2, ...))
local LM = K:NewModule("Loot", "AceEvent-3.0", "AceTimer-3.0")
local LibButtonGlow = LibStub("LibButtonGlow-1.0", true)

local _G = _G
local unpack, pairs = unpack, pairs
local tinsert = table.insert
local max = math.max

local CloseLoot = _G.CloseLoot
local CreateFrame = _G.CreateFrame
local CursorOnUpdate = _G.CursorOnUpdate
local CursorUpdate = _G.CursorUpdate
local DoMasterLootRoll = _G.DoMasterLootRoll
local GetCursorPosition = _G.GetCursorPosition
local GetCVar = _G.GetCVar
local GetLootSlotInfo = _G.GetLootSlotInfo
local GetLootSlotLink = _G.GetLootSlotLink
local GetNumLootItems = _G.GetNumLootItems
local GiveMasterLoot = _G.GiveMasterLoot
local IsFishingLoot = _G.IsFishingLoot
local IsModifiedClick = _G.IsModifiedClick
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS
local L_ToggleDropDownMenu = _G.L_ToggleDropDownMenu
local L_UIDropDownMenu_AddButton = _G.L_UIDropDownMenu_AddButton
local L_UIDropDownMenu_CreateInfo = _G.L_UIDropDownMenu_CreateInfo
local LOOT = _G.LOOT
local LootSlotHasItem = _G.LootSlotHasItem
local MasterLooterFrame_UpdatePlayers = _G.MasterLooterFrame_UpdatePlayers
local ResetCursor = _G.ResetCursor
local StaticPopup_Hide = _G.StaticPopup_Hide
local TEXTURE_ITEM_QUEST_BANG = _G.TEXTURE_ITEM_QUEST_BANG
local UnitIsDead = _G.UnitIsDead
local UnitIsFriend = _G.UnitIsFriend
local UnitName = _G.UnitName

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: GameTooltip, LootFrame, LootSlot, GroupLootDropDown, UISpecialFrames
-- GLOBALS: UIParent, GameFontNormalLeft, MasterLooterFrame_Show, MASTER_LOOTER
-- GLOBALS: ASSIGN_LOOT, REQUEST_ROLL

--This function is copied from FrameXML and modified to use DropDownMenu library function calls
--Using the regular DropDownMenu code causes taints in various places.
local function GroupLootDropDown_Initialize()
	local info = L_UIDropDownMenu_CreateInfo()
	info.isTitle = 1
	info.text = MASTER_LOOTER
	info.fontObject = GameFontNormalLeft
	info.notCheckable = 1
	L_UIDropDownMenu_AddButton(info)

	info = L_UIDropDownMenu_CreateInfo()
	info.notCheckable = 1
	info.text = ASSIGN_LOOT
	info.func = MasterLooterFrame_Show
	L_UIDropDownMenu_AddButton(info)
	info.text = REQUEST_ROLL
	info.func = function() DoMasterLootRoll(LootFrame.selectedSlot) end
	L_UIDropDownMenu_AddButton(info)
end

-- Create the new group loot dropdown frame and initialize it
local KkthnxUIGroupLootDropDown = CreateFrame("Frame", "KkthnxUIGroupLootDropDown", UIParent, "L_UIDropDownMenuTemplate")
KkthnxUIGroupLootDropDown:SetID(1)
KkthnxUIGroupLootDropDown:Hide()
L_UIDropDownMenu_Initialize(KkthnxUIGroupLootDropDown, nil, "MENU")
KkthnxUIGroupLootDropDown.initialize = GroupLootDropDown_Initialize

local coinTextureIDs = {
	[133784] = true,
	[133785] = true,
	[133786] = true,
	[133787] = true,
	[133788] = true,
	[133789] = true,
}

-- Credit Haste
local lootFrame, lootFrameHolder
local iconSize = 30

local ss
local OnEnter = function(self)
	local slot = self:GetID()
	if (LootSlotHasItem(slot)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end

	self.drop:Show()
	self.drop:SetVertexColor(1, 1, 0)
end

local OnLeave = function(self)
	if self.quality and (self.quality > 1) then
		local color = ITEM_QUALITY_COLORS[self.quality]
		self.drop:SetVertexColor(color.r, color.g, color.b)
	else
		self.drop:Hide()
	end

	GameTooltip:Hide()
	ResetCursor()
end

local OnClick = function(self)
	LootFrame.selectedQuality = self.quality
	LootFrame.selectedItemName = self.name:GetText()
	LootFrame.selectedSlot = self:GetID()
	LootFrame.selectedLootButton = self:GetName()
	LootFrame.selectedTexture = self.icon:GetTexture()

	if (IsModifiedClick()) then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		ss = self:GetID()
		LootSlot(ss)
	end
end

local OnShow = function(self)
	if (GameTooltip:IsOwned(self)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

local function anchorSlots(self)
	local iconsize = iconSize
	local shownSlots = 0
	for i = 1, #self.slots do
		local frame = self.slots[i]
		if (frame:IsShown()) then
			shownSlots = shownSlots + 1

			frame:SetPoint("TOP", lootFrame, 4, (-8 + iconsize) - (shownSlots * iconsize))
		end
	end

	self:SetHeight(max(shownSlots * iconsize + 16, 20))
end

local function createSlot(id)
	local iconsize = iconSize - 4
	local frame = CreateFrame("Button", "KkthnxLootSlot"..id, lootFrame)
	frame:SetPoint("LEFT", 8, 0)
	frame:SetPoint("RIGHT", -8, 0)
	frame:SetHeight(iconsize)
	frame:SetID(id)

	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)
	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnShow", OnShow)

	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:SetHeight(iconsize)
	iconFrame:SetWidth(iconsize)
	iconFrame:SetPoint("RIGHT", frame)
	iconFrame:SetTemplate("Transparent", true)
	frame.iconFrame = iconFrame

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	icon:SetAllPoints()
	frame.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:SetJustifyH("RIGHT")
	count:SetPoint("BOTTOMRIGHT", iconFrame, -2, 2)
	count:FontTemplate(nil, nil, "OUTLINE")
	count:SetText(1)
	frame.count = count

	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", frame)
	name:SetPoint("RIGHT", icon, "LEFT")
	name:SetNonSpaceWrap(true)
	name:FontTemplate(nil, nil, "OUTLINE")
	frame.name = name

	local drop = frame:CreateTexture(nil, "ARTWORK")
	drop:SetTexture"Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
	drop:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	drop:SetPoint("RIGHT", frame)
	drop:SetAllPoints(frame)
	drop:SetAlpha(.3)
	frame.drop = drop

	local questTexture = iconFrame:CreateTexture(nil, "OVERLAY")
	questTexture:SetAllPoints()
	questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
	questTexture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	frame.questTexture = questTexture

	lootFrame.slots[id] = frame
	return frame
end

function LM:LOOT_SLOT_CLEARED(_, slot)
	if (not lootFrame:IsShown()) then return end

	lootFrame.slots[slot]:Hide()
	anchorSlots(lootFrame)
end

function LM:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	lootFrame:Hide()

	for _, v in pairs(lootFrame.slots) do
		v:Hide()
	end
end

function LM:OPEN_MASTER_LOOT_LIST()
	L_ToggleDropDownMenu(1, nil, KkthnxUIGroupLootDropDown, lootFrame.slots[ss], 0, 0)
end

function LM:UPDATE_MASTER_LOOT_LIST()
	MasterLooterFrame_UpdatePlayers()
end

function LM:LOOT_OPENED(_, autoloot)
	lootFrame:Show()

	if (not lootFrame:IsShown()) then
		CloseLoot(not autoloot)
	end

	local items = GetNumLootItems()

	if (IsFishingLoot()) then
		lootFrame.title:SetText(L["Loot"].Fishy_Loot)
	elseif (not UnitIsFriend("player", "target") and UnitIsDead"target") then
		lootFrame.title:SetText(UnitName("target"))
	else
		lootFrame.title:SetText(LOOT)
	end

	-- Blizzard uses strings here
	if (GetCVar("lootUnderMouse") == "1") then
		local x, y = GetCursorPosition()
		x = x / lootFrame:GetEffectiveScale()
		y = y / lootFrame:GetEffectiveScale()

		lootFrame:ClearAllPoints()
		lootFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x - 40, y + 20)
		lootFrame:GetCenter()
		lootFrame:Raise()
	else
		lootFrame:ClearAllPoints()
		lootFrame:SetPoint("TOPLEFT", lootFrameHolder, "TOPLEFT")
	end

	local m, w, t = 0, 0, lootFrame.title:GetStringWidth()
	if (items > 0) then
		for i = 1, items do
			local slot = lootFrame.slots[i] or createSlot(i)
			local textureID, item, quantity, quality, _, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality]

			if coinTextureIDs[textureID] then
				item = item:gsub("\n", ", ")
			end

			if quantity and (quantity > 1) then
				slot.count:SetText(quantity)
				slot.count:Show()
			else
				slot.count:Hide()
			end

			if quality and (quality > 1) then
				slot.drop:SetVertexColor(color.r, color.g, color.b)
				slot.drop:Show()
			else
				slot.drop:Hide()
			end

			slot.quality = quality
			slot.name:SetText(item)
			if color then
				slot.name:SetTextColor(color.r, color.g, color.b)
			end
			slot.icon:SetTexture(textureID)

			if quality then
				m = max(m, quality)
			end
			w = max(w, slot.name:GetStringWidth())

			local questTexture = slot.questTexture
			if ( questId and not isActive ) then
				questTexture:Show()
				LibButtonGlow.ShowOverlayGlow(slot.iconFrame)
			elseif ( questId or isQuestItem ) then
				questTexture:Hide()
				LibButtonGlow.ShowOverlayGlow(slot.iconFrame)
			else
				questTexture:Hide()
				LibButtonGlow.HideOverlayGlow(slot.iconFrame)
			end

			slot:Enable()
			slot:Show()
		end
	else
		local slot = lootFrame.slots[1] or createSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L["Loot"].Empty_Slot)
		if color then
			slot.name:SetTextColor(color.r, color.g, color.b)
		end
		slot.icon:SetTexture([[Interface\Icons\INV_Misc_Herb_AncientLichen]])

		w = max(w, slot.name:GetStringWidth())

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end
	anchorSlots(lootFrame)

	w = w + 60
	t = t + 5

	local color = ITEM_QUALITY_COLORS[m]
	lootFrame:SetBackdropBorderColor(color.r, color.g, color.b, .8)
	lootFrame:SetWidth(max(w, t))
end

function LM:OnEnable()
	if C["Loot"].Enable ~= true then return end

	lootFrameHolder = CreateFrame("Frame", "KkthnxLootFrameHolder", UIParent)
	lootFrameHolder:SetPoint("TOPLEFT", 36, -195)
	lootFrameHolder:SetWidth(150)
	lootFrameHolder:SetHeight(22)

	lootFrame = CreateFrame("Button", "KkthnxLootFrame", lootFrameHolder)
	lootFrame:SetClampedToScreen(true)
	lootFrame:SetPoint("TOPLEFT")
	lootFrame:SetSize(256, 64)
	lootFrame:SetTemplate("Transparent")
	lootFrame:SetFrameStrata(LootFrame:GetFrameStrata())
	lootFrame:SetToplevel(true)
	lootFrame.title = lootFrame:CreateFontString(nil, "OVERLAY")
	lootFrame.title:FontTemplate(nil, nil, "OUTLINE")
	lootFrame.title:SetPoint("BOTTOMLEFT", lootFrame, "TOPLEFT", 0,  4)
	lootFrame.slots = {}
	lootFrame:SetScript("OnHide", function()
		StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
		CloseLoot()
	end)

	self:RegisterEvent("LOOT_OPENED")
	self:RegisterEvent("LOOT_SLOT_CLEARED")
	self:RegisterEvent("LOOT_CLOSED")
	self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
	self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

	if (GetCVar("lootUnderMouse") == "0") then
		K.Movers:RegisterFrame(lootFrameHolder)
	end

	-- Fuzz
	LootFrame:UnregisterAllEvents()
	tinsert(UISpecialFrames, "KkthnxLootFrame")

	StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(self, data)
		GiveMasterLoot(ss, data)
	end
end