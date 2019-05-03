local K, C = unpack(select(2, ...))
local Module = K:NewModule("Unitframes", "AceEvent-3.0", "AceTimer-3.0")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local math_ceil = math.ceil
local pairs = pairs
local select = select
local string_find = string.find
local table_insert = table.insert
local tonumber = tonumber
local unpack = unpack
local math_abs = math.abs
local math_min = math.min
local string_match = string.match

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local COOLDOWN_Anchor = _G.COOLDOWN_Anchor
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local C_NamePlate_GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit
local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetCVarDefault = _G.GetCVarDefault
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local MAX_ARENA_ENEMIES = _G.MAX_ARENA_ENEMIES or 5
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES or 5
local PVE_PVP_CC_Anchor = _G.PVE_PVP_CC_Anchor
local PVE_PVP_DEBUFF_Anchor = _G.PVE_PVP_DEBUFF_Anchor
local P_BUFF_ICON_Anchor = _G.P_BUFF_ICON_Anchor
local P_PROC_ICON_Anchor = _G.P_PROC_ICON_Anchor
local PlaySound = _G.PlaySound
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local SOUNDKIT = _G.SOUNDKIT
local SPECIAL_P_BUFF_ICON_Anchor = _G.SPECIAL_P_BUFF_ICON_Anchor
local SetCVar = _G.SetCVar
local T_BUFF_Anchor = _G.T_BUFF_Anchor
local T_DEBUFF_ICON_Anchor = _G.T_DEBUFF_ICON_Anchor
local T_DE_BUFF_BAR_Anchor = _G.T_DE_BUFF_BAR_Anchor
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax
local UnitReaction = _G.UnitReaction
local UnitSpellHaste = _G.UnitSpellHaste
local hooksecurefunc = _G.hooksecurefunc
local oUF_RaidDebuffs = _G.oUF_RaidDebuffs

local Movers = K["Movers"]
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

