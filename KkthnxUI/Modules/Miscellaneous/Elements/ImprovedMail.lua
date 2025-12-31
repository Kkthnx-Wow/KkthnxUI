local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local wipe, select, pairs = wipe, _G.select, _G.pairs

local ATTACHMENTS_MAX_RECEIVE, ERR_MAIL_DELETE_ITEM_ERROR = ATTACHMENTS_MAX_RECEIVE, _G.ERR_MAIL_DELETE_ITEM_ERROR
local C_Mail_HasInboxMoney = C_Mail.HasInboxMoney
local C_Mail_IsCommandPending = C_Mail.IsCommandPending
local GetInboxNumItems, GetInboxHeaderInfo, GetInboxItem, GetItemInfo = GetInboxNumItems, _G.GetInboxHeaderInfo, _G.GetInboxItem, _G.GetItemInfo
local GetSendMailPrice, GetMoney = GetSendMailPrice, _G.GetMoney
local InboxItemCanDelete, DeleteInboxItem, TakeInboxMoney, TakeInboxItem = InboxItemCanDelete, _G.DeleteInboxItem, _G.TakeInboxMoney, _G.TakeInboxItem
local NORMAL_STRING = GUILDCONTROL_OPTION16
local OPENING_STRING = OPEN_ALL_MAIL_BUTTON_OPENING
local GameTooltip = GameTooltip
local CreateFrame, hooksecurefunc, unpack = _G.CreateFrame, _G.hooksecurefunc, _G.unpack
local GetItemQualityColor, HasInboxItem = _G.GetItemQualityColor, _G.HasInboxItem
local INBOX_ITEMS_PER_PAGE = _G.INBOXITEMS_TO_DISPLAY or 7
local ATTACHMENTS_MAX = _G.ATTACHMENTS_MAX or ATTACHMENTS_MAX_RECEIVE or 12

-- Lightweight profiling hooks (disabled by default)
local PROFILING_ENABLED = false
local function profileStart()
	if PROFILING_ENABLED then
	end
end

local function profileEnd(startTime, label)
	if not PROFILING_ENABLED or not startTime then
		return
	end
	if K and K.Print then
		K.Print(string.format("[ImprovedMail] %s: %.2f ms", label or "block", elapsed))
	else
		print(string.format("[ImprovedMail] %s: %.2f ms", label or "block", elapsed))
	end
end

