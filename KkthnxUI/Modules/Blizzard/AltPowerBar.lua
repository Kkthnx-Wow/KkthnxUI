local K, C = unpack(select(2, ...))
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
	local statusBar = K.GetTexture(C["General"].Texture)
	local font = K.GetFont(C["General"].Font)

	bar:SetSize(width, height)
	bar:SetStatusBarTexture(statusBar)
	bar.text:SetFontObject(font)
	AltPowerBarHolder:SetSize(bar.Backdrop:GetSize())

	local _, _, perc = bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0
	bar.text:SetText(format("%s%%", perc))
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

				local r, g, b = K.ColorGradient(value, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
				bar.colorGradientR, bar.colorGradientG, bar.colorGradientB = r, g, b

				bar:SetStatusBarColor(r, g, b)
			end

			bar.text:SetText(format("%s%%", perc))
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