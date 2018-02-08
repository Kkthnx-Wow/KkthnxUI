local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G

-- Wow API
local ChatEdit_FocusActiveWindow = _G.ChatEdit_FocusActiveWindow
local DisableAddOn = _G.DisableAddOn
local EnableAddOn = _G.EnableAddOn
local ReloadUI = _G.ReloadUI
local RestartGx = _G.RestartGx
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemLink = _G.GetContainerItemLink
local DeleteCursorItem = _G.DeleteCursorItem
local PickupContainerItem = _G.PickupContainerItem

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: Install, UIConfig, UIConfigMain, KkthnxUIData

local Name = UnitName("Player")
local Realm = GetRealmName()

StaticPopupDialogs["CONFIG_RL"] = {
	text = L["StaticPopups"].Config_Reload,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() K.PixelPerfect.RequireReload = false ReloadUI() end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["CHANGES_RL"] = {
	text =  L["StaticPopups"].Changes_Reload,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["CLIENT_RESTART"] = {
	text = L["StaticPopups"].Resolution_Changed,
	button1 = "Restart Client",
	button2 = RELOADUI,
	OnAccept = function(self) K.RequireReload = false ForceQuit() end,
	OnCancel = function(self) K.RequireReload = false ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

StaticPopupDialogs["RESTART_GFX"] = {
	text = L["StaticPopups"].Restart_GFX,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() RestartGx() end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["WATCHFRAME_URL"] = {
	text = L["StaticPopups"].WoWHeadLink,
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	hideOnEscape = 1,
	editBoxWidth = 325,
	OnShow = function(self, ...)
		self.editBox:SetAutoFocus(true)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:SetWidth(325)
		self.editBox:HighlightText()
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	preferredIndex = 3,
}

StaticPopupDialogs["KKTHNXUI_UPDATE"] = {
	text = L["StaticPopups"].KkthnxUI_Update,
	hasEditBox = 1,
	OnShow = function(self)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:SetWidth(220)
		self.editBox:SetText("https://mods.curse.com/addons/wow/kkthnxui")
		self.editBox:HighlightText()
		ChatEdit_FocusActiveWindow()
	end,
	OnHide = function(self)
		self.editBox:SetWidth(self.editBox.width or 50)
		self.editBox.width = nil
	end,
	hideOnEscape = 1,
	button1 = OKAY,
	OnAccept = K.Noop,
	EditBoxOnEnterPressed = function(self)
		ChatEdit_FocusActiveWindow()
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		ChatEdit_FocusActiveWindow()
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= "https://mods.curse.com/addons/wow/kkthnxui") then
			self:SetText("https://mods.curse.com/addons/wow/kkthnxui")
		end
		self:HighlightText()
		self:ClearFocus()
		ChatEdit_FocusActiveWindow()
	end,
	OnEditFocusGained = function(self)
		self:HighlightText()
	end,
	showAlert = 1,
}

StaticPopupDialogs["SET_UISCALE"] = {
	text = L["StaticPopups"].Set_UI_Scale,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = K.SetUIScale,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3,
}

StaticPopupDialogs["DISBAND_RAID"] = {
	text = L["StaticPopups"].Disband_Group,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = K.DisbandRaidGroup,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["CANNOT_BUY_BANK_SLOT"] = {
	text = L["Inventory"].Cant_Buy_Slot,
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["BUY_BANK_SLOT"] = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		PurchaseSlot()
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetBankSlotCost())
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,
	preferredIndex = 3
}

-- Add a warning so we do not piss people off.
StaticPopupDialogs["BOOST_UI"] = {
	text = "BOOST_UI",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = K.BoostUI,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"] = {
	text = CONFIRM_LOOT_DISTRIBUTION,
	button1 = YES,
	button2 = NO,
	timeout = 0,
	hideOnEscape = 1,
	preferredIndex = 3,
}

StaticPopupDialogs["DISABLE_UI"] = {
	text = "DISABLE_UI",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() DisableAddOn("KkthnxUI") ReloadUI() end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["RESET_UI"] = {
	text = L["StaticPopups"].Reset_UI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() K.Install:Launch() if UIConfig and UIConfig:IsShown() then UIConfigMain:Hide() end end,
	OnCancel = function() KkthnxUIData[Realm][Name].InstallComplete = true end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

StaticPopupDialogs["FIX_ACTIONBARS"] = {
	text = L["StaticPopups"].Fix_Actionbars,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ReloadUI,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

StaticPopupDialogs["WARNING_BLIZZARD_ADDONS"] = {
	text = L["StaticPopups"].Warning_Blizzard_AddOns,
	button1 = OKAY,
	OnAccept = function() EnableAddOn("Blizzard_CompactRaidFrames") ReloadUI() end,
	timeout = 0,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}