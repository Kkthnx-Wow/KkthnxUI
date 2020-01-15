local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local floor = math.floor
local format = string.format

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local UnitAlternatePowerInfo = _G.UnitAlternatePowerInfo
local UnitPowerMax = _G.UnitPowerMax
local UnitPower = _G.UnitPower

local statusBarColor = {r = 0.2, g = 0.4, b = 0.8}
local statusWidth = 250
local statusHeight = 20
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
	if (not self:IsVisible()) or _G.GameTooltip:IsForbidden() then
		return
	end

	_G.GameTooltip:ClearAllPoints()
	_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, self)
	updateTooltip(self)
end

local function onLeave()
	_G.GameTooltip:Hide()
end

function Module:SetAltPowerBarText(text, name, value, max)
	text:SetText(format('%s: %s / %s', name, value, max))
end

function Module:PositionAltPower()
	self:SetPoint("CENTER", _G.AltPowerBarHolder, "CENTER")
end

function Module:PositionAltPowerBar()
	local holder = CreateFrame("Frame", "AltPowerBarHolder", UIParent)
	holder:SetPoint("TOP", UIParent, "TOP", 0, -46)
	holder:SetSize(128, 50)

	_G.PlayerPowerBarAlt:ClearAllPoints()
	_G.PlayerPowerBarAlt:SetPoint("CENTER", holder, "CENTER")
	_G.PlayerPowerBarAlt:SetParent(holder)
	_G.PlayerPowerBarAlt.ignoreFramePositionManager = true

	-- The Blizzard function FramePositionDelegate:UIParentManageFramePositions()
	-- calls :ClearAllPoints on PlayerPowerBarAlt under certain conditions.
	-- Doing ".ClearAllPoints = K.Noop" causes error when you enter combat.
	hooksecurefunc(_G.PlayerPowerBarAlt, "ClearAllPoints", Module.PositionAltPower)

	K.Mover(holder, "PlayerPowerBarAlt", "Alternative Power", {"TOP", UIParent, "TOP", 0, -46}, statusWidth or 250, statusHeight or 20)
end

function Module:UpdateAltPowerBarColors()
	local bar = _G.KKUI_AltPowerBar
	bar:SetStatusBarColor(statusBarColor.r, statusBarColor.g, statusBarColor.b)
end

function Module:UpdateAltPowerBarSettings()
	local bar = _G.KKUI_AltPowerBar

	bar:SetSize(statusWidth or 250, statusHeight or 20)
	bar:SetStatusBarTexture(statusBar)
	bar.text:SetFontObject(font)
	AltPowerBarHolder:SetSize(bar.Backdrop:GetSize())

	Module:SetAltPowerBarText(bar.text, bar.powerName or "", bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0)
end

function Module:UpdateAltPowerBar()
	_G.PlayerPowerBarAlt:UnregisterAllEvents()
	_G.PlayerPowerBarAlt:Hide()

	local barType, min, _, _, _, _, _, _, _, _, powerName, powerTooltip = UnitAlternatePowerInfo("player")
	if barType then
		local power = UnitPower("player", _G.ALTERNATE_POWER_INDEX)
		local maxPower = UnitPowerMax("player", _G.ALTERNATE_POWER_INDEX) or 0
		local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0

		self.powerMaxValue = maxPower
		self.powerName = powerName
		self.powerPercent = perc
		self.powerTooltip = powerTooltip
		self.powerValue = power

		self:Show()
		self:SetMinMaxValues(min, maxPower)
		self:SetValue(power)

		Module:SetAltPowerBarText(self.text, powerName or "", power or 0, maxPower, perc)
	else
		self.powerMaxValue = nil
		self.powerName = nil
		self.powerPercent = nil
		self.powerTooltip = nil
		self.powerValue = nil

		self:Hide()
	end
end

function Module:SkinAltPowerBar()
	local powerbar = CreateFrame("StatusBar", "KKUI_AltPowerBar", UIParent)
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
	powerbar:RegisterEvent("PLAYER_TARGET_CHANGED")
	powerbar:RegisterEvent("PLAYER_ENTERING_WORLD")
	powerbar:SetScript("OnEvent", Module.UpdateAltPowerBar)
end

function Module:CreateAltPowerbar()
	if not IsAddOnLoaded("SimplePowerBar") then
		self:PositionAltPowerBar()
		self:SkinAltPowerBar()
	end
end