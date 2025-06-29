-- Cache Global Variables
local K, C = KkthnxUI[1], KkthnxUI[2]

local select = select
local hooksecurefunc = hooksecurefunc
local tinsert = tinsert

local C_Item_IsCosmeticItem = C_Item.IsCosmeticItem
local CreateFrame = CreateFrame
local GetInventoryItemLink = GetInventoryItemLink

-- Global Colors
local greyRGB = K.QualityColors[0].r

-- Helper Functions
local function colourPopout(self)
	local glow = self:GetParent().IconBorder
	local aR, aG, aB = glow:IsShown() and glow:GetVertexColor() or K.r, K.g, K.b
	self.arrow:SetVertexColor(aR, aG, aB)
end

local function clearPopout(self)
	self.arrow:SetVertexColor(1, 1, 1)
end

local function UpdateAzeriteItem(self)
	if not self.styled then
		self.AzeriteTexture:SetAlpha(0)
		self.RankFrame.Texture:SetTexture(nil)
		self.RankFrame.Label:ClearAllPoints()
		self.RankFrame.Label:SetPoint("TOPLEFT", self, 2, -1)
		self.RankFrame.Label:SetTextColor(1, 0.5, 0)
		self.RankFrame.Label:SetFontObject(K.UIFontOutline)
		self.RankFrame.Label:SetFont(select(1, self.RankFrame.Label:GetFont()), 13, select(3, self.RankFrame.Label:GetFont()))
		self.styled = true
	end
end

local function UpdateAzeriteEmpoweredItem(self)
	self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
	self.AzeriteTexture:SetAllPoints()
	self.AzeriteTexture:SetDrawLayer("BORDER", 1)
end

local function UpdateCosmetic(self)
	local itemLink = GetInventoryItemLink("player", self:GetID())
	self.IconOverlay:SetShown(itemLink and C_Item_IsCosmeticItem(itemLink))
end

local function updateIconBorderColor(slot, r, g, b)
	if not r or r == greyRGB or (r > 0.99 and g > 0.99 and b > 0.99) then
		r, g, b = 1, 1, 1
	end

	if slot.KKUI_Border then
		slot.KKUI_Border:SetVertexColor(r, g, b)
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
	local icon = slot.icon
	local iconBorder = slot.IconBorder
	local cooldown = slot.Cooldown or _G[slotName .. "Cooldown"]
	local popout = slot.popoutButton

	slot:StripTextures()
	slot:SetSize(36, 36)
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	iconBorder:SetAlpha(0)
	slot:CreateBorder()
	cooldown:SetAllPoints()
	slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
	slot.IconOverlay:SetAtlas("CosmeticIconFrame")
	slot.IconOverlay:SetPoint("TOPLEFT", 1, -1)
	slot.IconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

	hooksecurefunc(iconBorder, "SetVertexColor", function(_, r, g, b)
		updateIconBorderColor(slot, r, g, b)
	end)

	hooksecurefunc(iconBorder, "Hide", function()
		resetIconBorderColor(slot)
	end)

	hooksecurefunc(iconBorder, "SetShown", function(_, show)
		iconBorderShown(slot, show)
	end)

	popout:SetNormalTexture("")
	popout:SetHighlightTexture("")

	local arrow = popout:CreateTexture(nil, "OVERLAY")
	arrow:SetSize(16, 16)
	if slot.verticalFlyout then
		K.SetupArrow(arrow, "down")
		arrow:SetPoint("TOP", slot, "BOTTOM", 0, 1)
	else
		K.SetupArrow(arrow, "right")
		arrow:SetPoint("LEFT", slot, "RIGHT", -1, 0)
	end
	popout.arrow = arrow

	popout:HookScript("OnEnter", clearPopout)
	popout:HookScript("OnLeave", colourPopout)

	hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
	hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
end

tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
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

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		if button.popoutButton then
			colourPopout(button.popoutButton)
		end
		UpdateCosmetic(button)
	end)

	-- Restore PaperDollFrame_UpdateStats hook with conservative approach
	-- Only hook if the function exists and we're not in combat
	if not InCombatLockdown() then
		hooksecurefunc("PaperDollFrame_UpdateStats", function()
			-- Minimal intervention to prevent taint while maintaining functionality
			if CharacterStatsPane and CharacterStatsPane.ItemLevelFrame then
				local CharItemLvLValue = CharacterStatsPane.ItemLevelFrame.Value
				if CharItemLvLValue then
					CharItemLvLValue:SetFontObject(K.UIFont)
					CharItemLvLValue:SetFont(select(1, CharItemLvLValue:GetFont()), 18, select(3, CharItemLvLValue:GetFont()))
				end
			end
		end)
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

	hooksecurefunc(CharacterFrame, "UpdateSize", function()
		if CharacterFrame.activeSubframe == "PaperDollFrame" then
			CharacterFrame:SetSize(640, 431)
			CharacterFrame.Inset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 432, 4)
			CharacterFrame.Inset.Bg:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom" .. K.Class)
			CharacterFrame.Inset.Bg:SetTexCoord(1 / 512, 479 / 512, 46 / 512, 455 / 512)
			CharacterFrame.Inset.Bg:SetHorizTile(false)
			CharacterFrame.Inset.Bg:SetVertTile(false)
			CharacterFrame.Background:Hide()
		else
			CharacterFrame.Background:Show()
		end
	end)

	if CharacterLevelText then
		CharacterLevelText:SetFontObject(K.UIFont)
	end

	CharacterStatsPane.ClassBackground:ClearAllPoints()
	CharacterStatsPane.ClassBackground:SetHeight(CharacterStatsPane.ClassBackground:GetHeight() + 6)
	CharacterStatsPane.ClassBackground:SetParent(CharacterFrameInsetRight)
	CharacterStatsPane.ClassBackground:SetPoint("CENTER")

	local function StyleSidebarTab(tab)
		if not tab.bg then
			tab.bg = CreateFrame("Frame", nil, tab)
			tab.bg:SetAllPoints(tab)
			tab.bg:SetFrameLevel(tab:GetFrameLevel())
			tab.bg:CreateBorder(nil, nil, nil, nil, nil, { 255 / 255, 223 / 255, 0 / 255 })
			tab.Icon:SetAllPoints(tab.bg)
			tab.Hider:SetAllPoints(tab.bg)
			tab.Highlight:SetPoint("TOPLEFT", tab.bg, "TOPLEFT", 1, -1)
			tab.Highlight:SetPoint("BOTTOMRIGHT", tab.bg, "BOTTOMRIGHT", -1, 1)
			tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
			tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
			tab.TabBg:SetAlpha(0)
		end
		local region = select(1, tab:GetRegions())
		if region and not tab.regionStyled then
			region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
			tab.regionStyled = true
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

	hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if not child.styled then
				child:DisableDrawLayer("BACKGROUND")
				child.styled = true
			end
		end
	end)

	local function updateReputationBars(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child and not child.styled then
				local repbar = child.Content and child.Content.ReputationBar
				if repbar then
					repbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
				end

				child.styled = true
			end
		end
	end
	-- hooksecurefunc(ReputationFrame.ScrollBox, "Update", updateReputationBars)
end)
