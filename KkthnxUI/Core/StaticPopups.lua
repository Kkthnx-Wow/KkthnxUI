local K, _, L = unpack(select(2, ...))

local _G = _G
local assert = assert
local pairs = pairs
local print = print
local table_contains = tContains
local table_insert = table.insert
local table_remove = table.remove
local table_wipe = table.wipe
local type = type
local unpack = unpack

local ACCEPT = _G.ACCEPT
local AutoCompleteEditBox_OnEnterPressed = _G.AutoCompleteEditBox_OnEnterPressed
local AutoCompleteEditBox_OnTextChanged = _G.AutoCompleteEditBox_OnTextChanged
local CANCEL = _G.CANCEL
local CreateFrame = _G.CreateFrame
local DisableAddOn = _G.DisableAddOn
local EnableAddOn = _G.EnableAddOn
local GetBankSlotCost = _G.GetBankSlotCost
local GetBindingFromClick = _G.GetBindingFromClick
local GetRealmName = _G.GetRealmName
local InCinematic = _G.InCinematic
local MoneyFrame_Update = _G.MoneyFrame_Update
local PlaySound = _G.PlaySound
local PurchaseSlot = _G.PurchaseSlot
local ReloadUI = _G.ReloadUI
local RestartGx = _G.RestartGx
local RunBinding = _G.RunBinding
local SOUNDKIT = _G.SOUNDKIT
local StaticPopup_Resize = _G.StaticPopup_Resize
local STATICPOPUP_TEXTURE_ALERT = _G.STATICPOPUP_TEXTURE_ALERT
local STATICPOPUP_TEXTURE_ALERTGEAR = _G.STATICPOPUP_TEXTURE_ALERTGEAR
local UIParent = _G.UIParent
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitName = _G.UnitName

local Name = UnitName("player")
local Realm = GetRealmName()

K.PopupDialogs = {}
K.StaticPopup_DisplayedFrames = {}

K.PopupDialogs["FRIENDS_BROADCAST"] = {
	text = BN_BROADCAST_TOOLTIP,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		local Parent = self:GetParent()

		BNSetCustomMessage(Parent.EditBox:GetText())
	end,
	hasEditBox = true,
}

K.PopupDialogs["QUEST_CHECK_ID"] = {
	text = "Check Quest ID",
	button1 = "Scan",

	OnAccept = function(self)
		if not tonumber(self.editBox:GetText()) then
			return
		end

		K.CheckQuestStatus(self.editBox:GetText())
	end,

	OnShow = function(self, ...)
		self.editBox:SetFocus()
	end,

	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,

	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,

	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	editBoxWidth = 200,
	hideOnEscape = false,
	preferredIndex = 3,
}

