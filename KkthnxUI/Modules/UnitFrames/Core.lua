local K, C = unpack(select(2, ...))
local Module = K:NewModule("Unitframes")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G

local pairs = _G.pairs
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_match = _G.string.match
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local unpack = _G.unpack

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumSubgroupMembers = _G.GetNumSubgroupMembers
local GetRealmName = _G.GetRealmName
local GetRuneCooldown = _G.GetRuneCooldown
local GetSpecialization = _G.GetSpecialization
local GetThreatStatusColor = _G.GetThreatStatusColor
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local MAX_ARENA_ENEMIES = _G.MAX_ARENA_ENEMIES
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES
local PlaySound = _G.PlaySound
local SOUNDKIT = _G.SOUNDKIT
local SetCVar = _G.SetCVar
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local UnitChannelInfo = _G.UnitChannelInfo
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
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
local UnitName = _G.UnitName
local UnitReaction = _G.UnitReaction
local UnitThreatSituation = _G.UnitThreatSituation
local hooksecurefunc = _G.hooksecurefunc
local oUF_RaidDebuffs = _G.oUF_RaidDebuffs

Module.Headers = {}
Module.Units = {}
Module.ticks = {}
Module.groupRoles = {}

local isInGroup
local isInInstance

local classify = {
	rare = {1, 1, 1, true},
	elite = {1, 1, 1},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
}

Module.CustomAuraFilter = {
	Blacklist = function(_, _, _, _, _, _, _, _, _, _, _, _, spellID)
		-- Don't allow blacklisted auras
		if (not K.AuraBlackList[spellID]) then
			return true
		end
	end,
}

function Module:UpdateClassPortraits(unit)
	if not unit then
		return
	end

	local _, unitClass = UnitClass(unit)
	if unitClass then
		local PortraitValue = C["General"].PortraitStyle.Value
		local ClassTCoords = CLASS_ICON_TCOORDS[unitClass]

		local defaultCPs = "ClassPortraits"
		local newCPs = "NewClassPortraits"

		for _, value in pairs({
			PortraitValue,
		}) do
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
		self:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\ObjectiveWidget")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module:UpdateThreat(_, unit)
	if (unit ~= self.unit) then
		return
	end

	local Status = UnitThreatSituation(unit)
	if C["General"].PortraitStyle.Value == "ThreeDPortraits" then
		if not self.Portrait then
			return
		end

		if (Status and Status > 0) then
			local r, g, b = GetThreatStatusColor(Status)
			self.Portrait:SetBackdropBorderColor(r, g, b)
		else
			self.Portrait:SetBackdropBorderColor()
		end
	elseif C["General"].PortraitStyle.Value ~= "ThreeDPortraits" then
		if not self.Portrait.Border then
			return
		end

		if (Status and Status > 0) then
			local r, g, b = GetThreatStatusColor(Status)
			self.Portrait.Border:SetBackdropBorderColor(r, g, b)
		else
			self.Portrait.Border:SetBackdropBorderColor()
		end
	end
end

function Module:UpdateHealth(unit, cur, max)
	if C["General"].PortraitStyle.Value == "ThreeDPortraits" then
		return
	end

	local parent = self.__owner
	Module.UpdatePortraitColor(parent, unit, cur, max)
end

local PhaseIconTexCoords = {
	[1] = {1 / 128, 33 / 128, 1 / 64, 33 / 64},
	[2] = {34 / 128, 66 / 128, 1 / 64, 33 / 64},
}

function Module:UpdatePhaseIcon(isInSamePhase)
	if not isInSamePhase then
		self:SetTexCoord(unpack(PhaseIconTexCoords[UnitIsWarModePhased(self.__owner.unit) and 2 or 1]))
	end
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

function Module:UpdateUnitClassify(unit)
	local class = _G.UnitClassification(unit)
	if self.creatureIcon then
		if class and classify[class] then
			local r, g, b, desature = unpack(classify[class])
			self.creatureIcon:SetVertexColor(r, g, b)
			self.creatureIcon:SetDesaturated(desature)
			self.creatureIcon:Show()
		else
			self.creatureIcon:Hide()
		end
	end
end

