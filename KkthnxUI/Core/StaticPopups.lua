local K, _, L = unpack(KkthnxUI)

local _G = _G

local ACCEPT = _G.ACCEPT
local CANCEL = _G.CANCEL
local ReloadUI = _G.ReloadUI
local StaticPopupDialogs = _G.StaticPopupDialogs

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
	text = format("|cff669dff%s |r", "KkthnxUI Popup"),
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
		if self:GetText() ~= self.temptxt then
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
