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
local UnitInVehicle = _G.UnitInVehicle
local UnitIsPlayer = _G.UnitIsPlayer
local UnitReaction = _G.UnitReaction
local UnitSpellTargetName = _G.UnitSpellTargetName
local UnitSpellTargetClass = _G.UnitSpellTargetClass
local UnitShouldDisplaySpellTargetName = _G.UnitShouldDisplaySpellTargetName
local PlayerIsSpellTarget = _G.PlayerIsSpellTarget
local Ambiguate = _G.Ambiguate
local GetPlayerInfoByGUID = _G.GetPlayerInfoByGUID
local INTERRUPTED = _G.INTERRUPTED
local YOU = _G.YOU

-- SECRET (12.0): spellID from UnitCastingInfo/UnitChannelInfo is secret on
-- nameplates/units in instances, and indexing a table with a secret key throws.
-- Use the shared K.IsSecret gate to short-circuit those Lua-table lookups.
local IsSecret = K.IsSecret

-- SECRET (12.0): UnitCastingInfo/UnitChannelInfo's `notInterruptible` is a secret
-- boolean on nameplates and units in combat, so we can never read it with a Lua
-- boolean test. Instead we feed it straight into the engine's secret-safe widget
-- helpers (SetVertexColorFromBoolean / SetAlphaFromBoolean), which need ColorMixin
-- objects. Build them once from the palette (one cache for all castbars).
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

Module._castingCastbars = {}

local function ShouldUseKickTick(castbar)
	if not C["Unitframe"].CastbarKickTick or not castbar then
		return false
	end
	local owner = castbar.__owner
	if not owner then
		return false
	end
	local style = owner.mystyle
	if style == "nameplate" or style == "arena" or style == "boss" then
		return true
	end
	local unit = owner.unit
	if not unit then
		return false
	end
	if unit == "target" or unit == "focus" then
		return true
	end
	-- Arena/boss frames may not have mystyle set yet; match tokens too.
	return unit:match("^arena%d+$") ~= nil or unit:match("^boss%d+$") ~= nil
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
			-- PERF: this runs every frame for the whole cast. self.decimal is a fixed
			-- format ("%.1f"/"%.2f") set once at castbar creation, so cache the two
			-- composed "cur - total" formats on the bar instead of re-concatenating
			-- them each frame. Rebuild only if decimal ever changes.
			if self._timeFmtFor ~= decimal then
				self._timeFmtFor = decimal
				self._timeFmt = decimal .. " - " .. decimal
				self._timeFmtDelay = decimal .. " - |cffff0000" .. decimal
			end

			local total = durationObject:GetTotalDuration()
			-- channels count down (remaining), casts/empowers count up (elapsed)
			local cur = self.channeling and durationObject:GetRemainingDuration() or durationObject:GetElapsedDuration()

			-- REASON: Display logic differs for player (with latency) vs other units.
			if self.__owner.unit == "player" then
				if self.delay and self.delay ~= 0 then
					self.Time:SetFormattedText(self._timeFmtDelay, cur, total)
				else
					self.Time:SetFormattedText(self._timeFmt, cur, total)
				end
			elseif total and total > 1e4 then
				self.Time:SetText("∞ - ∞")
			else
				self.Time:SetFormattedText(self._timeFmt, cur, total)
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
		else
			-- SECRET: don't leave the previous cast's numbers on the bar.
			if self.Time then
				self.Time:SetText("")
			end
			if self.stageString then
				self.stageString:SetText("")
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

