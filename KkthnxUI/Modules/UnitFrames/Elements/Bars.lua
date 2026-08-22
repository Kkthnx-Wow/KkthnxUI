--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Elements/Bars.lua
	Purpose:
		The bar family: health (with heal prediction and absorb sub-widgets),
		power, the druid style additional power strip, and the boss encounter
		alternative power strip.

		Health and power are separate bordered boxes, so each one owns its own
		background and border rather than sharing one on the parent frame.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build

local CreateFrame = CreateFrame
local IsSecret = K.IsSecret
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitReaction = UnitReaction
local UnitCanAttack = UnitCanAttack
local UnitThreatSituation = UnitThreatSituation
local oUF = K.oUF

-- ExponentialEaseOut is the only interpolation the client offers besides
-- Immediate, so "smooth bars" maps onto it directly.
local function Smoothing()
	if C.Unitframe.Smooth then
		return Enum.StatusBarInterpolation.ExponentialEaseOut
	end
	return Enum.StatusBarInterpolation.Immediate
end

-- A bordered status bar box: our gradient backdrop, border, and addon texture.
-- The empty part of the bar shows the gradient, matching the rest of the UI.
local function CreateBox(parent, height)
	local bar = CreateFrame("StatusBar", nil, parent)
	bar:SetStatusBarTexture(Module.Texture())
	if height then
		bar:SetHeight(height)
	end
	K.CreateGradientBackground(bar, 0.9)
	K.CreateBorder(bar)
	return bar
end
Module.CreateBox = CreateBox

-- ---------------------------------------------------------------------------
-- Bar shading
-- ---------------------------------------------------------------------------
-- Backdrop tint: the empty part of the bar tinted to a dark version of the fill
-- colour, so an almost dead target still reads as its class. Run from the bar's
-- PostUpdateColor so it always sees the colour oUF just applied.

local BACKDROP_TINT = 0.22
-- Matches the flat backdrop underneath, so turning the tint on does not make a
-- bar suddenly opaque.
local BACKDROP_ALPHA = 0.9

local function AddBackdropTint(bar)
	local tint = bar:CreateTexture(nil, "BACKGROUND", nil, -6)
	tint:SetTexture(Module.Texture())
	tint:SetAllPoints()
	tint:SetVertexColor(0.2, 0.2, 0.2, BACKDROP_ALPHA)
	K.DisablePixelSnap(tint)
	bar.KKUI_Tint = tint
	return tint
end

-- Reading the colour back off the widget rather than trusting the argument keeps
-- this working for the power element's atlas and alternative-colour paths, where
-- the ColorMixin argument is nil.
local function ShadeBar(bar)
	if not bar.KKUI_Tint then
		return
	end
	local texture = bar:GetStatusBarTexture()
	if texture:GetAtlas() then
		return
	end

	local r, g, b = texture:GetVertexColor()
	-- A smooth health curve hands back a secret colour, which cannot be
	-- multiplied, so leave the tint alone.
	if not r or IsSecret(r) then
		return
	end
	bar.KKUI_Tint:SetVertexColor(r * BACKDROP_TINT, g * BACKDROP_TINT, b * BACKDROP_TINT, BACKDROP_ALPHA)
end

-- Build the backdrop tint if enabled. Returns whether the bar needs shading on
-- every colour update, so the caller can skip the hook entirely when it is off.
local function AddShading(bar)
	if C.Unitframe.BarBackdrop then
		AddBackdropTint(bar)
		return true
	end
	return false
end

-- ---------------------------------------------------------------------------
-- Health
-- ---------------------------------------------------------------------------

-- Incoming heals and absorbs ride on top of the health fill. oUF sizes them
-- for us on every update, so we only anchor and colour them here.
local function CreatePredictionBar(health, r, g, b, a, reverse)
	local bar = CreateFrame("StatusBar", nil, health)
	bar:SetStatusBarTexture(Module.Texture())
	bar:SetStatusBarColor(r, g, b, a)
	bar:SetFrameLevel(health:GetFrameLevel() + 1)
	bar:SetPoint("TOP")
	bar:SetPoint("BOTTOM")
	bar:SetReverseFill(reverse or false)
	return bar
