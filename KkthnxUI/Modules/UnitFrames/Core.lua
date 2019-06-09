local K, C = unpack(select(2, ...))
local Module = K:NewModule("Unitframes", "AceEvent-3.0", "AceTimer-3.0")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local math_ceil = math.ceil
local math_min = math.min
local pairs = pairs
local select = select
local string_find = string.find
local string_match = string.match
local table_insert = table.insert
local tonumber = tonumber
local unpack = unpack

local C_NamePlate_GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit
local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local COOLDOWN_Anchor = _G.COOLDOWN_Anchor
local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetCVarDefault = _G.GetCVarDefault
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local MAX_ARENA_ENEMIES = _G.MAX_ARENA_ENEMIES or 5
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES or 5
local oUF_RaidDebuffs = _G.oUF_RaidDebuffs
local P_BUFF_ICON_Anchor = _G.P_BUFF_ICON_Anchor
local P_PROC_ICON_Anchor = _G.P_PROC_ICON_Anchor
local PlaySound = _G.PlaySound
local PVE_PVP_CC_Anchor = _G.PVE_PVP_CC_Anchor
local PVE_PVP_DEBUFF_Anchor = _G.PVE_PVP_DEBUFF_Anchor
local SetCVar = _G.SetCVar
local SOUNDKIT = _G.SOUNDKIT
local SPECIAL_P_BUFF_ICON_Anchor = _G.SPECIAL_P_BUFF_ICON_Anchor
local T_BUFF_Anchor = _G.T_BUFF_Anchor
local T_DE_BUFF_BAR_Anchor = _G.T_DE_BUFF_BAR_Anchor
local T_DEBUFF_ICON_Anchor = _G.T_DEBUFF_ICON_Anchor
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitReaction = _G.UnitReaction
local UnitSpellHaste = _G.UnitSpellHaste

Module.ticks = {}

Module.RaidBuffsTrackingPosition = {
	TOPLEFT = {6, 1},
	TOPRIGHT = {-6, 1},
	BOTTOMLEFT = {6, 1},
	BOTTOMRIGHT = {-6, 1},
	LEFT = {6, 1},
	RIGHT = {-6, 1},
	TOP = {0, 0},
	BOTTOM = {0, 0}
}

Module.DebuffHighlightColors = {
	[25771] = {
		enable = false,
		style = "FILL",
		color = {r = 0.85, g = 0, b = 0, a = 0.85}
	},
}

Module.PlateTotemData = {
	[GetSpellInfo(192058)] = "Interface\\Icons\\spell_nature_brilliance", -- Lightning Surge Totem
	[GetSpellInfo(192077)] = "Interface\\Icons\\ability_shaman_windwalktotem", -- Wind Rush Totem
	[GetSpellInfo(204331)] = "Interface\\Icons\\spell_nature_wrathofair_totem", -- Counterstrike Totem
	[GetSpellInfo(204332)] = "Interface\\Icons\\spell_nature_windfury", -- Windfury Totem
	[GetSpellInfo(204336)] = "Interface\\Icons\\spell_nature_groundingtotem", -- Grounding Totem
	[GetSpellInfo(98008)] = "Interface\\Icons\\spell_shaman_spiritlink", -- Spirit Link Totem
	-- Water
	[GetSpellInfo(108280)] = "Interface\\Icons\\ability_shaman_healingtide", -- Healing Tide Totem
	[GetSpellInfo(157153)] = "Interface\\Icons\\ability_shaman_condensationtotem", -- Cloudburst Totem
	[GetSpellInfo(5394)] = "Interface\\Icons\\INV_Spear_04", -- Healing Stream Totem
	-- Earth
	[GetSpellInfo(196932)] = "Interface\\Icons\\spell_totem_wardofdraining", -- Voodoo Totem
	[GetSpellInfo(198838)] = "Interface\\Icons\\spell_nature_stoneskintotem", -- Earthen Shield Totem
	[GetSpellInfo(207399)] = "Interface\\Icons\\spell_nature_reincarnation", -- Ancestral Protection Totem
	[GetSpellInfo(51485)] = "Interface\\Icons\\spell_nature_stranglevines", -- Earthgrab Totem
	[GetSpellInfo(61882)] = "Interface\\Icons\\spell_shaman_earthquake", -- Earthquake Totem
	-- Fire
	[GetSpellInfo(192222)] = "Interface\\Icons\\spell_shaman_spewlava", -- Liquid Magma Totem
	[GetSpellInfo(204330)] = "Interface\\Icons\\spell_fire_totemofwrath", -- Skyfury Totem
	-- Totem Mastery
	[GetSpellInfo(202188)] = "Interface\\Icons\\spell_nature_stoneskintotem", -- Resonance Totem
	[GetSpellInfo(210651)] = "Interface\\Icons\\spell_shaman_stormtotem", -- Storm Totem
	[GetSpellInfo(210657)] = "Interface\\Icons\\spell_fire_searingtotem", -- Ember Totem
	[GetSpellInfo(210660)] = "Interface\\Icons\\spell_nature_invisibilitytotem", -- Tailwind Totem
}

function Module:ThreatIndicatorPreUpdate(unit)
	local ROLE = Module.IsInGroup and (UnitExists(unit.."target") and not UnitIsUnit(unit.."target", "player")) and Module.GroupRoles[UnitName(unit.."target")] or "NONE"

	if ROLE == "TANK" then
		self.feedbackUnit = unit.."target"
		self.offTank = K.Role == "TANK"
		self.isTank = true
	else
		self.feedbackUnit = "player"
		self.offTank = false
		self.isTank = K.Role == "TANK"
	end

	self.__owner.ThreatStatus = nil
	self.__owner.ThreatOffTank = self.offTank
	self.__owner.ThreatIsTank = self.isTank
end

function Module:ThreatIndicatorPostUpdate(unit, status)
	if C["Nameplates"].Threat and not UnitIsTapDenied(unit) and status then
		self.__owner.Health.colorTapping = false
		self.__owner.Health.colorDisconnected = false
		self.__owner.Health.colorClass = false
		self.__owner.Health.colorClassNPC = false
		self.__owner.Health.colorClassPet = false
		self.__owner.Health.colorSelection = false
		self.__owner.Health.colorThreat = false
		self.__owner.Health.colorReaction = false
		self.__owner.Health.colorSmooth = false
		self.__owner.Health.colorHealth = false

		self.__owner.ThreatStatus = status

		local Color
		if (status == 3) then -- securely tanking
			Color = self.offTank and C["Nameplates"].OffTankColor or self.isTank and C["Nameplates"].GoodColor or C["Nameplates"].BadColor
		elseif (status == 2) then -- insecurely tanking
			Color = self.offTank and C["Nameplates"].OffTankColorColorBadTransition or self.isTank and C["Nameplates"].BadTransition or C["Nameplates"].GoodTransition
		elseif (status == 1) then -- not tanking but threat higher than tank
			Color = self.offTank and C["Nameplates"].OffTankColorColorGoodTransition or self.isTank and C["Nameplates"].GoodTransition or C["Nameplates"].BadTransition
		else -- not tanking at all
			Color = self.isTank and C["Nameplates"].BadColor or C["Nameplates"].GoodColor
		end

		local r, g, b
        r, g, b = Color[1], Color[2], Color[3]

        if self.__owner.HealthColorChanged then
            self.r, self.g, self.b = r, g, b
        else
            self.__owner.Health:SetStatusBarColor(r, g, b)
        end
	end
