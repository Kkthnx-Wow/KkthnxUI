local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local strfind = _G.strfind
local strsplit = _G.strsplit
local tonumber = _G.tonumber
local wipe = _G.wipe

local ATTACHMENTS_MAX_RECEIVE = _G.ATTACHMENTS_MAX_RECEIVE
local C_Mail_HasInboxMoney = _G.C_Mail.HasInboxMoney
local C_Mail_IsCommandPending = _G.C_Mail.IsCommandPending
local C_Timer_After = _G.C_Timer.After
local DeleteInboxItem = _G.DeleteInboxItem
local ERR_MAIL_DELETE_ITEM_ERROR = _G.ERR_MAIL_DELETE_ITEM_ERROR
local GetInboxHeaderInfo = _G.GetInboxHeaderInfo
local GetInboxItem = _G.GetInboxItem
local GetInboxNumItems = _G.GetInboxNumItems
local GetItemInfo = _G.GetItemInfo
local InboxItemCanDelete = _G.InboxItemCanDelete
local NORMAL_STRING = _G.NORMAL_STRING
local OPENING_STRING = _G.OPENING_STRING
local TakeInboxItem = _G.TakeInboxItem
local TakeInboxMoney = _G.TakeInboxMoney

local mailIndex, timeToWait, totalCash, inboxItems = 0, .15, 0, {}
local isGoldCollecting

function Module:MailBox_DelectClick()
	local selectedID = self.id + (InboxFrame.pageNum-1)*7
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

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexCoord(unpack(K.TexCoords))
	bu.Icon:SetTexture(136813)

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

local contactList = {}

function Module:ContactButton_OnClick()
	local text = self.name:GetText() or ""
	SendMailNameEditBox:SetText(text)
end

function Module:ContactButton_Delete()
	KkthnxUIData[K.Realm][K.Name].ContactList[self.__owner.name:GetText()] = nil
	Module:ContactList_Refresh()
end

