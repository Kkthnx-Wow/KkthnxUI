local K, C, L = select(2, ...):unpack()
if C.Bags.Enable ~= true then return end

local _G = _G
local ReplaceBags = 0
local LastButtonBag, LastButtonBank, LastButtonReagent
local Token1, Token2, Token3 = BackpackTokenFrameToken1, BackpackTokenFrameToken2, BackpackTokenFrameToken3
local Bags = CreateFrame("Frame")
local Inventory = CreateFrame("Frame")
local QuestColor = {1, 1, 0}

local BlizzardBags = {
	CharacterBag0Slot,
	CharacterBag1Slot,
	CharacterBag2Slot,
	CharacterBag3Slot,
}

local BlizzardBank = {
	BankSlotsFrame["Bag1"],
	BankSlotsFrame["Bag2"],
	BankSlotsFrame["Bag3"],
	BankSlotsFrame["Bag4"],
	BankSlotsFrame["Bag5"],
	BankSlotsFrame["Bag6"],
	BankSlotsFrame["Bag7"],
}

local BagType = {
	[8] = true, -- Leatherworking Bag
	[16] = true, -- Inscription Bag
	[32] = true, -- Herb Bag
	[64] = true, -- Enchanting Bag
	[128] = true, -- Engineering Bag
	[512] = true, -- Gem Bag
	[1024] = true, -- Mining Bag
	[32768] = true, -- Fishing Bag
}

function Bags:IsProfessionBag(bag)
	local Type = select(2, GetContainerNumFreeSlots(bag))

	if BagType[Type] then
		return true
	end
end

function Bags:SkinBagButton()
	if self.IsSkinned then
		return
	end

	local Icon = _G[self:GetName().."IconTexture"]
	local Quest = _G[self:GetName().."IconQuestTexture"]
	local JunkIcon = self.JunkIcon
	local Border = self.IconBorder
	local BattlePay = self.BattlepayItemTexture

	Border:SetAlpha(0)

	Icon:SetTexCoord(unpack(K.TexCoords))
	Icon:SetInside(self)

	if Quest then
		Quest:SetAlpha(0)
	end

	if JunkIcon then
		JunkIcon:SetAlpha(0)
	end

	if BattlePay then
		BattlePay:SetAlpha(0)
	end

	self:SetNormalTexture("")
	self:SetPushedTexture("")
	self:CreateBackdrop()
	self.backdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	self:StyleButton()

	self.IsSkinned = true
end

function Bags:HideBlizzard()
	local TokenFrame = _G["BackpackTokenFrame"]
	local Inset = _G["BankFrameMoneyFrameInset"]
	local Border = _G["BankFrameMoneyFrameBorder"]
	local BankClose = _G["BankFrameCloseButton"]
	local BankPortraitTexture = _G["BankPortraitTexture"]
	local BankSlotsFrame = _G["BankSlotsFrame"]

	TokenFrame:GetRegions():SetAlpha(0)
	Inset:Hide()
	Border:Hide()
	BankClose:Hide()
	BankPortraitTexture:Hide()
	BagHelpBox:Kill()
	BankFrame:EnableMouse(false)

	for i = 1, 12 do
		local CloseButton = _G["ContainerFrame"..i.."CloseButton"]
		CloseButton:Hide()

		for k = 1, 7 do
			local Container = _G["ContainerFrame"..i]
			select(k, Container:GetRegions()):SetAlpha(0)
		end
	end

	-- Hide Bank Frame Textures
	for i = 1, BankFrame:GetNumRegions() do
		local Region = select(i, BankFrame:GetRegions())

		Region:SetAlpha(0)
	end

	-- Hide BankSlotsFrame Textures and Fonts
	for i = 1, BankSlotsFrame:GetNumRegions() do
		local Region = select(i, BankSlotsFrame:GetRegions())

		Region:SetAlpha(0)
	end

	-- Hide Tabs, we will create our tabs
	for i = 1, 2 do
		local Tab = _G["BankFrameTab"..i]
		Tab:Hide()
	end
end

