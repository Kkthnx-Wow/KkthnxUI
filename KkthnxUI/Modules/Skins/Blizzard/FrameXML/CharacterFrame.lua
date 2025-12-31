-- Character Frame Skin
-- Purpose: Reskins the player character paper doll, equipment slots, and stats pane.
-- Performance: Optimized ScrollBox iteration and global caching.
-- Maintainer: WoW AddOn Forge

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

-- Cache Lua Globals
local _G = _G
local ipairs = ipairs
local select = select
local table_insert = table.insert

-- Cache WoW API
local C_Item_IsCosmeticItem = C_Item.IsCosmeticItem
local CreateFrame = CreateFrame
local GetInventoryItemLink = GetInventoryItemLink
local InCombatLockdown = InCombatLockdown
local hooksecurefunc = hooksecurefunc

-- Constants
local SLOT_SIZE = 36
local FONT_SIZE_RANK = 13
local FONT_SIZE_ILVL = 18

-- Colors
local WHITE_COLOR = { r = 1, g = 1, b = 1 }
local ORANGE_COLOR = { r = 1, g = 0.5, b = 0 }
local GOLD_BORDER_COLOR = { 255 / 255, 223 / 255, 0 / 255 }
local GREY_QUALITY_R = K.QualityColors[0].r

-- Paths & Atlases
local DRESSING_ROOM_PATH = "Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom"
local LEAVE_ITEM_TEXTURE = "Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent"
local ATLAS_COSMETIC = "CosmeticIconFrame"
local ATLAS_AZERITE = "AzeriteIconFrame"

-- Helper Functions

local function UpdateAzeriteItem(self)
	if not self.styled then
		self.AzeriteTexture:SetAlpha(0)
		self.RankFrame.Texture:SetTexture(nil)

		local label = self.RankFrame.Label
		label:ClearAllPoints()
		label:SetPoint("TOPLEFT", self, 2, -1)
		label:SetTextColor(ORANGE_COLOR.r, ORANGE_COLOR.g, ORANGE_COLOR.b)
		label:SetFontObject(K.UIFontOutline)

		-- Cache font data to avoid multiple GetFont() calls overhead
		local fontPath, _, fontFlags = label:GetFont()
		label:SetFont(fontPath, FONT_SIZE_RANK, fontFlags)

		self.styled = true
	end
end

local function UpdateAzeriteEmpoweredItem(self)
	local texture = self.AzeriteTexture
	texture:SetAtlas(ATLAS_AZERITE)
	texture:SetAllPoints()
	texture:SetDrawLayer("BORDER", 1)
end

local function UpdateCosmetic(self)
	local itemLink = GetInventoryItemLink("player", self:GetID())
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

local function ResetIconBorderColor(slot, texture)
	if not texture and slot.KKUI_Border then
		K.SetBorderColor(slot.KKUI_Border)
	end
end

local function ToggleIconBorder(slot, show)
	if not show and slot.KKUI_Border then
		ResetIconBorderColor(slot)
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
	local cooldown = slot.Cooldown or _G[slotName .. "Cooldown"]
	local iconOverlay = slot.IconOverlay
	local ignoreTexture = slot.ignoreTexture

	-- Apply Skin
	slot:StripTextures()
	slot:SetSize(SLOT_SIZE, SLOT_SIZE)

	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	icon:SetAllPoints()

	iconBorder:SetAlpha(0)
	slot:CreateBorder()

	cooldown:SetAllPoints()

	if ignoreTexture then
		ignoreTexture:SetTexture(LEAVE_ITEM_TEXTURE)
	end

	if iconOverlay then
		iconOverlay:SetAtlas(ATLAS_COSMETIC)
		iconOverlay:SetPoint("TOPLEFT", 1, -1)
		iconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	-- Hook Overrides
	hooksecurefunc(iconBorder, "SetVertexColor", function(_, r, g, b)
		UpdateIconBorderColor(slot, r, g, b)
	end)

	hooksecurefunc(iconBorder, "Hide", function()
		ResetIconBorderColor(slot)
	end)

	hooksecurefunc(iconBorder, "SetShown", function(_, show)
		ToggleIconBorder(slot, show)
	end)

	-- Hook Azerite logic
	hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
	hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)

	slot.KKUI_Styled = true
end

