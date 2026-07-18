--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Inspect frame and equipment slots.
-- - Design: CharacterFrames layout math — model fills inset, deferred tab resize.
-- - Events: N/A (Blizzard_InspectUI load-on-demand theme)
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local pairs = _G.pairs
local hooksecurefunc = _G.hooksecurefunc

local C_Item_IsCosmeticItem = _G.C_Item.IsCosmeticItem
local C_Timer_After = _G.C_Timer.After
local GetInventoryItemLink = _G.GetInventoryItemLink
local InCombatLockdown = _G.InCombatLockdown
local PanelTemplates_GetSelectedTab = _G.PanelTemplates_GetSelectedTab
local UnitClass = _G.UnitClass

-- NOTE: InspectFrame globals are NOT cached here because Blizzard_InspectUI is load-on-demand.

-- Constants (inspect sizes)
local SLOT_SIZE = 37
local FRAME_SIZE_TAB1 = { width = 438, height = 431 }
local FRAME_SIZE_TAB2 = { width = 338, height = 424 }
local PANEL_INSET_BOTTOM_OFFSET = _G.PANEL_INSET_BOTTOM_OFFSET or 4
local INSPECT_INSET_OFFSET_PAPER = 432
local INSPECT_INSET_OFFSET_OTHER = 332

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
for _, classFile in pairs(K.ClassList) do
	ClassTextures[classFile] = DRESSING_ROOM_PATH .. classFile
end

local function UpdateCosmetic(self)
	if not self then
		return
	end
	local unit = _G.InspectFrame and _G.InspectFrame.unit
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

	if not r or r == GREY_QUALITY_R or (r > 0.99 and g > 0.99 and b > 0.99) then
		border:SetVertexColor(WHITE_COLOR.r, WHITE_COLOR.g, WHITE_COLOR.b)
	else
		border:SetVertexColor(r, g, b)
	end
end

local function ResetIconBorderColor(slot)
	if slot.KKUI_Border then
		K.SetBorderColor(slot.KKUI_Border)
	end
end

local function IconBorder_OnSetVertexColor(self, r, g, b)
	UpdateIconBorderColor(self:GetParent(), r, g, b)
end

local function IconBorder_OnHide(self)
	ResetIconBorderColor(self:GetParent())
end

local function StyleEquipmentSlot(slotName)
	local slot = _G[slotName]
	if not slot or slot.KKUI_Styled then
		return
	end

	local icon = slot.icon
	local iconBorder = slot.IconBorder
	local iconOverlay = slot.IconOverlay

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

	if iconBorder then
		hooksecurefunc(iconBorder, "SetVertexColor", IconBorder_OnSetVertexColor)
		hooksecurefunc(iconBorder, "Hide", IconBorder_OnHide)
	end

	slot.KKUI_Styled = true
end

local lastAppliedTab
local lastAppliedClass

local function ApplyInspectFrameLayout(tabID)
	if InCombatLockdown() then
		return
	end

	local inspectFrame = _G.InspectFrame
	if not inspectFrame or not inspectFrame.Inset then
		return
	end

	local inset = inspectFrame.Inset
	local bg = inset.Bg

	local selectedTab = tabID or PanelTemplates_GetSelectedTab(inspectFrame)
	local unit = inspectFrame.unit or "target"
	-- classFilename (2nd return): no ConditionalSecret.
	local _, targetClass = UnitClass(unit)

	if selectedTab == lastAppliedTab and targetClass == lastAppliedClass then
		return
	end
	lastAppliedTab = selectedTab
	lastAppliedClass = targetClass

	if selectedTab == 1 then
		inspectFrame:SetSize(FRAME_SIZE_TAB1.width, FRAME_SIZE_TAB1.height)
		inset:SetPoint("BOTTOMRIGHT", inspectFrame, "BOTTOMLEFT", INSPECT_INSET_OFFSET_PAPER, PANEL_INSET_BOTTOM_OFFSET)

		local texturePath = targetClass and ClassTextures[targetClass]
		if texturePath and bg then
			bg:SetTexture(texturePath)
			bg:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
			bg:SetHorizTile(false)
			bg:SetVertTile(false)
		end
	else
		inspectFrame:SetSize(FRAME_SIZE_TAB2.width, FRAME_SIZE_TAB2.height)
		inset:SetPoint("BOTTOMRIGHT", inspectFrame, "BOTTOMLEFT", INSPECT_INSET_OFFSET_OTHER, PANEL_INSET_BOTTOM_OFFSET)

		if bg then
			bg:SetTexture(MARBLE_TEXTURE, "REPEAT", "REPEAT")
			bg:SetTexCoord(0, 1, 0, 1)
			bg:SetHorizTile(true)
			bg:SetVertTile(true)
		end
	end