function Bags:CreateReagentContainer()
	if select(4, GetAddOnInfo("TradeSkillMaster")) then
		return
	end

	ReagentBankFrame:StripTextures()

	local Reagent = CreateFrame("Frame", "KkthnxUIReagent", UIParent)
	local SwitchBankButton = CreateFrame("Button", nil, Reagent)
	local SortButton = CreateFrame("Button", nil, Reagent)
	local NumButtons = ReagentBankFrame.size
	local NumRows, LastRowButton, NumButtons, LastButton = 0, ReagentBankFrameItem1, 1, ReagentBankFrameItem1
	local Deposit = ReagentBankFrame.DespositButton
	local Movers = K.Movers

	Reagent:SetWidth(((C.Bags.ButtonSize + C.Bags.Spacing) * C.Bags.ItemsPerRow) + 22 - C.Bags.Spacing)
	Reagent:SetPoint(unpack(C.Position.Bank))
	Reagent:SetTemplate()
	Reagent:SetFrameStrata(self.Bank:GetFrameStrata())
	Reagent:SetFrameLevel(self.Bank:GetFrameLevel())

	SwitchBankButton:SetSize((Reagent:GetWidth() / 2) - 8, 23)
	SwitchBankButton:SkinButton()
	SwitchBankButton:SetPoint("BOTTOMLEFT", Reagent, "TOPLEFT", 4, 2)

	SwitchBankButton.Text = SwitchBankButton:CreateFontString(nil, "OVERLAY")
	SwitchBankButton.Text:SetFont(C.Media.Font, 12)
	SwitchBankButton.Text:SetJustifyH("LEFT")
	SwitchBankButton.Text:SetShadowColor(0, 0, 0)
	SwitchBankButton.Text:SetShadowOffset(K.Mult,-K.Mult)
	SwitchBankButton.Text:SetPoint("CENTER")
	SwitchBankButton.Text:SetText("Switch to: "..BANK)
	SwitchBankButton:SetScript("OnClick", function()
		Reagent:Hide()
		self.Bank:Show()
		BankFrame_ShowPanel(BANK_PANELS[1].name)

		for i = 5, 11 do
			if (not IsBagOpen(i)) then

				self:OpenBag(i, 1)
			end
		end
	end)

	Deposit:SetParent(Reagent)
	Deposit:ClearAllPoints()
	Deposit:SetSize(Reagent:GetWidth() - 8, 23)
	Deposit:SetPoint("BOTTOMLEFT", SwitchBankButton, "TOPLEFT", 0, 6)
	Deposit:SkinButton()

	SortButton:SetSize((Reagent:GetWidth() / 2) - 8, 23)
	SortButton:SetPoint("LEFT", SwitchBankButton, "RIGHT", 8, 0)
	SortButton:SkinButton()
	SortButton.Text = SortButton:CreateFontString(nil, "OVERLAY")
	SortButton.Text:SetFont(C.Media.Font, 12)
	SortButton.Text:SetJustifyH("LEFT")
	SortButton.Text:SetShadowColor(0, 0, 0)
	SortButton.Text:SetShadowOffset(K.Mult,-K.Mult)
	SortButton.Text:SetPoint("CENTER")
	SortButton.Text:SetText(BAG_FILTER_CLEANUP)
	SortButton:SetScript("OnClick", BankFrame_AutoSortButtonOnClick)

	for i = 1, 98 do
		local Button = _G["ReagentBankFrameItem"..i]
		local Count = _G[Button:GetName().."Count"]
		local Icon = _G[Button:GetName().."IconTexture"]

		ReagentBankFrame:SetParent(Reagent)
		ReagentBankFrame:ClearAllPoints()
		ReagentBankFrame:SetAllPoints()

		Button:ClearAllPoints()
		Button:SetWidth(C.Bags.ButtonSize)
		Button:SetHeight(C.Bags.ButtonSize)
		Button:SetNormalTexture("")
		Button:SetPushedTexture("")
		Button:SetHighlightTexture("")
		Button:CreateBackdrop()
		Button.IconBorder:SetAlpha(0)

		if (i == 1) then
			Button:SetPoint("TOPLEFT", Reagent, "TOPLEFT", 10, -10)
			LastRowButton = Button
			LastButton = Button
		elseif (NumButtons == C.Bags.ItemsPerRow) then
			Button:SetPoint("TOPRIGHT", LastRowButton, "TOPRIGHT", 0, -(C.Bags.Spacing + C.Bags.ButtonSize))
			Button:SetPoint("BOTTOMLEFT", LastRowButton, "BOTTOMLEFT", 0, -(C.Bags.Spacing + C.Bags.ButtonSize))
			LastRowButton = Button
			NumRows = NumRows + 1
			NumButtons = 1
		else
			Button:SetPoint("TOPRIGHT", LastButton, "TOPRIGHT", (C.Bags.Spacing + C.Bags.ButtonSize), 0)
			Button:SetPoint("BOTTOMLEFT", LastButton, "BOTTOMLEFT", (C.Bags.Spacing + C.Bags.ButtonSize), 0)
			NumButtons = NumButtons + 1
		end

		Icon:SetTexCoord(unpack(K.TexCoords))
		Icon:SetInside()

		LastButton = Button

		self:SlotUpdate(-3, Button)
	end

	Reagent:SetHeight(((C.Bags.ButtonSize + C.Bags.Spacing) * (NumRows + 1) + 20) - C.Bags.Spacing)
	Reagent:SetScript("OnHide", function()
		ReagentBankFrame:Hide()
	end)

	-- Unlock window
	local Unlock = ReagentBankFrameUnlockInfo
	local UnlockButton = ReagentBankFrameUnlockInfoPurchaseButton

	Unlock:StripTextures()
	Unlock:SetAllPoints(Reagent)
	Unlock:SetTemplate()

	UnlockButton:SkinButton()

	-- Movers:RegisterFrame(Reagent)

	self.Reagent = Reagent
	-- Couldn't access these.
	self.Reagent.SwitchBankButton = SwitchBankButton
	self.Reagent.SortButton = SortButton
