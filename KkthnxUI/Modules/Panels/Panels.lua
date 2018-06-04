local K, C = unpack(select(2, ...))

-- Lua API
local _G = _G

-- Wow API
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: KkthnxUIConfigFrame, KkthnxUIConfig
-- GLOBALS: Skada, UIConfigMain, CreateUIConfig, HideUIPanel, Menu, GameTooltip
-- GLOBALS: UIErrorsFrame, ERR_NOT_IN_COMBAT, Lib_EasyMenu, Recount_MainWindow

local Movers = K.Movers

-- Bottom bars anchor
local BottomBarAnchor = CreateFrame("Frame", "ActionBarAnchor", K.PetBattleHider)
BottomBarAnchor:SetSize(1, 1)
BottomBarAnchor:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 4)
BottomBarAnchor:SetFrameLevel(0)
BottomBarAnchor:SetFrameStrata("BACKGROUND")
BottomBarAnchor:SetWidth((C["ActionBar"].ButtonSize * 12) + (C["ActionBar"].ButtonSpace * 11))
if (C["ActionBar"].BottomBars == 2) then
	BottomBarAnchor:SetHeight((C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
elseif (C["ActionBar"].BottomBars == 3) then
	if (C["ActionBar"].SplitBars == true) then
		BottomBarAnchor:SetHeight((C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
	else
		BottomBarAnchor:SetHeight((C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2))
	end
else
	BottomBarAnchor:SetHeight(C["ActionBar"].ButtonSize)
end
Movers:RegisterFrame(BottomBarAnchor)

-- Right bars anchor
local RightBarAnchor = CreateFrame("Frame", "RightActionBarAnchor", K.PetBattleHider)
RightBarAnchor:SetSize(1, 1)
RightBarAnchor:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -5, 330)
RightBarAnchor:SetFrameLevel(0)
RightBarAnchor:SetFrameStrata("BACKGROUND")
RightBarAnchor:SetHeight((C["ActionBar"].ButtonSize * 12) + (C["ActionBar"].ButtonSpace * 11))
if (C["ActionBar"].RightBars == 1) then
	RightBarAnchor:SetWidth(C["ActionBar"].ButtonSize)
elseif (C["ActionBar"].RightBars == 2) then
	RightBarAnchor:SetWidth((C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
elseif (C["ActionBar"].RightBars == 3) then
	RightBarAnchor:SetWidth((C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2))
else
	RightBarAnchor:Hide()
end
Movers:RegisterFrame(RightBarAnchor)

-- Split bar anchor
if C["ActionBar"].SplitBars then
	local SplitBarLeft = CreateFrame("Frame", "SplitBarLeft", K.PetBattleHider)
	SplitBarLeft:SetSize((C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2), (C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
	SplitBarLeft:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C["ActionBar"].ButtonSpace, 0)
	SplitBarLeft:SetFrameLevel(0)
	SplitBarLeft:SetFrameStrata("BACKGROUND")

	local SplitBarRight = CreateFrame("Frame", "SplitBarRight", K.PetBattleHider)
	RightBarAnchor:SetSize((C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2), (C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
	RightBarAnchor:SetPoint("BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", C["ActionBar"].ButtonSpace, 0)
	SplitBarRight:SetFrameLevel(0)
	SplitBarRight:SetFrameStrata("BACKGROUND")
end

-- Pet bar anchor
local PetBarAnchor = CreateFrame("Frame", "PetActionBarAnchor", K.PetBattleHider)
PetBarAnchor:SetFrameLevel(0)
PetBarAnchor:SetFrameStrata("BACKGROUND")
if C["ActionBar"].PetBarHorizontal then
	PetBarAnchor:SetSize((C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9), (C["ActionBar"].ButtonSize + C["ActionBar"].ButtonSpace))
	PetBarAnchor:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOM", -175, 167)
elseif (C["ActionBar"].RightBars > 0) then
	PetBarAnchor:SetSize(C["ActionBar"].ButtonSize + 6, (C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9))
	PetBarAnchor:SetPoint("RIGHT", RightBarAnchor, "LEFT", 0, 0)
else
	PetBarAnchor:SetSize((C["ActionBar"].ButtonSize + C["ActionBar"].ButtonSpace), (C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9))
	PetBarAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 330)
end
RegisterStateDriver(PetBarAnchor, "visibility", "[pet,novehicleui,nopossessbar,nopetbattle] show; hide")
Movers:RegisterFrame(PetBarAnchor)

-- Stance bar anchor
local ShiftAnchor = CreateFrame("Frame", "ShapeShiftBarAnchor", K.PetBattleHider)
ShiftAnchor:RegisterEvent("PLAYER_LOGIN")
ShiftAnchor:RegisterEvent("PLAYER_ENTERING_WORLD")
ShiftAnchor:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
ShiftAnchor:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
ShiftAnchor:SetFrameLevel(0)
ShiftAnchor:SetFrameStrata("BACKGROUND")
ShiftAnchor:SetScript("OnEvent", function()
	local NumForms = GetNumShapeshiftForms()
	if (NumForms > 0) then
		if not C["ActionBar"].StanceBarHorizontal then
			ShiftAnchor:SetWidth(C["ActionBar"].ButtonSize + 3)
			ShiftAnchor:SetHeight((C["ActionBar"].ButtonSize * NumForms) + ((C["ActionBar"].ButtonSpace * NumForms) - 3))
			ShiftAnchor:SetPoint("TOPLEFT", _G["StanceButton1"], "TOPLEFT")
		else
			ShiftAnchor:SetWidth((C["ActionBar"].ButtonSize * NumForms) + ((C["ActionBar"].ButtonSpace * NumForms) - 3))
			ShiftAnchor:SetHeight(C["ActionBar"].ButtonSize)
			ShiftAnchor:SetPoint("TOPLEFT", _G["StanceButton1"], "TOPLEFT")
		end
	end
end)

if C["Filger"].Enable then
	local AnchorPlayer = CreateFrame("Frame", AnchorPlayer, UIParent)
	AnchorPlayer:SetSize(190, 52)
	AnchorPlayer:SetPoint("BOTTOMRIGHT", BottomBarAnchor, "TOPLEFT", -10, 200)
	AnchorPlayer:SetFrameLevel(0)
	AnchorPlayer:SetFrameStrata("BACKGROUND")

	local AnchorTarget = CreateFrame("Frame", AnchorTarget, UIParent)
	AnchorTarget:SetSize(190, 52)
	AnchorTarget:SetPoint("BOTTOMLEFT", BottomBarAnchor, "TOPRIGHT", 10, 200)
	AnchorPlayer:SetFrameLevel(0)
	AnchorPlayer:SetFrameStrata("BACKGROUND")
end

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