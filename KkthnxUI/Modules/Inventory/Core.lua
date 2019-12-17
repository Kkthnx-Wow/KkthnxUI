local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Bags")
local cargBags = cargBags or K.cargBags

local ceil = _G.ceil
local ipairs = _G.ipairs
local string_match = _G.string.match
local unpack = _G.unpack
local table_wipe = _G.table.wipe

local BAG_ITEM_QUALITY_COLORS = _G.BAG_ITEM_QUALITY_COLORS
local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = _G.C_NewItems.RemoveNewItem
local C_Timer_After = _G.C_Timer.After
local ClearCursor = _G.ClearCursor
local CreateFrame = _G.CreateFrame
local DeleteCursorItem = _G.DeleteCursorItem
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumFreeSlots = _G.GetContainerNumFreeSlots
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetInventoryItemID = _G.GetInventoryItemID
local GetItemInfo = _G.GetItemInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR
local LE_ITEM_QUALITY_RARE = _G.LE_ITEM_QUALITY_RARE
local PickupContainerItem = _G.PickupContainerItem
local PlaySound = _G.PlaySound
local SortBags = _G.SortBags
local SortBankBags = _G.SortBankBags

local bagsFont = K.GetFont(C["UIFonts"].InventoryFonts)
local deleteEnable, favouriteEnable

local sortCache = {}
function Module:ReverseSort()
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local texture, _, locked = GetContainerItemInfo(bag, slot)
			if (slot <= numSlots/2) and texture and not locked and not sortCache["b"..bag.."s"..slot] then
				PickupContainerItem(bag, slot)
				PickupContainerItem(bag, numSlots+1 - slot)
				sortCache["b"..bag.."s"..slot] = true
				C_Timer_After(.1, Module.ReverseSort)
				return
			end
		end
	end

	KKUI_Backpack.isSorting = false
	KKUI_Backpack:BAG_UPDATE()
end

function Module:UpdateAnchors(parent, bags)
	local anchor = parent
	for _, bag in ipairs(bags) do
		if bag:GetHeight() > 45 then
			bag:Show()
		else
			bag:Hide()
		end

		if bag:IsShown() then
			bag:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 5)
			anchor = bag
		end
	end
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or .3)
end

function Module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(160, 32)

	local icon = CreateFrame("Button", nil, infoFrame)
	icon:SetSize(18, 18)
	icon:SetPoint("LEFT")
	icon:SkinButton()
	icon:CreateInnerShadow()

	icon.Icon = icon:CreateTexture(nil, "ARTWORK")
	icon.Icon:SetAllPoints()
	icon.Icon:SetTexCoord(unpack(K.TexCoords))
	icon.Icon:SetTexture("Interface\\Minimap\\Tracking\\None")
	icon.Icon:SetTexCoord(1, 0, 0, 1)

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	search:DisableDrawLayer("BACKGROUND")
	search:CreateBackdrop()
	search.Backdrop:SetPoint("TOPLEFT", -5, -7)
	search.Backdrop:SetPoint("BOTTOMRIGHT", 5, 7)

	local moneyTag = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
	moneyTag:SetFontObject(bagsFont)
	moneyTag:SetFont(select(1, moneyTag:GetFont()), 13, select(3, moneyTag:GetFont()))
	moneyTag:SetPoint("LEFT", icon, "RIGHT", 6, 0)

	local currencyTag = self:SpawnPlugin("TagDisplay", "[currencies]", infoFrame)
	currencyTag:SetFontObject(bagsFont)
	currencyTag:SetFont(select(1, currencyTag:GetFont()), 13, select(3, currencyTag:GetFont()))
	currencyTag:SetPoint("TOP", self, "BOTTOM", 0, -6)
end

function Module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local width, height = bagBar:LayoutButtons("grid", columns, 5, 5, -5)
	bagBar:SetSize(width + 10, height + 10)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
	bagBar:CreateBorder()
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()

	self.BagBar = bagBar
end

function Module:CreateCloseButton()
	local closeButton = CreateFrame("Button", nil, self)
	closeButton:SetSize(18, 18)
	closeButton:SkinButton()
	closeButton:CreateInnerShadow()

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetAllPoints()
	closeButton.Icon:SetTexCoord(unpack(K.TexCoords))
	closeButton.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")

	closeButton:SetScript("OnClick", CloseAllBags)
	closeButton.title = CLOSE
	K.AddTooltip(closeButton, "ANCHOR_TOP")

	return closeButton