-- REASON: Spell cast target — Blizzard CastingBarFrame APIs (not unit.."target").
-- UnitSpellTargetName / UnitSpellTargetClass / PlayerIsSpellTarget are SecretReturns;
-- push secrets straight to SetText, only branch when NotSecret / BooleanIsTrue.
local function UpdateSpellTarget(self, unit)
	local isNameplate = self.__owner and self.__owner.mystyle == "nameplate"
	local enabled = isNameplate and C["Nameplate"].CastTarget or C["Unitframe"].CastTarget
	if not enabled then
		return
	end

	if not self.spellTarget or not unit then
		return
	end

	-- UF: Blizzard only wants a target line for some casts (boss/important).
	if not isNameplate and UnitShouldDisplaySpellTargetName then
		local shouldShow = UnitShouldDisplaySpellTargetName(unit)
		-- NeverSecret / plain bool when readable; if secret, still try the name APIs.
		if K.NotSecret(shouldShow) and not shouldShow then
			ResetSpellTarget(self)
			return
		end
	end

	local targetName = UnitSpellTargetName and UnitSpellTargetName(unit)
	if not targetName then
		ResetSpellTarget(self)
		return
	end

	local nameString
	if K.BooleanIsTrue(PlayerIsSpellTarget and PlayerIsSpellTarget(unit)) then
		nameString = string_format("|cffff0000%s|r", ">" .. string_upper(YOU) .. "<")
	elseif IsSecret(targetName) then
		nameString = targetName
	else
		local classFilename = UnitSpellTargetClass and UnitSpellTargetClass(unit)
		if K.NotSecret(classFilename) and classFilename and K.Colors.class[classFilename] then
			nameString = K.RGBToHex(K.Colors.class[classFilename]) .. targetName
		else
			nameString = targetName
		end
	end

	if IsSecret(nameString) then
		self.spellTarget:SetText(nameString)
		self._lastSpellTarget = nil
	elseif self._lastSpellTarget ~= nameString then
		self.spellTarget:SetText(nameString)
		self._lastSpellTarget = nameString
	end
end

local function SetNameplateNameHidden(castbar, hidden)
	if not C["Nameplate"].HideNameWhileCasting then
		return
	end
	local plate = castbar and castbar.__owner
	if not plate or plate.mystyle ~= "nameplate" or not plate.nameText then
		return
	end
	if hidden then
		plate.nameText:Hide()
	else
		plate.nameText:Show()
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
		-- Kick-ready tint layers on the interruptible casting color (secret-safe CD).
		local base = K.Colors.castbar.CastingColor
		local ready = K.Colors.castbar.InterruptReadyColor
		if ShouldUseKickTick(self) and K.ComputeCastBarTint and ready then
			local r, g, b = K.ComputeCastBarTint({ r = ready[1], g = ready[2], b = ready[3] }, { r = base[1], g = base[2], b = base[3] })
			CastingColorMixin:SetRGB(r, g, b)
		else
			CastingColorMixin:SetRGB(base[1], base[2], base[3])
		end
		-- SECRET (12.0): grey for non-interruptible, casting color otherwise. The
		-- engine evaluates the secret boolean for us, so we
		-- never perform a forbidden boolean test on self.notInterruptible.
		sbTex:SetVertexColorFromBoolean(self.notInterruptible, NotInterruptColorMixin, CastingColorMixin)
	else
		local base = K.Colors.castbar.CastingColor
		CastingColorMixin:SetRGB(base[1], base[2], base[3])
		self:SetStatusBarColor(CastingColorMixin:GetRGB())
	end

	-- SECRET (12.0): shield + icon dim for every castbar that owns them — UF
	-- used to create Shield then never drive it (nameplates only). Boolean
	-- widgets evaluate notInterruptible for us; no Lua branch on the secret.
	if self.Shield then
		self.Shield:SetAlphaFromBoolean(self.notInterruptible, 1, 0)
	end
	if isNameplate and self.Icon then
		self.Icon:SetVertexColorFromBoolean(self.notInterruptible, IconDimColorMixin, IconNormalColorMixin)
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

		Module:RefreshCastOverlay(self.__owner)
		SetNameplateNameHidden(self, true)
	end

	UpdateSpellTarget(self, unit)

	if ShouldUseKickTick(self) then
		Module:UpdateKickTick(self)
		Module._castingCastbars[self] = true
	end
end

function Module:PostCastUpdate(unit)
	UpdateSpellTarget(self, unit)
end

function Module:PostUpdateInterruptible(unit)
	UpdateCastBarColor(self, unit)
	if ShouldUseKickTick(self) and self.kickPositioner then
		Module:UpdateKickTick(self)
	end
