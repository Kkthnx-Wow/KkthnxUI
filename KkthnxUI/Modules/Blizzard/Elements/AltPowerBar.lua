--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Handles the Alternate Power Bar logic and skinning (e.g., boss energy, quest resources).
-- - Design: Disables the Blizzard PlayerPowerBarAlt and replaces it with a custom skinned StatusBar.
-- - Events: UNIT_POWER_UPDATE, UNIT_POWER_BAR_SHOW, UNIT_POWER_BAR_HIDE, PLAYER_ENTERING_WORLD
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local CreateFrame = CreateFrame
local GameTooltip = _G.GameTooltip
local GetUnitPowerBarInfo = GetUnitPowerBarInfo
local GetUnitPowerBarStrings = GetUnitPowerBarStrings
local InCombatLockdown = InCombatLockdown
local UIParent = _G.UIParent
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local math_floor = math.floor

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
local ALTERNATE_POWER_INDEX = _G.ALTERNATE_POWER_INDEX
local ALT_POWER_WIDTH = 250
local ALT_POWER_HEIGHT = 20

-- ---------------------------------------------------------------------------
-- Tooltip Handling
-- ---------------------------------------------------------------------------
-- REASON: Updates the tooltip when hovering over the power bar to show power name and description.
local function updateTooltip(self)
	-- WARNING: Check forbidden status to avoid potential taint or UI errors from inaccessible frames.
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
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
	updateTooltip(self)
end

local function onLeave()
	GameTooltip:Hide()
end

-- ---------------------------------------------------------------------------
-- Text Formatting
-- ---------------------------------------------------------------------------
function Module:SetAltPowerBarText(text, name, value, max, percent)
	-- REASON: Provides flexible text formatting for the power bar display.
	local textFormat = "NAMECURMAX" -- PERF: Hardcoded for now; could be exposed via config.

	if textFormat == "NONE" or not textFormat then
		text:SetText("")
	elseif textFormat == "NAME" then
		text:SetFormattedText("%s", name)
	elseif textFormat == "NAMEPERC" then
		text:SetFormattedText("%s: %s%%", name, percent)
	elseif textFormat == "NAMECURMAX" then
		text:SetFormattedText("%s: %s / %s", name, value, max)
	elseif textFormat == "NAMECURMAXPERC" then
		text:SetFormattedText("%s: %s / %s - %s%%", name, value, max, percent)
	elseif textFormat == "PERCENT" then
		text:SetFormattedText("%s%%", percent)
	elseif textFormat == "CURMAX" then
		text:SetFormattedText("%s / %s", value, max)
	elseif textFormat == "CURMAXPERC" then
		text:SetFormattedText("%s / %s - %s%%", value, max, percent)
	end
end

-- ---------------------------------------------------------------------------
-- Positioning and Setup
-- ---------------------------------------------------------------------------
function Module:PositionAltPowerBar()
	-- REASON: Creates a mover for the alternate power bar so the user can position it freely.
	local holder = _G.AltPowerBarHolder or CreateFrame("Frame", "AltPowerBarHolder", UIParent)
	holder:SetPoint("TOP", UIParent, "TOP", -1, -130)
	holder:SetSize(128, 50)

	-- WARNING: PlayerPowerBarAlt is a secure frame; modifying its parent or visibility requires care to avoid taint.
	local playerPowerBarAlt = _G.PlayerPowerBarAlt
	if playerPowerBarAlt then
		playerPowerBarAlt:ClearAllPoints()
		playerPowerBarAlt:SetPoint("CENTER", holder, "CENTER")
		playerPowerBarAlt:SetParent(holder)
		playerPowerBarAlt:SetMovable(true)
		playerPowerBarAlt:SetUserPlaced(true)
		-- REASON: Prevents Blizzard's layout engine from resetting the frame's position.
		playerPowerBarAlt:SetDontSavePosition(true)
		playerPowerBarAlt.ignoreFramePositionManager = true
	end

	K.Mover(holder, "PlayerPowerBarAlt", "Alternative Power", { "TOP", UIParent, "TOP", -1, -130 }, ALT_POWER_WIDTH, ALT_POWER_HEIGHT)
end