end

function Module:CreateRestoreButton(f)
	local restoreButton = CreateFrame("Button", nil, self)
	restoreButton:SetSize(18, 18)
	restoreButton:SkinButton()
	restoreButton:CreateInnerShadow()

	restoreButton.Icon = restoreButton:CreateTexture(nil, "ARTWORK")
	restoreButton.Icon:SetAllPoints()
	restoreButton.Icon:SetTexCoord(unpack(K.TexCoords))
	restoreButton.Icon:SetAtlas("transmog-icon-revert")

	restoreButton:SetScript("OnClick", function()
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][f.main:GetName()] = nil
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][f.bank:GetName()] = nil
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][f.reagent:GetName()] = nil
		f.main:ClearAllPoints()
		f.main:SetPoint("BOTTOMRIGHT", -50, 320)
		f.bank:ClearAllPoints()
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		f.reagent:ClearAllPoints()
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	end)
	restoreButton.title = RESET
	K.AddTooltip(restoreButton, "ANCHOR_TOP")

	return restoreButton
end

function Module:CreateReagentButton(f)
	local reagentButton = CreateFrame("Button", nil, self)
	reagentButton:SetSize(18, 18)
	reagentButton:SkinButton()
	reagentButton:CreateInnerShadow()

	reagentButton.Icon = reagentButton:CreateTexture(nil, "ARTWORK")
	reagentButton.Icon:SetAllPoints()
	reagentButton.Icon:SetTexCoord(unpack(K.TexCoords))
	reagentButton.Icon:SetTexture("Interface\\ICONS\\INV_Enchant_DustArcane")

	reagentButton:RegisterForClicks("AnyUp")
	reagentButton:SetScript("OnClick", function(_, btn)
		if not IsReagentBankUnlocked() then
			StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB")
		else
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
			ReagentBankFrame:Show()
			BankFrame.selectedTab = 2
			f.reagent:Show()
			f.bank:Hide()

			if btn == "RightButton" then
				DepositReagentBank()
			end
		end
	end)
	reagentButton.title = REAGENT_BANK
	K.AddTooltip(reagentButton, "ANCHOR_TOP")

	return reagentButton
end

function Module:CreateBankButton(f)
	local BankButton = CreateFrame("Button", nil, self)
	BankButton:SetSize(18, 18)
	BankButton:SkinButton()
	BankButton:CreateInnerShadow()

	BankButton.Icon = BankButton:CreateTexture(nil, "ARTWORK")
	BankButton.Icon:SetAllPoints()
	BankButton.Icon:SetTexCoord(unpack(K.TexCoords))
	BankButton.Icon:SetAtlas("Banker")

	BankButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
		ReagentBankFrame:Hide()
		BankFrame.selectedTab = 1
		f.reagent:Hide()
		f.bank:Show()
	end)

	BankButton.title = BANK
	K.AddTooltip(BankButton, "ANCHOR_TOP")

	return BankButton
end

function Module:CreateDepositButton()
	local DepositButton = CreateFrame("Button", nil, self)
	DepositButton:SetSize(18, 18)
	DepositButton:SkinButton()
	DepositButton:CreateInnerShadow()

	DepositButton.Icon = DepositButton:CreateTexture(nil, "ARTWORK")
	DepositButton.Icon:SetAllPoints()
	DepositButton.Icon:SetTexCoord(unpack(K.TexCoords))
	DepositButton.Icon:SetTexture("Interface\\ICONS\\misc_arrowdown")

	DepositButton:SetScript("OnClick", DepositReagentBank)

	DepositButton.title = REAGENTBANK_DEPOSIT
	K.AddTooltip(DepositButton, "ANCHOR_TOP")

	return DepositButton
end

