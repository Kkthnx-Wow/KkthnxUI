local K, C = unpack(select(2, ...))
local Module = K:NewModule("HideBlizzard", "AceHook-3.0", "AceEvent-3.0")

local _G = _G

local MainMenuBar, MainMenuBarArtFrame = _G.MainMenuBar, _G.MainMenuBarArtFrame
local OverrideActionBar = _G.OverrideActionBar
local PossessBarFrame = _G.PossessBarFrame
local PetActionBarFrame = _G.PetActionBarFrame
local ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight = _G.ShapeshiftBarLeft, _G.ShapeshiftBarMiddle, _G.ShapeshiftBarRight

Module.BarFrames = {
	MainMenuBar, MainMenuBarArtFrame, OverrideActionBar,
	PossessBarFrame, PetActionBarFrame, EJMicroButtonAlert,
	ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
	TalentMicroButtonAlert, CollectionsMicroButtonAlert
}

function Module:IconIntroTracker_Toggle()
	if C["ActionBar"].AddNewSpells then
		IconIntroTracker:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
		IconIntroTracker:Show()
		IconIntroTracker:SetParent(UIParent)
	else
		IconIntroTracker:UnregisterAllEvents()
		IconIntroTracker:Hide()
		IconIntroTracker:SetParent(K.UIFrameHider)
	end
end

function Module:DisableBlizzard()
	local Hider = K.UIFrameHider

	MainMenuBarRightEndCap.GetRight = function()
		return 0
	end

	MainMenuBar.ChangeMenuBarSizeAndPosition = function()
		return
	end

	MinimapCluster.GetBottom = function()
		return 999999999
	end

	SetCVar("alwaysShowActionBars", 1)

	for _, frame in pairs(Module.BarFrames) do
		frame:UnregisterAllEvents()
		frame.ignoreFramePositionManager = true
		frame:SetParent(Hider)
	end

	for i = 1, 6 do
		local Button = _G["OverrideActionBarButton"..i]

		Button:UnregisterAllEvents()
		Button:SetAttribute("statehidden", true)
		Button:SetAttribute("showgrid", 1)
	end

	hooksecurefunc("TalentFrame_LoadUI", function()
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	end)

	hooksecurefunc("ActionButton_OnEvent", function(self, event)
		if (event == "PLAYER_ENTERING_WORLD") then
			self:UnregisterEvent("ACTIONBAR_SHOWGRID")
			self:UnregisterEvent("ACTIONBAR_HIDEGRID")
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end
	end)

	MainMenuBar.slideOut.IsPlaying = function()
		return true
	end

	self:IconIntroTracker_Toggle()

	-- Avoid Hiding Buttons on open/close spellbook
	MultiActionBar_HideAllGrids = function() end
	MultiActionBar_ShowAllGrids = function() end

	ActionBarButtonEventsFrame:UnregisterEvent("ACTIONBAR_HIDEGRID")
end

function Module:OnEnable()
	if C["ActionBar"].Enable ~= true then
		return
	end

	self:DisableBlizzard()
end