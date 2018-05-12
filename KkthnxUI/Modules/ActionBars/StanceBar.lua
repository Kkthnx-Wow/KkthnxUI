local K, C, L = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local GetShapeshiftFormInfo = _G.GetShapeshiftFormInfo
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local RegisterStateDriver = _G.RegisterStateDriver

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: StanceButton1, RightBarMouseOver, HoverBind, StanceBarMouseOver, UIParent
-- GLOBALS: CreateFrame

local Movers = K.Movers

local ShiftHolder = CreateFrame("Frame", "ShiftHolder", K.PetBattleHider)
if C["ActionBar"].StanceBarHorizontal == true then
	ShiftHolder:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOM", -202, 167)
	ShiftHolder:SetWidth((C["ActionBar"].ButtonSize * 7) + (C["ActionBar"].ButtonSpace * 6))
	ShiftHolder:SetHeight(C["ActionBar"].ButtonSize)
else
	if (PetActionBarFrame:IsShown() or PetHolder) and C["ActionBar"].PetBarHorizontal ~= true then
		ShiftHolder:SetPoint("RIGHT", "PetHolder", "LEFT", -C["ActionBar"].ButtonSpace, (C["ActionBar"].ButtonSize / 2) + 1)
	else
		ShiftHolder:SetPoint("RIGHT", "RightActionBarAnchor", "LEFT", -C["ActionBar"].ButtonSpace, (C["ActionBar"].ButtonSize / 2) + 1)
	end
	ShiftHolder:SetWidth(C["ActionBar"].ButtonSize)
	ShiftHolder:SetHeight((C["ActionBar"].ButtonSize * 7) + (C["ActionBar"].ButtonSpace * 6))
end
Movers:RegisterFrame(ShiftHolder)

-- HIDE BAR
if C["ActionBar"].StanceBarHide then
	ShiftHolder:Hide()
	return
end

-- CREATE BAR
local StanceBar = CreateFrame("Frame", "UIShapeShift", ShiftHolder, "SecureHandlerStateTemplate")
StanceBar:ClearAllPoints()
StanceBar:SetAllPoints(ShiftHolder)

local States = {
	["DEATHKNIGHT"] = "show",
	["DRUID"] = "show",
	["MONK"] = "show",
	["PALADIN"] = "show",
	["PRIEST"] = "show",
	["ROGUE"] = "show",
	["WARLOCK"] = "show",
	["WARRIOR"] = "show",
}

StanceBar:RegisterEvent("PLAYER_LOGIN")
StanceBar:RegisterEvent("PLAYER_ENTERING_WORLD")
StanceBar:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
StanceBar:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
StanceBar:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
StanceBar:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
StanceBar:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
StanceBar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		for i = 1, NUM_STANCE_SLOTS do
			local button = _G["StanceButton"..i]
			button:ClearAllPoints()
			button:SetParent(self)
			if i == 1 then
				if C["ActionBar"].StanceBarHorizontal == true then
					button:SetPoint("BOTTOMLEFT", ShiftHolder, "BOTTOMLEFT", 0, 0)
				else
					button:SetPoint("TOPLEFT", ShiftHolder, "TOPLEFT", 0, 0)
				end
			else
				local previous = _G["StanceButton"..i-1]
				if C["ActionBar"].StanceBarHorizontal == true then
					button:SetPoint("LEFT", previous, "RIGHT", C["ActionBar"].ButtonSpace, 0)
				else
					button:SetPoint("TOP", previous, "BOTTOM", 0, -C["ActionBar"].ButtonSpace)
				end
			end
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
			else
				button:Hide()
			end
		end
		RegisterStateDriver(self, "visibility", States[K.Class] or "hide")
		local function movestance()
			if not InCombatLockdown() then
				if C["ActionBar"].StanceBarHorizontal == true then
					StanceButton1:SetPoint("BOTTOMLEFT", ShiftHolder, "BOTTOMLEFT", 0, 0)
				else
					StanceButton1:SetPoint("TOPLEFT", ShiftHolder, "TOPLEFT", 0, 0)
				end
			end
		end
		hooksecurefunc("StanceBar_Update", movestance)
	elseif event == "UPDATE_SHAPESHIFT_FORMS" then
		if InCombatLockdown() then return end
		for i = 1, NUM_STANCE_SLOTS do
			local button = _G["StanceButton"..i]
			local _, name = GetShapeshiftFormInfo(i)
			if name then
				button:Show()
			else
				button:Hide()
			end
		end
		K.ShiftBarUpdate()
	elseif event == "PLAYER_ENTERING_WORLD" then
		K.StyleShift()
	else
		K.ShiftBarUpdate()
	end
end)

-- Mouseover bar
if C["ActionBar"].RightBarsMouseover == true and C["ActionBar"].StanceBarHorizontal == false then
	for i = 1, NUM_STANCE_SLOTS do
		local b = _G["StanceButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then RightBarMouseOver(0) end end)
	end
end

if C["ActionBar"].StanceBarMouseover == true and C["ActionBar"].StanceBarHorizontal == true then
	ShapeShiftBarAnchor:SetAlpha(0)
	ShapeShiftBarAnchor:SetScript("OnEnter", function() StanceBarMouseOver(1) end)
	ShapeShiftBarAnchor:SetScript("OnLeave", function() if not HoverBind.enabled then StanceBarMouseOver(0) end end)
	for i = 1, NUM_STANCE_SLOTS do
		local b = _G["StanceButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() StanceBarMouseOver(1) end)
		b:HookScript("OnLeave", function() if not HoverBind.enabled then StanceBarMouseOver(0) end end)
	end
end