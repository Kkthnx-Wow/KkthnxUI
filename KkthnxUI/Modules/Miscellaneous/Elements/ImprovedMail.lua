local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local wipe, select, pairs, tonumber = _G.wipe, _G.select, _G.pairs, _G.tonumber
local strsplit, strfind = _G.strsplit, _G.strfind

local ATTACHMENTS_MAX_RECEIVE, ERR_MAIL_DELETE_ITEM_ERROR = _G.ATTACHMENTS_MAX_RECEIVE, _G.ERR_MAIL_DELETE_ITEM_ERROR
local C_Mail_HasInboxMoney = _G.C_Mail.HasInboxMoney
local C_Mail_IsCommandPending = _G.C_Mail.IsCommandPending
local C_Timer_After = _G.C_Timer.After
local GetInboxNumItems, GetInboxHeaderInfo, GetInboxItem, GetItemInfo = _G.GetInboxNumItems, _G.GetInboxHeaderInfo, _G.GetInboxItem, _G.GetItemInfo
local GetSendMailPrice, GetMoney = _G.GetSendMailPrice, _G.GetMoney
local InboxItemCanDelete, DeleteInboxItem, TakeInboxMoney, TakeInboxItem = _G.InboxItemCanDelete, _G.DeleteInboxItem, _G.TakeInboxMoney, _G.TakeInboxItem
local NORMAL_STRING = _G.GUILDCONTROL_OPTION16
local OPENING_STRING = _G.OPEN_ALL_MAIL_BUTTON_OPENING

local mailIndex, timeToWait, totalCash, inboxItems = 0, .15, 0, {}
local isGoldCollecting
local contactList = {}
local contactListByRealm = {}

function Module:MailBox_DelectClick()
	local selectedID = self.id + (InboxFrame.pageNum - 1) * 7
	if InboxItemCanDelete(selectedID) then
		DeleteInboxItem(selectedID)
	else
		UIErrorsFrame:AddMessage(K.InfoColor..ERR_MAIL_DELETE_ITEM_ERROR)
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
					GameTooltip:AddDoubleLine(" |T"..itemTexture..":12:12:0:0:50:50:4:46:4:46|t "..itemName, count, r, g, b)
				end
			end
			GameTooltip:Show()
		end
	end
end

function Module:ContactButton_OnClick()
	local text = self.name:GetText() or ""
	SendMailNameEditBox:SetText(text)
	SendMailNameEditBox:SetCursorPosition(0)
end

function Module:ContactButton_Delete()
	KkthnxUIDB.Variables[K.Realm][K.Name].ContactList[self.__owner.name:GetText()] = nil
	Module:ContactList_Refresh()
end

