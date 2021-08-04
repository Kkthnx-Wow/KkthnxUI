local K, C = unpack(select(2, ...))
local Module = K:NewModule("Unitframes")
local AuraModule = K:GetModule("Auras")
local oUF = oUF or K.oUF

local _G = _G

local pairs = _G.pairs
local string_format = _G.string.format
local unpack = _G.unpack

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CreateFrame = _G.CreateFrame
local GetRuneCooldown = _G.GetRuneCooldown
local GetTime = _G.GetTime
local IsInInstance = _G.IsInInstance
local IsReplacingUnit = _G.IsReplacingUnit
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES
local PlaySound = _G.PlaySound
local SOUNDKIT = _G.SOUNDKIT
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave
local UnitInVehicle = _G.UnitInVehicle
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitReaction = _G.UnitReaction
local UnitThreatSituation = _G.UnitThreatSituation
local oUF_RaidDebuffs = _G.oUF_RaidDebuffs

local castbarTicks = {}

function Module:UpdateClassPortraits(unit)
	if not unit or C["Unitframe"].PortraitStyle.Value == "NoPortraits" then
		return
	end

	local _, unitClass = UnitClass(unit)
	if unitClass then
		local PortraitValue = C["Unitframe"].PortraitStyle.Value
		local ClassTCoords = CLASS_ICON_TCOORDS[unitClass]

		local defaultCPs = "ClassPortraits"
		local newCPs = "NewClassPortraits"

		for _, value in pairs({PortraitValue}) do
			if value and value == defaultCPs and UnitIsPlayer(unit) then
				self:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
				if ClassTCoords then
					self:SetTexCoord(ClassTCoords[1], ClassTCoords[2], ClassTCoords[3], ClassTCoords[4])
				end
			elseif value and value == newCPs and UnitIsPlayer(unit) then
				local betterClassIcons = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\BetterClassIcons\\%s.tga"
				self:SetTexture(betterClassIcons:format(unitClass))
			else
				self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			end
		end
	end
end

function Module:UpdatePortraitColor(unit, min, max)
	if C["Unitframe"].PortraitStyle.Value == "NoPortraits" then
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

function Module:PostUpdatePvPIndicator(unit, status)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) and status == "ffa" then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self:SetTexCoord(0, 0.65625, 0, 0.65625)
	elseif factionGroup and UnitIsPVP(unit) and status ~= nil then
		self:SetTexture("Interface\\QUESTFRAME\\objectivewidget")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module:UpdateThreat(_, unit)
	if unit ~= self.unit then
		return
	end

	local status = UnitThreatSituation(unit)
	if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
		if not self then
			return
		end

		if not self.Portrait then
			return
		end

		if not self.Portrait.KKUI_Border then
			return
		end

		if status and status > 1 then
			local r, g, b = unpack(oUF.colors.threat[status])
			self.Portrait.KKUI_Border:SetVertexColor(r, g, b)
		else
			if C["General"].ColorTextures then
				self.Portrait.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				self.Portrait.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if not self then
			return
		end

		if not self.Portrait.Border then
			return
		end

		if not self.Portrait.Border.KKUI_Border then
			return
		end

		if status and status > 1 then
			local r, g, b = unpack(oUF.colors.threat[status])
			self.Portrait.Border.KKUI_Border:SetVertexColor(r, g, b)
		else
			if C["General"].ColorTextures then
				self.Portrait.Border.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				self.Portrait.Border.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	elseif C["Unitframe"].PortraitStyle.Value == "NoPortraits" then
		if not self then
			return
		end

		if not self.Health.KKUI_Border then
			return
		end

		if status and status > 1 then
			local r, g, b = unpack(oUF.colors.threat[status])
			self.Health.KKUI_Border:SetVertexColor(r, g, b)
		else
			if C["General"].ColorTextures then
				self.Health.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				self.Health.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	end
end

function Module:UpdateHealth(unit, cur, max)
	if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" or "NoPortraits" then
		return
	end

	local parent = self.__owner
	Module.UpdatePortraitColor(parent, unit, cur, max)
end

local PhaseIconTexCoords = {
	[1] = {1 / 128, 33 / 128, 1 / 64, 33 / 64},
	[2] = {34 / 128, 66 / 128, 1 / 64, 33 / 64},
}

function Module:UpdatePhaseIcon(isPhased)
	self:SetTexCoord(unpack(PhaseIconTexCoords[isPhased == 2 and 2 or 1]))
end

