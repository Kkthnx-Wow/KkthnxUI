local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local select = select
local tostring = tostring
local unpack = unpack

-- Wow API
local CreateFrame = _G.CreateFrame
local GetActiveSpecGroup = _G.GetActiveSpecGroup
local GetNumShapeshiftForms = _G.GetNumShapeshiftForms
local GetNumSpecializations = _G.GetNumSpecializations
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local InCombatLockdown = _G.InCombatLockdown
local IsShiftKeyDown = _G.IsShiftKeyDown
local SetSpecialization = _G.SetSpecialization
local UIParent = _G.UIParent

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIConfigFrame, KkthnxUIConfig
-- GLOBALS: Skada, UIConfigMain, CreateUIConfig, HideUIPanel, Menu, GameTooltip
-- GLOBALS: UIErrorsFrame, ERR_NOT_IN_COMBAT, Lib_EasyMenu, Recount_MainWindow

local Movers = K.Movers

-- Bottom bars anchor
local BottomBarAnchor = CreateFrame("Frame", "ActionBarAnchor", K.PetBattleHider)
BottomBarAnchor:CreatePanel("Invisible", 1, 1, "BOTTOM", "UIParent", "BOTTOM", 0, 4)
BottomBarAnchor:SetWidth((C["ActionBar"].ButtonSize * 12) + (C["ActionBar"].ButtonSpace * 11))
if C["ActionBar"].BottomBars == 2 then
	BottomBarAnchor:SetHeight((C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
elseif C["ActionBar"].BottomBars == 3 then
	if C["ActionBar"].SplitBars == true then
		BottomBarAnchor:SetHeight((C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
	else
		BottomBarAnchor:SetHeight((C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2))
	end
else
	BottomBarAnchor:SetHeight(C["ActionBar"].ButtonSize)
end
BottomBarAnchor:SetFrameStrata("LOW")
Movers:RegisterFrame(BottomBarAnchor)

-- Right bars anchor
local RightBarAnchor = CreateFrame("Frame", "RightActionBarAnchor", K.PetBattleHider)
RightBarAnchor:CreatePanel("Invisible", 1, 1, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 330)
RightBarAnchor:SetHeight((C["ActionBar"].ButtonSize * 12) + (C["ActionBar"].ButtonSpace * 11))
if C["ActionBar"].RightBars == 1 then
	RightBarAnchor:SetWidth(C["ActionBar"].ButtonSize)
elseif C["ActionBar"].RightBars == 2 then
	RightBarAnchor:SetWidth((C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
elseif C["ActionBar"].RightBars == 3 then
	RightBarAnchor:SetWidth((C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2))
else
	RightBarAnchor:Hide()
end
RightBarAnchor:SetFrameStrata("LOW")
Movers:RegisterFrame(RightBarAnchor)

-- Split bar anchor
if C["ActionBar"].SplitBars == true then
	local SplitBarLeft = CreateFrame("Frame", "SplitBarLeft", K.PetBattleHider)
	SplitBarLeft:CreatePanel("Invisible", (C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2), (C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace, "BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C["ActionBar"].ButtonSpace, 0)
	SplitBarLeft:SetFrameStrata("LOW")

	local SplitBarRight = CreateFrame("Frame", "SplitBarRight", K.PetBattleHider)
	SplitBarRight:CreatePanel("Invisible", (C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2), (C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace, "BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", C["ActionBar"].ButtonSpace, 0)
	SplitBarRight:SetFrameStrata("LOW")
end

-- Pet bar anchor
local PetBarAnchor = CreateFrame("Frame", "PetActionBarAnchor", K.PetBattleHider)
if C["ActionBar"].PetBarHorizontal == true then
	PetBarAnchor:CreatePanel("Invisible", (C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9), (C["ActionBar"].ButtonSize + C["ActionBar"].ButtonSpace),"BOTTOMRIGHT", UIParent, "BOTTOM", -175, 167)
elseif C["ActionBar"].RightBars > 0 then
	PetBarAnchor:CreatePanel("Invisible", C["ActionBar"].ButtonSize + 6, (C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9), "RIGHT", RightBarAnchor, "LEFT", 0, 0)
else
	PetBarAnchor:CreatePanel("Invisible", (C["ActionBar"].ButtonSize + C["ActionBar"].ButtonSpace), (C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9), "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 330)
end
PetBarAnchor:SetFrameStrata("LOW")
RegisterStateDriver(PetBarAnchor, "visibility", "[pet,novehicleui,nopossessbar,nopetbattle] show; hide")
Movers:RegisterFrame(PetBarAnchor)

-- Stance bar anchor
local ShiftAnchor = CreateFrame("Frame", "ShapeShiftBarAnchor", K.PetBattleHider)
ShiftAnchor:RegisterEvent("PLAYER_LOGIN")
ShiftAnchor:RegisterEvent("PLAYER_ENTERING_WORLD")
ShiftAnchor:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
ShiftAnchor:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
ShiftAnchor:SetScript("OnEvent", function(self, event, ...)
	local Forms = GetNumShapeshiftForms()
	if Forms > 0 then
		if C["ActionBar"].StanceBarHorizontal ~= true then
			ShiftAnchor:SetWidth(C["ActionBar"].ButtonSize + 3)
			ShiftAnchor:SetHeight((C["ActionBar"].ButtonSize * Forms) + ((C["ActionBar"].ButtonSpace * Forms) - 3))
			ShiftAnchor:SetPoint("TOPLEFT", _G["StanceButton1"], "TOPLEFT")
		else
			ShiftAnchor:SetWidth((C["ActionBar"].ButtonSize * Forms) + ((C["ActionBar"].ButtonSpace * Forms) - 3))
			ShiftAnchor:SetHeight(C["ActionBar"].ButtonSize)
			ShiftAnchor:SetPoint("TOPLEFT", _G["StanceButton1"], "TOPLEFT")
		end
	end
end)

if C["Chat"].Background then
	local chatBG = CreateFrame("Frame", "ChatBackground", UIParent)
	chatBG:SetBackdrop({bgFile = C["Media"].Blank, edgeFile = C["Media"].Glow, edgeSize = 3, insets = {left = 3, right = 3, top = 3, bottom = 3}})
	chatBG:SetFrameLevel(1)
	chatBG:SetFrameStrata("BACKGROUND")
	chatBG:SetSize(C["Chat"].Width + 7, C["Chat"].Height + 9)
	chatBG:ClearAllPoints()
	chatBG:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -4, 5)
	chatBG:SetBackdropBorderColor(0, 0, 0, C["Chat"].BackgroundAlpha or 0.25)
	chatBG:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Chat"].BackgroundAlpha or 0.25)
end