end

function Bags:CreateContainer(storagetype, ...)
	local Container = CreateFrame("Frame", "KkthnxUI".. storagetype, UIParent)
	Container:SetScale(1)
	Container:SetWidth(((C.Bags.ButtonSize + C.Bags.Spacing) * C.Bags.ItemsPerRow) + 22 - C.Bags.Spacing)
	Container:SetPoint(...)
	Container:SetFrameStrata("MEDIUM")
	Container:SetFrameLevel(50)
	Container:RegisterForDrag("LeftButton","RightButton")
	Container:SetScript("OnDragStart", function(self) if IsShiftKeyDown() then self:StartMoving() end end)
	Container:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	Container:Hide()
	Container:SetTemplate()
	Container:SetClampedToScreen(true)
	Container:SetMovable(true)
	Container:SetUserPlaced(true)
	Container:EnableMouse(true)
	Container:RegisterForDrag("LeftButton", "RightButton")

	if (storagetype == "Bag") then
		local Sort = BagItemAutoSortButton
		local BagsContainer = CreateFrame("Frame", nil, UIParent)
		local ToggleBagsContainer = CreateFrame("Frame")

		BagsContainer:SetParent(Container)
		BagsContainer:SetWidth(10)
		BagsContainer:SetHeight(10)
		BagsContainer:SetPoint("BOTTOMRIGHT", Container, "TOPRIGHT", 0, 27)
		BagsContainer:Hide()
		--BagsContainer:SetTemplate()

		Sort:SetSize(Container:GetWidth() - 8, 23)
		Sort:ClearAllPoints()
		Sort:SetParent(Container)
		Sort:SetPoint("BOTTOMLEFT", Container, "TOPLEFT", 4, 2)
		Sort:SetFrameLevel(Container:GetFrameLevel())
		Sort:SetFrameStrata(Container:GetFrameStrata())
		Sort:StripTextures()
		Sort:SkinButton()
		Sort.Text = Sort:CreateFontString(nil, "OVERLAY")
		Sort.Text:SetFont(C.Media.Font, 12)
		Sort.Text:SetJustifyH("LEFT")
		Sort.Text:SetShadowColor(0, 0, 0)
		Sort.Text:SetShadowOffset(K.Mult,-K.Mult)
		Sort.Text:SetPoint("CENTER")
		Sort.Text:SetText(BAG_FILTER_CLEANUP)
		Sort.ClearAllPoints = K.Noop
		Sort.SetPoint = K.Noop

		local ToggleBagsContainer = CreateFrame("Button", "BagsCloseButton", Container, "UIPanelCloseButton")
		ToggleBagsContainer:SetPoint("TOPRIGHT", Container, "TOPRIGHT", -2, -2)
		ToggleBagsContainer:SetParent(Container)
		ToggleBagsContainer:EnableMouse(true)
		ToggleBagsContainer:SetScript("OnMouseUp", function(self, button)
			local Purchase = BankFramePurchaseInfo

			if (button == "RightButton") then
				local BanksContainer = Bags.Bank.BagsContainer
				local Purchase = BankFramePurchaseInfo
				local ReagentButton = Bags.Bank.ReagentButton

				if (ReplaceBags == 0) then
					ReplaceBags = 1
					BagsContainer:Show()
					BanksContainer:Show()
					BanksContainer:ClearAllPoints()
					--ToggleBagsContainer.Text:SetTextColor(1, 1, 1)

					if Purchase:IsShown() then
						BanksContainer:SetPoint("BOTTOMLEFT", Purchase, "TOPLEFT", 50, 2)
					else
						BanksContainer:SetPoint("BOTTOMLEFT", ReagentButton, "TOPLEFT", 0, 2)
					end
				else
					ReplaceBags = 0
					BagsContainer:Hide()
					BanksContainer:Hide()
					-- ToggleBagsContainer.Text:SetTextColor(.4, .4, .4)
				end
			else
				CloseAllBags()
				CloseBankBagFrames()
				CloseBankFrame()
				PlaySound("igBackPackClose")
			end
		end)

		for _, Button in pairs(BlizzardBags) do
			local Count = _G[Button:GetName().."Count"]
			local Icon = _G[Button:GetName().."IconTexture"]

			Button:SetParent(BagsContainer)
			Button:ClearAllPoints()
			Button:SetWidth(C.Bags.ButtonSize)
			Button:SetHeight(C.Bags.ButtonSize)
			Button:SetFrameStrata("HIGH")
			Button:SetFrameLevel(2)
			Button:SetNormalTexture("")
			Button:SetPushedTexture("")
			Button:SetCheckedTexture("")
			Button:CreateBackdrop()
			Button.IconBorder:SetAlpha(0)

			if LastButtonBag then
				Button:SetPoint("LEFT", LastButtonBag, "RIGHT", C.Bags.Spacing, 0)
			else
				Button:SetPoint("TOPLEFT", BagsContainer, "TOPLEFT", C.Bags.Spacing, -C.Bags.Spacing)
			end

			Count.Show = K.Noop
			Count:Hide()

			Icon:SetTexCoord(unpack(K.TexCoords))
			Icon:SetInside()

			LastButtonBag = Button
			BagsContainer:SetWidth((C.Bags.ButtonSize * getn(BlizzardBags)) + (C.Bags.Spacing * (getn(BlizzardBags) + 1)))
			BagsContainer:SetHeight(C.Bags.ButtonSize + (C.Bags.Spacing * 2))
		end

		Container.BagsContainer = BagsContainer
		Container.CloseButton = ToggleBagsContainer
		Container.SortButton = Sort
	else
		local PurchaseButton = BankFramePurchaseButton
		local CostText = BankFrameSlotCost
		local TotalCost = BankFrameDetailMoneyFrame
		local Purchase = BankFramePurchaseInfo
		local SortButton = CreateFrame("Button", nil, Container)
		local BankBagsContainer = CreateFrame("Frame", nil, Container)

		CostText:ClearAllPoints()
		CostText:SetPoint("BOTTOMLEFT", 60, 10)
		TotalCost:ClearAllPoints()
		TotalCost:SetPoint("LEFT", CostText, "RIGHT", 0, 0)
		PurchaseButton:ClearAllPoints()
		PurchaseButton:SetPoint("BOTTOMRIGHT", -10, 10)
		PurchaseButton:SkinButton()
		BankItemAutoSortButton:Hide()

		local SwitchReagentButton = CreateFrame("Button", nil, Container)
		SwitchReagentButton:SetSize((Container:GetWidth() / 2) - 8, 23)
		SwitchReagentButton:SkinButton()
		SwitchReagentButton:SetPoint("BOTTOMLEFT", Container, "TOPLEFT", 4, 2)
		SwitchReagentButton.Text = SwitchReagentButton:CreateFontString(nil, "OVERLAY")
		SwitchReagentButton.Text:SetFont(C.Media.Font, 12)
		SwitchReagentButton.Text:SetJustifyH("LEFT")
		SwitchReagentButton.Text:SetShadowColor(0, 0, 0)
		SwitchReagentButton.Text:SetShadowOffset(K.Mult,-K.Mult)
		SwitchReagentButton.Text:SetPoint("CENTER")
		SwitchReagentButton.Text:SetText("Switch to: "..REAGENT_BANK)
		SwitchReagentButton:SetScript("OnClick", function()
			BankFrame_ShowPanel(BANK_PANELS[2].name)

			if (not ReagentBankFrame.isMade) then
				self:CreateReagentContainer()
				ReagentBankFrame.isMade = true
			else
				self.Reagent:Show()

			end

			for i = 5, 11 do
				self:CloseBag(i)
			end
		end)

		SortButton:SetSize((Container:GetWidth() / 2) - 8, 23)
		SortButton:SetPoint("LEFT", SwitchReagentButton, "RIGHT", 8, 0)
		SortButton:SkinButton()
		SortButton.Text = SortButton:CreateFontString(nil, "OVERLAY")
		SortButton.Text:SetFont(C.Media.Font, 12)
		SortButton.Text:SetJustifyH("LEFT")
		SortButton.Text:SetShadowColor(0, 0, 0)
		SortButton.Text:SetShadowOffset(K.Mult,-K.Mult)
		SortButton.Text:SetPoint("CENTER")
		SortButton.Text:SetText(BAG_FILTER_CLEANUP)
		SortButton:SetScript("OnClick", BankFrame_AutoSortButtonOnClick)

		Purchase:ClearAllPoints()
		Purchase:SetWidth(Container:GetWidth() + 50)
		Purchase:SetHeight(70)
		Purchase:SetPoint("BOTTOMLEFT", SwitchReagentButton, "TOPLEFT", -54, 2)
		Purchase:CreateBackdrop()
		Purchase.backdrop:SetPoint("TOPLEFT", 50, 0)
		Purchase.backdrop:SetPoint("BOTTOMRIGHT", 0, 0)

		BankBagsContainer:SetSize(Container:GetWidth(), BankSlotsFrame.Bag1:GetHeight() + C.Bags.Spacing + C.Bags.Spacing)
		BankBagsContainer:SetPoint("BOTTOMLEFT", SwitchReagentButton, "TOPLEFT", 0, 2)
		BankBagsContainer:SetFrameLevel(Container:GetFrameLevel())
		BankBagsContainer:SetFrameStrata(Container:GetFrameStrata())

		for i = 1, 7 do
			local Bag = BankSlotsFrame["Bag"..i]
			Bag.HighlightFrame:Kill() -- Bugged Texture on Bank Bag Slot

			Bag:SetParent(BankBagsContainer)
			Bag:SetWidth(C.Bags.ButtonSize)
			Bag:SetHeight(C.Bags.ButtonSize)

			Bag.IconBorder:SetAlpha(0)
			Bag.icon:SetTexCoord(unpack(K.TexCoords))
			Bag.icon:SetInside()
			Bag:SkinButton()
			Bag:ClearAllPoints()

			if i == 1 then
				Bag:SetPoint("TOPLEFT", BankBagsContainer, "TOPLEFT", C.Bags.Spacing, -C.Bags.Spacing)
			else
				Bag:SetPoint("LEFT", BankSlotsFrame["Bag"..i-1], "RIGHT", C.Bags.Spacing, 0)
			end
		end

		BankBagsContainer:SetWidth((C.Bags.ButtonSize * 7) + (C.Bags.Spacing * (7 + 1)))
		BankBagsContainer:SetHeight(C.Bags.ButtonSize + (C.Bags.Spacing * 2))
		BankBagsContainer:Hide()

		BankFrame:EnableMouse(false)

		Container.BagsContainer = BankBagsContainer
		Container.ReagentButton = SwitchReagentButton
		Container.SortButton = SortButton
	end

	self[storagetype] = Container
