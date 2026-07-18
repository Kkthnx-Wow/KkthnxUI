--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Tooltip unit health / status bar (Midnight-safe).
-- Split from Core.lua — no BackdropTemplate on the bar (secret width math).
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Tooltip")

local _G = _G
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local GameTooltipStatusBar = GameTooltipStatusBar
local hooksecurefunc = hooksecurefunc
local pcall = pcall
local Enum = Enum
local TooltipDataProcessor = TooltipDataProcessor

local DEAD = _G.DEAD
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local AbbreviateNumbers = AbbreviateNumbers
local UnitHealthPercent = _G.UnitHealthPercent
local CurveConstants = _G.CurveConstants
local ScaleTo100 = CurveConstants and CurveConstants.ScaleTo100

local IsSecret = K.IsSecret
local NotSecret = K.NotSecret
local ShortValue = K.ShortValue

local function IsRestrictedUnit(unit)
	return IsSecret(unit) or K.IsSecretUnit(unit)
end

-- Follow General.Texture — do not pin Blizzard's unitframe atlas; that ignored the dropdown.
local function ApplyBarTexture(bar)
	if not bar or not bar.SetStatusBarTexture then
		return
	end
	bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
end

local function EnsureStatusBarText(bar)
	if not bar or bar.Text then
		return
	end
	bar.Text = K.CreateFontString(bar, 11, nil, "")
	bar.Text:SetPoint("CENTER", bar, "CENTER", 0, 0)
	bar.Text:SetTextColor(1, 1, 1)
end

local function StyleStatusBar(bar)
	if not bar or bar.kkStyled then
		return
	end
	bar.kkStyled = true

	ApplyBarTexture(bar)

	local level = bar:GetFrameLevel()
	local bg = CreateFrame("Frame", nil, bar)
	bg:SetAllPoints(bar)
	bg:SetFrameLevel(level > 0 and level - 1 or 0)
	local bgTexture = bg:CreateTexture(nil, "BACKGROUND")
	bgTexture:SetAllPoints()
	bgTexture:SetColorTexture(0.06, 0.06, 0.06, 0.9)
	bar.kkBG = bg

	EnsureStatusBarText(bar)
	bar:SetHeight(C["Tooltip"].StatusBarHeight or 12)
end

local function UpdateHealthText(bar)
	bar = bar or GameTooltipStatusBar
	if not bar then
		return
	end

	EnsureStatusBarText(bar)
	local text = bar.Text
	if not text then
		return
	end

	local parent = bar:GetParent()
	local unit = parent and Module.GetUnitToken(parent)
	if not unit or IsRestrictedUnit(unit) then
		text:SetText("")
		return
	end

	local dead = UnitIsDeadOrGhost(unit)
	if NotSecret(dead) and dead then
		text:SetText(DEAD)
		return
	end

	local okCur, cur = pcall(UnitHealth, unit)
	local okMax, maxHP = pcall(UnitHealthMax, unit)
	if okCur and okMax and cur and maxHP then
		local showCurrent = C["Tooltip"].HealthBarText == "current"
		if NotSecret(cur) and NotSecret(maxHP) then
			if showCurrent then
				text:SetText(ShortValue(cur))
			else
				text:SetFormattedText("%s / %s", ShortValue(cur), ShortValue(maxHP))
			end
		else
			if showCurrent then
				text:SetText(AbbreviateNumbers(cur))
			else
				text:SetFormattedText("%s / %s", AbbreviateNumbers(cur), AbbreviateNumbers(maxHP))
			end
		end
		return
	end

	if UnitHealthPercent and ScaleTo100 then
		local ok, percent = pcall(UnitHealthPercent, unit, true, ScaleTo100)
		if ok and percent and NotSecret(percent) then
			text:SetFormattedText("%d%%", percent)
			return
		end
	end

	local ok, value = pcall(UnitHealth, unit)
	if ok and value then
		text:SetText(AbbreviateNumbers(value))
	else
		text:SetText("")
	end
end