end

local function AddPrediction(health)
	local healing = CreatePredictionBar(health, 0.0, 0.72, 0.35, 0.35)
	healing:SetPoint("LEFT", health:GetStatusBarTexture(), "RIGHT", 0, 0)
	health.HealingAll = healing

	local damageAbsorb = CreatePredictionBar(health, 0.62, 0.62, 1.0, 0.35)
	damageAbsorb:SetPoint("LEFT", healing:GetStatusBarTexture(), "RIGHT", 0, 0)
	health.DamageAbsorb = damageAbsorb

	-- Heal absorbs eat into existing health, so this one fills backwards from
	-- the current health edge.
	local healAbsorb = CreatePredictionBar(health, 0.9, 0.2, 0.2, 0.4, true)
	healAbsorb:SetPoint("RIGHT", health:GetStatusBarTexture(), "RIGHT", 0, 0)
	health.HealAbsorb = healAbsorb

	-- Shield went past full health: a bright sliver straddling the right edge.
	local overAbsorb = health:CreateTexture(nil, "OVERLAY")
	overAbsorb:SetColorTexture(0.62, 0.62, 1)
	overAbsorb:SetBlendMode("ADD")
	overAbsorb:SetPoint("TOP")
	overAbsorb:SetPoint("BOTTOM")
	overAbsorb:SetPoint("LEFT", health, "RIGHT", -4, 0)
	overAbsorb:SetWidth(8)
	health.OverDamageAbsorbIndicator = overAbsorb

	-- Same idea on the left for a heal absorb bigger than current health.
	local overHealAbsorb = health:CreateTexture(nil, "OVERLAY")
	overHealAbsorb:SetColorTexture(0.9, 0.2, 0.2)
	overHealAbsorb:SetBlendMode("ADD")
	overHealAbsorb:SetPoint("TOP")
	overHealAbsorb:SetPoint("BOTTOM")
	overHealAbsorb:SetPoint("RIGHT", health, "LEFT", 4, 0)
	overHealAbsorb:SetWidth(8)
	health.OverHealAbsorbIndicator = overHealAbsorb
end

-- ---------------------------------------------------------------------------
-- Health border colour
-- ---------------------------------------------------------------------------
-- Threat and the class colour option both want to own the health border, so
-- neither touches it directly. They set a field and call through here, and this
-- decides: threat first, then class, then the configured border colour.

local function UnitBorderColor(frame, unit)
	local colors = frame.colors

	if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
		-- Second return only. The localised class name is a conditional secret.
		local _, class = UnitClass(unit)
		return class and colors.class[class]
	end

	local reaction = UnitReaction(unit, "player")
	return reaction and colors.reaction[reaction]
end

function Module.RefreshHealthBorder(self)
	local health = self.Health
	local border = health and health.KKUI_Border
	if not border then
		return
	end

	-- Border priority for a healer's eyes: a dispellable debuff wins over threat,
	-- which wins over the optional class-coloured border.
	local color = self.__dispelColor or self.__threatColor
	if not color and C.Unitframe.ClassColorBorder then
		color = self.__unitColor
	end

	if color then
		border.__customColor = true
		border:SetVertexColor(color:GetRGB())
	else
		K.ResetBorderColor(border)
	end
end

-- Enemy fill override, run after oUF's own colouring. Players and friendly units
-- keep the colour oUF gave them. Enemies get a threat colour when that option is
-- on, and a solid hostile colour when their reaction is secret, so a mob we are
-- fighting never falls back to the plain green health fill.
local function ColorEnemyFill(element, unit)
	local isPlayer = UnitIsPlayer(unit)
	if IsSecret(isPlayer) or isPlayer then
		return
	end

	local canAttack = UnitCanAttack("player", unit)
	if IsSecret(canAttack) or not canAttack then
		return -- friendly npc: leave oUF's reaction colour
	end

	if C.Unitframe.ThreatHealthColor then
		local status = UnitThreatSituation("player", unit)
		if status and not IsSecret(status) then
			local color = K.ThreatFillColor(status, K.PlayerIsTank())
			if color then
				element:SetStatusBarColor(color[1], color[2], color[3])
				return
			end
		end
	end

	-- If the reaction is readable oUF already coloured it right, so only step in
	-- when it is secret: use the hostile colour instead of the stock green.
	local reaction = UnitReaction(unit, "player")
	if reaction and not IsSecret(reaction) then
		return
	end
	local hostile = oUF and oUF.colors and oUF.colors.reaction and oUF.colors.reaction[2]
	if hostile then
		element:SetStatusBarColor(hostile:GetRGB())
	end
