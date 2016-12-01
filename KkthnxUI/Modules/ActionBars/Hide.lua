local K, C, L = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local KkthnxUIActionBars = CreateFrame("Frame")
local _G = _G
local pairs = pairs
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

	MainMenuBar.slideOut.IsPlaying = function()
		return true
	end
end

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
	f:SetSwipeColor(0, 0, 0, alpha * 0.8)
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

KkthnxUIActionBars:RegisterEvent("PLAYER_LOGIN")
KkthnxUIActionBars:SetScript("OnEvent", KkthnxUIActionBars.DisableBlizzard)