end

function Module:UpdateClassPortraits(unit)
	if not unit then
		return
	end

	local _, unitClass = UnitClass(unit)
	if unitClass then
		local PartyValue = C["Party"].PortraitStyle.Value
		local BossValue = C["Boss"].PortraitStyle.Value
		local UnitframeValue = C["Unitframe"].PortraitStyle.Value
		local ClassTCoords = CLASS_ICON_TCOORDS[unitClass]

		if PartyValue == "ClassPortraits" or BossValue == "ClassPortraits" or UnitframeValue == "ClassPortraits" then
			self:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
			if ClassTCoords then
				self:SetTexCoord(ClassTCoords[1], ClassTCoords[2], ClassTCoords[3], ClassTCoords[4])
			end
		elseif PartyValue == "NewClassPortraits" or BossValue == "NewClassPortraits" or UnitframeValue == "NewClassPortraits" then
			self:SetTexture(C["Media"].NewClassPortraits)
			if ClassTCoords then
				self:SetTexCoord(ClassTCoords[1], ClassTCoords[2], ClassTCoords[3], ClassTCoords[4])
			end
		else
			self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		end
	end
end

function Module:UpdatePortraitColor(unit, min, max)
	if not C["Unitframe"].ShowPortrait then
		return
	end

	if not UnitIsConnected(unit) then
		self.Portrait:SetVertexColor(0.5, 0.5, 0.5, 0.7)
	elseif UnitIsDead(unit) then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 0.7)
	elseif UnitIsGhost(unit) then
		self.Portrait:SetVertexColor(0.3, 0.3, 0.9, 0.7)
	elseif max == 0 or min/max * 100 < 25 then
		if UnitIsPlayer(unit) then
			if unit ~= "player" then
				self.Portrait:SetVertexColor(1, 0, 0, 0.7)
			end
		end
	else
		self.Portrait:SetVertexColor(1, 1, 1, 1)
	end
end

function Module:UpdateHealth(unit, cur, max)
	if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
		return
	end

	local parent = self.__owner
	Module.UpdatePortraitColor(parent, unit, cur, max)
end

function Module:UpdateQuestUnit(unit)
	if unit == "player" then
		return
	end

	local updateSize = C["Nameplates"].QuestIconSize

	if (self.frameType == "FRIENDLY_NPC" or self.frameType == "ENEMY_NPC") and C["Nameplates"].QuestIcon then
		if not self:IsElementEnabled("QuestIcons") then
			self:EnableElement("QuestIcons")
		end

		self.QuestIcons:ClearAllPoints()
		self.QuestIcons:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
		self.QuestIcons:SetSize(updateSize + 4, updateSize + 4)

		self.QuestIcons.Item:SetSize(updateSize, updateSize)
		self.QuestIcons.Loot:SetSize(updateSize, updateSize)
		self.QuestIcons.Skull:SetSize(updateSize + 4, updateSize + 4)
		self.QuestIcons.Chat:SetSize(updateSize + 4, updateSize + 4)
	else
		if self:IsElementEnabled("QuestIcons") then
			self:DisableElement("QuestIcons")
		end
	end
end

function Module:UpdateHealerIcons()
	if (self.frameType == "FRIENDLY_PLAYER" or self.frameType == "ENEMY_PLAYER") and C["Nameplates"].MarkHealers then
		if not self:IsElementEnabled("HealerSpecs") then
			self:EnableElement("HealerSpecs")
		end

		self.HealerSpecs:SetPoint("BOTTOM", self.Health, "TOP", 0, 38)
	else
		if self:IsElementEnabled("HealerSpecs") then
			self:DisableElement("HealerSpecs")
		end
	end
end

function Module:UpdateThreatIndicator()
	if (Module.InstanceType ~= "arena" and Module.InstanceType ~= "pvp") and self.frameType == "ENEMY_NPC" and C["Nameplates"].Threat then
		if not self:IsElementEnabled("ThreatIndicator") then
			self:EnableElement("ThreatIndicator")
		end

		self.ThreatIndicator:SetAlpha(0)
	else
		if self:IsElementEnabled("ThreatIndicator") then
			self:DisableElement("ThreatIndicator")
		end
	end
end

function Module:HighlightPlate()
	local unit = self.unit
	local plateArrowLeft = C["Nameplates"].TargetArrow and self.leftArrow
	local plateArrowRight = C["Nameplates"].TargetArrow and self.rightArrow
	local plateShadow = self.Health.Shadow

	if plateArrowLeft then
		plateArrowLeft:SetVertexColor(255/255, 247/255, 173/255)
		plateArrowLeft:Hide()
	end

	if plateArrowRight then
		plateArrowRight:SetVertexColor(255/255, 247/255, 173/255)
		plateArrowRight:Hide()
	end

	if plateShadow then
		plateShadow:SetBackdropBorderColor(0, 0, 0, 0.8)
	end

	if UnitIsUnit(unit, "target") then
		if plateArrowLeft and plateArrowRight then
			plateArrowLeft:Show()
			plateArrowRight:Show()
		end
	end

	local r, g, b
	local showIndicator
	if UnitIsUnit(unit, "target") then
		showIndicator = true
		r, g, b = 255/255, 247/255, 173/255
	else
		showIndicator = false
		r, g, b = 0, 0, 0, 0.8
	end

	if showIndicator then
		if (plateArrowLeft and plateArrowRight) then
			plateArrowLeft:SetVertexColor(r, g, b)
			plateArrowRight:SetVertexColor(r, g, b)
		end

		if plateShadow then
			plateShadow:SetBackdropBorderColor(r, g, b)
		end
	end
end

function Module:UpdatePlateTotems()
	if C["Nameplates"].Totems ~= true then
		return
	end

	local name = UnitName(self.unit)
	if name then
		if Module.PlateTotemData[name] then
			self.Totem.Icon:SetTexture(Module.PlateTotemData[name])
			self.Totem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			self.Totem:Show()
		else
			self.Totem:Hide()
		end
	end
end

function Module:MouseoverHealth(unit)
	if (not unit) then
		return
	end

	local Health = self.Health
	local Texture = C["Media"].Mouseover

	self.Highlight = Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture(Texture)
	self.Highlight:SetVertexColor(1, 1, 1, .36)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()
end

function Module:CustomCastTimeText(duration)
	if self.channeling then
		self.Time:SetFormattedText("%.1f", abs(duration - self.max))
	else
		self.Time:SetFormattedText("%.1f", duration)
	end
end

