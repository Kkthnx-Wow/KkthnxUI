--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: cargBags implementation bootstrap (containers, slots, hooks).
-- - Design: One-shot InitBags; conflict-addon guard; Blizzard bank shims.
-- - Events: TRADE_SHOW, TRADE_CLOSED, GET_ITEM_INFO_RECEIVED (registered at end).
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Bags")

local _G = _G
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = _G.C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID
local C_Bank_CanPurchaseBankTab = _G.C_Bank.CanPurchaseBankTab
local C_Container_GetContainerItemInfo = _G.C_Container.GetContainerItemInfo
local C_Container_SetInsertItemsLeftToRight = _G.C_Container.SetInsertItemsLeftToRight
local C_Container_SetSortBagsRightToLeft = _G.C_Container.SetSortBagsRightToLeft
local C_Item_GetItemInfo = _G.C_Item.GetItemInfo
local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = _G.C_NewItems.RemoveNewItem
local C_Soulbinds_IsItemConduitByItemInfo = _G.C_Soulbinds.IsItemConduitByItemInfo
local C_Spell_GetSpellName = _G.C_Spell.GetSpellName
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetContainerItemID = _G.C_Container.GetContainerItemID
local GetContainerNumSlots = _G.C_Container.GetContainerNumSlots
local GetInventoryItemID = _G.GetInventoryItemID
local IsCosmeticItem = _G.C_Item.IsCosmeticItem
local PlaySound = _G.PlaySound
local SetCVar = _G.SetCVar
local SetCVarBitfield = _G.SetCVarBitfield
local SetItemCraftingQualityOverlay = _G.SetItemCraftingQualityOverlay
local hooksecurefunc = _G.hooksecurefunc
local ipairs = _G.ipairs
local math_ceil = _G.math.ceil
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format
local string_match = _G.string.match
local table_insert = _G.table.insert
local unpack = _G.unpack

local cargBags = K.cargBags
local Unfit = K.LibUnfit

