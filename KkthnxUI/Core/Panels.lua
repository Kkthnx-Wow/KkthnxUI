local K, C, L, _ = select(2, ...):unpack()

local unpack = unpack
local _G = _G
local CreateFrame = CreateFrame
local UIParent = UIParent

--	Bottom bars anchor
local bottombaranchor = CreateFrame("Frame", "ActionBarAnchor", UIParent)
bottombaranchor:CreatePanel("Invisible", 1, 1, unpack(C.Position.BottomBars))
bottombaranchor:SetWidth((C.ActionBar.ButtonSize * 12) + (C.ActionBar.ButtonSpace * 11))
if C.ActionBar.BottomBars == 2 then
	bottombaranchor:SetHeight((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
elseif C.ActionBar.BottomBars == 3 then
	if C.ActionBar.SplitBars == true then
		bottombaranchor:SetHeight((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
	else
		bottombaranchor:SetHeight((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
	end
else
	bottombaranchor:SetHeight(C.ActionBar.ButtonSize)
end
bottombaranchor:SetFrameStrata("LOW")

--	Right bars anchor
local rightbaranchor = CreateFrame("Frame", "RightActionBarAnchor", UIParent)
rightbaranchor:CreatePanel("Invisible", 1, 1, unpack(C.Position.RightBars))
rightbaranchor:SetHeight((C.ActionBar.ButtonSize * 12) + (C.ActionBar.ButtonSpace * 11))
if C.ActionBar.RightBars == 1 then
	rightbaranchor:SetWidth(C.ActionBar.ButtonSize)
elseif C.ActionBar.RightBars == 2 then
	rightbaranchor:SetWidth((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
elseif C.ActionBar.RightBars == 3 then
	rightbaranchor:SetWidth((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
else
	rightbaranchor:Hide()
end
rightbaranchor:SetFrameStrata("LOW")

--	Split bar anchor
if C.ActionBar.SplitBars == true then
	local SplitBarLeft = CreateFrame("Frame", "SplitBarLeft", UIParent)
	SplitBarLeft:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2), (C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace, "BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
	SplitBarLeft:SetFrameStrata("LOW")

	local SplitBarRight = CreateFrame("Frame", "SplitBarRight", UIParent)
	SplitBarRight:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2), (C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace, "BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", C.ActionBar.ButtonSpace, 0)
	SplitBarRight:SetFrameStrata("LOW")
end

--	Pet bar anchor
local petbaranchor = CreateFrame("Frame", "PetActionBarAnchor", UIParent)
if C.ActionBar.PetBarHorizontal == true then
	petbaranchor:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), (C.ActionBar.ButtonSize + C.ActionBar.ButtonSpace), unpack(C.Position.PetHorizontal))
elseif C.ActionBar.RightBars > 0 then
	petbaranchor:CreatePanel("Invisible", C.ActionBar.ButtonSize + 3, (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), "RIGHT", rightbaranchor, "LEFT", 0, 0)
else
	petbaranchor:CreatePanel("Invisible", (C.ActionBar.ButtonSize + C.ActionBar.ButtonSpace), (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), unpack(C.Position.RightBars))
end
petbaranchor:SetFrameStrata("LOW")
RegisterStateDriver(petbaranchor, "visibility", "[pet,novehicleui,nobonusbar:5] show; hide")

--	Stance bar anchor
local ShiftHolder = CreateFrame("Frame", "ShiftHolder", UIParent)
if C.ActionBar.StanceBarHorizontal == true then
	ShiftHolder:SetPoint(unpack(C.Position.StanceBar))
	ShiftHolder:SetWidth((C.ActionBar.ButtonSize * 7) + (C.ActionBar.ButtonSpace * 6))
	ShiftHolder:SetHeight(C.ActionBar.ButtonSize)
else
	if (PetActionBarFrame:IsShown() or PetHolder) and C.ActionBar.PetBarHorizontal ~= true then
		ShiftHolder:SetPoint("RIGHT", "PetHolder", "LEFT", -C.ActionBar.ButtonSpace, (C.ActionBar.ButtonSize / 2) + 1)
	else
		ShiftHolder:SetPoint("RIGHT", "RightActionBarAnchor", "LEFT", -C.ActionBar.ButtonSpace, (C.ActionBar.ButtonSize / 2) + 1)
	end
	ShiftHolder:SetWidth(C.ActionBar.ButtonSize)
	ShiftHolder:SetHeight((C.ActionBar.ButtonSize * 7) + (C.ActionBar.ButtonSpace * 6))
end