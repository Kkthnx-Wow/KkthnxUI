local K, C, L = unpack(select(2, ...))
if C.Loot.Enable ~= true then return end

-- WoW Lua
local format = string.format
local max = math.max
local pairs = pairs
local unpack = unpack

-- Wow API
local CursorOnUpdate = CursorOnUpdate
local CursorUpdate = CursorUpdate
local GetCursorPosition = GetCursorPosition
local GetCVar = GetCVar
local GetLootSlotInfo = GetLootSlotInfo
local GetLootSlotLink = GetLootSlotLink
local GetLootSlotType = GetLootSlotType
local GetNumLootItems = GetNumLootItems
local GroupLootDropDown = GroupLootDropDown
local HandleModifiedItemClick = HandleModifiedItemClick
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsFishingLoot = IsFishingLoot
local IsModifiedClick = IsModifiedClick
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local LootSlotHasItem = LootSlotHasItem
local ResetCursor = ResetCursor
local SendChatMessage = SendChatMessage
local StaticPopup_Hide = StaticPopup_Hide
local Lib_ToggleDropDownMenu = Lib_ToggleDropDownMenu
local Lib_UIDropDownMenu_AddButton = Lib_UIDropDownMenu_AddButton
local Lib_UIDropDownMenu_Refresh = Lib_UIDropDownMenu_Refresh
local UnitExists = UnitExists
local UnitIsDead = UnitIsDead
local UnitIsFriend = UnitIsFriend
local UnitIsPlayer = UnitIsPlayer
local UnitName = UnitName

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CloseLoot, autoLoot, LOOT, LOOT_SLOT_MONEY, EMPTY, LootFrame, GameTooltip
-- GLOBALS: LootSlot, CreateFrame

-- Loot frame(Butsu by Haste)
local _, _NS = ...
local Butsu = CreateFrame("Button", "Butsu")
local lb = CreateFrame("Button", "ButsuAdv", Butsu, "UIPanelScrollDownButtonTemplate")
local LDD = CreateFrame("Frame", "ButsuLDD", Butsu, "Lib_UIDropDownMenuTemplate")
Butsu:Hide()

Butsu:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

function Butsu:LOOT_OPENED(event, autoloot)
	self:Show()
	lb:Show()

	if not self:IsShown() then
		CloseLoot(not autoLoot)
	end

	if IsFishingLoot() then
		self.title:SetText(L.Loot.Fish)
	elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
		self.title:SetText(UnitName("target"))
	else
		self.title:SetText(LOOT)
	end

	-- Blizzard uses strings here
	if GetCVar("lootUnderMouse") == "1" then
		local x, y = GetCursorPosition()
		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x - 40, y + 20)
		self:GetCenter()
		self:Raise()
	end

	local m = 0
	local items = GetNumLootItems()
	if items > 0 then
		for i = 1, items do
			local slot = _NS.slots[i] or _NS.CreateSlot(i)
			local texture, item, quantity, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			if texture then
				local color = ITEM_QUALITY_COLORS[quality]
				local r, g, b = color.r, color.g, color.b

				if GetLootSlotType(i) == LOOT_SLOT_MONEY then
					item = item:gsub("\n", ", ")
				end

				if quantity and quantity > 1 then
					slot.count:SetText(quantity)
					slot.count:Show()
				else
					slot.count:Hide()
				end

				if questId and not isActive then
					slot.quest:Show()
				else
					slot.quest:Hide()
				end

				if color or questId or isQuestItem then
					if questId or isQuestItem then
						r, g, b = 1, 1, 0.2
					end

					slot.iconFrame:SetBackdropBorderColor(r, g, b)
					slot:SetBackdropBorderColor(r, g, b)
					slot.drop:SetVertexColor(r, g, b)
				end
				slot.drop:Show()

				slot.isQuestItem = isQuestItem
				slot.quality = quality

				slot.name:SetText(item)
				if color then
					slot.name:SetTextColor(r, g, b)
				end
				slot.icon:SetTexture(texture)

				if quality then
					m = max(m, quality)
				end

				slot:Enable()
				slot:Show()
			end
		end
	else
		local slot = _NS.slots[1] or _NS.CreateSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(EMPTY)
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture("Interface\\Icons\\INV_Misc_Herb_AncientLichen")

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end
	self:AnchorSlots()

	local color = ITEM_QUALITY_COLORS[m]
	self:SetBackdropBorderColor(color.r, color.g, color.b, 0.9)

	self:SetWidth(C.Loot.Width)
	self.title:SetWidth(C.Loot.Width - 45)
	self.title:SetHeight(C.Media.Font_Size)
end
Butsu:RegisterEvent("LOOT_OPENED")

function Butsu:LOOT_SLOT_CLEARED(event, slot)
	if not self:IsShown() then return end

	_NS.slots[slot]:Hide()
	self:AnchorSlots()
end
Butsu:RegisterEvent("LOOT_SLOT_CLEARED")