function Module:ContactButton_Create(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(170, 20)
	button:SetPoint("TOPLEFT", 2, -2 - (index - 1) * 20)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetPoint("TOPLEFT", button ,"TOPLEFT", 0, -2)
	button.HL:SetPoint("BOTTOMRIGHT", button ,"BOTTOMRIGHT", 0, 2)
	button.HL:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
	button.HL:SetBlendMode("ADD")
	button.HL:SetAlpha(0.6)

	button.name = K.CreateFontString(button, 13, "Name", "", false, "LEFT", 0, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 155, 0)
	button.name:SetJustifyH("LEFT")

	button.name.Background = button:CreateTexture(nil)
	button.name.Background:SetPoint("TOPLEFT", button.name, "TOPLEFT", 0, 2)
	button.name.Background:SetPoint("BOTTOMRIGHT", button.name, "BOTTOMRIGHT", 14, -2)
	button.name.Background:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
	button.name.Background:SetBlendMode("ADD")
	button.name.Background:SetAlpha(0.2)

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", Module.ContactButton_OnClick)

	button.delete = CreateFrame("Button", nil, button)
	button.delete:SetSize(20, 20)
	button.delete:SetPoint("LEFT", button, "RIGHT", 2, 0)

	button.delete.Icon = button.delete:CreateTexture(nil, "ARTWORK")
	button.delete.Icon:SetAllPoints()
	button.delete.Icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
	button.delete:SetHighlightTexture(button.delete.Icon:GetTexture())
	button.delete.__owner = button
	button.delete:SetScript("OnClick", Module.ContactButton_Delete)

	return button
end

local function GenerateDataByRealm(realm)
	if contactListByRealm[realm] then
		for name, color in pairs(contactListByRealm[realm]) do
			local r, g, b = strsplit(":", color)
			table.insert(contactList, {name = name.."-"..realm, r = r, g = g, b = b})
		end
	end
end

function Module:ContactList_Refresh()
	wipe(contactList)
	wipe(contactListByRealm)

	for fullname, color in pairs(KkthnxUIDB.Variables[K.Realm][K.Name].ContactList) do
		local name, realm = strsplit("-", fullname)
		if not contactListByRealm[realm] then contactListByRealm[realm] = {} end
		contactListByRealm[realm][name] = color
	end

	GenerateDataByRealm(K.Realm)

	for realm in pairs(contactListByRealm) do
		if realm ~= K.Realm then
			GenerateDataByRealm(realm)
		end
	end

	Module:ContactList_Update()
end

function Module:ContactButton_Update(button)
	local index = button.index
	local info = contactList[index]

	button.name:SetText(info.name)
	button.name:SetTextColor(info.r, info.g, info.b)
end

function Module:ContactList_Update()
	local scrollFrame = _G.KKUI_MailBoxScrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numFriendButtons = #contactList
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numFriendButtons then
			button.index = index
			Module:ContactButton_Update(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, numFriendButtons * height, usedHeight)
end

function Module:ContactList_OnMouseWheel(delta)
	local scrollBar = self.scrollBar
	local step = delta*self.buttonHeight
	if IsShiftKeyDown() then
		step = step*18
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	Module:ContactList_Update()
end

local function updatePicker()
	local swatch = ColorPickerFrame.__swatch
	local r, g, b = ColorPickerFrame:GetColorRGB()
	swatch.tex:SetVertexColor(r, g, b)
	swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
end

local function cancelPicker()
	local swatch = ColorPickerFrame.__swatch
	local r, g, b = ColorPicker_GetPreviousValues()
	swatch.tex:SetVertexColor(r, g, b)
	swatch.color.r, swatch.color.g, swatch.color.b = r, g, b
end

local function openColorPicker(self)
	local r, g, b = self.color.r, self.color.g, self.color.b
	ColorPickerFrame.__swatch = self
	ColorPickerFrame.func = updatePicker
	ColorPickerFrame.previousValues = {r = r, g = g, b = b}
	ColorPickerFrame.cancelFunc = cancelPicker
	ColorPickerFrame:SetColorRGB(r, g, b)
	ColorPickerFrame:Show()
end

function Module:MailBox_ContactList()
	local bu = CreateFrame("Button", nil, SendMailFrame)
	bu:SetSize(24, 24)
	bu:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 20, 0)

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface\\WorldMap\\Gear_64")
	bu.Icon:SetTexCoord(0, .5, 0, .5)
	bu:SetHighlightTexture("Interface\\WorldMap\\Gear_64")
	bu:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)

	local list = CreateFrame("Frame", nil, bu, "BasicFrameTemplateWithInset")
	list:SetSize(232, 424)
	list:SetPoint("TOPLEFT", MailFrame, "TOPRIGHT", 3, 0)
	list:SetFrameStrata("Tooltip")
	K.CreateFontString(list, 14, L["ContactList"], "", "system", "TOP", 0, -5)

	bu:SetScript("OnClick", function()
		K.TogglePanel(list)
	end)

	local editbox = CreateFrame("EditBox", nil, list, "InputBoxTemplate")
	editbox:SetSize(126, 18)
	editbox:SetPoint("TOPLEFT", 14, -29)
	editbox:SetAutoFocus(false)
	editbox:SetTextInsets(5, 5, 0, 0)
	editbox:SetMaxLetters(255)
	editbox.title = L["Tips"]
	K.AddTooltip(editbox, "ANCHOR_BOTTOMRIGHT", K.InfoColor..L["AddContactTip"])

	local swatch = CreateFrame("Button", nil, editbox)
	swatch:SetSize(16, 16)
	swatch:SetPoint("LEFT", editbox, "RIGHT", 6, 0)
	K.AddTooltip(swatch, "ANCHOR_TOPRIGHT", K.SystemColor.."Contact name color")

	local color = {r = 1, g = 1, b = 1}
	swatch.texture = swatch:CreateTexture(nil, "ARTWORK")
	swatch.texture:SetAllPoints()
	swatch.texture:SetTexture("Interface\\OPTIONSFRAME\\VoiceChat-Record")
	swatch.texture:SetVertexColor(color.r, color.g, color.b)
	swatch:SetHighlightTexture("Interface\\OPTIONSFRAME\\VoiceChat-Record")

	swatch.tex = swatch.texture
	swatch.color = color
	swatch:SetScript("OnClick", openColorPicker)

	local add = CreateFrame("Button", nil, list, "UIPanelButtonTemplate")
	add:SetSize(54, 22)
	add:SetPoint("LEFT", swatch, "RIGHT", 5, 0)
	add.text = K.CreateFontString(add, 12, ADD, "", "system")
	add:SetScript("OnClick", function()
		local text = editbox:GetText()
		if text == "" or tonumber(text) then -- incorrect input
			return
		end

		if not strfind(text, "-") then -- complete player realm name (We cant send money to other realms in classic)
			text = text.."-"..K.Realm
		end

		if KkthnxUIDB.Variables[K.Realm][K.Name].ContactList[text] then -- unit exists
			return
		end

		local r, g, b = swatch.tex:GetVertexColor()
		KkthnxUIDB.Variables[K.Realm][K.Name].ContactList[text] = r..":"..g..":"..b
		Module:ContactList_Refresh()
		editbox:SetText("")
	end)

	local scrollFrame = CreateFrame("ScrollFrame", "KKUI_MailBoxScrollFrame", list, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(198, 370)
	scrollFrame:SetPoint("BOTTOMLEFT", 8, 5)
	list.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 19 + 1
	local buttonHeight = 22
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = Module:ContactButton_Create(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = Module.ContactList_Update
	scrollFrame:SetScript("OnMouseWheel", Module.ContactList_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)

	Module:ContactList_Refresh()
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

	local button = Module:MailBox_CreatButton(InboxFrame, 120, 24, "", {"LEFT", OpenAllMail, "RIGHT", 3, 0})
	button:SetScript("OnClick", Module.MailBox_CollectAllGold)
	button:SetScript("OnEnter", Module.TotalCash_OnEnter)
	button:SetScript("OnLeave", Module.TotalCash_OnLeave)

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
		UIErrorsFrame:AddMessage(K.InfoColor..L["Mail Is COD"])
		return
	end

	local currentID = InboxFrame.openMailID
	if C_Mail_HasInboxMoney(currentID) then
		TakeInboxMoney(currentID)
	end
	Module:MailBox_CollectAttachment()
end

function Module:CollectCurrentButton()
	local button = Module:MailBox_CreatButton(OpenMailFrame, 82, 22, L["Take All"], {"RIGHT", "OpenMailReplyButton", "LEFT", -1, 0})
	button:SetScript("OnClick", Module.MailBox_CollectCurrent)
end

function Module:LastMailSaver()
	local mailSaver = CreateFrame("CheckButton", nil, SendMailFrame, "OptionsCheckButtonTemplate")
	mailSaver:SetHitRectInsets(0, 0, 0, 0)
	mailSaver:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 0, 0)
	mailSaver:SetSize(24, 24)
	mailSaver:SetChecked(C["Misc"].MailSaver)
	mailSaver:SetScript("OnClick", function(self)
		C["Misc"].MailSaver = self:GetChecked()
	end)
	K.AddTooltip(mailSaver, "ANCHOR_TOP", L["Save Mail Target"])

	local resetPending
	hooksecurefunc("SendMailFrame_SendMail", function()
		if C["Misc"].MailSaver then
			C["Misc"].MailTarget = SendMailNameEditBox:GetText()
			resetPending = true
		else
			resetPending = nil
		end
	end)

	hooksecurefunc(SendMailNameEditBox, "SetText", function(self, text)
		if resetPending and text == "" then
			resetPending = nil
			self:SetText(C["Misc"].MailTarget)
		end
	end)

	SendMailFrame:HookScript("OnShow", function()
		if C["Misc"].MailSaver then
			SendMailNameEditBox:SetText(C["Misc"].MailTarget)
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

		GameTooltip:AddLine(SEND_MAIL_COST..colorStr..K.FormatMoney(sendPrice, true))
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
		local itemButton = _G["MailItem"..i.."Button"]
		Module.MailItem_AddDelete(itemButton, i)
	end

	-- Tooltips for multi-items
	hooksecurefunc("InboxFrameItem_OnEnter", Module.InboxItem_OnEnter)

	-- Custom contact list
	Module:MailBox_ContactList()

	-- Elements
	Module:ArrangeDefaultElements()
	Module:CollectGoldButton()
	Module:CollectCurrentButton()
	Module:LastMailSaver()
end