-- overrides oUF"s color function
function Module:UpdateColor(unit, cur, max)
	local parent = self.__owner

	local r, g, b, t

	if (self.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
		t = parent.colors.tapped
	elseif self.ColorOverride and not UnitIsPlayer(unit) then
		t = self.ColorOverride
	elseif (self.colorDisconnected and self.disconnected) then
		t = parent.colors.disconnected
	elseif (self.colorClass and UnitIsPlayer(unit)) or
		(self.colorClassNPC and not UnitIsPlayer(unit)) or
		(self.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
		local _, class = UnitClass(unit)
		t = parent.colors.class[class]
	elseif (self.colorReaction and UnitReaction(unit, "player")) then
		t = parent.colors.reaction[UnitReaction(unit, "player")]
	elseif (self.colorSmooth) then
		r, g, b = parent:ColorGradient(cur, max, unpack(self.smoothGradient or parent.colors.smooth))
	elseif (self.colorHealth) then
		t = parent.colors.health
	end

	if (t) then
		r, g, b = t[1], t[2], t[3]
	end

	if (r or g or b) then
		self:SetStatusBarColor(r, g, b)
	end
end

function Module:PreUpdateThreat(threat, unit)
	local ROLE = IsInGroup() or IsInRaid() and UnitExists(unit.."target") and UnitGroupRolesAssigned(unit.."target") or "NONE"

	if ROLE == "TANK" then
		threat.feedbackUnit = unit.."target"
		threat.offtank = not UnitIsUnit(unit.."target", "player")
		threat.isTank = true
	else
		threat.feedbackUnit = "player"
		threat.offtank = false
		threat.isTank = K.GetPlayerRole() == "TANK" and true or false
	end
end

function Module:PostUpdateThreat(threat, _, status)
	if C["Nameplates"].Threat then
		local r, g, b
		if status then
			if (status == 3) then -- Securely Tanking
				if threat.isTank then
					r, g, b = C["Nameplates"].GoodColor[1], C["Nameplates"].GoodColor[2], C["Nameplates"].GoodColor[3]
				else
					r, g, b = C["Nameplates"].BadColor[1], C["Nameplates"].BadColor[2], C["Nameplates"].BadColor[3]
				end
			elseif (status == 2) then -- insecurely tanking
				if threat.isTank then
					r, g, b = C["Nameplates"].BadTransition[1], C["Nameplates"].BadTransition[2], C["Nameplates"].BadTransition[3]
				else
					r, g, b = C["Nameplates"].GoodTransition[1], C["Nameplates"].GoodTransition[2], C["Nameplates"].GoodTransition[3]
				end
			elseif (status == 1) then -- not tanking but threat higher than tank
				if threat.isTank then
					r, g, b = C["Nameplates"].GoodTransition[1], C["Nameplates"].GoodTransition[2], C["Nameplates"].GoodTransition[3]
				else
					r, g, b = C["Nameplates"].BadTransition[1], C["Nameplates"].BadTransition[2], C["Nameplates"].BadTransition[3]
				end
			else -- not tanking at all
				if threat.isTank then
					-- Check if it is being tanked by an offtank.
					if threat.offtank then
						r, g, b = C["Nameplates"].TankedByTankColor[1], C["Nameplates"].TankedByTankColor[2], C["Nameplates"].TankedByTankColor[3]
					else
						r, g, b = C["Nameplates"].BadColor[1], C["Nameplates"].BadColor[2], C["Nameplates"].BadColor[3]
					end
				else
					if threat.offtank then
						r, g, b = C["Nameplates"].TankedByTankColor[1], C["Nameplates"].TankedByTankColor[2], C["Nameplates"].TankedByTankColor[3]
					else
						r, g, b = C["Nameplates"].GoodColor[1], C["Nameplates"].GoodColor[2], C["Nameplates"].GoodColor[3]
					end
				end
			end
		end

		local shouldUpdate
		if threat.__owner.Health.ColorOverride and (not r or not g or not b) then
			threat.__owner.Health.ColorOverride = nil
			shouldUpdate = true
		elseif threat.__owner.Health.ColorOverride and (threat.__owner.Health.ColorOverride[1] ~= r or threat.__owner.Health.ColorOverride[2] ~= g or threat.__owner.Health.ColorOverride ~= b) then
			threat.__owner.Health.ColorOverride = {r, g, b}
			shouldUpdate = true
		elseif not threat.__owner.Health.ColorOverride and (r and g and b) then
			threat.__owner.Health.ColorOverride = {r, g, b}
			shouldUpdate = true
		end

		if shouldUpdate then
			threat.__owner.Health:ForceUpdate()
		end
	else
		if threat.__owner.Health.ColorOverride then
			threat.__owner.Health.ColorOverride = nil
			threat.__owner.Health:ForceUpdate()
		end
	end
end

function Module:UpdateQuestUnit(unit)
	if unit == "player" then
		return
	end

	local updateSize = C["Nameplates"].QuestIconSize

	if C["Nameplates"].QuestIcon then
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
	if C["Nameplates"].MarkHealers then
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

function Module:UpdateClassificationIcons()
	if C["Nameplates"].EliteIcon then
		if not self:IsElementEnabled("ClassificationIndicator") then
			self:EnableElement("ClassificationIndicator")
		end

		self.ClassificationIndicator:ClearAllPoints()
		self.ClassificationIndicator:SetSize(self.Health:GetHeight() + 2, self.Health:GetHeight() + 2)
		self.ClassificationIndicator:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
	else
		if self:IsElementEnabled("ClassificationIndicator") then
			self:DisableElement("ClassificationIndicator")
		end
	end
end

function Module:HighlightPlate()
	local unit = self.unit

	local health = self.Health
	local shadowH = health.Shadow
	local arrowT = C["Nameplates"].TargetArrow and self.TopArrow

	local isPlayer = unit and UnitIsPlayer(unit)
	local reaction = unit and UnitReaction(unit, "player")

	if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
		if isPlayer then
			local _, class = UnitClass(unit)
			if class then
				local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				if color then
					if arrowT then
						arrowT:Show()
						arrowT:SetVertexColor(color.r, color.g, color.b)
					end

					if shadowH then
						shadowH:SetBackdropBorderColor(color.r, color.g, color.b)
					end
				end
			end
		elseif reaction then
			local color = FACTION_BAR_COLORS[reaction]
			if color then
				if arrowT then
					arrowT:Show()
					arrowT:SetVertexColor(color.r, color.g, color.b)
				end

				if shadowH then
					shadowH:SetBackdropBorderColor(color.r, color.g, color.b)
				end
			end
		end
	else
		if arrowT then
			arrowT:Hide()
		end

		if shadowH then
			shadowH:SetBackdropBorderColor(0, 0, 0, 0.8)
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
		self.Time:SetText(("%.1f"):format(math_abs(duration - self.max)))
	else
		self.Time:SetText(("%.1f"):format(duration))
	end
end

function Module:CustomCastDelayText(duration)
	if self.channeling then
		self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(math_abs(duration - self.max), self.delay))
	else
		self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(duration, "+", self.delay))
	end
