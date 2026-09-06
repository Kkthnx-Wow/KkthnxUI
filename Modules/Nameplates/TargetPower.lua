--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Nameplates/TargetPower.lua
	Purpose:
		Show the player's class resource (combo points, chi, holy power, and the
		like) as a segmented bar that follows the current target's nameplate, the
		way Plater and other UIs put combo points on the target. One bar re-anchors
		to whichever plate is the target rather than a widget on every plate.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Nameplates")

local CreateFrame = CreateFrame
local floor = math.floor
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitExists = UnitExists
local IsSecret = K.IsSecret
local C_NamePlate = C_NamePlate
local Enum = Enum

-- Class resource each class shows here. Death knight runes work differently, so
-- they are left off the plate.
local POWER_BY_CLASS = {
	ROGUE = Enum.PowerType.ComboPoints,
	DRUID = Enum.PowerType.ComboPoints,
	MAGE = Enum.PowerType.ArcaneCharges,
	MONK = Enum.PowerType.Chi,
	PALADIN = Enum.PowerType.HolyPower,
	WARLOCK = Enum.PowerType.SoulShards,
	EVOKER = Enum.PowerType.Essence,
}

-- Combo-point ramp, matching the unit-frame class power colours.
local COMBO_COLORS = {
	{ 0.85, 0.27, 0.27 },
	{ 0.90, 0.45, 0.25 },
	{ 0.90, 0.68, 0.28 },
	{ 0.62, 0.80, 0.35 },
	{ 0.35, 0.80, 0.45 },
	{ 0.36, 0.55, 0.81 },
	{ 0.55, 0.32, 0.78 },
}
local EMPTY = { 0.15, 0.15, 0.15 }

local MAX_SEGMENTS = 10
local powerType = POWER_BY_CLASS[K.Class]
local isCombo = K.Class == "ROGUE" or K.Class == "DRUID"

-- Fill colour for non-combo resources (soul shards, chi, holy power, and the
-- like), taken from the same power token the unit frame uses so the nameplate
-- and the player frame match. Falls back to the theme accent.
local POWER_TOKEN = {
	[Enum.PowerType.SoulShards] = "SOUL_SHARDS",
	[Enum.PowerType.Chi] = "CHI",
	[Enum.PowerType.HolyPower] = "HOLY_POWER",
	[Enum.PowerType.ArcaneCharges] = "ARCANE_CHARGES",
	[Enum.PowerType.Essence] = "ESSENCE",
}
local FILLED = { K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3] }
local token = powerType and POWER_TOKEN[powerType]
local tokenColor = token and _G.PowerBarColor and _G.PowerBarColor[token]
if tokenColor then
	FILLED = { tokenColor.r, tokenColor.g, tokenColor.b }
end

local holder

-- Match the spacing we use elsewhere so our borders clear each other instead of
-- overlapping (our border extends a few pixels outside each segment).
local SPACING = 6

-- Fill the full health-bar width end to end with whole-pixel segments. Flooring
-- alone left a gap, so the leftover pixels are handed out one each to the first
-- few segments. The holder is the exact health width and centre-anchored to the
-- plate, so the row lines up with the health bar below.
local function Layout(count)
	if count < 1 then
		return
	end
	local target = C.Nameplate.Width
	holder:SetWidth(target)

	local avail = target - SPACING * (count - 1)
	local barWidth = floor(avail / count)
	if barWidth < 1 then
		barWidth = 1
	end
	local remainder = avail - barWidth * count

	local x = 0
	for i = 1, MAX_SEGMENTS do
		local bar = holder.bars[i]
		if i <= count then
			local w = barWidth + (i <= remainder and 1 or 0)
			bar:ClearAllPoints()
			bar:SetWidth(w)
			bar:SetPoint("TOPLEFT", holder, "TOPLEFT", x, 0)
			bar:SetPoint("BOTTOMLEFT", holder, "BOTTOMLEFT", x, 0)
			bar:Show()
			x = x + w + SPACING
		else
			bar:Hide()
		end
	end
end

local function Update()
	if not holder or not powerType then
		return
	end
	local cur = UnitPower("player", powerType)
	local max = UnitPowerMax("player", powerType)
	if IsSecret(cur) or IsSecret(max) or not max or max < 1 then
		holder:Hide()
		return
	end

	Layout(max)
	for i = 1, max do
		local bar = holder.bars[i]
		if i <= cur then
			local col = isCombo and (COMBO_COLORS[i] or COMBO_COLORS[#COMBO_COLORS]) or FILLED
			bar.Fill:SetVertexColor(col[1], col[2], col[3], 1)
		else
			bar.Fill:SetVertexColor(EMPTY[1], EMPTY[2], EMPTY[3], 0.8)
		end
	end
end

local function Reanchor()
	if not holder then
		return
	end
	local plate = UnitExists("target") and C_NamePlate and C_NamePlate.GetNamePlateForUnit and C_NamePlate.GetNamePlateForUnit("target")
	if plate then
		-- Parent to the plate so the bar inherits the nameplate scale, otherwise a
		-- UIParent-scaled bar is wider/narrower than the scaled health bar.
		holder:SetParent(plate)
		holder:ClearAllPoints()
		-- Sit above the name line rather than on top of it.
		holder:SetPoint("BOTTOM", plate, "TOP", 0, 14)
		holder:Show()
		Update()
	else
		holder:SetParent(UIParent)
		holder:Hide()
	end
end

function Module:SetupTargetPower()
	if not powerType or not C.Nameplate.TargetPower then
		return
	end

	holder = CreateFrame("Frame", "KKUI_NamePlateTargetPower", UIParent)
	holder:SetSize(C.Nameplate.Width, 11)
	holder:Hide()

	holder.bars = {}
	for i = 1, MAX_SEGMENTS do
		local bar = CreateFrame("Frame", nil, holder)
		K.CreateBackground(bar, 0.06, 0.06, 0.06, 0.9)
		-- Match the nameplate look: a soft shadow rather than the hard border.
		K.CreateShadow(bar, 3)
		local fill = bar:CreateTexture(nil, "ARTWORK")
		fill:SetTexture(K.GetTexture(C.Unitframe and C.Unitframe.Texture or "KkthnxUI"))
		fill:SetPoint("TOPLEFT", bar, "TOPLEFT", 1, -1)
		fill:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -1, 1)
		bar.Fill = fill
		bar:Hide()
		holder.bars[i] = bar
	end

	local watcher = CreateFrame("Frame")
	watcher:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
	watcher:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	watcher:RegisterEvent("PLAYER_TARGET_CHANGED")
	watcher:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	watcher:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	watcher:SetScript("OnEvent", function(_, event)
		if event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" then
			if holder:IsShown() then
				Update()
			end
		else
			Reanchor()
		end
	end)

	Reanchor()
end