-- Quest progress
local function refreshGroupRoles()
	local isInRaid = IsInRaid()
	isInGroup = isInRaid or IsInGroup()
	table_wipe(Module.groupRoles)

	if isInGroup then
		local numPlayers = (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()
		local unit = (isInRaid and "raid") or "party"
		for i = 1, numPlayers do
			local index = unit..i
			if UnitExists(index) then
				Module.groupRoles[UnitName(index)] = UnitGroupRolesAssigned(index)
			end
		end
	end
end

local function resetGroupRoles()
	isInGroup = IsInRaid() or IsInGroup()
	table_wipe(Module.groupRoles)
end

function Module:UpdateGroupRoles()
	refreshGroupRoles()
	K:RegisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	K:RegisterEvent("GROUP_LEFT", resetGroupRoles)
end

local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function Module:QuestIconCheck()
	if not C["Nameplates"].QuestInfo then
		return
	end

	CheckInstanceStatus()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

function Module:UpdateQuestUnit(_, unit)
	if not C["Nameplates"].QuestInfo then
		return
	end

	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local isLootQuest, questProgress
	K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetUnit(unit)

	for i = 2, K.ScanTooltip:NumLines() do
		local textLine = _G[K.ScanTooltip:GetName().."TextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			if r > .99 and g > .82 and b == 0 then
				if isInGroup and text == K.Name or not isInGroup then
					isLootQuest = true

					local questLine = _G[K.ScanTooltip:GetName().."TextLeft"..(i + 1)]
					local questText = questLine:GetText()
					if questLine and questText then
						local current, goal = string_match(questText, "(%d+)/(%d+)")
						local progress = string_match(questText, "([%d%.]+)%%")
						if current and goal then
							current = tonumber(current)
							goal = tonumber(goal)
							if current == goal then
								isLootQuest = nil
							elseif current < goal then
								questProgress = goal - current
								break
							end
						elseif progress then
							progress = tonumber(progress)
							if progress == 100 then
								isLootQuest = nil
							elseif progress < 100 then
								questProgress = progress.."%"
								break
							end
						end
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
		self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
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
	self:SetAlpha(1)
	self.Spark:Show()

	local colors = K.Colors.castbar
	local r, g, b = unpack(self.casting and colors.CastingColor or colors.ChannelingColor)

	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and K.Colors.class[Class]
		if t then r, g, b = t[1], t[2], t[3] end
	elseif C["Unitframe"].CastReactionColor then
		local Reaction = UnitReaction(unit, "player")
		local t = Reaction and K.Colors.reaction[Reaction]
		if t then r, g, b = t[1], t[2], t[3] end
	end

	self:SetStatusBarColor(r, g, b)

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
			numTicks = K.ChannelingTicks[spellID] or 0
		end
		updateCastBarTicks(self, numTicks)
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		self:SetStatusBarColor(unpack(K.Colors.castbar.notInterruptibleColor))
	end
end

function Module:PostUpdateInterruptible(unit)
	if unit == "vehicle" or unit == "player" then
		return
	end

	local colors = K.Colors.castbar
	local r, g, b = unpack(self.casting and colors.CastingColor or colors.ChannelingColor)

	if self.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = colors.notInterruptibleColor[1], colors.notInterruptibleColor[2], colors.notInterruptibleColor[3]
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
			self.TimeLeft = self.TimeLeft - self.Elapsed

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

function Module:CancelPlayerBuff()
	if InCombatLockdown() then
		return
	end

	CancelUnitBuff("player", self.index)
end

function Module:PostCreateAura(button)
	-- Set "self.Buffs.isCancellable" to true to a buffs frame to be able to cancel click
	local isCancellable = button:GetParent().isCancellable
	local fontSize = button:GetParent().fontSize or button:GetParent().size * 0.45

	if string_match(button:GetName(), "NamePlate") and C["Nameplates"].Enable then
		-- Skin aura button
		button:CreateShadow(true)
		button:CreateInnerShadow()
		button.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

		button.Remaining = button:CreateFontString(nil, "OVERLAY")
		button.Remaining:SetFontObject(K.GetFont(C["UIFonts"].NameplateFonts))
		button.Remaining:SetFont(select(1, button.Remaining:GetFont()), fontSize, "OUTLINE")
		button.Remaining:SetShadowOffset(0, 0)
		button.Remaining:SetPoint("CENTER", 1, 0)

		button.cd.noOCC = true
		button.cd.noCooldownCount = true
		button.cd:SetReverse(true)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT")
		button.cd:SetPoint("BOTTOMRIGHT")
		button.cd:SetHideCountdownNumbers(true)

		button.icon:SetAllPoints()
		button.icon:SetTexCoord(unpack(K.TexCoords))
		button.icon:SetDrawLayer("ARTWORK")

		button.count:SetPoint("BOTTOMRIGHT", 3, 0)
		button.count:SetJustifyH("RIGHT")
		button.count:SetFontObject(K.GetFont(C["UIFonts"].NameplateFonts))
		button.count:SetFont(select(1, button.count:GetFont()), fontSize, "OUTLINE")
		button.count:SetShadowOffset(0, 0)
	else
		-- Right-click-cancel script
		if isCancellable then
			-- Add a button.index to allow CancelUnitAura to work with player
			local Name = button:GetName()
			local Index = tonumber(Name:gsub("%D", ""))

			button.index = Index
			button:SetScript("OnMouseUp", Module.CancelPlayerBuff)
		end

		-- Skin aura button
		button:CreateBorder()
		button:CreateInnerShadow()
		button:SetBackdropBorderColor()

		button.Remaining = button:CreateFontString(nil, "OVERLAY")
		button.Remaining:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		button.Remaining:SetFont(select(1, button.Remaining:GetFont()), fontSize, "OUTLINE")
		button.Remaining:SetShadowOffset(0, 0)
		button.Remaining:SetPoint("CENTER", 1, 0)

		button.cd.noOCC = true
		button.cd.noCooldownCount = true
		button.cd:SetReverse(true)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", 1, -1)
		button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
		button.cd:SetHideCountdownNumbers(true)

		button.icon:SetAllPoints()
		button.icon:SetTexCoord(unpack(K.TexCoords))
		button.icon:SetDrawLayer("ARTWORK")

		button.count:SetPoint("BOTTOMRIGHT", 3, 0)
		button.count:SetJustifyH("RIGHT")
		button.count:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		button.count:SetFont(select(1, button.count:GetFont()), fontSize, "OUTLINE")
		button.count:SetShadowOffset(0, 0)
	end

	button.OverlayFrame = CreateFrame("Frame", nil, button, nil)
	button.OverlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
	button.overlay:SetParent(button.OverlayFrame)
	button.count:SetParent(button.OverlayFrame)
	button.Remaining:SetParent(button.OverlayFrame)

	button.Animation = button:CreateAnimationGroup()
	button.Animation:SetLooping("BOUNCE")

	button.Animation.FadeOut = button.Animation:CreateAnimation("Alpha")
	button.Animation.FadeOut:SetFromAlpha(1)
	button.Animation.FadeOut:SetToAlpha(0.3)
	button.Animation.FadeOut:SetDuration(0.3)
	button.Animation.FadeOut:SetSmoothing("IN_OUT")
end

function Module:PostUpdateAura(unit, button, index)
	local _, _, _, DType, Duration, ExpirationTime = UnitAura(unit, index, button.filter)

	if button then
		if (button.filter == "HARMFUL") then
			if (not UnitIsFriend("player", unit) and not button.isPlayer) then
				button.icon:SetDesaturated(true)
				button:SetBackdropBorderColor()

				if string_match(button:GetName(), "NamePlate") and button.Shadow then
					button.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
				end
			else
				local color = DebuffTypeColor[DType] or DebuffTypeColor.none
				button.icon:SetDesaturated(false)
				button:SetBackdropBorderColor(color.r, color.g, color.b)

				if string_match(button:GetName(), "NamePlate") and button.Shadow then
					button.Shadow:SetBackdropBorderColor(color.r * 0.8, color.g * 0.8, color.b * 0.8, 0.8)
				end
			end
		else
			-- These classes can purge, show them
			if (button.Animation) and (K.Class == "PRIEST") or (K.Class == "SHAMAN") then
				if (DType == "Magic") and (not UnitIsFriend("player", unit)) and (not button.Animation.Playing) then
					button.Animation:Play()
					button.Animation.Playing = true
				else
					button.Animation:Stop()
					button.Animation.Playing = false
				end
			end
		end

		if button.Remaining then
			if (Duration and Duration > 0) then
				button.Remaining:Show()
			else
				button.Remaining:Hide()
			end

			button:SetScript("OnUpdate", Module.CreateAuraTimer)
		end

		if (button.cd) then
			if (Duration and Duration > 0) then
				button.cd:SetCooldown(ExpirationTime - Duration, Duration)
				button.cd:Show()
			else
				button.cd:Hide()
			end
		end

		button.Duration = Duration
		button.TimeLeft = ExpirationTime
		button.Elapsed = GetTime()
	end
end

function Module:CreateAuraWatch()
	local auras = CreateFrame("Frame", nil, self)
	auras:SetFrameLevel(self:GetFrameLevel() + 10)
	auras:SetPoint("TOPLEFT", self, 2, -2)
	auras:SetPoint("BOTTOMRIGHT", self, -2, 2)
	auras.presentAlpha = 1
	auras.missingAlpha = 0
	auras.PostCreateIcon = Module.AuraWatchPostCreateIcon
	auras.PostUpdateIcon = Module.AuraWatchPostUpdateIcon

	if (self.unit == "pet") then
		auras.watched = K.BuffsTracking.PET
	else
		auras.watched = K.BuffsTracking[K.Class]
	end

	auras.size = C["Raid"].AuraWatchIconSize

	return auras
end

function Module:AuraWatchPostCreateIcon(button)
	button:CreateShadow(true)

	button.count:FontTemplate()
	button.count:ClearAllPoints()
	button.count:SetPoint("CENTER", button, 2, -1)

	if (button.cd) then
		button.cd:SetAllPoints()
		button.cd:SetReverse(true)
		button.cd.noOCC = true
		button.cd.noCooldownCount = true
		button.cd:SetHideCountdownNumbers(true)
	end
end

function Module:AuraWatchPostUpdateIcon(_, button)
	local Settings = self.watched[button.spellID]
	if (Settings) then -- This should never fail.
		button.icon:SetTexCoord(unpack(K.TexCoords))
		button.icon:SetAllPoints()
		button.icon:SetSnapToPixelGrid(false)
		button.icon:SetTexelSnappingBias(0)
	end
end

function Module.PostUpdateAddPower(element, _, cur, max)
	if element.Text and max > 0 then
		local perc = cur / max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = string_format("%d%%", perc)
			element:SetAlpha(1)
		end

		element.Text:SetText(perc)
	end
end

function Module:PostCreateAuraBar(bar)
	if not bar.isSkinned then
		bar:CreateBorder()
		bar:SetPoint("LEFT")
		bar:SetPoint("RIGHT")

		bar.icon.frame = CreateFrame("Frame", nil, bar)
		bar.icon.frame:SetAllPoints(bar.icon)
		bar.icon.frame:SetFrameLevel(bar:GetFrameLevel())
		bar.icon.frame:CreateBorder()
		bar.icon.frame:CreateInnerShadow()

		bar.timeText:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		bar.nameText:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))

		bar.nameText:SetJustifyH("LEFT")
		bar.nameText:SetJustifyV("MIDDLE")
		bar.nameText:SetPoint("RIGHT", bar.timeText, "LEFT", -4, 0)
		bar.nameText:SetWordWrap(false)

		bar.isSkinned = true
	end
