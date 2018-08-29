local K, C = unpack(select(2, ...))
if C["Inventory"].Enable == true or C["Skins"].BlizzardBags ~= true then
	return
end

local Module = K:GetModule("Skins")

local function SkinBlizzardBags()
	for i = 1, 12 do
		local Bag = _G["ContainerFrame"..i]
		Bag:CreateBackdrop()

		for j = 1, 36 do
			local ItemButton = _G["ContainerFrame"..i.."Item"..j]
			ItemButton:CreateBorder()
			ItemButton.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			ItemButton:SetNormalTexture("")
			ItemButton:SetPushedTexture("")
			ItemButton.icon:SetInside()

			ItemButton.IconBorder:SetAlpha(0)
			ItemButton.NewItemTexture:SetAtlas(nil)
			ItemButton.NewItemTexture.SetAtlas = K.Noop

			_G["ContainerFrame"..i.."Item"..j.."IconQuestTexture"]:SetAlpha(0)

			ItemButton:CreateBackdrop()
			ItemButton.Backdrop:Hide()

			hooksecurefunc(ItemButton.NewItemTexture, "Show", function()
				ItemButton.Backdrop:Show()
			end)

			hooksecurefunc(ItemButton.NewItemTexture, "Hide", function()
				ItemButton.Backdrop:Hide()
			end)

			ItemButton.Backdrop:SetAllPoints()
			ItemButton.Backdrop:SetFrameStrata(ItemButton:GetFrameStrata())
			ItemButton.Backdrop:SetFrameLevel(ItemButton:GetFrameLevel() + 4)
			ItemButton.Backdrop:SetScript("OnUpdate", function(self)
				local isQuestItem, questId, isActive = GetContainerItemQuestInfo(ItemButton:GetParent():GetID(), ItemButton:GetID())
				local Quality = select(4, GetContainerItemInfo(ItemButton:GetParent():GetID(), ItemButton:GetID()))
				ItemButton:SetBackdropBorderColor()

				if Quality and BAG_ITEM_QUALITY_COLORS[Quality] then
					self:SetBackdropBorderColor(BAG_ITEM_QUALITY_COLORS[Quality].r, BAG_ITEM_QUALITY_COLORS[Quality].g, BAG_ITEM_QUALITY_COLORS[Quality].b)
				elseif isQuestItem then
					self:SetBackdropBorderColor(1, .82, 0)
				else
					self:SetBackdropBorderColor(1, 1, 1)
				end

				self:SetAlpha(self:GetParent().NewItemTexture:GetAlpha())
			end)

			ItemButton.Backdrop:SetScript("OnHide", function(self)
				local Quality = select(4, GetContainerItemInfo(ItemButton:GetParent():GetID(), ItemButton:GetID()))
				local isQuestItem, questId, isActive = GetContainerItemQuestInfo(ItemButton:GetParent():GetID(), ItemButton:GetID())

				if Quality and (Quality > LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[Quality]) then
					ItemButton:SetBackdropBorderColor(BAG_ITEM_QUALITY_COLORS[Quality].r, BAG_ITEM_QUALITY_COLORS[Quality].g, BAG_ITEM_QUALITY_COLORS[Quality].b)
				elseif isQuestItem then
					ItemButton:SetBackdropBorderColor(1, .82, 0)
				else
					ItemButton:SetBackdropBorderColor()
				end
			end)

			ItemButton.searchOverlay:SetAllPoints(ItemButton.icon)
			ItemButton.searchOverlay:SetColorTexture(0, 0, 0, .8)

			ItemButton:SetNormalTexture("")
			ItemButton:StyleButton()
			hooksecurefunc(ItemButton.IconBorder, "SetVertexColor", function(self, r, g, b, a)
				local Quality = select(4, GetContainerItemInfo(ItemButton:GetParent():GetID(), ItemButton:GetID()))
				local isQuestItem, questId, isActive = GetContainerItemQuestInfo(ItemButton:GetParent():GetID(), ItemButton:GetID())
				if Quality and Quality > LE_ITEM_QUALITY_COMMON then
					ItemButton:SetBackdropBorderColor(r, g, b)
				elseif isQuestItem then
					ItemButton:SetBackdropBorderColor(1, .82, 0)
				else
					ItemButton:SetBackdropBorderColor()
				end
			end)

			hooksecurefunc(ItemButton.IconBorder, "Hide", function(self)
				ItemButton:SetBackdropBorderColor()
			end)
		end

		Bag.Backdrop:SetPoint("TOPLEFT", 4, -2)
		Bag.Backdrop:SetPoint("BOTTOMRIGHT", 1, 1)

		_G["ContainerFrame"..i.."BackgroundTop"]:Kill()
		_G["ContainerFrame"..i.."BackgroundMiddle1"]:Kill()
		_G["ContainerFrame"..i.."BackgroundMiddle2"]:Kill()
		_G["ContainerFrame"..i.."BackgroundBottom"]:Kill()
		_G["ContainerFrame"..i.."CloseButton"]:SetPoint("TOPRIGHT", 5, 2)
		_G["ContainerFrame"..i.."CloseButton"]:SkinCloseButton()

		Bag.PortraitButton:SetSize(34, 34)
		Bag.PortraitButton:SkinButton()
		Bag.PortraitButton.Highlight:Kill()
	end

	local function UpdateBagIcon()
		for i = 1, 12 do
			local Portrait = _G["ContainerFrame"..i.."PortraitButton"]
			if i == 1 then
				Portrait:SetNormalTexture("Interface\\ICONS\\INV_Misc_Bag_36")
			elseif i <= 5 and i >= 2 then
				Portrait:SetNormalTexture(_G["CharacterBag"..(i - 2).."SlotIconTexture"]:GetTexture())
			elseif i <= 12 and i >= 6 then
				Portrait:SetNormalTexture(BankSlotsFrame["Bag"..(i-5)].icon:GetTexture())
			end

			if Portrait:GetNormalTexture() then
				Portrait:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				Portrait:GetNormalTexture():SetInside()
			end

			for j = 1, 30 do
				local ItemButton = _G["ContainerFrame"..i.."Item"..j]
				if ItemButton then
					local QuestIcon = _G["ContainerFrame"..i.."Item"..j.."IconQuestTexture"]
					local QuestTexture = QuestIcon:GetTexture()
					if QuestTexture == TEXTURE_ITEM_QUEST_BANG then
						QuestIcon:SetAlpha(1)
					else
						QuestIcon:SetAlpha(0)
					end
				end
			end
		end
	end

	hooksecurefunc("BankFrameItemButton_Update", UpdateBagIcon)
	hooksecurefunc("ContainerFrame_Update", UpdateBagIcon)

	BagItemSearchBox:StripTextures()
	BagItemSearchBox:CreateBorder()
	BackpackTokenFrame:StripTextures()

	BagItemAutoSortButton:SkinButton()
	BagItemAutoSortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
	BagItemAutoSortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
	BagItemAutoSortButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	BagItemAutoSortButton:GetNormalTexture():SetInside()
	BagItemAutoSortButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	BagItemAutoSortButton:GetPushedTexture():SetInside()
	BagItemAutoSortButton:SetSize(22, 22)

	BagItemAutoSortButton:SetScript("OnShow", function(self)
		local a, b, c, d, e = self:GetPoint()
		self:SetPoint(a, b, c, d - 3, e - 1)
		self.SetPoint = K.Noop
		self:SetScript("OnShow", nil)
	end)

	for i = 1, 3 do
		local Token = _G["BackpackTokenFrameToken"..i]
		Token.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		Token:CreateBackdrop()
		Token.Backdrop:SetFrameLevel(2)
		Token.Backdrop:SetOutside(Token.icon)
		Token.icon:SetPoint("LEFT", Token.count, "RIGHT", 3, 0)
	end

	BankFrame:CreateBorder()
	BankFrameCloseButton:SkinCloseButton()
	BankFrameMoneyFrameBorder:StripTextures()
	BankFrameMoneyFrameInset:StripTextures()
	BankSlotsFrame:StripTextures()

	BankFramePurchaseButton:SkinButton()
	BankFramePurchaseButton:SetHeight(22)

	BankItemSearchBox:StripTextures()
	BankItemSearchBox:SetSize(159, 16)
	BankItemSearchBox:CreateBorder()

	BankItemAutoSortButton:SkinButton()
	BankItemAutoSortButton:SetNormalTexture("Interface\\ICONS\\INV_Pet_Broom")
	BankItemAutoSortButton:SetPushedTexture("Interface\\ICONS\\INV_Pet_Broom")
	BankItemAutoSortButton:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	BankItemAutoSortButton:GetNormalTexture():SetInside()
	BankItemAutoSortButton:GetPushedTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	BankItemAutoSortButton:GetPushedTexture():SetInside()
	BankItemAutoSortButton:SetSize(20, 20)
	BankItemAutoSortButton:SetPoint("LEFT", BankItemSearchBox, "RIGHT", 4, 0)

	-- Bank Bags
	for i = 1, 7 do
		local BankBag = BankSlotsFrame["Bag"..i]
		BankBag:CreateBorder()
		BankBag.HighlightFrame.HighlightTexture:SetTexture(1, 1, 1, .2)
		BankBag:StyleButton()
		BankBag.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		BankBag.icon:SetInside()

		hooksecurefunc(BankBag.IconBorder, "SetVertexColor", function(self, r, g, b, a)
			BankBag:SetBackdropBorderColor(r, g, b)
		end)

		hooksecurefunc(BankBag.IconBorder, "Hide", function(self)
			BankBag:SetBackdropBorderColor()
		end)
	end

	-- Bank Slots
	for i = 1, 28 do
		local ItemButton = _G["BankFrameItem"..i]
		ItemButton:CreateBorder()
		ItemButton.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		ItemButton.icon:SetInside()

		ItemButton.searchOverlay:SetAllPoints(ItemButton.icon)
		ItemButton.searchOverlay:SetTexture(0, 0, 0, .8)

		ItemButton:SetNormalTexture(nil)
		ItemButton:StyleButton()

		hooksecurefunc(ItemButton.IconBorder, "SetVertexColor", function(self, r, g, b, a)
			ItemButton:SetBackdropBorderColor(r, g, b)
		end)
		hooksecurefunc(ItemButton.IconBorder, "Hide", function(self)
			ItemButton:SetBackdropBorderColor()
		end)
	end

	-- Reagent Bank
	ReagentBankFrame.DespositButton:SkinButton()
	ReagentBankFrame:HookScript("OnShow", function(self)
		if ReagentBankFrame.slots_initialized and not ReagentBankFrame.isSkinned then
			for i = 1, 98 do
				local ItemButton = _G["ReagentBankFrameItem"..i]
				ItemButton:CreateBorder()
				ItemButton.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				ItemButton.icon:SetInside()

				ItemButton.searchOverlay:SetAllPoints(ItemButton.icon)
				ItemButton.searchOverlay:SetTexture(0, 0, 0, .8)

				ItemButton:SetNormalTexture(nil)
				ItemButton:StyleButton()

				hooksecurefunc(ItemButton.IconBorder, "SetVertexColor", function(self, r, g, b, a)
					ItemButton:SetBackdropBorderColor(r, g, b)
				end)

				hooksecurefunc(ItemButton.IconBorder, "Hide", function(self)
					ItemButton:SetBackdropBorderColor()
				end)

				BankFrameItemButton_Update(ItemButton)
			end

			ReagentBankFrame:StripTextures(true)
			self.isSkinned = true
		end
	end)

	-- BankFrameTab1:SkinTab()
	-- BankFrameTab2:SkinTab()
end

table.insert(Module.SkinFuncs["KkthnxUI"], SkinBlizzardBags)