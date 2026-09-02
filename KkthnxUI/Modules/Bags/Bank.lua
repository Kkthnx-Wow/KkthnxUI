--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Bank.lua
	Purpose:
		The bank window. It reuses the shared container, layout, and item buttons
		from Core.lua and Slots.lua, and adds a tab strip to switch between the
		character bank and the Warband (account) bank. The stock BankFrame is
		moved out of sight so only our window shows, while the bank stays open
		server side so deposits and withdrawals keep working. Retail only.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Bags")

local _G = _G
local ipairs = ipairs
local tinsert = table.insert

local CreateFrame = CreateFrame
local C_Bank = C_Bank
local Enum = Enum

local CHARACTER = Enum.BankType and Enum.BankType.Character or 0
local ACCOUNT = Enum.BankType and Enum.BankType.Account or 2

-- Which bank we are looking at. Defaults to the character bank.
Module.bankType = CHARACTER

-- The container ids that make up the currently selected bank, one per purchased
-- tab. Read fresh so newly bought tabs appear without a reload.
function Module:GetBankBags()
	local ids = {}
	if C_Bank and C_Bank.FetchPurchasedBankTabIDs then
		local tabs = C_Bank.FetchPurchasedBankTabIDs(self.bankType)
		if tabs then
			for _, id in ipairs(tabs) do
				tinsert(ids, id)
			end
		end
	end
	return ids
end

-- Tell the game which bank is active so a right-click deposit lands in it. Blizzard
-- routes UseContainerItem to BankFrame:GetActiveBankType(), which reads the bank
-- panel's type but only while the panel reports shown. We keep the stock panel
-- under our hidden parent, so we flip its shown flag on (invisible) and set its
-- type. Without this every deposit falls back to the character bank, which is why
-- the Warband tab was storing into the personal bank.
function Module:SetActiveBankType(bankType)
	local panel = _G.BankFrame and _G.BankFrame.BankPanel
	if not panel then
		return
	end
	if panel.Show and not panel:IsShown() then
		panel:Show()
	end
	if panel.SetBankType then
		panel:SetBankType(bankType)
	end
end

-- Point the bank window at the selected bank and relayout.
function Module:RefreshBankBags()
	if not self.BankFrame then
		return
	end
	self.BankFrame.bags = self:GetBankBags()
	if self.BankFrame:IsShown() then
		self:LayoutContainer(self.BankFrame)
	end
	self:UpdateBankTabs()
end

-- Highlight the active tab and grey the others.
function Module:UpdateBankTabs()
	if not self.BankFrame or not self.BankFrame.Tabs then
		return
	end
	for _, tab in ipairs(self.BankFrame.Tabs) do
		local active = tab.bankType == self.bankType
		tab.Text:SetTextColor(active and K.Colors.gold[1] or K.Colors.silver[1], active and K.Colors.gold[2] or K.Colors.silver[2], active and K.Colors.gold[3] or K.Colors.silver[3])
	end
	-- Show the Warband balance and its deposit/withdraw only on the Warband tab.
	if self.UpdateWarbandMoney then
		self:UpdateWarbandMoney(self.BankFrame)
	end
	-- Rebuild the tab icons and buy button for the active bank type.
	if self.UpdateBankBar then
		self:UpdateBankBar(self.BankFrame)
	end
end

local function AddTab(frame, label, bankType, index)
	local tab = CreateFrame("Button", "$parentTab" .. index, frame)
	tab:SetSize(90, 20)
	tab.bankType = bankType
	tab.Text = tab:CreateFontString(nil, "OVERLAY")
	K.SetFont(tab.Text, 12, K.FontOutlineStyle())
	tab.Text:SetPoint("CENTER")
	tab.Text:SetText(label)
	tab:SetScript("OnClick", function()
		Module.bankType = bankType
		Module:SetActiveBankType(bankType)
		Module:RefreshBankBags()
	end)
	K.SkinButton(tab)
	return tab
end

function Module:SetupBank()
	local f = self:CreateContainer("KKUI_BankFrame", L["Bank"], {}, C.Bags.BankPerRow)
	f.isBank = true
	f.extraTop = 26 -- room for the tab strip under the title band
	self.BankFrame = f

	-- Tab strip: character bank and Warband bank.
	f.Tabs = {}
	-- 8px below the search box (which ends at y -30), matching the tab-to-grid gap.
	local charTab = AddTab(f, L["Character"], CHARACTER, 1)
	charTab:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -38)
	tinsert(f.Tabs, charTab)

	local acctTab = AddTab(f, L["Warband"], ACCOUNT, 2)
	acctTab:SetPoint("LEFT", charTab, "RIGHT", 6, 0)
	tinsert(f.Tabs, acctTab)

	-- Deposit-all button, mirrors Blizzard's auto-deposit for the active bank.
	local deposit = CreateFrame("Button", "$parentDeposit", f)
	deposit:SetSize(90, 20)
	deposit:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -38)
	deposit.Text = deposit:CreateFontString(nil, "OVERLAY")
	K.SetFont(deposit.Text, 12, K.FontOutlineStyle())
	deposit.Text:SetPoint("CENTER")
	deposit.Text:SetText(L["Deposit All"])
	deposit:SetScript("OnClick", function()
		if C_Bank and C_Bank.AutoDepositItemsIntoBank then
			C_Bank.AutoDepositItemsIntoBank(Module.bankType)
		end
	end)
	K.SkinButton(deposit)
	f.Deposit = deposit

	K.CreateMover(f, "Bank", L["Bank"], { "TOPLEFT", UIParent, "TOPLEFT", 60, -60 }, f:GetWidth(), f:GetHeight())
	K.EnableFrameDrag(f)

	-- Per-character gold breakdown on hover of the money text, plus the clickable
	-- Warband balance in the bottom bar (shown only on the Warband tab).
	if self.AttachGoldTooltip then
		self:AttachGoldTooltip(f)
		self:CreateWarbandMoney(f)
	end

	-- The tab bar: purchased tabs and a buy button, below the bank window.
	if self.CreateBankBar then
		self:CreateBankBar(f)
	end

	-- Move the stock bank UI out of the way. The bank stays open server side, so
	-- deposits and withdrawals still work through our own item buttons.
	local hidden = _G.KKUI_HiddenParent
	if not hidden then
		hidden = CreateFrame("Frame", "KKUI_HiddenParent", UIParent)
		hidden:Hide()
	end
	if _G.BankFrame then
		_G.BankFrame:SetParent(hidden)
	end

	self:RegisterEvent("BANKFRAME_OPENED", function()
		if self.CaptureGold then
			self:CaptureGold()
		end
		self:OpenBank()
	end)
	self:RegisterEvent("BANKFRAME_CLOSED", function()
		self:CloseBank()
	end)
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", "MarkDirty")
	self:RegisterEvent("BANK_TABS_CHANGED", "MarkDirty")
end

function Module:OpenBank()
	if not self.BankFrame then
		return
	end
	self:SetActiveBankType(self.bankType)
	self:RefreshBankBags()
	self.BankFrame:Show()
	self:LayoutContainer(self.BankFrame)
	-- Show the bags alongside the bank, the way the default UI does.
	self:OpenBags()

	if C.Bags.AutoDepositReagents and C_Bank and C_Bank.AutoDepositItemsIntoBank then
		C_Bank.AutoDepositItemsIntoBank(CHARACTER)
	end
end

function Module:CloseBank()
	if self.BankFrame then
		self.BankFrame:Hide()
	end
	self:CloseBags()
end