end

-- Class Powers
function Module.PostUpdateClassPower(element, cur, max, diff, powerType)
	if diff then
		for i = 1, max do
			element[i]:SetWidth((156 - (max - 1) * 6) / max)
		end
	end

	if (powerType == "COMBO_POINTS" or powerType == "HOLY_POWER") and element.__owner.unit ~= "vehicle" and cur == max then
		for i = 1, 6 do
			if element[i]:IsShown() then
				-- K.libButtonGlow.ShowOverlayGlow(element[i])
				K.libCustomGlow.AutoCastGlow_Start(element[i])
			end
		end
	else
		for i = 1, 6 do
			-- K.libButtonGlow.HideOverlayGlow(element[i])
			K.libCustomGlow.AutoCastGlow_Stop(element[i])
		end
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

function Module:UpdatePlateClassIcons(unit)
	if C["Nameplates"].ClassIcons then
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			local texcoord = CLASS_ICON_TCOORDS[class]
			self.Class.Icon:SetTexCoord(texcoord[1] + 0.015, texcoord[2] - 0.02, texcoord[3] + 0.018, texcoord[4] - 0.02)
			self.Class:Show()
		else
			self.Class.Icon:SetTexCoord(0, 0, 0, 0)
			self.Class:Hide()
		end
	end
