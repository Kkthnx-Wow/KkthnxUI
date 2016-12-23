local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

-- Lua API
local _G = _G
local pairs = pairs

-- Wow API
local hooksecurefunc = hooksecurefunc
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: RightBarMouseOver, StanceBarMouseOver, PetBarMouseOver, IconIntroTracker
-- GLOBALS: TalentMicroButtonAlert, CollectionsMicroButtonAlert, UIFrameHider
-- GLOBALS: InterfaceOptionsActionBarsPanelBottomLeft, InterfaceOptionsActionBarsPanelBottomRight
-- GLOBALS: InterfaceOptionsActionBarsPanelRight, InterfaceOptionsActionBarsPanelRightTwo
-- GLOBALS: InterfaceOptionsActionBarsPanelAlwaysShowActionBars, PlayerTalentFrame, RightActionBarAnchor
-- GLOBALS: PetActionBarAnchor, ShapeShiftBarAnchor, MultiBarLeft, MultiBarBottomRight, MultiBarRight
-- GLOBALS: PetHolder, ShiftHolder, HoverBind, MainMenuBar, MainMenuBarArtFrame, OverrideActionBar
-- GLOBALS: PossessBarFrame, PetActionBarFrame, ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight
-- GLOBALS: EJMicroButtonAlert

local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("PLAYER_LOGIN")
DisableBlizzard:SetScript("OnEvent", function(self, event)
	for _, Frame in pairs({
		MainMenuBar,
		MainMenuBarArtFrame,
		OverrideActionBar,
		PossessBarFrame,
		PetActionBarFrame,
		IconIntroTracker,
		ShapeshiftBarLeft,
		ShapeshiftBarMiddle,
		ShapeshiftBarRight,
		TalentMicroButtonAlert,
		CollectionsMicroButtonAlert,
		EJMicroButtonAlert
	}) do
		Frame:UnregisterAllEvents()
		Frame.ignoreFramePositionManager = true
		Frame:SetParent(UIFrameHider)
	end

	for index = 1, 6 do
		local Button = _G["OverrideActionBarButton" .. index]

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

	InterfaceOptionsActionBarsPanelBottomLeft:SetScale(0.00001)
	InterfaceOptionsActionBarsPanelBottomLeft:SetAlpha(0)
	InterfaceOptionsActionBarsPanelBottomRight:SetScale(0.00001)
	InterfaceOptionsActionBarsPanelBottomRight:SetAlpha(0)
	InterfaceOptionsActionBarsPanelRight:SetScale(0.00001)
	InterfaceOptionsActionBarsPanelRight:SetAlpha(0)
	InterfaceOptionsActionBarsPanelRightTwo:SetScale(0.00001)
	InterfaceOptionsActionBarsPanelRightTwo:SetAlpha(0)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetScale(0.00001)
	InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
end)

function RightBarMouseOver(alpha)
	RightActionBarAnchor:SetAlpha(alpha)
	PetActionBarAnchor:SetAlpha(alpha)
	ShapeShiftBarAnchor:SetAlpha(alpha)

	if MultiBarLeft:IsShown() then
		for i = 1, 12 do
			local pb = _G["MultiBarLeftButton"..i]
			pb:SetAlpha(alpha)
			local f = _G["MultiBarLeftButton"..i.."Cooldown"]
			K.HideSpiral(f, alpha)
		end
		MultiBarLeft:SetAlpha(alpha)
	end

	if C.ActionBar.RightBars > 2 then
		if MultiBarBottomRight:IsShown() then
			for i = 1, 12 do
				local pb = _G["MultiBarBottomRightButton"..i]
				pb:SetAlpha(alpha)
				local d = _G["MultiBarBottomRightButton"..i.."Cooldown"]
				K.HideSpiral(d, alpha)
			end
			MultiBarBottomRight:SetAlpha(alpha)
		end
	end

	if MultiBarRight:IsShown() then
		for i = 1, 12 do
			local pb = _G["MultiBarRightButton"..i]
			pb:SetAlpha(alpha)
			local g = _G["MultiBarRightButton"..i.."Cooldown"]
			K.HideSpiral(g, alpha)
		end
		MultiBarRight:SetAlpha(alpha)
	end

	if C.ActionBar.PetBarHorizontal == false and C.ActionBar.PetBarHide == false then
		if PetHolder:IsShown() then
			for i = 1, NUM_PET_ACTION_SLOTS do
				local pb = _G["PetActionButton"..i]
				pb:SetAlpha(alpha)
				local f = _G["PetActionButton"..i.."Cooldown"]
				K.HideSpiral(f, alpha)
			end
			PetHolder:SetAlpha(alpha)
		end
	end

	if C.ActionBar.StanceBarHorizontal == false and C.ActionBar.StanceBarHide == false then
		if ShiftHolder:IsShown() then
			for i = 1, NUM_STANCE_SLOTS do
				local pb = _G["StanceButton"..i]
				pb:SetAlpha(alpha)
				local f = _G["StanceButton"..i.."Cooldown"]
				K.HideSpiral(f, alpha)
			end
			ShiftHolder:SetAlpha(alpha)
		end
	end