end

local function OnHealthColor(element, unit)
	local frame = element.__owner
	frame.__unitColor = UnitBorderColor(frame, unit)
	Module.RefreshHealthBorder(frame)

	if element.__shaded then
		ShadeBar(element)
	end

	ColorEnemyFill(element, unit)
end

function Build.Health(self, height)
	local health = CreateBox(self, height)
	health:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	health:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
	health.smoothing = Smoothing()
	health.__shaded = AddShading(health)
	health.PostUpdateColor = OnHealthColor

	health.colorDisconnected = true
	health.colorTapping = true
	if C.Unitframe.ClassHealth then
		health.colorClass = true
		health.colorClassPet = true
		health.colorReaction = true
	end
	-- Last link in oUF's colour chain either way. Without it a unit that matches
	-- none of the above keeps whatever colour the bar had last, which the shading
	-- below would then read back and reuse.
	health.colorHealth = true

	if C.Unitframe.HealthPrediction then
		AddPrediction(health)
	end

	self.Health = health

	-- Mouseover and target-select highlights framing the health border.
	if Build.Highlight then
		Build.Highlight(self, "communitiesfinder_card_highlight", "GarrMission_FollowerListButton-Select")
	end

	return health
end

-- ---------------------------------------------------------------------------
-- Power
-- ---------------------------------------------------------------------------

-- gap lets compact frames (raid) sit the power bar tight under health instead
-- of using the standard detached gap. pinBottom anchors the bar to the frame's
-- bottom edge instead of below health, so the caller can let health fill the
-- space above (used by raid so hiding power expands health).
function Build.Power(self, height, gap, pinBottom)
	if not height or height <= 0 then
		return
	end

	gap = gap or Module.GAP
	local power = CreateBox(self, height)
	if pinBottom then
		power:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
		power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
	else
		power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -gap)
		power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -gap)
	end
	power.smoothing = Smoothing()
	power.colorPower = true
	power.frequentUpdates = true

	if AddShading(power) then
		power.PostUpdateColor = ShadeBar
	end

	self.Power = power
	return power
end

-- ---------------------------------------------------------------------------
-- Additional power (druid mana while shifted)
-- ---------------------------------------------------------------------------
-- A thin strip along the bottom of the health bar. Overlaying keeps the frame
-- height stable whether or not the player is in a form that shows it.

function Build.AdditionalPower(self)
	local bar = CreateFrame("StatusBar", nil, self.Health)
	bar:SetStatusBarTexture(Module.Texture())
	bar:SetHeight(4)
	bar:SetFrameLevel(self.Health:GetFrameLevel() + 3)
	bar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, 0)
	bar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, 0)
	bar.colorPower = true
	bar.smoothing = Smoothing()

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.6)

	self.AdditionalPower = bar
	return bar
end

-- ---------------------------------------------------------------------------
-- Alternative power (boss encounter bars)
-- ---------------------------------------------------------------------------

function Build.AlternativePower(self)
	local bar = CreateFrame("StatusBar", nil, self.Health)
	bar:SetStatusBarTexture(Module.Texture())
	bar:SetStatusBarColor(0.7, 0.7, 0.6)
	bar:SetHeight(4)
	bar:SetFrameLevel(self.Health:GetFrameLevel() + 3)
	bar:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 0)
	bar:SetPoint("TOPRIGHT", self.Health, "TOPRIGHT", 0, 0)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0, 0, 0, 0.6)

	self.AlternativePower = bar
	return bar
end