end

function Bags:SetBagsSearchPosition()
	local BagItemSearchBox = BagItemSearchBox
	local BankItemSearchBox = BankItemSearchBox

	BagItemSearchBox:SetParent(self.Bag)
	BagItemSearchBox:SetWidth(self.Bag:GetWidth() - (C.Bags.Spacing + C.Bags.Spacing + C.Bags.Spacing + C.Bags.Spacing))
	BagItemSearchBox:ClearAllPoints()
	BagItemSearchBox:SetPoint("BOTTOMLEFT", self.Bag, "BOTTOMLEFT", C.Bags.Spacing - 1, C.Bags.Spacing * 3)
	BagItemSearchBox:StripTextures()
	BagItemSearchBox.SetParent = K.Noop
	BagItemSearchBox.ClearAllPoints = K.Noop
	BagItemSearchBox.SetPoint = K.Noop
	BagItemSearchBox.Backdrop = CreateFrame("Frame", nil, BagItemSearchBox)
	BagItemSearchBox.Backdrop:SetPoint("TOPLEFT", 7, 6)
	BagItemSearchBox.Backdrop:SetPoint("BOTTOMRIGHT", 2, -4)
	BagItemSearchBox.Backdrop:SetTemplate()
	BagItemSearchBox.Backdrop:SetFrameLevel(BagItemSearchBox:GetFrameLevel() - 1)

	BankItemSearchBox:Hide()