function Module:CustomCastDelayText(duration)
	if self.channeling then
		self.Time:SetFormattedText("%.1f |cffaf5050%.1f|r", abs(duration - self.max), self.delay)
	else
		self.Time:SetFormattedText("%.1f |cffaf5050%s %.1f|r", duration, "+", self.delay)
	end
end

function Module:HideTicks()
	for i = 1, #Module.ticks do
		Module.ticks[i]:Hide()
	end
end

local CastTicksTexture = K.GetTexture(C["Unitframe"].Texture)
function Module:SetCastTicks(castbar, numTicks, extraTickRatio)
	extraTickRatio = extraTickRatio or 0
	Module:HideTicks()

	if numTicks and numTicks <= 0 then
		return
	end

	local w = castbar:GetWidth()
	local d = w / (numTicks + extraTickRatio)

	for i = 1, numTicks do
		if not Module.ticks[i] then
			Module.ticks[i] = castbar:CreateTexture(nil, "OVERLAY")
			Module.ticks[i]:SetTexture(CastTicksTexture)
			Module.ticks[i]:SetVertexColor(castbar.tickColor[1], castbar.tickColor[2], castbar.tickColor[3], castbar.tickColor[4])
			Module.ticks[i]:SetWidth(castbar.tickWidth)
		end

		Module.ticks[i]:SetHeight(castbar.tickHeight)
		Module.ticks[i]:ClearAllPoints()
		Module.ticks[i]:SetPoint("RIGHT", castbar, "LEFT", d * i, 0)
		Module.ticks[i]:Show()
	end
end

