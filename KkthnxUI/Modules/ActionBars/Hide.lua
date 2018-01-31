local K, C, L = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then return end
local Module = K:NewModule("DisableJunk", "AceHook-3.0", "AceEvent-3.0")

-- Lua API
local _G = _G

-- Wow API
local hooksecurefunc = _G.hooksecurefunc
local MainMenuBar = _G.MainMenuBar
local MainMenuBarArtFrame = _G.MainMenuBarArtFrame
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local OverrideActionBar = _G.OverrideActionBar
local PetActionBarFrame = _G.PetActionBarFrame
local PossessBarFrame = _G.PossessBarFrame

function Module:BlizzardOptionsPanel_OnEvent()
	InterfaceOptionsActionBarsPanelBottomRight.Text:SetFormattedText("Remove Bar %d Action Page", 2)
	InterfaceOptionsActionBarsPanelBottomLeft.Text:SetFormattedText("Remove Bar %d Action Page", 3)
	InterfaceOptionsActionBarsPanelRightTwo.Text:SetFormattedText("Remove Bar %d Action Page", 4)
	InterfaceOptionsActionBarsPanelRight.Text:SetFormattedText("Remove Bar %d Action Page", 5)

	InterfaceOptionsActionBarsPanelBottomRight:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelBottomLeft:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelRightTwo:SetScript("OnEnter", nil)
	InterfaceOptionsActionBarsPanelRight:SetScript("OnEnter", nil)
end

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
	-- Look into what this does
	ArtifactWatchBar:SetParent(K.UIFrameHider)
	HonorWatchBar:SetParent(K.UIFrameHider)

	ActionBarController:UnregisterAllEvents()
	ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")

	MainMenuBar:EnableMouse(false)
	MainMenuBar:UnregisterAllEvents()
	MainMenuBar:SetAlpha(0)
	MainMenuBar:SetScale(0.00001)

	MainMenuExpBar:EnableMouse(false)
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetAlpha(0)
	MainMenuExpBar:SetScale(0.00001)
	MainMenuExpBar:SetParent(K.UIFrameHider)

	-- Trying to work around a bug sometimes happening
	-- on level 20 starter edition characters.
	MainMenuExpBar:SetScript("OnShow", nil)
	MainMenuExpBar:SetScript("OnHide", nil)
	MainMenuExpBar:SetScript("OnEvent", nil)
	MainMenuExpBar:SetScript("OnUpdate", nil)
	MainMenuExpBar:SetScript("OnEnter", nil)
	MainMenuExpBar:SetScript("OnLeave", nil)
	MainMenuExpBar:SetScript("OnValueChanged", nil)

	for i = 1, MainMenuBar:GetNumChildren() do
		local child = select(i, MainMenuBar:GetChildren())
		if child then
			child:UnregisterAllEvents()
			child:Hide()
			child:SetParent(K.UIFrameHider)
		end
	end

	for i = 1, 6 do
		_G["OverrideActionBarButton"..i]:UnregisterAllEvents()
		_G["OverrideActionBarButton"..i]:SetAttribute("statehidden", true)
		_G["OverrideActionBarButton"..i]:EnableMouse(false) -- just in case it's still there
	end

	ReputationWatchBar:UnregisterAllEvents()
	ReputationWatchBar:Hide()
	ReputationWatchBar:SetParent(K.UIFrameHider)

	MainMenuBarArtFrame:UnregisterAllEvents()
	MainMenuBarArtFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetAlpha(0)
	MainMenuBarArtFrame:SetParent(K.UIFrameHider)

	StanceBarFrame:EnableMouse(false)
	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetAlpha(0)

	OverrideActionBar:SetParent(K.UIFrameHider)
	OverrideActionBar:EnableMouse(false)
	OverrideActionBar:SetScale(0.00001)
	OverrideActionBar:UnregisterAllEvents()

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetAlpha(0)
	PossessBarFrame:SetParent(K.UIFrameHider)

	PetActionBarFrame:EnableMouse(false)
	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:SetParent(K.UIFrameHider)
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetAlpha(0)

	MultiCastActionBarFrame:UnregisterAllEvents()
	MultiCastActionBarFrame:Hide()
	MultiCastActionBarFrame:SetParent(K.UIFrameHider)

	MainMenuBarMaxLevelBar:SetParent(K.UIFrameHider)
	MainMenuBarMaxLevelBar:Hide()

	TalentMicroButtonAlert:UnregisterAllEvents()
	TalentMicroButtonAlert:SetParent(K.UIFrameHider)

	CollectionsMicroButtonAlert:UnregisterAllEvents()
	CollectionsMicroButtonAlert:SetParent(K.UIFrameHider)
	CollectionsMicroButtonAlert:Hide()

	EJMicroButtonAlert:UnregisterAllEvents()
	EJMicroButtonAlert:SetParent(K.UIFrameHider)
	EJMicroButtonAlert:Hide()

	LFDMicroButtonAlert:UnregisterAllEvents()
	LFDMicroButtonAlert:SetParent(K.UIFrameHider)
	LFDMicroButtonAlert:Hide()

	UIPARENT_MANAGED_FRAME_POSITIONS["ExtraActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarLeft"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MULTICASTACTIONBAR_YPOS"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ShapeshiftBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil

	-- Enable/disable functionality to automatically put spells on the actionbar.
	self:IconIntroTracker_Toggle()

	MainMenuBar.slideOut.IsPlaying = function()
		return true
	end

	MainMenuBar.slideOut:GetAnimations():SetOffset(0, 0)
	OverrideActionBar.slideOut:GetAnimations():SetOffset(0, 0)

	self:SecureHook("BlizzardOptionsPanel_OnEvent")

	if PlayerTalentFrame then
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function()
			PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		end)
	end
