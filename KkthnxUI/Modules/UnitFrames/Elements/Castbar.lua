--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Handles castbar functionality including ticks, latency, and visual updates.
-- - Design: Modular element for oUF unitframes, handling both player and unit castbars.
-- - Events: UNIT_SPELLCAST_START, UNIT_SPELLCAST_STOP, UNIT_SPELLCAST_CHANNEL_START, etc.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize C-functions (Snake Case)
local math_floor = _G.math.floor
local math_min = _G.math.min
local string_format = _G.string.format
local string_upper = _G.string.upper
local unpack = _G.unpack

-- REASON: Localize Globals
local CreateColor = _G.CreateColor
local GetTime = _G.GetTime
local IsPlayerSpell = _G.IsPlayerSpell
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitInVehicle = _G.UnitInVehicle
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitReaction = _G.UnitReaction
local YOU = _G.YOU

-- SECRET (12.0): spellID from UnitCastingInfo/UnitChannelInfo is secret on
-- nameplates/units in instances, and indexing a table with a secret key throws.
-- Use the shared K.IsSecret gate to short-circuit those Lua-table lookups.
local IsSecret = K.IsSecret

-- SECRET (12.0): UnitCastingInfo/UnitChannelInfo's `notInterruptible` is a secret
-- boolean on nameplates and units in combat, so we can never read it with a Lua
-- boolean test. Instead we feed it straight into the engine's secret-safe widget
-- helpers (SetVertexColorFromBoolean / SetAlphaFromBoolean), which need ColorMixin
-- objects. Build them once from the palette (mirrors NDui's UF.CastingColor cache).
local CastingColorMixin = CreateColor(unpack(K.Colors.castbar.CastingColor))
local NotInterruptColorMixin = CreateColor(unpack(K.Colors.castbar.notInterruptibleColor))
-- icon tint used to "dim" a non-interruptible cast in place of SetDesaturated(bool)
local IconDimColorMixin = CreateColor(0.5, 0.5, 0.5)
local IconNormalColorMixin = CreateColor(1, 1, 1)

local channelingTicks = {
	[740] = 4, -- Tranquility
	[755] = 5, -- Life Tap
	[5143] = 4, -- Arcane Missiles
	[12051] = 6, -- Evocation
	[15407] = 6, -- Mind Flay
	[47757] = 3, -- Penance
	[47758] = 3, -- Penance
	[48045] = 6, -- Mind Sear
	[64843] = 4, -- Divine Hymn
	[120360] = 15, -- Barrage
	[198013] = 10, -- Eye Beam
	[198590] = 5, -- Drain Soul
	[205021] = 5, -- Frostbolt
	[205065] = 6, -- Void Torrent
	[206931] = 3, -- Blooddrinker
	[212084] = 10, -- Fel Devastation
	[234153] = 5, -- Drain Life
	[257044] = 7, -- Rapid Fire
	[291944] = 6, -- Rejuvenation, Zandalari Trolls
	[314791] = 4, -- Metamorphosis, Demon Hunter
	[324631] = 8, -- Blood and Thunder, Covenant
	[356995] = 3, -- Decimate, Dragon's Breath
}

if K.Class == "PRIEST" then
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then
			numTicks = 4
		end
		channelingTicks[47757] = numTicks
		channelingTicks[47758] = numTicks
	end

	-- REASON: Update ticks on login and talent changes to account for Haste/Talent effects.
	K:RegisterEvent("PLAYER_LOGIN", updateTicks)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
end

-- REASON: Creates or updates the visual tick marks on the castbar for channeled spells.
local function CreateAndUpdateBarTicks(bar, ticks, numTicks)
	for i = 1, #ticks do
		local t = ticks[i]
		if t and t:IsShown() then
			t:Hide()
		end
	end

	if numTicks and numTicks > 0 then
		local width, height = bar:GetSize()
		local delta = width / numTicks
		for i = 1, numTicks - 1 do
			local tex = ticks[i]
			if not tex then
				tex = bar:CreateTexture(nil, "OVERLAY")
				tex:SetAtlas("UI-Frame-DastardlyDuos-ProgressBar-BorderTick", false)
				tex:SetWidth(3)
				tex:SetHeight(height)
				tex:SetVertexColor(0.8, 0.8, 0.8, 0.8)
				ticks[i] = tex
			end
			tex:ClearAllPoints()
			tex:SetPoint("RIGHT", bar, "LEFT", delta * i, 0)
			if not tex:IsShown() then
				tex:Show()
			end
		end
	end
end

-- REASON: Main update loop for castbar. Handles text, sparks, and pips.
-- MIDNIGHT (12.0): the bundled oUF now animates the bar through native StatusBar
-- interpolation (SetTimerDuration) and no longer maintains the legacy self.duration
-- / self.max numeric fields. We read the live timings from the Duration object
-- returned by self:GetTimerDuration() and never call SetValue ourselves (that would
-- fight the engine, which fills a 0-1 normalized bar). The Spark is anchored to the
-- interpolating fill texture in PostCastStart, so it follows the edge for free.
function Module:OnCastbarUpdate(elapsed)
	if self.casting or self.channeling or self.empowering then
		local durationObject = self:GetTimerDuration()
		-- SECRET (12.0): cast timings are normally readable, but guard so a secret
		-- Duration can never reach the arithmetic / SetFormattedText paths below.
		if durationObject and not durationObject:HasSecretValues() then
			local decimal = self.decimal
			local total = durationObject:GetTotalDuration()
			-- channels count down (remaining), casts/empowers count up (elapsed)
			local cur = self.channeling and durationObject:GetRemainingDuration() or durationObject:GetElapsedDuration()

			-- REASON: Display logic differs for player (with latency) vs other units.
			if self.__owner.unit == "player" then
				if self.delay and self.delay ~= 0 then
					self.Time:SetFormattedText(decimal .. " - |cffff0000" .. decimal, cur, total)
				else
					self.Time:SetFormattedText(decimal .. " - " .. decimal, cur, total)
				end
			elseif total and total > 1e4 then
				self.Time:SetText("∞ - ∞")
			else
				self.Time:SetFormattedText(decimal .. " - " .. decimal, cur, total)
			end

			-- REASON: Handle Empowered spells (pips/stages) off the elapsed time.
			if self.stageString then
				self.stageString:SetText("")
				if self.empowering and self.numStages then
					local cast = durationObject:GetElapsedDuration()
					for i = self.numStages, 1, -1 do
						local pip = self.Pips[i]
						if pip and cast and pip.duration and cast > pip.duration then
							self.stageString:SetText(i)

							if self.pipStage ~= i then
								self.pipStage = i
								local nextStage = self.numStages == i and 1 or i + 1
								local nextPip = self.Pips[nextStage]
								K.UIFrameFadeIn(nextPip.tex, 0.25, 0.3, 1)
							end
							break
						end
					end
				end
			end
		end
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - 0.02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

-- REASON: Captures the time a cast was sent to calculate latency.
function Module:OnCastSent()
	local element = self.Castbar
	if not element.SafeZone then
		return
	end
	element.__sendTime = GetTime()
end

local function ResetSpellTarget(self)
	if self.spellTarget then
		self.spellTarget:SetText("")
	end
end

-- REASON: Updates the spell target text, localized YOU if targeting player.
local function UpdateSpellTarget(self, unit)
	if not C["Nameplate"].CastTarget then
		return
	end

	if not self.spellTarget then
		return
	end

	local unitTarget = unit and unit .. "target"
	if unitTarget and UnitExists(unitTarget) then
		local nameString
		-- SECRET (12.0): on restricted nameplates UnitIsUnit returns a secret
		-- boolean that cannot be branched on; treat it as "not the player".
		local isYou = UnitIsUnit(unitTarget, "player")
		if K.NotSecret(isYou) and isYou then
			nameString = string_format("|cffff0000%s|r", ">" .. string_upper(YOU) .. "<")
		else
			-- REASON: Class color the name if possible.
			nameString = K.RGBToHex(K.UnitColor(unitTarget)) .. UnitName(unitTarget)
		end

		-- SECRET (12.0): UnitName can yield a secret string; the result inherits
		-- that secret state. Comparing/caching a secret errors, so just push it to
		-- the widget (SetText accepts secrets) and skip the change-cache that turn.
		if IsSecret(nameString) then
			self.spellTarget:SetText(nameString)
			self._lastSpellTarget = nil
		elseif self._lastSpellTarget ~= nameString then
			self.spellTarget:SetText(nameString)
			self._lastSpellTarget = nameString
		end
	else
		ResetSpellTarget(self) -- when unit loses target
	end
end

-- REASON: Updates the castbar color based on class, reaction, or interruptible status.
local function UpdateCastBarColor(self, unit)
	local isNameplate = self.__owner.mystyle == "nameplate"
	local sbTex = self:GetStatusBarTexture()

	-- REASON: Class/reaction coloring does not depend on the (possibly secret)
	-- interruptible flag, so keep using direct SetStatusBarColor for those modes.
	-- SAFETY: UnitClass/UnitReaction can return nil; fall back to the casting color.
	if not isNameplate and C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		local color = (class and K.Colors.class[class]) or K.Colors.castbar.CastingColor
		self:SetStatusBarColor(color[1], color[2], color[3])
	elseif not isNameplate and C["Unitframe"].CastReactionColor then
		local reaction = UnitReaction(unit, "player")
		local color = (reaction and K.Colors.reaction[reaction]) or K.Colors.castbar.CastingColor
		self:SetStatusBarColor(color[1], color[2], color[3])
	elseif sbTex and not K.UnitIsUnit(unit, "player") then
		-- SECRET (12.0): grey for non-interruptible, casting color otherwise. The
		-- engine evaluates the secret boolean for us (mirrors NDui's approach), so we
		-- never perform a forbidden boolean test on self.notInterruptible.
		sbTex:SetVertexColorFromBoolean(self.notInterruptible, NotInterruptColorMixin, CastingColorMixin)
	else
		self:SetStatusBarColor(CastingColorMixin:GetRGB())
	end

	-- REASON: Visual feedback for nameplate shields/icon dimming, secret-safe.
	if isNameplate then
		if self.Shield then
			self.Shield:SetAlphaFromBoolean(self.notInterruptible, 1, 0)
		end
		if self.Icon then
			self.Icon:SetVertexColorFromBoolean(self.notInterruptible, IconDimColorMixin, IconNormalColorMixin)
		end
	end
end

-- REASON: Handler for when a cast starts. Sets up latency safezone and visual indicators.
function Module:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()

	-- REASON: With native StatusBar interpolation the fill texture animates on its
	-- own (MIDNIGHT 12.0), so anchor the Spark to the moving edge of that texture
	-- instead of repositioning it every frame from the now-removed self.max value.
	local sparkTex = self:GetStatusBarTexture()
	if self.Spark and sparkTex then
		self.Spark:ClearAllPoints()
		self.Spark:SetPoint("CENTER", sparkTex, self:GetReverseFill() and "LEFT" or "RIGHT", 0, 0)
	end

	local safeZone = self.SafeZone
	local lagString = self.LagString

	if unit == "vehicle" or UnitInVehicle("player") then
		if safeZone then
			safeZone:Hide()
			lagString:Hide()
		end
	elseif unit == "player" then
		-- REASON: Calculate and display latency safezone for player.
		if safeZone then
			local sendTime = self.__sendTime
			-- REASON: the library sets startTime/endTime (seconds) for the player; the
			-- old self.max field no longer exists under MIDNIGHT's native castbar.
			local castDuration = (self.startTime and self.endTime) and (self.endTime - self.startTime)
			local timeDiff = (sendTime and castDuration) and math_min((GetTime() - sendTime), castDuration)
			if timeDiff and timeDiff > 0 and castDuration and castDuration > 0 then
				local width = self:GetWidth() * timeDiff / castDuration
				if self._lastSafeZoneWidth ~= width then
					safeZone:SetWidth(width)
					self._lastSafeZoneWidth = width
				end
				if not safeZone:IsShown() then
					safeZone:Show()
				end
				local lagMs = math_floor(timeDiff * 1000)
				if self._lastLagMs ~= lagMs then
					lagString:SetFormattedText("%d ms", lagMs)
					self._lastLagMs = lagMs
				end
				if not lagString:IsShown() then
					lagString:Show()
				end
			else
				safeZone:Hide()
				lagString:Hide()
			end
			self.__sendTime = nil
		end

		local numTicks = 0
		if self.channeling and not IsSecret(self.spellID) then
			numTicks = channelingTicks[self.spellID] or 0
		end
		CreateAndUpdateBarTicks(self, self.castTicks, numTicks)
	end

	UpdateCastBarColor(self, unit)

	if self.__owner.mystyle == "nameplate" then
		-- REASON: Support "Major Spells" glow on nameplates.
		-- SECRET (12.0): spellID is secret on instance nameplates; indexing MajorSpells
		-- with a secret key throws, so treat unreadable casts as "not major" (no glow).
		if not IsSecret(self.spellID) and C.MajorSpells[self.spellID] then
			K.ShowOverlayGlow(self.glowFrame)
		else
			K.HideOverlayGlow(self.glowFrame)
		end

		UpdateSpellTarget(self, unit)
	end
end

function Module:PostCastUpdate(unit)
	UpdateSpellTarget(self, unit)
end

function Module:PostUpdateInterruptible(unit)
	UpdateCastBarColor(self, unit)
end

-- REASON: Reset bar color and target text on cast stop.
function Module:PostCastStop()
	if not self.fadeOut then
		-- PERF: unpack traverses the table once instead of three separate chained index lookups.
		self:SetStatusBarColor(unpack(K.Colors.castbar.CompleteColor))
		self.fadeOut = true
	end

	self:Show()
	ResetSpellTarget(self)
end

-- REASON: Visual feedback for failed casts.
function Module:PostCastFailed()
	-- PERF: unpack traverses the table once instead of three separate chained index lookups.
	self:SetStatusBarColor(unpack(K.Colors.castbar.FailColor))
	-- MIDNIGHT (12.0): the bar is a normalized 0-1 StatusBar driven by interpolation,
	-- so force it visually full on failure (self.max no longer exists).
	self:SetValue(1)
	self.fadeOut = true
	self:Show()
	ResetSpellTarget(self)
end

Module.PipColors = {
	[1] = { 0.08, 1, 0, 0.3 },
	[2] = { 1, 0.1, 0.1, 0.3 },
	[3] = { 1, 0.5, 0, 0.3 },
	[4] = { 0.1, 0.7, 0.7, 0.3 },
	[5] = { 0, 1, 1, 0.3 },
}

-- REASON: Creates individual pip frames for multi-stage casts (Empowered spells).
function Module:CreatePip(stage)
	local _, height = self:GetSize()

	local pip = CreateFrame("Frame", nil, self, "CastingBarFrameStagePipTemplate")
	pip.BasePip:SetTexture(C["Media"].Textures.White8x8Texture)
	pip.BasePip:SetVertexColor(0, 0, 0)
	pip.BasePip:SetWidth(2)
	pip.BasePip:SetHeight(height)
	pip.tex = pip:CreateTexture(nil, "ARTWORK", nil, 2)
	pip.tex:SetTexture(K.GetTexture(C["General"].Texture))
	pip.tex:SetVertexColor(unpack(Module.PipColors[stage]))

	return pip
end

-- REASON: Updates pip positions and states based on current cast stage.
-- REASON: numStages is always sourced from self; the parameter has been removed to eliminate the accidental shadow.
function Module:PostUpdatePips()
	local pips = self.Pips
	local numStages = self.numStages

	for stage = 1, numStages do
		local pip = pips[stage]
		pip.tex:SetAlpha(0.3) -- reset pip alpha
		pip.duration = self.stagePoints[stage]

		if stage == numStages then
			local firstPip = pips[1]
			local anchor = pips[numStages]
			firstPip.tex:SetPoint("BOTTOMRIGHT", self)
			firstPip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
		end

		if stage ~= 1 then
			local anchor = pips[stage - 1]
			pip.tex:SetPoint("BOTTOMRIGHT", pip.BasePip, "BOTTOMLEFT")
			pip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
		end
	end
end
