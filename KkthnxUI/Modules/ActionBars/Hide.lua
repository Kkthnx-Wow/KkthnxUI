local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

-- Lua API
local _G = _G
local pairs = pairs

-- Wow API
local hooksecurefunc = _G.hooksecurefunc
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local SetCVar = _G.SetCVar
local UIParent = _G.UIParent

-- Global variables that we don't need to cache, list them here for mikk's FindGlobals script
-- GLOBALS: ActionBarController, MainMenuBar, MainMenuExpBar, ReputationWatchBar
-- GLOBALS: CollectionsMicroButtonAlert, EJMicroButtonAlert, TalentMicroButtonAlert
-- GLOBALS: IconIntroTracker, MultiCastActionBarFrame, RightBarMouseOver, PetBarMouseOver
-- GLOBALS: MainMenuBarArtFrame, PlayerTalentFrame, ArtifactWatchBar, HonorWatchBar
-- GLOBALS: MultiBarBottomRight, MultiBarLeft, MultiBarRight, StanceBarMouseOver
-- GLOBALS: PetActionBarAnchor, ShapeShiftBarAnchor, PetActionBarFrame, PossessBarFrame
-- GLOBALS: OverrideActionBar, StanceBarFramePetHolder, ShiftHolder, PetHolder
-- GLOBALS: HoverBind, UIFrameHider, RightActionBarAnchor, StanceBarFrame, SetActionBarToggles

local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("PLAYER_LOGIN")
DisableBlizzard:SetScript("OnEvent", function()
	-- Lets start with these
	CollectionsMicroButtonAlert:Kill()
	EJMicroButtonAlert:Kill()
	TalentMicroButtonAlert:Kill()

	-- Look into what this does
	ArtifactWatchBar:SetParent(UIFrameHider)
	HonorWatchBar:SetParent(UIFrameHider)

	for i = 1, 12 do
	if _G["OverrideActionBarButton"..i] then
			_G["OverrideActionBarButton"..i]:Hide()
			_G["OverrideActionBarButton"..i]:UnregisterAllEvents()
			_G["OverrideActionBarButton"..i]:SetAttribute("statehidden", true)
		end
	end

	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	MainMenuBar:EnableMouse(false)
	MainMenuBar:SetAlpha(0)
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetParent(UIFrameHider)

	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(UIFrameHider)

	MainMenuBarArtFrame:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
	MainMenuBarArtFrame:UnregisterEvent("ADDON_LOADED")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetParent(UIFrameHider)

	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetParent(UIFrameHider)

	OverrideActionBar:UnregisterAllEvents()
	OverrideActionBar:Hide()
	OverrideActionBar:SetParent(UIFrameHider)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetParent(UIFrameHider)

	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetParent(UIFrameHider)

	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(UIFrameHider)

	IconIntroTracker:UnregisterAllEvents()
	IconIntroTracker:Hide()
	IconIntroTracker:SetParent(UIFrameHider)

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end

	SetActionBarToggles(nil, nil, nil, nil, nil)
end)

-- Mouseover stuff
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