function Module:CreateHeader()
	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", function()
		UnitFrame_OnEnter(self)

		if not self.Highlight then
			return
		end

		self.Highlight:Show()
	end)

	self:HookScript("OnLeave", function()
		UnitFrame_OnLeave(self)

		if not self.Highlight then
			return
		end

		self.Highlight:Hide()
	end)
end

-- Castbar Functions
local function updateCastBarTicks(bar, numTicks)
	if numTicks and numTicks > 0 then
		local delta = bar:GetWidth() / numTicks
		for i = 1, numTicks do
			if not castbarTicks[i] then
				castbarTicks[i] = bar:CreateTexture(nil, "OVERLAY")
				castbarTicks[i]:SetTexture(C["Media"].Textures.BlankTexture)
				castbarTicks[i]:SetVertexColor(0, 0, 0, 0.8)
				castbarTicks[i]:SetWidth(2 * K.Mult)
				castbarTicks[i]:SetHeight(bar:GetHeight())
			end
			castbarTicks[i]:ClearAllPoints()
			castbarTicks[i]:SetPoint("CENTER", bar, "LEFT", delta * i, 0 )
			castbarTicks[i]:Show()
		end
	else
		for _, tick in pairs(castbarTicks) do
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
				self.Time:SetFormattedText(decimal.." - |cffff0000"..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText(decimal.." - "..decimal, duration, self.max)
				if self.Lag and self.SafeZone and self.SafeZone.timeDiff and self.SafeZone.timeDiff ~= 0 then
					self.Lag:SetFormattedText("%d ms", self.SafeZone.timeDiff * 1000)
				end
			end
		else
			if duration > 1e4 then
				self.Time:SetText("∞ - ∞")
			else
				self.Time:SetFormattedText(decimal.." - "..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			end
		end
		self.duration = duration
		self:SetValue(duration)

		if self.Spark then
			self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
		end
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
	else
		if self.Spark then
			self.Spark:Hide()
		end

		local alpha = self:GetAlpha() - 0.02
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
	self:SetAlpha(1)

	if self.Spark then
		self.Spark:Show()
	end

	local color = K.Colors.castbar.CastingColor
	if (C["Unitframe"].CastClassColor) and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and K.Colors.class[Class]
		if t then
			color = K.Colors.class[Class]
		end
	elseif (C["Unitframe"].CastReactionColor) then
		local Reaction = UnitReaction(unit, 'player')
		local t = Reaction and K.Colors.reaction[Reaction]
		if t then
			color = K.Colors.reaction[Reaction]
		end
	end
	self:SetStatusBarColor(color[1], color[2], color[3])

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
			numTicks = C.ChannelingTicks[self.spellID] or 0
		end
		updateCastBarTicks(self, numTicks)
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		color = K.Colors.castbar.notInterruptibleColor
		self:SetStatusBarColor(color[1], color[2], color[3])
	end
end

function Module:PostUpdateInterruptible(unit)
	local color = K.Colors.castbar.CastingColor
	if not UnitIsUnit(unit, "player") and self.notInterruptible then
		color = K.Colors.castbar.notInterruptibleColor
	end
	self:SetStatusBarColor(color[1], color[2], color[3])
end

function Module:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(K.Colors.castbar.CompleteColor[1], K.Colors.castbar.CompleteColor[2], K.Colors.castbar.CompleteColor[3])
		self.fadeOut = true
	end

	self:Show()
end

function Module:PostCastFailed()
	self:SetStatusBarColor(K.Colors.castbar.FailColor[1], K.Colors.castbar.FailColor[2], K.Colors.castbar.FailColor[3])
	self:SetValue(self.max)
	self.fadeOut = true
	self:Show()
end

function Module.auraIconSize(w, n, s)
	return (w - (n - 1) * s) / n
end

function Module:UpdateAuraContainer(width, element, maxAuras)
	local iconsPerRow = element.iconsPerRow
	local maxLines = iconsPerRow and K.Round(maxAuras / iconsPerRow) or 2
	element.size = iconsPerRow and Module.auraIconSize(width, iconsPerRow, element.spacing) or element.size
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
end

function Module.PostCreateAura(element, button)
	local fontSize = element.fontSize or element.size * 0.52
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
	button.count = K.CreateFontString(parentFrame, fontSize - 1, "", "OUTLINE", false, "BOTTOMRIGHT", 6, -3)
	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetHideCountdownNumbers(true)
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(K.TexCoords))
	button.cd:ClearAllPoints()

	if element.__owner.mystyle == "nameplate" then
		button.cd:SetAllPoints()
		button:CreateShadow(true)
	else
		button.cd:SetPoint("TOPLEFT", 1, -1)
		button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
		button:CreateBorder()
	end

	button.overlay:SetTexture(nil)
	button.stealable:SetParent(parentFrame)
	button.stealable:SetAtlas("bags-newitem")
	button:HookScript("OnMouseDown", AuraModule.RemoveSpellFromIgnoreList)

	button.timer = K.CreateFontString(parentFrame, fontSize, "", "OUTLINE")
end

local filteredStyle = {
	["arena"] = true,
	["boss"] = true,
	["nameplate"] = true,
	["target"] = true,
}

function Module.PostUpdateAura(element, _, button, _, _, duration, expiration, debuffType)
	local style = element.__owner.mystyle
	if style == "nameplate" then
		button:SetSize(element.size, element.size - 4)
	else
		button:SetSize(element.size, element.size)
	end

	if button.isDebuff and filteredStyle[style] and not button.isPlayer then
		button.icon:SetDesaturated(true)
	else
		button.icon:SetDesaturated(false)
	end

	if button.isDebuff then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		if style == "nameplate" and button.Shadow then
			button.Shadow:SetBackdropBorderColor(color[1], color[2], color[3], 0.8)
		else
			if C["General"].ColorTextures then
				button.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				button.KKUI_Border:SetVertexColor(color[1], color[2], color[3])
			end
		end
	else
		if style == "nameplate" and button.Shadow then
			button.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		elseif C["General"].ColorTextures then
			button.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
		else
			button.KKUI_Border:SetVertexColor(1, 1, 1)
		end
	end

	if duration and duration > 0 then
		button.expiration = expiration
		button:SetScript("OnUpdate", K.CooldownOnUpdate)
		button.timer:Show()
	else
		button:SetScript("OnUpdate", nil)
		button.timer:Hide()
	end
end

function Module.bolsterPreUpdate(element)
	element.bolster = 0
	element.bolsterIndex = nil
end

function Module.bolsterPostUpdate(element)
	if not element.bolsterIndex then
		return
	end

	for _, button in pairs(element) do
		if button == element.bolsterIndex then
			button.count:SetText(element.bolster)
			return
		end
	end
end

function Module.CustomFilter(element, unit, button, name, _, _, _, _, _, caster, isStealable, _, spellID, _, _, _, nameplateShowAll)
	local style = element.__owner.mystyle
	if name and spellID == 209859 then
		if style == "nameplate" or style == "target" then
			element.bolster = element.bolster + 1
			if not element.bolsterIndex then
				element.bolsterIndex = button
				return true
			end
		end
	elseif style == "nameplate" or style == "boss" or style == "arena" then
		if element.__owner.isNameOnly then
			return C.NameplateWhiteList[spellID]
		elseif C.NameplateBlackList[spellID] then
			return false
		elseif element.showStealableBuffs and isStealable and not UnitIsPlayer(unit) then
			return true
		elseif C.NameplateWhiteList[spellID] then
			return true
		else
			local auraFilter = C["Nameplate"].AuraFilter.Value
			return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and (caster == "player" or caster == "pet" or caster == "vehicle"))
		end
	elseif (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name) then
		return true
	end
