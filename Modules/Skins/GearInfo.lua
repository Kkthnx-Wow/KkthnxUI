--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/GearInfo.lua
	Purpose:
		Overlay each equipment slot on the character and inspect frames with its
		effective item level (quality coloured), the gems socketed in it, the
		enchant it carries, and a warning on an enchantable slot that has none.

		Data is read from the structured tooltip API (C_TooltipInfo), which is the
		only source that exposes gem icons, empty socket types and enchant text in
		one pass, so a single scan per slot fills everything. Every read is guarded
		against Midnight secret values, which the inspect path can hand back inside
		instanced content. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("CharacterFrames")

local _G = _G
local ipairs = ipairs
local strfind = string.find
local strmatch = string.match
local strsub = string.sub
local gsub = string.gsub
local format = string.format
local tonumber = tonumber

local IsSecret = K.IsSecret
local Colors = K.Colors
local CreateFrame = CreateFrame
local C_Item = C_Item
local C_TooltipInfo = C_TooltipInfo
local GetInventoryItemLink = GetInventoryItemLink
local GameTooltip = GameTooltip
local UnitGUID = UnitGUID

local MAX_GEMS = 5
local GEM_SIZE = 13
local ILVL_SIZE = 12
local ENCHANT_SIZE = 12
local MISSING_ENCHANT_ICON = 134400 -- inv_misc_questionmark
local EMPTY_SOCKET = "Interface\\ItemSocketingFrame\\UI-EmptySocket-%s"

-- Patterns from Blizzard's localised templates, built once.
local ILVL_PATTERN = "^" .. gsub(_G.ITEM_LEVEL or "Item Level %d", "%%d", "")
local ENCHANT_PATTERN = gsub(_G.ENCHANTED_TOOLTIP_LINE or "Enchanted: %s", "%%s", "(.+)")

-- Slots that take a permanent enchant in current retail (Midnight 11.x reworked
-- these: wrist and cloak enchants were dropped, head and shoulder came back).
-- Keyed by the inventory slot id, which is what slot:GetID() returns.
local ENCHANTABLE = {
	[1] = true, -- Head
	[3] = true, -- Shoulder
	[5] = true, -- Chest
	[7] = true, -- Legs
	[8] = true, -- Feet
	[11] = true, -- Finger 1
	[12] = true, -- Finger 2
	[16] = true, -- Main Hand
	[17] = true, -- Off Hand
}

-- Inventory slot id to the Blizzard global that names it, for the warning tip.
local SLOT_NAME = {
	[1] = "HEADSLOT",
	[3] = "SHOULDERSLOT",
	[5] = "CHESTSLOT",
	[7] = "LEGSSLOT",
	[8] = "FEETSLOT",
	[11] = "FINGER0SLOT",
	[12] = "FINGER1SLOT",
	[16] = "MAINHANDSLOT",
	[17] = "SECONDARYHANDSLOT",
}

local function ShouldShow()
	return C.Skins and C.Skins.CharacterFrames and C.Skins.GearInfo
end

-- Which unit a slot reads from: the player on the character sheet, the target on
-- the inspect sheet.
local function SlotUnit(slot)
	local name = slot:GetName() or ""
	if strfind(name, "^Inspect") then
		return _G.InspectFrame and _G.InspectFrame.unit
	end
	return "player"
end

-- Enchant text sits beside the slot and points inward: left-column slots grow
-- rightward, right-column slots grow leftward, the two weapons sit on the row
-- below their icon. Offsets and anchor match the widened paperdoll layout.
local function EnchantAnchor(id)
	if id <= 5 or id == 9 or id == 15 then
		return "BOTTOMLEFT", 42, 18
	elseif id == 16 then
		return "BOTTOMRIGHT", -42, 2
	elseif id == 17 then
		return "BOTTOMLEFT", 42, 2
	else
		return "BOTTOMRIGHT", -42, 18
	end
end

