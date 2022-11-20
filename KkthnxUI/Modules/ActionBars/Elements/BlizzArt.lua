local K = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local next = _G.next
local tonumber = _G.tonumber

local ACTION_BUTTON_SHOW_GRID_REASON_CVAR = _G.ACTION_BUTTON_SHOW_GRID_REASON_CVAR
local ActionBarDownButton = _G.ActionBarDownButton
local ActionBarUpButton = _G.ActionBarUpButton
-- local BackpackTokenFrame_Update = _G.BackpackTokenFrame_Update
local GetCVar = _G.GetCVar
local InCombatLockdown = _G.InCombatLockdown
local MainMenuBar = _G.MainMenuBar
local MainMenuBarArtFrame = _G.MainMenuBarArtFrame
local MainMenuBarVehicleLeaveButton = _G.MainMenuBarVehicleLeaveButton
local MicroButtonAndBagsBar = _G.MicroButtonAndBagsBar
local OverrideActionBar = _G.OverrideActionBar
local OverrideActionBarExpBar = _G.OverrideActionBarExpBar
local OverrideActionBarHealthBar = _G.OverrideActionBarHealthBar
local OverrideActionBarPitchFrame = _G.OverrideActionBarPitchFrame
local OverrideActionBarPowerBar = _G.OverrideActionBarPowerBar
local StatusTrackingBarManager = _G.StatusTrackingBarManager
local TokenFrame_LoadUI = _G.TokenFrame_LoadUI
local TokenFrame_Update = _G.TokenFrame_Update
local hooksecurefunc = _G.hooksecurefunc

local updateAfterCombat

local scripts = {
	"OnClick",
	"OnEnter",
	"OnEvent",
	"OnHide",
	"OnLeave",
	"OnMouseDown",
	"OnMouseUp",
	"OnShow",
	"OnUpdate",
	"OnValueChanged",
}

local framesToHide = {
	MainMenuBar,
	OverrideActionBar,
}

local framesToDisable = {
	MainMenuBar,
	MicroButtonAndBagsBar,
	MainMenuBarArtFrame,
	StatusTrackingBarManager,
	ActionBarDownButton,
	ActionBarUpButton,
	MainMenuBarVehicleLeaveButton,
	OverrideActionBar,
	OverrideActionBarExpBar,
	OverrideActionBarHealthBar,
	OverrideActionBarPowerBar,
	OverrideActionBarPitchFrame,
}

local function DisableAllScripts(frame)
	for _, script in next, scripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

local function buttonShowGrid(name, showgrid)
	for i = 1, 12 do
		local button = _G[name .. i]
		if button then
			button:SetAttribute("showgrid", showgrid)
			button:ShowGrid(ACTION_BUTTON_SHOW_GRID_REASON_CVAR)
		end
	end
end

local function toggleButtonGrid()
	if InCombatLockdown() then
		updateAfterCombat = true
		K:RegisterEvent("PLAYER_REGEN_ENABLED", toggleButtonGrid)
	else
		local showgrid = tonumber(GetCVar("alwaysShowActionBars"))
		buttonShowGrid("ActionButton", showgrid)
		buttonShowGrid("MultiBarBottomRightButton", showgrid)
		buttonShowGrid("KKUI_ActionBarXButton", showgrid)
		if updateAfterCombat then
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", toggleButtonGrid)
			updateAfterCombat = false
		end
	end
end

local function updateTokenVisibility()
	TokenFrame_LoadUI()
	TokenFrame_Update()
end

local function ReplaceSpellbookButtons()
	local function replaceOnEnter(self)
		local slot = SpellBook_GetSpellBookSlot(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

		if InClickBindingMode() and not self.canClickBind then
			GameTooltip:AddLine(CLICK_BINDING_NOT_AVAILABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
			GameTooltip:Show()
			return
		end

		GameTooltip:SetSpellBookItem(slot, SpellBookFrame.bookType)
		self.UpdateTooltip = nil

		if self.SpellHighlightTexture and self.SpellHighlightTexture:IsShown() then
			GameTooltip:AddLine(SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b)
		end
		GameTooltip:Show()
	end

	local function handleSpellButton(button)
		button.OnEnter = replaceOnEnter
		button:SetScript("OnEnter", replaceOnEnter)
		button.OnLeave = B.HideTooltip
		button:SetScript("OnLeave", B.HideTooltip)
	end

	for i = 1, SPELLS_PER_PAGE do
		handleSpellButton(_G["SpellButton" .. i])
	end

	local professions = { "PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3" }
	for _, button in pairs(professions) do
		local bu = _G[button]
		handleSpellButton(bu.SpellButton1)
		handleSpellButton(bu.SpellButton2)
	end
end

function Module:HideBlizz()
	MainMenuBar:SetMovable(true)
	MainMenuBar:SetUserPlaced(true)
	MainMenuBar.ignoreFramePositionManager = true
	MainMenuBar:SetAttribute("ignoreFramePositionManager", true)

	for _, frame in next, framesToHide do
		frame:SetParent(K.UIFrameHider)
	end

	for _, frame in next, framesToDisable do
		frame:UnregisterAllEvents()
		DisableAllScripts(frame)
	end

	-- Fix spellbook button taint with Editmode
	-- ReplaceSpellbookButtons()
	-- Hide blizz options
	SetCVar("multiBarRightVerticalLayout", 0)
	-- Fix maw block anchor
	MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- Update token panel
	K:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateTokenVisibility)
end
