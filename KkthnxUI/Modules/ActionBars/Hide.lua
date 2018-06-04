local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

local Module = K:NewModule("DisableBlizzard", "AceHook-3.0", "AceEvent-3.0")

local _G = _G

local hooksecurefunc = _G.hooksecurefunc
local MainMenuBar = _G.MainMenuBar
local MainMenuBarArtFrame = _G.MainMenuBarArtFrame
local MainMenuBarMaxLevelBar = _G.MainMenuBarMaxLevelBar
local MainMenuExpBar = _G.MainMenuExpBar
local PetActionBarFrame = _G.PetActionBarFrame
local PossessBarFrame = _G.PossessBarFrame
local ReputationWatchBar = _G.ReputationWatchBar
local StreamingIcon = _G.StreamingIcon
local TutorialFrameAlertButton = _G.TutorialFrameAlertButton
local UIPARENT_MANAGED_FRAME_POSITIONS = _G.UIPARENT_MANAGED_FRAME_POSITIONS

function Module:IconIntroTracker_Toggle()
	if (C["ActionBar"].AddNewSpells) then
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
	local UIHider = K["UIFrameHider"]

	MainMenuBar:EnableMouse(false)
	MainMenuBar:UnregisterAllEvents()
	MainMenuBar:SetAlpha(0)
	MainMenuBar:SetScale(0.00001)

	MainMenuBarArtFrame:UnregisterAllEvents()
	MainMenuBarArtFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	MainMenuBarArtFrame:Hide()
	MainMenuBarArtFrame:SetAlpha(0)
	MainMenuBarArtFrame:SetParent(UIHider)

	MainMenuExpBar:EnableMouse(false)
	MainMenuExpBar:UnregisterAllEvents()
	MainMenuExpBar:Hide()
	MainMenuExpBar:SetAlpha(0)
	MainMenuExpBar:SetScale(0.00001)
	MainMenuExpBar:SetParent(UIHider)

	-- Trying to work around a bug sometimes happening
	-- on level 20 starter edition characters.
	MainMenuExpBar:SetScript("OnShow", nil)
	MainMenuExpBar:SetScript("OnHide", nil)
	MainMenuExpBar:SetScript("OnEvent", nil)
	MainMenuExpBar:SetScript("OnUpdate", nil)
	MainMenuExpBar:SetScript("OnEnter", nil)
	MainMenuExpBar:SetScript("OnLeave", nil)
	MainMenuExpBar:SetScript("OnValueChanged", nil)

	-- Not strictly certain when they added this,
	-- so we're going with the most recent expansion only.
	-- Chances are this is the only place starter edition accounts exist.
	K.LockCVar("xpBarText", 0)

	PossessBarFrame:UnregisterAllEvents()
	PossessBarFrame:Hide()
	PossessBarFrame:SetAlpha(0)
	PossessBarFrame:SetParent(UIHider)

	PetActionBarFrame:EnableMouse(false)
	PetActionBarFrame:UnregisterAllEvents()
	PetActionBarFrame:SetParent(UIHider)
	PetActionBarFrame:Hide()
	PetActionBarFrame:SetAlpha(0)

	TutorialFrameAlertButton:UnregisterAllEvents()
	TutorialFrameAlertButton:Hide()

	MainMenuBarMaxLevelBar:SetParent(UIHider)
	MainMenuBarMaxLevelBar:Hide()

	ReputationWatchBar:SetParent(UIHider)

	StreamingIcon:SetParent(UIHider)

	local TalentMicroButtonAlert = _G.TalentMicroButtonAlert
	TalentMicroButtonAlert:UnregisterAllEvents()
	TalentMicroButtonAlert:SetParent(UIHider)

	local StanceBarFrame = _G.StanceBarFrame
	local StanceBarLeft = _G.StanceBarLeft
	local StanceBarMiddle = _G.StanceBarMiddle
	local StanceBarRight = _G.StanceBarRight
	local OverrideActionBar = _G.OverrideActionBar

	StanceBarFrame:EnableMouse(false)
	StanceBarFrame:UnregisterAllEvents()
	StanceBarFrame:Hide()
	StanceBarFrame:SetAlpha(0)

	StanceBarLeft:Hide()
	StanceBarLeft:SetAlpha(0)

	StanceBarMiddle:Hide()
	StanceBarMiddle:SetAlpha(0)

	StanceBarRight:Hide()
	StanceBarRight:SetAlpha(0)

	-- If I'm not hiding this, it will become visible (though transparent)
	-- and cover our own custom vehicle/possess action bar.
	OverrideActionBar:SetParent(UIHider)
	OverrideActionBar:EnableMouse(false)
	OverrideActionBar:UnregisterAllEvents()

	MainMenuBar.slideOut:GetAnimations():SetOffset(0,0)
	OverrideActionBar.slideOut:GetAnimations():SetOffset(0,0)

	for i = 1,6 do
		_G["OverrideActionBarButton"..i]:UnregisterAllEvents()
		_G["OverrideActionBarButton"..i]:SetAttribute("statehidden", true)
		_G["OverrideActionBarButton"..i]:EnableMouse(false) -- just in case it's still there
	end

	local CollectionsMicroButtonAlert = _G.CollectionsMicroButtonAlert
	local EJMicroButtonAlert = _G.EJMicroButtonAlert
	local LFDMicroButtonAlert = _G.LFDMicroButtonAlert

	CollectionsMicroButtonAlert:UnregisterAllEvents()
	CollectionsMicroButtonAlert:SetParent(UIHider)
	CollectionsMicroButtonAlert:Hide()

	EJMicroButtonAlert:UnregisterAllEvents()
	EJMicroButtonAlert:SetParent(UIHider)
	EJMicroButtonAlert:Hide()

	LFDMicroButtonAlert:UnregisterAllEvents()
	LFDMicroButtonAlert:SetParent(UIHider)
	LFDMicroButtonAlert:Hide()

	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarLeft"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomRight"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MainMenuBar"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["ShapeshiftBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PossessBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MultiCastActionBarFrame"] = nil
	UIPARENT_MANAGED_FRAME_POSITIONS["MULTICASTACTIONBAR_YPOS"] = nil

	if _G.PlayerTalentFrame then
		_G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
		hooksecurefunc("TalentFrame_LoadUI", function() _G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end)
	end

	-- Enable/disable functionality to automatically put spells on the actionbar.
	self:IconIntroTracker_Toggle()
end

function Module:OnEnable()
	self:DisableBlizzard()
end