-- ---------------------------------------------------------------------------
-- Widget helpers
-- ---------------------------------------------------------------------------
local function NewFS(parent, size)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(fs, size, K.FontOutlineStyle())
	fs:SetWordWrap(false)
	return fs
end

-- A gem shows its own tooltip on hover. The link is resolved at scan time and
-- stashed on the border frame, which owns the mouse region.
local function Gem_OnEnter(self)
	if not self.gemLink then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink(self.gemLink)
	GameTooltip:Show()
end

local function Tip_OnLeave()
	GameTooltip:Hide()
end

-- A gem icon with a thin quality-tinted border. The border frame doubles as the
-- mouse region so the gem's tooltip can be shown on hover.
local function NewGem(parent)
	local icon = parent:CreateTexture(nil, "OVERLAY")
	icon:SetSize(GEM_SIZE, GEM_SIZE)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	border:SetBackdrop({ edgeFile = C.Media.Textures.White8x8, edgeSize = 1 })
	border:SetBackdropBorderColor(0, 0, 0)
	border:SetPoint("TOPLEFT", icon, -1, 1)
	border:SetPoint("BOTTOMRIGHT", icon, 1, -1)
	border:SetFrameLevel(parent:GetFrameLevel() + 3)
	border:EnableMouse(true)
	border:SetScript("OnEnter", Gem_OnEnter)
	border:SetScript("OnLeave", Tip_OnLeave)
	border:Hide()
	icon.border = border

	return icon
end

-- The missing-enchant warning: a red question mark whose tooltip names the slot.
local function Warning_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Missing Enchant", Colors.crimson[1], Colors.crimson[2], Colors.crimson[3])
	if self.slotName and self.slotName ~= "" then
		GameTooltip:AddLine(self.slotName, 1, 1, 1)
	end
	GameTooltip:Show()
end

local function NewWarning(parent, slotName)
	local icon = parent:CreateTexture(nil, "OVERLAY")
	icon:SetSize(GEM_SIZE, GEM_SIZE)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetTexture(MISSING_ENCHANT_ICON)
	icon:SetVertexColor(Colors.crimson[1], Colors.crimson[2], Colors.crimson[3])
	icon:Hide()

	local border = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	border:SetBackdrop({ edgeFile = C.Media.Textures.White8x8, edgeSize = 1 })
	border:SetBackdropBorderColor(Colors.crimson[1], Colors.crimson[2], Colors.crimson[3])
	border:SetPoint("TOPLEFT", icon, -1, 1)
	border:SetPoint("BOTTOMRIGHT", icon, 1, -1)
	border:SetFrameLevel(parent:GetFrameLevel() + 4)
	border:EnableMouse(true)
	border.slotName = slotName
	border:SetScript("OnEnter", Warning_OnEnter)
	border:SetScript("OnLeave", Tip_OnLeave)
	border:Hide()
	icon.border = border

	return icon
end

-- Enchant text can be long, so it stays clipped to 100px and expands on hover.
local function Enchant_Expand(self)
	self:SetWidth(0)
end
local function Enchant_Collapse(self)
	self:SetWidth(100)
end

-- Build the overlay widgets on a slot once.
local function BuildOverlay(slot)
	if slot.KKUI_Gear then
		return slot.KKUI_Gear
	end
	local id = slot:GetID()
	local gear = {}
	slot.KKUI_Gear = gear

	local level = NewFS(slot, ILVL_SIZE)
	level:SetPoint("TOPLEFT", slot, "TOPLEFT", 1, -1)
	gear.Level = level

	local point, x, y = EnchantAnchor(id)
	local enchant = NewFS(slot, ENCHANT_SIZE)
	enchant:SetPoint(point, slot, point, x, y)
	enchant:SetTextColor(Colors.jade[1], Colors.jade[2], Colors.jade[3])
	enchant:SetJustifyH(strsub(point, 7))
	enchant:SetWidth(100)
	enchant:EnableMouse(true)
	enchant:HookScript("OnEnter", Enchant_Expand)
	enchant:HookScript("OnLeave", Enchant_Collapse)
	enchant:HookScript("OnShow", Enchant_Collapse)
	gear.Enchant = enchant

	gear.Gems = {}
	for i = 1, MAX_GEMS do
		local gem = NewGem(slot)
		local offset = (i - 1) * (GEM_SIZE + 3) + 4
		local gemX = x > 0 and x + offset or x - offset
		local gemY = id > 15 and 18 or 2
		gem:SetPoint(point, slot, point, gemX, gemY)
		gear.Gems[i] = gem
	end

	-- Warning marker only for slots that can be enchanted. It sits at the head of
	-- the enchant-text row so it clears the gems below.
	if ENCHANTABLE[id] then
		local slotName = SLOT_NAME[id] and _G[SLOT_NAME[id]] or ""
		local markX = x > 0 and x + 4 or x - 4
		gear.Warning = NewWarning(slot, slotName)
		gear.Warning:SetPoint(point, slot, point, markX, y)
	end

	return gear