end

function Module:UpdateNameplateTarget()
	local Highlight = self.Highlight

	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		self:SetAlpha(1)

		if Highlight then
			Highlight:Show()
		else
			Highlight:SetBackdropBorderColor(unpack(C["Nameplates"].HighlightColor))
		end
	else
		self:SetAlpha(C["Nameplates"].NonTargetAlpha)

		if Highlight then
			Highlight:Hide()
		else
			Highlight:SetBackdropBorderColor(0, 0, 0, 0.8)
		end
	end
end

function Module:NameplatesCallback(event, unit)
	if not self then
		return
	end

	if event == "NAME_PLATE_UNIT_ADDED" then
		if UnitIsUnit(unit, "player") then
			if self:IsElementEnabled('Castbar') then
				self:DisableElement('Castbar')
			end

			if self:IsElementEnabled("RaidTargetIndicator") then
				self:DisableElement("RaidTargetIndicator")
			end

			if self.Name then
				self.Name:SetAlpha(0)
			end

			if self.Class then
				self.Class:SetAlpha(0)
			end

			if self.Highlight then
				self.Highlight:SetAlpha(0)
			end
		else
			if not self:IsElementEnabled("Castbar") then
				self:EnableElement("Castbar")
			end

			if not self:IsElementEnabled("RaidTargetIndicator") then
				self:EnableElement("RaidTargetIndicator")
			end

			if self.Name then
				self.Name:SetAlpha(1)
			end

			if self.Class then
				self.Class:SetAlpha(1)
			end

			if self.Highlight then
				self.Highlight:SetAlpha(1)
			end
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		if not self:IsElementEnabled("Castbar") then
			self:EnableElement("Castbar")
		end

		if not self:IsElementEnabled("RaidTargetIndicator") then
			self:EnableElement("RaidTargetIndicator")
		end

		if self.Name then
			self.Name:SetAlpha(1)
		end

		if self.Class then
			self.Class:SetAlpha(1)
		end

		if self.Highlight then
			self.Highlight:SetAlpha(1)
		end
	end

	Module.UpdateQuestUnit(self)
	Module.UpdateNameplateTarget(self)
	Module.UpdatePlateClassIcons(self, unit)
	Module.UpdateUnitClassify(self, unit)
