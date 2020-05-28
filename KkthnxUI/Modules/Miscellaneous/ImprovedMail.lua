local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local string_split = _G.string.split
local string_sub = _G.string.sub
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local DELETE = _G.DELETE
local ERR_INV_FULL = _G.ERR_INV_FULL
local ERR_ITEM_MAX_COUNT = _G.ERR_ITEM_MAX_COUNT
local ERR_MAIL_DELETE_ITEM_ERROR = _G.ERR_MAIL_DELETE_ITEM_ERROR
local GameTooltip = _G.GameTooltip
local GetInboxHeaderInfo = _G.GetInboxHeaderInfo
local GetInboxItem = _G.GetInboxItem
local GetInboxItemLink = _G.GetInboxItemLink
local GetInboxNumItems = _G.GetInboxNumItems
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local InboxTooMuchMail = _G.InboxTooMuchMail
local IsModifiedClick = _G.IsModifiedClick
local UIErrorsFrame = _G.UIErrorsFrame
local hooksecurefunc = _G.hooksecurefunc

local deletedelay = 0.5
local mailItemIndex = 0
local inboxItems = {}

local button1
local button2
local button3
local lastopened
local imOrig_InboxFrame_OnClick
local hasNewMail
local takingOnlyCash
local onlyCurrentMail
local needsToWait
local skipMail

function Module:MailItem_OnClick()
	mailItemIndex = 7 * (_G.InboxFrame.pageNum - 1) + tonumber(string_sub(self:GetName(), 9, 9))
	local modifiedClick = IsModifiedClick("MAILAUTOLOOTTOGGLE")
	if modifiedClick then
		_G.InboxFrame_OnModifiedClick(self, self.index)
	else
		_G.InboxFrame_OnClick(self, self.index)
	end
end

function Module:MailBox_OpenAll()
	if GetInboxNumItems() == 0 then
		return
	end

	button1:SetScript("OnClick", nil)
	button2:SetScript("OnClick", nil)
	button3:SetScript("OnClick", nil)
	imOrig_InboxFrame_OnClick = _G.InboxFrame_OnClick
	_G.InboxFrame_OnClick = K.Noop

	if onlyCurrentMail then
		button3:RegisterEvent("UI_ERROR_MESSAGE")
		Module.MailBox_Open(button3, mailItemIndex)
	else
		button1:RegisterEvent("UI_ERROR_MESSAGE")
		Module.MailBox_Open(button1, GetInboxNumItems())
	end
end

