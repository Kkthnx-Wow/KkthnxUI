local K, C = unpack(select(2, ...))
local Module = K:NewModule("Unitframes", "AceEvent-3.0", "AceTimer-3.0")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local math_ceil = math.ceil
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
local UnitReaction = _G.UnitReaction

Module.Units = {}
Module.Headers = {}
Module.ticks = {}

local classify = {
	rare = {1, 1, 1, true},
	elite = {1, 1, 1},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
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

function Module:HighlightPlate()
	local unit = self.unit
	local plateShadow = self.Health.Shadow

	if plateShadow then
		plateShadow:SetBackdropBorderColor(0, 0, 0, 0.8)
	end

	local r, g, b, a
	local showIndicator
	if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
		showIndicator = true
		r, g, b, a = 1, 1, 1, 0.8
	end

	if showIndicator then
		if plateShadow then
			plateShadow:SetBackdropBorderColor(r, g, b, a)
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
	self.Highlight:SetVertexColor(1, 1, 1, 0.50)
	self.Highlight:Hide()
end

function Module:UpdateUnitClassify(unit)
	local class = _G.UnitClassification(unit)
	if self.creatureIcon then
		if class and classify[class] then
			local r, g, b, desature = unpack(classify[class])
			self.creatureIcon:SetVertexColor(r, g, b)
			self.creatureIcon:SetDesaturated(desature)
			self.creatureIcon:SetAlpha(1)
		else
			self.creatureIcon:SetAlpha(0)
		end
	end
end

local unitTip = CreateFrame("GameTooltip", "KkthnxUIQuestUnitTip", nil, "GameTooltipTemplate")
function Module:UpdateQuestUnit(_, unit)
	if not C["Nameplates"].QuestIcon then
		return
	end

	if IsInInstance() then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local isLootQuest, questProgress
	unitTip:SetOwner(UIParent, "ANCHOR_NONE")
	unitTip:SetUnit(unit)

	for i = 2, unitTip:NumLines() do
		local textLine = _G[unitTip:GetName().."TextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			local unitName, progressText = strmatch(text, "^ ([^ ]-) ?%- (.+)$")
			if r > .99 and g > .82 and b == 0 then
				isLootQuest = true
			elseif unitName and progressText then
				isLootQuest = false
				if unitName == "" or unitName == K.Name then
					local current, goal = strmatch(progressText, "(%d+)/(%d+)")
					local progress = strmatch(progressText, "([%d%.]+)%%")
					if current and goal then
						if tonumber(current) < tonumber(goal) then
							questProgress = goal - current
							break
						end
					elseif progress then
						progress = tonumber(progress)
						if progress and progress < 100 then
							questProgress = progress.."%"
							break
						end
					else
						isLootQuest = true
						break
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetAtlas("Warfronts-BaseMapIcons-Horde-Barracks-Minimap")
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas("adventureguide-microbutton-alert")
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

-- Castbar Functions
local function updateCastBarTicks(bar, numTicks)
	if numTicks and numTicks > 0 then
		local delta = bar:GetWidth() / numTicks
		for i = 1, numTicks do
			if not Module.ticks[i] then
				Module.ticks[i] = bar:CreateTexture(nil, "OVERLAY")
				Module.ticks[i]:SetTexture(C["Media"].Blank)
				Module.ticks[i]:SetVertexColor(0, 0, 0, 0.8)
				Module.ticks[i]:SetWidth(2)
				Module.ticks[i]:SetHeight(bar:GetHeight())
			end
			Module.ticks[i]:ClearAllPoints()
			Module.ticks[i]:SetPoint("CENTER", bar, "LEFT", delta * i, 0 )
			Module.ticks[i]:Show()
		end
	else
		for _, tick in pairs(Module.ticks) do
			tick:Hide()
		end
	end
end

function Module:OnCastbarUpdate(elapsed)
	if self.casting or self.channeling then
		local decimal = self.decimal

		local duration = self.casting and self.duration + elapsed or self.duration - elapsed
		if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			return
		end

		if self.__owner.unit == "player" then
			if self.delay ~= 0 then
				self.Time:SetFormattedText(decimal.." | |cffff0000"..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText(decimal.." | "..decimal, duration, self.max)
				if self.Lag and self.SafeZone and self.SafeZone.timeDiff ~= 0 then
					self.Lag:SetFormattedText("%d ms", self.SafeZone.timeDiff * 1000)
				end
			end
		else
			if duration > 1e4 then
				self.Time:SetText("∞ | ∞")
			else
				self.Time:SetFormattedText(decimal.." | "..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			end
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - .02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

function Module:OnCastSent()
	local element = self.Castbar
	if not element.SafeZone then
		return
	end

	element.SafeZone.sendTime = GetTime()
	element.SafeZone.castSent = true
end

function Module:PostCastStart(unit)
	--[[if unit == "vehicle" then
		unit = "player"
	end--]]

	if unit == "vehicle" or UnitInVehicle("player") then
		if self.SafeZone then
			self.SafeZone:Hide()
		end

		if self.Lag then
			self.Lag:Hide()
		end
	elseif unit == "player" then
		local safeZone = self.SafeZone
		if not safeZone then
			return
		end

		safeZone.timeDiff = 0
		if safeZone.castSent then
			safeZone.timeDiff = GetTime() - safeZone.sendTime
			safeZone.timeDiff = safeZone.timeDiff > self.max and self.max or safeZone.timeDiff
			safeZone:SetWidth(self:GetWidth() * (safeZone.timeDiff + .001) / self.max)
			safeZone:Show()
			safeZone.castSent = false
		end

		local numTicks = 0
		if self.channeling then
			local spellID = UnitChannelInfo(unit)
			numTicks = K.ChannelingTicks[spellID] or 0 -- Move this shit to filters
		end
		updateCastBarTicks(self, numTicks)
	end

	-- Fix for empty icon
	if self.Icon and not self.Icon:GetTexture() then
		self.Icon:SetTexture(136243)
	end

	local r, g, b = self.casting and K.Colors.castbar.CastingColor[1], K.Colors.castbar.CastingColor[2], K.Colors.castbar.CastingColor[3] or K.Colors.castbar.ChannelingColor[1], K.Colors.castbar.ChannelingColor[2], K.Colors.castbar.ChannelingColor[3]
	--local r, g, b = K.Colors.castbar.CastingColor[1], K.Colors.castbar.CastingColor[2], K.Colors.castbar.CastingColor[3]

	if (self.notInterruptible and unit ~= "player") and UnitCanAttack("player", unit) then
		r, g, b = K.Colors.castbar.notInterruptibleColor[1], K.Colors.castbar.notInterruptibleColor[2], K.Colors.castbar.notInterruptibleColor[3]
	elseif C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and K.Colors.class[Class]
		if t then
			r, g, b = t[1], t[2], t[3]
		end
	elseif C["Unitframe"].CastReactionColor then
		local Reaction = UnitReaction(unit, 'player')
		local t = Reaction and K.Colors.reaction[Reaction]
		if t then
			r, g, b = t[1], t[2], t[3]
		end
	end

	self:SetAlpha(1)
	self.Spark:Show()
	self:SetStatusBarColor(r, g, b)
end

function Module:PostUpdateInterruptible(unit)
	if unit == "vehicle" or unit == "player" then
		return
	end

	local r, g, b = self.casting and K.Colors.castbar.CastingColor[1], K.Colors.castbar.CastingColor[2], K.Colors.castbar.CastingColor[3] or K.Colors.castbar.ChannelingColor[1], K.Colors.castbar.ChannelingColor[2], K.Colors.castbar.ChannelingColor[3]
	--local r, g, b = K.Colors.castbar.CastingColor[1], K.Colors.castbar.CastingColor[2], K.Colors.castbar.CastingColor[3]

	if self.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = K.Colors.castbar.notInterruptibleColor[1], K.Colors.castbar.notInterruptibleColor[2], K.Colors.castbar.notInterruptibleColor[3]
	elseif C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and K.Colors.class[Class]
		if t then
			r, g, b = t[1], t[2], t[3]
		end
	elseif C["Unitframe"].CastReactionColor then
		local Reaction = UnitReaction(unit, "player")
		local t = Reaction and K.Colors.reaction[Reaction]
		if t then
			r, g, b = t[1], t[2], t[3]
		end
	end

	self:SetStatusBarColor(r, g, b)
end

function Module:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(K.Colors.castbar.CompleteColor[1], K.Colors.castbar.CompleteColor[2], K.Colors.castbar.CompleteColor[3])
		self.fadeOut = true
	end

	self:SetValue(self.max)
	self:Show()
end

function Module:PostChannelStop()
	self.fadeOut = true
	self:SetValue(0)
	self:Show()
end

function Module:PostCastFailed()
	self:SetStatusBarColor(K.Colors.castbar.FailColor[1], K.Colors.castbar.FailColor[2], K.Colors.castbar.FailColor[3])
	self:SetValue(self.max)
	self.fadeOut = true
	self:Show()
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
	local buttonFontSize = self.fontSize or self.size * 0.46

	if string_match(button:GetName(), "NamePlate") then
		if C["Nameplates"].Enable then
			button:CreateShadow(true)

			button.Remaining = button.cd:CreateFontString(nil, "OVERLAY")
			button.Remaining:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
			button.Remaining:SetPoint("TOPLEFT", 0, 0)

			button.cd.noCooldownCount = true
			button.cd:SetReverse(true)
			button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
			button.cd:ClearAllPoints()
			button.cd:SetAllPoints()
			button.cd:SetHideCountdownNumbers(true)

			button.icon:SetAllPoints()
			button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			button.icon:SetDrawLayer("ARTWORK")

			button.count:SetPoint("BOTTOMRIGHT", 0, 0)
			button.count:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
			button.count:SetTextColor(0.84, 0.75, 0.65)
		end
	else
		button:CreateBorder()

		button.Remaining = button.cd:CreateFontString(nil, "OVERLAY")
		button.Remaining:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
		button.Remaining:SetPoint("TOPLEFT", 0, 0)

		button.cd.noCooldownCount = true
		button.cd:SetReverse(true)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:SetPoint("TOPLEFT", 1, -1)
		button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
		button.cd:SetHideCountdownNumbers(true)

		button.icon:SetAllPoints()
		button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		button.icon:SetDrawLayer("ARTWORK")

		button.count:SetPoint("BOTTOMRIGHT", 0, 0)
		button.count:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
		button.count:SetTextColor(0.84, 0.75, 0.65)

		button.overlay:SetTexture(nil)
		button.stealable:SetAtlas("bags-newitem")
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

	if (K.RaidBuffsTracking["ALL"]) then
		for _, value in pairs(K.RaidBuffsTracking["ALL"]) do
			table_insert(buffs, value)
		end
	end

	if (K.RaidBuffsTracking[Class]) then
		for _, value in pairs(K.RaidBuffsTracking[Class]) do
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
			Count:SetPoint("CENTER", unpack(K.RaidBuffsTrackingPosition[spell[2]]))
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
	local Point, Relpoint, xOffset, yOffset = "TOP", "BOTTOM", 0, -4

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

				if (K.Class == "MONK") then
					Nameplate.Stagger:Show()
					Nameplate:EnableElement("Stagger")
					Nameplate.Stagger:ForceUpdate()
				end
			end
		else
			Nameplate:EnableElement("Castbar")
			Nameplate:EnableElement("RaidTargetIndicator")
			Nameplate:EnableElement("PvPIndicator")
			Nameplate.Name:Show()

			Module.HighlightPlate(Nameplate)

			Module.UpdateQuestUnit(Nameplate, event, unit)
			Module.UpdateNameplateTarget(Nameplate)
			Module.UpdateUnitClassify(Nameplate, unit)

			if Nameplate.ClassPower then
				Nameplate.ClassPower:Hide()
				Nameplate:DisableElement("ClassPower")

				if (K.Class == "DEATHKNIGHT") then
					Nameplate.Runes:Hide()
					Nameplate:DisableElement("Runes")
				end

				if (K.Class == "MONK") then
					Nameplate.Stagger:Hide()
					Nameplate:DisableElement("Stagger")
				end
			end
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		Nameplate:DisableElement("ClassPower")
		Nameplate:DisableElement("Runes")
		Nameplate:DisableElement("Stagger")

		Nameplate:EnableElement("Castbar")
		Nameplate:EnableElement("RaidTargetIndicator")
		Nameplate:EnableElement("PvPIndicator")
		Nameplate.Name:Show()

		if Nameplate.ClassPower then
			Nameplate.ClassPower:Hide()
			Nameplate.ClassPower:ClearAllPoints()
			Nameplate.ClassPower:SetParent(Nameplate)
			Nameplate.ClassPower:SetPoint(Point, Nameplate.Castbar, Relpoint, xOffset, yOffset)
		end

		if Nameplate.Runes then
			Nameplate.Runes:Hide()
			Nameplate.Runes:ClearAllPoints()
			Nameplate.Runes:SetParent(Nameplate)
			Nameplate.Runes:SetPoint(Point, Nameplate.Castbar, Relpoint, xOffset, yOffset)
		end

		if Nameplate.Stagger then
			Nameplate.Stagger:Hide()
			Nameplate.Stagger:ClearAllPoints()
			Nameplate.Stagger:SetParent(Nameplate)
			Nameplate.Stagger:SetPoint(Point, Nameplate.Castbar, Relpoint, xOffset, yOffset)
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
				Player.unitFrame.ClassPower:SetPoint(Point, Anchor.Castbar, Relpoint, xOffset, yOffset)
			end
			if Player.unitFrame.Runes then
				Player.unitFrame.Runes:ClearAllPoints()
				Player.unitFrame.Runes:SetParent(Anchor)
				Player.unitFrame.Runes:SetPoint(Point, Anchor.Castbar, Relpoint, xOffset, yOffset)
			end
			if Player.unitFrame.Stagger then
				Player.unitFrame.Stagger:ClearAllPoints()
				Player.unitFrame.Stagger:SetParent(Anchor)
				Player.unitFrame.Stagger:SetPoint(Point, Anchor.Castbar, Relpoint, xOffset, yOffset)
			end
		end
	end
end

function Module:GetPartyFramesAttributes()
	local PartyProperties = "custom [group:party,nogroup:raid] show; hide"

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
	"groupingOrder", "TANK, HEALER, DAMAGER, NONE",
	"sortMethod", "NAME",
	"groupBy", "ASSIGNEDROLE",
	"yOffset", C["Party"].ShowBuffs and -44 or -18
end

function Module:GetDamageRaidFramesAttributes()
	local DamageRaidProperties = "custom [group:raid] show; hide"

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
	"groupingOrder", "TANK, HEALER, DAMAGER, NONE",
	"sortMethod", "NAME",
	"groupBy", "ASSIGNEDROLE",
	"maxColumns", math_ceil(40 / 5),
	"unitsPerColumn", C["Raid"].MaxUnitPerColumn,
	"columnSpacing", 6,
	"columnAnchorPoint", "LEFT"
end

function Module:GetHealerRaidFramesAttributes()
	local HealerRaidProperties = "custom [group:raid] show; hide"

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
	"groupingOrder", "TANK, HEALER, DAMAGER, NONE",
	"sortMethod", "NAME",
	"groupBy", "ASSIGNEDROLE",
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
	if C["Unitframe"].Enable then
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

			self.Units.TargetOfTarget = TargetOfTarget
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

			self.Units.FocusTarget = FocusTarget
		end

		self.Units.Player = Player
		self.Units.Target = Target
		self.Units.Pet = Pet
		self.Units.Focus = Focus

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

			self.Units.Arena = Arena
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

			self.Units.Boss = Boss
		end

		if C["Party"].Enable then
			local Party = oUF:SpawnHeader(Module:GetPartyFramesAttributes())
			Party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -180)

			Module.Headers.Party = Party

			K.Mover(Party, "Party", "Party", {"TOPLEFT", UIParent, "TOPLEFT", 4, -180}, 158, 390)
		end

		if C["Raid"].Enable then
			local DamageRaid = oUF:SpawnHeader(Module:GetDamageRaidFramesAttributes())
			local HealerRaid = oUF:SpawnHeader(Module:GetHealerRaidFramesAttributes())
			local MainTankRaid = oUF:SpawnHeader(Module:GetMainTankAttributes())

			if C["Raid"].RaidLayout.Value == "Healer" then
				HealerRaid:SetPoint("TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 12, 14)

				Module.Headers.Raid = HealerRaid

				K.Mover(HealerRaid, "HealerRaid", "HealerRaid", {"TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 12, 14}, C["Raid"].Width, C["Raid"].Height)
			elseif C["Raid"].RaidLayout.Value == "Damage" then
				DamageRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -30)

				Module.Headers.Raid = DamageRaid

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
	local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs

	if (ORD) then
		local _, InstanceType = IsInInstance()

		if (ORD.RegisteredList ~= "RD") and (InstanceType == "party" or InstanceType == "raid") then
			ORD:ResetDebuffData()
			ORD:RegisterDebuffs(K.DebuffsTracking.RaidDebuffs.spells)
			ORD.RegisteredList = "RD"
		else
			if ORD.RegisteredList ~= "CC" then
				ORD:ResetDebuffData()
				ORD:RegisterDebuffs(K.DebuffsTracking.CCDebuffs.spells)
				ORD.RegisteredList = "CC"
			end
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

function Module:OnEnable()
	Module.Backdrop = {
		bgFile = C["Media"].Blank,
		insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult}
	}

	oUF:RegisterStyle(" ", Module.CreateStyle)
	oUF:SetActiveStyle(" ")

	Module:CreateUnits()
	Module:CreateFilgerAnchors()

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
	end

	if C["Unitframe"].Enable then
		K.HideInterfaceOption(InterfaceOptionsCombatPanelTargetOfTarget)

		Module:RegisterEvent("PLAYER_TARGET_CHANGED")
		Module:RegisterEvent("PLAYER_FOCUS_CHANGED")
		Module:RegisterEvent("UNIT_FACTION")

		Module:UpdateRangeCheckSpells()
	end
end