function Butsu:LOOT_CLOSED()
	StaticPopup_Hide("LOOT_BIND")
	self:Hide()
	lb:Hide()

	for _, v in pairs(_NS.slots) do
		v:Hide()
	end
end
Butsu:RegisterEvent("LOOT_CLOSED")

function Butsu:OPEN_MASTER_LOOT_LIST()
	Lib_ToggleDropDownMenu(nil, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0)
end
Butsu:RegisterEvent("OPEN_MASTER_LOOT_LIST")

function Butsu:UPDATE_MASTER_LOOT_LIST()
	Lib_UIDropDownMenu_Refresh(GroupLootDropDown)
end
Butsu:RegisterEvent("UPDATE_MASTER_LOOT_LIST")

do
	local title = Butsu:CreateFontString(nil, "OVERLAY")
	title:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	title:SetJustifyH("LEFT")
	title:SetPoint("TOPLEFT", Butsu, "TOPLEFT", 8, -7)
	Butsu.title = title
end

Butsu:SetScript("OnMouseDown", function(self, button)
    if IsAltKeyDown() then
        self:StartMoving()
    elseif IsControlKeyDown() and button == "RightButton" then
        self:SetPoint(unpack(C.Position.Loot))
    end
end)

Butsu:SetScript("OnMouseUp", function(self)
	self:StopMovingOrSizing()
end)

Butsu:SetScript("OnHide", function(self)
	StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
	CloseLoot()
end)

Butsu:SetMovable(true)
Butsu:RegisterForClicks("AnyUp")
Butsu:SetParent(UIParent)
Butsu:SetUserPlaced(true)
Butsu:SetPoint(unpack(C.Position.Loot))
Butsu:SetBackdrop(K.Backdrop)
Butsu:SetBackdropColor(unpack(C.Media.Backdrop_Color))
Butsu:SetBackdropBorderColor(unpack(C.Media.Border_Color))
Butsu:SetClampedToScreen(true)
Butsu:SetFrameStrata("DIALOG")
Butsu:SetToplevel(true)
Butsu:SetFrameLevel(10)

local close = CreateFrame("Button", "LootCloseButton", Butsu, "UIPanelCloseButton")
close:SetSize(26, 26)
close:SetPoint("BOTTOMRIGHT", Butsu, "TOPRIGHT", 2, -25)
close:SetScript("OnClick", function() CloseLoot() end)

-- lcLoot by RustamIrzaev
local function OnLinkClick(self)
	Lib_ToggleDropDownMenu(1, nil, LDD, lb, 0, 0)
end

local function Announce(chn)
	local nums = GetNumLootItems()
	if nums == 0 or (nums == 1 and GetLootSlotType(1) == LOOT_SLOT_MONEY) then return end
	if UnitIsPlayer("target") or not UnitExists("target") then
		SendChatMessage(">> "..LOOT..":", chn)
	else
		SendChatMessage(">> "..LOOT.." - '"..UnitName("target").."':", chn)
	end
	for i = 1, GetNumLootItems() do
		if LootSlotHasItem(i) then
			local link = GetLootSlotLink(i)
			local messlink = "- %s"
			if GetLootSlotType(i) ~= LOOT_SLOT_MONEY then
				SendChatMessage(format(messlink, link), chn)
			end
		end
	end
end

local function LDD_OnClick(self)
	local val = self.value
	Announce(val)
end

local function LDD_Initialize()
	local info = {}

	info.text = L.Loot.Announce
	info.notCheckable = true
	info.isTitle = true
	Lib_UIDropDownMenu_AddButton(info)

	info = {}
	info.text = L.Loot.ToRaid
	info.value = "raid"
	info.notCheckable = 1
	info.func = LDD_OnClick
	Lib_UIDropDownMenu_AddButton(info)

	info = {}
	info.text = L.Loot.ToGuild
	info.value = "guild"
	info.notCheckable = 1
	info.func = LDD_OnClick
	Lib_UIDropDownMenu_AddButton(info)

	info = {}
	info.text = L.Loot.ToParty
	info.value = "party"
	info.notCheckable = 1
	info.func = LDD_OnClick
	Lib_UIDropDownMenu_AddButton(info)

	info = {}
	info.text = L.Loot.ToInstance
	info.value = "instance_chat"
	info.notCheckable = 1
	info.func = LDD_OnClick
	Lib_UIDropDownMenu_AddButton(info)

	info = {}
	info.text = L.Loot.ToSay
	info.value = "say"
	info.notCheckable = 1
	info.func = LDD_OnClick
	Lib_UIDropDownMenu_AddButton(info)

	info = nil
end

lb:SetWidth(14)
lb:SetHeight(12)
lb:ClearAllPoints()
lb:SetPoint("BOTTOMRIGHT", Butsu, "TOPRIGHT", -21, -18)
lb:SetFrameStrata("DIALOG")
lb:RegisterForClicks("RightButtonUp", "LeftButtonUp")
lb:SetScript("OnClick", function(self, button)
    if button == "RightButton" then
        Lib_ToggleDropDownMenu(nil, nil, LDD, lb, 0, 0)
    else
        Announce(K.CheckChat())
    end
end)
lb:Hide()
Lib_UIDropDownMenu_Initialize(LDD, LDD_Initialize, "MENU")