local function StyleSidebarTab(tab)
	if not tab then
		return
	end

	if not tab.bg then
		-- Create background frame
		local bg = CreateFrame("Frame", nil, tab)
		bg:SetAllPoints(tab)
		bg:SetFrameLevel(tab:GetFrameLevel())
		bg:CreateBorder(nil, nil, nil, nil, nil, GOLD_BORDER_COLOR)

		-- Adjust existing elements
		if tab.Icon then
			tab.Icon:SetAllPoints(bg)
		end
		if tab.Hider then
			tab.Hider:SetAllPoints(bg)
			tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
		end

		if tab.Highlight then
			tab.Highlight:SetPoint("TOPLEFT", bg, "TOPLEFT", 1, -1)
			tab.Highlight:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -1, 1)
			tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
		end

		if tab.TabBg then
			tab.TabBg:SetAlpha(0)
		end

		tab.bg = bg
	end

	if not tab.regionStyled then
		local region = select(1, tab:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
			tab.regionStyled = true
		end
	end
end

local function UpdateSidebarTabs()
	local index = 1
	local tab = _G["PaperDollSidebarTab" .. index]
	while tab do
		StyleSidebarTab(tab)
		index = index + 1
		tab = _G["PaperDollSidebarTab" .. index]
	end
end

local function StyleTitleManagerPaneChild(child)
	if not child.styled then
		child:DisableDrawLayer("BACKGROUND")
		child.styled = true
	end
end

local function HandleTitleManagerScrollBox(scrollBox)
	if scrollBox and scrollBox.ForEachFrame then
		scrollBox:ForEachFrame(StyleTitleManagerPaneChild)
	end
end

-- Main Theme Registration

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end
	if CharacterFrame and CharacterFrame.KKUI_Skinned then
		return
	end

	-- Clean up CharacterModelScene
	if CharacterModelScene then
		CharacterModelScene:DisableDrawLayer("BACKGROUND")
		CharacterModelScene:DisableDrawLayer("BORDER")
		CharacterModelScene:DisableDrawLayer("OVERLAY")
		CharacterModelScene:StripTextures(true)
	end

	-- Style Slots
	local equipmentSlots = {
		"CharacterBackSlot",
		"CharacterChestSlot",
		"CharacterFeetSlot",
		"CharacterFinger0Slot",
		"CharacterFinger1Slot",
		"CharacterHandsSlot",
		"CharacterHeadSlot",
		"CharacterLegsSlot",
		"CharacterMainHandSlot",
		"CharacterNeckSlot",
		"CharacterSecondaryHandSlot",
		"CharacterShirtSlot",
		"CharacterShoulderSlot",
		"CharacterTabardSlot",
		"CharacterTrinket0Slot",
		"CharacterTrinket1Slot",
		"CharacterWaistSlot",
		"CharacterWristSlot",
	}

	for _, slotName in ipairs(equipmentSlots) do
		StyleEquipmentSlot(slotName)
	end

	-- Hooks
	if CharacterFrame and not CharacterFrame.KKUI_Hooks then
		-- Cosmetic Update Hook
		hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
			if button then
				UpdateCosmetic(button)
			end
		end)

		-- Stats Pane ItemLevel Hook
		if CharacterStatsPane and CharacterStatsPane.ItemLevelFrame then
			hooksecurefunc("PaperDollFrame_UpdateStats", function()
				-- Avoid taint by checking combat
				if InCombatLockdown() then
					return
				end

				local ilvlValue = CharacterStatsPane.ItemLevelFrame.Value
				if ilvlValue then
					ilvlValue:SetFontObject(K.UIFont)
					local fontPath, _, fontFlags = ilvlValue:GetFont()
					ilvlValue:SetFont(fontPath, FONT_SIZE_ILVL, fontFlags)
				end
			end)
		end

		-- Character Frame Size & Background Hook
		local playerClassTexture = DRESSING_ROOM_PATH .. K.Class
		hooksecurefunc(CharacterFrame, "UpdateSize", function()
			local inset = CharacterFrame.Inset
			local bg = inset and inset.Bg

			if CharacterFrame.activeSubframe == "PaperDollFrame" then
				CharacterFrame:SetSize(640, 431)
				if inset then
					inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 432, 4)
				end

				if bg then
					bg:SetTexture(playerClassTexture)
					bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
					bg:SetHorizTile(false)
					bg:SetVertTile(false)
				end

				if CharacterFrame.Background then
					CharacterFrame.Background:Hide()
				end
			else
				if CharacterFrame.Background then
					CharacterFrame.Background:Show()
				end
			end
		end)

		-- Sidebar Tabs Hook
		hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", UpdateSidebarTabs)

		-- Title Pane ScrollBox Hook (Optimized)
		if PaperDollFrame.TitleManagerPane and PaperDollFrame.TitleManagerPane.ScrollBox then
			hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", HandleTitleManagerScrollBox)
		end

		CharacterFrame.KKUI_Hooks = true
	end

	-- Adjust Positions (Only if not in combat to be safe, though usually safe during loading)
	if not InCombatLockdown() then
		if CharacterFrame.Inset then
			CharacterHeadSlot:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 6, -6)
			CharacterHandsSlot:SetPoint("TOPRIGHT", CharacterFrame.Inset, "TOPRIGHT", -6, -6)
			CharacterMainHandSlot:SetPoint("BOTTOMLEFT", CharacterFrame.Inset, "BOTTOMLEFT", 176, 5)
			CharacterSecondaryHandSlot:ClearAllPoints()
			CharacterSecondaryHandSlot:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -176, 5)

			CharacterModelScene:SetSize(300, 360)
			CharacterModelScene:ClearAllPoints()
			CharacterModelScene:SetPoint("TOPLEFT", CharacterFrame.Inset, 64, -3)

			-- Adjust Gear Enchant Animation Frames
			local fxFrames = {
				CharacterModelScene.GearEnchantAnimation.FrameFX.PurpleGlow,
				CharacterModelScene.GearEnchantAnimation.FrameFX.BlueGlow,
				CharacterModelScene.GearEnchantAnimation.FrameFX.Sparkles,
				CharacterModelScene.GearEnchantAnimation.FrameFX.Mask,
			}

			for _, frame in ipairs(fxFrames) do
				if frame then
					frame:ClearAllPoints()
					frame:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
					frame:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)
				end
			end

			local topFrame = CharacterModelScene.GearEnchantAnimation.TopFrame.Frame
			if topFrame then
				topFrame:ClearAllPoints()
				topFrame:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 2, -2)
				topFrame:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -2, 2)
			end
		end

		if CharacterLevelText then
			CharacterLevelText:SetFontObject(K.UIFont)
		end

		if CharacterStatsPane.ClassBackground then
			CharacterStatsPane.ClassBackground:ClearAllPoints()
			CharacterStatsPane.ClassBackground:SetHeight(CharacterStatsPane.ClassBackground:GetHeight() + 6)
			CharacterStatsPane.ClassBackground:SetParent(CharacterFrameInsetRight)
			CharacterStatsPane.ClassBackground:SetPoint("CENTER")
		end
	end

	if CharacterFrame then
		CharacterFrame.KKUI_Skinned = true
	end
end)