end

-- REASON: Main entry point for Blizzard Inspect UI skinning.
C.themes["Blizzard_InspectUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local InspectFrame = _G.InspectFrame
	local InspectFrameInset = _G.InspectFrameInset or (InspectFrame and InspectFrame.Inset)
	local InspectHandsSlot = _G.InspectHandsSlot
	local InspectHeadSlot = _G.InspectHeadSlot
	local InspectMainHandSlot = _G.InspectMainHandSlot
	local InspectModelFrame = _G.InspectModelFrame
	local InspectPaperDollItemsFrame = _G.InspectPaperDollItemsFrame
	local InspectSecondaryHandSlot = _G.InspectSecondaryHandSlot

	if InspectFrame and InspectFrame.KKUI_Skinned then
		return
	end

	if InspectPaperDollItemsFrame and InspectPaperDollItemsFrame.InspectTalents then
		local talents = InspectPaperDollItemsFrame.InspectTalents
		talents:ClearAllPoints()
		talents:SetPoint("TOPRIGHT", InspectFrame, "BOTTOMRIGHT", 0, -1)
	end

	if InspectModelFrame then
		InspectModelFrame:DisableDrawLayer("BACKGROUND")
		InspectModelFrame:DisableDrawLayer("BORDER")
		InspectModelFrame:DisableDrawLayer("OVERLAY")
		InspectModelFrame:StripTextures(true)
	end

	for i = 1, #EquipmentSlots do
		StyleEquipmentSlot(EquipmentSlots[i])
	end

	if InspectFrame and not InspectFrame.KKUI_Hooks then
		local function ResetInspectLayoutCache()
			lastAppliedTab = nil
			lastAppliedClass = nil
		end
		InspectFrame:HookScript("OnShow", ResetInspectLayoutCache)
		InspectFrame:HookScript("OnHide", ResetInspectLayoutCache)

		hooksecurefunc("InspectPaperDollItemSlotButton_Update", UpdateCosmetic)

		-- Defer tab layout — avoids tainting secure elements mid-switch.
		hooksecurefunc("InspectSwitchTabs", function(newID)
			C_Timer_After(0, function()
				ApplyInspectFrameLayout(newID)
			end)
		end)

		ApplyInspectFrameLayout(1)

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
				InspectMainHandSlot:SetPoint("BOTTOMLEFT", InspectFrameInset, "BOTTOMLEFT", 175, 5)
			end

			if InspectSecondaryHandSlot then
				InspectSecondaryHandSlot:ClearAllPoints()
				InspectSecondaryHandSlot:SetPoint("BOTTOMRIGHT", InspectFrameInset, "BOTTOMRIGHT", -175, 5)
			end

			if InspectModelFrame then
				-- Stretch model to inset, leave foot room for avg iLvl text.
				InspectModelFrame:SetSize(0, 0)
				InspectModelFrame:ClearAllPoints()
				InspectModelFrame:SetPoint("TOPLEFT", InspectFrameInset, 0, 0)
				InspectModelFrame:SetPoint("BOTTOMRIGHT", InspectFrameInset, 0, 30)
				if InspectModelFrame.SetCamDistanceScale then
					InspectModelFrame:SetCamDistanceScale(1.1)
				end
			end
		end

		if _G.InspectPaperDollFrame then
			_G.InspectPaperDollFrame:HookScript("OnShow", function()
				-- Pawn inspect button lift lives in CharacterFrame skin; nudge if already loaded.
				local button = _G.PawnUI_InspectPawnButton
				if button and InspectFrame then
					button:EnableMouse(true)
					button:SetFrameStrata("HIGH")
					button:SetFrameLevel(InspectFrame:GetFrameLevel() + 50)
					button:Raise()
				end
			end)
		end

		InspectFrame.KKUI_Hooks = true
	end

	if InspectFrame then
		InspectFrame.KKUI_Skinned = true
	end
end