end

function Module:CreateStyle(unit)
	if (not unit) then
		return
	end

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
	elseif (string_find(unit, "raid") and C["Raid"].Enable) then
		Module.CreateRaid(self)
	elseif (string_find(unit, "party") and not string_find(unit, "pet") and C["Party"].Enable) then
		Module.CreateParty(self)
	elseif (string_match(unit, "nameplate") and C["Nameplates"].Enable) then
		Module.CreateNameplates(self, unit)
	end

	return self
end

function Module:CreateUnits()
	if C["Nameplates"].Enable then
		oUF:SpawnNamePlates(nil, Module.NameplatesCallback)
	end

	if C["Unitframe"].Enable then
		local Player = oUF:Spawn("player")
		Player:SetPoint("BOTTOM", UIParent, "BOTTOM", -290, 320)
		Player:SetSize(210, 48)
		Module.Units.Player = Player
		K.Mover(Player, "Player", "Player", {"BOTTOM", UIParent, "BOTTOM", -290, 320}, 210, 50)

		local Target = oUF:Spawn("target")
		Target:SetPoint("BOTTOM", UIParent, "BOTTOM", 290, 320)
		Target:SetSize(210, 48)
		Module.Units.Target = Target
		K.Mover(Target, "Target", "Target", {"BOTTOM", UIParent, "BOTTOM", 290, 320}, 210, 50)

		if not C["Unitframe"].HideTargetofTarget then
			local TargetOfTarget = oUF:Spawn("targettarget")
			TargetOfTarget:SetPoint("TOPLEFT", Target, "BOTTOMRIGHT", -48, -6)
			TargetOfTarget:SetSize(116, 28)
			K.Mover(TargetOfTarget, "TargetOfTarget", "TargetOfTarget", {"TOPLEFT", Target, "BOTTOMRIGHT", -48, -6}, 116, 28)

			Module.Units.TargetOfTarget = TargetOfTarget
		end

		local Pet = oUF:Spawn("pet")
		if C["Unitframe"].CombatFade and Player and not InCombatLockdown() then
			Pet:SetParent(Player)
		end
		Pet:SetPoint("TOPRIGHT", Player, "BOTTOMLEFT", 48, -6)
		Pet:SetSize(116, 28)
		Module.Units.Pet = Pet
		K.Mover(Pet, "Pet", "Pet", {"TOPRIGHT", Player, "BOTTOMLEFT", 48, -6}, 116, 28)

		local Focus = oUF:Spawn("focus")
		Focus:SetPoint("BOTTOMRIGHT", Player, "TOPLEFT", -60, 30)
		Focus:SetSize(210, 48)
		Module.Units.Focus = Focus
		K.Mover(Focus, "Focus", "Focus", {"BOTTOMRIGHT", Player, "TOPLEFT", -60, 30}, 210, 48)

		if not C["Unitframe"].HideTargetofTarget then
			local FocusTarget = oUF:Spawn("focustarget")
			FocusTarget:SetPoint("TOPRIGHT", Focus, "BOTTOMLEFT", 48, -6)
			FocusTarget:SetSize(116, 28)

			Module.Units.FocusTarget = FocusTarget
		end
	end

	if C["Arena"].Enable then
		local Arena = {}
		for i = 1, MAX_ARENA_ENEMIES or 5 do
			Arena[i] = oUF:Spawn("arena" .. i, nil)
			Arena[i]:SetSize(156, 44)
			if (i == 1) then
				Arena.Position = {"BOTTOMRIGHT", UIParent, "RIGHT", -250, 140}
			else
				Arena.Position = {"TOPLEFT", Arena[i - 1], "BOTTOMLEFT", 0, -56}
			end

			K.Mover(Arena[i], "Arena"..i, "Arena"..i, Arena.Position)
		end

		Module.Units.Arena = Arena
	end

	if C["Boss"].Enable then
		local Boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			Boss[i] = oUF:Spawn("boss" .. i)
			Boss[i]:SetSize(210, 44)
			if (i == 1) then
				Boss.Position = {"BOTTOMRIGHT", UIParent, "RIGHT", -250, 140}
			else
				Boss.Position = {"TOPLEFT", Boss[i - 1], "BOTTOMLEFT", 0, -56}
			end

			K.Mover(Boss[i], "Boss"..i, "Boss"..i, Boss.Position)
		end

		Module.Units.Boss = Boss
	end

	if C["Party"].Enable then
		local xOffset, yOffset = 6, C["Party"].ShowBuffs and 54 or 18
		local moverWidth = C["Party"].HorizonParty and (164 * 5 + xOffset * 4) or 164
		local moverHeight = C["Party"].HorizonParty and 34 or (34 * 5 + yOffset * 4)
		local groupingOrder = C["Party"].HorizonParty and "TANK,HEALER,DAMAGER,NONE" or "NONE,DAMAGER,HEALER,TANK"

		local party = oUF:SpawnHeader("oUF_Party", nil, "custom [@raid6,exists] hide;show",
		"showPlayer", true,
		"showSolo", false,
		"showParty", true,
		"showRaid", false,
		"xoffset", xOffset,
		"yOffset", yOffset,
		"groupFilter", "1",
		"groupingOrder", groupingOrder,
		"groupBy", "ASSIGNEDROLE",
		"sortMethod", "NAME",
		"point", C["Party"].HorizonParty and "LEFT" or "BOTTOM",
		"columnAnchorPoint", "LEFT",
		"oUF-initialConfigFunction", ([[
		self:SetWidth(%d)
		self:SetHeight(%d)
		]]):format(164, 34))

		Module.Headers.Party = party
		-- I do not like naming it like this...
		Module.partyMover = K.Mover(party, "PartyFrame", "PartyFrame", {"TOPLEFT", UIParent, "TOPLEFT", 4, -180}, moverWidth, moverHeight)
		party:ClearAllPoints()
		party:SetPoint("TOPLEFT", Module.partyMover)

		if C["Party"].ShowTarget then
			local partyTargetMoverWidth = C["Party"].HorizonParty and (64 * 5 + xOffset * 4) or 64
			local partyTargetMoverHeight = C["Party"].HorizonParty and 34 or (34 * 5 + yOffset * 4)

			-- Party targets
			local partytarget = oUF:SpawnHeader("oUF_PartyTarget", nil, "custom [@raid6,exists] hide;show",
			"showSolo", false,
			"showPlayer", true,
			"groupBy", "ASSIGNEDROLE",
			"groupingOrder", groupingOrder,
			"sortMethod", "NAME",
			"showParty", true,
			"showRaid", true,
			"yOffset", yOffset,
			"point", C["Party"].HorizonParty and "LEFT" or "BOTTOM",
			"columnAnchorPoint", "LEFT",
			"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
			self:SetAttribute("unitsuffix", "target")
			]]):format(64, 34))

			Module.Headers.PartyTarget = partytarget
			-- I do not like naming it like this...
			Module.partyTargetMover = K.Mover(partytarget, "PartyTargetFrame", "PartyTargetFrame", {"LEFT", Module.partyMover, "RIGHT", 6, 0}, partyTargetMoverWidth, partyTargetMoverHeight)
			partytarget:ClearAllPoints()
			partytarget:SetPoint("TOPLEFT", Module.partyTargetMover)
		end

		-- Party pets
		if C["Party"].ShowPet then
			local partyPetMoverWidth = C["Party"].HorizonParty and (64 * 5 + xOffset * 4) or 64
			local partyPetMoverHeight = C["Party"].HorizonParty and 34 or (34 * 5 + yOffset * 4)

			local partypet = oUF:SpawnHeader("oUF_PartyPet", nil, "custom [@raid6,exists] hide;show",
			"showSolo", false,
			"showPlayer", true,
			"groupBy", "ASSIGNEDROLE",
			"groupingOrder", groupingOrder,
			"sortMethod", "NAME",
			"showParty", true,
			"showRaid", true,
			"yOffset", yOffset,
			"point", C["Party"].HorizonParty and "LEFT" or "BOTTOM",
			"columnAnchorPoint", "LEFT",
			"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
			self:SetAttribute("useOwnerUnit", "true")
			self:SetAttribute("unitsuffix", "pet")
			]]):format(64, 34))

			Module.Headers.PartyPet = partypet

			local positionPet
			if C["Party"].ShowTarget then
				positionPet = Module.partyTargetMover
			else
				positionPet = Module.partyMover
			end

			local partyPetMover = K.Mover(partypet, "PartyPetFrame", "PartyPetFrame", {"LEFT", positionPet, "RIGHT", 6, 0}, partyPetMoverWidth, partyPetMoverHeight)
			partypet:ClearAllPoints()
			partypet:SetPoint("TOPLEFT", partyPetMover)
		end
	end

	if C["Raid"].Enable then
		local horizonRaid = C["Raid"].HorizonRaid
		local numGroups = C["Raid"].NumGroups
		local raidWidth, raidHeight = C["Raid"].Width, C["Raid"].Height
		local reverse = C["Raid"].ReverseRaid

		-- Hide Default RaidFrame
		if CompactRaidFrameManager_UpdateShown then
			local function HideRaid()
				if InCombatLockdown() then
					return
				end

				K.HideInterfaceOption(CompactRaidFrameManager)
				local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
				if compact_raid and compact_raid ~= "0" then
					CompactRaidFrameManager_SetSetting("IsShown", "0")
				end
			end

			CompactRaidFrameManager:HookScript("OnShow", HideRaid)
			hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
			CompactRaidFrameContainer:UnregisterAllEvents()
			HideRaid()
		end

		local raidMover
		local function CreateGroup(name, i)
			local group = oUF:SpawnHeader(name, nil, C["Party"].Enable and "custom [@raid6,exists] show;hide" or "solo,party,raid",
			"showPlayer", true,
			"showSolo", false,
			"showParty", true,
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

		local groups = {}
		for i = 1, numGroups do
			groups[i] = CreateGroup("oUF_Raid"..i, i)
			if i == 1 then
				if horizonRaid then
					raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", {"TOPLEFT", UIParent, "TOPLEFT", 4, -60}, (raidWidth + 5) * 5, (raidHeight + (C["Raid"].ShowTeamIndex and 21 or 15)) * numGroups)
					if reverse then
						groups[i]:ClearAllPoints()
						groups[i]:SetPoint("BOTTOMLEFT", raidMover)
					end
				else
					raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", {"TOPLEFT", UIParent, "TOPLEFT", 4, -60}, (raidWidth + 5) * numGroups, (raidHeight + 10) * 5)
					if reverse then
						groups[i]:ClearAllPoints()
						groups[i]:SetPoint("TOPRIGHT", raidMover)
					end
				end
			else
				if horizonRaid then
					if reverse then
						groups[i]:SetPoint("BOTTOMLEFT", groups[i-1], "TOPLEFT", 0, C["Raid"].ShowTeamIndex and 21 or 15)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i-1], "BOTTOMLEFT", 0, C["Raid"].ShowTeamIndex and -21 or -15)
					end
				else
					if reverse then
						groups[i]:SetPoint("TOPRIGHT", groups[i-1], "TOPLEFT", -6, 0)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i-1], "TOPRIGHT", 6, 0)
					end
				end
			end

			if C["Raid"].ShowTeamIndex then
				local parent = _G["oUF_Raid"..i.."UnitButton1"]
				if not parent then
					return
				end

				local teamIndex = K.CreateFontString(parent, 12, string_format(GROUP_NUMBER, i), "")
				teamIndex:ClearAllPoints()
				teamIndex:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 5)
				-- teamIndex:SetTextColor(0.6, 0.8, 1)
			end
		end

		if raidMover then
			if not C["Raid"].SpecRaidPos then
				return
			end

			local function UpdateSpecPos(event, ...)
				local unit, _, spellID = ...
				if (event == "UNIT_SPELLCAST_SUCCEEDED" and unit == "player" and spellID == 200749) or event == "PLAYER_ENTERING_WORLD" then
					if not GetSpecialization() then
						return
					end

					local specIndex = GetSpecialization()
					if not KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"]["RaidPos"..specIndex] then
						KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"]["RaidPos"..specIndex] = {"TOPLEFT", UIParent, "TOPLEFT", 4, -60}
					end

					raidMover:ClearAllPoints()
					raidMover:SetPoint(unpack(KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"]["RaidPos"..specIndex]))
				end
			end
			K:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateSpecPos)
			K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateSpecPos)

			raidMover:HookScript("OnDragStop", function()
				if not GetSpecialization() then
					return
				end

				local specIndex = GetSpecialization()
				KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"]["RaidPos"..specIndex] = KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"]["RaidFrame"]
			end)
		end
	end