end

-- REASON: Reset bar color and target text on cast stop.
function Module:PostCastStop()
	Module:HideKickTick(self)
	SetNameplateNameHidden(self, false)
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
	Module:HideKickTick(self)
	SetNameplateNameHidden(self, false)
	-- PERF: unpack traverses the table once instead of three separate chained index lookups.
	self:SetStatusBarColor(unpack(K.Colors.castbar.FailColor))
	-- MIDNIGHT (12.0): the bar is a normalized 0-1 StatusBar driven by interpolation,
	-- so force it visually full on failure (self.max no longer exists).
	self:SetValue(1)
	self.fadeOut = true
	self:Show()
	ResetSpellTarget(self)
end

-- REASON: Nameplate castbars show who interrupted via UNIT_SPELLCAST_* (no CLEU).
function Module:PostCastInterrupted(unit, interruptedBy)
	if not interruptedBy or IsSecret(interruptedBy) then
		return
	end

	local _, class, _, _, _, name = GetPlayerInfoByGUID(interruptedBy)
	if not name or name == "" or IsSecret(name) then
		return
	end

	local r, g, b = K.ColorClass(class)
	local color = K.RGBToHex(r, g, b)
	local interrupterName = Ambiguate(name, "short")

	if self.Text then
		self.Text:SetFormattedText("%s [ %s%s|r ]", INTERRUPTED, color, interrupterName)
	end
	if self.Time then
		self.Time:SetText("")
	end
	Module:HideKickTick(self)
	SetNameplateNameHidden(self, false)
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
-- MIDNIGHT (12.0): the bundled oUF never sets self.numStages/self.stagePoints; it
-- passes the stage percentage table (UnitEmpoweredStagePercentages) as an argument.
-- Derive the stage count and per-stage boundary times from that, and publish
-- self.numStages for OnCastbarUpdate's stage-counter logic.
function Module:PostUpdatePips(stages)
	local pips = self.Pips
	local numStages = type(stages) == "table" and not K.IsSecretTable(stages) and #stages or 0
	self.numStages = numStages
	self.pipStage = nil

	if numStages == 0 or not pips then
		return
	end

	-- Total cast time (seconds) to convert stage fractions into boundary times.
	local total
	local durationObject = self.GetTimerDuration and self:GetTimerDuration()
	if durationObject and not durationObject:HasSecretValues() then
		total = durationObject:GetTotalDuration()
	end

	local cumulative = 0
	for stage = 1, numStages do
		local pip = pips[stage]
		if not pip then
			return
		end

		pip.tex:SetAlpha(0.3) -- reset pip alpha

		local section = stages[stage]
		if total and type(section) == "number" and not K.IsSecret(section) then
			cumulative = cumulative + section
			pip.duration = total * cumulative
		else
			pip.duration = nil -- OnCastbarUpdate guards on pip.duration
		end

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

-- ---------------------------------------------------------------------------
-- KICK TICK (target/focus/arena/boss castbars)
-- ---------------------------------------------------------------------------