function Module:CreateBagToggle()
	local bagToggleButton = CreateFrame("Button", nil, self)
	bagToggleButton:SetSize(18, 18)
	bagToggleButton:SkinButton()
	bagToggleButton:CreateInnerShadow()

	bagToggleButton.Icon = bagToggleButton:CreateTexture(nil, "ARTWORK")
	bagToggleButton.Icon:SetAllPoints()
	bagToggleButton.Icon:SetTexCoord(unpack(K.TexCoords))
	bagToggleButton.Icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")

	bagToggleButton:SetScript("OnClick", function()
		ToggleFrame(self.BagBar)
		if self.BagBar:IsShown() then
			bagToggleButton:SetBackdropBorderColor(1, .8, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		else
			bagToggleButton:SetBackdropBorderColor()
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		end
	end)
	bagToggleButton.title = BACKPACK_TOOLTIP
	K.AddTooltip(bagToggleButton, "ANCHOR_TOP")

	return bagToggleButton
end

function Module:CreateSortButton(name)
	local sortButton = CreateFrame("Button", nil, self)
	sortButton:SetSize(18, 18)
	sortButton:SkinButton()
	sortButton:CreateInnerShadow()

	sortButton.Icon = sortButton:CreateTexture(nil, "ARTWORK")
	sortButton.Icon:SetAllPoints()
	sortButton.Icon:SetTexCoord(unpack(K.TexCoords))
	sortButton.Icon:SetTexture("Interface\\Icons\\INV_Pet_Broom")

	sortButton:SetScript("OnClick", function()
		if name == "Bank" then
			SortBankBags()
		elseif name == "Reagent" then
			SortReagentBankBags()
		else
			if C["Inventory"].ReverseSort then
				if InCombatLockdown() then
					UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
				else
					SortBags()
					table_wipe(sortCache)
					KKUI_Backpack.isSorting = true
					C_Timer_After(.5, Module.ReverseSort)
				end
			else
				SortBags()
			end
		end
	end)
	sortButton.title = "Sort"
	K.AddTooltip(sortButton, "ANCHOR_TOP")

	return sortButton
end

function Module:CreateDeleteButton()
	local enabledText = K.SystemColor..L["Delete Mode Enabled"]

	local deleteButton = CreateFrame("Button", nil, self)
	deleteButton:SetSize(18, 18)
	deleteButton:SkinButton()
	deleteButton:CreateInnerShadow()

	deleteButton.Icon = deleteButton:CreateTexture(nil, "ARTWORK")
	deleteButton.Icon:SetPoint("TOPLEFT", 3, -2)
	deleteButton.Icon:SetPoint("BOTTOMRIGHT", -1, 2)
	deleteButton.Icon:SetTexCoord(unpack(K.TexCoords))
	deleteButton.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

	deleteButton:SetScript("OnClick", function(self)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self:SetBackdropBorderColor(1, .8, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			self:SetBackdropBorderColor()
			self.Icon:SetDesaturated(false)
			self.text = nil
		end
		self:GetScript("OnEnter")(self)
	end)
	deleteButton.title = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t"..L["Item Delete Mode"]
	K.AddTooltip(deleteButton, "ANCHOR_TOP")

	return deleteButton
end

local function deleteButtonOnClick(self)
	if not deleteEnable then
		return
	end

	local texture, _, _, quality = GetContainerItemInfo(self.bagID, self.slotID)
	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < LE_ITEM_QUALITY_RARE) then
		PickupContainerItem(self.bagID, self.slotID)
		DeleteCursorItem()
	end
end

function Module:CreateFavouriteButton()
	local enabledText = K.SystemColor..L["Favourite Mode Enabled"]

	local favouriteButton = CreateFrame("Button", nil, self)
	favouriteButton:SetSize(18, 18)
	favouriteButton:SkinButton()
	favouriteButton:CreateInnerShadow()

	favouriteButton.Icon = favouriteButton:CreateTexture(nil, "ARTWORK")
	favouriteButton.Icon:SetAllPoints()
	favouriteButton.Icon:SetTexCoord(unpack(K.TexCoords))
	favouriteButton.Icon:SetTexture("Interface\\ICONS\\Ability_DeathKnight_HeartstopAura")

	favouriteButton:SetScript("OnClick", function(self)
		favouriteEnable = not favouriteEnable
		if favouriteEnable then
			self:SetBackdropBorderColor(1, .8, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			self:SetBackdropBorderColor()
			self.Icon:SetDesaturated(false)
			self.text = nil
		end
		self:GetScript("OnEnter")(self)
	end)
	favouriteButton.title = L["Favourite Mode"]
	K.AddTooltip(favouriteButton, "ANCHOR_TOP")

	return favouriteButton
end

local function favouriteOnClick(self)
	if not favouriteEnable then
		return
	end

	local texture, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and quality > LE_ITEM_QUALITY_POOR then
		if KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] then
			KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] = nil
		else
			KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] = true
		end
		ClearCursor()
		KKUI_Backpack:BAG_UPDATE()
	end