end

-- Post Update Runes
local function OnUpdateRunes(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)

	if self.timer then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(K.FormatTime(remain))
		else
			self.timer:SetText(nil)
		end
	end
end

function Module.PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				if rune.timer then
					rune.timer:SetText(nil)
				end
			elseif start then
				rune:SetAlpha(0.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", OnUpdateRunes)
			end
		end
	end
end

function Module.PostUpdateClassPower(element, cur, max, diff, powerType, chargedPowerPoints)
	if not cur or cur == 0 then
		element.prevColor = nil
	else
		element.thisColor = cur == max and 1 or 2
		if not element.prevColor or element.prevColor ~= element.thisColor then
			local r, g, b = 1, 0, 0
			if element.thisColor == 2 then
				local color = element.__owner.colors.power[powerType]
				r, g, b = color[1], color[2], color[3]
			end
			for i = 1, #element do
				element[i]:SetStatusBarColor(r, g, b)
			end
			element.prevColor = element.thisColor
		end
	end

	if diff then
		for i = 1, max do
			element[i]:SetWidth((Module.barWidth - (max - 1) * 6) / max)
		end
	end

	for i = 1, 6 do
		local bar = element[i]
		if not bar.chargeStar then
			break
		end

		bar.chargeStar:SetShown(chargedPowerPoints and tContains(chargedPowerPoints, i))
	end
end

function Module:CreateClassPower(self)
	if self.mystyle == "PlayerPlate" then
		Module.barWidth = C["Nameplate"].NameplateClassPower and C["Nameplate"].PlateWidth or C["Nameplate"].PPIconSize * 5 + 2 * 4
		Module.barHeight = C["Nameplate"].NameplateClassPower and C["Nameplate"].PlateHeight or C["Nameplate"].PPHeight
		Module.ClassPowerBarPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, 3}
	end

	local bar = CreateFrame("Frame", "oUF_ClassPowerBar", self.Health)
	bar:SetSize(Module.barWidth, Module.barHeight)
	bar:SetPoint(unpack(Module.ClassPowerBarPoint))

	local bars = {}
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, bar)
		bars[i]:SetHeight(Module.barHeight)
		bars[i]:SetWidth((Module.barWidth - 5 * 6) / 6)
		bars[i]:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
		bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)
		if self.mystyle == "nameplate" or self.mystyle == "PlayerPlate" then
			bars[i]:CreateShadow(true)
		else
			bars[i]:CreateBorder()
		end

		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i - 1], "RIGHT", 6, 0)
		end

		if K.Class == "DEATHKNIGHT" then
			bars[i].timer = K.CreateFontString(bars[i], 10, "")
		elseif K.Class == "ROGUE" then
			local chargeStar = bars[i]:CreateTexture()
			chargeStar:SetAtlas("VignetteKill")
			chargeStar:SetDesaturated(true)
			chargeStar:SetSize(22, 22)
			chargeStar:SetPoint("CENTER")
			chargeStar:Hide()
			bars[i].chargeStar = chargeStar
		end
	end

	if K.Class == "DEATHKNIGHT" then
		bars.colorSpec = true
		bars.sortOrder = "asc"
		bars.PostUpdate = Module.PostUpdateRunes
		bars.__max = 6
		self.Runes = bars
	else
		bars.PostUpdate = Module.PostUpdateClassPower
		self.ClassPower = bars
	end
