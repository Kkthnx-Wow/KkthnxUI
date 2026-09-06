--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/BankBar.lua
	Purpose:
		The bank window's tab bar: an icon per purchased bank tab for the active bank
		type (character or Warband), and a buy button to purchase the next tab. The
		buy button inherits Blizzard's BankPanelPurchaseButtonScriptTemplate, so the
		restricted PurchaseBankTab runs inside Blizzard's own secure context through
		its confirm popup, never from our tainted code. It hangs below the bank frame
		the same way the carried-bag strip hangs below the bags.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Bags")
if not Module then
	return
end

local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local max = math.max
local floor = math.floor
local ceil = math.ceil
local CreateFrame = CreateFrame
local C_Bank = C_Bank
local GetCoinTextureString = GetCoinTextureString

local SLOT = 28
local PAD = 6

local CHARACTER = (Enum.BankType and Enum.BankType.Character) or 0
local ACCOUNT = (Enum.BankType and Enum.BankType.Account) or 2

-- ---------------------------------------------------------------------------
-- Tab editor (name and icon)
-- ---------------------------------------------------------------------------
-- Right-clicking a tab opens this editor: a name box and a paged grid of every
-- game icon. Save writes the name and chosen icon straight through the bank API,
-- keeping the tab's deposit rules. Built from Blizzard's own IconDataProvider so
-- the icon list matches the one the stock bank offers.

local ICON = 30
local COLS, ROWS = 10, 8
local PER_PAGE = COLS * ROWS

local iconProvider

local function HighlightSelected(editor)
	local gold = K.Colors.gold
	for _, button in ipairs(editor.icons) do
		if button:IsShown() and button.fileID == editor.selected then
			button.KKUI_Border:SetVertexColor(gold[1], gold[2], gold[3], 1)
		else
			K.ResetBorderColor(button.KKUI_Border)
		end
	end
end

local function RefreshPage(editor)
	if not iconProvider then
		return
	end
	local num = iconProvider:GetNumIcons()
	local pages = max(1, ceil(num / PER_PAGE))
	editor.page = max(1, math.min(editor.page, pages))
	local base = (editor.page - 1) * PER_PAGE
	for i = 1, PER_PAGE do
		local button = editor.icons[i]
		local index = base + i
		if index <= num then
			local fileID = iconProvider:GetIconByIndex(index)
			button.fileID = fileID
			button.Icon:SetTexture(fileID)
			button:Show()
		else
			button:Hide()
		end
	end
	editor.PageText:SetText(editor.page .. " / " .. pages)
	HighlightSelected(editor)
end

