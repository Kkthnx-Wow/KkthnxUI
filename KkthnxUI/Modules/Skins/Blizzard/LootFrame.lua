local K, C, L = unpack(KkthnxUI)

tinsert(C.defaultThemes, function()
	local LootFrame = _G.LootFrame

	LootFrame:StripTextures()
	LootFrame:CreateBorder()

	LootFrameCloseButton:SkinCloseButton()

	LootFrame:SetHeight(LootFrame:GetHeight() - 30)

	LootFramePortraitOverlay:SetParent(K.UIFrameHider)

	for i=1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions())
		if region:IsObjectType("FontString") then
			if region:GetText() == ITEMS then
				LootFrame.Title = region
			end
		end
	end

	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:SetPoint("TOPLEFT", LootFrame, "TOPLEFT", 4, -4)
	LootFrame.Title:SetJustifyH("LEFT")

	for i = 1, _G.LOOTFRAME_NUMBUTTONS do
		local button = _G["LootButton"..i]
		_G["LootButton"..i.."NameFrame"]:Hide()
		_G["LootButton"..i.."IconQuestTexture"]:SetParent(K.UIFrameHider)

		button:StripTextures()
		button:CreateBorder()
		button:StyleButton()

		button.icon:SetTexCoord(unpack(K.TexCoords))

		button.IconBorder:SetAlpha(0)

		local point, attachTo, point2, x, y = button:GetPoint()
		button:ClearAllPoints()
		button:SetPoint(point, attachTo, point2, x, y + 30)
	end

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local numLootItems = LootFrame.numLootItems

		-- Logic to determine how many items to show per page
		local numLootToShow = _G.LOOTFRAME_NUMBUTTONS
		if LootFrame.AutoLootTable then
			numLootItems = #LootFrame.AutoLootTable
		end

		if numLootItems > _G.LOOTFRAME_NUMBUTTONS then
			numLootToShow = numLootToShow - 1 -- make space for the page buttons
		end

		local button = _G["LootButton"..index]
		local slot = (numLootToShow * (LootFrame.page - 1)) + index
		local quality = select(5, GetLootSlotInfo(slot))
		local color = K.QualityColors[quality or 1]
		if button and button:IsShown() then
			local texture, _, isQuestItem, questId, isActive
			if LootFrame.AutoLootTable then
				local entry = LootFrame.AutoLootTable[slot]
				if entry.hide then
					button:Hide()
					return
				else
					texture = entry.texture
					isQuestItem = entry.isQuestItem
					questId = entry.questId
					isActive = entry.isActive
				end
			else
				texture, _, _, _, _, isQuestItem, questId, isActive = GetLootSlotInfo(slot)
			end

			if texture then
				if questId and not isActive then
					K.ShowButtonGlow(button)
					button.KKUI_Border:SetVertexColor(1, 1, 0)
				elseif questId or isQuestItem then
					K.ShowButtonGlow(button)
					button.KKUI_Border:SetVertexColor(1, 1, 0)
				else
					K.HideButtonGlow(button)
					button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
				end
			end
		end
	end)

	LootFrame:HookScript("OnShow", function(s)
		if IsFishingLoot() then
			s.Title:SetText(L["Fishy Loot"])
		elseif not UnitIsFriend("player", "target") and UnitIsDead("target") then
			s.Title:SetText(UnitName("target"))
		else
			s.Title:SetText(LOOT)
		end
	end)

	K.ReskinArrow(LootFrameUpButton, "up")
	K.ReskinArrow(LootFrameDownButton, "down")
end)