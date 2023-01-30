local K, C = unpack(KkthnxUI)

local select = select

local CharacterHandsSlot = CharacterHandsSlot
local CharacterHeadSlot = CharacterHeadSlot
local CharacterMainHandSlot = CharacterMainHandSlot
local CharacterModelScene = CharacterModelScene
local CharacterSecondaryHandSlot = CharacterSecondaryHandSlot
local CharacterStatsPane = CharacterStatsPane
local GetInventoryItemLink = GetInventoryItemLink
local HideUIPanel = HideUIPanel
local IsCosmeticItem = IsCosmeticItem
local hooksecurefunc = hooksecurefunc

tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if CharacterFrame:IsShown() then
		HideUIPanel(CharacterFrame)
	end

	local disabledDraw = false
	if not disabledDraw then
		CharacterModelScene:DisableDrawLayer("BACKGROUND")
		CharacterModelScene:DisableDrawLayer("BORDER")
		CharacterModelScene:DisableDrawLayer("OVERLAY")
		disabledDraw = true
	end

	local function colourPopout(self)
		local aR, aG, aB
		local glow = self:GetParent().IconBorder

		if glow:IsShown() then
			aR, aG, aB = glow:GetVertexColor()
		else
			aR, aG, aB = K.r, K.g, K.b
		end

		self.arrow:SetVertexColor(aR, aG, aB)
	end

	local function clearPopout(self)
		self.arrow:SetVertexColor(1, 1, 1)
	end

	local function UpdateAzeriteItem(self)
		if not self.styled then
			self.AzeriteTexture:SetAlpha(0)
			self.RankFrame.Texture:SetTexture("")
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
		if itemLink and IsCosmeticItem(itemLink) then
			self.IconOverlay:SetShown(true)
		end
	end

	CharacterModelScene:StripTextures(true)

	local slots = {
		"Head",
		"Neck",
		"Shoulder",
		"Shirt",
		"Chest",
		"Waist",
		"Legs",
		"Feet",
		"Wrist",
		"Hands",
		"Finger0",
		"Finger1",
		"Trinket0",
		"Trinket1",
		"Back",
		"MainHand",
		"SecondaryHand",
		"Tabard",
	}

	for i = 1, #slots do
		local slot = _G["Character" .. slots[i] .. "Slot"]
		local cooldown = _G["Character" .. slots[i] .. "SlotCooldown"]

		slot:StripTextures()
		slot:SetSize(36, 36)
		slot.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		slot.IconBorder:SetAlpha(0)
		slot:CreateBorder()
		cooldown:SetAllPoints()

		slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
		slot.IconOverlay:SetAtlas("CosmeticIconFrame")
		slot.IconOverlay:SetPoint("TOPLEFT", 1, -1)
		slot.IconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)
		slot.IconBorder:SetAlpha(0)

		hooksecurefunc(slot.IconBorder, "SetVertexColor", function(_, r, g, b)
			slot.KKUI_Border:SetVertexColor(r, g, b)
		end)

		hooksecurefunc(slot.IconBorder, "Hide", function()
			slot.KKUI_Border:SetVertexColor(1, 1, 1)
		end)

		local popout = slot.popoutButton
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

	hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		-- also fires for bag slots, we don't want that
		if button.popoutButton then
			local itemLink = GetInventoryItemLink("player", button:GetID())
			if itemLink then
				button.icon:SetShown(true)
			end
			colourPopout(button.popoutButton)
		end
		UpdateCosmetic(button)
	end)

	do
		local characterInset = CharacterFrame.Inset
		CharacterHeadSlot:SetPoint("TOPLEFT", characterInset, "TOPLEFT", 6, -6)
		CharacterHandsSlot:SetPoint("TOPRIGHT", characterInset, "TOPRIGHT", -6, -6)
		CharacterMainHandSlot:SetPoint("BOTTOMLEFT", characterInset, "BOTTOMLEFT", 176, 5)
		CharacterSecondaryHandSlot:SetPoint("BOTTOMRIGHT", characterInset, "BOTTOMRIGHT", -176, 5)

		CharacterModelScene:SetSize(0, 0)
		CharacterModelScene:SetPoint("TOPLEFT", characterInset, 0, 0)
		CharacterModelScene:SetPoint("BOTTOMRIGHT", characterInset, 0, 20)

		hooksecurefunc("CharacterFrame_Expand", function()
			CharacterFrame:SetSize(640, 431)
			characterInset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 432, 4)

			local texture = "Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom" .. K.Class
			characterInset.Bg:SetTexture(texture)
			characterInset.Bg:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
			characterInset.Bg:SetHorizTile(false)
			characterInset.Bg:SetVertTile(false)
		end)

		hooksecurefunc("CharacterFrame_Collapse", function()
			CharacterFrame:SetHeight(424)
			characterInset:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 332, 4)

			local texture = "Interface\\FrameGeneral\\UI-Background-Marble", "REPEAT", "REPEAT"
			characterInset.Bg:SetTexture(texture)
			characterInset.Bg:SetTexCoord(0, 1, 0, 1)
			characterInset.Bg:SetHorizTile(true)
			characterInset.Bg:SetVertTile(true)
		end)

		if CharacterLevelText then
			CharacterLevelText:SetFontObject(K.UIFont)
		end

		local CharItemLvLValue = CharacterStatsPane.ItemLevelFrame.Value
		CharItemLvLValue:SetFontObject(K.UIFont)
		CharItemLvLValue:SetFont(select(1, CharItemLvLValue:GetFont()), 18, select(3, CharItemLvLValue:GetFont()))

		CharacterStatsPane.ClassBackground:ClearAllPoints()
		CharacterStatsPane.ClassBackground:SetHeight(CharacterStatsPane.ClassBackground:GetHeight() + 6)
		CharacterStatsPane.ClassBackground:SetParent(CharacterFrameInsetRight)
		CharacterStatsPane.ClassBackground:SetPoint("CENTER")

		hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", function(self)
			for i = 1, self.ScrollTarget:GetNumChildren() do
				local child = select(i, self.ScrollTarget:GetChildren())
				if not child.styled then
					child:DisableDrawLayer("BACKGROUND")
					child.styled = true
				end
			end
		end)

		for i = 1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab" .. i]
			local region = select(1, tab:GetRegions())

			if i == 1 then
				region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
				region.SetTexCoord = K.Noop
			end

			tab.bg = CreateFrame("Frame", nil, tab)
			tab.bg:SetFrameLevel(tab:GetFrameLevel())
			tab.bg:SetAllPoints(tab)
			tab.bg:CreateBorder(nil, nil, nil, nil, nil, { 255 / 255, 223 / 255, 0 / 255 })

			tab.Icon:SetAllPoints(tab.bg)
			tab.Hider:SetAllPoints(tab.bg)
			tab.Highlight:SetPoint("TOPLEFT", tab.bg, "TOPLEFT", 1, -1)
			tab.Highlight:SetPoint("BOTTOMRIGHT", tab.bg, "BOTTOMRIGHT", -1, 1)
			tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
			tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
			tab.TabBg:SetAlpha(0)
		end
	end
end)