local function BuildEditor()
	local editor = CreateFrame("Frame", "KKUI_BankTabEditor", UIParent)
	editor:SetSize(COLS * (ICON + 4) + 20, ROWS * (ICON + 4) + 128)
	editor:SetPoint("CENTER")
	editor:SetFrameStrata("FULLSCREEN_DIALOG")
	editor:EnableMouse(true)
	editor:SetMovable(true)
	editor:RegisterForDrag("LeftButton")
	editor:SetScript("OnDragStart", editor.StartMoving)
	editor:SetScript("OnDragStop", editor.StopMovingOrSizing)
	K.CreateGradientBackground(editor, 0.95)
	K.CreateBorder(editor)
	editor:Hide()

	local title = editor:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 14, K.FontOutlineStyle())
	title:SetPoint("TOP", editor, "TOP", 0, -10)
	title:SetText(L["Edit Bank Tab"])
	title:SetTextColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])

	local close = CreateFrame("Button", nil, editor)
	close:SetSize(22, 22)
	close:SetPoint("TOPRIGHT", editor, "TOPRIGHT", -4, -4)
	if K.SkinCloseButton then
		K.SkinCloseButton(close)
	end
	close:SetScript("OnClick", function()
		editor:Hide()
	end)

	local name = CreateFrame("EditBox", nil, editor)
	name:SetSize(editor:GetWidth() - 24, 22)
	name:SetPoint("TOP", editor, "TOP", 0, -34)
	name:SetAutoFocus(false)
	name:SetMaxLetters(32)
	K.SetFont(name, 12, "")
	name:SetTextInsets(6, 6, 0, 0)
	if K.SkinEditBox then
		K.SkinEditBox(name)
	end
	name:SetScript("OnEscapePressed", name.ClearFocus)
	editor.Name = name

	editor.icons = {}
	for i = 1, PER_PAGE do
		local button = CreateFrame("Button", nil, editor)
		button:SetSize(ICON, ICON)
		local col = (i - 1) % COLS
		local row = floor((i - 1) / COLS)
		button:SetPoint("TOPLEFT", editor, "TOPLEFT", 10 + col * (ICON + 4), -64 - row * (ICON + 4))
		local tex = button:CreateTexture(nil, "ARTWORK")
		tex:SetPoint("TOPLEFT", 1, -1)
		tex:SetPoint("BOTTOMRIGHT", -1, 1)
		tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.Icon = tex
		K.CreateBorder(button)
		button:SetScript("OnClick", function(self)
			editor.selected = self.fileID
			HighlightSelected(editor)
		end)
		editor.icons[i] = button
	end

	editor:EnableMouseWheel(true)
	editor:SetScript("OnMouseWheel", function(_, delta)
		editor.page = editor.page - delta
		RefreshPage(editor)
	end)

	local function PagerButton(text, anchor, dx, step)
		local b = CreateFrame("Button", nil, editor)
		b:SetSize(24, 20)
		b:SetPoint("BOTTOMLEFT", editor, "BOTTOMLEFT", anchor, 10)
		b.Text = b:CreateFontString(nil, "OVERLAY")
		K.SetFont(b.Text, 14, K.FontOutlineStyle())
		b.Text:SetPoint("CENTER")
		b.Text:SetText(text)
		K.SkinButton(b)
		b:SetScript("OnClick", function()
			editor.page = editor.page + step
			RefreshPage(editor)
		end)
		return b
	end
	PagerButton("<", 10, 0, -1)
	PagerButton(">", 38, 0, 1)

	local pageText = editor:CreateFontString(nil, "OVERLAY")
	K.SetFont(pageText, 12, K.FontOutlineStyle())
	pageText:SetPoint("BOTTOM", editor, "BOTTOM", 0, 14)
	editor.PageText = pageText

	local save = CreateFrame("Button", nil, editor)
	save:SetSize(80, 20)
	save:SetPoint("BOTTOMRIGHT", editor, "BOTTOMRIGHT", -10, 10)
	save.Text = save:CreateFontString(nil, "OVERLAY")
	K.SetFont(save.Text, 12, K.FontOutlineStyle())
	save.Text:SetPoint("CENTER")
	save.Text:SetText(L["Save"])
	K.SkinButton(save)
	save:SetScript("OnClick", function()
		local nm = editor.Name:GetText()
		if editor.tabID and nm and nm ~= "" and editor.selected and C_Bank and C_Bank.UpdateBankTabSettings then
			C_Bank.UpdateBankTabSettings(editor.bankType, editor.tabID, nm, editor.selected, editor.depositFlags or 0)
			editor:Hide()
		end
	end)

	return editor
end

function Module:EditTab(button)
	if not (button and button.tabID and C_Bank and C_Bank.UpdateBankTabSettings) then
		return
	end
	if not iconProvider and CreateAndInitFromMixin and IconDataProviderMixin then
		iconProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.None)
	end

	self.TabEditor = self.TabEditor or BuildEditor()
	local editor = self.TabEditor
	editor.bankType = button.bankType
	editor.tabID = button.tabID
	editor.depositFlags = button.depositFlags
	editor.selected = button.tabIcon
	editor.page = 1
	editor.Name:SetText(button.tabName or "")

	-- Open on the page holding the current icon so it is in view.
	if iconProvider and editor.selected then
		local index = iconProvider:GetIndexOfIcon(editor.selected)
		if index and index > 0 then
			editor.page = ceil(index / PER_PAGE)
		end
	end
	RefreshPage(editor)
	editor:Show()
	editor.Name:SetFocus()
end

-- ---------------------------------------------------------------------------
-- Buy button
-- ---------------------------------------------------------------------------

