--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Enhances the mail system with mass collection, contact management, and item highlighting.
-- - Design: Hooks Inbox and Send Mail frames, implements an LRU cache for item info, and manages throttled collection.
-- - Events: GET_ITEM_INFO_RECEIVED, MAIL_INBOX_UPDATE, UI_ERROR_MESSAGE
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string_format
local table_remove = _G.table.remove
local table_wipe = _G.table.wipe

local _G = _G
local C_Mail_HasInboxMoney = _G.C_Mail.HasInboxMoney
local C_Mail_IsCommandPending = _G.C_Mail.IsCommandPending
local CreateFrame = _G.CreateFrame
local DeleteInboxItem = _G.DeleteInboxItem
local GetInboxHeaderInfo = _G.GetInboxHeaderInfo
local GetInboxItem = _G.GetInboxItem
local GetInboxNumItems = _G.GetInboxNumItems
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMoney = _G.GetMoney
local GetSendMailPrice = _G.GetSendMailPrice
local HookSecureFunc = _G.hooksecurefunc
local InboxItemCanDelete = _G.InboxItemCanDelete
local TakeInboxMoney = _G.TakeInboxMoney
local TakeInboxItem = _G.TakeInboxItem
local Unpack = _G.unpack

-- ---------------------------------------------------------------------------
local ATTACHMENTS_MAX_RECEIVE = _G.ATTACHMENTS_MAX_RECEIVE
local ERR_MAIL_DELETE_ITEM_ERROR = _G.ERR_MAIL_DELETE_ITEM_ERROR
local INBOX_ITEMS_PER_PAGE = _G.INBOXITEMS_TO_DISPLAY or 7
local INBOX_NORMAL_TEXT = _G.GUILDCONTROL_OPTION16
local INBOX_OPENING_TEXT = _G.OPEN_ALL_MAIL_BUTTON_OPENING
local INBOX_DELETE_ICON_ID = 136813

-- ---------------------------------------------------------------------------
local ITEM_INFO_CACHE_LIMIT = 256
local itemInfoCache = {}
local itemInfoCacheOrder = {}