-- REASON: Standard oUF castbar for unit frames (party, boss, arena, etc.).
function Module:CreateUnitCastbar(frame, opts)
	opts = opts or {}
	local Castbar = CreateFrame("StatusBar", opts.name, frame)
	Castbar:SetStatusBarTexture(opts.texture or K.GetTexture(C["General"].Texture))
	Castbar:SetFrameLevel(opts.frameLevel or 10)
	Castbar:SetClampedToScreen(opts.clampedToScreen == true)

	local height = opts.height or 18
	if opts.width then
		Castbar:SetSize(opts.width, height)
	else
		Castbar:SetHeight(height)
	end

	if opts.onSize then
		opts.onSize(Castbar, frame)
	elseif opts.point then
		Castbar:SetPoint(opts.point, opts.relativeTo or frame.Health, opts.relativePoint, opts.x or 0, opts.y or 6)
	else
		Castbar:SetPoint("BOTTOM", opts.relativeTo or frame.Health, "TOP", opts.x or 0, opts.y or 6)
		if opts.width then
			Castbar:SetWidth(opts.width)
		end
	end

	Castbar:CreateBorder()
	Castbar.castTicks = {}

	local sparkSubLevel = opts.sparkSubLevel or 2
	Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY", nil, sparkSubLevel)
	Castbar.Spark:SetSize(opts.sparkWidth or 64, Castbar:GetHeight() - (opts.sparkInset or 2))
	Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	Castbar.Spark:SetBlendMode("ADD")
	Castbar.Spark:SetAlpha(opts.sparkAlpha or 0.8)

	if opts.shield then
		local shield = Castbar:CreateTexture(nil, "OVERLAY", nil, 4)
		shield:SetAtlas("Soulbinds_Portrait_Lock")
		local shieldSize = type(opts.shield) == "table" and opts.shield.size or 28
		shield:SetSize(shieldSize, shieldSize)
		shield:SetPoint("TOP", Castbar, "CENTER", 0, 6)
		Castbar.Shield = shield
	end

	local textSize = opts.textSize or 11

	local labelAnchor = CreateFrame("Frame", nil, Castbar)
	labelAnchor:EnableMouse(false)
	labelAnchor:SetAllPoints(Castbar)
	labelAnchor:SetFrameLevel(Castbar:GetFrameLevel() + 8)
	Castbar.labelAnchor = labelAnchor

	local timer = K.CreateFontString(labelAnchor, textSize, "", "", false)
	local name = K.CreateFontString(labelAnchor, textSize, "", "", false)
	-- Spell name left, duration right — long names truncate into the gap before the timer.
	-- OVERLAY+7 sits above shield/icon ARTWORK so boss timer isn't painted under the lock.
	timer:SetDrawLayer("OVERLAY", 7)
	name:SetDrawLayer("OVERLAY", 7)
	local textJustify = opts.textJustify or "LEFT"
	timer:SetPoint("RIGHT", labelAnchor, "RIGHT", opts.timeX or -3, opts.timeY or 0)
	name:SetPoint("LEFT", labelAnchor, "LEFT", opts.textX or 3, opts.textY or 0)
	name:SetPoint("RIGHT", timer, "LEFT", -(opts.textGap or 5), 0)
	name:SetJustifyH(textJustify)
	name:SetWordWrap(false)
	if opts.textColor then
		timer:SetTextColor(opts.textColor[1], opts.textColor[2], opts.textColor[3], opts.textColor[4] or 1)
		name:SetTextColor(opts.textColor[1], opts.textColor[2], opts.textColor[3], opts.textColor[4] or 1)
	end
	if opts.timerJustify then
		timer:SetJustifyH(opts.timerJustify)
	else
		timer:SetJustifyH("RIGHT")
	end
	if opts.icon ~= false then
		Castbar.Icon = Castbar:CreateTexture(nil, "ARTWORK")
		Castbar.Icon:SetSize(opts.iconSize or Castbar:GetHeight(), opts.iconSize or Castbar:GetHeight())
		Castbar.Icon:SetPoint(opts.iconPoint or "BOTTOMRIGHT", Castbar, opts.iconRelative or "BOTTOMLEFT", opts.iconX or -6, opts.iconY or 0)
		Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		Castbar.Button = CreateFrame("Frame", nil, Castbar)
		if opts.iconButtonSize then
			Castbar.Button:SetSize(opts.iconButtonSize, opts.iconButtonSize)
		end
		Castbar.Button:CreateBorder()
		Castbar.Button:SetAllPoints(Castbar.Icon)
		Castbar.Button:SetFrameLevel(Castbar:GetFrameLevel())

		local stage = K.CreateFontString(Castbar, opts.stageSize or 16)
		stage:ClearAllPoints()
		stage:SetPoint("TOPLEFT", Castbar.Icon, 1, -1)
		Castbar.stageString = stage
	end

	if opts.latency then
		local safeZone = Castbar:CreateTexture(nil, "OVERLAY")
		safeZone:SetTexture(K.GetTexture(C["General"].Texture))
		safeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		safeZone:SetPoint("TOPRIGHT")
		safeZone:SetPoint("BOTTOMRIGHT")
		Castbar.SafeZone = safeZone

		local lagStr = K.CreateFontString(Castbar, opts.lagTextSize or 11)
		lagStr:ClearAllPoints()
		lagStr:SetPoint("BOTTOM", Castbar, "TOP", 0, 4)
		Castbar.LagString = lagStr
	end

	Castbar.decimal = opts.decimal or "%.1f"
	Castbar.Time = timer
	Castbar.Text = name

	-- Spell-target line under the cast name (target/focus/boss when Unitframe.CastTarget).
	if opts.spellTarget or (C["Unitframe"].CastTarget and opts.kickTick) then
		local spellTarget = K.CreateFontString(labelAnchor, (opts.textSize or 11) - 1, "", "", false)
		spellTarget:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
		spellTarget:SetPoint("TOPRIGHT", timer, "BOTTOMRIGHT", 0, -2)
		spellTarget:SetJustifyH("LEFT")
		spellTarget:SetWordWrap(false)
		spellTarget:SetDrawLayer("OVERLAY", 7)
		Castbar.spellTarget = spellTarget
	end

	if opts.timeToHold then
		Castbar.timeToHold = opts.timeToHold
	end
	Castbar.OnUpdate = Module.OnCastbarUpdate
	Castbar.PostCastStart = Module.PostCastStart
	Castbar.PostCastUpdate = Module.PostCastUpdate
	Castbar.PostCastStop = Module.PostCastStop
	Castbar.PostCastFail = Module.PostCastFailed
	Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
	Castbar.CreatePip = Module.CreatePip
	Castbar.PostUpdatePips = Module.PostUpdatePips

	if opts.mover then
		local m = opts.mover
		local mover = K.Mover(Castbar, m.label, m.key, m.anchor, m.width, m.height)
		Castbar:ClearAllPoints()
		Castbar:SetPoint(m.attachPoint or "RIGHT", mover)
		Castbar.mover = mover
	end

	if opts.kickTick then
		Module:CreateKickTickFrames(Castbar)
	end

	frame.Castbar = Castbar

	if opts.latency then
		Module:ToggleCastBarLatency(frame)
	end

	if opts.afterCreate then
		opts.afterCreate(Castbar, frame)
	end

	return Castbar
