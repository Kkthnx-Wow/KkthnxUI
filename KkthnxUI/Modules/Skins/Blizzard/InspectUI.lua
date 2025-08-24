local K, C = KkthnxUI[1], KkthnxUI[2]

C.themes["Blizzard_InspectUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if InspectFrame and InspectFrame.KKUI_Skinned then
		return
	end

	local GetInventoryItemLink = GetInventoryItemLink
	local C_Item_IsCosmeticItem = C_Item.IsCosmeticItem
	local PanelTemplates_GetSelectedTab = PanelTemplates_GetSelectedTab
	local UnitClass = UnitClass
	local hooksecurefunc = hooksecurefunc

	local InspectPaperDollItemsFrame = InspectPaperDollItemsFrame
	local InspectModelFrame = InspectModelFrame

	if InspectPaperDollItemsFrame.InspectTalents then
		InspectPaperDollItemsFrame.InspectTalents:ClearAllPoints()
		InspectPaperDollItemsFrame.InspectTalents:SetPoint("TOPRIGHT", InspectFrame, "BOTTOMRIGHT", 0, -1)
	end

	InspectModelFrame:DisableDrawLayer("BACKGROUND")
	InspectModelFrame:DisableDrawLayer("BORDER")
	InspectModelFrame:DisableDrawLayer("OVERLAY")
	InspectModelFrame:StripTextures(true)

	local equipmentSlots = {
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

	for i = 1, #equipmentSlots do
		local slot = _G[equipmentSlots[i]]
		if slot and not slot.KKUI_Styled then
			slot:StripTextures()
			slot:SetSize(36, 36)
			slot.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			slot:CreateBorder()
			slot.IconBorder:SetAlpha(0)
			slot.IconOverlay:SetAtlas("CosmeticIconFrame")
			slot.IconOverlay:SetPoint("TOPLEFT", 1, -1)
			slot.IconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

			hooksecurefunc(slot.IconBorder, "SetVertexColor", function(_, r, g, b)
				slot.KKUI_Border:SetVertexColor(r, g, b)
			end)

			hooksecurefunc(slot.IconBorder, "Hide", function()
				slot.KKUI_Border:SetVertexColor(1, 1, 1)
			end)

			slot.KKUI_Styled = true
		end
	end

	local function UpdateCosmetic(self)
		local unit = InspectFrame.unit
		local itemLink = unit and GetInventoryItemLink(unit, self:GetID())
		self.IconOverlay:SetShown(itemLink and C_Item_IsCosmeticItem(itemLink))
	end

	if not InspectFrame or not InspectFrame.KKUI_Hooks then
		hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
			if button then
				UpdateCosmetic(button)
			end
		end)

		local InspectHeadSlot = InspectHeadSlot
		local InspectHandsSlot = InspectHandsSlot
		local InspectMainHandSlot = InspectMainHandSlot
		local InspectSecondaryHandSlot = InspectSecondaryHandSlot

		InspectHeadSlot:ClearAllPoints()
		InspectHandsSlot:ClearAllPoints()
		InspectMainHandSlot:ClearAllPoints()
		InspectSecondaryHandSlot:ClearAllPoints()
		InspectModelFrame:ClearAllPoints()

		InspectHeadSlot:SetPoint("TOPLEFT", InspectFrameInset, "TOPLEFT", 6, -6)
		InspectHandsSlot:SetPoint("TOPRIGHT", InspectFrameInset, "TOPRIGHT", -6, -6)
		InspectMainHandSlot:SetPoint("BOTTOMLEFT", InspectFrameInset, "BOTTOMLEFT", 176, 5)
		InspectSecondaryHandSlot:SetPoint("BOTTOMRIGHT", InspectFrameInset, "BOTTOMRIGHT", -176, 5)

		InspectModelFrame:SetSize(300, 360)
		InspectModelFrame:ClearAllPoints()
		InspectModelFrame:SetPoint("TOPLEFT", InspectFrameInset, 64, -3)

		local function ApplyInspectFrameLayout()
			local InspectFrame = InspectFrame
			local InspectFrameInset = InspectFrame.Inset

			if PanelTemplates_GetSelectedTab(InspectFrame) == 1 then
				InspectFrame:SetSize(438, 431)
				InspectFrameInset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 432, 4)

				local _, targetClass = UnitClass("target")
				if targetClass then
					InspectFrameInset.Bg:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Skins\\DressingRoom" .. targetClass)
					InspectFrameInset.Bg:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
					InspectFrameInset.Bg:SetHorizTile(false)
					InspectFrameInset.Bg:SetVertTile(false)
				end
			else
				InspectFrame:SetSize(338, 424)
				InspectFrameInset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 332, 4)

				InspectFrameInset.Bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble", "REPEAT", "REPEAT")
				InspectFrameInset.Bg:SetTexCoord(0, 1, 0, 1)
				InspectFrameInset.Bg:SetHorizTile(true)
				InspectFrameInset.Bg:SetVertTile(true)
			end
		end

		local function OnInspectSwitchTabs(newID)
			local tabID = newID or PanelTemplates_GetSelectedTab(InspectFrame)
			ApplyInspectFrameLayout(tabID == 1)
		end

		hooksecurefunc("InspectSwitchTabs", OnInspectSwitchTabs)
		OnInspectSwitchTabs(1)

		InspectFrame.KKUI_Hooks = true
	end

	if InspectFrame then
		InspectFrame.KKUI_Skinned = true
	end
end
