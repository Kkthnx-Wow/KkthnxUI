local K, C, L, _ = select(2, ...):unpack()

-- LUA API
local unpack = unpack
local _G = _G

-- WOW API
local CreateFrame = CreateFrame
local UIParent = UIParent

--	BOTTOM BARS ANCHOR
local BottomBarAnchor = CreateFrame("Frame", "ActionBarAnchor", PetBattleFrameHider)
BottomBarAnchor:CreatePanel("Invisible", 1, 1, unpack(C.Position.BottomBars))
BottomBarAnchor:SetWidth((C.ActionBar.ButtonSize * 12) + (C.ActionBar.ButtonSpace * 11))
if C.ActionBar.BottomBars == 2 then
	BottomBarAnchor:SetHeight((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
elseif C.ActionBar.BottomBars == 3 then
	if C.ActionBar.SplitBars == true then
		BottomBarAnchor:SetHeight((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
	else
		BottomBarAnchor:SetHeight((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
	end
else
	BottomBarAnchor:SetHeight(C.ActionBar.ButtonSize)
end
BottomBarAnchor:SetFrameStrata("LOW")
RegisterStateDriver(BottomBarAnchor, "visibility", "[petbattle] hide; show")

--	RIGHT BARS ANCHOR
local RightBarAnchor = CreateFrame("Frame", "RightActionBarAnchor", PetBattleFrameHider)
RightBarAnchor:CreatePanel("Invisible", 1, 1, unpack(C.Position.RightBars))
RightBarAnchor:SetHeight((C.ActionBar.ButtonSize * 12) + (C.ActionBar.ButtonSpace * 11))
if C.ActionBar.RightBars == 1 then
	RightBarAnchor:SetWidth(C.ActionBar.ButtonSize)
elseif C.ActionBar.RightBars == 2 then
	RightBarAnchor:SetWidth((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
elseif C.ActionBar.RightBars == 3 then
	RightBarAnchor:SetWidth((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
else
	RightBarAnchor:Hide()
end
RightBarAnchor:SetFrameStrata("LOW")
--RegisterStateDriver(RightBarAnchor, "visibility", "[vehicleui][petbattle][overridebar] hide; show")

--	SPLIT BAR ANCHOR
if C.ActionBar.SplitBars == true then
	local SplitBarLeft = CreateFrame("Frame", "SplitBarLeft", PetBattleFrameHider)
	SplitBarLeft:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2), (C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace, "BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
	SplitBarLeft:SetFrameStrata("LOW")
	--RegisterStateDriver(SplitBarLeft, "visibility", "[petbattle] hide; show")

	local SplitBarRight = CreateFrame("Frame", "SplitBarRight", PetBattleFrameHider)
	SplitBarRight:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2), (C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace, "BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", C.ActionBar.ButtonSpace, 0)
	SplitBarRight:SetFrameStrata("LOW")
	--RegisterStateDriver(SplitBarRight, "visibility", "[petbattle] hide; show")
end

--	PET BAR ANCHOR
local PetBarAnchor = CreateFrame("Frame", "PetActionBarAnchor", PetBattleFrameHider)
if C.ActionBar.PetBarHorizontal == true then
	PetBarAnchor:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), (C.ActionBar.ButtonSize + C.ActionBar.ButtonSpace), unpack(C.Position.PetHorizontal))
elseif C.ActionBar.RightBars > 0 then
	PetBarAnchor:CreatePanel("Invisible", C.ActionBar.ButtonSize + 3, (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), "RIGHT", RightBarAnchor, "LEFT", 0, 0)
else
	PetBarAnchor:CreatePanel("Invisible", (C.ActionBar.ButtonSize + C.ActionBar.ButtonSpace), (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), unpack(C.Position.RightBars))
end
PetBarAnchor:SetFrameStrata("LOW")
--RegisterStateDriver(PetBarAnchor, "visibility", "[pet,nopetbattle,novehicleui,nooverridebar,nobonusbar:5] show; hide")

-- STANCE BAR ANCHOR
local ShiftAnchor = CreateFrame("Frame", "ShapeShiftBarAnchor", PetBattleFrameHider)
ShiftAnchor:RegisterEvent("PLAYER_LOGIN")
ShiftAnchor:RegisterEvent("PLAYER_ENTERING_WORLD")
ShiftAnchor:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
ShiftAnchor:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
ShiftAnchor:SetScript("OnEvent", function(self, event, ...)
	local Forms = GetNumShapeshiftForms()
	if Forms > 0 then
		if C.ActionBar.StanceBarHorizontal ~= true then
			ShiftAnchor:SetWidth(C.ActionBar.ButtonSize + 3)
			ShiftAnchor:SetHeight((C.ActionBar.ButtonSize * Forms) + ((C.ActionBar.ButtonSpace * Forms) - 3))
			ShiftAnchor:SetPoint("TOPLEFT", _G["StanceButton1"], "TOPLEFT")
		else
			ShiftAnchor:SetWidth((C.ActionBar.ButtonSize * Forms) + ((C.ActionBar.ButtonSpace * Forms) - 3))
			ShiftAnchor:SetHeight(C.ActionBar.ButtonSize)
			ShiftAnchor:SetPoint("TOPLEFT", _G["StanceButton1"], "TOPLEFT")
		end
	end
end)
--RegisterStateDriver(ShiftAnchor, "visibility", "[vehicleui][petbattle] hide; show")