function Module:MailBox_Update(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if (not needsToWait) or (self.elapsed > deletedelay) then
		self.elapsed = 0
		needsToWait = false
		self:SetScript("OnUpdate", nil)

		local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(lastopened)
		if skipMail then
			Module.MailBox_Open(self, lastopened - 1)
		elseif money > 0 or (not takingOnlyCash and numItems and numItems > 0 and COD <= 0) then
			Module.MailBox_Open(self, lastopened)
		else
			Module.MailBox_Open(self, lastopened - 1)
		end
	end
end

function Module:MailBox_Open(index)
	if not _G.InboxFrame:IsVisible() or index == 0 then
		Module:MailBox_Stop()
		return
	end

	local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(index)
	if not takingOnlyCash then
		if money > 0 or (numItems and numItems > 0) and COD <= 0 then
			_G.AutoLootMailItem(index)
			needsToWait = true
		end

		if onlyCurrentMail then
			Module:MailBox_Stop()
			return
		end
	elseif money > 0 then
		_G.TakeInboxMoney(index)
		needsToWait = true
	end

	local items = GetInboxNumItems()
	if (numItems and numItems > 0) or (items > 1 and index <= items) then
		lastopened = index
		self:SetScript("OnUpdate", Module.MailBox_Update)
	else
		Module:MailBox_Stop()
	end
end

function Module:MailBox_Stop()
	button1:SetScript("OnUpdate", nil)
	button1:SetScript("OnClick", function()
		onlyCurrentMail = false
		Module:MailBox_OpenAll()
	end)

	button2:SetScript("OnClick", function()
		takingOnlyCash = true
		Module:MailBox_OpenAll()
	end)

	button3:SetScript("OnUpdate", nil)
	button3:SetScript("OnClick", function()
		onlyCurrentMail = true
		Module:MailBox_OpenAll()
	end)

	if imOrig_InboxFrame_OnClick then
		_G.InboxFrame_OnClick = imOrig_InboxFrame_OnClick
	end

	if onlyCurrentMail then
		button3:UnregisterEvent("UI_ERROR_MESSAGE")
	else
		button1:UnregisterEvent("UI_ERROR_MESSAGE")
	end

	takingOnlyCash = false
	onlyCurrentMail = false
	needsToWait = false
	skipMail = false
end

function Module:MailBox_OnEvent(event, _, msg)
	if event == "UI_ERROR_MESSAGE" then
		if msg == ERR_INV_FULL then
			Module:MailBox_Stop()
		elseif msg == ERR_ITEM_MAX_COUNT then
			skipMail = true
		end
	elseif event == "MAIL_CLOSED" then
		if not hasNewMail then
			_G.MiniMapMailFrame:Hide()
		end
		Module:MailBox_Stop()
	end
end

function Module:TotalCash_OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	local total_cash = 0
	for index = 0, GetInboxNumItems() do
		total_cash = total_cash + select(5, GetInboxHeaderInfo(index))
	end

	if total_cash > 0 then
		_G.SetTooltipMoney(GameTooltip, total_cash)
	end
	GameTooltip:Show()
end

function Module:MailBox_DelectClick()
	local selectedID = self.id + (_G.InboxFrame.pageNum - 1) * 7
	if _G.InboxItemCanDelete(selectedID) then
		_G.DeleteInboxItem(selectedID)
	else
		UIErrorsFrame:AddMessage("|cff99ccff"..ERR_MAIL_DELETE_ITEM_ERROR)
	end
end

function Module:MailItem_AddDelete(i)
	local bu = CreateFrame("Button", nil, self)
	bu:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -10, 5)
	bu:SetSize(16, 16)

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture(136813)
	bu.Icon:SetTexCoord(unpack(K.TexCoords))

	bu.id = i
	bu:SetScript("OnClick", Module.MailBox_DelectClick)
	K.AddTooltip(bu, "ANCHOR_RIGHT", DELETE, "system")
end

function Module:CreatButton(parent, text, w, h, ap, frame, rp, x, y)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetWidth(w)
	button:SetHeight(h)
	button:SetPoint(ap, frame, rp, x, y)
	button:SetText(text)

	return button
end

function Module:InboxFrame_Hook()
	hasNewMail = false
	if select(4, GetInboxHeaderInfo(1)) then
		for i = 1, GetInboxNumItems() do
			local wasRead = select(9, GetInboxHeaderInfo(i))
			if not wasRead then
				hasNewMail = true
				break
			end
		end
	end
end

function Module:InboxItem_OnEnter()
	table_wipe(inboxItems)

	local itemAttached = select(8, GetInboxHeaderInfo(self.index))
	if itemAttached then
		for attachID = 1, 12 do
			local _, _, _, itemCount = GetInboxItem(self.index, attachID)
			if itemCount and itemCount > 0 then
				local _, itemid = string_split(":", GetInboxItemLink(self.index, attachID))
				itemid = tonumber(itemid)
				inboxItems[itemid] = (inboxItems[itemid] or 0) + itemCount
			end
		end

		if itemAttached > 1 then
			GameTooltip:AddLine(L["Attach List"])
			for key, value in pairs(inboxItems) do
				local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(key)
				if itemName then
					local r, g, b = GetItemQualityColor(itemQuality)
					GameTooltip:AddDoubleLine(" |T"..itemTexture..":12:12:0:0:50:50:4:46:4:46|t "..itemName, value, r, g, b)
				end
			end
			GameTooltip:Show()
		end
	end
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

