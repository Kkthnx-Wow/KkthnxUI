local K = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local next = _G.next
local tonumber = _G.tonumber

local ACTION_BUTTON_SHOW_GRID_REASON_CVAR = _G.ACTION_BUTTON_SHOW_GRID_REASON_CVAR
local ActionBarDownButton = _G.ActionBarDownButton
local ActionBarUpButton = _G.ActionBarUpButton
local BackpackTokenFrame_Update = _G.BackpackTokenFrame_Update
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
local StreamingIcon = _G.StreamingIcon
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
	StreamingIcon,
}

local framesToDisable = {
	ActionBarDownButton,
	ActionBarUpButton,
	MainMenuBar,
	MainMenuBarArtFrame,
	MainMenuBarVehicleLeaveButton,
	MicroButtonAndBagsBar,
	OverrideActionBar,
	OverrideActionBarExpBar,
	OverrideActionBarHealthBar,
	OverrideActionBarPitchFrame,
	OverrideActionBarPowerBar,
	StatusTrackingBarManager,
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
		local button = _G[name..i]
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
		buttonShowGrid("KKUI_CustomBarButton", showgrid)
		if updateAfterCombat then
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", toggleButtonGrid)
			updateAfterCombat = false
		end
	end
end

local function hideFakeExtraBar(event, addon)
	if addon == "Blizzard_BindingUI" then
		QuickKeybindFrame.phantomExtraActionButton:Kill()
		K:UnregisterEvent(event, hideFakeExtraBar)
	end
end

local function updateTokenVisibility()
	TokenFrame_LoadUI()
	TokenFrame_Update()
	BackpackTokenFrame_Update()
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

	-- Update button grid
	hooksecurefunc("MultiActionBar_UpdateGridVisibility", toggleButtonGrid)
	-- Update token panel
	K:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateTokenVisibility)
	-- Fake ExtraActionButton
	K:RegisterEvent("ADDON_LOADED", hideFakeExtraBar)
end