end

function Bags:SetTokensPosition()
	local Money = ContainerFrame1MoneyFrame

	Token3:ClearAllPoints()
	Token3:SetPoint("LEFT", Money, "RIGHT", 2, -2)
	Token2:ClearAllPoints()
	Token2:SetPoint("LEFT", Token3, "RIGHT", 10, 0)
	Token1:ClearAllPoints()
	Token1:SetPoint("LEFT", Token2, "RIGHT", 10, 0)
end

function Bags:SkinTokens()
	for i = 1, 3 do
		local Token = _G["BackpackTokenFrameToken"..i]
		local Icon = _G["BackpackTokenFrameToken"..i.."Icon"]
		local Count = _G["BackpackTokenFrameToken"..i.."Count"]
		local PreviousToken = _G["BackpackTokenFrameToken"..(i - 1)]

		Token:SetFrameStrata("HIGH")
		Token:SetFrameLevel(5)
		Token:SetScale(1)

		Icon:SetSize(12, 12)
		Icon:SetTexCoord(unpack(K.TexCoords))
		Icon:SetPoint("LEFT", Token, "RIGHT", -8, 2)

		Count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	end
end

function Bags:SlotUpdate(id, button)
	if not button then
		return
	end

	local ItemLink = GetContainerItemLink(id, button:GetID())

	local Texture, Count, Lock, quality, _, _, _, _, _, ItemID = GetContainerItemInfo(id, button:GetID())
	local IsNewItem = C_NewItems.IsNewItem(id, button:GetID())

	if IsNewItem ~= true and button.Animation and button.Animation:IsPlaying() then
		button.Animation:Stop()
	end

	if (button.ItemID == ItemID) then
		return
	end

	button.ItemID = ItemID

	local IsQuestItem, QuestId, IsActive = GetContainerItemQuestInfo(id, button:GetID())
	local IsBattlePayItem = IsBattlePayItem(id, button:GetID())
	local NewItem = button.NewItemTexture
	local IsProfBag = self:IsProfessionBag(id)
	local IconQuestTexture = button.IconQuestTexture

	if IconQuestTexture then
		IconQuestTexture:SetAlpha(0)
	end

	-- Letting you style this
	if IsProfBag then

	else
		--button:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	end

	if IsNewItem and NewItem then
		NewItem:SetAlpha(0)

		if C.Bags.PulseNewItem then
			if not button.Animation then
				button.Animation = button:CreateAnimationGroup()
				button.Animation:SetLooping("BOUNCE")

				button.FadeOut = button.Animation:CreateAnimation("Alpha")
				button.FadeOut:SetFromAlpha(1)
				button.FadeOut:SetToAlpha(0)
				button.FadeOut:SetDuration(0.40)
				button.FadeOut:SetSmoothing("IN_OUT")
			end

			button.Animation:Play()
		end
	end

	if IsQuestItem then
		button.backdrop:SetBackdropBorderColor(1, 1, 0)
	elseif ItemLink then
		local Rarity = select(3, GetItemInfo(ItemLink)) or 0

		button.backdrop:SetBackdropBorderColor(GetItemQualityColor(Rarity))
	else
		button.backdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	end