end

-- ---------------------------------------------------------------------------
-- Scan
-- ---------------------------------------------------------------------------
local function GemQualityColor(gemLink)
	if not gemLink or not C_Item.GetItemQualityByID then
		return
	end
	local quality = C_Item.GetItemQualityByID(gemLink)
	if quality and quality > 1 and C_Item.GetItemQualityColor then
		return C_Item.GetItemQualityColor(quality)
	end
end

-- Read item level, enchant text and gem/socket icons from the structured slot
-- tooltip in one pass. gemLinks are resolved separately for the hover tooltips.
-- Returns level (number or nil), enchant text (string or nil), and a gems list.
local function ScanSlot(unit, id, itemLink)
	local data = C_TooltipInfo and C_TooltipInfo.GetInventoryItem(unit, id)
	if not data or not data.lines then
		return
	end

	local level, enchant
	local gems, gemCount, gemStep = {}, 0, 0

	for i = 2, #data.lines do
		local line = data.lines[i]
		local text = line.leftText

		if not level and text and not IsSecret(text) and strfind(text, ILVL_PATTERN) then
			level = tonumber(strmatch(text, "(%d+)%)?$")) or 0
		elseif line.enchantID and not IsSecret(line.enchantID) then
			if text and not IsSecret(text) then
				enchant = strmatch(text, ENCHANT_PATTERN) or text
			end
		elseif line.gemIcon and not IsSecret(line.gemIcon) then
			gemCount = gemCount + 1
			gemStep = gemStep + 1
			local gemLink = itemLink and C_Item.GetItemGem and select(2, C_Item.GetItemGem(itemLink, gemStep))
			gems[gemCount] = { icon = line.gemIcon, link = gemLink }
		elseif line.essenceIcon and not IsSecret(line.essenceIcon) then
			gemCount = gemCount + 1
			gems[gemCount] = { icon = line.essenceIcon, color = line.leftColor }
		elseif line.socketType and not IsSecret(line.socketType) then
			gemCount = gemCount + 1
			gems[gemCount] = { icon = format(EMPTY_SOCKET, line.socketType) }
		end
	end

	return level, enchant, gems
end

