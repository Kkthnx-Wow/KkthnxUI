local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local unpack = unpack
local CreateFrame = CreateFrame
local UIParent = UIParent
local GetRuneCooldown = GetRuneCooldown
local GetTime = GetTime
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHasVehicleUI = UnitHasVehicleUI

if (K.Class == "DEATHKNIGHT" and C.PowerBar.DKRuneBar) then
	for i = 1, 6 do
		RuneFrame:UnregisterAllEvents()
		_G["RuneButtonIndividual"..i]:Hide()
	end
end

if C.PowerBar.Enable ~= true then return end

local PowerBarAnchor = CreateFrame("Frame", "PowerBarAnchor", UIParent)
PowerBarAnchor:SetSize(C.PowerBar.Width, 24)
if not InCombatLockdown() then
	PowerBarAnchor:SetPoint(unpack(C.Position.PowerBar))
end

local f = CreateFrame("Frame", nil, UIParent)
f:SetSize(18, 18)
f:SetPoint("CENTER", PowerBarAnchor, "CENTER", 0, 0)
f:EnableMouse(false)

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("RUNE_TYPE_UPDATE")
f:RegisterEvent("UNIT_COMBO_POINTS")

if (C.PowerBar.Combo) then
	f.ComboPoints = {}

	for i = 1, 5 do
		f.ComboPoints[i] = f:CreateFontString(nil, "ARTWORK")

		if (C.PowerBar.FontOutline) then
			f.ComboPoints[i]:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
			f.ComboPoints[i]:SetShadowOffset(0, 0)
		else
			f.ComboPoints[i]:SetFont(C.Media.Font, C.Media.Font_Size)
			f.ComboPoints[i]:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
		end

		f.ComboPoints[i]:SetParent(f)
		f.ComboPoints[i]:SetText(i)
		f.ComboPoints[i]:SetAlpha(0)
	end

	f.ComboPoints[1]:SetPoint("CENTER", -52, 0)
	f.ComboPoints[2]:SetPoint("CENTER", -26, 0)
	f.ComboPoints[3]:SetPoint("CENTER", 0, 0)
	f.ComboPoints[4]:SetPoint("CENTER", 26, 0)
	f.ComboPoints[5]:SetPoint("CENTER", 52, 0)
end

if (K.Class == "DEATHKNIGHT" and C.PowerBar.RuneCooldown) then
	f.Rune = {}

	for i = 1, 6 do
		f.Rune[i] = f:CreateFontString(nil, "ARTWORK")

		if (C.PowerBar.FontOutline) then
			f.Rune[i]:SetFont(C.Media.Font, C.Media.Font_Size + 4, C.Media.Font_Style)
			f.Rune[i]:SetShadowOffset(0, 0)
		else
			f.Rune[i]:SetFont(C.Media.Font, C.Media.Font_Size + 4)
			f.Rune[i]:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
		end
		f.Rune[i]:SetParent(f)
	end

	f.Rune[1]:SetPoint("CENTER", -65, 0)
	f.Rune[2]:SetPoint("CENTER", -39, 0)
	f.Rune[3]:SetPoint("CENTER", 39, 0)
	f.Rune[4]:SetPoint("CENTER", 65, 0)
	f.Rune[5]:SetPoint("CENTER", -13, 0)
	f.Rune[6]:SetPoint("CENTER", 13, 0)
end

f.Power = CreateFrame("StatusBar", nil, UIParent)
f.Power:SetScale(UIParent:GetScale())
f.Power:SetHeight(C.PowerBar.Height)
f.Power:SetWidth(C.PowerBar.Width)
f.Power:SetPoint("CENTER", f, 0, -23)
f.Power:SetStatusBarTexture(C.Media.Texture)
f.Power:CreatePixelShadow()
f.Power:SetAlpha(0)

f.Power.Value = f.Power:CreateFontString(nil, "ARTWORK")

if (C.PowerBar.FontOutline) then
	f.Power.Value:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	f.Power.Value:SetShadowOffset(0, 0)
else
	f.Power.Value:SetFont(C.Media.Font, C.Media.Font_Size)
	f.Power.Value:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
end

f.Power.Value:SetPoint("CENTER", f.Power, 0, 0)
f.Power.Value:SetVertexColor(1, 1, 1)

f.Power.Background = f.Power:CreateTexture(nil, "BACKGROUND")
f.Power.Background:SetAllPoints(f.Power)
f.Power.Background:SetTexture(C.Media.Blank)
f.Power.Background:SetVertexColor(unpack(C.Media.Backdrop_Color))