do
	local slots = {}
	_NS.slots = slots

	local OnEnter = function(self)
		local slot = self:GetID()
		if LootSlotHasItem(slot) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetLootItem(slot)
			CursorUpdate(self)
		end

		self.drop:Show()
		if self.isQuestItem then
			self.drop:SetVertexColor(0.8, 0.8, 0.2)
		else
			self.drop:SetVertexColor(1, 1, 0)
		end
	end

	local OnLeave = function(self)
		local color = ITEM_QUALITY_COLORS[self.quality]
		if self.isQuestItem then
			self.drop:SetVertexColor(1, 1, 0.2)
		elseif color then
			self.drop:SetVertexColor(color.r, color.g, color.b)
		end

		GameTooltip:Hide()
		ResetCursor()
	end

	local OnClick = function(self)
		if IsModifiedClick() then
			HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
		else
			StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")

			LootFrame.selectedLootButton = self
			LootFrame.selectedSlot = self:GetID()
			LootFrame.selectedQuality = self.quality
			LootFrame.selectedItemName = self.name:GetText()

			LootSlot(self:GetID())
		end
	end

	local OnUpdate = function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetLootItem(self:GetID())
			CursorOnUpdate(self)
		end
	end

	function _NS.CreateSlot(id)
		local frame = CreateFrame("Button", "ButsuSlot"..id, Butsu)
		frame:SetHeight(max(C.Media.Font_Size, C.Loot.IconSize))
		frame:SetID(id)

		frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

		frame:SetScript("OnEnter", OnEnter)
		frame:SetScript("OnLeave", OnLeave)
		frame:SetScript("OnClick", OnClick)
		frame:SetScript("OnUpdate", OnUpdate)

		local iconFrame = CreateFrame("Frame", nil, frame)
		iconFrame:SetSize(C.Loot.IconSize, C.Loot.IconSize)
		K.CreateBorder(iconFrame, 1)
		iconFrame:SetPoint("LEFT", frame)
		frame.iconFrame = iconFrame

		local icon = iconFrame:CreateTexture(nil, "ARTWORK")
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		icon:SetPoint("TOPLEFT", 2, -2)
		icon:SetPoint("BOTTOMRIGHT", -2, 2)
		frame.icon = icon

		local quest = iconFrame:CreateTexture(nil, "OVERLAY")
		quest:SetTexture("Interface\\Minimap\\ObjectIcons")
		quest:SetTexCoord(1/8, 2/8, 1/8, 2/8)
		quest:SetSize(C.Loot.IconSize * 0.8, C.Loot.IconSize * 0.9)
		quest:SetPoint("BOTTOMLEFT", -C.Loot.IconSize * 0.15, 0)
		frame.quest = quest

		local count = iconFrame:CreateFontString(nil, "OVERLAY")
		count:SetJustifyH("RIGHT")
		count:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 1, 1)
		count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		count:SetShadowOffset(K.Mult, -K.Mult)
		count:SetText(1)
		frame.count = count

		local name = frame:CreateFontString(nil, "OVERLAY")
		name:SetJustifyH("LEFT")
		name:SetPoint("LEFT", icon, "RIGHT", 10, 0)
		name:SetNonSpaceWrap(true)
		name:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		name:SetShadowOffset(K.Mult, -K.Mult)
		name:SetWidth(C.Loot.Width - C.Loot.IconSize - 25)
		name:SetHeight(C.Media.Font_Size)
		frame.name = name

		local drop = frame:CreateTexture(nil, "ARTWORK")
		drop:SetTexture(C.Media.Texture)
		drop:SetPoint("TOPLEFT", C.Loot.IconSize, -2)
		drop:SetPoint("BOTTOMRIGHT", -2, 2)
		drop:SetAlpha(0.5)
		frame.drop = drop

		K.CreateBorder(frame, 1)

		slots[id] = frame
		return frame
	end

	function Butsu:AnchorSlots()
		local frameSize = max(C.Loot.IconSize, C.Loot.IconSize)
		local shownSlots = 0

		local prevShown
		for i = 1, #slots do
			local frame = slots[i]
			if frame:IsShown() then
				frame:ClearAllPoints()
				frame:SetPoint("LEFT", 8, 0)
				frame:SetPoint("RIGHT", -8, 0)
				if not prevShown then
					frame:SetPoint("TOPLEFT", self, 8, -25)
				else
					frame:SetPoint("TOP", prevShown, "BOTTOM", 0, -3)
				end

				frame:SetHeight(frameSize)
				shownSlots = shownSlots + 1
				prevShown = frame
			end
		end

		self:SetHeight((shownSlots * (frameSize + 3)) + 30)
	end
end

-- Kill the default loot frame
LootFrame:UnregisterAllEvents()

-- Escape the dungeon
table.insert(UISpecialFrames, "Butsu")