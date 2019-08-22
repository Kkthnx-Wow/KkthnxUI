local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local next, tonumber = next, tonumber

local GetCVar = _G.GetCVar
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown

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

function Module:HideBlizz()
	if not C["ActionBar"].Enable then
		return
	end

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

	-- Update Button Grid
	local function buttonShowGrid(name, showgrid)
		for i = 1, 12 do
			local button = _G[name..i]
			button:SetAttribute("showgrid", showgrid)
			ActionButton_ShowGrid(button, ACTION_BUTTON_SHOW_GRID_REASON_CVAR)
		end
	end

	local updateAfterCombat
	local function ToggleButtonGrid()
		if InCombatLockdown() then
			updateAfterCombat = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", ToggleButtonGrid)
		else
			local showgrid = tonumber(GetCVar("alwaysShowActionBars"))
			buttonShowGrid("ActionButton", showgrid)
			buttonShowGrid("MultiBarBottomRightButton", showgrid)
			if updateAfterCombat then
				K:UnregisterEvent("PLAYER_REGEN_ENABLED", ToggleButtonGrid)
				updateAfterCombat = false
			end
		end
	end
	hooksecurefunc("MultiActionBar_UpdateGridVisibility", ToggleButtonGrid)

	-- Unregister Talent Event
	if _G.PlayerTalentFrame then
		_G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function()
			_G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end)
	end

	-- Update Token Panel
	local function updateToken()
		TokenFrame_LoadUI()
		TokenFrame_Update()
		BackpackTokenFrame_Update()
	end
	K:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateToken)

	_G.InterfaceOptionsActionBarsPanelStackRightBars:Kill()
end