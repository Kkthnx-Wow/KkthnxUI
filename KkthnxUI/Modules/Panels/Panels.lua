local K, C = unpack(select(2, ...))

local _G = _G

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local GetNumShapeshiftForms = _G.GetNumShapeshiftForms

local Movers = K.Movers

-- Bottom bars anchor
local BottomBarAnchor = CreateFrame("Frame", "ActionBarAnchor", K.PetBattleHider)
BottomBarAnchor:SetSize(1, 1)
BottomBarAnchor:SetPoint("BOTTOM", "UIParent", "BOTTOM", 0, 4)
BottomBarAnchor:SetFrameLevel(10)
BottomBarAnchor:SetFrameStrata("LOW")
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
RightBarAnchor:SetPoint("RIGHT", "UIParent", "RIGHT", -5, 8)
RightBarAnchor:SetFrameLevel(10)
RightBarAnchor:SetFrameStrata("LOW")
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
	SplitBarLeft:SetSize((C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2),(C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
	SplitBarLeft:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C["ActionBar"].ButtonSpace, 0)
	SplitBarLeft:SetFrameLevel(10)
	SplitBarLeft:SetFrameStrata("LOW")

	local SplitBarRight = CreateFrame("Frame", "SplitBarRight", K.PetBattleHider)
	SplitBarRight:SetSize((C["ActionBar"].ButtonSize * 3) + (C["ActionBar"].ButtonSpace * 2),(C["ActionBar"].ButtonSize * 2) + C["ActionBar"].ButtonSpace)
	SplitBarRight:SetPoint("BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", C["ActionBar"].ButtonSpace, 0)
	SplitBarRight:SetFrameLevel(10)
	SplitBarRight:SetFrameStrata("LOW")
end

-- Pet bar anchor
local PetBarAnchor = CreateFrame("Frame", "PetActionBarAnchor", K.PetBattleHider)
PetBarAnchor:SetFrameLevel(0)
PetBarAnchor:SetFrameStrata("BACKGROUND")
if C["ActionBar"].PetBarHorizontal then
	PetBarAnchor:SetSize((C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9),(C["ActionBar"].ButtonSize + C["ActionBar"].ButtonSpace))
	PetBarAnchor:SetPoint("BOTTOM", ActionBarAnchor, "TOP", 0, 35)
elseif (C["ActionBar"].RightBars > 0) then
	PetBarAnchor:SetSize(C["ActionBar"].ButtonSize + 6,(C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9))
	PetBarAnchor:SetPoint("RIGHT", RightBarAnchor, "LEFT", 0, 0)
else
	PetBarAnchor:SetSize((C["ActionBar"].ButtonSize + C["ActionBar"].ButtonSpace),(C["ActionBar"].ButtonSize * 10) + (C["ActionBar"].ButtonSpace * 9))
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
ShiftAnchor:SetFrameLevel(10)
ShiftAnchor:SetFrameStrata("LOW")
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

if C["Chat"].Background then
	local chatBG = CreateFrame("Frame", "ChatBackground", UIParent)
	chatBG:SetBackdrop({bgFile = C["Media"].Blank,	edgeFile = C["Media"].Glow,	edgeSize = 3,	insets = {left = 3, right = 3, top = 3, bottom = 3}})
	chatBG:SetFrameLevel(1)
	chatBG:SetFrameStrata("BACKGROUND")
	chatBG:SetSize(C["Chat"].Width + 29, C["Chat"].Height + 12)
	chatBG:ClearAllPoints()
	chatBG:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -4, 5)
	chatBG:SetBackdropBorderColor(0, 0, 0, C["Chat"].BackgroundAlpha or 0.25)
	chatBG:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Chat"].BackgroundAlpha or 0.25)
end