end

function Bags:BagUpdate(id)
	local Size = GetContainerNumSlots(id)

	for Slot = 1, Size do
		local Button = _G["ContainerFrame"..(id + 1).."Item"..Slot]

		if Button then
			if not Button:IsShown() then
				Button:Show()
			end

			self:SlotUpdate(id, Button)
		end
	end
end

function Bags:UpdateAllBags()
	local NumRows, LastRowButton, NumButtons, LastButton = 0, ContainerFrame1Item1, 1, ContainerFrame1Item1
	local FirstButton

	for Bag = 5, 1, -1 do
		local ID = Bag - 1
		local Slots = GetContainerNumSlots(ID)

		for Item = Slots, 1, -1 do
			local Button = _G["ContainerFrame"..Bag.."Item"..Item]
			local Money = ContainerFrame1MoneyFrame

			if not FirstButton then
				FirstButton = Button
			end

			Button:ClearAllPoints()
			Button:SetWidth(C.Bags.ButtonSize)
			Button:SetHeight(C.Bags.ButtonSize)
			Button:SetScale(1)
			Button:SetFrameStrata("HIGH")
			Button:SetFrameLevel(2)

			Button.newitemglowAnim:Stop()
			Button.newitemglowAnim.Play = K.Noop

			Button.flashAnim:Stop()
			Button.flashAnim.Play = K.Noop

			Money:ClearAllPoints()
			Money:Show()
			Money:SetPoint("TOPLEFT", Bags.Bag, "TOPLEFT", 8, -10)
			Money:SetFrameStrata("HIGH")
			Money:SetFrameLevel(2)
			Money:SetScale(1)

			if (Button == FirstButton) then
				Button:SetPoint("TOPLEFT", Bags.Bag, "TOPLEFT", 10, -40)
				LastRowButton = Button
				LastButton = Button
			elseif (NumButtons == C.Bags.ItemsPerRow) then
				Button:SetPoint("TOPRIGHT", LastRowButton, "TOPRIGHT", 0, -(C.Bags.Spacing + C.Bags.ButtonSize))
				Button:SetPoint("BOTTOMLEFT", LastRowButton, "BOTTOMLEFT", 0, -(C.Bags.Spacing + C.Bags.ButtonSize))
				LastRowButton = Button
				NumRows = NumRows + 1
				NumButtons = 1
			else
				Button:SetPoint("TOPRIGHT", LastButton, "TOPRIGHT", (C.Bags.Spacing + C.Bags.ButtonSize), 0)
				Button:SetPoint("BOTTOMLEFT", LastButton, "BOTTOMLEFT", (C.Bags.Spacing + C.Bags.ButtonSize), 0)
				NumButtons = NumButtons + 1
			end

			Bags.SkinBagButton(Button)

			LastButton = Button
		end

		Bags:BagUpdate(ID)
	end

	Bags.Bag:SetHeight(((C.Bags.ButtonSize + C.Bags.Spacing) * (NumRows + 1) + 54 + BagItemSearchBox:GetHeight() + (C.Bags.Spacing * 4)) - C.Bags.Spacing)
