-- Cache Global Variables
local K, C = KkthnxUI[1], KkthnxUI[2]

-- Cache Lua functions
local select = select
local hooksecurefunc = hooksecurefunc
local tinsert = tinsert
local ipairs = ipairs

-- Cache WoW API
local C_Item_IsCosmeticItem = C_Item.IsCosmeticItem
local CreateFrame = CreateFrame
local GetInventoryItemLink = GetInventoryItemLink
local InCombatLockdown = InCombatLockdown

-- Cache texture paths (avoid string concatenation in loops)
local DRESSING_ROOM_PATH = "Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom"
local LEAVE_ITEM_TEXTURE = "Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent"
local COSMETIC_ATLAS = "CosmeticIconFrame"
local AZERITE_ATLAS = "AzeriteIconFrame"

-- Constants
local SLOT_SIZE = 36
local FONT_SIZE_RANK = 13
local FONT_SIZE_ILVL = 18
local WHITE_R, WHITE_G, WHITE_B = 1, 1, 1
local ORANGE_R, ORANGE_G, ORANGE_B = 1, 0.5, 0

-- Global Colors
local greyRGB = K.QualityColors[0].r

-- Helper Functions
local function UpdateAzeriteItem(self)
	if not self.styled then
		self.AzeriteTexture:SetAlpha(0)
		self.RankFrame.Texture:SetTexture(nil)

		local label = self.RankFrame.Label
		label:ClearAllPoints()
		label:SetPoint("TOPLEFT", self, 2, -1)
		label:SetTextColor(ORANGE_R, ORANGE_G, ORANGE_B)
		label:SetFontObject(K.UIFontOutline)

		-- Cache font data to avoid multiple GetFont() calls
		local fontPath, _, fontFlags = label:GetFont()
		label:SetFont(fontPath, FONT_SIZE_RANK, fontFlags)

		self.styled = true
	end
end

local function UpdateAzeriteEmpoweredItem(self)
	local texture = self.AzeriteTexture
	texture:SetAtlas(AZERITE_ATLAS)
	texture:SetAllPoints()
	texture:SetDrawLayer("BORDER", 1)
end

local function UpdateCosmetic(self)
	local itemLink = GetInventoryItemLink("player", self:GetID())
	self.IconOverlay:SetShown(itemLink and C_Item_IsCosmeticItem(itemLink))
end

local function updateIconBorderColor(slot, r, g, b)
	local border = slot.KKUI_Border
	if not border then
		return
	end

	-- Reset to white if invalid/grey/white color
	if not r or r == greyRGB or (r > 0.99 and g > 0.99 and b > 0.99) then
		border:SetVertexColor(WHITE_R, WHITE_G, WHITE_B)
	else
		border:SetVertexColor(r, g, b)
	end
end

local function resetIconBorderColor(slot, texture)
	if not texture and slot.KKUI_Border then
		K.SetBorderColor(slot.KKUI_Border)
	end
end

local function iconBorderShown(slot, show)
	if not show and slot.KKUI_Border then
		resetIconBorderColor(slot)
	end
end

local function styleEquipmentSlot(slotName)
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

	slot:StripTextures()
	slot:SetSize(SLOT_SIZE, SLOT_SIZE)
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	iconBorder:SetAlpha(0)
	slot:CreateBorder()
	cooldown:SetAllPoints()
	ignoreTexture:SetTexture(LEAVE_ITEM_TEXTURE)
	iconOverlay:SetAtlas(COSMETIC_ATLAS)
	iconOverlay:SetPoint("TOPLEFT", 1, -1)
	iconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

	-- Hook icon border updates
	hooksecurefunc(iconBorder, "SetVertexColor", function(_, r, g, b)
		updateIconBorderColor(slot, r, g, b)
	end)

	hooksecurefunc(iconBorder, "Hide", function()
		resetIconBorderColor(slot)
	end)

	hooksecurefunc(iconBorder, "SetShown", function(_, show)
		iconBorderShown(slot, show)
	end)

	-- Hook azerite display updates
	hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
	hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)

	slot.KKUI_Styled = true
end

tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- Prevent duplicate work and hooks
	if CharacterFrame and CharacterFrame.KKUI_Skinned then
		return
	end

	CharacterModelScene:DisableDrawLayer("BACKGROUND")
	CharacterModelScene:DisableDrawLayer("BORDER")
	CharacterModelScene:DisableDrawLayer("OVERLAY")
	CharacterModelScene:StripTextures(true)

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
		styleEquipmentSlot(slotName)
	end

	if not CharacterFrame or not CharacterFrame.KKUI_Hooks then
		-- Hook to update cosmetics
		hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
			if button then
				UpdateCosmetic(button)
			end
		end)

		-- Hook item level font updates
		if not InCombatLockdown() then
			hooksecurefunc("PaperDollFrame_UpdateStats", function()
				if CharacterStatsPane and CharacterStatsPane.ItemLevelFrame then
					local ilvlValue = CharacterStatsPane.ItemLevelFrame.Value
					if ilvlValue then
						ilvlValue:SetFontObject(K.UIFont)

						-- Cache font data to avoid multiple GetFont() calls
						local fontPath, _, fontFlags = ilvlValue:GetFont()
						ilvlValue:SetFont(fontPath, FONT_SIZE_ILVL, fontFlags)
					end
				end
			end)
		end

		-- Character frame sizing/background hooks
		-- Cache player class texture path (computed once, reused)
		local playerClassTexture = DRESSING_ROOM_PATH .. K.Class

		hooksecurefunc(CharacterFrame, "UpdateSize", function()
			local inset = CharacterFrame.Inset
			local bg = inset.Bg

			if CharacterFrame.activeSubframe == "PaperDollFrame" then
				CharacterFrame:SetSize(640, 431)
				inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 432, 4)
				bg:SetTexture(playerClassTexture)
				bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
				bg:SetHorizTile(false)
				bg:SetVertTile(false)
				CharacterFrame.Background:Hide()
			else
				CharacterFrame.Background:Show()
			end
		end)

		-- Sidebar tabs
		-- Cache golden border color
		local BORDER_GOLD_R, BORDER_GOLD_G, BORDER_GOLD_B = 255 / 255, 223 / 255, 0 / 255

		local function StyleSidebarTab(tab)
			if not tab.bg then
				-- Create and cache background frame
				local bg = CreateFrame("Frame", nil, tab)
				bg:SetAllPoints(tab)
				bg:SetFrameLevel(tab:GetFrameLevel())
				bg:CreateBorder(nil, nil, nil, nil, nil, { BORDER_GOLD_R, BORDER_GOLD_G, BORDER_GOLD_B })

				-- Cache tab elements
				local icon = tab.Icon
				local hider = tab.Hider
				local highlight = tab.Highlight

				icon:SetAllPoints(bg)
				hider:SetAllPoints(bg)
				highlight:SetPoint("TOPLEFT", bg, "TOPLEFT", 1, -1)
				highlight:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -1, 1)
				highlight:SetColorTexture(1, 1, 1, 0.25)
				hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
				tab.TabBg:SetAlpha(0)

				tab.bg = bg
			end

			if not tab.regionStyled then
				local region = select(1, tab:GetRegions())
				if region then
					region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
					tab.regionStyled = true
				end
			end
		end

		local function StyleSidebarTabs()
			local index = 1
			local tab = _G["PaperDollSidebarTab" .. index]
			while tab do
				StyleSidebarTab(tab)
				index = index + 1
				tab = _G["PaperDollSidebarTab" .. index]
			end
		end

		hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", StyleSidebarTabs)

		-- Title pane scroll updates (idempotent within update)
		hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if not child.styled then
					child:DisableDrawLayer("BACKGROUND")
					child.styled = true
				end
			end
		end)

		CharacterFrame.KKUI_Hooks = true
	end

	CharacterHeadSlot:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 6, -6)
	CharacterHandsSlot:SetPoint("TOPRIGHT", CharacterFrame.Inset, "TOPRIGHT", -6, -6)
	CharacterMainHandSlot:SetPoint("BOTTOMLEFT", CharacterFrame.Inset, "BOTTOMLEFT", 176, 5)
	CharacterSecondaryHandSlot:ClearAllPoints()
	CharacterSecondaryHandSlot:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -176, 5)

	CharacterModelScene:SetSize(300, 360)
	CharacterModelScene:ClearAllPoints()
	CharacterModelScene:SetPoint("TOPLEFT", CharacterFrame.Inset, 64, -3)

	CharacterModelScene.GearEnchantAnimation.FrameFX.PurpleGlow:ClearAllPoints()
	CharacterModelScene.GearEnchantAnimation.FrameFX.PurpleGlow:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
	CharacterModelScene.GearEnchantAnimation.FrameFX.PurpleGlow:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)

	CharacterModelScene.GearEnchantAnimation.FrameFX.BlueGlow:ClearAllPoints()
	CharacterModelScene.GearEnchantAnimation.FrameFX.BlueGlow:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
	CharacterModelScene.GearEnchantAnimation.FrameFX.BlueGlow:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)

	CharacterModelScene.GearEnchantAnimation.FrameFX.Sparkles:ClearAllPoints()
	CharacterModelScene.GearEnchantAnimation.FrameFX.Sparkles:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
	CharacterModelScene.GearEnchantAnimation.FrameFX.Sparkles:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)

	CharacterModelScene.GearEnchantAnimation.FrameFX.Mask:ClearAllPoints()
	CharacterModelScene.GearEnchantAnimation.FrameFX.Mask:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", -244, 102)
	CharacterModelScene.GearEnchantAnimation.FrameFX.Mask:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", 247, -103)

	CharacterModelScene.GearEnchantAnimation.TopFrame.Frame:ClearAllPoints()
	CharacterModelScene.GearEnchantAnimation.TopFrame.Frame:SetPoint("TOPLEFT", CharacterFrame.Inset, "TOPLEFT", 2, -2)
	CharacterModelScene.GearEnchantAnimation.TopFrame.Frame:SetPoint("BOTTOMRIGHT", CharacterFrame.Inset, "BOTTOMRIGHT", -2, 2)

	if CharacterLevelText then
		CharacterLevelText:SetFontObject(K.UIFont)
	end

	CharacterStatsPane.ClassBackground:ClearAllPoints()
	CharacterStatsPane.ClassBackground:SetHeight(CharacterStatsPane.ClassBackground:GetHeight() + 6)
	CharacterStatsPane.ClassBackground:SetParent(CharacterFrameInsetRight)
	CharacterStatsPane.ClassBackground:SetPoint("CENTER")

	-- Mark as skinned
	if CharacterFrame then
		CharacterFrame.KKUI_Skinned = true
	end
end)
