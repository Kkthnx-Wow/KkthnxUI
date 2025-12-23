-- [[
--  KkthnxUI: Inspect Frame Skin
--  Purpose: Reskins the inspection frame, equipment slots, and model viewer.
--  Performance: Cached texture paths and optimized tab switching logic.
--  Maintainer: WoW AddOn Forge
-- ]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

-- Cache Lua Globals
local _G = _G
local ipairs = ipairs
local table_insert = table.insert

-- Cache WoW API
local C_Item_IsCosmeticItem = C_Item.IsCosmeticItem
local GetInventoryItemLink = GetInventoryItemLink
local PanelTemplates_GetSelectedTab = PanelTemplates_GetSelectedTab
local UnitClass = UnitClass
local hooksecurefunc = hooksecurefunc

-- Constants
local SLOT_SIZE = 36
local FRAME_SIZE_TAB1 = { width = 438, height = 431 }
local FRAME_SIZE_TAB2 = { width = 338, height = 424 }

-- Colors
local WHITE_COLOR = { r = 1, g = 1, b = 1 }
local GREY_QUALITY_R = K.QualityColors[0].r

-- Paths & Atlases
local DRESSING_ROOM_PATH = "Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom"
local MARBLE_TEXTURE = "Interface\\FrameGeneral\\UI-Background-Marble"
local ATLAS_COSMETIC = "CosmeticIconFrame"

-- Cache Data
local EquipmentSlots = {
	"InspectHeadSlot",
	"InspectNeckSlot",
	"InspectShoulderSlot",
	"InspectShirtSlot",
	"InspectChestSlot",
	"InspectWaistSlot",
	"InspectLegsSlot",
	"InspectFeetSlot",
	"InspectWristSlot",
	"InspectHandsSlot",
	"InspectFinger0Slot",
	"InspectFinger1Slot",
	"InspectTrinket0Slot",
	"InspectTrinket1Slot",
	"InspectBackSlot",
	"InspectMainHandSlot",
	"InspectSecondaryHandSlot",
	"InspectTabardSlot",
}

-- Pre-calculate class background paths to avoid runtime concatenation
local ClassTextures = {}
for classID, classFile in pairs(K.ClassList) do
	ClassTextures[classFile] = DRESSING_ROOM_PATH .. classFile
end

-- ----------------------------------------------------------------------------
-- Helper Functions
-- ----------------------------------------------------------------------------

local function UpdateCosmetic(self)
	local unit = InspectFrame.unit
	if not unit then
		return
	end

	local itemLink = GetInventoryItemLink(unit, self:GetID())
	self.IconOverlay:SetShown(itemLink and C_Item_IsCosmeticItem(itemLink))
end

local function UpdateIconBorderColor(slot, r, g, b)
	local border = slot.KKUI_Border
	if not border then
		return
	end

	-- Normalize invalid/grey/white colors to pure white for consistent border styling
	if not r or r == GREY_QUALITY_R or (r > 0.99 and g > 0.99 and b > 0.99) then
		border:SetVertexColor(WHITE_COLOR.r, WHITE_COLOR.g, WHITE_COLOR.b)
	else
		border:SetVertexColor(r, g, b)
	end
end

local function ResetIconBorderColor(slot)
	if slot.KKUI_Border then
		slot.KKUI_Border:SetVertexColor(WHITE_COLOR.r, WHITE_COLOR.g, WHITE_COLOR.b)
	end
end

local function StyleEquipmentSlot(slotName)
	local slot = _G[slotName]
	if not slot or slot.KKUI_Styled then
		return
	end

	-- Cache slot elements
	local icon = slot.icon
	local iconBorder = slot.IconBorder
	local iconOverlay = slot.IconOverlay

	-- Apply Skin
	slot:StripTextures()
	slot:SetSize(SLOT_SIZE, SLOT_SIZE)

	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	icon:SetAllPoints()

	slot:CreateBorder()

	if iconBorder then
		iconBorder:SetAlpha(0)
	end

	if iconOverlay then
		iconOverlay:SetAtlas(ATLAS_COSMETIC)
		iconOverlay:SetPoint("TOPLEFT", 1, -1)
		iconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	-- Hook Icon Border
	if iconBorder then
		hooksecurefunc(iconBorder, "SetVertexColor", function(_, r, g, b)
			UpdateIconBorderColor(slot, r, g, b)
		end)

		hooksecurefunc(iconBorder, "Hide", function()
			ResetIconBorderColor(slot)
		end)
	end

	slot.KKUI_Styled = true
end

local function ApplyInspectFrameLayout()
	local inspectFrame = InspectFrame
	if not inspectFrame or not inspectFrame.Inset then
		return
	end

	local inset = inspectFrame.Inset
	local bg = inset.Bg

	local selectedTab = PanelTemplates_GetSelectedTab(inspectFrame)

	if selectedTab == 1 then
		inspectFrame:SetSize(FRAME_SIZE_TAB1.width, FRAME_SIZE_TAB1.height)
		inset:SetPoint("BOTTOMRIGHT", inspectFrame, "BOTTOMLEFT", 432, 4)

		-- Determine class texture
		local unit = inspectFrame.unit or "target"
		local _, targetClass = UnitClass(unit)
		local texturePath = targetClass and ClassTextures[targetClass]

		if texturePath and bg then
			bg:SetTexture(texturePath)
			bg:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
			bg:SetHorizTile(false)
			bg:SetVertTile(false)
		end
	else
		inspectFrame:SetSize(FRAME_SIZE_TAB2.width, FRAME_SIZE_TAB2.height)
		inset:SetPoint("BOTTOMRIGHT", inspectFrame, "BOTTOMLEFT", 332, 4)

		if bg then
			bg:SetTexture(MARBLE_TEXTURE, "REPEAT", "REPEAT")
			bg:SetTexCoord(0, 1, 0, 1)
			bg:SetHorizTile(true)
			bg:SetVertTile(true)
		end
	end
end

-- ----------------------------------------------------------------------------
-- Main Theme Registration
-- ----------------------------------------------------------------------------

C.themes["Blizzard_InspectUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end
	if InspectFrame and InspectFrame.KKUI_Skinned then
		return
	end

	-- Reposition Talents Frame if it exists
	if InspectPaperDollItemsFrame and InspectPaperDollItemsFrame.InspectTalents then
		local talents = InspectPaperDollItemsFrame.InspectTalents
		talents:ClearAllPoints()
		talents:SetPoint("TOPRIGHT", InspectFrame, "BOTTOMRIGHT", 0, -1)
	end

	-- Clean Model Frame
	if InspectModelFrame then
		InspectModelFrame:DisableDrawLayer("BACKGROUND")
		InspectModelFrame:DisableDrawLayer("BORDER")
		InspectModelFrame:DisableDrawLayer("OVERLAY")
		InspectModelFrame:StripTextures(true)
	end

	-- Style Slots
	for _, slotName in ipairs(EquipmentSlots) do
		StyleEquipmentSlot(slotName)
	end

	-- Hooks & Positioning
	if InspectFrame and not InspectFrame.KKUI_Hooks then
		-- Cosmetic Update Hook
		hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
			if button then
				UpdateCosmetic(button)
			end
		end)

		-- Layout Hook
		hooksecurefunc("InspectSwitchTabs", ApplyInspectFrameLayout)

		-- Initial Layout Application
		ApplyInspectFrameLayout()

		-- Manual Element Positioning
		if InspectFrameInset then
			if InspectHeadSlot then
				InspectHeadSlot:ClearAllPoints()
				InspectHeadSlot:SetPoint("TOPLEFT", InspectFrameInset, "TOPLEFT", 6, -6)
			end

			if InspectHandsSlot then
				InspectHandsSlot:ClearAllPoints()
				InspectHandsSlot:SetPoint("TOPRIGHT", InspectFrameInset, "TOPRIGHT", -6, -6)
			end

			if InspectMainHandSlot then
				InspectMainHandSlot:ClearAllPoints()
				InspectMainHandSlot:SetPoint("BOTTOMLEFT", InspectFrameInset, "BOTTOMLEFT", 176, 5)
			end

			if InspectSecondaryHandSlot then
				InspectSecondaryHandSlot:ClearAllPoints()
				InspectSecondaryHandSlot:SetPoint("BOTTOMRIGHT", InspectFrameInset, "BOTTOMRIGHT", -176, 5)
			end

			if InspectModelFrame then
				InspectModelFrame:ClearAllPoints()
				InspectModelFrame:SetSize(300, 360)
				InspectModelFrame:SetPoint("TOPLEFT", InspectFrameInset, 64, -3)
			end
		end

		InspectFrame.KKUI_Hooks = true
	end

	if InspectFrame then
		InspectFrame.KKUI_Skinned = true
	end
end
