local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- Cache globals
local _G = _G
local math_floor = math.floor
local string_format = string.format
local CreateFrame = CreateFrame
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local GetUnitPowerBarInfo = GetUnitPowerBarInfo
local GetUnitPowerBarStrings = GetUnitPowerBarStrings
local GameTooltip = GameTooltip
local UIParent = UIParent

local AltPowerWidth = 250
local AltPowerHeight = 20

local function updateTooltip(self)
	if GameTooltip:IsForbidden() then
		return
	end

	if self.powerName and self.powerTooltip then
		GameTooltip:SetText(self.powerName, 1, 1, 1)
		GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, true)
		GameTooltip:Show()
	end
end

local function onEnter(self)
	if not self:IsVisible() or GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:ClearAllPoints()
	_G.GameTooltip_SetDefaultAnchor(GameTooltip, self)
	updateTooltip(self)
end

local function onLeave()
	GameTooltip:Hide()
end

function Module:SetAltPowerBarText(text, name, value, max, percent)
	local textFormat = "NAMECURMAX"
	if textFormat == "NONE" or not textFormat then
		text:SetText("")
	elseif textFormat == "NAME" then
		text:SetText(string_format("%s", name))
	elseif textFormat == "NAMEPERC" then
		text:SetText(string_format("%s: %s%%", name, percent))
	elseif textFormat == "NAMECURMAX" then
		text:SetText(string_format("%s: %s / %s", name, value, max))
	elseif textFormat == "NAMECURMAXPERC" then
		text:SetText(string_format("%s: %s / %s - %s%%", name, value, max, percent))
	elseif textFormat == "PERCENT" then
		text:SetText(string_format("%s%%", percent))
	elseif textFormat == "CURMAX" then
		text:SetText(string_format("%s / %s", value, max))
	elseif textFormat == "CURMAXPERC" then
		text:SetText(string_format("%s / %s - %s%%", value, max, percent))
	end
end

function Module:PositionAltPowerBar()
	local holder = CreateFrame("Frame", "AltPowerBarHolder", UIParent)
	holder:SetPoint("TOP", UIParent, "TOP", -1, -108)
	holder:SetSize(128, 50)

	local PlayerPowerBarAlt = _G.PlayerPowerBarAlt
	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint("CENTER", holder, "CENTER")
	PlayerPowerBarAlt:SetParent(holder)
	PlayerPowerBarAlt:SetMovable(true)
	PlayerPowerBarAlt:SetUserPlaced(true)
	PlayerPowerBarAlt.ignoreFramePositionManager = true

	K.Mover(holder, "PlayerPowerBarAlt", "Alternative Power", { "TOP", UIParent, "TOP", -1, -108 }, AltPowerWidth, AltPowerHeight)
end

function Module:UpdateAltPowerBarColors()
	local bar = KKUI_AltPowerBar
	local color = { r = 0.2, g = 0.4, b = 0.8 }
	bar:SetStatusBarColor(color.r, color.g, color.b)
end

function Module:UpdateAltPowerBarSettings()
	local bar = KKUI_AltPowerBar
	bar:SetSize(AltPowerWidth, AltPowerHeight)
	bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	bar.text:SetFontObject(K.UIFont)

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
		local perc = maxPower > 0 and math_floor(power / maxPower * 100) or 0

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
	if C_AddOns.IsAddOnLoaded("SimplePowerBar") then
		return
	end

	self:PositionAltPowerBar()
	self:SkinAltPowerBar()
end
