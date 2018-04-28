local K, C, L = unpack(select(2, ...))
local Dialog = LibStub("LibDialog-1.0")

-- Lua API
local _G = _G

-- Wow API
local ACCEPT = _G.ACCEPT
local CANCEL = _G.CANCEL
local DisableAddOn = _G.DisableAddOn
local EnableAddOn = _G.EnableAddOn
local GetRealmName = _G.GetRealmName
local NO = _G.NO
local OKAY = _G.OKAY
local ReloadUI = _G.ReloadUI
local RELOADUI = _G.RELOADUI
local RestartGx = _G.RestartGx
local UnitName = _G.UnitName
local YES = _G.YES

local Name = UnitName("player")
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

Dialog:Register("RESTART_GFX", {
	text = L["StaticPopups"].Restart_GFX,
	buttons = {
		{
			text = ACCEPT,
			on_click = function(self, mouseButton, down)
				RestartGx()
			end,
		},
		{
			text = CANCEL,
			on_click = function(self, mouseButton, down)
				print("You have canceled this dialog.")
			end,
		},
	},
	show_while_dead = true,
	hide_on_escape = true,
})

Dialog:Register("SET_UISCALE", {
	text = L["StaticPopups"].Set_UI_Scale,
	buttons = {
		{
			text = ACCEPT,
			on_click = function(self, mouseButton, down)
				K.SetUIScale()
			end,
		},
		{
			text = CANCEL,
			on_click = function(self, mouseButton, down)
				print("You have canceled this dialog.")
			end,
		},
	},
	showwhiledead = true,
	hideonescape = true,
})

Dialog:Register("DISBAND_RAID", {
	text = L["StaticPopups"].Disband_Group,
	buttons = {
		{
			text = ACCEPT,
			on_click = function(self, mouseButton, down)
				K.DisbandRaidGroup()
			end,
		},
		{
			text = CANCEL,
			on_click = function(self, mouseButton, down)
				print("You have canceled this dialog.")
			end,
		},
	},
	showwhiledead = true,
	hideonescape = true,
})

Dialog:Register("CANNOT_BUY_BANK_SLOT", {
	text = L["Inventory"].Cant_Buy_Slot,
	buttons = {
		{
			text = OKAY,
		},
	},
	showwhiledead = true,
	hideonescape = false,
})


Dialog:Register("BUY_BANK_SLOT", {
	text = CONFIRM_BUY_BANK_SLOT,
	on_show = function(self)
		--MoneyFrame_Update(self.moneyFrame, GetBankSlotCost())
	end,
	buttons = {
		{
			text = YES,
			on_click = function(self, mouseButton, down)
				PurchaseSlot()
			end,
		},
		{
			text = NO,
		},
	},
	showwhiledead = false,
	hideonescape = true,
})

Dialog:Register("BOOST_UI", {
	text = "BOOST_UI",
	buttons = {
		{
			text = ACCEPT,
			on_click = function(self, mouseButton, down)
				K.BoostUI()
			end,
		},
		{
			text = CANCEL,
		},
	},
	showwhiledead = true,
	hideonescape = true,
})

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
	OnAccept = function() K.Install:Launch() if UIConfig and UIConfig:IsShown() then
		UIConfigMain:Hide()
		end
	end,
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