local function HookBarHealth(bar)
	if not bar or bar.kkHealthHooked then
		return
	end
	bar.kkHealthHooked = true
	StyleStatusBar(bar)

	-- Wiping OnValueChanged stops Blizzard text flicker, but also drops their
	-- colour updates — re-paint class/reaction colour on UpdateUnitHealth.
	local function OnBarHealthUpdated(self)
		local tip = self:GetParent()
		if tip and not tip:IsForbidden() then
			Module.UpdateStatusBarColor(tip)
		else
			UpdateHealthText(self)
		end
	end

	if bar.UpdateUnitHealth then
		bar:SetScript("OnValueChanged", nil)
		hooksecurefunc(bar, "UpdateUnitHealth", OnBarHealthUpdated)
	else
		bar:HookScript("OnValueChanged", OnBarHealthUpdated)
	end
end

function Module:UpdateStatusBarColor()
	if self:IsForbidden() then
		return
	end

	local bar = self.StatusBar or GameTooltipStatusBar
	if not bar then
		return
	end

	local unit = Module.GetUnitToken(self)
	if not unit or IsRestrictedUnit(unit) then
		-- Restricted identity: keep last paint; only seed green once so we never
		-- sit on an undyed atlas (dark grey). Prefer not stomping a good reaction.
		local cr, cg, cb = bar:GetStatusBarColor()
		if not cr or (cr == 1 and cg == 1 and cb == 1) or (cr == 0 and cg == 0 and cb == 0) or (cr == 0.6 and cg == 0.6 and cb == 0.6) then
			bar:SetStatusBarColor(0, 1, 0)
		end
	else
		bar:SetStatusBarColor(K.UnitColor(unit))
	end

	UpdateHealthText(bar)
end

function Module:ReskinStatusBar()
	if not self.StatusBar then
		return
	end
	StyleStatusBar(self.StatusBar)
	self.StatusBar:ClearAllPoints()
	self.StatusBar:SetPoint("BOTTOMLEFT", self.bg, "TOPLEFT", 0, 6)
	self.StatusBar:SetPoint("BOTTOMRIGHT", self.bg, "TOPRIGHT", 0, 6)
end

function Module:GameTooltip_ShowStatusBar()
	if not self or self:IsForbidden() or not self.statusBarPool then
		return
	end

	local bar = self.statusBarPool:GetNextActive()
	if bar and not bar.kkStyled then
		if bar.StripTextures then
			bar:StripTextures()
		end
		StyleStatusBar(bar)
	end
end

function Module:RefreshStatusBarLayout()
	local height = C["Tooltip"].StatusBarHeight or 12
	if GameTooltipStatusBar and GameTooltipStatusBar.SetHeight then
		GameTooltipStatusBar:SetHeight(height)
	end
	if GameTooltip and GameTooltip.StatusBar and GameTooltip.StatusBar.SetHeight then
		GameTooltip.StatusBar:SetHeight(height)
	end
	if GameTooltip and not GameTooltip:IsForbidden() then
		Module:UpdateStatusBarColor(GameTooltip)
	end
end

function Module:UpdateStatusBarTextures()
	local bars = {
		GameTooltipStatusBar,
		GameTooltip and GameTooltip.StatusBar,
	}

	for i = 1, #bars do
		local bar = bars[i]
		if bar then
			ApplyBarTexture(bar)
		end
	end

	if GameTooltip and GameTooltip.statusBarPool and GameTooltip.statusBarPool.GetNextActive then
		local bar = GameTooltip.statusBarPool:GetNextActive()
		if bar then
			ApplyBarTexture(bar)
		end
	end
end

function Module:CreateTooltipStatusBar()
	local bar = GameTooltip.StatusBar or GameTooltipStatusBar
	if bar then
		if bar.SetScript then
			bar:SetScript("OnValueChanged", nil)
		end
		HookBarHealth(bar)
	end
	if GameTooltip.StatusBar and GameTooltip.StatusBar ~= GameTooltipStatusBar then
		HookBarHealth(GameTooltip.StatusBar)
	end

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, Module.UpdateStatusBarColor)
	hooksecurefunc("GameTooltip_ShowStatusBar", Module.GameTooltip_ShowStatusBar)
end