end

function Module:OnEnable()
	self:DisableBlizzard()
end

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

	if C["ActionBar"].RightBars > 2 then
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

	if C["ActionBar"].PetBarHorizontal == false and C["ActionBar"].PetBarHide == false then
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

	if C["ActionBar"].StanceBarHorizontal == false and C["ActionBar"].StanceBarHide == false then
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
	if C["ActionBar"].RightBarsMouseover == true then
		RightBarMouseOver(0)
	end

	if C["ActionBar"].PetBarMouseover == true and C["ActionBar"].PetBarHorizontal == true and C["ActionBar"].PetBarHide ~= true then
		PetBarMouseOver(0)
	end

	if C["ActionBar"].StanceBarMouseover == true and C["ActionBar"].StanceBarHorizontal == true then
		StanceBarMouseOver(0)
	end
end)

if (C["ActionBar"].RightBarsMouseover == true and C["ActionBar"].PetBarHorizontal == false and C["ActionBar"].PetBarHide == false) or (C["ActionBar"].PetBarMouseover == true and C["ActionBar"].PetBarHorizontal == true and C["ActionBar"].PetBarHide == false) then
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
	if C["ActionBar"].RightBarsMouseover == true then
		RightActionBarAnchor:SetAlpha(0)
		RightActionBarAnchor:SetScript("OnEnter", function() RightBarMouseOver(1) end)
		RightActionBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
		if C["ActionBar"].PetBarHorizontal == false then
			PetActionBarAnchor:SetAlpha(0)
			PetActionBarAnchor:SetScript("OnEnter", function() if PetHolder:IsShown() then RightBarMouseOver(1) end end)
			PetActionBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
		end
		if C["ActionBar"].StanceBarHorizontal == false and C["ActionBar"].StanceBarHide == false then
			ShapeShiftBarAnchor:SetAlpha(0)
			ShapeShiftBarAnchor:SetScript("OnEnter", function() RightBarMouseOver(1) end)
			ShapeShiftBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
		end
	end
	if C["ActionBar"].PetBarMouseover == true and C["ActionBar"].PetBarHorizontal == true then
		PetActionBarAnchor:SetAlpha(0)
		PetActionBarAnchor:SetScript("OnEnter", function() PetBarMouseOver(1) end)
		PetActionBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then PetBarMouseOver(0) end end)
	end
end