end

local Enum_StatusBarFillStyle_Reverse = Enum and Enum.StatusBarFillStyle and Enum.StatusBarFillStyle.Reverse
local Enum_StatusBarFillStyle_Standard = Enum and Enum.StatusBarFillStyle and Enum.StatusBarFillStyle.Standard

local function DisableStatusBarSnap(texture)
	if texture and texture.SetSnapToPixelGrid then
		texture:SetSnapToPixelGrid(false)
		texture:SetTexelSnappingBias(0)
	end
end

function Module:CreateKickTickFrames(castbar)
	if not castbar or castbar.kickPositioner then
		return
	end

	local kickClip = CreateFrame("Frame", nil, castbar)
	kickClip:SetAllPoints(castbar)
	kickClip:SetClipsChildren(true)
	castbar.kickClip = kickClip

	local kickPositioner = CreateFrame("StatusBar", nil, kickClip)
	kickPositioner:SetStatusBarTexture(C["Media"].Textures.White8x8Texture)
	kickPositioner:GetStatusBarTexture():SetAlpha(0)
	DisableStatusBarSnap(kickPositioner:GetStatusBarTexture())
	kickPositioner:SetPoint("CENTER", castbar)
	kickPositioner:SetFrameLevel(castbar:GetFrameLevel() + 1)
	kickPositioner:Hide()
	castbar.kickPositioner = kickPositioner

	local kickMarker = CreateFrame("StatusBar", nil, kickClip)
	kickMarker:SetStatusBarTexture(C["Media"].Textures.White8x8Texture)
	kickMarker:GetStatusBarTexture():SetAlpha(0)
	DisableStatusBarSnap(kickMarker:GetStatusBarTexture())
	kickMarker:SetPoint("LEFT", kickPositioner:GetStatusBarTexture(), "RIGHT")
	kickMarker:SetSize(1, 1)
	kickMarker:SetFrameLevel(castbar:GetFrameLevel() + 2)
	kickMarker:Hide()
	castbar.kickMarker = kickMarker

	local kickTick = kickMarker:CreateTexture(nil, "OVERLAY", nil, 3)
	kickTick:SetColorTexture(1, 0.35, 0.2, 1)
	kickTick:SetWidth(2)
	kickTick:SetPoint("TOP", kickMarker, "TOP", 0, 0)
	kickTick:SetPoint("BOTTOM", kickMarker, "BOTTOM", 0, 0)
	kickTick:SetPoint("LEFT", kickMarker:GetStatusBarTexture(), "RIGHT")
	castbar.kickTick = kickTick

	-- Mid-cast window: from kick-ready edge to cast end. Anchors cross to zero
	-- width when the interrupt won't land in time — no secret Lua branch needed.
	local kickReadyFill = castbar:CreateTexture(nil, "ARTWORK", nil, 1)
	kickReadyFill:SetColorTexture(0.32, 0.82, 0.36, 1)
	kickReadyFill:SetAlpha(0)
	kickReadyFill:Hide()
	castbar.kickReadyFill = kickReadyFill