end

function StanceBarMouseOver(alpha)
	for i = 1, NUM_STANCE_SLOTS do
		local pb = _G["StanceButton"..i]
		pb:SetAlpha(alpha)
		local f = _G["StanceButton"..i.."Cooldown"]
		K.HideSpiral(f, alpha)
	end
	ShapeShiftBarAnchor:SetAlpha(alpha)
end

function PetBarMouseOver(alpha)
	for i = 1, NUM_PET_ACTION_SLOTS do
		local pb = _G["PetActionButton"..i]
		pb:SetAlpha(alpha)
		local f = _G["PetActionButton"..i.."Cooldown"]
		K.HideSpiral(f, alpha)
	end
	PetHolder:SetAlpha(alpha)
end

-- Fix cooldown spiral alpha
function K.HideSpiral(f, alpha)
	f:SetSwipeColor(0, 0, 0, alpha * 0.9)
	f:SetDrawBling(alpha == 1)
end

local EventSpiral = CreateFrame("Frame")
EventSpiral:RegisterEvent("PLAYER_ENTERING_WORLD")
EventSpiral:SetScript("OnEvent", function()
	if C.ActionBar.RightBarsMouseover == true then
		RightBarMouseOver(0)
	end

	if C.ActionBar.PetBarMouseover == true and C.ActionBar.PetBarHorizontal == true and C.ActionBar.PetBarHide ~= true then
		PetBarMouseOver(0)
	end

	if C.ActionBar.StanceBarMouseover == true and C.ActionBar.StanceBarHorizontal == true then
		StanceBarMouseOver(0)
	end
end)

if (C.ActionBar.RightBarsMouseover == true and C.ActionBar.PetBarHorizontal == false and C.ActionBar.PetBarHide == false) or (C.ActionBar.PetBarMouseover == true and C.ActionBar.PetBarHorizontal == true and C.ActionBar.PetBarHide == false) then
	local EventPetSpiral = CreateFrame("Frame")
	EventPetSpiral:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	EventPetSpiral:SetScript("OnEvent", function()
		for i = 1, NUM_PET_ACTION_SLOTS do
			local f = _G["PetActionButton"..i.."Cooldown"]
			K.HideSpiral(f, 0)
		end
		EventPetSpiral:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")
	end)
end

do
	if C.ActionBar.RightBarsMouseover == true then
		RightActionBarAnchor:SetAlpha(0)
		RightActionBarAnchor:SetScript("OnEnter", function() RightBarMouseOver(1) end)
		RightActionBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
		if C.ActionBar.PetBarHorizontal == false then
			PetActionBarAnchor:SetAlpha(0)
			PetActionBarAnchor:SetScript("OnEnter", function() if PetHolder:IsShown() then RightBarMouseOver(1) end end)
			PetActionBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
		end
		if C.ActionBar.StanceBarHorizontal == false and C.ActionBar.StanceBarHide == false then
			ShapeShiftBarAnchor:SetAlpha(0)
			ShapeShiftBarAnchor:SetScript("OnEnter", function() RightBarMouseOver(1) end)
			ShapeShiftBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
		end
	end
	if C.ActionBar.PetBarMouseover == true and C.ActionBar.PetBarHorizontal == true then
		PetActionBarAnchor:SetAlpha(0)
		PetActionBarAnchor:SetScript("OnEnter", function() PetBarMouseOver(1) end)
		PetActionBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then PetBarMouseOver(0) end end)
	end
end