-- A purchase button per bank type. Inheriting Blizzard's template hands the buy
-- to their secure code (its OnClick opens CONFIRM_BUY_BANK_TAB, whose accept does
-- the purchase), so overrideBankType is all we set.
local function MakeBuyButton(parent, bankType)
	local ok, button = pcall(CreateFrame, "Button", nil, parent, "BankPanelPurchaseButtonScriptTemplate")
	if not ok or not button then
		return nil
	end
	button:SetAttribute("overrideBankType", bankType)
	button:SetSize(SLOT, SLOT)
	K.CreateGradientBackground(button, 0.9)
	K.CreateBorder(button)

	local plus = button:CreateFontString(nil, "OVERLAY")
	K.SetFont(plus, 20, K.FontOutlineStyle())
	plus:SetPoint("CENTER")
	plus:SetText("+")
	plus:SetTextColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])

	button:HookScript("OnEnter", function(self)
		self.KKUI_Border:SetVertexColor(1, 1, 1, 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(L["Buy Bank Tab"], 1, 1, 1)
		local data = C_Bank.FetchNextPurchasableBankTabData and C_Bank.FetchNextPurchasableBankTabData(bankType)
		if data and data.tabCost then
			local g = data.canAfford and 1 or 0.3
			GameTooltip:AddLine(GetCoinTextureString(data.tabCost), 1, g, g)
		end
		GameTooltip:Show()
	end)
	button:HookScript("OnLeave", function(self)
		K.ResetBorderColor(self.KKUI_Border)
		GameTooltip:Hide()
	end)
	button:Hide()
	return button
end

-- ---------------------------------------------------------------------------
-- Tab icons
-- ---------------------------------------------------------------------------

local function TabOnEnter(self)
	self.KKUI_Border:SetVertexColor(1, 1, 1, 1)
	if self.tabName then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tabName, 1, 1, 1)
		GameTooltip:AddLine(L["Right-click to edit name and icon"], 0.7, 0.85, 1)
		GameTooltip:Show()
	end
end

local function TabOnClick(self, mouseButton)
	if mouseButton == "RightButton" then
		Module:EditTab(self)
	end
end

local function TabOnLeave(self)
	K.ResetBorderColor(self.KKUI_Border)
	GameTooltip:Hide()
end

-- Pooled: reuse a tab button across bank-type switches and tab purchases.
local function AcquireTab(bar, index)
	local button = bar.tabs[index]
	if not button then
		button = CreateFrame("Button", nil, bar)
		button:SetSize(SLOT, SLOT)
		K.CreateGradientBackground(button, 0.9)
		K.CreateBorder(button)
		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT", 2, -2)
		icon:SetPoint("BOTTOMRIGHT", -2, 2)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.Icon = icon
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetScript("OnEnter", TabOnEnter)
		button:SetScript("OnLeave", TabOnLeave)
		button:SetScript("OnClick", TabOnClick)
		bar.tabs[index] = button
	end
	return button
end

-- ---------------------------------------------------------------------------
-- Build and refresh
-- ---------------------------------------------------------------------------

function Module:CreateBankBar(f)
	if not f or f.BankBar then
		return f and f.BankBar
	end

	local bar = CreateFrame("Frame", nil, f)
	bar:SetHeight(SLOT + PAD * 2)
	K.CreateGradientBackground(bar, 0.95)
	K.CreateBorder(bar)
	bar:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 0, -6)
	bar.tabs = {}
	bar.buy = {
		[CHARACTER] = MakeBuyButton(bar, CHARACTER),
		[ACCOUNT] = MakeBuyButton(bar, ACCOUNT),
	}

	bar:SetShown(C.Bags.ShowBagBar)
	f.BankBar = bar
	self:UpdateBankBar(f)
	return bar
end

-- Lay out the tab icons for the active bank type, then the buy button when a new
-- tab can still be bought.
function Module:UpdateBankBar(f)
	local bar = f and f.BankBar
	if not bar then
		return
	end
	local bankType = self.bankType or CHARACTER

	for _, button in ipairs(bar.tabs) do
		button:Hide()
	end
	for _, button in pairs(bar.buy) do
		if button then
			button:Hide()
		end
	end

	local x = PAD
	local tabs = C_Bank and C_Bank.FetchPurchasedBankTabData and C_Bank.FetchPurchasedBankTabData(bankType)
	if tabs then
		for i, tab in ipairs(tabs) do
			local button = AcquireTab(bar, i)
			button:ClearAllPoints()
			button:SetPoint("LEFT", bar, "LEFT", x, 0)
			button.Icon:SetTexture(tab.icon)
			button.tabName = tab.name
			button.tabID = tab.ID
			button.tabIcon = tab.icon
			button.depositFlags = tab.depositFlags
			button.bankType = bankType
			button:Show()
			x = x + SLOT + C.Bags.Spacing
		end
	end

	local canBuy = C_Bank and C_Bank.CanPurchaseBankTab and C_Bank.CanPurchaseBankTab(bankType)
	local maxed = C_Bank and C_Bank.HasMaxBankTabs and C_Bank.HasMaxBankTabs(bankType)
	local buy = bar.buy[bankType]
	if buy and canBuy and not maxed then
		buy:ClearAllPoints()
		buy:SetPoint("LEFT", bar, "LEFT", x, 0)
		buy:Show()
		x = x + SLOT + C.Bags.Spacing
	end

	bar:SetWidth(max(x - C.Bags.Spacing + PAD, SLOT + PAD * 2))
end
