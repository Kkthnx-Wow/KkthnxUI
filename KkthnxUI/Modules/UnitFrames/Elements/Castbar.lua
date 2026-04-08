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
local tonumber = _G.tonumber
local unpack = _G.unpack

-- REASON: Localize Globals
local GetTime = _G.GetTime
local IsPlayerSpell = _G.IsPlayerSpell
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitInVehicle = _G.UnitInVehicle
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitReaction = _G.UnitReaction
local YOU = _G.YOU

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

-- REASON: Main update loop for castbar. Handles duration, texts, sparks, and pips.
function Module:OnCastbarUpdate(elapsed)
	if self.casting or self.channeling or self.empowering then
		local isCasting = self.casting or self.empowering
		local decimal = self.decimal

		local duration = isCasting and (self.duration + elapsed) or (self.duration - elapsed)
		if (isCasting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			self.empowering = nil
			return
		end

		-- REASON: Display logic differs for player (with latency) vs other units.
		if self.__owner.unit == "player" then
			if self.delay ~= 0 then
				self.Time:SetFormattedText(decimal .. " - |cffff0000" .. decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText(decimal .. " - " .. decimal, duration, self.max)
			end
		else
			if duration > 1e4 then
				self.Time:SetText("∞ - ∞")
			else
				self.Time:SetFormattedText(decimal .. " - " .. decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			end
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)

		-- REASON: Handle Empowered spells (pips/stages).
		if self.stageString then
			self.stageString:SetText("")
			if self.empowering then
				for i = self.numStages, 1, -1 do
					local pip = self.Pips[i]
					if pip and duration > pip.duration then
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
		if UnitIsUnit(unitTarget, "player") then
			nameString = string_format("|cffff0000%s|r", ">" .. string_upper(YOU) .. "<")
		else
			-- REASON: Class color the name if possible.
			nameString = K.RGBToHex(K.UnitColor(unitTarget)) .. UnitName(unitTarget)
		end
		if self._lastSpellTarget ~= nameString then
			self.spellTarget:SetText(nameString)
			self._lastSpellTarget = nameString
		end
	else
		ResetSpellTarget(self) -- when unit loses target
	end
end

-- REASON: Updates the castbar color based on class, reaction, or interruptible status.
local function UpdateCastBarColor(self, unit)
	local color = K.Colors.castbar.CastingColor

	-- REASON: Prioritize class color, then reaction color, then default.
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = class and K.Colors.class[class]
	elseif C["Unitframe"].CastReactionColor then
		local reaction = UnitReaction(unit, "player")
		color = reaction and K.Colors.reaction[reaction]
	elseif self.notInterruptible and not UnitIsUnit(unit, "player") then
		color = K.Colors.castbar.notInterruptibleColor
	end

	-- REASON: Grayish color for non-interruptible casts on nameplates.
	if self.__owner.mystyle == "nameplate" and self.notInterruptible then
		color = { 0.7, 0.7, 0.7 }
	end

	-- REASON: Apply color immediately.
	self:SetStatusBarColor(color[1], color[2], color[3])

	-- REASON: Visual feedback for nameplate shields/icon desaturation.
	if self.__owner.mystyle == "nameplate" then
		if self.notInterruptible then
			if self.Icon then
				self.Icon:SetDesaturated(true)
			end
			if self.Shield then
				self.Shield:Show()
			end
		else
			if self.Icon then
				self.Icon:SetDesaturated(false)
			end
			if self.Shield then
				self.Shield:Hide()
			end
		end
	end
end

-- REASON: Handler for when a cast starts. Sets up latency safezone and visual indicators.
function Module:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()

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
			local timeDiff = sendTime and math_min((GetTime() - sendTime), self.max)
			if timeDiff and timeDiff ~= 0 then
				local width = self:GetWidth() * timeDiff / self.max
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
		if self.channeling then
			numTicks = channelingTicks[self.spellID] or 0
		end
		CreateAndUpdateBarTicks(self, self.castTicks, numTicks)
	end

	UpdateCastBarColor(self, unit)

	if self.__owner.mystyle == "nameplate" then
		-- REASON: Support "Major Spells" glow on nameplates.
		if C.MajorSpells[self.spellID] then
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
		self:SetStatusBarColor(K.Colors.castbar.CompleteColor[1], K.Colors.castbar.CompleteColor[2], K.Colors.castbar.CompleteColor[3])
		self.fadeOut = true
	end

	self:Show()
	ResetSpellTarget(self)
end

-- REASON: Visual feedback for failed casts.
function Module:PostCastFailed()
	self:SetStatusBarColor(K.Colors.castbar.FailColor[1], K.Colors.castbar.FailColor[2], K.Colors.castbar.FailColor[3])
	self:SetValue(self.max)
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
function Module:PostUpdatePips(numStages)
	local pips = self.Pips
	local numStages = self.numStages -- REASON: Shadow numStages for safer access/performance.

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
