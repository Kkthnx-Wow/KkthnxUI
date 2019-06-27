local K, C = unpack(select(2, ...))
local Module = K:NewModule("AltPowerBar", "AceEvent-3.0", "AceHook-3.0")

if not Module then
	return
end

local _G = _G
local floor = math.floor
local format = string.format

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local UnitAlternatePowerInfo = _G.UnitAlternatePowerInfo
local UnitPowerMax = _G.UnitPowerMax
local UnitPower = _G.UnitPower

local statusBarColorGradient = false
local statusBarColor = {r = 0.2, g = 0.4, b = 0.8}
local textFormat = "NAMECURMAX"
local enable = true
local width = 250
local height = 20
local statusBar = K.GetTexture(C["UITextures"].GeneralTextures)
local font = K.GetFont(C["UIFonts"].GeneralFonts)

local function updateTooltip(self)
	if _G.GameTooltip:IsForbidden() then
		return
	end

	if self.powerName and self.powerTooltip then
		_G.GameTooltip:SetText(self.powerName, 1, 1, 1)
		_G.GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
		_G.GameTooltip:Show()
	end
end

local function onEnter(self)
	if not self:IsVisible() then
		return
	end

	_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, self)
	updateTooltip(self)
end

local function onLeave()
	_G.GameTooltip:Hide()
end

function Module:SetAltPowerBarText(name, value, max, percent)
	local textFormat = textFormat

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

	_G.PlayerPowerBarAlt:ClearAllPoints()
	_G.PlayerPowerBarAlt:SetPoint("CENTER", holder, "CENTER")
	_G.PlayerPowerBarAlt:SetParent(holder)
	_G.PlayerPowerBarAlt.ignoreFramePositionManager = true

	--[[ The Blizzard function FramePositionDelegate:UIParentManageFramePositions()
	calls :ClearAllPoints on PlayerPowerBarAlt under certain conditions.
	Doing ".ClearAllPoints = K.Noop" causes error when you enter combat. --]]
	local function Position(bar) bar:SetPoint("CENTER", AltPowerBarHolder, "CENTER") end
	hooksecurefunc(_G.PlayerPowerBarAlt, "ClearAllPoints", Position)

	K.Mover(holder, "PlayerPowerBarAlt", "Alternative Power", {"TOP", UIParent, "TOP", 0, -18}, 128, 50)
end

function Module:UpdateAltPowerBarColors()
	local bar = _G.KkthnxUI_AltPowerBar

	if statusBarColorGradient then
		if bar.colorGradientR and bar.colorGradientG and bar.colorGradientB then
			bar:SetStatusBarColor(bar.colorGradientR, bar.colorGradientG, bar.colorGradientB)
		elseif bar.powerValue then
			local power, maxPower = bar.powerValue or 0, bar.powerMaxValue or 0
			local value = (maxPower > 0 and power / maxPower) or 0
			bar.colorGradientValue = value

			local r, g, b = K.ColorGradient(value, 0.8,0,0, 0.8,0.8,0, 0,0.8,0)
			bar.colorGradientR, bar.colorGradientG, bar.colorGradientB = r, g, b

			bar:SetStatusBarColor(r, g, b)
		else
			bar:SetStatusBarColor(0.6, 0.6, 0.6) -- uh, fallback!
		end
	else
		local color = statusBarColor
		bar:SetStatusBarColor(color.r, color.g, color.b)
	end
end

function Module:UpdateAltPowerBarSettings()
	local bar = _G.KkthnxUI_AltPowerBar

	bar:SetSize(width or 250, height or 20)
	bar:SetStatusBarTexture(statusBar)
	bar.text:SetFontObject(font)
	AltPowerBarHolder:SetSize(bar.Backdrop:GetSize())

	K:SetSmoothing(bar, true)

	local textFormat = textFormat
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
	powerbar.Backdrop:SetFrameLevel(1)
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
		_G.PlayerPowerBarAlt:UnregisterAllEvents()
		_G.PlayerPowerBarAlt:Hide()

		local barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo("player")
		if not barType then
			barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo("target")
		end

		bar.powerName = powerName
		bar.powerTooltip = powerTooltip

		if barType then
			local power = UnitPower("player", _G.ALTERNATE_POWER_INDEX)
			local maxPower = UnitPowerMax("player", _G.ALTERNATE_POWER_INDEX) or 0
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

function Module:OnEnable()
	if not IsAddOnLoaded("SimplePowerBar") then
		self:PositionAltPowerBar()
		self:SkinAltPowerBar()
	end
end