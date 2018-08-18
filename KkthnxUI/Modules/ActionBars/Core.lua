local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

local Module = K:NewModule("Actionbars", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local string_format = string.format

local ActionButton_ShowGrid = _G.ActionButton_ShowGrid
local AutoCastShine_AutoCastStart = _G.AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = _G.AutoCastShine_AutoCastStop
local CooldownFrame_Set = _G.CooldownFrame_Set
local GetActionBarToggles = _G.GetActionBarToggles
local GetNumShapeshiftForms = _G.GetNumShapeshiftForms
local GetPetActionInfo = _G.GetPetActionInfo
local GetPetActionSlotUsable = _G.GetPetActionSlotUsable
local GetShapeshiftFormCooldown = _G.GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = _G.GetShapeshiftFormInfo
local IsPetAttackAction = _G.IsPetAttackAction
local MainMenuBar, MainMenuBarArtFrame = _G.MainMenuBar, _G.MainMenuBarArtFrame
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local OverrideActionBar = _G.OverrideActionBar
local PetActionBarFrame = _G.PetActionBarFrame
local PetActionButton_StartFlash = _G.PetActionButton_StartFlash
local PetActionButton_StopFlash = _G.PetActionButton_StopFlash
local PetHasActionBar = _G.PetHasActionBar
local PossessBarFrame = _G.PossessBarFrame
local SetActionBarToggles = _G.SetActionBarToggles
local SetCVar = _G.SetCVar
local SetDesaturation = _G.SetDesaturation
local ShapeshiftBarLeft = _G.ShapeshiftBarLeft
local ShapeshiftBarMiddle = _G.ShapeshiftBarMiddle
local ShapeshiftBarRight = _G.ShapeshiftBarRight

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

	MainMenuBarArtFrame.RightEndCap.GetRight = function()
		return 0
	end

	MainMenuBarMixin.ChangeMenuBarSizeAndPosition = function()
		return
	end

	MinimapCluster.GetBottom = function()
		return 999999999
	end

	for _, frame in pairs(Module.BarFrames) do
		frame:UnregisterAllEvents()
		frame.ignoreFramePositionManager = true
		frame:SetParent(Hider)
	end

	for i = 1, 6 do
		local Button = _G["OverrideActionBarButton"..i]

		Button:UnregisterAllEvents()
		Button:SetAttribute("statehidden", true)
	end

	hooksecurefunc("TalentFrame_LoadUI", function()
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	end)

	MainMenuBar.slideOut.IsPlaying = function()
		return true
	end

	-- Avoid Hiding Buttons on open/close spellbook
	MultiActionBar_HideAllGrids = function() end
	MultiActionBar_ShowAllGrids = function() end

	self:IconIntroTracker_Toggle()
end

function Module:GridToggle()
	Module:UnregisterEvent("PLAYER_ENTERING_WORLD")

	local IsInstalled = KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete

	if IsInstalled then
		local b1, b2, b3, b4 = GetActionBarToggles()
		if (not b1 or not b2 or not b3 or not b4) then
			SetActionBarToggles(1, 1, 1, 1, 0)
			K.StaticPopup_Show("FIX_ACTIONBARS")
		end
	end

	if C["ActionBar"].ShowGrid == true then
		SetCVar("alwaysShowActionBars", 1)
		for i = 1, 12 do
			local button = _G[string_format("ActionButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarRightButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarBottomRightButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarLeftButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarBottomLeftButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
		end
	else
		SetCVar("alwaysShowActionBars", 0)
	end
end

function K.ShiftBarUpdate()
	local numForms = GetNumShapeshiftForms()
	local texture, isActive, isCastable
	local button, icon, cooldown
	local start, duration, enable
	for i = 1, NUM_STANCE_SLOTS do
		button = _G["StanceButton"..i]
		icon = _G["StanceButton"..i.."Icon"]
		if i <= numForms then
			texture, isActive, isCastable = GetShapeshiftFormInfo(i)
			icon:SetTexture(texture)

			cooldown = _G["StanceButton"..i.."Cooldown"]
			if texture then
				cooldown:SetAlpha(1)
			else
				cooldown:SetAlpha(0)
			end

			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_Set(cooldown, start, duration, enable)

			if isActive then
				StanceBarFrame.lastSelected = button:GetID()
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

function K.PetBarUpdate()
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton"..i
		petActionButton = _G[buttonName]
		petActionIcon = _G[buttonName.."Icon"]
		petAutoCastableTexture = _G[buttonName.."AutoCastable"]
		petAutoCastShine = _G[buttonName.."Shine"]

		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)

		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end

		petActionButton.isToken = isToken

		if isActive and name ~= "PET_ACTION_FOLLOW" then
			petActionButton:SetChecked(true)
			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(petActionButton)
			end
		else
			petActionButton:SetChecked(false)
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(petActionButton)
			end
		end

		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end

		if autoCastEnabled then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end

		if name then
			if not C["ActionBar"].ShowGrid then
				petActionButton:SetAlpha(1)
			end
		else
			if not C["ActionBar"].ShowGrid then
				petActionButton:SetAlpha(0)
			end
		end

		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(petActionIcon, nil)
			else
				SetDesaturation(petActionIcon, 1)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end

		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(petActionButton)
			SetDesaturation(petActionIcon, 1)
			petActionButton:SetChecked(false)
		end
	end
end

-- Mouseover actionbars
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

if C["ActionBar"].RightMouseover == true then
	RightActionBarAnchor:SetAlpha(0)
	RightActionBarAnchor:SetScript("OnEnter", function()
		RightBarMouseOver(1)
	end)

	RightActionBarAnchor:SetScript("OnLeave", function()
		if not HoverBind.enabled then
			RightBarMouseOver(0)
		end
	end)
end

-- Fix cooldown spiral alpha (WoD Bug) <-- Does this even still happen?
function K.HideSpiral(f, alpha)
	f:SetSwipeColor(0, 0, 0, alpha * 0.8)
	f:SetDrawBling(alpha == 1)
end

local EventSpiral = CreateFrame("Frame")
EventSpiral:RegisterEvent("PLAYER_ENTERING_WORLD")
EventSpiral:SetScript("OnEvent", function()
	if C["ActionBar"].RightMouseover == true then
		RightBarMouseOver(0)
	end

	if C["ActionBar"].PetMouseover == true and C["ActionBar"].PetBarHorizontal == true and C["ActionBar"].PetBarHide ~= true then
		PetBarMouseOver(0)
	end

	if C["ActionBar"].StanceMouseover == true and C["ActionBar"].StanceBarHorizontal == true then
		StanceBarMouseOver(0)
	end
end)

if (C["ActionBar"].RightMouseover == true and C["ActionBar"].PetBarHorizontal == false and C["ActionBar"].PetBarHide == false) or (C["ActionBar"].PetMouseover == true and C["ActionBar"].PetBarHorizontal == true and C["ActionBar"].PetBarHide == false) then
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

function Module:OnEnable()
	if C["ActionBar"].Enable ~= true then
		return
	end

	self:DisableBlizzard()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "GridToggle")
end