end

local textScaleFrames = {
	["player"] = true,
	["target"] = true,
	-- These will be enabled once we finish the sizing elements for them
	-- ["focus"] = true,
	-- ["pet"] = true,
	-- ["tot"] = true,
	-- ["focustarget"] = true,
	-- ["boss"] = true,
	-- ["arena"] = true,
}

function Module:UpdateTextScale()
	local scale = C["Unitframe"].AllTextScale
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			if frame.Name then
				frame.Name:SetScale(scale)
			end

			if frame.Level then
				frame.Level:SetScale(scale)
			end

			frame.Health.Value:SetScale(scale)

			if frame.Power.Value then
				frame.Power.Value:SetScale(scale)
			end

			local castbar = frame.Castbar
			if castbar then
				castbar.Text:SetScale(scale)
				castbar.Time:SetScale(scale)
				if castbar.Lag then
					castbar.Lag:SetScale(scale)
				end
			end
		end
	end
end

function Module:CreateUnits()
	local horizonRaid = C["Raid"].HorizonRaid
	local numGroups = C["Raid"].NumGroups
	local raidWidth, raidHeight = C["Raid"].Width, C["Raid"].Height
	local reverse = C["Raid"].ReverseRaid
	local showPartyFrame = C["Party"].Enable
	local showTeamIndex = C["Raid"].ShowTeamIndex

	if C["Nameplate"].Enable then
		Module:PlateCVarReset()
		Module:SetupCVars()
		Module:BlockAddons()
		Module:CreateUnitTable()
		Module:CreatePowerUnitTable()
		Module:CheckExplosives()
		Module:AddInterruptInfo()
		Module:UpdateGroupRoles()
		Module:QuestIconCheck()
		Module:RefreshPlateOnFactionChanged()

		oUF:RegisterStyle("Nameplates", Module.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", Module.PostUpdatePlates)
	end

	if C["Nameplate"].ShowPlayerPlate then
		oUF:RegisterStyle("PlayerPlate", Module.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		K.Mover(plate, "PlayerNP", "PlayerPlate", {"BOTTOM", UIParent, "BOTTOM", 0, 300}, plate:GetWidth(), plate:GetHeight())
	end

	if C["Unitframe"].Enable then
		oUF:RegisterStyle("Player", Module.CreatePlayer)
		oUF:RegisterStyle("Target", Module.CreateTarget)
		oUF:RegisterStyle("ToT", Module.CreateTargetOfTarget)
		oUF:RegisterStyle("Focus", Module.CreateFocus)
		oUF:RegisterStyle("FocusTarget", Module.CreateFocusTarget)
		oUF:RegisterStyle("Pet", Module.CreatePet)

		oUF:SetActiveStyle("Player")
		local Player = oUF:Spawn("player", "oUF_Player")
		local PlayerFrameHeight = C["Unitframe"].PlayerHealthHeight + C["Unitframe"].PlayerPowerHeight + 6
		local PlayerFrameWidth = C["Unitframe"].PlayerHealthWidth
		Player:SetSize(PlayerFrameWidth, PlayerFrameHeight)
		K.Mover(Player, "PlayerUF", "PlayerUF", {"BOTTOM", UIParent, "BOTTOM", -250, 320}, PlayerFrameWidth, PlayerFrameHeight)

		oUF:SetActiveStyle("Target")
		local Target = oUF:Spawn("target", "oUF_Target")
		local TargetFrameHeight = C["Unitframe"].TargetHealthHeight + C["Unitframe"].TargetPowerHeight + 6
		local TargetFrameWidth = C["Unitframe"].TargetHealthWidth
		Target:SetSize(TargetFrameWidth, TargetFrameHeight)
		K.Mover(Target, "TargetUF", "TargetUF", {"BOTTOM", UIParent, "BOTTOM", 250, 320}, TargetFrameWidth, TargetFrameHeight)

		if not C["Unitframe"].HideTargetofTarget then
			oUF:SetActiveStyle("ToT")
			local TargetOfTarget = oUF:Spawn("targettarget", "oUF_ToT")
			local TargetOfTargetFrameHeight = C["Unitframe"].TargetTargetHealthHeight + C["Unitframe"].TargetTargetPowerHeight + 6
			local TargetOfTargetFrameWidth = C["Unitframe"].TargetTargetHealthWidth
			TargetOfTarget:SetSize(TargetOfTargetFrameWidth, TargetOfTargetFrameHeight)
			K.Mover(TargetOfTarget, "TotUF", "TotUF", {"TOPLEFT", Target, "BOTTOMRIGHT", 6, -6}, TargetOfTargetFrameWidth, TargetOfTargetFrameHeight)
		end

		oUF:SetActiveStyle("Pet")
		local Pet = oUF:Spawn("pet", "oUF_Pet")
		if C["Unitframe"].CombatFade and Player and not InCombatLockdown() then
			Pet:SetParent(Player)
		end
		local PetFrameHeight = C["Unitframe"].PetHealthHeight + C["Unitframe"].PetPowerHeight + 6
		local PetFrameWidth = C["Unitframe"].PetHealthWidth
		Pet:SetSize(PetFrameWidth, PetFrameHeight)
		K.Mover(Pet, "Pet", "Pet", {"TOPRIGHT", Player, "BOTTOMLEFT", -6, -6}, PetFrameWidth, PetFrameHeight)

		oUF:SetActiveStyle("Focus")
		local Focus = oUF:Spawn("focus", "oUF_Focus")
		local FocusFrameHeight = C["Unitframe"].FocusHealthHeight + C["Unitframe"].FocusPowerHeight + 6
		local FocusFrameWidth = C["Unitframe"].FocusHealthWidth
		Focus:SetSize(FocusFrameWidth, FocusFrameHeight)
		K.Mover(Focus, "FocusUF", "FocusUF", {"BOTTOMRIGHT", Player, "TOPLEFT", -60, 30}, FocusFrameWidth, FocusFrameHeight)

		if not C["Unitframe"].HideTargetofTarget then
			oUF:SetActiveStyle("FocusTarget")
			local FocusTarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
			local FocusTargetFrameHeight = C["Unitframe"].FocusTargetHealthHeight + C["Unitframe"].FocusTargetPowerHeight + 6
			local FoucsTargetFrameWidth = C["Unitframe"].FocusTargetHealthWidth
			FocusTarget:SetSize(FoucsTargetFrameWidth, FocusTargetFrameHeight)
			K.Mover(FocusTarget, "FocusTarget", "FocusTarget", {"TOPLEFT", Focus, "BOTTOMRIGHT", 6, -6}, FoucsTargetFrameWidth, FocusTargetFrameHeight)
		end

		K.HideInterfaceOption(InterfaceOptionsCombatPanelTargetOfTarget)
		K:RegisterEvent("PLAYER_TARGET_CHANGED", Module.PLAYER_TARGET_CHANGED)
		K:RegisterEvent("PLAYER_FOCUS_CHANGED", Module.PLAYER_FOCUS_CHANGED)
		K:RegisterEvent("UNIT_FACTION", Module.UNIT_FACTION)

		Module:UpdateTextScale()
	end

	if C["Boss"].Enable then
		oUF:RegisterStyle("Boss", Module.CreateBoss)
		oUF:SetActiveStyle("Boss")

		local Boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			Boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
			Boss[i]:SetSize(C["Boss"].HealthWidth, C["Boss"].HealthHeight + C["Boss"].PowerHeight + 6)

			local bossMoverWidth, bossMoverHeight = C["Boss"].HealthWidth, C["Boss"].HealthHeight + C["Boss"].PowerHeight + 6
			if i == 1 then
				Boss[i].mover = K.Mover(Boss[i], "BossFrame"..i, "Boss1", {"BOTTOMRIGHT", UIParent, "RIGHT", -250, 140}, bossMoverWidth, bossMoverHeight)
			else
				Boss[i].mover = K.Mover(Boss[i], "BossFrame"..i, "Boss"..i, {"TOPLEFT", Boss[i - 1], "BOTTOMLEFT", 0, -C["Boss"].YOffset}, bossMoverWidth, bossMoverHeight)
			end
		end
	end

	if C["Arena"].Enable then
		oUF:RegisterStyle("Arena", Module.CreateArena)
		oUF:SetActiveStyle("Arena")

		local Arena = {}
		for i = 1, 5 do
			Arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
			Arena[i]:SetSize(C["Arena"].HealthWidth, C["Arena"].HealthHeight + C["Arena"].PowerHeight + 6)

			local arenaMoverWidth, arenaMoverHeight = C["Arena"].HealthWidth, C["Arena"].HealthHeight + C["Arena"].PowerHeight + 6
			if i == 1 then
				Arena[i].mover = K.Mover(Arena[i], "ArenaFrame"..i, "Arena1", {"BOTTOMRIGHT", UIParent, "RIGHT", -250, 140}, arenaMoverWidth, arenaMoverHeight)
			else
				Arena[i].mover = K.Mover(Arena[i], "ArenaFrame"..i, "Arena"..i, {"TOPLEFT", Arena[i - 1], "BOTTOMLEFT", 0, -C["Arena"].YOffset}, arenaMoverWidth, arenaMoverHeight)
			end
		end

		SetCVar("showArenaEnemyFrames", 0) -- Why these still load and show is dumb.
	end

	local partyMover
	if showPartyFrame then
		oUF:RegisterStyle("Party", Module.CreateParty)
		oUF:SetActiveStyle("Party")

		local partyXOffset, partyYOffset = 6, C["Party"].ShowBuffs and 54 or 18
		local partyMoverWidth = C["Party"].HealthWidth
		local partyMoverHeight = C["Party"].HealthHeight * 5 + partyYOffset * 4
		local partyGroupingOrder = "NONE,DAMAGER,HEALER,TANK"

		local party = oUF:SpawnHeader("oUF_Party", nil, "solo,party",
		"showPlayer", C["Party"].ShowPlayer,
		"showSolo", C["Party"].ShowPartySolo,
		"showParty", true,
		"showRaid", false,
		"xoffset", partyXOffset,
		"yOffset", partyYOffset,
		"groupFilter", "1",
		"groupingOrder", partyGroupingOrder,
		"groupBy", "ASSIGNEDROLE",
		"sortMethod", "NAME",
		"point", "BOTTOM",
		"columnAnchorPoint", "LEFT",
		"oUF-initialConfigFunction", ([[
		self:SetWidth(%d)
		self:SetHeight(%d)
		]]):format(C["Party"].HealthWidth, C["Party"].HealthHeight + C["Party"].PowerHeight + 6))

		partyMover = K.Mover(party, "PartyFrame", "PartyFrame", {"TOPLEFT", UIParent, "TOPLEFT", 46, -180}, partyMoverWidth, partyMoverHeight)
		party:ClearAllPoints()
		party:SetPoint("TOPLEFT", partyMover)

		if C["Party"].ShowPet then
			oUF:RegisterStyle("PartyPet", Module.CreatePartyPet)
			oUF:SetActiveStyle("PartyPet")

			local partypetXOffset, partypetYOffset = 6, 25
			local partpetMoverWidth = 60
			local partpetMoverHeight = 34 * 5 + partypetYOffset * 4

			local partyPet = oUF:SpawnHeader("oUF_PartyPet", nil, "solo,party",
			"showPlayer", true,
			"showSolo", false,
			"showParty", true,
			"showRaid", false,
			"xoffset", partypetXOffset,
			"yOffset", partypetYOffset,
			"point", "BOTTOM",
			"columnAnchorPoint", "LEFT",
			"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
			self:SetAttribute("unitsuffix", "pet")
			]]):format(60, 34))

			local moverAnchor = {"TOPLEFT", partyMover, "TOPRIGHT", 6, -40}
			local petMover = K.Mover(partyPet, "PartyPetFrame", "PartyPetFrame", moverAnchor, partpetMoverWidth, partpetMoverHeight)
			partyPet:ClearAllPoints()
			partyPet:SetPoint("TOPLEFT", petMover)
		end
	end

	if C["Raid"].Enable then
		oUF:RegisterStyle("Raid", Module.CreateRaid)
		oUF:SetActiveStyle("Raid")

		-- Hide Default RaidFrame
		if CompactRaidFrameManager_SetSetting then
			CompactRaidFrameManager_SetSetting("IsShown", "0")
			UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
			CompactRaidFrameManager:UnregisterAllEvents()
			CompactRaidFrameManager:SetParent(K.UIFrameHider)
		end

		local raidMover
		local function CreateGroup(name, i)
			local group = oUF:SpawnHeader(name, nil, "solo,party,raid",
			"showPlayer", true,
			"showSolo", not showPartyFrame and C["Raid"].ShowRaidSolo,
			"showParty", not showPartyFrame,
			"showRaid", true,
			"xoffset", 6,
			"yOffset", -6,
			"groupFilter", tostring(i),
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"sortMethod", "INDEX",
			"maxColumns", 1,
			"unitsPerColumn", 5,
			"columnSpacing", 5,
			"point", horizonRaid and "LEFT" or "TOP",
			"columnAnchworPoint", "LEFT",
			"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
			]]):format(raidWidth, raidHeight))

			return group
		end

		local function CreateTeamIndex(header)
			local parent = _G[header:GetName().."UnitButton1"]
			if parent and not parent.teamIndex then
				local teamIndex = K.CreateFontString(parent, 11, string_format(GROUP_NUMBER, header.index), "")
				teamIndex:ClearAllPoints()
				teamIndex:SetPoint("BOTTOM", parent, "TOP", 0, 3)
				teamIndex:SetTextColor(255/255, 204/255, 102/255)

				parent.teamIndex = teamIndex
			end
		end

		local groups = {}
		for i = 1, numGroups do
			groups[i] = CreateGroup("oUF_Raid"..i, i)
			groups[i].index = i

			if i == 1 then
				if horizonRaid then
					raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", {"TOPLEFT", UIParent, "TOPLEFT", 4, -180}, (raidWidth + 5) * 5, (raidHeight + (showTeamIndex and 21 or 15)) * numGroups)
					if reverse then
						groups[i]:ClearAllPoints()
						groups[i]:SetPoint("BOTTOMLEFT", raidMover)
					end
				else
					raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", {"TOPLEFT", UIParent, "TOPLEFT", 4, -180}, (raidWidth + 5) * numGroups, (raidHeight + 10) * 5)
					if reverse then
						groups[i]:ClearAllPoints()
						groups[i]:SetPoint("TOPRIGHT", raidMover)
					end
				end
			else
				if horizonRaid then
					if reverse then
						groups[i]:SetPoint("BOTTOMLEFT", groups[i-1], "TOPLEFT", 0, showTeamIndex and 21 or 15)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i-1], "BOTTOMLEFT", 0, showTeamIndex and -21 or -15)
					end
				else
					if reverse then
						groups[i]:SetPoint("TOPRIGHT", groups[i-1], "TOPLEFT", -6, 0)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i-1], "TOPRIGHT", 6, 0)
					end
				end
			end

			if showTeamIndex then
				CreateTeamIndex(groups[i])
				groups[i]:HookScript("OnShow", CreateTeamIndex)
			end
		end

		if C["Raid"].SpecRaidPos then
			local function UpdateSpecPos(event, ...)
				local unit, _, spellID = ...
				if (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and spellID == 200749) or event == "ON_LOGIN" then
					local specIndex = GetSpecialization()
					if not specIndex then
						return
					end

					if not KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidPos"..specIndex] then
						KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidPos"..specIndex] = {"TOPLEFT", "UIParent", "TOPLEFT", 4, -180}
					end

					if raidMover then
						raidMover:ClearAllPoints()
						raidMover:SetPoint(unpack(KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidPos"..specIndex]))
					end

					if not KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["PartyPos"..specIndex] then
						KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["PartyPos"..specIndex] = {"TOPLEFT", "UIParent", "TOPLEFT", 4, -180}
					end

					if partyMover then
						partyMover:ClearAllPoints()
						partyMover:SetPoint(unpack(KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["PartyPos"..specIndex]))
					end
				end
			end
			UpdateSpecPos("ON_LOGIN")
			K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateSpecPos)

			if raidMover then
				raidMover:HookScript("OnDragStop", function()
					local specIndex = GetSpecialization()
					if not specIndex then
						return
					end

					KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidPos"..specIndex] = KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidFrame"]
				end)
			end

			if partyMover then
				partyMover:HookScript("OnDragStop", function()
					local specIndex = GetSpecialization()
					if not specIndex then
						return
					end

					KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["PartyPos"..specIndex] = KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["PartyFrame"]
				end)
			end
		end

		-- if raidMover then
		-- 	if not C["Raid"].SpecRaidPos then
		-- 		return
		-- 	end

		-- 	local function UpdateSpecPos(event, ...)
		-- 		local unit, _, spellID = ...
		-- 		if (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and spellID == 200749) or event == "PLAYER_ENTERING_WORLD" then
		-- 			if not GetSpecialization() then
		-- 				return
		-- 			end

		-- 			local specIndex = GetSpecialization()
		-- 			if not KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidPos"..specIndex] then
		-- 				KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidPos"..specIndex] = {"TOPLEFT", UIParent, "TOPLEFT", 4, -180}
		-- 			end

		-- 			raidMover:ClearAllPoints()
		-- 			raidMover:SetPoint(unpack(KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidPos"..specIndex]))
		-- 		end
		-- 	end
		-- 	K:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateSpecPos)
		-- 	K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateSpecPos)

		-- 	raidMover:HookScript("OnDragStop", function()
		-- 		if not GetSpecialization() then
		-- 			return
		-- 		end

		-- 		local specIndex = GetSpecialization()
		-- 		KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidPos"..specIndex] = KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"]["RaidFrame"]
		-- 	end)
		-- end

		if C["Raid"].MainTankFrames then
			oUF:RegisterStyle("MainTank", Module.CreateRaid)
			oUF:SetActiveStyle("MainTank")

			local horizonTankRaid = C["Raid"].HorizonRaid
			local raidTankWidth, raidTankHeight = C["Raid"].Width, C["Raid"].Height

			local raidtank = oUF:SpawnHeader("oUF_MainTank", nil, "raid",
			"showRaid", true,
			"xoffset", 6,
			"yOffset", -6,
			"groupFilter", "MAINTANK",
			"point", horizonTankRaid and "LEFT" or "TOP",
			"columnAnchworPoint", "LEFT",
			"template", C["Raid"].MainTankFrames and "oUF_MainTankTT" or "oUF_MainTank",
			"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
			]]):format(raidTankWidth, raidTankHeight))

			local raidtankMover = K.Mover(raidtank, "MainTankFrame", "MainTankFrame", {"TOPLEFT", UIParent, "TOPLEFT", 4, -50}, raidTankWidth, raidTankHeight)
			raidtank:ClearAllPoints()
			raidtank:SetPoint("TOPLEFT", raidtankMover)
		end
	end
end

function Module:UpdateRaidDebuffIndicator()
	local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs

	if (ORD) then
		local _, InstanceType = IsInInstance()

		ORD:ResetDebuffData()

		if (InstanceType == "party" or InstanceType == "raid") then
			if C["Raid"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C.DebuffsTracking_PvE.spells)
			end

			ORD:RegisterDebuffs(KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvE)
		else
			if C["Raid"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C.DebuffsTracking_PvP.spells)
			end

			ORD:RegisterDebuffs(KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvP)
		end
	end
end

local function CreateTargetSound(_, unit)
	if UnitExists(unit) and not IsReplacingUnit() then
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
function Module:UNIT_FACTION(unit)
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
	Module.ClassPowerBarSize = {C["Unitframe"].PlayerHealthWidth, 14}
	Module.ClassPowerBarPoint = {"TOPLEFT", 0, 20}
	Module.barWidth, Module.barHeight = unpack(Module.ClassPowerBarSize)

	-- Register our units / layout
	self:CreateUnits()

	if (C["Raid"].DebuffWatch) then
		local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs
		local RaidDebuffs = CreateFrame("Frame")

		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", Module.UpdateRaidDebuffIndicator)

		if (ORD) then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end

		self:CreateTracking()
	end
end