end

function Module:ButtonOnClick(btn)
	if btn ~= "LeftButton" then
		return
	end

	deleteButtonOnClick(self)
	favouriteOnClick(self)
end

function Module:GetContainerEmptySlot(bagID)
	for slotID = 1, GetContainerNumSlots(bagID) do
		if not GetContainerItemID(bagID, slotID) then
			return slotID
		end
	end
end

function Module:GetEmptySlot(name)
	if name == "Main" then
		for bagID = 0, 4 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Bank" then
		local slotID = Module:GetContainerEmptySlot(-1)
		if slotID then
			return -1, slotID
		end

		for bagID = 5, 11 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Reagent" then
		local slotID = Module:GetContainerEmptySlot(-3)
		if slotID then
			return -3, slotID
		end
	end
end

function Module:FreeSlotOnDrop()
	local bagID, slotID = Module:GetEmptySlot(self.__name)
	if slotID then
		PickupContainerItem(bagID, slotID)
	end
end

local freeSlotContainer = {
	["Main"] = true,
	["Bank"] = true,
	["Reagent"] = true,
}

function Module:CreateFreeSlots()
	local name = self.name
	if not freeSlotContainer[name] then
		return
	end

	local slot = CreateFrame("Button", name.."FreeSlot", self)
	slot:SetSize(self.iconSize, self.iconSize)
	slot:CreateBorder()
	slot:CreateInnerShadow()
	slot:SetScript("OnMouseUp", Module.FreeSlotOnDrop)
	slot:SetScript("OnReceiveDrag", Module.FreeSlotOnDrop)
	K.AddTooltip(slot, "ANCHOR_RIGHT", "FreeSlots")
	slot.__name = name

	local tag = self:SpawnPlugin("TagDisplay", "[space]", slot)
	tag:SetFontObject(bagsFont)
	tag:SetFont(select(1, tag:GetFont()), 16, select(3, tag:GetFont()))
	tag:SetPoint("CENTER", 1, 0)
	tag.__name = name

	self.freeSlot = slot
end