-- Small, bounded cache for GetItemInfo
local ITEMINFO_CACHE_LIMIT = 256
local itemInfoCache, itemInfoCacheOrder = {}, {}
local function GetItemInfoCached(itemID)
	if not itemID then
		return
	end
	local cacheEntry = itemInfoCache[itemID]
	if cacheEntry then
		-- Move to most-recently-used position (LRU)
		for idx = 1, #itemInfoCacheOrder do
			if itemInfoCacheOrder[idx] == itemID then
				if idx ~= #itemInfoCacheOrder then
					table.remove(itemInfoCacheOrder, idx)
					itemInfoCacheOrder[#itemInfoCacheOrder + 1] = itemID
				end
				break
			end
		end
		return cacheEntry.name, cacheEntry.quality, cacheEntry.texture
	end
	local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
	if itemName then
		itemInfoCache[itemID] = { name = itemName, quality = itemQuality, texture = itemTexture }
		itemInfoCacheOrder[#itemInfoCacheOrder + 1] = itemID
		if #itemInfoCacheOrder > ITEMINFO_CACHE_LIMIT then
			local oldItemID = table.remove(itemInfoCacheOrder, 1)
			itemInfoCache[oldItemID] = nil
		end
	end
	return itemName, itemQuality, itemTexture
end

-- Event-driven cache invalidation for item info updates
do
	local EventFrame = CreateFrame("Frame")
	EventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
	EventFrame:SetScript("OnEvent", function(_, _, itemID, success)
		if not itemID then
			return
		end
		-- Drop from cache so next access refreshes the data
		if itemInfoCache[itemID] then
			itemInfoCache[itemID] = nil
			for idx = 1, #itemInfoCacheOrder do
				if itemInfoCacheOrder[idx] == itemID then
					table.remove(itemInfoCacheOrder, idx)
					break
				end
			end
		end
	end)
end

local mailIndex = 0
local BASE_THROTTLE = (C and C.Misc and C.Misc.MailThrottle) or 0.25 -- seconds
local NEAR_FULL_THROTTLE = 1.0 -- seconds when nearly full
local NEAR_FULL_FREE_SLOTS = 1 -- if KeepFreeSpace is set, bump earlier
local totalCash = 0
local inboxItems = {}
local isGoldCollecting
local attachmentBlacklist = {}
local firstMailDaysLeft
local lastInboxCount, lastInboxTotal
local KEEP_FREE_SPACE = 0 -- configurable if needed; 0 disables

local function computeThrottle(isNearlyFull)
	if isNearlyFull then
		return NEAR_FULL_THROTTLE
	end
	return BASE_THROTTLE
end

function Module:MailBox_DeleteClick()
	local selectedID = self.id + (InboxFrame.pageNum - 1) * INBOX_ITEMS_PER_PAGE
	if InboxItemCanDelete(selectedID) then
		DeleteInboxItem(selectedID)
	else
		UIErrorsFrame:AddMessage(K.InfoColor .. ERR_MAIL_DELETE_ITEM_ERROR)
	end
end

function Module:MailItem_AddDelete(i)
	local bu = CreateFrame("Button", nil, self)
	bu:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -6, 5)
	bu:SetSize(16, 16)

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetTexture(136813)
	bu.Icon:SetAllPoints(bu)

	bu:EnableMouse(true)
	bu.HL = bu:CreateTexture(nil, "HIGHLIGHT")
	bu.HL:SetTexture(136813)
	bu.HL:SetAllPoints(bu.Icon)
	bu.HL:SetBlendMode("ADD")

	bu.id = i
	bu:SetScript("OnClick", Module.MailBox_DeleteClick)
	K.AddTooltip(bu, "ANCHOR_RIGHT", DELETE, "system")
end

function Module:InboxItem_OnEnter()
	local t = profileStart()
	if not self.index then -- may receive fake mails from Narcissus
		return
	end
	wipe(inboxItems)

	local itemAttached = select(8, GetInboxHeaderInfo(self.index))
	if itemAttached then
		for attachID = 1, ATTACHMENTS_MAX_RECEIVE do
			local _, itemID, _, itemCount = GetInboxItem(self.index, attachID)
			if itemCount and itemCount > 0 then
				inboxItems[itemID] = (inboxItems[itemID] or 0) + itemCount
			end
		end

		if itemAttached > 1 then
			GameTooltip:AddLine("Attach List")
			for itemID, count in pairs(inboxItems) do
				local itemName, itemQuality, itemTexture = GetItemInfoCached(itemID)
				if itemName then
					local r, g, b = GetItemQualityColor(itemQuality)
					GameTooltip:AddDoubleLine(" |T" .. itemTexture .. ":12:12:0:0:50:50:4:46:4:46|t " .. itemName, count, r, g, b)
				end
			end
			GameTooltip:Show()
		end
	end
	profileEnd(t, "InboxItem_OnEnter")
end

function Module:MailBox_CollectGold()
	if mailIndex > 0 then
		if not C_Mail_IsCommandPending() then
			if C_Mail_HasInboxMoney(mailIndex) then
				TakeInboxMoney(mailIndex)
			end
			mailIndex = mailIndex - 1
		end
		K.Delay(computeThrottle(false), Module.MailBox_CollectGold)
	else
		isGoldCollecting = false
		Module:UpdateOpeningText()
	end
end

function Module:MailBox_CollectAllGold()
	if isGoldCollecting then
		return
	end

	if totalCash == 0 then
		return
	end

	isGoldCollecting = true
	local current, total = GetInboxNumItems()
	mailIndex = current
	firstMailDaysLeft = select(7, GetInboxHeaderInfo(1)) or 0
	lastInboxCount, lastInboxTotal = current, total
	Module:UpdateOpeningText(true)
	Module:MailBox_CollectGold()
end

function Module:TotalCash_OnEnter()
	totalCash = 0
	local numItems = GetInboxNumItems()
	if numItems == 0 then
		return
	end

	for i = 1, numItems do
		totalCash = totalCash + select(5, GetInboxHeaderInfo(i))
	end

	if totalCash > 0 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Total Gold"])
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.FormatMoney(totalCash, true), 1, 1, 1)
		GameTooltip:Show()
	end