end

function Module:HideTicks()
	for i = 1, #Module.ticks do
		Module.ticks[i]:Hide()
	end
end

function Module:SetCastTicks(castbar, numTicks, extraTickRatio)
	local CastTicksTexture = K.GetTexture(C["Unitframe"].Texture)

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

function Module:PostCastStart(unit, name)
	if unit == "vehicle" then
		unit = "player"
	end

	if self.Text and name then -- ??
		self.Text:SetText(name)
	end

	-- Get length of Time, then calculate available length for Text
	local timeWidth = self.Time:GetStringWidth()
	local textWidth = self:GetWidth() - timeWidth - 10
	local textStringWidth = self.Text:GetStringWidth()

	if timeWidth == 0 or textStringWidth == 0 then
		K.Delay(0.05, function() -- Delay may need tweaking
			textWidth = self:GetWidth() - self.Time:GetStringWidth() - 10
			textStringWidth = self.Text:GetStringWidth()
			if textWidth > 0 then self.Text:SetWidth(math_min(textWidth, textStringWidth)) end
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

	if C["Unitframe"].CastbarTicks and unit == "player" then
		local baseTicks = Module.ChannelTicks[name]

		-- Detect channeling spell and if it"s the same as the previously channeled one
		if baseTicks and name == self.prevSpellCast then
			self.chainChannel = true
		elseif baseTicks then
			self.chainChannel = nil
			self.prevSpellCast = name
		end

		if baseTicks and Module.ChannelTicksSize[name] and Module.HastedChannelTicks[name] then
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

			local baseTickSize = Module.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			local extraTickRatio = extraTick / hastedTickSize

			Module:SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
		elseif baseTicks and Module.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = Module.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			local extraTickRatio = extraTick / hastedTickSize

			Module:SetCastTicks(self, baseTicks, extraTickRatio)
		elseif baseTicks then
			Module:SetCastTicks(self, baseTicks)
		else
			Module:HideTicks()
		end
	elseif unit == "player" then
		Module:HideTicks()
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

	if self.notInterruptible and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
end

function Module:PostCastStop()
	self.chainChannel = nil
	self.prevSpellCast = nil
end

function Module:PostChannelUpdate(unit, name)
	if not (unit == "player" or unit == "vehicle") then
		return
	end

	if C["Unitframe"].CastbarTicks then
		local baseTicks = Module.ChannelTicks[name]

		if baseTicks and Module.ChannelTicksSize[name] and Module.HastedChannelTicks[name] then
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

			local baseTickSize = Module.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)

			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			Module:SetCastTicks(self, baseTicks + bonusTicks, self.extraTickRatio)
		elseif baseTicks and Module.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = Module.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			Module:SetCastTicks(self, baseTicks, self.extraTickRatio)
		elseif baseTicks then
			if self.chainChannel then
				baseTicks = baseTicks + 1
			end
			Module:SetCastTicks(self, baseTicks)
		else
			Module:HideTicks()
		end
	else
		Module:HideTicks()
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

function Module:PostCastFailedOrInterrupted()
	self:SetStatusBarColor(1.0, 0.0, 0.0)
	self:SetValue(self.max)

	if (self.Time) then
		self.Time:SetText("")
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
				K.UIFrameFlash(button, 0.80, true)
			else
				button:SetBackdropBorderColor()
				K.UIFrameStopFlash(button)
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

	if C["Nameplates"].TargetArrow ~= true then
		return
	end

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
		if UnitIsUnit(unit, "player") then
			Nameplate:DisableElement("Castbar")
			Nameplate:DisableElement("RaidTargetIndicator")
			Nameplate:DisableElement("PvPIndicator")
			Nameplate.Name:Hide()

			if Nameplate.ClassPowerText then
				Nameplate.ClassPowerText:Show()
			end

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
		else
			Nameplate:EnableElement("Castbar")
			Nameplate:EnableElement("RaidTargetIndicator")
			Nameplate:EnableElement("PvPIndicator")
			Nameplate.Name:Show()

			Module.UpdateQuestUnit(Nameplate, unit)
			Module.UpdateClassificationIcons(Nameplate)
			Module.HighlightPlate(Nameplate)
			Module.UpdateNameplateTarget(Nameplate)
			Module.NameplateClassIcons(Nameplate)
			Module.UpdatePlateTotems(Nameplate)
			Module.UpdateHealerIcons(Nameplate)

			if Nameplate.ClassPowerText then
				Nameplate.ClassPowerText:Hide()
			end

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

		if Nameplate.ClassPowerText then
			Nameplate.ClassPowerText:Hide()
			Nameplate.ClassPowerText:ClearAllPoints()
			Nameplate.ClassPowerText:SetPoint(Point, Nameplate.Health, Relpoint, xOffset, yOffset)
			Nameplate.ClassPowerText:SetParent(Nameplate)
		end

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
			if Player.unitFrame.ClassPowerText then
				Player.unitFrame.ClassPowerText:ClearAllPoints()
				Player.unitFrame.ClassPowerText:SetParent(Anchor)
				Player.unitFrame.ClassPowerText:SetPoint(Point, Anchor.Health, Relpoint, xOffset, yOffset)
			end
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