local function SetComboColor(i)
	local comboPoints = GetComboPoints("player", "target") or 0

	if (i > comboPoints or UnitIsDeadOrGhost("target")) then
		return 1, 1, 1
	else
		return K.ComboColor[i].r, K.ComboColor[i].g, K.ComboColor[i].b
	end
end

local function SetComboAlpha(i)
	local comboPoints = GetComboPoints("player", "target") or 0

	if (i == comboPoints) then
		return 1
	else
		return 0
	end
end

local function CalcRuneCooldown(self)
	local start, duration, runeReady = GetRuneCooldown(self)
	local time = floor(GetTime() - start)
	local cooldown = ceil(duration - time)

	if (runeReady or UnitIsDeadOrGhost("player")) then
		return "#"
	elseif (not UnitIsDeadOrGhost("player") and cooldown) then
		return cooldown
	end
end

local function SetRuneColor(i)
	if (f.Rune[i].type == 4) then
		return 1, 0, 1
	else
		return K.RuneColor[i].r, K.RuneColor[i].g, K.RuneColor[i].b
	end
end

local function UpdateBarVisibility()
	local _, powerType = UnitPowerType("player")

	if ((not C.PowerBar.Enable and powerType == "ENERGY") or (not C.PowerBar.Rage and powerType == "RAGE") or (not C.PowerBar.Mana and powerType == "MANA") or (not C.PowerBar.Rune and powerType == "RUNEPOWER") or UnitIsDeadOrGhost("player") or UnitHasVehicleUI("player")) then
		f.Power:SetAlpha(0)
	elseif (InCombatLockdown()) then
		securecall("UIFrameFadeIn", f.Power, 0.3, f.Power:GetAlpha(), 1)
	elseif (not InCombatLockdown() and UnitPower("player") > 0) then
		securecall("UIFrameFadeOut", f.Power, 0.3, f.Power:GetAlpha(), 0.4)
	else
		securecall("UIFrameFadeOut", f.Power, 0.3, f.Power:GetAlpha(), 0)
	end
end

local function UpdateBarValue()
	f.Power:SetMinMaxValues(0, UnitPowerMax("player", f))
	f.Power:SetValue(UnitPower("player"))

	local curValue = UnitPower("player")
	if (C.PowerBar.ValueAbbreviate) then
		f.Power.Value:SetText(UnitPower("player") > 0 and K.ShortValue(curValue) or "")
	else
		f.Power.Value:SetText(UnitPower("player") > 0 and curValue or "")
	end
end

local function UpdateBarColor()
	local _, powerType, altR, altG, altB = UnitPowerType("player")
	local unitPower = PowerBarColor[powerType]

	if (unitPower) then
		f.Power:SetStatusBarColor(unitPower.r, unitPower.g, unitPower.b)
	else
		f.Power:SetStatusBarColor(altR, altG, altB)
	end
end

local function UpdateBar()
	UpdateBarColor()
	UpdateBarValue()
end

f:SetScript("OnEvent", function(self, event, arg1)
	if (f.ComboPoints) then
		if (event == "UNIT_COMBO_POINTS" or event == "PLAYER_TARGET_CHANGED") then
			for i = 1, 5 do
				f.ComboPoints[i]:SetTextColor(SetComboColor(i))
				f.ComboPoints[i]:SetAlpha(SetComboAlpha(i))
			end
		end
	end

	if (event == "RUNE_TYPE_UPDATE") then
		f.Rune[arg1].type = GetRuneType(arg1)
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		if (InCombatLockdown()) then
			securecall("UIFrameFadeIn", f, 0.35, f:GetAlpha(), 1)
		else
			securecall("UIFrameFadeOut", f, 0.35, f:GetAlpha(), 0.4)
		end
	end

	if (event == "PLAYER_REGEN_DISABLED") then
		securecall("UIFrameFadeIn", f, 0.35, f:GetAlpha(), 1)
	end

	if (event == "PLAYER_REGEN_ENABLED") then
		securecall("UIFrameFadeOut", f, 0.35, f:GetAlpha(), 0.4)
	end
end)

local updateTimer = 0
f:SetScript("OnUpdate", function(self, elapsed)
	updateTimer = updateTimer + elapsed

	if (updateTimer > 0.1) then
		if (f.Rune) then
			for i = 1, 6 do
				if (UnitHasVehicleUI("player")) then
					if (f.Rune[i]:IsShown()) then
						f.Rune[i]:Hide()
					end
				else
					if (not f.Rune[i]:IsShown()) then
						f.Rune[i]:Show()
					end
				end

				f.Rune[i]:SetText(CalcRuneCooldown(i))
				f.Rune[i]:SetTextColor(SetRuneColor(i))
			end
		end

		UpdateBar()
		UpdateBarVisibility()

		updateTimer = 0
	end
end)