function Module:UpdateAltPowerBarColors()
	local bar = _G.KKUI_AltPowerBar
	if not bar then
		return
	end

	-- REASON: Sets a consistent color for the custom power bar.
	bar:SetStatusBarColor(0.2, 0.4, 0.8)
end

function Module:UpdateAltPowerBarSettings()
	local bar = _G.KKUI_AltPowerBar
	if not bar then
		return
	end

	bar:SetSize(ALT_POWER_WIDTH, ALT_POWER_HEIGHT)
	bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	bar.text:SetFontObject(K.UIFont)

	local holder = _G.AltPowerBarHolder
	if holder then
		holder:SetSize(bar:GetSize())
	end

	-- K:SmoothBar(bar)

	Module:SetAltPowerBarText(bar.text, bar.powerName or "", bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0)
end

-- ---------------------------------------------------------------------------
-- Event Handler
-- ---------------------------------------------------------------------------
-- REASON: Updates the custom power bar state based on Blizzard's unit power events.
local function updateAltPowerBar(self, event, unit)
	if event and event:find("^UNIT_") and unit ~= "player" then
		return
	end

	-- WARNING: Hiding secure frames like PlayerPowerBarAlt can cause taint if done in combat.
	if not InCombatLockdown() then
		local playerPowerBarAlt = _G.PlayerPowerBarAlt
		if playerPowerBarAlt then
			playerPowerBarAlt:UnregisterAllEvents()
			playerPowerBarAlt:Hide()
		end
	end

	local barInfo = GetUnitPowerBarInfo("player")
	local powerName, powerTooltip = GetUnitPowerBarStrings("player")

	if barInfo then
		local power = UnitPower("player", ALTERNATE_POWER_INDEX) or 0
		local maxPower = UnitPowerMax("player", ALTERNATE_POWER_INDEX) or 0
		local percent = maxPower > 0 and math_floor(power / maxPower * 100) or 0

		self.powerMaxValue = maxPower
		self.powerName = powerName
		self.powerPercent = percent
		self.powerTooltip = powerTooltip
		self.powerValue = power

		self:SetMinMaxValues(barInfo.minPower or 0, maxPower)
		self:SetValue(power)
		self:Show()

		Module:SetAltPowerBarText(self.text, powerName or "", power or 0, maxPower, percent)
	else
		self.powerMaxValue = nil
		self.powerName = nil
		self.powerPercent = nil
		self.powerTooltip = nil
		self.powerValue = nil

		self:Hide()
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:SkinAltPowerBar()
	-- REASON: Creates and skins the alternative power bar to match the KkthnxUI aesthetic.
	if _G.KKUI_AltPowerBar then
		return
	end

	local powerBar = CreateFrame("StatusBar", "KKUI_AltPowerBar", UIParent)
	powerBar:CreateBorder()
	powerBar:SetMinMaxValues(0, 200)
	powerBar:SetPoint("CENTER", _G.AltPowerBarHolder)
	powerBar:Hide()

	powerBar:SetScript("OnEnter", onEnter)
	powerBar:SetScript("OnLeave", onLeave)

	powerBar.text = powerBar:CreateFontString(nil, "OVERLAY")
	powerBar.text:SetPoint("CENTER", powerBar, "CENTER")
	powerBar.text:SetJustifyH("CENTER")

	Module:UpdateAltPowerBarSettings()
	Module:UpdateAltPowerBarColors()

	local spark = powerBar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Textures.Spark16Texture)
	spark:SetHeight(ALT_POWER_HEIGHT)
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", powerBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	powerBar.spark = spark

	powerBar:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
	powerBar:RegisterUnitEvent("UNIT_POWER_BAR_SHOW", "player")
	powerBar:RegisterUnitEvent("UNIT_POWER_BAR_HIDE", "player")
	powerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
	powerBar:SetScript("OnEvent", updateAltPowerBar)
end

function Module:CreateAltPowerbar()
	-- REASON: Entry point for the alternate power bar modification.
	-- COMPAT: Check if conflicting addons are loaded to avoid UI breakage.
	if _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded("SimplePowerBar") then
		return
	end

	self:PositionAltPowerBar()
	self:SkinAltPowerBar()
end
