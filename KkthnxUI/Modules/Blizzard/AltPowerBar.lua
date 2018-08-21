local K, C = unpack(select(2, ...))
if IsAddOnLoaded("SimplePowerBar") then
	return
end

local Module = K:NewModule("AltPowerBar", "AceEvent-3.0", "AceHook-3.0")

local _G = _G

local floor = math.floor
local format = string.format
local UnitAlternatePowerInfo = _G.UnitAlternatePowerInfo
local UnitPowerMax = _G.UnitPowerMax
local UnitPower = _G.UnitPower

local statusBarColorGradient = true

local function updateTooltip(self)
	if GameTooltip:IsForbidden() then
		return
	end

	if self.powerName and self.powerTooltip then
		GameTooltip:SetText(self.powerName, 1, 1, 1)
		GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
		GameTooltip:Show()
	end
end

local function onEnter(self)
	if not self:IsVisible() then
		return
	end

	GameTooltip_SetDefaultAnchor(GameTooltip, self)
	updateTooltip(self)
end

local function onLeave()
	GameTooltip:Hide()
end

function Module:SetAltPowerBarText(name, value, max, percent)
	local textFormat = "PERCENT" -- altPowerBar.textFormat

	if textFormat == "NONE" or not textFormat then
		return ""
	elseif textFormat == "NAME" then
		return format("%s", name)
	elseif textFormat == "NAMEPERC" then
		return format("%s: %s%%", name, percent)
	elseif textFormat == "NAMECURMAX" then
		return format("%s: %s / %s", name, value, max)
	elseif textFormat == "NAMECURMAXPERC" then
		return format("%s: %s / %s - %s%%", name, value, max, percent)
	elseif textFormat == "PERCENT" then
		return format("%s%%", percent)
	elseif textFormat == "CURMAX" then
		return format("%s / %s", value, max)
	elseif textFormat == "CURMAXPERC" then
		return format("%s / %s - %s%%", value, max, percent)
	end
end

function Module:PositionAltPowerBar()
	local holder = CreateFrame("Frame", "AltPowerBarHolder", UIParent)
	holder:SetPoint("TOP", UIParent, "TOP", 0, -18)
	holder:SetSize(128, 50)

	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint("CENTER", holder, "CENTER")
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt.ignoreFramePositionManager = true

	-- The Blizzard function FramePositionDelegate:UIParentManageFramePositions()
	-- calls :ClearAllPoints on PlayerPowerBarAlt under certain conditions.
	-- Doing ".ClearAllPoints = E.noop" causes error when you enter combat.
	local function Position(bar)
		bar:SetPoint("CENTER", AltPowerBarHolder, "CENTER")
	end
	hooksecurefunc(PlayerPowerBarAlt, "ClearAllPoints", Position)

	K.Movers:RegisterFrame(holder)
end

function Module:UpdateAltPowerBarColors()
	local bar = KkthnxUI_AltPowerBar

	if statusBarColorGradient then
		if bar.colorGradientR and bar.colorGradientG and bar.colorGradientB then
			bar:SetStatusBarColor(bar.colorGradientR, bar.colorGradientG, bar.colorGradientB)
		elseif bar.powerValue then
			local power, maxPower = bar.powerValue or 0, bar.powerMaxValue or 0
			local value = (maxPower > 0 and power / maxPower) or 0
			bar.colorGradientValue = value

			local r, g, b = K.ColorGradient(value, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
			bar.colorGradientR, bar.colorGradientG, bar.colorGradientB = r, g, b

			bar:SetStatusBarColor(r, g, b)
		else
			bar:SetStatusBarColor(0.6, 0.6, 0.6) -- uh, fallback!
		end
	else
		bar:SetStatusBarColor(0.2, 0.4, 0.8)
	end
end

function Module:UpdateAltPowerBarSettings()
	local bar = KkthnxUI_AltPowerBar
	local width = 250
	local height = 20
	local fontOutline = ""
	local fontSize = 12
	local statusBar = C.Media.Texture
	local font = C.Media.Font

	bar:SetSize(width, height)
	bar:SetStatusBarTexture(statusBar)
	bar.text:SetFont(font, fontSize, fontOutline)
	AltPowerBarHolder:SetSize(bar.Backdrop:GetSize())

	local textFormat = "PERCENT"
	if textFormat == "NONE" or not textFormat then
		bar.text:SetText("")
	else
		local power, maxPower, perc = bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0
		local text = Module:SetAltPowerBarText(bar.powerName or "", power, maxPower, perc)
		bar.text:SetText(text)
	end
end

function Module:SkinAltPowerBar()
	local powerbar = CreateFrame("StatusBar", "KkthnxUI_AltPowerBar", UIParent)
	powerbar:CreateBackdrop()
	powerbar:SetMinMaxValues(0, 200)
	powerbar:SetPoint("CENTER", AltPowerBarHolder)
	powerbar:Hide()

	powerbar:SetScript("OnEnter", onEnter)
	powerbar:SetScript("OnLeave", onLeave)

	powerbar.text = powerbar:CreateFontString(nil, "OVERLAY")
	powerbar.text:SetPoint("CENTER", powerbar, "CENTER")
	powerbar.text:SetJustifyH("CENTER")

	Module:UpdateAltPowerBarSettings()
	Module:UpdateAltPowerBarColors()

	-- Event handling
	powerbar:RegisterEvent("UNIT_POWER_UPDATE")
	powerbar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	powerbar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	powerbar:RegisterEvent("PLAYER_ENTERING_WORLD")
	powerbar:SetScript("OnEvent", function(bar)
		PlayerPowerBarAlt:UnregisterAllEvents()
		PlayerPowerBarAlt:Hide()

		local barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo("player")
		if not barType then
			barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo("target")
		end

		bar.powerName = powerName
		bar.powerTooltip = powerTooltip

		if barType then
			local power = UnitPower("player", ALTERNATE_POWER_INDEX)
			local maxPower = UnitPowerMax("player", ALTERNATE_POWER_INDEX) or 0
			local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0

			bar.powerValue = power
			bar.powerMaxValue = maxPower
			bar.powerPercent = perc

			bar:Show()
			bar:SetMinMaxValues(min, maxPower)
			bar:SetValue(power)

			if statusBarColorGradient then
				local value = (maxPower > 0 and power / maxPower) or 0
				bar.colorGradientValue = value

				local r, g, b = K.ColorGradient(value, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
				bar.colorGradientR, bar.colorGradientG, bar.colorGradientB = r, g, b

				bar:SetStatusBarColor(r, g, b)
			end

			local text = Module:SetAltPowerBarText(powerName or "", power, maxPower, perc)
			bar.text:SetText(text)
		else
			bar:Hide()
		end
	end)
end