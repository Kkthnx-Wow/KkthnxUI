local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local KkthnxUIActionBars = CreateFrame("Frame")
local _G = _G
local format = format
local Noop = function() end
local NUM_ACTIONBAR_BUTTONS = NUM_ACTIONBAR_BUTTONS
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS
local MainMenuBar, MainMenuBarArtFrame = MainMenuBar, MainMenuBarArtFrame
local OverrideActionBar = OverrideActionBar
local PossessBarFrame = PossessBarFrame
local PetActionBarFrame = PetActionBarFrame
local ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight = ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight

local Frames = {
	MainMenuBar, MainMenuBarArtFrame, OverrideActionBar,
	PossessBarFrame, PetActionBarFrame, IconIntroTracker,
	ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
	TalentMicroButtonAlert, CollectionsMicroButtonAlert, EJMicroButtonAlert
}

function KkthnxUIActionBars:DisableBlizzard()
	if C.ActionBar.Grid == true then
		SetCVar("alwaysShowActionBars", 1)
	else
		SetCVar("alwaysShowActionBars", 0)
	end

	for _, frame in pairs(Frames) do
		frame:UnregisterAllEvents()
		frame.ignoreFramePositionManager = true
		frame:SetParent(UIFrameHider)
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
end

KkthnxUIActionBars:RegisterEvent("PLAYER_LOGIN")
KkthnxUIActionBars:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		self:DisableBlizzard()
	end
end)