end

function Module:HideKickTick(castbar)
	if not castbar or not castbar.kickPositioner then
		return
	end
	castbar.kickPositioner:Hide()
	castbar.kickMarker:Hide()
	if castbar.kickReadyFill then
		castbar.kickReadyFill:Hide()
	end
	if castbar._kickTicker then
		castbar._kickTicker:Cancel()
		castbar._kickTicker = nil
	end
	Module._castingCastbars[castbar] = nil
end

local function GetCastbarUninterruptible(castbar)
	local value = castbar and castbar.notInterruptible
	if value == nil then
		return false
	end
	return value
end

function Module:UpdateKickTick(castbar)
	if not ShouldUseKickTick(castbar) or not castbar.kickPositioner then
		return
	end

	local ownerUnit = castbar.__owner and castbar.__owner.unit
	if not ownerUnit then
		Module:HideKickTick(castbar)
		return
	end

	local kickSpell = K.GetActiveKickSpell()
	if not kickSpell or not (C_Spell and C_Spell.GetSpellCooldownDuration) then
		Module:HideKickTick(castbar)
		return
	end

	local kickProtected = GetCastbarUninterruptible(castbar)
	castbar._kickProtected = kickProtected
	local isChannel = castbar.channeling and true or false
	local isEmpowered = false

	-- Transient API/read misses during an ongoing cast: skip, do not hide.
	-- Hide/re-Show on every SPELL_UPDATE_COOLDOWN is what made the tick blink.
	if not UnitCastingDuration then
		return
	end

	local castDuration
	if isChannel then
		if UnitEmpoweredChannelDuration then
			castDuration = UnitEmpoweredChannelDuration(ownerUnit, true)
			if castDuration then
				isEmpowered = true
			end
		end
		if not castDuration and UnitChannelDuration then
			castDuration = UnitChannelDuration(ownerUnit)
		end
	else
		castDuration = UnitCastingDuration(ownerUnit)
	end
	if not castDuration then
		return
	end

	castbar._kickIsChannel = isChannel
	castbar._kickIsEmpowered = isEmpowered

	local totalDur = castDuration:GetTotalDuration()
	local interruptCD = C_Spell.GetSpellCooldownDuration(kickSpell)
	if not interruptCD then
		return
	end

	local barW = castbar:GetWidth()
	local barH = castbar:GetHeight()
	if not barW or barW <= 0 then
		return
	end

	castbar.kickPositioner:SetSize(barW, barH)
	castbar.kickPositioner:SetMinMaxValues(0, totalDur)
	castbar.kickMarker:SetMinMaxValues(0, totalDur)
	castbar.kickMarker:SetSize(barW, barH)
	castbar.kickPositioner:SetValue(castDuration:GetElapsedDuration())
	castbar.kickMarker:SetValue(interruptCD:GetRemainingDuration())

	local readyFill = castbar.kickReadyFill
	if isChannel and not isEmpowered and Enum_StatusBarFillStyle_Reverse then
		castbar.kickPositioner:SetFillStyle(Enum_StatusBarFillStyle_Reverse)
		castbar.kickMarker:SetFillStyle(Enum_StatusBarFillStyle_Reverse)
		DisableStatusBarSnap(castbar.kickPositioner:GetStatusBarTexture())
		DisableStatusBarSnap(castbar.kickMarker:GetStatusBarTexture())
		castbar.kickMarker:ClearAllPoints()
		castbar.kickTick:ClearAllPoints()
		castbar.kickMarker:SetPoint("RIGHT", castbar.kickPositioner:GetStatusBarTexture(), "LEFT")
		castbar.kickTick:SetPoint("TOP", castbar.kickMarker, "TOP", 0, 0)
		castbar.kickTick:SetPoint("BOTTOM", castbar.kickMarker, "BOTTOM", 0, 0)
		castbar.kickTick:SetPoint("RIGHT", castbar.kickMarker:GetStatusBarTexture(), "LEFT")
		if readyFill then
			readyFill:ClearAllPoints()
			readyFill:SetPoint("TOP", castbar, "TOP", 0, 0)
			readyFill:SetPoint("BOTTOM", castbar, "BOTTOM", 0, 0)
			readyFill:SetPoint("LEFT", castbar, "LEFT", 0, 0)
			readyFill:SetPoint("RIGHT", castbar.kickMarker:GetStatusBarTexture(), "LEFT")
		end
	else
		if Enum_StatusBarFillStyle_Standard then
			castbar.kickPositioner:SetFillStyle(Enum_StatusBarFillStyle_Standard)
			castbar.kickMarker:SetFillStyle(Enum_StatusBarFillStyle_Standard)
		end
		DisableStatusBarSnap(castbar.kickPositioner:GetStatusBarTexture())
		DisableStatusBarSnap(castbar.kickMarker:GetStatusBarTexture())
		castbar.kickMarker:ClearAllPoints()
		castbar.kickTick:ClearAllPoints()
		castbar.kickMarker:SetPoint("LEFT", castbar.kickPositioner:GetStatusBarTexture(), "RIGHT")
		castbar.kickTick:SetPoint("TOP", castbar.kickMarker, "TOP", 0, 0)
		castbar.kickTick:SetPoint("BOTTOM", castbar.kickMarker, "BOTTOM", 0, 0)
		castbar.kickTick:SetPoint("LEFT", castbar.kickMarker:GetStatusBarTexture(), "RIGHT")
		if readyFill then
			readyFill:ClearAllPoints()
			readyFill:SetPoint("TOP", castbar, "TOP", 0, 0)
			readyFill:SetPoint("BOTTOM", castbar, "BOTTOM", 0, 0)
			readyFill:SetPoint("LEFT", castbar.kickMarker:GetStatusBarTexture(), "RIGHT")
			readyFill:SetPoint("RIGHT", castbar, "RIGHT", 0, 0)
		end
	end

	castbar.kickPositioner:Show()
	castbar.kickMarker:Show()

	-- Tick and mid-cast fill are independent toggles (SetShown).
	local tickOn = C["Unitframe"].CastbarKickTick ~= false
	local midOn = C["Unitframe"].CastbarKickReadyFill == true
	castbar.kickTick:SetShown(tickOn)
	local readyFill = castbar.kickReadyFill
	if readyFill then
		readyFill:SetShown(midOn)
	end

	if interruptCD.IsZero and C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean then
		local interruptible = C_CurveUtil.EvaluateColorValueFromBoolean(kickProtected, 0, 1)
		local kickReady = interruptCD:IsZero()
		local alpha = C_CurveUtil.EvaluateColorValueFromBoolean(kickReady, 0, interruptible)
		castbar.kickTick:SetAlpha(tickOn and alpha or 0)
		if readyFill then
			readyFill:SetAlpha(midOn and alpha or 0)
		end
	else
		castbar.kickTick:SetAlpha(0)
		if readyFill then
			readyFill:SetAlpha(0)
		end
	end

	if castbar._kickTicker then
		castbar._kickTicker:Cancel()
	end
	castbar._kickTicker = C_Timer.NewTicker(0.1, function()
		if not castbar:IsShown() or not ownerUnit then
			Module:HideKickTick(castbar)
			return
		end
		if not K.GetActiveKickSpell() then
			Module:HideKickTick(castbar)
			return
		end
		local icd = C_Spell.GetSpellCooldownDuration(K.GetActiveKickSpell())
		if icd and icd.IsZero and C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean then
			local interruptible = C_CurveUtil.EvaluateColorValueFromBoolean(castbar._kickProtected, 0, 1)
			local alpha = C_CurveUtil.EvaluateColorValueFromBoolean(icd:IsZero(), 0, interruptible)
			local tickEnabled = C["Unitframe"].CastbarKickTick ~= false
			local midEnabled = C["Unitframe"].CastbarKickReadyFill == true
			castbar.kickTick:SetAlpha(tickEnabled and alpha or 0)
			if castbar.kickReadyFill then
				castbar.kickReadyFill:SetAlpha(midEnabled and alpha or 0)
			end
		end
	end)