function Module:PostCastStart(unit)
	if unit == "vehicle" then
		unit = "player"
	end

	-- Get length of Time, then calculate available length for Text
	local timeWidth = self.Time:GetStringWidth()
	local textWidth = self:GetWidth() - timeWidth - 10
	local textStringWidth = self.Text:GetStringWidth()

	if timeWidth == 0 or textStringWidth == 0 then
		K.Delay(0.05, function() -- Delay may need tweaking
			textWidth = self:GetWidth() - self.Time:GetStringWidth() - 10
			textStringWidth = self.Text:GetStringWidth()
			if textWidth > 0 then
				self.Text:SetWidth(math_min(textWidth, textStringWidth))
			end
		end)
	else
		self.Text:SetWidth(math_min(textWidth, textStringWidth))
	end

	if self.Spark then
		self.Spark:SetHeight(self:GetHeight())
		self.Spark:SetPoint("CENTER", self:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	self.unit = unit

	if unit == "player" and self.Latency then
		local _, _, _, ms = _G.GetNetStats()
		self.Latency:SetText(("%dms"):format(ms))
	end

	if self.channeling and C["Unitframe"].CastbarTicks and unit == "player" then
		local baseTicks = Module.ChannelTicks[self.spellID]

		if baseTicks and Module.ChannelTicksSize[self.spellID] and Module.HastedChannelTicks[self.spellID] then
			local tickIncRate = 1 / baseTicks
			local curHaste = UnitSpellHaste("player") * 0.01
			local firstTickInc = tickIncRate / 2
			local bonusTicks = 0
			if curHaste >= firstTickInc then
				bonusTicks = bonusTicks + 1
			end

			local x = tonumber(K.Round(firstTickInc + tickIncRate, 2))
			while curHaste >= x do
				x = tonumber(K.Round(firstTickInc + (tickIncRate * bonusTicks), 2))
				if curHaste >= x then
					bonusTicks = bonusTicks + 1
				end
			end

			local baseTickSize = Module.ChannelTicksSize[self.spellID]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			local extraTickRatio = extraTick / hastedTickSize

			Module:SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
			self.hadTicks = true
		elseif baseTicks and Module.ChannelTicksSize[self.spellID] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = Module.ChannelTicksSize[self.spellID]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			local extraTickRatio = extraTick / hastedTickSize

			Module:SetCastTicks(self, baseTicks, extraTickRatio)
			self.hadTicks = true
		elseif baseTicks then
			Module:SetCastTicks(self, baseTicks)
			self.hadTicks = true
		else
			Module:HideTicks()
		end
	end

	local colors = K.Colors
	local r, g, b = colors.status.castColor[1], colors.status.castColor[2], colors.status.castColor[3]

	local t
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C["Unitframe"].CastReactionColor and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if t then
		r, g, b = t[1], t[2], t[3]
	end

	if self.notInterruptible and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
end

function Module:PostCastStop(unit)
	if self.hadTicks and unit == 'player' then
		Module:HideTicks()
		self.hadTicks = false
	end
end

function Module:PostCastInterruptible(unit)
	if unit == "vehicle" or unit == "player" then
		return
	end

	local colors = K.Colors
	local r, g, b = colors.status.castColor[1], colors.status.castColor[2], colors.status.castColor[3]

	local t
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C["Unitframe"].CastReactionColor and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if (t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
end

function Module:PostCastFail()
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetStatusBarColor(1.0, 0.0, 0.0)

	if self.Time then
		self.Time:SetText("")
	end

	if self.Spark then
		self.Spark:SetPoint("CENTER", self, "RIGHT")
	end
end

function Module:CreateAuraTimer(elapsed)
	if (self.TimeLeft) then
		self.Elapsed = (self.Elapsed or 0) + elapsed

		if self.Elapsed >= 0.1 then
			if not self.First then
				self.TimeLeft = self.TimeLeft - self.Elapsed
			else
				self.TimeLeft = self.TimeLeft - GetTime()
				self.First = false
			end

			if self.TimeLeft > 0 then
				local Time = K.FormatTime(self.TimeLeft)
				self.Remaining:SetText(Time)

				if self.TimeLeft <= 5 then
					self.Remaining:SetTextColor(1, 0, 0)
				else
					self.Remaining:SetTextColor(1, 1, 1)
				end
			else
				self.Remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.Elapsed = 0
		end
	end
end

function Module:PostCreateAura(button)
	local buttonFont = C["Media"].Font
	local buttonFontSize = self.size * 0.46

	if string_match(button:GetName(), "NamePlate") then
		if C["Nameplates"].Enable then
			button:CreateShadow(true)

			button.Remaining = button.cd:CreateFontString(nil, "OVERLAY")
			button.Remaining:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
			button.Remaining:SetPoint("CENTER", 1, 0)

			button.cd.noCooldownCount = true
			button.cd:SetReverse(true)
			button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
			button.cd:ClearAllPoints()
			button.cd:SetAllPoints()
			button.cd:SetHideCountdownNumbers(true)

			button.icon:SetAllPoints()
			button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			button.icon:SetDrawLayer("ARTWORK")

			button.count:SetPoint("BOTTOMRIGHT", 1, 1)
			button.count:SetJustifyH("RIGHT")
			button.count:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
			button.count:SetTextColor(0.84, 0.75, 0.65)
		end
	else
		button:CreateBorder()

		button.Remaining = button.cd:CreateFontString(nil, "OVERLAY")
		button.Remaining:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
		button.Remaining:SetPoint("CENTER", 1, 0)

		button.cd.noCooldownCount = true
		button.cd:SetReverse(true)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", 1, -1)
		button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
		button.cd:SetHideCountdownNumbers(true)

		button.icon:SetAllPoints()
		button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		button.icon:SetDrawLayer("ARTWORK")

		button.count:SetPoint("BOTTOMRIGHT", 1, 1)
		button.count:SetJustifyH("RIGHT")
		button.count:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
		button.count:SetTextColor(0.84, 0.75, 0.65)
	end
end

function Module:PostUpdateAura(unit, button, index)
	if not button then
		return
	end

	local Name, _, _, DType, Duration, ExpirationTime, Caster, IsStealable = UnitAura(unit, index, button.filter)

	local isPlayer = (Caster == "player" or Caster == "vehicle")
	local isFriend = unit and UnitIsFriend("player", unit) and not UnitCanAttack("player", unit)

	if button then
		if button.isDebuff then
			if (not isFriend and not isPlayer) then
				if C["Unitframe"].OnlyShowPlayerDebuff then
					button:Hide()
				else
					button.icon:SetDesaturated((unit and not string_find(unit, "arena%d")) and true or false)
					button:SetBackdropBorderColor()
					if button.Shadow then
						button.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
					end
				end
			else
				local color = (DType and DebuffTypeColor[DType]) or DebuffTypeColor.none
				if Name and (Name == "Unstable Affliction" or Name == "Vampiric Touch") and K.Class ~= "WARLOCK" then
					button:SetBackdropBorderColor(0.05, 0.85, 0.94)
					if button.Shadow then
						button.Shadow:SetBackdropBorderColor(0.05, 0.85, 0.94, 0.8)
					end
				else
					button:SetBackdropBorderColor(color.r, color.g, color.b)
					if button.Shadow then
						button.Shadow:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 0.8)
					end
				end
				button.icon:SetDesaturated(false)
			end
		else
			if IsStealable and not isFriend then
				button:SetBackdropBorderColor(255/255, 255/255, 0/255)
				K.Flash(button, 0.80, true)
			else
				button:SetBackdropBorderColor()
				K.StopFlash(button)
			end
		end

		if button.Remaining then
			if Duration and (Duration ~= 0) then
				button.Remaining:Show()
			else
				button.Remaining:Hide()
			end

			button:SetScript("OnUpdate", Module.CreateAuraTimer)
		end

		button.Duration = Duration
		button.TimeLeft = ExpirationTime
		button.First = true
	end
end

function Module:CreateAuraWatchIcon(icon)
	icon:CreateShadow(true)
	icon.icon:SetPoint("TOPLEFT")
	icon.icon:SetPoint("BOTTOMRIGHT")
	icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon.icon:SetDrawLayer("ARTWORK")

	if (icon.cd) then
		icon.cd:SetHideCountdownNumbers(true)
		icon.cd:SetReverse(true)
	end

	icon.overlay:SetTexture()
end

function Module:CreateAuraWatch(frame)
	local buffs = {}
	local Class = select(2, UnitClass("player"))

	local Auras = CreateFrame("Frame", nil, frame)
	Auras:SetPoint("TOPLEFT", frame.Health, 2, -2)
	Auras:SetPoint("BOTTOMRIGHT", frame.Health, -2, 2)
	Auras.presentAlpha = 1
	Auras.missingAlpha = 0
	Auras.icons = {}
	Auras.PostCreateIcon = Module.CreateAuraWatchIcon
	Auras.strictMatching = true

	if (Module.RaidBuffsTracking["ALL"]) then
		for _, value in pairs(Module.RaidBuffsTracking["ALL"]) do
			table_insert(buffs, value)
		end
	end

	if (Module.RaidBuffsTracking[Class]) then
		for _, value in pairs(Module.RaidBuffsTracking[Class]) do
			table_insert(buffs, value)
		end
	end

	if (buffs) then
		for _, spell in pairs(buffs) do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon:SetWidth(C["Raid"].AuraWatchIconSize)
			Icon:SetHeight(C["Raid"].AuraWatchIconSize)
			Icon:SetPoint(spell[2], 0, 0)

			if C["Raid"].AuraWatchTexture then
				local Texture = Icon:CreateTexture(nil, "OVERLAY")
				Texture:SetInside(Icon)
				Texture:SetTexture(C["Media"].Blank)

				if (spell[3]) then
					Texture:SetVertexColor(unpack(spell[3]))
				else
					Texture:SetVertexColor(0.8, 0.8, 0.8)
				end
			end

			local Count = Icon:CreateFontString(nil, "OVERLAY")
			Count:SetFont(C["Media"].Font, 8, "THINOUTLINE")
			Count:SetPoint("CENTER", unpack(Module.RaidBuffsTrackingPosition[spell[2]]))
			Icon.count = Count

			Auras.icons[spell[1]] = Icon
		end
	end

	frame.AuraWatch = Auras
end

function Module:UpdateNameplateTarget()
	local Nameplate = self

	if not Nameplate then
		return
	end

	local targetExists = Nameplate.unit and UnitIsUnit(Nameplate.unit, "target") or nil

	if targetExists or not UnitExists("target") then
		Nameplate:SetAlpha(1)
	else
		Nameplate:SetAlpha(C["Nameplates"].NonTargetAlpha)
	end
end

function Module:NameplatesCallback(event, unit)
	local Nameplate = self

	if not unit or not Nameplate then
		return
	end

	-- Position of the resources
	local Point, Relpoint, xOffset, yOffset = "TOP", "BOTTOM", 0, -8

	if event == "NAME_PLATE_UNIT_ADDED" then
		Nameplate.reaction = UnitReaction("player", unit)
		Nameplate.isPlayer = UnitIsPlayer(unit)

		if UnitIsUnit(unit, "player") then
			Nameplate.frameType = "PLAYER"
		elseif UnitIsPVPSanctuary(unit) or (Nameplate.isPlayer and UnitIsFriend("player", unit) and Nameplate.reaction and Nameplate.reaction >= 5) then
			Nameplate.frameType = "FRIENDLY_PLAYER"
		elseif not Nameplate.isPlayer and (Nameplate.reaction and Nameplate.reaction >= 5) or UnitFactionGroup(unit) == "Neutral" then
			Nameplate.frameType = "FRIENDLY_NPC"
		elseif not Nameplate.isPlayer and (Nameplate.reaction and Nameplate.reaction <= 4) then
			Nameplate.frameType = "ENEMY_NPC"
		else
			Nameplate.frameType = "ENEMY_PLAYER"
		end

		if UnitIsUnit(unit, "player") then
			Nameplate:DisableElement("Castbar")
			Nameplate:DisableElement("RaidTargetIndicator")
			Nameplate:DisableElement("PvPIndicator")
			Nameplate.Name:Hide()

			if Nameplate.ClassPower then
				Nameplate.ClassPower:Show()
				Nameplate:EnableElement("ClassPower")
				Nameplate.ClassPower:ForceUpdate()

				if (K.Class == "DEATHKNIGHT") then
					Nameplate.Runes:Show()
					Nameplate:EnableElement("Runes")
					Nameplate.Runes:ForceUpdate()
				end
			end

			if C["Nameplates"].TargetArrow and Nameplate.leftArrow then
				Nameplate.leftArrow:Hide()
			end

			if C["Nameplates"].TargetArrow and self.rightArrow then
				Nameplate.rightArrow:Hide()
			end

		else
			Nameplate:EnableElement("Castbar")
			Nameplate:EnableElement("RaidTargetIndicator")
			Nameplate:EnableElement("PvPIndicator")
			Nameplate.Name:Show()

			Module.UpdateQuestUnit(Nameplate, unit)
			Module.HighlightPlate(Nameplate)
			Module.UpdateNameplateTarget(Nameplate)
			Module.UpdatePlateTotems(Nameplate)
			Module.UpdateHealerIcons(Nameplate)
			Module.UpdateThreatIndicator(Nameplate)

			if Nameplate.ClassPower then
				Nameplate.ClassPower:Hide()
				Nameplate:DisableElement("ClassPower")

				if (K.Class == "DEATHKNIGHT") then
					Nameplate.Runes:Hide()
					Nameplate:DisableElement("Runes")
				end
			end
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		Nameplate:DisableElement("ClassPower")
		Nameplate:DisableElement("Runes")

		Nameplate:EnableElement("Castbar")
		Nameplate:EnableElement("RaidTargetIndicator")
		Nameplate:EnableElement("PvPIndicator")
		Nameplate.Name:Show()

		if Nameplate.ClassPower then
			Nameplate.ClassPower:Hide()
			Nameplate.ClassPower:ClearAllPoints()
			Nameplate.ClassPower:SetParent(Nameplate)
			Nameplate.ClassPower:SetPoint(Point, Nameplate.Health, Relpoint, xOffset, yOffset)
		end

		if Nameplate.Runes then
			Nameplate.Runes:Hide()
			Nameplate.Runes:ClearAllPoints()
			Nameplate.Runes:SetParent(Nameplate)
			Nameplate.Runes:SetPoint(Point, Nameplate.Health, Relpoint, xOffset, yOffset)
		end
	end

	if _G.GetCVarBool("nameplateResourceOnTarget") then
		local Player, Target = C_NamePlate_GetNamePlateForUnit("player"), UnitExists("target") and C_NamePlate_GetNamePlateForUnit("target")
		if Target and Target:IsForbidden() then
			Target = nil
		end
		if Player then
			local Anchor = Target and Target.unitFrame or Player.unitFrame
			if Player.unitFrame.ClassPower then
				Player.unitFrame.ClassPower:ClearAllPoints()
				Player.unitFrame.ClassPower:SetParent(Anchor)
				Player.unitFrame.ClassPower:SetPoint(Point, Anchor.Health, Relpoint, xOffset, yOffset)
			end
			if Player.unitFrame.Runes then
				Player.unitFrame.Runes:ClearAllPoints()
				Player.unitFrame.Runes:SetParent(Anchor)
				Player.unitFrame.Runes:SetPoint(Point, Anchor.Health, Relpoint, xOffset, yOffset)
			end
		end
	end
end

function Module:NameplatePowerAndCastBar(unit, cur, _, max)
	if not unit then
		unit = self:GetParent().unit
	end

	if not unit then
		return
	end

	if not cur then
		cur, max = UnitPower(unit), UnitPowerMax(unit)
	end

	local CurrentPower = cur
	local MaxPower = max
	local Nameplate = self:GetParent()
	local PowerBar = Nameplate.Power
	local CastBar = Nameplate.Castbar
	local Health = Nameplate.Health
	local IsPowerHidden = PowerBar.IsHidden

	if (not CastBar:IsShown()) and (CurrentPower and CurrentPower == 0) and (MaxPower and MaxPower == 0) then
		if (not IsPowerHidden) then
			Health:ClearAllPoints()
			Health:SetAllPoints()

			PowerBar:Hide()
			PowerBar.IsHidden = true
		end
	else
		if IsPowerHidden then
			Health:ClearAllPoints()
			Health:SetPoint("TOPLEFT")
			Health:SetHeight(C["Nameplates"].Height - C["Nameplates"].CastHeight - 1)
			Health:SetWidth(Nameplate:GetWidth())

			PowerBar:Show()
			PowerBar.IsHidden = false
		end
	end
end

function Module:GetPartyFramesAttributes()
	local PartyProperties = "custom [@raid6,exists] hide;show"

	return "oUF_Party", nil, PartyProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", 158,
	"initial-height", 38,
	"showSolo", false,
	"showParty", true,
	"showPlayer", C["Party"].ShowPlayer,
	"showRaid", true,
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", "GROUP",
	"yOffset", C["Party"].ShowBuffs and -44 or -18
end

function Module:GetDamageRaidFramesAttributes()
	local DamageRaidProperties = C["Party"].Enable and "custom [@raid6,exists] show;hide" or "solo,party,raid"

	return "oUF_Raid_Damage", nil, DamageRaidProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", C["Raid"].Width,
	"initial-height", C["Raid"].Height,
	"showParty", true,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", 6,
	"yOffset", -6,
	"point", "TOP",
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", C["Raid"].GroupBy.Value,
	"maxColumns", math_ceil(40 / 5),
	"unitsPerColumn", C["Raid"].MaxUnitPerColumn,
	"columnSpacing", 6,
	"columnAnchorPoint", "LEFT"
end

function Module:GetHealerRaidFramesAttributes()
	local HealerRaidProperties = C["Party"].Enable and "custom [@raid6,exists] show;hide" or "solo,party,raid"

	return "oUF_Raid_Healer", nil, HealerRaidProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", C["Raid"].Width,
	"initial-height", C["Raid"].Height,
	"showParty", true,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", 6,
	"yOffset", -6,
	"point", "LEFT",
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", C["Raid"].GroupBy.Value,
	"maxColumns", math.ceil(40 / 5),
	"unitsPerColumn", C["Raid"].MaxUnitPerColumn,
	"columnSpacing", 6,
	"columnAnchorPoint", "BOTTOM"
end

function Module:GetMainTankAttributes()
	local MainTankProperties = "raid"

	return "oUF_MainTank", nil, MainTankProperties,
	"oUF-initialConfigFunction", [[
	self:SetWidth(76)
	self:SetHeight(40)
	]],

	"showRaid", true,
	"yOffset", -8,
	"groupFilter", "MAINTANK",
	"template", "oUF_MainTank"
end

function Module:CreateStyle(unit)
	if (not unit) then
		return
	end

	local Parent = self:GetParent():GetName()

	if (unit == "player") then
		Module.CreatePlayer(self)
	elseif (unit == "target") then
		Module.CreateTarget(self)
	elseif (unit == "targettarget") then
		Module.CreateTargetOfTarget(self)
	elseif (unit == "pet") then
		Module.CreatePet(self)
	elseif (unit == "focus") then
		Module.CreateFocus(self)
	elseif (unit == "focustarget") then
		Module.CreateFocusTarget(self)
	elseif string_find(unit, "arena%d") then
		Module.CreateArena(self)
	elseif string_find(unit, "boss%d") then
		Module.CreateBoss(self)
	elseif (string_find(unit, "raid") or string_find(unit, "maintank")) then
		if string_match(Parent, "Party") then
			Module.CreateParty(self)
		else
			Module.CreateRaid(self)
		end
	elseif string_match(unit, "nameplate") and C["Nameplates"].Enable then
		Module.CreateNameplates(self)
	end

	return self
end

function Module:CreateUnits()
	if (C["Unitframe"].Enable) then
		local Player = oUF:Spawn("player")
		Player:SetPoint("BOTTOM", UIParent, "BOTTOM", -290, 320)
		Player:SetSize(200, 52)

		local Target = oUF:Spawn("target")
		Target:SetPoint("BOTTOM", UIParent, "BOTTOM", 290, 320)
		Target:SetSize(200, 52)

		if not C["Unitframe"].HideTargetofTarget then
			local TargetOfTarget = oUF:Spawn("targettarget")
			TargetOfTarget:SetPoint("TOPLEFT", Target, "BOTTOMRIGHT", -56, 2)
			TargetOfTarget:SetSize(116, 36)
			K.Mover(TargetOfTarget, "TargetOfTarget", "TargetOfTarget", {"TOPLEFT", Target, "BOTTOMRIGHT", -56, 2}, 116, 36)

			Module.TargetOfTarget = TargetOfTarget
		end

		local Pet = oUF:Spawn("pet")
		if C["Unitframe"].CombatFade and Player and not InCombatLockdown() then
			Pet:SetParent(Player)
		end
		Pet:SetPoint("TOPRIGHT", Player, "BOTTOMLEFT", 56, 2)
		Pet:SetSize(116, 36)

		local Focus = oUF:Spawn("focus")
		Focus:SetPoint("BOTTOMRIGHT", Player, "TOPLEFT", -60, 30)
		Focus:SetSize(190, 52)

		if not C["Unitframe"].HideTargetofTarget then
			local FocusTarget = oUF:Spawn("focustarget")
			FocusTarget:SetPoint("TOPRIGHT", Focus, "BOTTOMLEFT", 56, 2)
			FocusTarget:SetSize(116, 36)

			Module.FocusTarget = FocusTarget
		end

		Module.Player = Player
		Module.Target = Target
		Module.Pet = Pet
		Module.Focus = Focus

		if (C["Arena"].Enable) then
			local Arena = {}
			for i = 1, MAX_ARENA_ENEMIES or 5 do
				Arena[i] = oUF:Spawn("arena" .. i, nil)
				Arena[i]:SetSize(190, 52)

				if (i == 1) then
					Arena.Position = {"BOTTOMRIGHT", UIParent, "RIGHT", -140, 140}
				else
					Arena.Position = {"TOPLEFT", Arena[i - 1], "BOTTOMLEFT", 0, -48}
				end
				Arena[i]:SetPoint(Arena.Position[1], Arena.Position[2], Arena.Position[3], Arena.Position[4], Arena.Position[5])

				K.Mover(Arena[i], "Arena"..i, "Arena"..i, Arena.Position)
			end

			Module.Arena = Arena
		end

		if C["Boss"].Enable then
			local Boss = {}
			for i = 1, MAX_BOSS_FRAMES do
				Boss[i] = oUF:Spawn("boss" .. i)
				Boss[i]:SetSize(190, 52)

				if (i == 1) then
					Boss.Position = {"BOTTOMRIGHT", UIParent, "RIGHT", -140, 140}
				else
					Boss.Position = {"TOPLEFT", Boss[i - 1], "BOTTOMLEFT", 0, -28}
				end
				Boss[i]:SetPoint(Boss.Position[1], Boss.Position[2], Boss.Position[3], Boss.Position[4], Boss.Position[5])

				K.Mover(Boss[i], "Boss"..i, "Boss"..i, Boss.Position)
			end

			Module.Boss = Boss
		end

		if C["Party"].Enable then
			local Party = oUF:SpawnHeader(Module:GetPartyFramesAttributes())
			Party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -180)
			K.Mover(Party, "Party", "Party", {"TOPLEFT", UIParent, "TOPLEFT", 4, -180}, 158, 390)
		end

		if C["Raid"].Enable then
			local DamageRaid = oUF:SpawnHeader(Module:GetDamageRaidFramesAttributes())
			local HealerRaid = oUF:SpawnHeader(Module:GetHealerRaidFramesAttributes())
			local MainTankRaid = oUF:SpawnHeader(Module:GetMainTankAttributes())

			if C["Raid"].RaidLayout.Value == "Healer" then
				HealerRaid:SetPoint("TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 10, 14)
				K.Mover(HealerRaid, "HealerRaid", "HealerRaid", {"TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 10, 14}, C["Raid"].Width, C["Raid"].Height)
			elseif C["Raid"].RaidLayout.Value == "Damage" then
				DamageRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -30)
				K.Mover(DamageRaid, "DamageRaid", "DamageRaid", {"TOPLEFT", UIParent, "TOPLEFT", 4, -30}, 158, 390)
			end

			if C["Raid"].MainTankFrames then
				MainTankRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
				K.Mover(MainTankRaid, "MainTank", "MainTank", {"TOPLEFT", UIParent, "TOPLEFT", 6, -6}, 76, 40)
			end
		end

		K.Mover(Player, "Player", "Player", {"BOTTOM", UIParent, "BOTTOM", -290, 320}, 200, 52)
		K.Mover(Target, "Target", "Target", {"BOTTOM", UIParent, "BOTTOM", 290, 320}, 200, 52)
		K.Mover(Pet, "Pet", "Pet", {"TOPRIGHT", Player, "BOTTOMLEFT", 56, 2}, 116, 36)
		K.Mover(Focus, "Focus", "Focus", {"BOTTOMRIGHT", Player, "TOPLEFT", -60, 30}, 190, 52)
	end

	if C["Nameplates"].Enable then
		Module.NameplatesVars = {
			nameplateGlobalScale = 1,
			namePlateHorizontalScale = 1,
			nameplateLargerScale = 1.2,
			nameplateMaxAlpha = 1,
			nameplateMaxAlphaDistance = 0,
			nameplateMaxDistance = C["Nameplates"].Distance or 40,
			nameplateMaxScale = 1,
			nameplateMaxScaleDistance = 0,
			nameplateMinAlpha = 1,
			nameplateMinAlphaDistance = 0,
			nameplateMinScale = 1,
			nameplateMinScaleDistance = 0,
			nameplateOtherBottomInset = C["Nameplates"].Clamp and 0.1 or -1,
			nameplateOtherTopInset = C["Nameplates"].Clamp and 0.08 or -1,
			nameplateOverlapV = C["Nameplates"].OverlapV or 1.2,
			nameplateOverlapH = C["Nameplates"].OverlapH or 1.2,
			nameplateSelectedAlpha = 1,
			nameplateSelectedScale = C["Nameplates"].SelectedScale or 1,
			nameplateSelfAlpha = 1,
			nameplateSelfScale = 1,
			nameplateShowAll = 1,
			nameplateShowFriendlyNPCs = 0,
			nameplateVerticalScale = 1,
		}

		oUF:SpawnNamePlates(nil, Module.NameplatesCallback, Module.NameplatesVars)
	end
end

function Module:NameplatesVarsReset()
	if InCombatLockdown() then
		return
		print(_G.ERR_NOT_IN_COMBAT)
	end

	SetCVar("NamePlateHorizontalScale", GetCVarDefault("NamePlateHorizontalScale"))
	SetCVar("nameplateClassResourceTopInset", GetCVarDefault("nameplateClassResourceTopInset"))
	SetCVar("nameplateGlobalScale", GetCVarDefault("nameplateGlobalScale"))
	SetCVar("nameplateLargeBottomInset", GetCVarDefault("nameplateLargeBottomInset"))
	SetCVar("nameplateLargeTopInset", GetCVarDefault("nameplateLargeTopInset"))
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateMaxAlpha", GetCVarDefault("nameplateMaxAlpha"))
	SetCVar("nameplateMaxAlphaDistance", 40)
	SetCVar("nameplateMaxScale", 1)
	SetCVar("nameplateMaxScaleDistance", GetCVarDefault("nameplateMaxScaleDistance"))
	SetCVar("nameplateMinAlpha", 1)
	SetCVar("nameplateMinAlphaDistance", 0)
	SetCVar("nameplateMinScale", 1)
	SetCVar("nameplateMinScaleDistance", GetCVarDefault("nameplateMinScaleDistance"))
	SetCVar("nameplateMotionSpeed", GetCVarDefault("nameplateMotionSpeed"))
	SetCVar("nameplateOccludedAlphaMult", GetCVarDefault("nameplateOccludedAlphaMult"))
	SetCVar("nameplateOtherAtBase", GetCVarDefault("nameplateOtherAtBase"))
	SetCVar("nameplateOverlapH", GetCVarDefault("nameplateOverlapH"))
	SetCVar("nameplateOverlapV", GetCVarDefault("nameplateOverlapV"))
	SetCVar("nameplateResourceOnTarget", GetCVarDefault("nameplateResourceOnTarget"))
	SetCVar("nameplateSelectedAlpha", GetCVarDefault("nameplateSelectedAlpha"))
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateSelfAlpha", GetCVarDefault("nameplateSelfAlpha"))
	SetCVar("nameplateSelfBottomInset", GetCVarDefault("nameplateSelfBottomInset"))
	SetCVar("nameplateSelfScale", GetCVarDefault("nameplateSelfScale"))
	SetCVar("nameplateSelfTopInset", GetCVarDefault("nameplateSelfTopInset"))
	SetCVar("nameplateShowEnemies", GetCVarDefault("nameplateShowEnemies"))
	SetCVar("nameplateShowEnemyGuardians", GetCVarDefault("nameplateShowEnemyGuardians"))
	SetCVar("nameplateShowEnemyPets", GetCVarDefault("nameplateShowEnemyPets"))
	SetCVar("nameplateShowEnemyTotems", GetCVarDefault("nameplateShowEnemyTotems"))
	SetCVar("nameplateShowFriendlyGuardians", GetCVarDefault("nameplateShowFriendlyGuardians"))
	SetCVar("nameplateShowFriendlyNPCs", GetCVarDefault("nameplateShowFriendlyNPCs"))
	SetCVar("nameplateShowFriendlyPets", GetCVarDefault("nameplateShowFriendlyPets"))
	SetCVar("nameplateShowFriendlyTotems", GetCVarDefault("nameplateShowFriendlyTotems"))
	SetCVar("nameplateShowFriends", GetCVarDefault("nameplateShowFriends"))
	SetCVar("nameplateTargetBehindMaxDistance", GetCVarDefault("nameplateTargetBehindMaxDistance"))

	print(_G.RESET_TO_DEFAULT.." ".._G.UNIT_NAMEPLATES)

	K.StaticPopup_Show("CHANGES_RL")
end

function Module:PostUpdateArenaPreparationSpec()
	local specIcon = self.PVPSpecIcon
	local instanceType = select(2, IsInInstance())

	if (instanceType == "arena") then
		local specID = self.id and GetArenaOpponentSpec(tonumber(self.id))

		if specID and specID > 0 then
			local icon = select(4, GetSpecializationInfoByID(specID))

			specIcon.Icon:SetTexture(icon)
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	else
		local faction = UnitFactionGroup(self.unit)

		if faction == "Horde" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_01]])
		elseif faction == "Alliance" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_02]])
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	end

	self.forceInRange = true