end

function Bags:UpdateAllBankBags()
	local NumRows, LastRowButton, NumButtons, LastButton = 0, ContainerFrame1Item1, 1, ContainerFrame1Item1

	for Bank = 1, 28 do
		local Button = _G["BankFrameItem"..Bank]
		local Money = ContainerFrame2MoneyFrame
		local BankFrameMoneyFrame = BankFrameMoneyFrame

		Button:ClearAllPoints()
		Button:SetWidth(C.Bags.ButtonSize)
		Button:SetHeight(C.Bags.ButtonSize)
		Button:SetFrameStrata("HIGH")
		Button:SetFrameLevel(2)
		Button:SetScale(1)
		Button.IconBorder:SetAlpha(0)

		BankFrameMoneyFrame:Hide()

		if (Bank == 1) then
			Button:SetPoint("TOPLEFT", Bags.Bank, "TOPLEFT", 10, -10)
			LastRowButton = Button
			LastButton = Button
		elseif (NumButtons == C.Bags.ItemsPerRow) then
			Button:SetPoint("TOPRIGHT", LastRowButton, "TOPRIGHT", 0, -(C.Bags.Spacing + C.Bags.ButtonSize))
			Button:SetPoint("BOTTOMLEFT", LastRowButton, "BOTTOMLEFT", 0, -(C.Bags.Spacing + C.Bags.ButtonSize))
			LastRowButton = Button
			NumRows = NumRows + 1
			NumButtons = 1
		else
			Button:SetPoint("TOPRIGHT", LastButton, "TOPRIGHT", (C.Bags.Spacing + C.Bags.ButtonSize), 0)
			Button:SetPoint("BOTTOMLEFT", LastButton, "BOTTOMLEFT", (C.Bags.Spacing + C.Bags.ButtonSize), 0)
			NumButtons = NumButtons + 1
		end

		Bags.SkinBagButton(Button)
		Bags.SlotUpdate(self, -1, Button)

		LastButton = Button
	end

	for Bag = 6, 12 do
		local Slots = GetContainerNumSlots(Bag - 1)

		for Item = Slots, 1, -1 do
			local Button = _G["ContainerFrame"..Bag.."Item"..Item]

			Button:ClearAllPoints()
			Button:SetWidth(C.Bags.ButtonSize)
			Button:SetHeight(C.Bags.ButtonSize)
			Button:SetFrameStrata("HIGH")
			Button:SetFrameLevel(2)
			Button:SetScale(1)
			Button.IconBorder:SetAlpha(0)

			if (NumButtons == C.Bags.ItemsPerRow) then
				Button:SetPoint("TOPRIGHT", LastRowButton, "TOPRIGHT", 0, -(C.Bags.Spacing + C.Bags.ButtonSize))
				Button:SetPoint("BOTTOMLEFT", LastRowButton, "BOTTOMLEFT", 0, -(C.Bags.Spacing + C.Bags.ButtonSize))
				LastRowButton = Button
				NumRows = NumRows + 1
				NumButtons = 1
			else
				Button:SetPoint("TOPRIGHT", LastButton, "TOPRIGHT", (C.Bags.Spacing+C.Bags.ButtonSize), 0)
				Button:SetPoint("BOTTOMLEFT", LastButton, "BOTTOMLEFT", (C.Bags.Spacing+C.Bags.ButtonSize), 0)
				NumButtons = NumButtons + 1
			end

			Bags.SkinBagButton(Button)
			Bags.SlotUpdate(self, Bag - 1, Button)

			LastButton = Button
		end
	end

	Bags.Bank:SetHeight(((C.Bags.ButtonSize + C.Bags.Spacing) * (NumRows + 1) + 20) - C.Bags.Spacing)
end

function Bags:OpenBag(id)
	if (not CanOpenPanels()) then
		if (UnitIsDead("player")) then
			NotWhileDeadError()
		end

		return
	end

	local Size = GetContainerNumSlots(id)
	local OpenFrame = ContainerFrame_GetOpenFrame()

	for i = 1, Size, 1 do
		local Index = Size - i + 1
		local Button = _G[OpenFrame:GetName().."Item"..i]

		Button:SetID(Index)
		Button:Show()
	end

	OpenFrame.size = Size
	OpenFrame:SetID(id)
	OpenFrame:Show()

	if (id == 4) then
		Bags:UpdateAllBags()
	elseif (id == 11) then
		Bags:UpdateAllBankBags()
	end
end

function Bags:CloseBag(id)
	CloseBag(id)
end