-- REASON: Implements a Least Recently Used (LRU) cache to minimize repeated GetItemInfo calls during mass mail processing.
local function getItemInfoCached(itemID)
	if not itemID then
		return
	end

	local cacheEntry = itemInfoCache[itemID]
	if cacheEntry then
		for i = 1, #itemInfoCacheOrder do
			if itemInfoCacheOrder[i] == itemID then
				if i ~= #itemInfoCacheOrder then
					table_remove(itemInfoCacheOrder, i)
					itemInfoCacheOrder[#itemInfoCacheOrder + 1] = itemID
				end
				break
			end
		end
		return cacheEntry.name, cacheEntry.quality, cacheEntry.texture
	end

	local name, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemID)
	if name then
		itemInfoCache[itemID] = { name = name, quality = quality, texture = texture }
		itemInfoCacheOrder[#itemInfoCacheOrder + 1] = itemID
		if #itemInfoCacheOrder > ITEM_INFO_CACHE_LIMIT then
			local oldestItemID = table_remove(itemInfoCacheOrder, 1)
			itemInfoCache[oldestItemID] = nil
		end
	end
	return name, quality, texture
end

-- REASON: Invalidates cache entries when the server provides updated item data to ensure fresh information.
do
	local cacheEventFrame = CreateFrame("Frame")
	cacheEventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	cacheEventFrame:SetScript("OnEvent", function(_, _, itemID)
		if not itemID or not itemInfoCache[itemID] then
			return
		end
		itemInfoCache[itemID] = nil
		for i = 1, #itemInfoCacheOrder do
			if itemInfoCacheOrder[i] == itemID then
				table_remove(itemInfoCacheOrder, i)
				break
			end
		end
	end)
end

-- ---------------------------------------------------------------------------
local currentMailIndex = 0
local MAIL_BASE_THROTTLE = (C and C.Misc and C.Misc.MailThrottle) or 0.25
local MAIL_FULL_THROTTLE = 1.0
local MAIL_FULL_THRESHOLD = 1
local totalInboxCash = 0
local inboxItemMap = {}
local isCollectingGold = false
local attachmentBlacklist = {}
local firstMailDayRemaining = 0
local lastInboxCount, lastInboxTotalCount = 0, 0

local function getMailThrottle(isNearlyFull)
	return isNearlyFull and MAIL_FULL_THROTTLE or MAIL_BASE_THROTTLE
end

local function onMailDeleteButtonClick(self)
	local targetMailID = self.id + (_G.InboxFrame.pageNum - 1) * INBOX_ITEMS_PER_PAGE
	if InboxItemCanDelete(targetMailID) then
		DeleteInboxItem(targetMailID)
	else
		_G.UIErrorsFrame:AddMessage(K.InfoColor .. ERR_MAIL_DELETE_ITEM_ERROR)
	end
end

local function addDeleteButtonToMailItem(button, index)
	local deleteButton = CreateFrame("Button", nil, button)
	deleteButton:SetPoint("BOTTOMRIGHT", button:GetParent(), "BOTTOMRIGHT", -6, 5)
	deleteButton:SetSize(16, 16)

	deleteButton.Icon = deleteButton:CreateTexture(nil, "ARTWORK")
	deleteButton.Icon:SetTexture(INBOX_DELETE_ICON_ID)
	deleteButton.Icon:SetAllPoints(deleteButton)

	deleteButton:EnableMouse(true)
	deleteButton.Highlight = deleteButton:CreateTexture(nil, "HIGHLIGHT")
	deleteButton.Highlight:SetTexture(INBOX_DELETE_ICON_ID)
	deleteButton.Highlight:SetAllPoints(deleteButton.Icon)
	deleteButton.Highlight:SetBlendMode("ADD")

	deleteButton.id = index
	deleteButton:SetScript("OnClick", onMailDeleteButtonClick)
	K.AddTooltip(deleteButton, "ANCHOR_RIGHT", _G.DELETE, "system")
end

local function onInboxItemEnter(self)
	if not self.index then
		return
	end
	table_wipe(inboxItemMap)

	local _, _, _, _, _, _, _, hasAttachment = GetInboxHeaderInfo(self.index)
	if hasAttachment then
		for i = 1, ATTACHMENTS_MAX_RECEIVE do
			local _, itemID, _, itemCount = GetInboxItem(self.index, i)
			if itemCount and itemCount > 0 then
				inboxItemMap[itemID] = (inboxItemMap[itemID] or 0) + itemCount
			end
		end

		if hasAttachment > 1 then
			_G.GameTooltip:AddLine("Attachment List")
			for itemID, count in pairs(inboxItemMap) do
				local name, quality, texture = getItemInfoCached(itemID)
				if name then
					local r, g, b = GetItemQualityColor(quality)
					_G.GameTooltip:AddDoubleLine(string_format(" |T%s:12:12:0:0:50:50:4:46:4:46|t %s", texture, name), count, r, g, b)
				end
			end
			_G.GameTooltip:Show()
		end
	end
end

function Module:collectMailGold()
	if not _G.MailFrame or not _G.MailFrame:IsShown() then
		isCollectingGold = false
		Module:UpdateOpeningText()
		return
	end

	if currentMailIndex > 0 then
		if not C_Mail_IsCommandPending() then
			if C_Mail_HasInboxMoney(currentMailIndex) then
				TakeInboxMoney(currentMailIndex)
			end
			currentMailIndex = currentMailIndex - 1
		end
		K.Delay(getMailThrottle(false), Module.collectMailGold)
	else
		isCollectingGold = false
		Module:UpdateOpeningText()
	end
end

function Module:collectAllMailGold()
	if isCollectingGold then
		return
	end

	if totalInboxCash == 0 then
		return
	end

	isCollectingGold = true
	local items, total = GetInboxNumItems()
	currentMailIndex = items
	firstMailDayRemaining = select(7, GetInboxHeaderInfo(1)) or 0
	lastInboxCount, lastInboxTotalCount = items, total
	Module:UpdateOpeningText(true)
	Module:collectMailGold()
end

local function onTotalCashEnter(self)
	totalInboxCash = 0
	local numItems = GetInboxNumItems()
	if numItems == 0 then
		return
	end

	for i = 1, numItems do
		totalInboxCash = totalInboxCash + select(5, GetInboxHeaderInfo(i))
	end

	if totalInboxCash > 0 then
		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		_G.GameTooltip:AddLine(L["Total Gold"])
		_G.GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(K.FormatMoney(totalInboxCash, true), 1, 1, 1)
		_G.GameTooltip:Show()
	end
end

local function onTotalCashLeave()
	_G.K.HideTooltip()
	totalInboxCash = 0
end

function Module:UpdateOpeningText(isOpening)
	if not Module.GoldButton then return end
	if isOpening then
		Module.GoldButton:SetText(INBOX_OPENING_TEXT)
	else
		Module.GoldButton:SetText(INBOX_NORMAL_TEXT)
	end
end

function Module:createMailControlButton(parentFrame, frameWidth, frameHeight, buttonText, frameAnchor)
	local controlButton = CreateFrame("Button", nil, parentFrame, "UIPanelButtonTemplate")
	controlButton:SetSize(frameWidth, frameHeight)
	controlButton:SetPoint(Unpack(frameAnchor))
	controlButton:SetText(buttonText)

	return controlButton
end

function Module:createCollectGoldButton()
	local openAllMailButton = _G.OpenAllMail
	local inboxFrame = _G.InboxFrame

	openAllMailButton:ClearAllPoints()
	openAllMailButton:SetPoint("TOPLEFT", inboxFrame, "TOPLEFT", 70, -28)

	local collectGoldButton = Module:createMailControlButton(inboxFrame, 120, 24, "", { "LEFT", openAllMailButton, "RIGHT", 3, 0 })
	collectGoldButton:SetScript("OnClick", Module.collectAllMailGold)
	collectGoldButton:HookScript("OnEnter", onTotalCashEnter)
	collectGoldButton:HookScript("OnLeave", onTotalCashLeave)

	Module.GoldButton = collectGoldButton
	Module:UpdateOpeningText(false)
end

-- REASON: Recursively collects attachments from the currently open mail, with logic to stop if inventory space is low.
function Module:collectMailAttachments()
	if not _G.MailFrame or not _G.MailFrame:IsShown() then
		return
	end

	local openMailFrame = _G.OpenMailFrame
	local attachmentFrames = openMailFrame.OpenMailAttachments
	local currentMailID = _G.InboxFrame.openMailID
	if not currentMailID or not attachmentFrames then
		return
	end

	local isInventoryNearlyFull = false
	local freeSlotsCount = 0
	-- REASON: Check for standard inventory slots (excluding specialty bags)
	for bagIndex = 0, _G.NUM_BAG_SLOTS do
		local free, family = _G.C_Container.GetContainerNumFreeSlots(bagIndex)
		if family == 0 then
			freeSlotsCount = freeSlotsCount + (free or 0)
		end
	end

	isInventoryNearlyFull = freeSlotsCount <= (MAIL_FULL_THRESHOLD + 1)
	if freeSlotsCount <= 0 then
		return
	end

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local attachmentButton = attachmentFrames[i]
		if attachmentButton:IsShown() and not (attachmentBlacklist[currentMailID] and attachmentBlacklist[currentMailID][i]) then
			TakeInboxItem(currentMailID, i)
			K.Delay(getMailThrottle(isInventoryNearlyFull), Module.collectMailAttachments)
			return
		end
	end
end

function Module:collectCurrentMailAttachments()
	local openMailFrame = _G.OpenMailFrame
	if openMailFrame.cod then
		_G.UIErrorsFrame:AddMessage(K.InfoColor .. L["Mail Is COD"])
		return
	end

	local currentMailID = _G.InboxFrame.openMailID
	if C_Mail_HasInboxMoney(currentMailID) then
		TakeInboxMoney(currentMailID)
	end

	attachmentBlacklist[currentMailID] = nil
	Module:collectMailAttachments()
end

function Module:createCollectCurrentButton()
	local collectAllButton = Module:createMailControlButton(_G.OpenMailFrame, 82, 22, L["Take All"], { "RIGHT", "OpenMailReplyButton", "LEFT", -1, 0 })
	collectAllButton:SetScript("OnClick", Module.collectCurrentMailAttachments)
end

-- REASON: Monitors for inventory errors during mass collection to blacklist stuck items or stop the process.
do
	local ERR_INV_FULL = _G.ERR_INV_FULL
	local ERR_ITEM_NOT_FOUND = _G.ERR_ITEM_NOT_FOUND
	local mailErrorFrame = CreateFrame("Frame")
	mailErrorFrame:RegisterEvent("UI_ERROR_MESSAGE")
	mailErrorFrame:SetScript("OnEvent", function(_, _, _, errorMessage)
		if not errorMessage then
			return
		end

		if errorMessage == ERR_INV_FULL then
			return
		end

		if errorMessage == ERR_ITEM_NOT_FOUND then
			local openMailID = _G.InboxFrame and _G.InboxFrame.openMailID
			if openMailID then
				attachmentBlacklist[openMailID] = attachmentBlacklist[openMailID] or {}
				local attachmentFrames = _G.OpenMailFrame and _G.OpenMailFrame.OpenMailAttachments
				if attachmentFrames then
					for i = 1, ATTACHMENTS_MAX_RECEIVE do
						local attachmentButton = attachmentFrames[i]
						if attachmentButton and attachmentButton:IsShown() then
							attachmentBlacklist[openMailID][i] = true
							break
						end
					end
				end
			end
		end
	end)
end

function Module:arrangeDefaultMailElements()
	_G.InboxTooMuchMail:ClearAllPoints()
	_G.InboxTooMuchMail:SetPoint("BOTTOM", _G.MailFrame, "TOP", 0, 5)

	_G.SendMailNameEditBox:SetWidth(155)
	_G.SendMailNameEditBoxMiddle:SetWidth(146)
	_G.SendMailCostMoneyFrame:SetAlpha(0)

	_G.SendMailMailButton:HookScript("OnEnter", function(self)
		_G.GameTooltip:SetOwner(self, "ANCHOR_TOP")
		_G.GameTooltip:ClearLines()
		local sendMailCost = GetSendMailPrice()
		local costColorString = "|cffffffff"
		if sendMailCost > GetMoney() then
			costColorString = "|cffff0000"
		end

		_G.GameTooltip:AddLine(_G.SEND_MAIL_COST .. costColorString .. K.FormatMoney(sendMailCost, true))
		_G.GameTooltip:Show()
	end)

	_G.SendMailMailButton:HookScript("OnLeave", K.HideTooltip)
end

function Module:CreateImprovedMail()
	if not C["Misc"].EnhancedMail then
		return
	end

	if _G.C_AddOns.IsAddOnLoaded("Postal") then
		return
	end

	for i = 1, INBOX_ITEMS_PER_PAGE do
		local mailItemButton = _G["MailItem" .. i .. "Button"]
		addDeleteButtonToMailItem(mailItemButton, i)
	end

	HookSecureFunc("InboxFrameItem_OnEnter", onInboxItemEnter)

	Module:arrangeDefaultMailElements()
	Module:createCollectGoldButton()
	Module:createCollectCurrentButton()

	-- REASON: Monitors the inbox for updates during mass gold collection to reset indices if the mailbox content changes.
	local mailUpdateFrame = CreateFrame("Frame")
	mailUpdateFrame:RegisterEvent("MAIL_INBOX_UPDATE")
	mailUpdateFrame:SetScript("OnEvent", function()
		if not isCollectingGold then
			return
		end
		local currentFirstMailDayRemaining = select(7, GetInboxHeaderInfo(1)) or 0
		local currentCount, totalCount = GetInboxNumItems()
		if (currentFirstMailDayRemaining ~= 0 and currentFirstMailDayRemaining ~= firstMailDayRemaining) or (currentCount ~= lastInboxCount or totalCount ~= lastInboxTotalCount) then
			firstMailDayRemaining = currentFirstMailDayRemaining
			lastInboxCount, lastInboxTotalCount = currentCount, totalCount
			currentMailIndex = currentCount
		end
	end)
end

Module:RegisterMisc("ImprovedMail", Module.CreateImprovedMail)

-- REASON: Overrides standard OpenAllMail logic to handle GM mails and blacklisted items during mass processing.
function _G.OpenAllMail:AdvanceToNextItem()
	local foundAttachment = false
	while not foundAttachment do
		local _, _, _, _, _, codAmount, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex)
		local _, itemID = GetInboxItem(self.mailIndex, self.attachmentIndex)
		local isBlacklisted = self:IsItemBlacklisted(itemID)
		local hasCOD = codAmount and codAmount > 0
		local hasMoneyOrItem = _G.C_Mail.HasInboxMoney(self.mailIndex) or _G.HasInboxItem(self.mailIndex, self.attachmentIndex)

		if not isBlacklisted and not isGM and not hasCOD and hasMoneyOrItem then
			foundAttachment = true
		else
			self.attachmentIndex = self.attachmentIndex - 1
			if self.attachmentIndex == 0 then
				break
			end
		end
	end

	if not foundAttachment then
		self.mailIndex = self.mailIndex + 1
		self.attachmentIndex = _G.ATTACHMENTS_MAX or ATTACHMENTS_MAX_RECEIVE or 12
		if self.mailIndex > GetInboxNumItems() then
			return false
		end

		return self:AdvanceToNextItem()
	end

	return true
end