end

function Module:SetNameplateCVars()
	if InCombatLockdown() then
		return
	end

	if C["Nameplates"].Clamp then
		SetCVar("nameplateOtherTopInset", 0.05)
		SetCVar("nameplateOtherBottomInset", 0.08)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end

	SetCVar("nameplateOverlapH", 0.8)
	SetCVar("nameplateOverlapV", C["Nameplates"].VerticalSpacing)
	SetCVar("nameplateMaxDistance", C["Nameplates"].LoadDistance)
	SetCVar("nameplateMinAlpha", 1)
	SetCVar("nameplateMaxAlpha", 1)
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("showQuestTrackingTooltips", 1)
	SetCVar("namePlateMinScale", 1)
	SetCVar("namePlateMaxScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateSelectedScale", C["Nameplates"].SelectedScale or 1)
end

function Module:CreateFilgerAnchors()
	if C["Filger"].Enable and C["Unitframe"].Enable then
		K.P_BUFF_ICON_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 169)
		K.P_BUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		K.P_PROC_ICON_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 169)
		K.P_PROC_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		K.SPECIAL_P_BUFF_ICON_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 211)
		K.SPECIAL_P_BUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		K.T_DEBUFF_ICON_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 211)
		K.T_DEBUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		K.T_BUFF_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 253)
		K.T_BUFF_Anchor:SetSize(C["Filger"].PvPSize, C["Filger"].PvPSize)

		K.PVE_PVP_DEBUFF_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 253)
		K.PVE_PVP_DEBUFF_Anchor:SetSize(C["Filger"].PvPSize, C["Filger"].PvPSize)

		K.PVE_PVP_CC_Anchor:SetPoint("TOPLEFT", "oUF_Player", "BOTTOMLEFT", -2, -44)
		K.PVE_PVP_CC_Anchor:SetSize(221, 25)

		K.COOLDOWN_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 63, 17)
		K.COOLDOWN_Anchor:SetSize(C["Filger"].CooldownSize, C["Filger"].CooldownSize)

		K.T_DE_BUFF_BAR_Anchor:SetPoint("TOPLEFT", "oUF_Target", "BOTTOMRIGHT", 6, 25)
		K.T_DE_BUFF_BAR_Anchor:SetSize(218, 25)

		K.Mover(K.P_BUFF_ICON_Anchor, "P_BUFF_ICON", "P_BUFF_ICON", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 169})
		K.Mover(K.P_PROC_ICON_Anchor, "P_PROC_ICON", "P_PROC_ICON", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 169})
		K.Mover(K.SPECIAL_P_BUFF_ICON_Anchor, "SPECIAL_P_BUFF_ICON", "SPECIAL_P_BUFF_ICON", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 211})
		K.Mover(K.T_DEBUFF_ICON_Anchor, "T_DEBUFF_ICON", "T_DEBUFF_ICON", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 211})
		K.Mover(K.T_BUFF_Anchor, "T_BUFF", "T_BUFF", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 253})
		K.Mover(K.PVE_PVP_DEBUFF_Anchor, "PVE_PVP_DEBUFF", "PVE_PVP_DEBUFF", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 253})
		K.Mover(K.PVE_PVP_CC_Anchor, "PVE_PVP_CC", "PVE_PVP_CC", {"TOPLEFT", "oUF_Player", "BOTTOMLEFT", -2, -44})
		K.Mover(K.COOLDOWN_Anchor, "COOLDOWN", "COOLDOWN", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 63, 17})
		K.Mover(K.T_DE_BUFF_BAR_Anchor, "T_DE_BUFF_BAR", "T_DE_BUFF_BAR", {"TOPLEFT", "oUF_Target", "BOTTOMRIGHT", 6, 25})
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