end

function Module:UpdatePowerColorArenaPreparation(specID)
	-- oUF is unable to get power color on arena preparation, so we add this feature here.
	local power = self
	local playerClass = select(6, GetSpecializationInfoByID(specID))

	if playerClass then
		local powerColor = K.Colors.specpowertypes[playerClass][specID]

		if powerColor then
			local r, g, b = unpack(powerColor)

			power:SetStatusBarColor(r, g, b)
		else
			power:SetStatusBarColor(0, 0, 0)
		end
	end
end

function Module:CreateFilgerAnchors()
	if C["Filger"].Enable and C["Unitframe"].Enable then
		P_BUFF_ICON_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 169)
		P_BUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		P_PROC_ICON_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 169)
		P_PROC_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		SPECIAL_P_BUFF_ICON_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 211)
		SPECIAL_P_BUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		T_DEBUFF_ICON_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 211)
		T_DEBUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		T_BUFF_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 253)
		T_BUFF_Anchor:SetSize(C["Filger"].PvPSize, C["Filger"].PvPSize)

		PVE_PVP_DEBUFF_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 253)
		PVE_PVP_DEBUFF_Anchor:SetSize(C["Filger"].PvPSize, C["Filger"].PvPSize)

		PVE_PVP_CC_Anchor:SetPoint("TOPLEFT", "oUF_Player", "BOTTOMLEFT", -2, -44)
		PVE_PVP_CC_Anchor:SetSize(221, 25)

		COOLDOWN_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 63, 17)
		COOLDOWN_Anchor:SetSize(C["Filger"].CooldownSize, C["Filger"].CooldownSize)

		T_DE_BUFF_BAR_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "BOTTOMRIGHT", 2, 3)
		T_DE_BUFF_BAR_Anchor:SetSize(218, 25)

		K.Mover(P_BUFF_ICON_Anchor, "P_BUFF_ICON", "P_BUFF_ICON", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 169})
		K.Mover(P_PROC_ICON_Anchor, "P_PROC_ICON", "P_PROC_ICON", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 169})
		K.Mover(SPECIAL_P_BUFF_ICON_Anchor, "SPECIAL_P_BUFF_ICON", "SPECIAL_P_BUFF_ICON", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 211})
		K.Mover(T_DEBUFF_ICON_Anchor, "T_DEBUFF_ICON", "T_DEBUFF_ICON", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 211})
		K.Mover(T_BUFF_Anchor, "T_BUFF", "T_BUFF", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 253})
		K.Mover(PVE_PVP_DEBUFF_Anchor, "PVE_PVP_DEBUFF", "PVE_PVP_DEBUFF", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 253})
		K.Mover(PVE_PVP_CC_Anchor, "PVE_PVP_CC", "PVE_PVP_CC", {"TOPLEFT", "oUF_Player", "BOTTOMLEFT", -2, -44})
		K.Mover(COOLDOWN_Anchor, "COOLDOWN", "COOLDOWN", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 63, 17})
		K.Mover(T_DE_BUFF_BAR_Anchor, "T_DE_BUFF_BAR", "T_DE_BUFF_BAR", {"BOTTOMLEFT", "oUF_Target", "BOTTOMRIGHT", 2, 3})
	end