end

function Module:TotalCash_OnLeave()
	K:HideTooltip()
	totalCash = 0
end

function Module:UpdateOpeningText(opening)
	if opening then
		Module.GoldButton:SetText(OPENING_STRING)
	else
		Module.GoldButton:SetText(NORMAL_STRING)
	end
end

function Module:MailBox_CreateButton(parent, width, height, text, anchor)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width, height)
	button:SetPoint(unpack(anchor))
	button:SetText(text)

	return button
end

function Module:CollectGoldButton()
	OpenAllMail:ClearAllPoints()
	OpenAllMail:SetPoint("TOPLEFT", InboxFrame, "TOPLEFT", 70, -28)

	local button = Module:MailBox_CreateButton(InboxFrame, 120, 24, "", { "LEFT", OpenAllMail, "RIGHT", 3, 0 })
	button:SetScript("OnClick", Module.MailBox_CollectAllGold)
	button:HookScript("OnEnter", Module.TotalCash_OnEnter)
	button:HookScript("OnLeave", Module.TotalCash_OnLeave)

	Module.GoldButton = button
	Module:UpdateOpeningText()
end

function Module:MailBox_CollectAttachment()
	local attachments = OpenMailFrame.OpenMailAttachments
	local openMailID = InboxFrame.openMailID
	if not openMailID or not attachments then
		return
	end

	-- start attachment collection

	-- KeepFreeSpace: stop if we have too few regular slots; track near-full
	local nearlyFull = false
	if KEEP_FREE_SPACE and KEEP_FREE_SPACE > 0 then
		local free = 0
		for bag = 0, NUM_BAG_SLOTS do
			local bagFree, bagFam = C_Container.GetContainerNumFreeSlots(bag)
			if bagFam == 0 then
				free = free + (bagFree or 0)
			end
		end
		nearlyFull = free <= (KEEP_FREE_SPACE + NEAR_FULL_FREE_SLOTS)
		if free <= KEEP_FREE_SPACE then
			-- stop collecting due to insufficient space
			return
		end
	end
	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local attachmentButton = attachments[i]
		if attachmentButton:IsShown() and not (attachmentBlacklist[openMailID] and attachmentBlacklist[openMailID][i]) then
			TakeInboxItem(openMailID, i)
			K.Delay(computeThrottle(nearlyFull), Module.MailBox_CollectAttachment)
			return
		end
	end

	-- Done with collection for this mail
end

function Module:MailBox_CollectCurrent()
	if OpenMailFrame.cod then
		UIErrorsFrame:AddMessage(K.InfoColor .. L["Mail Is COD"])
		return
	end

	local currentID = InboxFrame.openMailID
	if C_Mail_HasInboxMoney(currentID) then
		TakeInboxMoney(currentID)
	end
	-- Reset blacklist for this mail before starting a new collection
	attachmentBlacklist[currentID] = nil
	Module:MailBox_CollectAttachment()
end

function Module:CollectCurrentButton()
	local button = Module:MailBox_CreateButton(OpenMailFrame, 82, 22, L["Take All"], { "RIGHT", "OpenMailReplyButton", "LEFT", -1, 0 })
	button:SetScript("OnClick", Module.MailBox_CollectCurrent)
end