local function editBoxClearFocus(self)
	self:ClearFocus()
end

function Module:MailBox_ContactList()
	local bars = {}
	local barIndex = 0

	local bu = CreateFrame("Button", nil, SendMailFrame)
	bu:SetSize(22, 22)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface\\WorldMap\\Gear_64")
	bu.Icon:SetTexCoord(0, .5, 0, .5)
	bu:SetHighlightTexture("Interface\\WorldMap\\Gear_64")
	bu:GetHighlightTexture():SetTexCoord(0, .5, 0, .5)
	bu:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 3, 0)

	local list = CreateFrame("Frame", nil, bu)
	list:SetSize(204, 418)
	list:SetPoint("TOPLEFT", MailFrame, "TOPRIGHT", 5, -2)
	list:SetFrameStrata("Tooltip")
	list:CreateBorder()
	K.CreateFontString(list, 12, "Contact List", "", "system", "TOP", 0, -5)

	local editbox = CreateFrame("EditBox", nil, list)
	editbox:SetSize(120, 20)
	editbox:SetAutoFocus(false)
	editbox:SetTextInsets(5, 5, 0, 0)
	editbox:FontTemplate()
	editbox:CreateBorder()
	editbox:SetScript("OnEscapePressed", editBoxClearFocus)
	editbox:SetScript("OnEnterPressed", editBoxClearFocus)
	editbox:SetPoint("TOPLEFT", 5, -22)

	local swatch = CreateFrame("Button", nil, list)
	swatch:SetSize(20, 20)
	swatch.text = K.CreateFontString(swatch, 14, list, "", false, "LEFT", 26, 0)
	swatch:CreateBorder()
	swatch:CreateInnerShadow()

	local tex = swatch:CreateTexture()
	tex:SetAllPoints()
	tex:SetTexture(C["Media"].Texture)
	tex:SetVertexColor(1, 1, 1, 1)
	swatch.tex = tex
	swatch.color = {r = 1, g = 1, b = 1}
	swatch:SetScript("OnClick", openColorPicker)
	swatch:SetPoint("LEFT", editbox, "RIGHT", 6, 0)

	local function sortBars()
		local index = 0
		for _, bar in pairs(bars) do
			if bar:IsShown() then
				bar:SetPoint("TOPLEFT", list, 5, -50 - index*22)
				index = index + 1
			end
		end
	end

	local function buttonOnClick(self)
		local text = self.name:GetText() or ""
		SendMailNameEditBox:SetText(text)
	end

	local function deleteOnClick(self)
		KkthnxUIData[K.Realm][K.Name].ContactList[self.__owner.name:GetText()] = nil
		self.__owner:Hide()
		sortBars()
		barIndex = barIndex - 1
	end

	local function createContactBar(text, r, g, b)
		local button = CreateFrame("Button", nil, list)
		button:SetSize(164, 20)
		button.HL = button:CreateTexture(nil, "HIGHLIGHT")
		button.HL:SetAllPoints()
		button.HL:SetColorTexture(1, 1, 1, .25)

		button.name = K.CreateFontString(button, 13, text, "", false, "LEFT", 10, 0)
		button.name:SetPoint("RIGHT", button, "LEFT", 230, 0)
		button.name:SetJustifyH("LEFT")
		button.name:SetTextColor(r, g, b)

		button:RegisterForClicks("AnyUp")
		button:SetScript("OnClick", buttonOnClick)

		button.delete = CreateFrame("Button", nil, button)
		button.delete:SetWidth(18)
		button.delete:SetHeight(18)

		button.delete.Icon = button.delete:CreateTexture(nil, "ARTWORK")
		button.delete.Icon:SetAllPoints()
		button.delete.Icon:SetTexture("Interface\\RAIDFRAME\\ReadyCheck-NotReady")
		button.delete.Icon:SetTexCoord(unpack(K.TexCoords))

		button.delete:SetPoint("LEFT", button, "RIGHT", 5, 0)
		button.delete.__owner = button
		button.delete:SetScript("OnClick", deleteOnClick)

		return button
	end

	local function createBar(text, r, g, b)
		if barIndex < 17 then
			barIndex = barIndex + 1
		end
		for i = 1, barIndex do
			if not bars[i] then
				bars[i] = createContactBar(text, r, g, b)
			end
			if not bars[i]:IsShown() then
				bars[i]:Show()
				bars[i].name:SetText(text)
				bars[i].name:SetTextColor(r, g, b)
				break
			end
		end
	end

	bu:SetScript("OnClick", function()
		K.TogglePanel(list)
	end)

	local add = CreateFrame("Button", nil, list)
	add:SetSize(42, 20)
	add:SetPoint("LEFT", swatch, "RIGHT", 6, 0)
	add:SkinButton()
	add.name = K.CreateFontString(add, 13, ADD, "", "system", "CENTER", 0, -1)
	add:SetScript("OnClick", function()
		local text = editbox:GetText()
		if text == "" or tonumber(text) then -- incorrect input
			return
		end

		if not strfind(text, "-") then -- complete player realm name
			text = text.."-"..K.Realm
		end

		local r, g, b = swatch.tex:GetVertexColor()
		KkthnxUIData[K.Realm][K.Name].ContactList[text] = r..":"..g..":"..b
		createBar(text, r, g, b)
		sortBars()
		editbox:SetText("")
	end)

	for name, color in pairs(KkthnxUIData[K.Realm][K.Name].ContactList) do
		if color then
			local r, g, b = strsplit(":", color)
			r, g, b = tonumber(r), tonumber(g), tonumber(b)
			createBar(name, r, g, b)
		end
	end

	sortBars()