function Bags:OpenAllBags()
	self:OpenBag(0, 1)

	for i = 1, 4 do
		self:OpenBag(i, 1)
	end

	if IsBagOpen(0) then
		self.Bag:Show()
	end
end

function Bags:OpenAllBankBags()
	local Bank = BankFrame

	if Bank:IsShown() then
		self.Bank:Show()

		for i = 5, 11 do
			if (not IsBagOpen(i)) then

				self:OpenBag(i, 1)
			end
		end
	end
end

function Bags:CloseAllBags()
	if MerchantFrame:IsVisible() or InboxFrame:IsVisible() then
		return
	end

	CloseAllBags()
	PlaySound("igBackPackClose")
end

function Bags:CloseAllBankBags()
	local Bank = BankFrame

	if (Bank:IsVisible()) then
		CloseBankBagFrames()
		CloseBankFrame()
	end
end

function Bags:ToggleBags()
	if (self.Bag:IsShown() and BankFrame:IsShown()) and (not self.Bank:IsShown()) and (not ReagentBankFrame:IsShown()) then
		self:OpenAllBankBags()

		return
	end

	if (self.Bag:IsShown() or self.Bank:IsShown()) then
		if MerchantFrame:IsVisible() or InboxFrame:IsVisible() then
			return
		end

		self:CloseAllBags()
		self:CloseAllBankBags()

		return
	end

	if not self.Bag:IsShown() then
		self:OpenAllBags()
	end

	if not self.Bank:IsShown() and BankFrame:IsShown() then
		self:OpenAllBankBags()
	end
end

function Bags:OnEvent(event, ...)
	if (event == "BAG_UPDATE") then
		self:BagUpdate(...)
	elseif (event == "BAG_CLOSED") then
		-- This is usually where the client find a bag swap in character or bank slots.

		local Bag = ... + 1

		-- We need to hide buttons from a bag when closing it because they are not parented to the original frame
		local Container = _G["ContainerFrame"..Bag]
		local Size = Container.size

		for i = 1, Size do
			local Button = _G["ContainerFrame"..Bag.."Item"..i]

			if Button then
				Button:Hide()
			end
		end

		-- We close to refresh the all in one layout.
		self:CloseAllBags()
		self:CloseAllBankBags()
	elseif (event == "PLAYERBANKSLOTS_CHANGED") then
		local ID = ...

		if ID <= 28 then
			local Button = _G["BankFrameItem"..ID]

			if (Button) then
				self:SlotUpdate(-1, Button)
			end
		end
	elseif (event == "PLAYERREAGENTBANKSLOTS_CHANGED") then
		local ID = ...

		local Button = _G["ReagentBankFrameItem"..ID]

		if (Button) then
			self:SlotUpdate(-3, Button)
		end
	end
end

function Bags:Enable()
	if (not C.Bags.Enable) then
		return
	end

	if C.Bags.SortRightToLeft == false then
		SetSortBagsRightToLeft(false)
	else
		SetSortBagsRightToLeft(true)
	end

	if C.Bags.InsertLeftToRight == true then
		SetInsertItemsLeftToRight(true)
	else
		SetInsertItemsLeftToRight(false)
	end

	local Bag = ContainerFrame1
	local GameMenu = GameMenuFrame
	local Bank = BankFrameItem1
	local BankFrame = BankFrame

	self:CreateContainer("Bag", unpack(C.Position.Bag))
	self:CreateContainer("Bank", unpack(C.Position.Bank))
	self:HideBlizzard()
	self:SetBagsSearchPosition()
	self:SetTokensPosition()
	self:SkinTokens()

	Bag:SetScript("OnHide", function()
		self.Bag:Hide()

		if self.Reagent and self.Reagent:IsShown() then
			self.Reagent:Hide()
		end
	end)

	Bank:SetScript("OnHide", function()
		self.Bank:Hide()
	end)

	BankFrame:HookScript("OnHide", function()
		if self.Reagent and self.Reagent:IsShown() then
			self.Reagent:Hide()
		end
	end)

	-- Rewrite Blizzard Bags Functions
	function UpdateContainerFrameAnchors() end
	function ToggleBag() ToggleAllBags() end
	function ToggleBackpack() ToggleAllBags() end
	function OpenAllBags() ToggleAllBags() end
	function OpenBackpack() ToggleAllBags() end
	function ToggleAllBags() self:ToggleBags() end

	-- Register Events for Updates
	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
	self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")
	-- self:RegisterEvent("BAG_CLOSED")
	self:SetScript("OnEvent", self.OnEvent)

	-- Force an update, setting colors
	ToggleAllBags()
	ToggleAllBags()
end

Inventory.Bags = Bags
Bags:RegisterEvent("PLAYER_LOGIN")
Bags:SetScript("OnEvent", Bags.Enable)