local ACCOUNT_BANK_TYPE = _G.Enum.BankType.Account or 2
local CHAR_BANK_TYPE = _G.Enum.BankType.Character or 0
function Module:InitBags()
	if Module.initComplete then
		return
	end

	if not C["Inventory"].Enable then
		return
	end

	-- REASON: Inventory management is a core system frequently replaced by specialized addons.
	-- To prevent conflicting logic, taint, or UI overlap, we gracefully disable the module
	-- if any well-known alternative is detected.
	local conflictAddons = { "AdiBags", "ArkInventory", "cargBags_Nivaya", "cargBags", "Bagnon", "Combuctor", "TBag", "BaudBag" }
	for _, addon in ipairs(conflictAddons) do
		if _G.C_AddOns.IsAddOnLoaded(addon) then
			Module.initConflict = addon
			return
		end
	end

	local iconSize = C["Inventory"].IconSize
	local isShowItemLevel = C["Inventory"].BagsItemLevel
	local isShowBindOnEquip = C["Inventory"].BagsBindOnEquip
	local isShowNewItem = C["Inventory"].ShowNewItem
	local hasCanIMogIt = _G.C_AddOns.IsAddOnLoaded("CanIMogIt")

	-- ---------------------------------------------------------------------------
	-- cargBags Implementation
	-- ---------------------------------------------------------------------------
	local Backpack = cargBags:NewImplementation("KKUI_Backpack")
	Backpack:RegisterBlizzard()

	Backpack:HookScript("OnShow", function()
		PlaySound(_G.SOUNDKIT.IG_BACKPACK_OPEN)
	end)

	Backpack:HookScript("OnHide", function()
		PlaySound(_G.SOUNDKIT.IG_BACKPACK_CLOSE)
	end)

	Module.Bags = Backpack
	Module.BagsType = { [0] = 0 }

	local bagFrames = {}
	local filters = Module:GetFilters()
	local MyContainer = Backpack:GetContainerClass()
	Module.ContainerGroups = { ["Bag"] = {}, ["Bank"] = {}, ["Account"] = {} }

	local function addNewContainer(bagType, index, name, filter)
		local container = MyContainer:New(name, { BagType = bagType, Index = index })
		container:SetFilter(filter, true)
		Module.ContainerGroups[bagType][index] = container
	end

	function Backpack:OnInit()
		for i = 1, 5 do
			addNewContainer("Bag", i, "BagCustom" .. i, filters["bagCustom" .. i])
		end
		-- Recent first after customs — stacks directly above the main bag when it has loot.
		addNewContainer("Bag", 6, "BagRecent", filters.bagRecent)
		addNewContainer("Bag", 7, "BagReagent", filters.onlyBagReagent)
		addNewContainer("Bag", 21, "Junk", filters.bagsJunk)
		addNewContainer("Bag", 10, "EquipSet", filters.bagEquipSet)
		addNewContainer("Bag", 11, "BagAOE", filters.bagAOE)
		addNewContainer("Bag", 8, "AzeriteItem", filters.bagAzeriteItem)
		addNewContainer("Bag", 18, "BagLegacy", filters.bagLegacy)
		addNewContainer("Bag", 20, "BagLower", filters.bagLower)
		addNewContainer("Bag", 9, "Equipment", filters.bagEquipment)
		addNewContainer("Bag", 12, "BagCollection", filters.bagCollection)
		addNewContainer("Bag", 15, "BagStone", filters.bagStone)
		addNewContainer("Bag", 19, "BagKeystone", filters.bagKeystone)
		addNewContainer("Bag", 16, "Consumable", filters.bagConsumable)
		addNewContainer("Bag", 13, "BagGoods", filters.bagGoods)
		addNewContainer("Bag", 17, "BagQuest", filters.bagQuest)
		addNewContainer("Bag", 14, "BagAnima", filters.bagAnima)
		addNewContainer("Bag", 22, "BagDecor", filters.bagDecor)

		bagFrames.main = MyContainer:New("Bag", { Bags = "bags", BagType = "Bag" })
		bagFrames.main.__anchor = { "BOTTOMRIGHT", -50, 100 }
		bagFrames.main:SetPoint(unpack(bagFrames.main.__anchor))
		bagFrames.main:SetFilter(filters.onlyBags, true)

		for i = 1, 5 do
			addNewContainer("Bank", i, "BankCustom" .. i, filters["bankCustom" .. i])
		end
		addNewContainer("Bank", 8, "BankEquipSet", filters.bankEquipSet)
		addNewContainer("Bank", 9, "BankAOE", filters.bankAOE)
		addNewContainer("Bank", 6, "BankAzeriteItem", filters.bankAzeriteItem)
		addNewContainer("Bank", 10, "BankLegendary", filters.bankLegendary)
		addNewContainer("Bank", 16, "BankLegacy", filters.bankLegacy)
		addNewContainer("Bank", 17, "BankLower", filters.bankLower)
		addNewContainer("Bank", 7, "BankEquipment", filters.bankEquipment)
		addNewContainer("Bank", 11, "BankCollection", filters.bankCollection)
		addNewContainer("Bank", 14, "BankConsumable", filters.bankConsumable)
		addNewContainer("Bank", 12, "BankGoods", filters.bankGoods)
		addNewContainer("Bank", 15, "BankQuest", filters.bankQuest)
		addNewContainer("Bank", 13, "BankAnima", filters.bankAnima)
		addNewContainer("Bank", 18, "BankDecor", filters.bankDecor)

		bagFrames.bank = MyContainer:New("Bank", { Bags = "bank", BagType = "Bank" })
		bagFrames.bank.__anchor = { "BOTTOMLEFT", 25, 50 }
		bagFrames.bank:SetPoint(unpack(bagFrames.bank.__anchor))
		bagFrames.bank:SetFilter(filters.onlyBank, true)
		bagFrames.bank:Hide()

		for i = 1, 5 do
			addNewContainer("Account", i, "AccountCustom" .. i, filters["accountCustom" .. i])
		end
		addNewContainer("Account", 8, "AccountAOE", filters.accountAOE)
		addNewContainer("Account", 7, "AccountLegacy", filters.accountLegacy)
		addNewContainer("Account", 6, "AccountEquipment", filters.accountEquipment)
		addNewContainer("Account", 10, "AccountConsumable", filters.accountConsumable)
		addNewContainer("Account", 9, "AccountGoods", filters.accountGoods)

		bagFrames.accountbank = MyContainer:New("Account", { Bags = "accountbank", BagType = "Account" })
		bagFrames.accountbank:SetFilter(filters.accountbank, true)
		bagFrames.accountbank:SetPoint(unpack(bagFrames.bank.__anchor))
		bagFrames.accountbank:Hide()

		Module.BagFrames = bagFrames

		for bagType, groups in pairs(Module.ContainerGroups) do
			for _, container in ipairs(groups) do
				local parent = Backpack.contByName[bagType]
				container:SetParent(parent)
				K.CreateMoverFrame(container, parent, true)
			end
		end
	end

	local isBagTypeInitialized = false
	function Backpack:OnBankOpened()
		_G.BankFrame:Show()
		self:GetContainer("Bank"):Show()

		if not isBagTypeInitialized then
			Module:UpdateAllBags()
			Module:UpdateBagSize()
			isBagTypeInitialized = true
		end
	end

	function Backpack:OnBankClosed()
		_G.BankFrame.selectedTab = 1
		_G.BankFrame.activeTabIndex = 1
		self:GetContainer("Bank"):Hide()
		self:GetContainer("Account"):Hide()
	end

	-- ---------------------------------------------------------------------------
	-- Button Decoration
	-- ---------------------------------------------------------------------------
	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(0)
		self:SetPushedTexture(0)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))

		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFontObject(K.UIFontOutline)

		self.Cooldown:SetPoint("TOPLEFT", 1, -1)
		self.Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

		self.IconOverlay:SetPoint("TOPLEFT", 1, -1)
		self.IconOverlay:SetPoint("BOTTOMRIGHT", -1, 1)

		self.IconOverlay2:SetPoint("TOPLEFT", 1, -1)
		self.IconOverlay2:SetPoint("BOTTOMRIGHT", -1, 1)

		self:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, { 1, 1, 1 })
		self:StyleButton()

		local overlayFrame = CreateFrame("Frame", nil, self)
		overlayFrame:SetAllPoints()
		overlayFrame:SetFrameLevel(12)

		self.Favourite = overlayFrame:CreateTexture(nil, "OVERLAY")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(28, 28)
		self.Favourite:SetPoint("TOPRIGHT", 4, 3)

		self.QuestTag = overlayFrame:CreateTexture(nil, "OVERLAY")
		self.QuestTag:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
		self.QuestTag:SetSize(26, 26)
		self.QuestTag:SetPoint("LEFT", 0, 1)

		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 0)
		self.bindType = K.CreateFontString(self, 12, "", "OUTLINE", false, "TOPLEFT", 1, -2)

		if isShowNewItem and not self.glowFrame then
			self.glowFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
			self.glowFrame:SetFrameLevel(self:GetFrameLevel() + 2)
			self.glowFrame:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16 })
			self.glowFrame:SetBackdropBorderColor(1, 223 / 255, 0, 1)
			self.glowFrame:SetPoint("TOPLEFT", self, -6, 6)
			self.glowFrame:SetPoint("BOTTOMRIGHT", self, 6, -6)

			self.glowFrame.Animation = self.glowFrame.Animation or self.glowFrame:CreateAnimationGroup()
			self.glowFrame.Animation:SetLooping("BOUNCE")

			self.glowFrame.Animation.FadeOut = self.glowFrame.Animation.FadeOut or self.glowFrame.Animation:CreateAnimation("Alpha")
			self.glowFrame.Animation.FadeOut:SetFromAlpha(1)
			self.glowFrame.Animation.FadeOut:SetToAlpha(0.1)
			self.glowFrame.Animation.FadeOut:SetDuration(0.6)
			self.glowFrame.Animation.FadeOut:SetSmoothing("IN_OUT")
		end

		self:HookScript("OnClick", Module.ButtonOnClick)

		if hasCanIMogIt then
			self.canIMogIt = overlayFrame:CreateTexture(nil, "OVERLAY")
			self.canIMogIt:SetSize(iconSize / 2.6, iconSize / 2.6)
			self.canIMogIt:SetPoint(unpack(_G.CanIMogIt.ICON_LOCATIONS[_G.CanIMogItOptions["iconLocation"]]))
		end

		if not self.ProfessionQualityOverlay then
			self.ProfessionQualityOverlay = overlayFrame:CreateTexture(nil, "OVERLAY")
			self.ProfessionQualityOverlay:SetPoint("TOPLEFT", -3, 2)
		end
	end

	function MyButton:ItemOnEnter()
		-- Hover clears "new" so glow dies and the slot can leave Recent on next refresh.
		if self.bagId and self.slotId and Module.ClearRecentItem and Module:IsRecentItem(self.bagId, self.slotId) then
			Module:ClearRecentItem(self.bagId, self.slotId)
			if Module.Bags then
				Module.Bags:BAG_UPDATE(self.bagId, self.slotId)
			end
		end

		if self.glowFrame then
			if self.glowFrame.Animation then
				self.glowFrame.Animation:Stop()
			end
			self.glowFrame:Hide()
		end
	end

	local BAG_TYPE_COLOR = {
		[0] = { 1, 1, 1, 0.3 }, -- Container
		[1] = false, -- Soul Bag
		[2] = { 0, 0.5, 0, 0.25 }, -- Herb Bag
		[3] = { 0.8, 0, 0.8, 0.25 }, -- Enchanting Bag
		[4] = { 1, 0.8, 0, 0.25 }, -- Engineering Bag
		[5] = { 0, 0.8, 0.8, 0.25 }, -- Gem Bag
		[6] = { 0.5, 0.4, 0, 0.25 }, -- Mining Bag
		[7] = { 0.8, 0.5, 0.5, 0.25 }, -- Leatherworking Bag
		[8] = { 0.8, 0.8, 0.8, 0.25 }, -- Inscription Bag
		[9] = { 0.4, 0.6, 1, 0.25 }, -- Toolbox
		[10] = { 0.8, 0, 0, 0.25 }, -- Cooking Bag
		[11] = { 0.2, 0.8, 0.2, 0.25 }, -- Material Bag
	}

	local function isItemNeedsLevel(item)
		return item.link and item.quality > 1 and item.ilvl
	end

	local function getIconOverlayAtlas(item)
		if not item.link then
			return
		end

		if C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link) then
			return "AzeriteIconFrame"
		elseif IsCosmeticItem(item.link) then
			return "CosmeticIconFrame"
		elseif C_Soulbinds_IsItemConduitByItemInfo(item.link) then
			return "ConduitIconFrame", "ConduitIconFrame-Corners"
		end
	end

	local function updateCanIMogIt(self, item)
		if not self.canIMogIt then
			return
		end

		local text, unmodifiedText = _G.CanIMogIt:GetTooltipText(nil, item.bagId, item.slotId)
		if text and text ~= "" then
			local icon = _G.CanIMogIt.tooltipOverlayIcons[unmodifiedText]
			self.canIMogIt:SetTexture(icon)
			self.canIMogIt:Show()
		else
			self.canIMogIt:Hide()
		end
	end

	local ITEM_UPGRADE_THROTTLE = 0.5
	local function onUpgradeCheckUpdate(self, elapsed)
		self._timeSinceUpgradeCheck = (self._timeSinceUpgradeCheck or 0) + elapsed
		if self._timeSinceUpgradeCheck >= ITEM_UPGRADE_THROTTLE then
			self._timeSinceUpgradeCheck = 0
			if self._callUpdateUpgradeIcon then
				self:_callUpdateUpgradeIcon()
			end
		end
	end

	local function updateUpgradeArrow(self, item)
		if not self or not self.UpgradeIcon then
			return
		end

		if not C["Inventory"].UpgradeIcon or not item or not item.link or not _G.IsEquippableItem(item.link) then
			self.UpgradeIcon:SetShown(false)
			self:SetScript("OnUpdate", nil)
			return
		end

		local isUpgrade
		local bagID, slotID = item.bagId, item.slotId

		if _G.PawnIsContainerItemAnUpgrade then
			isUpgrade = _G.PawnIsContainerItemAnUpgrade(bagID, slotID)
		end
		if isUpgrade == nil and _G.IsContainerItemAnUpgrade then
			isUpgrade = _G.IsContainerItemAnUpgrade(bagID, slotID)
		end

		self.UpgradeIcon:ClearAllPoints()
		self.UpgradeIcon:SetPoint("TOPRIGHT", 3, 3)

		if isUpgrade == nil then
			self.UpgradeIcon:SetShown(false)
			self._callUpdateUpgradeIcon = function(btn)
				updateUpgradeArrow(btn, btn:GetInfo())
			end
			self:SetScript("OnUpdate", onUpgradeCheckUpdate)
		else
			self.UpgradeIcon:SetShown(isUpgrade)
			self:SetScript("OnUpdate", nil)
		end
	end

	function MyButton:OnUpdateButton(item)
		if self.JunkIcon then
			local charVars = K.GetCharVars()
			if (item.quality == _G.Enum.ItemQuality.Poor or (charVars and charVars.CustomJunkList and charVars.CustomJunkList[item.id])) and item.hasPrice then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		-- REASON: Visual feedback for items that the player cannot use due to level or class restrictions.
		-- We apply a red tint to the icon to match Blizzard's standard unusable item indicator.
		if C["Inventory"].ColorUnusableItems then
			if (Unfit:IsItemUnusable(item.link) or item.minLevel and item.minLevel > K.Level) and not item.locked then
				self.Icon:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			else
				self.Icon:SetVertexColor(1, 1, 1)
			end
		end

		self.IconOverlay:SetVertexColor(1, 1, 1)
		self.IconOverlay:Hide()
		self.IconOverlay2:Hide()

		local atlas, secondAtlas = getIconOverlayAtlas(item)
		if atlas then
			self.IconOverlay:SetAtlas(atlas)
			self.IconOverlay:Show()

			if secondAtlas then
				local qualityColor = K.QualityColors[item.quality or 1]
				self.IconOverlay:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
				self.IconOverlay2:SetAtlas(secondAtlas)
				self.IconOverlay2:Show()
			end
		end

		if self.ProfessionQualityOverlay and SetItemCraftingQualityOverlay then
			self.ProfessionQualityOverlay:SetAtlas(nil)
			SetItemCraftingQualityOverlay(self, item.link)
		end

		local charVars = K.GetCharVars()
		if charVars and charVars.CustomItems and charVars.CustomItems[item.id] and not C["Inventory"].ItemFilter then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		self.iLvl:SetText("")
		if isShowItemLevel then
			local level = item.level -- ilvl for keystone and battlepet
			if not level and isItemNeedsLevel(item) then
				level = item.ilvl
			end

			if level then
				local qualityColor = K.QualityColors[item.quality]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
			end
		end

		self.bindType:SetText("")
		if isShowBindOnEquip then
			local isBoE, isBoU = item.bindType == 2, item.bindType == 3
			if isBoE or isBoU then
				if item.quality > 1 and not item.bound then
					local qualityColor = K.QualityColors[item.quality]
					self.bindType:SetText(isBoE and L["BoE"] or L["BoU"])
					self.bindType:SetTextColor(qualityColor.r, qualityColor.g, qualityColor.b)
				end
			end
		end

		if self.glowFrame then
			local isNew = C["Inventory"].ShowNewItem and Module.IsRecentItem and Module:IsRecentItem(item.bagId, item.slotId)
			if isNew then
				local qualityColor = K.QualityColors[item.quality] or {}
				if item.questID or item.isQuestItem then
					self.glowFrame:SetBackdropBorderColor(1, 0.82, 0.2, 1)
				elseif qualityColor.r and qualityColor.g and qualityColor.b then
					self.glowFrame:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)
				else
					self.glowFrame:SetBackdropBorderColor(1, 223 / 255, 0, 1)
				end
				self.glowFrame:Show()
				self.glowFrame.Animation:Play()
			else
				self.glowFrame:Hide()
				self.glowFrame.Animation:Stop()
			end
		elseif C["Inventory"].ShowNewItem and Module.IsRecentItem and Module:IsRecentItem(item.bagId, item.slotId) then
			-- ShowNewItem was off at OnCreate — build glow once on first new-item paint.
			self.glowFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
			self.glowFrame:SetFrameLevel(self:GetFrameLevel() + 2)
			self.glowFrame:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16 })
			self.glowFrame:SetPoint("TOPLEFT", self, -6, 6)
			self.glowFrame:SetPoint("BOTTOMRIGHT", self, 6, -6)
			self.glowFrame.Animation = self.glowFrame:CreateAnimationGroup()
			self.glowFrame.Animation:SetLooping("BOUNCE")
			self.glowFrame.Animation.FadeOut = self.glowFrame.Animation:CreateAnimation("Alpha")
			self.glowFrame.Animation.FadeOut:SetFromAlpha(1)
			self.glowFrame.Animation.FadeOut:SetToAlpha(0.1)
			self.glowFrame.Animation.FadeOut:SetDuration(0.6)
			self.glowFrame.Animation.FadeOut:SetSmoothing("IN_OUT")
			local qualityColor = K.QualityColors[item.quality] or {}
			if qualityColor.r then
				self.glowFrame:SetBackdropBorderColor(qualityColor.r, qualityColor.g, qualityColor.b, 1)
			else
				self.glowFrame:SetBackdropBorderColor(1, 223 / 255, 0, 1)
			end
			self.glowFrame:Show()
			self.glowFrame.Animation:Play()
		end

		if C["Inventory"].SpecialBagsColor then
			local bagType = Module.BagsType[item.bagId]
			local vertexColor = BAG_TYPE_COLOR[bagType] or BAG_TYPE_COLOR[0]
			self:SetBackdropColor(unpack(vertexColor))
		else
			self:SetBackdropColor(0.04, 0.04, 0.04, 0.9)
		end

		if not item.texture and not GameTooltip:IsForbidden() and GameTooltip:GetOwner() == self then
			GameTooltip:Hide()
		end

		updateCanIMogIt(self, item)
		updateUpgradeArrow(self, item)
	end

	function MyButton:OnUpdateQuest(item)
		if item.questID and not item.questActive then
			self.QuestTag:Show()
		else
			self.QuestTag:Hide()
		end

		if item.questID or item.isQuestItem then
			self.KKUI_Border:SetVertexColor(1, 0.82, 0.2)
		elseif item.quality and item.quality > -1 then
			local qualityColor = K.QualityColors[item.quality]
			self.KKUI_Border:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
		else
			K.SetBorderColor(self.KKUI_Border)
		end
	end

	function Module:UpdateAllAnchors()
		Module:UpdateBagsAnchor(bagFrames.main, Module.ContainerGroups["Bag"])
		Module:UpdateBankAnchor(bagFrames.bank, Module.ContainerGroups["Bank"])
		Module:UpdateBankAnchor(bagFrames.accountbank, Module.ContainerGroups["Account"])
	end

	function Module:GetContainerColumns(bagType)
		if bagType == "Bag" then
			return C["Inventory"].BagsWidth
		elseif bagType == "Bank" then
			return C["Inventory"].BankWidth
		elseif bagType == "Account" then
			return C["Inventory"].BankWidth
		end
	end

	function MyContainer:OnContentsChanged(isGridOnly)
		self:SortButtons("bagSlot")

		local columns = Module:GetContainerColumns(self.Settings.BagType)
		local headerOffset = 38
		local itemSpacing = 6
		local horizontalOffset = 6
		local verticalOffset = -headerOffset + horizontalOffset
		local _, totalHeight = self:LayoutButtons("grid", columns, itemSpacing, horizontalOffset, verticalOffset)
		local totalWidth = columns * (iconSize + itemSpacing) - itemSpacing

		if self.freeSlot then
			if C["Inventory"].GatherEmpty then
				local slotCount = #self.buttons + 1
				local rowIdx = math_ceil(slotCount / columns)
				local colIdx = slotCount % columns
				if colIdx == 0 then
					colIdx = columns
				end

				local posX = (colIdx - 1) * (iconSize + itemSpacing)
				local posY = -1 * (rowIdx - 1) * (iconSize + itemSpacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", posX + horizontalOffset, posY + verticalOffset)
				self.freeSlot:Show()

				if totalHeight < 0 then
					totalHeight = iconSize
				elseif colIdx == 1 then
					totalHeight = totalHeight + iconSize + itemSpacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(totalWidth + horizontalOffset * 2, totalHeight + headerOffset)

		if not isGridOnly then
			Module:UpdateAllAnchors()
		end
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:CreateBorder()

		if settings.Bags then
			K.CreateMoverFrame(self, nil, true)
		end

		self.iconSize = iconSize
		Module.CreateFreeSlots(self)

		local groupLabel
		if name:match("AzeriteItem$") then
			groupLabel = L["Azerite Armor"]
		elseif name:match("Equipment$") then
			groupLabel = _G.BAG_FILTER_EQUIPMENT
		elseif name:match("EquipSet$") then
			groupLabel = L["Equipment Set"]
		elseif name == "Junk" then
			groupLabel = _G.BAG_FILTER_JUNK
		elseif name == "BagRecent" then
			groupLabel = L["Recent Items"]
		elseif name == "BagRelic" then
			groupLabel = L["Korthian Relics"]
		elseif name == "BagReagent" then
			groupLabel = L["Reagent Bag"]
		elseif name == "BagStone" then
			groupLabel = C_Spell_GetSpellName(404861)
		elseif name:match("Keystone$") then
			groupLabel = _G.WEEKLY_REWARDS_MYTHIC_KEYSTONE
		elseif string_match(name, "AOE") then
			groupLabel = _G.ITEM_ACCOUNTBOUND_UNTIL_EQUIP
		elseif string_match(name, "Lower") then
			groupLabel = L["Lower Item Level"]
		elseif string_match(name, "Legacy") then
			groupLabel = L["Legacy Items"]
		elseif string_match(name, "Decor") then
			groupLabel = _G.AUCTION_CATEGORY_HOUSING
		else
			if name:match("Legendary$") then
				groupLabel = _G.LOOT_JOURNAL_LEGENDARIES
			elseif name:match("Consumable$") then
				groupLabel = _G.BAG_FILTER_CONSUMABLES
			elseif name:match("Collection") then
				groupLabel = _G.COLLECTIONS
			elseif name:match("Goods") then
				groupLabel = _G.AUCTION_CATEGORY_TRADE_GOODS
			elseif name:match("Quest") then
				groupLabel = _G.QUESTS_LABEL
			elseif name:match("Anima") then
				groupLabel = _G.POWER_TYPE_ANIMA
			elseif name:match("Custom%d") then
				groupLabel = Module:GetCustomGroupTitle(settings.Index)
			end
		end

		if groupLabel then
			self.label = K.CreateFontString(self, 13, groupLabel, "OUTLINE", true, "TOPLEFT", 6, -8)
			return
		end

		Module.CreateInfoFrame(self)

		local widgets = {}
		widgets[1] = Module.CreateCloseButton(self, bagFrames)
		widgets[2] = Module.CreateSortButton(self, name)
		if name == "Bag" then
			Module.CreateBagBar(self, settings, 5)
			widgets[3] = Module.CreateBagToggle(self)
			widgets[4] = Module.CreateSplitButton(self)
			widgets[5] = Module.CreateFavouriteButton(self)
			widgets[6] = Module.CreateJunkButton(self)
			widgets[7] = Module.CreateDeleteButton(self)
			if widgets[7] then
				widgets[7]:SetShown(C["Inventory"].DeleteButton)
			end
		elseif name == "Bank" then
			Module.CreateBagTab(self, settings, 6)
			widgets[3] = Module.CreateBagToggle(self)
			widgets[4] = Module.CreateAccountBankButton(self)
		elseif name == "Account" then
			Module.CreateBagTab(self, settings, 5, "account")
			widgets[3] = Module.CreateBagToggle(self)
			widgets[4] = Module.CreateAccountBankDeposit(self)
			widgets[5] = Module.CreateBankButton(self)
			widgets[6] = Module.CreateAccountMoney(self)
		end

		for i = 1, #widgets do
			local widgetBu = widgets[i]
			if not widgetBu then
				break
			end

			if i == 1 then
				widgetBu:SetPoint("TOPRIGHT", -6, -6)
			else
				widgetBu:SetPoint("RIGHT", widgets[i - 1], "LEFT", -6, 0)
			end
		end
		self.widgetButtons = widgets

		if name == "Bag" then
			Module.CreateCollapseArrow(self)
		end

		self:HookScript("OnShow", K.RestoreMoverFrame)
	end

	local function refreshSlotSize(button)
		button:SetSize(iconSize, iconSize)
		if button.glowFrame then
			button.glowFrame:SetSize(iconSize + 8, iconSize + 8)
		end
	end

	-- REASON: External hook for UI configuration changes. This allows other modules or the options GUI
	-- to trigger a forced refresh of the bag system when settings like 'Icon Size' or 'Reverse Sort' are modified.
	function Module:UpdateBagStatus()
		Module:UpdateAllBags()
	end

	function Module:UpdateBagSize()
		iconSize = C["Inventory"].IconSize
		for _, container in pairs(Backpack.contByName) do
			container:ApplyToButtons(refreshSlotSize)
			if container.freeSlot then
				container.freeSlot:SetSize(iconSize, iconSize)
			end
			if container.BagBar then
				for _, bagBtn in ipairs(container.BagBar.buttons) do
					bagBtn:SetSize(iconSize, iconSize)
				end
				container.BagBar:UpdateAnchor()
			end
			container:OnContentsChanged(true)
		end
	end

	function Module:UpdateBagAnchor()
		if not Module.initComplete then
			return
		end
		for _, container in pairs(Backpack.contByName) do
			container:OnContentsChanged(false)
		end
	end

	function Module:UpdateSortOrder()
		C_Container_SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(0)
		self:SetPushedTexture(0)

		self:SetSize(iconSize, iconSize)
		self:CreateBorder()
		self:StyleButton()

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))
	end

	function BagButton:OnUpdateButton()
		local itemID = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		if not itemID then
			return
		end

		local _, _, quality, _, _, _, _, _, _, _, _, classID, subClassID = C_Item_GetItemInfo(itemID)
		if not quality or quality == 1 then
			quality = 0
		end

		local qualityColor = K.QualityColors[quality]
		if not self.hidden and not self.notBought then
			self.KKUI_Border:SetVertexColor(qualityColor.r, qualityColor.g, qualityColor.b)
		else
			K.SetBorderColor(self.KKUI_Border)
		end

		if classID == _G.LE_ITEM_CLASS_CONTAINER then
			Module.BagsType[self.bagId] = subClassID or 0
		else
			Module.BagsType[self.bagId] = 0
		end
	end

	C_Container_SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
	C_Container_SetInsertItemsLeftToRight(false)

	-- REASON: Brief toggle to force cargBags to recalculate slot groupings on load. This ensures
	-- that the initial bag display correctly reflects the user's filtered categories and layout.
	C["Inventory"].GatherEmpty = not C["Inventory"].GatherEmpty
	_G.ToggleAllBags()
	C["Inventory"].GatherEmpty = not C["Inventory"].GatherEmpty
	_G.ToggleAllBags()
	Module.initComplete = true

	if Module.SetupRecentItems then
		Module:SetupRecentItems()
	end

	if _G.KKUI_GoldDataText then
		Backpack.OnOpen = function()
			if not _G.KkthnxUIDB.ShowSlots then
				return
			end
			K.GoldButton_OnEvent()
		end
	end

	-- REASON: Shim for Blizzard BankFrame logic to respect custom anchoring. By overriding 'GetRight',
	-- we ensure that dependent UI elements (like tutorial popups or specific addon frames) anchor
	-- correctly to our virtual bank container rather than the hidden original Blizzard bank frame.
	_G.BankFrame.GetRight = function()
		return bagFrames.bank:GetRight()
	end
	_G.BankFrameItemButton_Update = K.Noop

	local suppressedTable = { ["TutorialReagentBag"] = true }
	hooksecurefunc(_G.HelpTip, "Show", function(self, _, info)
		if info and suppressedTable[info.system] then
			self:HideAllSystem(info.system)
		end
	end)

	SetCVarBitfield("closedInfoFrames", _G.LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG, true)
	_G.SetCVar("professionToolSlotsExampleShown", 1)
	_G.SetCVar("professionAccessorySlotsExampleShown", 1)

	hooksecurefunc(BankFrame.BankPanel, "SetBankType", function(self, bankType)
		Module.Bags:GetContainer("Bank"):SetShown(bankType == CHAR_BANK_TYPE)
		Module.Bags:GetContainer("Account"):SetShown(bankType == ACCOUNT_BANK_TYPE)
		Module:UpdateAllBags()
		if _G["KKUI_BankPurchaseButton"] then
			_G["KKUI_BankPurchaseButton"]:SetShown(bankType == ACCOUNT_BANK_TYPE and C_Bank_CanPurchaseBankTab(ACCOUNT_BANK_TYPE))
		end
	end)

	local throttlingFrame = CreateFrame("Frame", nil, bagFrames.main)
	throttlingFrame:Hide()
	throttlingFrame:SetScript("OnUpdate", function(self, elapsed)
		self.delay = self.delay - elapsed
		if self.delay < 0 then
			Module:UpdateAllBags()
			self:Hide()
		end
	end)
	Module._bagItemInfoThrottle = throttlingFrame

	function Module.OnBagItemInfoReceived()
		if Module.Bags and Module.Bags:IsShown() and Module._bagItemInfoThrottle then
			Module._bagItemInfoThrottle.delay = 1
			Module._bagItemInfoThrottle:Show()
		end
	end

	K:RegisterEvent("TRADE_SHOW", Module.OpenBags)
	K:RegisterEvent("TRADE_CLOSED", Module.CloseBags)
	K:RegisterEvent("GET_ITEM_INFO_RECEIVED", Module.OnBagItemInfoReceived)
	Module._bagEventsRegistered = true
end
