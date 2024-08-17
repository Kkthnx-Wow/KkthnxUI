local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local wipe, select, pairs = wipe, _G.select, _G.pairs

local ATTACHMENTS_MAX_RECEIVE, ERR_MAIL_DELETE_ITEM_ERROR = ATTACHMENTS_MAX_RECEIVE, _G.ERR_MAIL_DELETE_ITEM_ERROR
local C_Mail_HasInboxMoney = C_Mail.HasInboxMoney
local C_Mail_IsCommandPending = C_Mail.IsCommandPending
local C_Timer_After = C_Timer.After
local GetInboxNumItems, GetInboxHeaderInfo, GetInboxItem, GetItemInfo = GetInboxNumItems, _G.GetInboxHeaderInfo, _G.GetInboxItem, _G.GetItemInfo
local GetSendMailPrice, GetMoney = GetSendMailPrice, _G.GetMoney
local InboxItemCanDelete, DeleteInboxItem, TakeInboxMoney, TakeInboxItem = InboxItemCanDelete, _G.DeleteInboxItem, _G.TakeInboxMoney, _G.TakeInboxItem
local NORMAL_STRING = GUILDCONTROL_OPTION16
local OPENING_STRING = OPEN_ALL_MAIL_BUTTON_OPENING
local GameTooltip = GameTooltip

local mailIndex = 0
local timeToWait = 0.15
local totalCash = 0
local inboxItems = {}
local isGoldCollecting

function Module:MailBox_DelectClick()
	local selectedID = self.id + (InboxFrame.pageNum - 1) * 7
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
	bu:SetScript("OnClick", Module.MailBox_DelectClick)
	K.AddTooltip(bu, "ANCHOR_RIGHT", DELETE, "system")
end

function Module:InboxItem_OnEnter()
	if not self.index then -- may receive fake mails from Narcissus
		return
	end
	wipe(inboxItems)

	local itemAttached = select(8, GetInboxHeaderInfo(self.index))
	if itemAttached then
		for attachID = 1, 12 do
			local _, itemID, _, itemCount = GetInboxItem(self.index, attachID)
			if itemCount and itemCount > 0 then
				inboxItems[itemID] = (inboxItems[itemID] or 0) + itemCount
			end
		end

		if itemAttached > 1 then
			GameTooltip:AddLine(L["Attach List"])
			for itemID, count in pairs(inboxItems) do
				local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
				if itemName then
					local r, g, b = GetItemQualityColor(itemQuality)
					GameTooltip:AddDoubleLine(" |T" .. itemTexture .. ":12:12:0:0:50:50:4:46:4:46|t " .. itemName, count, r, g, b)
				end
			end
			GameTooltip:Show()
		end
	end
end

function Module:MailBox_CollectGold()
	if mailIndex > 0 then
		if not C_Mail_IsCommandPending() then
			if C_Mail_HasInboxMoney(mailIndex) then
				TakeInboxMoney(mailIndex)
			end
			mailIndex = mailIndex - 1
		end
		C_Timer_After(timeToWait, Module.MailBox_CollectGold)
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
	mailIndex = GetInboxNumItems()
	Module:UpdateOpeningText(true)
	Module:MailBox_CollectGold()
end

function Module:TotalCash_OnEnter()
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

function Module:MailBox_CreatButton(parent, width, height, text, anchor)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width, height)
	button:SetPoint(unpack(anchor))
	button:SetText(text)

	return button
end

function Module:CollectGoldButton()
	OpenAllMail:ClearAllPoints()
	OpenAllMail:SetPoint("TOPLEFT", InboxFrame, "TOPLEFT", 70, -28)

	local button = Module:MailBox_CreatButton(InboxFrame, 120, 24, "", { "LEFT", OpenAllMail, "RIGHT", 3, 0 })
	button:SetScript("OnClick", Module.MailBox_CollectAllGold)
	button:HookScript("OnEnter", Module.TotalCash_OnEnter)
	button:HookScript("OnLeave", Module.TotalCash_OnLeave)

	Module.GoldButton = button
	Module:UpdateOpeningText()
end

function Module:MailBox_CollectAttachment()
	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local attachmentButton = OpenMailFrame.OpenMailAttachments[i]
		if attachmentButton:IsShown() then
			TakeInboxItem(InboxFrame.openMailID, i)
			C_Timer_After(timeToWait, Module.MailBox_CollectAttachment)
			return
		end
	end
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
	Module:MailBox_CollectAttachment()
end

function Module:CollectCurrentButton()
	local button = Module:MailBox_CreatButton(OpenMailFrame, 82, 22, L["Take All"], { "RIGHT", "OpenMailReplyButton", "LEFT", -1, 0 })
	button:SetScript("OnClick", Module.MailBox_CollectCurrent)
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
	for i = 1, 7 do
		local itemButton = _G["MailItem" .. i .. "Button"]
		Module.MailItem_AddDelete(itemButton, i)
	end

	-- Tooltips for multi-items
	hooksecurefunc("InboxFrameItem_OnEnter", Module.InboxItem_OnEnter)

	-- Elements
	Module:ArrangeDefaultElements()
	Module:CollectGoldButton()
	Module:CollectCurrentButton()
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