-- ---------------------------------------------------------------------------
-- Update
-- ---------------------------------------------------------------------------
function Module:UpdateGearInfo(slot)
	if not ShouldShow() or not slot or not slot.GetID then
		return
	end
	local name = slot:GetName() or ""
	if not strfind(name, "Slot$") then
		return
	end

	local gear = BuildOverlay(slot)

	-- Clear first so an empty or swapped slot never keeps a stale mark.
	gear.Level:SetText("")
	gear.Enchant:SetText("")
	for i = 1, MAX_GEMS do
		local gem = gear.Gems[i]
		gem:SetTexture(nil)
		gem.border.gemLink = nil
		gem.border:Hide()
	end
	if gear.Warning then
		gear.Warning:Hide()
		gear.Warning.border:Hide()
	end

	local id = slot:GetID()
	local unit = SlotUnit(slot)
	local link = unit and GetInventoryItemLink(unit, id)
	if not link or IsSecret(link) then
		return
	end

	local level, enchant, gems = ScanSlot(unit, id, link)

	-- Item level, coloured by the equipped item's quality.
	if level and level > 1 then
		local r, g, b = 1, 1, 1
		local quality = C_Item.GetItemQualityByID and C_Item.GetItemQualityByID(link)
		if quality and not IsSecret(quality) and quality > 1 and C_Item.GetItemQualityColor then
			r, g, b = C_Item.GetItemQualityColor(quality)
		end
		gear.Level:SetText(level)
		gear.Level:SetTextColor(r, g, b)
	end

	if enchant and enchant ~= "" then
		-- Drop a "Source - " prefix so only the enchant name shows.
		gear.Enchant:SetText((gsub(enchant, "^.-%s%-%s", "")))
	end

	if gems then
		for i = 1, MAX_GEMS do
			local data = gems[i]
			local gem = gear.Gems[i]
			if data and data.icon then
				gem:SetTexture(data.icon)
				gem.border.gemLink = data.link
				local r, g, b = GemQualityColor(data.link)
				if not r and data.color then
					r, g, b = data.color.r, data.color.g, data.color.b
				end
				gem.border:SetBackdropBorderColor(r or 0, g or 0, b or 0)
				gem.border:Show()
			end
		end
	end

	-- Warn on an enchantable slot that carries no enchant.
	if gear.Warning then
		local missing = not (enchant and enchant ~= "")
		gear.Warning:SetShown(missing)
		gear.Warning.border:SetShown(missing)
	end
end

-- Refresh every slot on a paperdoll item container.
local function UpdateAll(container)
	if not container then
		return
	end
	for _, slot in ipairs({ container:GetChildren() }) do
		Module:UpdateGearInfo(slot)
	end
end

-- ---------------------------------------------------------------------------
-- Inspect refresh
--   Inspect gem/enchant data streams in after the frame is first shown, so we
--   rescan on INSPECT_READY once the resolved GUID matches the inspected unit.
-- ---------------------------------------------------------------------------
local function OnInspectReady(_, _, guid)
	if not ShouldShow() then
		return
	end
	local InspectFrame = _G.InspectFrame
	local unit = InspectFrame and InspectFrame.unit
	if not (unit and InspectFrame:IsShown() and _G.InspectPaperDollItemsFrame) then
		return
	end
	-- Both GUIDs can be secret inside instanced content, and comparing two
	-- secrets throws, so confirm both are readable first.
	local inspectGUID = UnitGUID(unit)
	if IsSecret(guid) or IsSecret(inspectGUID) or inspectGUID ~= guid then
		return
	end
	UpdateAll(_G.InspectPaperDollItemsFrame)
end

-- ---------------------------------------------------------------------------
-- Hook installation
--   Safe to call more than once: character hooks attach on the first call, the
--   inspect hooks attach once Blizzard_InspectUI is loaded (a later call).
-- ---------------------------------------------------------------------------
function Module:SetupGearInfo()
	if not ShouldShow() then
		return
	end

	if not self.gearCharHooked and _G.PaperDollItemSlotButton_Update then
		self.gearCharHooked = true
		hooksecurefunc("PaperDollItemSlotButton_Update", function(slot)
			Module:UpdateGearInfo(slot)
		end)
		if _G.PaperDollItemsFrame then
			_G.PaperDollItemsFrame:HookScript("OnShow", function(frame)
				UpdateAll(frame)
			end)
		end
	end

	if not self.gearInspectHooked and _G.InspectPaperDollItemSlotButton_Update then
		self.gearInspectHooked = true
		hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(slot)
			Module:UpdateGearInfo(slot)
		end)
	end

	if not self.gearInspectWatcher then
		local watcher = CreateFrame("Frame")
		watcher:RegisterEvent("INSPECT_READY")
		watcher:SetScript("OnEvent", OnInspectReady)
		self.gearInspectWatcher = watcher
	end
end