-- UI error handling: stop/skip on inventory full or item missing
do
	local ERR_INV_FULL, ERR_ITEM_NOT_FOUND = _G.ERR_INV_FULL, _G.ERR_ITEM_NOT_FOUND
	local EventFrame = CreateFrame("Frame")
	EventFrame:RegisterEvent("UI_ERROR_MESSAGE")
	EventFrame:SetScript("OnEvent", function(_, _, _, message)
		if not message then
			return
		end

		-- Inventory full: stop collecting attachments immediately
		if message == ERR_INV_FULL then
			return
		end

		-- Item not found: blacklist the current attachment index for this mail and continue
		if message == ERR_ITEM_NOT_FOUND then
			local openMailID = InboxFrame and InboxFrame.openMailID
			if openMailID then
				attachmentBlacklist[openMailID] = attachmentBlacklist[openMailID] or {}
				-- Heuristic: find first visible attachment and skip it next pass
				local attachments = OpenMailFrame and OpenMailFrame.OpenMailAttachments
				if attachments then
					for i = 1, ATTACHMENTS_MAX_RECEIVE do
						local attachmentButton = attachments[i]
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

function Module:ArrangeDefaultElements()
	InboxTooMuchMail:ClearAllPoints()
	InboxTooMuchMail:SetPoint("BOTTOM", MailFrame, "TOP", 0, 5)

	SendMailNameEditBox:SetWidth(155)
	SendMailNameEditBoxMiddle:SetWidth(146)
	SendMailCostMoneyFrame:SetAlpha(0)

	SendMailMailButton:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:ClearLines()
		local sendPrice = GetSendMailPrice()
		local colorStr = "|cffffffff"
		if sendPrice > GetMoney() then
			colorStr = "|cffff0000"
		end

		GameTooltip:AddLine(SEND_MAIL_COST .. colorStr .. K.FormatMoney(sendPrice, true))
		GameTooltip:Show()
	end)

	SendMailMailButton:HookScript("OnLeave", K.HideTooltip)
end

function Module:CreateImprovedMail()
	if not C["Misc"].EnhancedMail then
		return
	end

	if C_AddOns.IsAddOnLoaded("Postal") then
		return
	end

	-- Delete buttons
	for i = 1, INBOX_ITEMS_PER_PAGE do
		local itemButton = _G["MailItem" .. i .. "Button"]
		Module.MailItem_AddDelete(itemButton, i)
	end

	-- Tooltips for multi-items
	hooksecurefunc("InboxFrameItem_OnEnter", Module.InboxItem_OnEnter)

	-- Elements
	Module:ArrangeDefaultElements()
	Module:CollectGoldButton()
	Module:CollectCurrentButton()

	-- Restart-on-refresh guard (gold collection scenario)
	local EventFrame = CreateFrame("Frame")
	EventFrame:RegisterEvent("MAIL_INBOX_UPDATE")
	EventFrame:SetScript("OnEvent", function()
		if not isGoldCollecting then
			return
		end
		local currentFirstMailDaysLeft = select(7, GetInboxHeaderInfo(1)) or 0
		local current, total = GetInboxNumItems()
		if (currentFirstMailDaysLeft ~= 0 and currentFirstMailDaysLeft ~= firstMailDaysLeft) or (current ~= lastInboxCount or total ~= lastInboxTotal) then
			firstMailDaysLeft = currentFirstMailDaysLeft
			lastInboxCount, lastInboxTotal = current, total
			mailIndex = current
		end
	end)
end

Module:RegisterMisc("ImprovedMail", Module.CreateImprovedMail)

-- Temp fix for GM mails
function OpenAllMail:AdvanceToNextItem()
	local foundAttachment = false
	while not foundAttachment do
		local _, _, _, _, _, CODAmount, _, _, _, _, _, _, isGM = GetInboxHeaderInfo(self.mailIndex)
		local itemID = select(2, GetInboxItem(self.mailIndex, self.attachmentIndex))
		local hasBlacklistedItem = self:IsItemBlacklisted(itemID)
		local hasCOD = CODAmount and CODAmount > 0
		local hasMoneyOrItem = C_Mail.HasInboxMoney(self.mailIndex) or HasInboxItem(self.mailIndex, self.attachmentIndex)
		if not hasBlacklistedItem and not isGM and not hasCOD and hasMoneyOrItem then
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
		self.attachmentIndex = ATTACHMENTS_MAX
		if self.mailIndex > GetInboxNumItems() then
			return false
		end

		return self:AdvanceToNextItem()
	end

	return true
end
