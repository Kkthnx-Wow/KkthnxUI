local K, L = KkthnxUI[1], KkthnxUI[3]

local ACCEPT = ACCEPT
local CANCEL = CANCEL
local ReloadUI = ReloadUI
local StaticPopupDialogs = StaticPopupDialogs

StaticPopupDialogs["KKUI_RESET_DATA"] = {
	text = "Are you sure you want to reset all KkthnxUI Data?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		K:GetModule("Installer"):ResetSettings()
		K:GetModule("Installer"):ResetData()
		ReloadUI()
	end,
}

StaticPopupDialogs["KKUI_RESET_CVARS"] = {
	text = "Are you sure you want to reset all KkthnxUI CVars?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		K:GetModule("Installer"):ForceDefaultCVars()
		ReloadUI()
	end,
}

StaticPopupDialogs["KKUI_RESET_CHAT"] = {
	text = "Are you sure you want to reset KkthnxUI Chat?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		K:GetModule("Installer"):ForceChatSettings()
		ReloadUI()
	end,
}

StaticPopupDialogs["KKUI_QUEST_CHECK_ID"] = {
	text = "Check Quest ID",
	button1 = "Scan",

	OnAccept = function(self)
		if not tonumber(self.editBox:GetText()) then
			return
		end

		self:GetParent():Hide()
	end,

	OnShow = function(self)
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

StaticPopupDialogs["KKUI_POPUP_LINK"] = {
	text = format("|cff5C8BCF%s |r", "KkthnxUI Popup"),
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		data = data or "" -- Ensure data is valid
		self.EditBox:SetAutoFocus(false)
		self.EditBox.width = self.EditBox:GetWidth()
		self.EditBox:SetWidth(280)
		self.EditBox:AddHistoryLine("text")
		self.EditBox.temptxt = data
		self.EditBox:SetText(data)
		self.EditBox:HighlightText() -- Text highlighted on show
		self.EditBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.EditBox:SetWidth(self.EditBox.width or 50)
		self.EditBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if self:GetText() ~= self.temptxt then
			self:SetText(self.temptxt)
			self:HighlightText()
			self:ClearFocus()
		end
	end,
	OnAccept = K.Noop,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

StaticPopupDialogs["KKUI_CHANGES_RELOAD"] = {
	text = L["Changes Reload"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ReloadUI()
	end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3,
}

StaticPopupDialogs["SKIP_INSTALLER_CONFIRM"] = {
	text = "Are you sure you want to skip the installer and proceed without reviewing its contents?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ReloadUI()
	end,
	hideOnEscape = false,
	whileDead = 0,
	preferredIndex = 3,
}