function Module:NameplateClassIcons()
	local Nameplate = self
	local reaction = UnitReaction(Nameplate.unit, "player")

	if UnitIsPlayer(Nameplate.unit) and (reaction and reaction <= 4) then
		local _, class = UnitClass(Nameplate.unit)
		local texcoord = CLASS_ICON_TCOORDS[class]

		Nameplate.Class.Icon:SetTexCoord(texcoord[1] + 0.015, texcoord[2] - 0.02, texcoord[3] + 0.018, texcoord[4] - 0.02)
		Nameplate.Class:Show()
	else
		Nameplate.Class.Icon:SetTexCoord(0, 0, 0, 0)
		Nameplate.Class:Hide()
	end
end

function Module:GetPartyFramesAttributes()
	local PartyProperties = C["Party"].PartyAsRaid and "custom [group:party] hide" or "custom [@raid6,exists] hide;show"

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
	local DamageRaidProperties = C["Party"].PartyAsRaid and "custom [group:party] show" or "custom [@raid6,exists] show;hide"

	return "DamageRaid", nil, DamageRaidProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", C["Raid"].Width,
	"initial-height", C["Raid"].Height,
	"showParty", true,
	"showRaid", true,
	"showPlayer", C["Party"].ShowPlayer,
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
    local HealerRaidProperties = C["Party"].PartyAsRaid and "custom [group:party] show" or "custom [@raid6,exists] show;hide"

    return "HealerRaid", nil, HealerRaidProperties,
    "oUF-initialConfigFunction", [[
    local header = self:GetParent()
    self:SetWidth(header:GetAttribute("initial-width"))
    self:SetHeight(header:GetAttribute("initial-height"))
    ]],

    "initial-width", C["Raid"].Width,
    "initial-height", C["Raid"].Height,
    "showParty", true,
    "showRaid", true,
    "showPlayer", C["Party"].ShowPlayer,
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
	elseif (string_find(unit, "party") or string_find(unit, "raid") or string_find(unit, "maintank")) then
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
		Player:SetPoint("BOTTOMRIGHT", "ActionBarAnchor", "TOPLEFT", 44, 200)
		Player:SetSize(200, 52)

		local Target = oUF:Spawn("target")
		Target:SetPoint("BOTTOMLEFT", "ActionBarAnchor", "TOPRIGHT", -44, 200)
		Target:SetSize(200, 52)

		local TargetOfTarget = oUF:Spawn("targettarget")
		TargetOfTarget:SetPoint("TOPLEFT", Target, "BOTTOMRIGHT", -56, 2)
		TargetOfTarget:SetSize(116, 36)

		local Pet = oUF:Spawn("pet")
		if C["Unitframe"].CombatFade and Player and not InCombatLockdown() then
			Pet:SetParent(Player)
		end
		Pet:SetPoint("TOPRIGHT", Player, "BOTTOMLEFT", 56, 2)
		Pet:SetSize(116, 36)

		local Focus = oUF:Spawn("focus")
		Focus:SetPoint("BOTTOMRIGHT", Player, "TOPLEFT", -60, 30)
		Focus:SetSize(190, 52)

		local FocusTarget = oUF:Spawn("focustarget")
		FocusTarget:SetPoint("TOPRIGHT", Focus, "BOTTOMLEFT", 56, 2)
		FocusTarget:SetSize(116, 36)

		Module.Player = Player
		Module.Target = Target
		Module.TargetOfTarget = TargetOfTarget
		Module.Pet = Pet
		Module.Focus = Focus
		Module.FocusTarget = FocusTarget

		if (C["Arena"].Enable) then
			local Arena = {}
			for i = 1, MAX_ARENA_ENEMIES or 5 do
				Arena[i] = oUF:Spawn("arena" .. i, nil)
				Arena[i]:SetSize(190, 52)
				if (i == 1) then
					Arena[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
				else
					Arena[i]:SetPoint("TOPLEFT", Arena[i - 1], "BOTTOMLEFT", 0, -48)
				end
				Movers:RegisterFrame(Arena[i])
			end

			Module.Arena = Arena
		end

		if (C["Boss"].Enable) then
			local Boss = {}
			for i = 1, MAX_BOSS_FRAMES do
				Boss[i] = oUF:Spawn("boss" .. i)
				if (i == 1) then
					Boss[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
				else
					Boss[i]:SetPoint("TOPLEFT", Boss[i - 1], "BOTTOMLEFT", 0, -28)
				end

				Boss[i]:SetSize(190, 52)
				Movers:RegisterFrame(Boss[i])
			end

			Module.Boss = Boss
		end

		if C["Party"].Enable then
			local Party = oUF:SpawnHeader(Module:GetPartyFramesAttributes())
			Party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -180)
			Movers:RegisterFrame(Party)
		end

		if C["Raid"].Enable then
			local DamageRaid = oUF:SpawnHeader(Module:GetDamageRaidFramesAttributes())
			local HealerRaid = oUF:SpawnHeader(Module:GetHealerRaidFramesAttributes())
			local MainTankRaid = oUF:SpawnHeader(Module:GetMainTankAttributes())

			if C["Raid"].RaidLayout.Value == "Healer" then
				HealerRaid:SetPoint("TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 10, 14)
				Movers:RegisterFrame(HealerRaid)
			elseif C["Raid"].RaidLayout.Value == "Damage" then
				DamageRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -30)
				Movers:RegisterFrame(DamageRaid)
			end

			if C["Raid"].MainTankFrames then
				if C["Raid"].RaidLayout.Value == "Healer" then
					MainTankRaid:SetPoint("BOTTOMLEFT", "ActionBarAnchor", "BOTTOMRIGHT", 6, 2)
				elseif C["Raid"].RaidLayout.Value == "Damage" then
					MainTankRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
				end

				Movers:RegisterFrame(MainTankRaid)
			end
		end

		Movers:RegisterFrame(Player)
		Movers:RegisterFrame(Target)
		Movers:RegisterFrame(TargetOfTarget)
		Movers:RegisterFrame(Pet)
		Movers:RegisterFrame(Focus)
		Movers:RegisterFrame(FocusTarget)
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

		Movers:RegisterFrame(P_BUFF_ICON_Anchor)
		Movers:RegisterFrame(P_PROC_ICON_Anchor)
		Movers:RegisterFrame(SPECIAL_P_BUFF_ICON_Anchor)
		Movers:RegisterFrame(T_DEBUFF_ICON_Anchor)
		Movers:RegisterFrame(T_BUFF_Anchor)
		Movers:RegisterFrame(PVE_PVP_DEBUFF_Anchor)
		Movers:RegisterFrame(PVE_PVP_CC_Anchor)
		Movers:RegisterFrame(COOLDOWN_Anchor)
		Movers:RegisterFrame(T_DE_BUFF_BAR_Anchor)
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

function Module:OnEnable()
	self.Backdrop = {
		bgFile = C["Media"].Blank,
		insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult}
	}

	oUF:RegisterStyle(" ", Module.CreateStyle)
	oUF:SetActiveStyle(" ")

	self:CreateUnits()
	self:CreateFilgerAnchors()

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
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:PLAYER_REGEN_ENABLED()

		local BlizzPlateManaBar = _G.NamePlateDriverFrame.classNamePlatePowerBar
		if BlizzPlateManaBar then
			BlizzPlateManaBar:Hide()
			BlizzPlateManaBar:UnregisterAllEvents()
		end

		hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
			if frame.classNamePlateMechanicFrame then
				frame.classNamePlateMechanicFrame:Hide()
			end
			if frame.classNamePlatePowerBar then
				frame.classNamePlatePowerBar:Hide()
				frame.classNamePlatePowerBar:UnregisterAllEvents()
			end
		end)
	end

	if C["Unitframe"].Enable then
		self:RegisterEvent("PLAYER_TARGET_CHANGED")
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")
		self:RegisterEvent("UNIT_FACTION")

		self:UpdateRangeCheckSpells()
	end
end