end

function Module:CreateMailBox()
	for i = 1, 7 do
		local itemButton = _G["MailItem"..i.."Button"]
		itemButton:SetScript("OnClick", Module.MailItem_OnClick)
		Module.MailItem_AddDelete(itemButton, i)
	end

	button1 = Module:CreatButton(_G.InboxFrame, L["Collect All"], 100, 22, "TOPLEFT", "InboxFrame", "TOPLEFT", 82, -30)
	button1:RegisterEvent("MAIL_CLOSED")
	button1:SetScript("OnClick", Module.MailBox_OpenAll)
	button1:SetScript("OnEvent", Module.MailBox_OnEvent)

	button2 = Module:CreatButton(_G.InboxFrame, L["Collect Gold"], 100, 22, "TOPRIGHT", "InboxFrame", "TOPRIGHT", -82, -30)
	button2:SetScript("OnClick", function()
		takingOnlyCash = true
		Module:MailBox_OpenAll()
	end)
	button2:SetScript("OnEnter", Module.TotalCash_OnEnter)
	button2:SetScript("OnLeave", K.HideTooltip)

	button3 = Module:CreatButton(_G.OpenMailFrame, L["Collect Letters"], 82, 22, "RIGHT", "OpenMailReplyButton", "LEFT", 0, 0)
	button3:SetScript("OnClick", function()
		onlyCurrentMail = true
		Module:MailBox_OpenAll()
	end)
	button3:SetScript("OnEvent", Module.MailBox_OnEvent)

	hooksecurefunc("InboxFrame_Update", Module.InboxFrame_Hook)
	hooksecurefunc("InboxFrameItem_OnEnter", Module.InboxItem_OnEnter)

	Module:MailBox_ContactList()

	-- Replace the alert frame
	if InboxTooMuchMail then
		InboxTooMuchMail:ClearAllPoints()
		InboxTooMuchMail:SetPoint("BOTTOM", _G.MailFrame, "TOP", 0, 5)
	end

	-- Hide Blizz
	_G.OpenAllMail:Kill()
end

function Module:CreateImprovedMail()
	if K.CheckAddOnState("Postal") then
		return
	end

	self:CreateMailBox()
end