end

function Module:RefreshKickTick(castbar)
	if not castbar or not castbar.kickPositioner or not castbar.kickPositioner:IsShown() then
		return
	end

	local kickSpell = K.GetActiveKickSpell()
	if not kickSpell or not (C_Spell and C_Spell.GetSpellCooldownDuration) then
		Module:HideKickTick(castbar)
		return
	end

	local interruptCD = C_Spell.GetSpellCooldownDuration(kickSpell)
	if not interruptCD then
		return
	end

	local ownerUnit = castbar.__owner and castbar.__owner.unit
	if not (UnitCastingDuration and ownerUnit) then
		return
	end

	local castDuration
	if castbar._kickIsChannel then
		if castbar._kickIsEmpowered and UnitEmpoweredChannelDuration then
			castDuration = UnitEmpoweredChannelDuration(ownerUnit, true)
		end
		if not castDuration and UnitChannelDuration then
			castDuration = UnitChannelDuration(ownerUnit)
		end
	else
		castDuration = UnitCastingDuration(ownerUnit)
	end
	if not castDuration then
		return
	end

	castbar.kickPositioner:SetValue(castDuration:GetElapsedDuration())
	castbar.kickMarker:SetValue(interruptCD:GetRemainingDuration())

	if interruptCD.IsZero and C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean then
		local interruptible = C_CurveUtil.EvaluateColorValueFromBoolean(castbar._kickProtected, 0, 1)
		local alpha = C_CurveUtil.EvaluateColorValueFromBoolean(interruptCD:IsZero(), 0, interruptible)
		local tickOn = C["Unitframe"].CastbarKickTick ~= false
		local midOn = C["Unitframe"].CastbarKickReadyFill == true
		castbar.kickTick:SetAlpha(tickOn and alpha or 0)
		if castbar.kickReadyFill then
			castbar.kickReadyFill:SetAlpha(midOn and alpha or 0)
		end
	end
end

local kickWatcher = CreateFrame("Frame")
kickWatcher:RegisterEvent("SPELL_UPDATE_COOLDOWN")
kickWatcher:RegisterEvent("SPELL_UPDATE_USABLE")
kickWatcher:SetScript("OnEvent", function()
	for castbar in pairs(Module._castingCastbars) do
		if castbar:IsShown() and castbar.__owner and castbar.__owner.unit then
			if castbar.kickPositioner and not castbar.kickPositioner:IsShown() then
				Module:UpdateKickTick(castbar)
			else
				Module:RefreshKickTick(castbar)
			end
		end
	end
end)