end

function Module:PLAYER_REGEN_DISABLED()
	if (C["Nameplates"].ShowFriendlyCombat.Value == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 1)
	elseif (C["Nameplates"].ShowFriendlyCombat.Value == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 0)
	end

	if (C["Nameplates"].ShowEnemyCombat.Value == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 1)
	elseif (C["Nameplates"].ShowEnemyCombat.Value == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 0)
	end
end

function Module:PLAYER_REGEN_ENABLED()
	if (C["Nameplates"].ShowFriendlyCombat.Value == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0)
	elseif (C["Nameplates"].ShowFriendlyCombat.Value == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1)
	end

	if (C["Nameplates"].ShowEnemyCombat.Value == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0)
	elseif (C["Nameplates"].ShowEnemyCombat.Value == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1)
	end
end

function Module:UpdateRaidDebuffIndicator()
	local ORD = oUF_RaidDebuffs or K.oUF_RaidDebuffs

	if (ORD) then
		ORD:ResetDebuffData()
		local _, InstanceType = IsInInstance()
		if (InstanceType == "party" or InstanceType == "raid") then
			ORD:RegisterDebuffs(Module.DebuffsTracking.RaidDebuffs.spells)
		else
			ORD:RegisterDebuffs(Module.DebuffsTracking.CCDebuffs.spells)
		end
	end