K.PopupDialogs["GITHUB_EDITBOX"] = {
	text = format("|cff669dff%s |r", "KkthnxUI GitHub"),
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:SetWidth(280)
		self.editBox:AddHistoryLine("text")
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.editBox:SetWidth(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= self.temptxt) then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end,
	OnAccept = K.Noop,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

K.PopupDialogs["DISCORD_EDITBOX"] = {
	text = format("|cff669dff%s |r", "KkthnxUI Discord"),
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:SetWidth(280)
		self.editBox:AddHistoryLine("text")
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.editBox:SetWidth(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= self.temptxt) then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end,
	OnAccept = K.Noop,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

K.PopupDialogs["CHANGES_RL"] = {
	text = L["Changes Reload"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

K.PopupDialogs["RESTART_GFX"] = {
	text = L["Restart Graphics"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		RestartGx()
	end,
	OnCancel = function()
		print(CANCEL)
	end,
	hideOnEscape = true,
	whileDead = 1,
}

K.PopupDialogs["DISBAND_RAID"] = {
	text = L["Disband Group"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		K.DisbandRaidGroup()
	end,
	OnCancel = function()
		print(CANCEL)
	end,
	hideOnEscape = true,
	whileDead = 1,
}

K.PopupDialogs["CANNOT_BUY_BANK_SLOT"] = {
	text = L["Can't Buy Slot"],
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,
}

K.PopupDialogs["BUY_BANK_SLOT"] = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = PurchaseSlot,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetBankSlotCost())
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,
}

K.PopupDialogs["CONFIRM_LOOT_DISTRIBUTION"] = {
	text = CONFIRM_LOOT_DISTRIBUTION,
	button1 = YES,
	button2 = NO,
	timeout = 0,
	hideOnEscape = 1,
	preferredIndex = 3,
}

K.PopupDialogs["DISABLE_UI"] = {
	text = "DISABLE_UI",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		DisableAddOn("KkthnxUI")
		ReloadUI()
	end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

K.PopupDialogs["RESET_UI"] = {
	text = L["Reset KkthnxUI"],
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		K.Install:Launch()
		if UIConfig and UIConfig:IsShown() then
			UIConfigMain:Hide()
		end
	end,
	OnCancel = function()
		KkthnxUIData[Realm][Name].InstallComplete = true
	end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

K.PopupDialogs["WARNING_BLIZZARD_ADDONS"] = {
	text = L["Warning Blizzard AddOns"],
	button1 = OKAY,
	OnAccept = function()
		EnableAddOn("Blizzard_CompactRaidFrames")
		ReloadUI()
	end,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

K.PopupDialogs["KKTHNXUI_OUTDATED"] = {
	text = L["KkthnxUI Outdated"],
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	editBoxWidth = 325,
	OnShow = function(self)
		self.editBox:SetFocus()
		self.editBox:SetText("https://github.com/kkthnx-wow/KkthnxUI_8.0.1")
		self.editBox:HighlightText()
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
}


local MAX_STATIC_POPUPS = 4
function K.StaticPopup_OnShow(self)
	PlaySound(PlaySoundKitID and "igmainmenuopen" or SOUNDKIT.IG_MAINMENU_OPEN)

	local dialog = K.PopupDialogs[self.which]
	local OnShow = dialog.OnShow

	if (OnShow) then
		OnShow(self, self.data)
	end
	if (dialog.hasMoneyInputFrame) then
		_G[self:GetName().."MoneyInputFrameGold"]:SetFocus()
	end
	if (dialog.enterClicksFirstButton) then
		self:SetScript("OnKeyDown", K.StaticPopup_OnKeyDown)
	end
end

function K.StaticPopup_EscapePressed()
	local closed = nil
	for _, frame in pairs(K.StaticPopup_DisplayedFrames) do
		if(frame:IsShown() and frame.hideOnEscape) then
			local standardDialog = K.PopupDialogs[frame.which]
			if (standardDialog) then
				local OnCancel = standardDialog.OnCancel
				local noCancelOnEscape = standardDialog.noCancelOnEscape
				if (OnCancel and not noCancelOnEscape) then
					OnCancel(frame, frame.data, "clicked")
				end
				frame:Hide()
			else
				K.StaticPopupSpecial_Hide(frame)
			end
			closed = 1
		end
	end
	return closed
end

function K.StaticPopupSpecial_Hide(frame)
	frame:Hide()
	K.StaticPopup_CollapseTable()
end

function K.StaticPopup_CollapseTable()
	local displayedFrames = K.StaticPopup_DisplayedFrames
	local index = #displayedFrames
	while ((index >= 1) and (not displayedFrames[index]:IsShown())) do
		table_remove(displayedFrames, index)
		index = index - 1
	end
end

function K.StaticPopup_SetUpPosition(_, dialog)
	if (not table_contains(K.StaticPopup_DisplayedFrames, dialog)) then
		local lastFrame = K.StaticPopup_DisplayedFrames[#K.StaticPopup_DisplayedFrames]
		if (lastFrame) then
			dialog:SetPoint("TOP", lastFrame, "BOTTOM", 0, -4)
		else
			dialog:SetPoint("TOP", UIParent, "TOP", 0, -100)
		end
		table_insert(K.StaticPopup_DisplayedFrames, dialog)
	end
end

function K.StaticPopupSpecial_Show(frame)
	if (frame.exclusive) then
		K.StaticPopup_HideExclusive()
	end

	K.StaticPopup_SetUpPosition(frame)
	frame:Show()
end

function K.StaticPopupSpecial_Hide(frame)
	frame:Hide()
	K.StaticPopup_CollapseTable()
end

--Used to figure out if we can resize a frame
function K.StaticPopup_IsLastDisplayedFrame(frame)
	for i = #K.StaticPopup_DisplayedFrames, 1, -1 do
		local popup = K.StaticPopup_DisplayedFrames[i]
		if (popup:IsShown()) then
			return frame == popup
		end
	end
	return false
end

function K.StaticPopup_OnKeyDown(self, key)
	if (GetBindingFromClick(key) == "TOGGLEGAMEMENU") then
		return K.StaticPopup_EscapePressed()
	elseif (GetBindingFromClick(key) == "SCREENSHOT") then
		RunBinding("SCREENSHOT")
		return
	end

	local dialog = K.PopupDialogs[self.which]
	if (dialog) then
		if (key == "ENTER" and dialog.enterClicksFirstButton) then
			local frameName = self:GetName()
			local button
			local i = 1
			while (true) do
				button = _G[frameName.."Button"..i]
				if (button) then
					if (button:IsShown()) then
						K.StaticPopup_OnClick(self, i)
						return
					end
					i = i + 1
				else
					break
				end
			end
		end
	end
end

function K.StaticPopup_OnHide(self)
	PlaySound(PlaySoundKitID and "igmainmenuclose" or SOUNDKIT.IG_MAINMENU_CLOSE)

	K.StaticPopup_CollapseTable()

	local dialog = K.PopupDialogs[self.which]
	local OnHide = dialog.OnHide
	if (OnHide) then
		OnHide(self, self.data)
	end
	self.extraFrame:Hide()
	if (dialog.enterClicksFirstButton) then
		self:SetScript("OnKeyDown", nil)
	end
end

function K.StaticPopup_OnUpdate(self, elapsed)
	if (self.timeleft and self.timeleft > 0) then
		local which = self.which
		local timeleft = self.timeleft - elapsed
		if (timeleft <= 0) then
			if (not K.PopupDialogs[which].timeoutInformationalOnly) then
				self.timeleft = 0
				local OnCancel = K.PopupDialogs[which].OnCancel
				if (OnCancel) then
					OnCancel(self, self.data, "timeout")
				end
				self:Hide()
			end
			return
		end
		self.timeleft = timeleft
	end

	if (self.startDelay) then
		local which = self.which
		local timeleft = self.startDelay - elapsed
		if (timeleft <= 0) then
			self.startDelay = nil
			local text = _G[self:GetName().."Text"]
			text:SetFormattedText(K.PopupDialogs[which].text, text.text_arg1, text.text_arg2)
			local button1 = _G[self:GetName().."Button1"]
			button1:Enable()
			StaticPopup_Resize(self, which)
			return
		end
		self.startDelay = timeleft
	end

	local onUpdate = K.PopupDialogs[self.which].OnUpdate
	if (onUpdate) then
		onUpdate(self, elapsed)
	end
end

function K.StaticPopup_OnClick(self, index)
	if (not self:IsShown()) then
		return
	end
	local which = self.which
	local info = K.PopupDialogs[which]
	if (not info) then
		return nil
	end
	local hide = true
	if (index == 1) then
		local OnAccept = info.OnAccept
		if (OnAccept) then
			hide = not OnAccept(self, self.data, self.data2)
		end
	elseif (index == 3) then
		local OnAlt = info.OnAlt
		if (OnAlt) then
			OnAlt(self, self.data, "clicked")
		end
	else
		local OnCancel = info.OnCancel
		if (OnCancel) then
			hide = not OnCancel(self, self.data, "clicked")
		end
	end

	if (hide and (which == self.which)) then
		-- can self.which change inside one of the On* functions???
		self:Hide()
	end
end

function K.StaticPopup_EditBoxOnEnterPressed(self)
	local EditBoxOnEnterPressed, which, dialog
	local parent = self:GetParent()
	if (parent.which) then
		which = parent.which
		dialog = parent
	elseif (parent:GetParent().which) then
		-- This is needed if this is a money input frame since it"s nested deeper than a normal edit box
		which = parent:GetParent().which
		dialog = parent:GetParent()
	end
	if (not self.autoCompleteParams or not AutoCompleteEditBox_OnEnterPressed(self)) then
		EditBoxOnEnterPressed = K.PopupDialogs[which].EditBoxOnEnterPressed
		if (EditBoxOnEnterPressed) then
			EditBoxOnEnterPressed(self, dialog.data)
		end
	end
end

function K.StaticPopup_EditBoxOnEscapePressed(self)
	local EditBoxOnEscapePressed = K.PopupDialogs[self:GetParent().which].EditBoxOnEscapePressed
	if (EditBoxOnEscapePressed) then
		EditBoxOnEscapePressed(self, self:GetParent().data)
	end
end

function K.StaticPopup_EditBoxOnTextChanged(self, userInput)
	if (not self.autoCompleteParams or not AutoCompleteEditBox_OnTextChanged(self, userInput)) then
		local EditBoxOnTextChanged = K.PopupDialogs[self:GetParent().which].EditBoxOnTextChanged
		if (EditBoxOnTextChanged) then
			EditBoxOnTextChanged(self, self:GetParent().data)
		end
	end
end

function K.StaticPopup_FindVisible(which, data)
	local info = K.PopupDialogs[which]
	if (not info) then
		return nil
	end
	for index = 1, MAX_STATIC_POPUPS, 1 do
		local frame = _G["KkthnxUI_StaticPopup"..index]
		if (frame:IsShown() and (frame.which == which) and (not info.multiple or (frame.data == data))) then
			return frame
		end
	end
	return nil
end

function K.StaticPopup_Resize(dialog, which)
	local info = K.PopupDialogs[which]
	if (not info) then
		return nil
	end

	local text = _G[dialog:GetName().."Text"]
	local editBox = _G[dialog:GetName().."EditBox"]
	local button1 = _G[dialog:GetName().."Button1"]

	local maxHeightSoFar, maxWidthSoFar = (dialog.maxHeightSoFar or 0), (dialog.maxWidthSoFar or 0)
	local width = 320

	if (dialog.numButtons == 3) then
		width = 440
	elseif (info.showAlert or info.showAlertGear or info.closeButton) then
		-- Widen
		width = 420
	elseif (info.editBoxWidth and info.editBoxWidth > 260) then
		width = width + (info.editBoxWidth - 260)
	end

	if (width > maxWidthSoFar) then
		dialog:SetWidth(width)
		dialog.maxWidthSoFar = width
	end

	local height = 32 + text:GetHeight() + 8 + button1:GetHeight()
	if (info.hasEditBox) then
		height = height + 8 + editBox:GetHeight()
	elseif (info.hasMoneyFrame) then
		height = height + 16
	elseif (info.hasMoneyInputFrame) then
		height = height + 22
	end
	if (info.hasItemFrame) then
		height = height + 64
	end

	if (height > maxHeightSoFar) then
		dialog:SetHeight(height)
		dialog.maxHeightSoFar = height
	end
end

function K.StaticPopup_OnEvent(self)
	self.maxHeightSoFar = 0
	K.StaticPopup_Resize(self, self.which)
end

local tempButtonLocs = {}	-- So we don"t make a new table each time.
function K.StaticPopup_Show(which, text_arg1, text_arg2, data)
	local info = K.PopupDialogs[which]
	if (not info) then
		return nil
	end

	if (UnitIsDeadOrGhost("player") and not info.whileDead) then
		if (info.OnCancel) then
			info.OnCancel()
		end
		return nil
	end

	if (InCinematic() and not info.interruptCinematic) then
		if (info.OnCancel) then
			info.OnCancel()
		end
		return nil
	end

	if (info.cancels) then
		for index = 1, MAX_STATIC_POPUPS, 1 do
			local frame = _G["KkthnxUI_StaticPopup"..index]
			if (frame:IsShown() and (frame.which == info.cancels)) then
				frame:Hide()
				local OnCancel = K.PopupDialogs[frame.which].OnCancel
				if (OnCancel) then
					OnCancel(frame, frame.data, "override")
				end
			end
		end
	end

	-- Pick a free dialog to use, find an open dialog of the requested type
	local dialog = K.StaticPopup_FindVisible(which, data)
	if (dialog) then
		if (not info.noCancelOnReuse) then
			local OnCancel = info.OnCancel
			if (OnCancel) then
				OnCancel(dialog, dialog.data, "override")
			end
		end
		dialog:Hide()
	end
	if (not dialog) then
		-- Find a free dialog
		local index = 1
		if (info.preferredIndex) then
			index = info.preferredIndex
		end
		for i = index, MAX_STATIC_POPUPS do
			local frame = _G["KkthnxUI_StaticPopup"..i]
			if (not frame:IsShown()) then
				dialog = frame
				break
			end
		end

		-- If dialog not found and there"s a preferredIndex then try to find an available frame before the preferredIndex
			if (not dialog and info.preferredIndex) then
				for i = 1, info.preferredIndex do
					local frame = _G["KkthnxUI_StaticPopup"..i]
					if (not frame:IsShown()) then
						dialog = frame
						break
					end
				end
			end
		end
		if (not dialog) then
			if (info.OnCancel) then
				info.OnCancel()
			end
			return nil
		end

		dialog.maxHeightSoFar, dialog.maxWidthSoFar = 0, 0
		-- Set the text of the dialog
		local text = _G[dialog:GetName().."Text"]
		text:SetFormattedText(info.text, text_arg1, text_arg2)

		-- Show or hide the close button
		if (info.closeButton) then
			local closeButton = _G[dialog:GetName().."CloseButton"]
			if (info.closeButtonIsHide) then
				closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-HideButton-Up")
				closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-HideButton-Down")
			else
				closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
				closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
			end
			closeButton:Show()
		else
			_G[dialog:GetName().."CloseButton"]:Hide()
		end

		-- Set the editbox of the dialog
		local editBox = _G[dialog:GetName().."EditBox"]
		if (info.hasEditBox) then
			editBox:Show()

			if (info.maxLetters) then
				editBox:SetMaxLetters(info.maxLetters)
				editBox:SetCountInvisibleLetters(info.countInvisibleLetters)
			end
			if (info.maxBytes) then
				editBox:SetMaxBytes(info.maxBytes)
			end
			editBox:SetText("")
			if (info.editBoxWidth) then
				editBox:SetWidth(info.editBoxWidth)
			else
				editBox:SetWidth(130)
			end
		else
			editBox:Hide()
		end

		-- Show or hide money frame
		if (info.hasMoneyFrame) then
			_G[dialog:GetName().."MoneyFrame"]:Show()
			_G[dialog:GetName().."MoneyInputFrame"]:Hide()
		elseif (info.hasMoneyInputFrame) then
			local moneyInputFrame = _G[dialog:GetName().."MoneyInputFrame"]
			moneyInputFrame:Show()
			_G[dialog:GetName().."MoneyFrame"]:Hide()
			-- Set OnEnterPress for money input frames
			if (info.EditBoxOnEnterPressed) then
				moneyInputFrame.gold:SetScript("OnEnterPressed", K.StaticPopup_EditBoxOnEnterPressed)
				moneyInputFrame.silver:SetScript("OnEnterPressed", K.StaticPopup_EditBoxOnEnterPressed)
				moneyInputFrame.copper:SetScript("OnEnterPressed", K.StaticPopup_EditBoxOnEnterPressed)
			else
				moneyInputFrame.gold:SetScript("OnEnterPressed", nil)
				moneyInputFrame.silver:SetScript("OnEnterPressed", nil)
				moneyInputFrame.copper:SetScript("OnEnterPressed", nil)
			end
		else
			_G[dialog:GetName().."MoneyFrame"]:Hide()
			_G[dialog:GetName().."MoneyInputFrame"]:Hide()
		end

		-- Show or hide item button
		if (info.hasItemFrame) then
			_G[dialog:GetName().."ItemFrame"]:Show()
			if (data and type(data) == "table") then
				_G[dialog:GetName().."ItemFrame"].link = data.link
				_G[dialog:GetName().."ItemFrameIconTexture"]:SetTexture(data.texture)
				local nameText = _G[dialog:GetName().."ItemFrameText"]
				nameText:SetTextColor(unpack(data.color or {1, 1, 1, 1}))
				nameText:SetText(data.name)
				if (data.count and data.count > 1) then
					_G[dialog:GetName().."ItemFrameCount"]:SetText(data.count)
					_G[dialog:GetName().."ItemFrameCount"]:Show()
				else
					_G[dialog:GetName().."ItemFrameCount"]:Hide()
				end
			end
		else
			_G[dialog:GetName().."ItemFrame"]:Hide()
		end

		-- Set the miscellaneous variables for the dialog
		dialog.which = which
		dialog.timeleft = info.timeout
		dialog.hideOnEscape = info.hideOnEscape
		dialog.exclusive = info.exclusive
		dialog.enterClicksFirstButton = info.enterClicksFirstButton
		-- Clear out data
		dialog.data = data

		-- Set the buttons of the dialog
		local button1 = _G[dialog:GetName().."Button1"]
		local button2 = _G[dialog:GetName().."Button2"]
		local button3 = _G[dialog:GetName().."Button3"]

		do	-- If there is any recursion in this block, we may get errors (tempButtonLocs is static). If you have to recurse, we"ll have to create a new table each time.
		assert(#tempButtonLocs == 0)	-- If this fails, we"re recursing. (See the table.wipe at the end of the block)

		table_insert(tempButtonLocs, button1)
		table_insert(tempButtonLocs, button2)
		table_insert(tempButtonLocs, button3)

		for i = #tempButtonLocs, 1, -1 do
			--Do this stuff before we move it. (This is why we go back-to-front)
			tempButtonLocs[i]:SetText(info["button"..i])
			tempButtonLocs[i]:Hide()
			tempButtonLocs[i]:ClearAllPoints()
			--Now we possibly remove it.
			if (not (info["button"..i] and (not info["DisplayButton"..i] or info["DisplayButton"..i](dialog)))) then
				table_remove(tempButtonLocs, i)
			end
		end

		local numButtons = #tempButtonLocs
		--Save off the number of buttons.
		dialog.numButtons = numButtons

		if (numButtons == 3) then
			tempButtonLocs[1]:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -72, 16)
		elseif (numButtons == 2) then
			tempButtonLocs[1]:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -6, 16)
		elseif (numButtons == 1) then
			tempButtonLocs[1]:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 16)
		end

		for i = 1, numButtons do
			if (i > 1) then
				tempButtonLocs[i]:SetPoint("LEFT", tempButtonLocs[i-1], "RIGHT", 13, 0)
			end

			local width = tempButtonLocs[i]:GetTextWidth()
			if (width > 110) then
				tempButtonLocs[i]:SetWidth(width + 20)
			else
				tempButtonLocs[i]:SetWidth(120)
			end
			tempButtonLocs[i]:Enable()
			tempButtonLocs[i]:Show()
		end

		table_wipe(tempButtonLocs)
	end

	-- Show or hide the alert icon
	local alertIcon = _G[dialog:GetName().."AlertIcon"]
	if (info.showAlert) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT)
		if (button3:IsShown())then
			alertIcon:SetPoint("LEFT", 24, 10)
		else
			alertIcon:SetPoint("LEFT", 24, 0)
		end
		alertIcon:Show()
	elseif (info.showAlertGear) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERTGEAR)
		if (button3:IsShown())then
			alertIcon:SetPoint("LEFT", 24, 0)
		else
			alertIcon:SetPoint("LEFT", 24, 0)
		end
		alertIcon:Show()
	else
		alertIcon:SetTexture()
		alertIcon:Hide()
	end

	if (info.StartDelay) then
		dialog.startDelay = info.StartDelay()
		button1:Disable()
	else
		dialog.startDelay = nil
		button1:Enable()
	end

	editBox.autoCompleteParams = info.autoCompleteParams
	editBox.autoCompleteRegex = info.autoCompleteRegex
	editBox.autoCompleteFormatRegex = info.autoCompleteFormatRegex

	editBox.addHighlightedText = true

	-- Finally size and show the dialog
	K.StaticPopup_SetUpPosition(_, dialog)
	dialog:Show()

	K.StaticPopup_Resize(dialog, which)

	if (info.sound) then
		PlaySound(info.sound)
	end

	return dialog
end

function K.StaticPopup_Hide(which, data)
	for index = 1, MAX_STATIC_POPUPS, 1 do
		local dialog = _G["KkthnxUI_StaticPopup"..index]
		if ((dialog.which == which) and (not data or (data == dialog.data))) then
			dialog:Hide()
		end
	end
end

function K.CreateStaticPopups()
	K.StaticPopupFrames = {}

	for index = 1, MAX_STATIC_POPUPS do
		K.StaticPopupFrames[index] = CreateFrame("Frame", "KkthnxUI_StaticPopup"..index, UIParent, "StaticPopupTemplate")
		K.StaticPopupFrames[index]:SetID(index)

		-- Fix Scripts
		K.StaticPopupFrames[index]:SetScript("OnShow", K.StaticPopup_OnShow)
		K.StaticPopupFrames[index]:SetScript("OnHide", K.StaticPopup_OnHide)
		K.StaticPopupFrames[index]:SetScript("OnUpdate", K.StaticPopup_OnUpdate)
		K.StaticPopupFrames[index]:SetScript("OnEvent", K.StaticPopup_OnEvent)

		for i = 1, 3 do
			_G["KkthnxUI_StaticPopup"..index.."Button"..i]:SetScript("OnClick", function(self)
				K.StaticPopup_OnClick(self:GetParent(), self:GetID())
			end)
		end

		_G["KkthnxUI_StaticPopup"..index.."EditBox"]:SetScript("OnEnterPressed", K.StaticPopup_EditBoxOnEnterPressed)
		_G["KkthnxUI_StaticPopup"..index.."EditBox"]:SetScript("OnEscapePressed", K.StaticPopup_EditBoxOnEscapePressed)
		_G["KkthnxUI_StaticPopup"..index.."EditBox"]:SetScript("OnTextChanged", K.StaticPopup_EditBoxOnTextChanged)
	end

	hooksecurefunc("StaticPopup_SetUpPosition", function(self)
		K.StaticPopup_SetUpPosition(_, self)
	end)
	hooksecurefunc("StaticPopup_CollapseTable", K.StaticPopup_CollapseTable)
end