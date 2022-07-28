local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")

local _G = _G

local wipe, select, pairs = _G.wipe, _G.select, _G.pairs

local ATTACHMENTS_MAX_RECEIVE, ERR_MAIL_DELETE_ITEM_ERROR = _G.ATTACHMENTS_MAX_RECEIVE, _G.ERR_MAIL_DELETE_ITEM_ERROR
local C_Mail_HasInboxMoney = _G.C_Mail.HasInboxMoney
local C_Mail_IsCommandPending = _G.C_Mail.IsCommandPending
local C_Timer_After = _G.C_Timer.After
local GetInboxNumItems, GetInboxHeaderInfo, GetInboxItem, GetItemInfo = _G.GetInboxNumItems, _G.GetInboxHeaderInfo, _G.GetInboxItem, _G.GetItemInfo
local GetSendMailPrice, GetMoney = _G.GetSendMailPrice, _G.GetMoney
local InboxItemCanDelete, DeleteInboxItem, TakeInboxMoney, TakeInboxItem = _G.InboxItemCanDelete, _G.DeleteInboxItem, _G.TakeInboxMoney, _G.TakeInboxItem
local NORMAL_STRING = _G.GUILDCONTROL_OPTION16
local OPENING_STRING = _G.OPEN_ALL_MAIL_BUTTON_OPENING

local mailIndex, timeToWait, totalCash, inboxItems = 0, 0.15, 0, {}
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
	bu:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -10, 5)
	bu:SetSize(16, 16)
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

	if IsAddOnLoaded("Postal") then
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