function Module.PLAYER_FOCUS_CHANGED()
	CreateTargetSound("focus")
end

function Module.PLAYER_TARGET_CHANGED()
	CreateTargetSound("target")
end

local announcedPVP
function Module.UNIT_FACTION(_, unit)
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
	Module.Backdrop = {
		bgFile = C["Media"].Blank,
		insets = {top = -1, left = -1, bottom = -1, right = -1}
	}

	oUF:RegisterStyle(" ", Module.CreateStyle)

	self:CreateUnits()
	self:CreateFilgerAnchors()

	if C["Raid"].AuraWatch then
		local RaidDebuffs = CreateFrame("Frame")
		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", self.UpdateRaidDebuffIndicator)

		local ORD = oUF_RaidDebuffs or K.oUF_RaidDebuffs
		if (ORD) then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end
	end

	if C["Nameplates"].Enable then
		self:SetNameplateCVars()
		self:UpdateGroupRoles()
		self:QuestIconCheck()

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

	end

	if C["Unitframe"].Enable then
		K.HideInterfaceOption(InterfaceOptionsCombatPanelTargetOfTarget)
		K:RegisterEvent("PLAYER_TARGET_CHANGED", self.PLAYER_TARGET_CHANGED)
		K:RegisterEvent("PLAYER_FOCUS_CHANGED", self.PLAYER_FOCUS_CHANGED)
		K:RegisterEvent("UNIT_FACTION", self.UNIT_FACTION)

		self:UpdateRangeCheckSpells()
	end
end