function Module:OnEnable()
	if not C["Inventory"].Enable then
		return
	end

	-- Settings
	local bagsWidth = C["Inventory"].BagsWidth
	local bankWidth = C["Inventory"].BankWidth
	local iconSize = C["Inventory"].IconSize
	local showItemLevel = C["Inventory"].BagsiLvl
	local deleteButton = C["Inventory"].DeleteButton
	local itemSetFilter = C["Inventory"].ItemSetFilter
	local showNewItem = C["Inventory"].ShowNewItem

	-- Init
	local Backpack = cargBags:NewImplementation("KKUI_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:SetScale(1)

	Backpack:HookScript("OnShow", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	end)

	Backpack:HookScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end)

	local f = {}
	Module.SpecialBags = {}
	local onlyBags, bagAzeriteItem, bagEquipment, bagConsumble, bagTradeGoods, bagQuestItem, bagsJunk, onlyBank, bankAzeriteItem, bankLegendary, bankEquipment, bankConsumble, onlyReagent, bagMountPet, bankMountPet, bagFavourite, bankFavourite = self:GetFilters()

	function Backpack:OnInit()
		local MyContainer = self:GetContainerClass()

		f.main = MyContainer:New("Main", {Columns = bagsWidth, Bags = "bags"})
		f.main:SetFilter(onlyBags, true)
		f.main:SetPoint("BOTTOMRIGHT", -50, 320)

		f.junk = MyContainer:New("Junk", {Columns = bagsWidth, Parent = f.main})
		f.junk:SetFilter(bagsJunk, true)

		f.bagFavourite = MyContainer:New("BagFavourite", {Columns = bagsWidth, Parent = f.main})
		f.bagFavourite:SetFilter(bagFavourite, true)

		f.azeriteItem = MyContainer:New("AzeriteItem", {Columns = bagsWidth, Parent = f.main})
		f.azeriteItem:SetFilter(bagAzeriteItem, true)

		f.equipment = MyContainer:New("Equipment", {Columns = bagsWidth, Parent = f.main})
		f.equipment:SetFilter(bagEquipment, true)

		f.consumble = MyContainer:New("Consumble", {Columns = bagsWidth, Parent = f.main})
		f.consumble:SetFilter(bagConsumble, true)

		f.bagCompanion = MyContainer:New("BagCompanion", {Columns = bagsWidth, Parent = f.main})
		f.bagCompanion:SetFilter(bagMountPet, true)

		f.tradegoods = MyContainer:New("TradeGoods", {Columns = bagsWidth, Parent = f.main})
		f.tradegoods:SetFilter(bagTradeGoods, true)

		f.questitem = MyContainer:New("QuestItem", {Columns = bagsWidth, Parent = f.main})
		f.questitem:SetFilter(bagQuestItem, true)

		f.bank = MyContainer:New("Bank", {Columns = bankWidth, Bags = "bank"})
		f.bank:SetFilter(onlyBank, true)
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		f.bank:Hide()

		f.bankFavourite = MyContainer:New("BankFavourite", {Columns = bankWidth, Parent = f.bank})
		f.bankFavourite:SetFilter(bankFavourite, true)

		f.bankAzeriteItem = MyContainer:New("BankAzeriteItem", {Columns = bankWidth, Parent = f.bank})
		f.bankAzeriteItem:SetFilter(bankAzeriteItem, true)

		f.bankLegendary = MyContainer:New("BankLegendary", {Columns = bankWidth, Parent = f.bank})
		f.bankLegendary:SetFilter(bankLegendary, true)

		f.bankEquipment = MyContainer:New("BankEquipment", {Columns = bankWidth, Parent = f.bank})
		f.bankEquipment:SetFilter(bankEquipment, true)

		f.bankConsumble = MyContainer:New("BankConsumble", {Columns = bankWidth, Parent = f.bank})
		f.bankConsumble:SetFilter(bankConsumble, true)

		f.bankCompanion = MyContainer:New("BankCompanion", {Columns = bankWidth, Parent = f.bank})
		f.bankCompanion:SetFilter(bankMountPet, true)

		f.reagent = MyContainer:New("Reagent", {Columns = bankWidth})
		f.reagent:SetFilter(onlyReagent, true)
		f.reagent:SetPoint("BOTTOMLEFT", f.bank)
		f.reagent:Hide()
	end

	function Backpack:OnBankOpened()
		BankFrame:Show()
		self:GetContainer("Bank"):Show()
	end

	function Backpack:OnBankClosed()
		BankFrame.selectedTab = 1
		BankFrame:Hide()
		self:GetContainer("Bank"):Hide()
		self:GetContainer("Reagent"):Hide()
		ReagentBankFrame:Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))
		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFontObject(bagsFont)

		self:CreateBorder()
		self:CreateInnerShadow()

		self.junkIcon = self:CreateTexture(nil, "ARTWORK")
		self.junkIcon:SetAtlas("bags-junkcoin")
		self.junkIcon:SetSize(20, 20)
		self.junkIcon:SetPoint("TOPRIGHT", 1, 0)

		self.Quest = self:CreateTexture(nil, "ARTWORK")
		self.Quest:SetSize(26, 26)
		self.Quest:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
		self.Quest:ClearAllPoints()
		self.Quest:SetPoint("LEFT", self, "LEFT", 0, 1)

		self.Azerite = self:CreateTexture(nil, "ARTWORK", nil, 1)
		self.Azerite:SetAtlas("AzeriteIconFrame")
		self.Azerite:SetAllPoints()

		self.Favourite = self:CreateTexture(nil, "OVERLAY", nil, 2)
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(24, 24)
		self.Favourite:SetPoint("TOPLEFT", -12, 9)

		if showItemLevel then
			self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 1)
			self.iLvl:SetFontObject(bagsFont)
			self.iLvl:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))
		end

		if showNewItem then
			self.glowFrame = self:CreateTexture(nil, "OVERLAY")
			self.glowFrame:SetInside(self, 0, 0)
			self.glowFrame:SetAtlas("bags-glow-white")

			self.glowFrame.Animation = self.glowFrame:CreateAnimationGroup()
			self.glowFrame.Animation:SetLooping("BOUNCE")

			self.glowFrame.Animation.FadeOut = self.glowFrame.Animation:CreateAnimation("Alpha")
			self.glowFrame.Animation.FadeOut:SetFromAlpha(1)
			self.glowFrame.Animation.FadeOut:SetToAlpha(0.3)
			self.glowFrame.Animation.FadeOut:SetDuration(0.6)
			self.glowFrame.Animation.FadeOut:SetSmoothing("IN_OUT")

			self:HookScript("OnHide", function()
				if self.glowFrame and self.glowFrame.Animation:IsPlaying() then
					self.glowFrame.Animation:Stop()
					self.glowFrame.Animation.Playing = false
					self.glowFrame:Hide()
				end
			end)
		end

		self:HookScript("OnClick", Module.ButtonOnClick)
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame and self.glowFrame.Animation then
			self.glowFrame.Animation:Stop()
			self.glowFrame.Animation.Playing = false
			self.glowFrame:Hide()
			-- Clear things on blizzard side too.
			C_NewItems_RemoveNewItem(self.bagID, self.slotID)
		end
	end

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() then
			if item.isInSet then
				self:SetAlpha(.5)
			else
				self:SetAlpha(1)
			end
		end

		if MerchantFrame:IsShown() and item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0 then
			self.junkIcon:SetAlpha(1)
		else
			self.junkIcon:SetAlpha(0)
		end

		if self.UpgradeIcon then
			local itemIsUpgrade = _G.IsContainerItemAnUpgrade(self:GetParent():GetID(), self:GetID())
			if not itemIsUpgrade or itemIsUpgrade == nil then
				self.UpgradeIcon:SetShown(false)
			else
				self.UpgradeIcon:SetShown(itemIsUpgrade or true)
			end
		end

		if IsAddOnLoaded("CanIMogIt") then
			CIMI_AddToFrame(self, ContainerFrameItemButton_CIMIUpdateIcon)
			ContainerFrameItemButton_CIMIUpdateIcon(self.CanIMogItOverlay)
		end

		if item.link and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(item.link) then
			self.Azerite:SetAlpha(1)
		else
			self.Azerite:SetAlpha(0)
		end

		if KkthnxUIData[K.Realm][K.Name].FavouriteItems[item.id] then
			self.Favourite:SetAlpha(1)
		else
			self.Favourite:SetAlpha(0)
		end

		if showItemLevel then
			if item.link and item.level and item.rarity > 1 and (item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR) then
				local level = K.GetItemLevel(item.link, item.bagID, item.slotID) or item.level
				local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			else
				self.iLvl:SetText("")
			end
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagID, item.slotID) and self.glowFrame and self.glowFrame.Animation then
				self.glowFrame:Show()
				self.glowFrame.Animation:Play()
				self.glowFrame.Animation.Playing = true
			else
				self.glowFrame.Animation:Stop()
				self.glowFrame.Animation.Playing = false
				self.glowFrame:Hide()
			end
		end
	end

	function MyButton:OnUpdateQuest(item)
		if item.questID and not item.questActive then
			self.Quest:SetAlpha(1)
		else
			self.Quest:SetAlpha(0)
		end

		if item.questID or item.isQuestItem then
			self:SetBackdropBorderColor(1, 0.30, 0.30)
		elseif item.rarity and item.rarity > -1 then
			local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
			self:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor()
		end
	end

	local MyContainer = Backpack:GetContainerClass()
	function MyContainer:OnContentsChanged()
		self:SortButtons("bagSlot")

		local columns = self.Settings.Columns
		local offset = 38
		local spacing = 5
		local xOffset = 5
		local yOffset = -offset + spacing
		local _, height = self:LayoutButtons("grid", columns, spacing, xOffset, yOffset)
		local width = columns * (iconSize+spacing) - spacing
		if self.freeSlot then
			if C["Inventory"].GatherEmpty then
				local numSlots = #self.buttons + 1
				local row = ceil(numSlots / columns)
				local col = numSlots % columns
				if col == 0 then
					col = columns
				end

				local xPos = (col-1) * (iconSize + spacing)
				local yPos = -1 * (row-1) * (iconSize + spacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos+xOffset, yPos+yOffset)
				self.freeSlot:Show()

				if height < 0 then
					height = iconSize
				elseif col == 1 then
					height = height + iconSize + spacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(width + xOffset * 2, height + offset)

		Module:UpdateAnchors(f.main, {f.azeriteItem, f.equipment, f.bagCompanion, f.consumble, f.bagFavourite, f.tradegoods, f.questitem, f.junk})
		Module:UpdateAnchors(f.bank, {f.bankAzeriteItem, f.bankEquipment, f.bankLegendary, f.bankCompanion, f.bankConsumble, f.bankFavourite})
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetParent(settings.Parent or Backpack)
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:CreateBorder()
		K.CreateMoverFrame(self, settings.Parent, true)

		local label
		if string_match(name, "AzeriteItem$") then
			label = "Azerite Armor"
		elseif string_match(name, "Equipment$") then
			if itemSetFilter then
				label = "Equipement Set"
			else
				label = BAG_FILTER_EQUIPMENT
			end
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif string_match(name, "Consumble$") then
			label = BAG_FILTER_CONSUMABLES
		elseif string_match(name, "TradeGoods$") then
			label = BAG_FILTER_TRADE_GOODS
		elseif string_match(name, "QuestItem$") then
			label = AUCTION_CATEGORY_QUEST_ITEMS
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif string_match(name, "Companion") then
			label = MOUNTS_AND_PETS
		elseif string_match(name, "Favourite") then
			label = PREFERENCES
		end

		if label then
			K.CreateFontString(self, 13, label, "OUTLINE", true, "TOPLEFT", 5, -8)
			-- self:SetFontObject(bagsFont)
			-- self:SetFont(select(1, self:GetFont()), 18, select(3, self:GetFont()))
			return
		end

		Module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = Module.CreateCloseButton(self)
		if name == "Main" then
			Module.CreateBagBar(self, settings, 4)
			buttons[2] = Module.CreateRestoreButton(self, f)
			buttons[3] = Module.CreateBagToggle(self)
			buttons[5] = Module.CreateFavouriteButton(self)
			if deleteButton then
				buttons[6] = Module.CreateDeleteButton(self)
			end
		elseif name == "Bank" then
			Module.CreateBagBar(self, settings, 7)
			buttons[2] = Module.CreateReagentButton(self, f)
			buttons[3] = Module.CreateBagToggle(self)
		elseif name == "Reagent" then
			buttons[2] = Module.CreateBankButton(self, f)
			buttons[3] = Module.CreateDepositButton(self)
		end
		buttons[4] = Module.CreateSortButton(self, name)

		for i = 1, 6 do
			local bu = buttons[i]
			if not bu then break end
			if i == 1 then
				bu:SetPoint("TOPRIGHT", -6, -6)
			else
				bu:SetPoint("RIGHT", buttons[i-1], "LEFT", -5, 0)
			end
		end

		self:HookScript("OnShow", K.RestoreMoverFrame)

		self.iconSize = iconSize
		Module.CreateFreeSlots(self)
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)

		self:SetSize(iconSize, iconSize)
		self:CreateBorder()
		self:CreateInnerShadow()

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))
	end

	function BagButton:OnUpdate()
		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		local quality = id and select(3, GetItemInfo(id)) or 0
		if quality == 1 then
			quality = 0
		end

		local color = BAG_ITEM_QUALITY_COLORS[quality]
		if not self.hidden and not self.notBought then
			self:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor()
		end

		local bagFamily = select(2, GetContainerNumFreeSlots(self.bagID))
		if bagFamily then
			Module.SpecialBags[self.bagID] = bagFamily ~= 0
		end
	end

	-- Fixes
	ToggleAllBags()
	ToggleAllBags()
	Module.initComplete = true

	BankFrame.GetRight = function()
		return f.bank:GetRight()
	end
	BankFrameItemButton_Update = K.Noop

	-- Sort order
	SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
	SetInsertItemsLeftToRight(false)
end