function Module:ContactButton_Create(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(150, 20)
	button:SetPoint("TOPLEFT", 2, -2 - (index - 1) * 20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(1, 1, 1, .25)

	button.name = K.CreateFontString(button, 13, "Name", "", false, "LEFT", 0, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 155, 0)
	button.name:SetJustifyH("LEFT")

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

function Module:ContactList_Refresh()
	wipe(contactList)

	local count = 0
	for name, color in pairs(KkthnxUIData[K.Realm][K.Name].ContactList) do
		count = count + 1
		local r, g, b = strsplit(":", color)
		if not contactList[count] then contactList[count] = {} end
		contactList[count].name = name
		contactList[count].r = r
		contactList[count].g = g
		contactList[count].b = b
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

	HybridScrollFrame_Update(scrollFrame, numFriendButtons*height, usedHeight)
end

function Module:ContactList_OnMouseWheel(delta)
	local scrollBar = self.scrollBar
	local step = delta * self.buttonHeight
	if IsShiftKeyDown() then
		step = step * 18
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	Module:ContactList_Update()
end

local function editBoxClearFocus(self)
	self:ClearFocus()
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
	local bars = {}
	local barIndex = 0

	local bu = CreateFrame("Button", nil, SendMailFrame)
	bu:SetSize(24, 24)
	bu:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 3, 0)

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface\\WorldMap\\Gear_64")
	bu.Icon:SetTexCoord(0, .5, 0, .5)
	bu:SetHighlightTexture("Interface\\WorldMap\\Gear_64")
	bu:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)

	local list = CreateFrame("Frame", nil, bu)
	list:SetSize(200, 424)
	list:SetPoint("LEFT", MailFrame, "RIGHT", 6, 0)
	list:SetFrameStrata("Tooltip")
	list:CreateBorder()
	K.CreateFontString(list, 14, L["ContactList"], "", "system", "TOP", 0, -5)

	bu:SetScript("OnClick", function()
		K.TogglePanel(list)
	end)

	local editbox = CreateFrame("EditBox", nil, list)
	editbox:SetSize(120, 18)
	editbox:SetPoint("TOPLEFT", 5, -25)
	editbox:SetAutoFocus(false)
	editbox:SetTextInsets(5, 5, 0, 0)
	editbox:FontTemplate(nil, nil, "")
	editbox:SetMaxLetters(255)

	editbox.bg = CreateFrame("Frame", nil, editbox, "BackdropTemplate")
	editbox.bg:SetAllPoints(editbox)
	editbox.bg:SetFrameLevel(editbox:GetFrameLevel())
	editbox.bg:CreateBorder()

	editbox.title = L["Tips"]
	K.AddTooltip(editbox, "ANCHOR_BOTTOMRIGHT", K.InfoColor..L["AddContactTip"])
	editbox:SetScript("OnEscapePressed", editBoxClearFocus)
	editbox:SetScript("OnEnterPressed", editBoxClearFocus)

	local color = {r = 1, g = 1, b = 1}

	local swatch = CreateFrame("Button", nil, editbox, "BackdropTemplate")
	swatch:SetSize(18, 18)
	swatch:SetPoint("LEFT", editbox, "RIGHT", 5, 0)
	swatch:CreateBorder()
	swatch.text = K.CreateFontString(swatch, 14, list, "", false, "LEFT", 26, 0)

	local tex = swatch:CreateTexture()
	tex:SetAllPoints()
	tex:SetTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
	tex:SetVertexColor(color.r, color.g, color.b)

	swatch.tex = tex
	swatch.color = color
	swatch:SetScript("OnClick", openColorPicker)

	local add = CreateFrame("Button", nil, list, "BackdropTemplate")
	add:SetSize(42, 18)
	add:SetPoint("LEFT", swatch, "RIGHT", 5, 0)
	add:SkinButton()
	add.text = K.CreateFontString(add, 12, ADD, "", true)
	add:SetScript("OnClick", function()
		local text = editbox:GetText()
		if text == "" or tonumber(text) then -- incorrect input
			return
		end

		if not strfind(text, "-") then -- complete player realm name
			text = text.."-"..K.Realm
		end

		if KkthnxUIData[K.Realm][K.Name].ContactList[text] then -- unit exists
			return
		end

		local r, g, b = swatch.tex:GetVertexColor()
		KkthnxUIData[K.Realm][K.Name].ContactList[text] = r..":"..g..":"..b
		Module:ContactList_Refresh()
		editbox:SetText("")
	end)

	local scrollFrame = CreateFrame("ScrollFrame", "KKUI_MailBoxScrollFrame", list, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(175, 370)
	scrollFrame:SetPoint("BOTTOMLEFT", 2, 5)
	scrollFrame:CreateBorder()
	list.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	scrollBar:SkinScrollBar()
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
	if numItems == 0 then return end

	for i = 1, numItems do
		totalCash = totalCash + select(5, GetInboxHeaderInfo(i))
	end

	if totalCash > 0 then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Total Gold")
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.FormatMoney(totalCash), 1, 1, 1)
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
	OpenAllMail:SetPoint("TOPLEFT", InboxFrame, "TOPLEFT", 66, -30)

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
		UIErrorsFrame:AddMessage(K.InfoColor.."You can't auto collect Cash on Delivery")
		return
	end

	local currentID = InboxFrame.openMailID
	if C_Mail_HasInboxMoney(currentID) then
		TakeInboxMoney(currentID)
	end
	Module:MailBox_CollectAttachment()
end

function Module:CollectCurrentButton()
	local button = Module:MailBox_CreatButton(OpenMailFrame, 82, 22, "Take all", {"RIGHT", "OpenMailReplyButton", "LEFT", -1, 0})
	button:SetScript("OnClick", Module.MailBox_CollectCurrent)
end

function Module:CreateImprovedMail()
	--if not NDuiDB["Misc"]["Mail"] then return end
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

	-- Replace the alert frame
	if InboxTooMuchMail then
		InboxTooMuchMail:ClearAllPoints()
		InboxTooMuchMail:SetPoint("BOTTOM", MailFrame, "TOP", 0, 5)
	end

	Module:CollectGoldButton()
	Module:CollectCurrentButton()
end