end

local function CreateTargetSound(unit)
	if UnitExists(unit) then
		if UnitIsEnemy(unit, "player") then
			PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend("player", unit) then
			PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
		end
	else
		PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

function Module:PLAYER_FOCUS_CHANGED()
	CreateTargetSound("focus")
end

function Module:PLAYER_TARGET_CHANGED()
	CreateTargetSound("target")
end

local announcedPVP
function Module:UNIT_FACTION(_, unit)
	if (unit ~= "player") then
		return
	end

	if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
		if not announcedPVP then
			announcedPVP = true
			PlaySound(SOUNDKIT.IG_PVP_UPDATE)
		end
	else
		announcedPVP = nil
	end
end

local function HideRaid()
	if InCombatLockdown() then
		return
	end

	_G.CompactRaidFrameManager:Kill()
	local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

function Module:DisableBlizzardCompactRaid()
	if not CompactRaidFrameManager_UpdateShown then
		K.StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
	else
		if not _G.CompactRaidFrameManager.hookedHide then
			hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
			_G.CompactRaidFrameManager:HookScript("OnShow", HideRaid)
			_G.CompactRaidFrameManager.hookedHide = true
		end
		CompactRaidFrameContainer:UnregisterAllEvents()

		HideRaid()
	end
end

function Module:GROUP_ROSTER_UPDATE()
	local isInRaid = IsInRaid()
	Module.IsInGroup = isInRaid or IsInGroup()

	wipe(Module.GroupRoles)

	if Module.IsInGroup then
		local NumPlayers, Unit = (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers(), (isInRaid and "raid") or "party"
		for i = 1, NumPlayers do
			if UnitExists(Unit..i) then
				Module.GroupRoles[UnitName(Unit..i)] = UnitGroupRolesAssigned(Unit..i)
			end
		end
	end
end

function Module:GROUP_LEFT()
	Module.IsInGroup = IsInRaid() or IsInGroup()
	wipe(Module.GroupRoles)
end

function Module:PLAYER_ENTERING_WORLD()
	Module.InstanceType = select(2, GetInstanceInfo())
end

function Module:OnEnable()
	Module.Backdrop = {
		bgFile = C["Media"].Blank,
		insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult}
	}

	oUF:RegisterStyle(" ", Module.CreateStyle)
	oUF:SetActiveStyle(" ")

	Module:CreateUnits()
	Module:CreateFilgerAnchors()

	if not Module.GroupRoles then Module.GroupRoles = {} end

	if C["Party"].Enable or C["Raid"].Enable then
		self:DisableBlizzardCompactRaid()

		self:RegisterEvent("GROUP_ROSTER_UPDATE", "DisableBlizzardCompactRaid")
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE") --This may fuck shit up.. we'll see...
	else
		CompactUnitFrameProfiles:RegisterEvent("VARIABLES_LOADED")
	end

	if C["Raid"].AuraWatch then
		local RaidDebuffs = CreateFrame("Frame")
		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", Module.UpdateRaidDebuffIndicator)

		local ORD = oUF_RaidDebuffs or K.oUF_RaidDebuffs
		if (ORD) then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end
	end

	if C["Nameplates"].Enable then
		K.HideInterfaceOption(InterfaceOptionsNamesPanelUnitNameplatesMakeLarger)
		K.HideInterfaceOption(InterfaceOptionsNamesPanelUnitNameplatesAggroFlash)

		Module:RegisterEvent("PLAYER_REGEN_ENABLED")
		Module:RegisterEvent("PLAYER_REGEN_DISABLED")
		Module:RegisterEvent("PLAYER_ENTERING_WORLD")
		Module:RegisterEvent("GROUP_ROSTER_UPDATE")
		Module:RegisterEvent("GROUP_LEFT")

		local BlizzPlateManaBar = _G.NamePlateDriverFrame.classNamePlatePowerBar
		if BlizzPlateManaBar then
			BlizzPlateManaBar:Hide()
			BlizzPlateManaBar:UnregisterAllEvents()
		end

		hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
			if not frame or frame:IsForbidden() then
				return
			end

			if frame.classNamePlateMechanicFrame then
				frame.classNamePlateMechanicFrame:Hide()
			end
			if frame.classNamePlatePowerBar then
				frame.classNamePlatePowerBar:Hide()
				frame.classNamePlatePowerBar:UnregisterAllEvents()
			end
		end)

		Module:PLAYER_REGEN_ENABLED()
		Module:GROUP_ROSTER_UPDATE()
	end

	if C["Unitframe"].Enable then
		K.HideInterfaceOption(InterfaceOptionsCombatPanelTargetOfTarget)

		Module:RegisterEvent("PLAYER_TARGET_CHANGED")
		Module:RegisterEvent("PLAYER_FOCUS_CHANGED")
		Module:RegisterEvent("UNIT_FACTION")

		Module:UpdateRangeCheckSpells()
	end
end