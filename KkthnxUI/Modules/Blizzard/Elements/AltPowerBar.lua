local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local floor = _G.floor
local format = _G.format
local CreateFrame = _G.CreateFrame
local UnitPowerMax = _G.UnitPowerMax
local UnitPower = _G.UnitPower
local GetUnitPowerBarInfo = _G.GetUnitPowerBarInfo
local GetUnitPowerBarStrings = _G.GetUnitPowerBarStrings

local AltPowerWidth = 250
local AltPowerHeight = 20

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

function Module:SetAltPowerBarText(text, name, value, max, percent)
	local textFormat = "NAMECURMAX"
	if textFormat == "NONE" or not textFormat then
		text:SetText("")
	elseif textFormat == "NAME" then
		text:SetText(format("%s", name))
	elseif textFormat == "NAMEPERC" then
		text:SetText(format("%s: %s%%", name, percent))
	elseif textFormat == "NAMECURMAX" then
		text:SetText(format("%s: %s / %s", name, value, max))
	elseif textFormat == "NAMECURMAXPERC" then
		text:SetText(format("%s: %s / %s - %s%%", name, value, max, percent))
	elseif textFormat == "PERCENT" then
		text:SetText(format("%s%%", percent))
	elseif textFormat == "CURMAX" then
		text:SetText(format("%s / %s", value, max))
	elseif textFormat == "CURMAXPERC" then
		text:SetText(format("%s / %s - %s%%", value, max, percent))
	end
end

function Module:PositionAltPowerBar()
	local holder = CreateFrame("Frame", "AltPowerBarHolder", UIParent)
	holder:SetPoint("TOP", UIParent, "TOP", -1, -108)
	holder:SetSize(128, 50)

	_G.PlayerPowerBarAlt:ClearAllPoints()
	_G.PlayerPowerBarAlt:SetPoint("CENTER", holder, "CENTER")
	_G.PlayerPowerBarAlt:SetParent(holder)
	_G.PlayerPowerBarAlt:SetMovable(true)
	_G.PlayerPowerBarAlt:SetUserPlaced(true)
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.PlayerPowerBarAlt = nil

	K.Mover(holder, "PlayerPowerBarAlt", "Alternative Power", {"TOP", UIParent, "TOP", -1, -108}, AltPowerWidth or 250, AltPowerHeight or 20)
end

function Module:UpdateAltPowerBarColors()
	local bar = _G.KKUI_AltPowerBar

	local color = {r = 0.2, g = 0.4, b = 0.8}
	bar:SetStatusBarColor(color.r, color.g, color.b)
end

function Module:UpdateAltPowerBarSettings()
	local bar = _G.KKUI_AltPowerBar

	bar:SetSize(AltPowerWidth or 250, AltPowerHeight or 20)
	bar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
	bar.text:FontTemplate()

	_G.AltPowerBarHolder:SetSize(bar:GetSize())

	K:SmoothBar(bar)

	Module:SetAltPowerBarText(bar.text, bar.powerName or "", bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0)
end

function Module:UpdateAltPowerBar()
	_G.PlayerPowerBarAlt:UnregisterAllEvents()
	_G.PlayerPowerBarAlt:Hide()

	local barInfo = GetUnitPowerBarInfo("player")
	local powerName, powerTooltip = GetUnitPowerBarStrings("player")
	if barInfo then
		local power = UnitPower("player", _G.ALTERNATE_POWER_INDEX)
		local maxPower = UnitPowerMax("player", _G.ALTERNATE_POWER_INDEX) or 0
		local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0

		self.powerMaxValue = maxPower
		self.powerName = powerName
		self.powerPercent = perc
		self.powerTooltip = powerTooltip
		self.powerValue = power

		self:Show()
		self:SetMinMaxValues(barInfo.minPower, maxPower)
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
	powerbar:CreateBorder()
	powerbar:SetMinMaxValues(0, 200)
	powerbar:SetPoint("CENTER", _G.AltPowerBarHolder)
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
	powerbar:SetScript("OnEvent", Module.UpdateAltPowerBar)
end


function Module:CreateAltPowerbar()
	if IsAddOnLoaded("SimplePowerBar") then
		return
	end

	self:PositionAltPowerBar()
	self:SkinAltPowerBar()
end