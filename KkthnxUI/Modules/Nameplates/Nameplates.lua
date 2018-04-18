local K, C, L = unpack(select(2, ...))
if C["Nameplates"].Enable ~= true then return end

-- oUF_Nameplates
local _, ns = ...
local oUF = ns.oUF

-- Lua API
local _G = _G
local math_abs = math.abs
local math_min = math.min
local pairs = pairs
local string_format = string.format
local table_insert = table.insert
local unpack = unpack
local string_gsub = string.gsub

-- Wow API
local C_NamePlate_GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit
local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetBattlefieldScore = _G.GetBattlefieldScore
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHealth = _G.UnitHealth
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitReaction = _G.UnitReaction
local UnitSelectionColor = _G.UnitSelectionColor

local CVarUpdate = {
	nameplateMaxDistance = C["Nameplates"].Distance or 40,
	nameplateMinScale = 1,
	nameplateOtherBottomInset = C["Nameplates"].Clamp and 0.1 or -1,
	nameplateOtherTopInset = C["Nameplates"].Clamp and 0.08 or -1,
	nameplateSelectedAlpha = 1,
	nameplateGlobalScale = 1,
	NamePlateHorizontalScale = 1,
	nameplateLargerScale = 1.2,
	nameplateMaxAlpha = 0.5,
	nameplateMaxAlphaDistance = 40,
	nameplateMaxScale = 1,
	nameplateMaxScaleDistance = 40,
	nameplateMinAlpha = 0.5,
	nameplateMinAlphaDistance = 0,
	nameplateMinScaleDistance = 0,
	nameplateSelectedScale = 1,
	nameplateSelfScale = 1,
	nameplateShowFriendlyNPCs = 0,
	NamePlateVerticalScale = 1,
}

local NameplateFont = K.GetFont(C["Nameplates"].Font)
local NameplateTexture = K.GetTexture(C["Nameplates"].Texture)

local healList, exClass, healerSpecs = {}, {}, {}
local testing = false

exClass.DEATHKNIGHT = true
exClass.MAGE = true
exClass.ROGUE = true
exClass.WARLOCK = true
exClass.WARRIOR = true
if C["Nameplates"].HealerIcon == true then
	local EventFrame = CreateFrame("Frame")

	EventFrame.Factions = {
		["Horde"] = 1,
		["Alliance"] = 0,
	}

	local healerSpecIDs = {
		105, -- Druid Restoration
		270, -- Monk Mistweaver
		65, -- Paladin Holy
		256, -- Priest Discipline
		257, -- Priest Holy
		264, -- Shaman Restoration
	}

	for _, specID in pairs(healerSpecIDs) do
		local _, name = GetSpecializationInfoByID(specID)
		if name and not healerSpecs[name] then
			healerSpecs[name] = true
		end
	end

	local lastCheck = 3
	local function CheckHealers(self, elapsed)
		lastCheck = lastCheck + elapsed
		if lastCheck > 8 then
			lastCheck = 0
			healList = {}
			for i = 1, GetNumBattlefieldScores() do
				local name, _, _, _, _, faction, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)

				if name and healerSpecs[talentSpec] and EventFrame.Factions[UnitFactionGroup("player")] == faction then
					name = string_gsub(name, "%-"..string_gsub(K.Realm, "[%s%-]", ""), "")
					healList[name] = talentSpec
				end
			end
		end
	end

	local function CheckArenaHealers(self, elapsed)
		local numOpps = GetNumArenaOpponentSpecs()
		if not (numOpps > 1) then
			return
		end

		lastCheck = lastCheck + elapsed
		if lastCheck > 8 then
			lastCheck = 0
			healList = {}
			for i = 1, 5 do
				local specID = GetArenaOpponentSpec(i)
				if specID and specID > 0 then
					local name = UnitName(string_format("arena%d", i))
					local _, talentSpec = GetSpecializationInfoByID(specID)
					if name and healerSpecs[talentSpec] then
						healList[name] = talentSpec
					end
				end
			end
		end
	end

	local function CheckHealerLoc(self, event)
		local _, instanceType = IsInInstance()
		if instanceType == "pvp" then
			EventFrame:SetScript("OnUpdate", CheckHealers)
		elseif instanceType == "arena" then
			self:RegisterEvent("UNIT_NAME_UPDATE", "CheckArenaHealers")
			self:RegisterEvent("ARENA_OPPONENT_UPDATE", "CheckArenaHealers")
			EventFrame:SetScript("OnUpdate", CheckArenaHealers)
		else
			self:UnregisterEvent("UNIT_NAME_UPDATE")
			self:UnregisterEvent("ARENA_OPPONENT_UPDATE")
			healList = {}
			EventFrame:SetScript("OnUpdate", nil)
		end
	end

	EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	EventFrame:SetScript("OnEvent", CheckHealerLoc)
end

local totemData = {
	[GetSpellInfo(192058)] = "Interface\\Icons\\spell_nature_brilliance", -- Lightning Surge Totem
	[GetSpellInfo(98008)] = "Interface\\Icons\\spell_shaman_spiritlink", -- Spirit Link Totem
	[GetSpellInfo(192077)] = "Interface\\Icons\\ability_shaman_windwalktotem", -- Wind Rush Totem
	[GetSpellInfo(204331)] = "Interface\\Icons\\spell_nature_wrathofair_totem", -- Counterstrike Totem
	[GetSpellInfo(204332)] = "Interface\\Icons\\spell_nature_windfury", -- Windfury Totem
	[GetSpellInfo(204336)] = "Interface\\Icons\\spell_nature_groundingtotem", -- Grounding Totem
	-- Water
	[GetSpellInfo(157153)] = "Interface\\Icons\\ability_shaman_condensationtotem", -- Cloudburst Totem
	[GetSpellInfo(5394)] = "Interface\\Icons\\INV_Spear_04", -- Healing Stream Totem
	[GetSpellInfo(108280)] = "Interface\\Icons\\ability_shaman_healingtide", -- Healing Tide Totem
	-- Earth
	[GetSpellInfo(207399)] = "Interface\\Icons\\spell_nature_reincarnation", -- Ancestral Protection Totem
	[GetSpellInfo(198838)] = "Interface\\Icons\\spell_nature_stoneskintotem", -- Earthen Shield Totem
	[GetSpellInfo(51485)] = "Interface\\Icons\\spell_nature_stranglevines", -- Earthgrab Totem
	[GetSpellInfo(61882)] = "Interface\\Icons\\spell_shaman_earthquake", -- Earthquake Totem
	[GetSpellInfo(196932)] = "Interface\\Icons\\spell_totem_wardofdraining", -- Voodoo Totem
	-- Fire
	[GetSpellInfo(192222)] = "Interface\\Icons\\spell_shaman_spewlava", -- Liquid Magma Totem
	[GetSpellInfo(204330)] = "Interface\\Icons\\spell_fire_totemofwrath", -- Skyfury Totem
	-- Totem Mastery
	[GetSpellInfo(202188)] = "Interface\\Icons\\spell_nature_stoneskintotem", -- Resonance Totem
	[GetSpellInfo(210651)] = "Interface\\Icons\\spell_shaman_stormtotem", -- Storm Totem
	[GetSpellInfo(210657)] = "Interface\\Icons\\spell_fire_searingtotem", -- Ember Totem
	[GetSpellInfo(210660)] = "Interface\\Icons\\spell_nature_invisibilitytotem", -- Tailwind Totem
}

local function CustomFilterList(_, unit, _, name, _, _, _, _, _, _, caster, _, nameplateShowSelf, _, _, _, _, nameplateShowAll)
	local allow = false

	if caster == "player" then
		if UnitIsUnit(unit, "player") then
			if ((nameplateShowAll or nameplateShowSelf) and not K.BuffBlackList[name]) then
				allow = true
			elseif K.BuffWhiteList[name] then
				allow = true
			end
		else
			if ((nameplateShowAll or nameplateShowSelf) and not K.DebuffBlackList[name]) then
				allow = true
			elseif K.DebuffWhiteList[name] then
				allow = true
			end
		end
	end

	return allow
end

local function CreateVirtualFrame(frame, point)
	if point == nil then point = frame end
	if point.backdrop then return end

	frame.backdrop = CreateFrame("Frame", nil, frame)
	frame.backdrop:SetAllPoints()
	frame.backdrop:SetBackdrop({
		bgFile = C["Media"].Blank,
		edgeFile = C["Media"].Glow,
		edgeSize = 3 * K.NoScaleMult,
		insets = {
			top = 3 * K.NoScaleMult,
			left = 3 * K.NoScaleMult,
			bottom = 3 * K.NoScaleMult,
			right = 3 * K.NoScaleMult
	}})
	frame.backdrop:SetPoint("TOPLEFT", point, -3 * K.NoScaleMult, 3 * K.NoScaleMult)
	frame.backdrop:SetPoint("BOTTOMRIGHT", point, 3 * K.NoScaleMult, -3 * K.NoScaleMult)
	frame.backdrop:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
	frame.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

	if frame:GetFrameLevel() - 1 > 0 then
		frame.backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
	else
		frame.backdrop:SetFrameLevel(0)
	end
end

local function SetVirtualBorder(frame, r, g, b, a)
	if not a then
		a = 1
	end
	frame.backdrop:SetBackdropBorderColor(r, g, b, a)
end

local function ThreatColor(self, forced)
	if UnitIsPlayer(self.unit) then return end
	local combat = UnitAffectingCombat("player")
	local _, threatStatus = UnitDetailedThreatSituation("player", self.unit)

	if C["Nameplates"].EnhancedThreat ~= true then
		SetVirtualBorder(self.Health, 0, 0, 0)
	end

	if UnitIsTapDenied(self.unit) then
		self.Health:SetStatusBarColor(0.6, 0.6, 0.6)
	elseif combat then
		if threatStatus == 3 then -- securely tanking, highest threat
			if K.GetPlayerRole() == "TANK" then
				if C["Nameplates"].EnhancedThreat == true then
					self.Health:SetStatusBarColor(C["Nameplates"].GoodColor[1], C["Nameplates"].GoodColor[2], C["Nameplates"].GoodColor[3])
				else
					SetVirtualBorder(self.Health, C["Nameplates"].BadColor[1], C["Nameplates"].BadColor[2], C["Nameplates"].BadColor[3])
				end
			else
				if C["Nameplates"].EnhancedThreat == true then
					self.Health:SetStatusBarColor(C["Nameplates"].BadColor[1], C["Nameplates"].BadColor[2], C["Nameplates"].BadColor[3])
				else
					SetVirtualBorder(self.Health, C["Nameplates"].BadColor[1], C["Nameplates"].BadColor[2], C["Nameplates"].BadColor[3])
				end
			end
		elseif threatStatus == 2 then -- insecurely tanking, another unit have higher threat but not tanking
			if C["Nameplates"].EnhancedThreat == true then
				self.Health:SetStatusBarColor(C["Nameplates"].NearColor[1], C["Nameplates"].NearColor[2], C["Nameplates"].NearColor[3])
			else
				SetVirtualBorder(self.Health, C["Nameplates"].NearColor[1], C["Nameplates"].NearColor[2], C["Nameplates"].NearColor[3])
			end
		elseif threatStatus == 1 then -- not tanking, higher threat than tank
			if C["Nameplates"].EnhancedThreat == true then
				self.Health:SetStatusBarColor(C["Nameplates"].NearColor[1], C["Nameplates"].NearColor[2], C["Nameplates"].NearColor[3])
			else
				SetVirtualBorder(self.Health, C["Nameplates"].NearColor[1], C["Nameplates"].NearColor[2], C["Nameplates"].NearColor[3])
			end
		elseif threatStatus == 0 then -- not tanking, lower threat than tank
			if C["Nameplates"].EnhancedThreat == true then
				if K.GetPlayerRole() == "TANK" then
					self.Health:SetStatusBarColor(C["Nameplates"].BadColor[1], C["Nameplates"].BadColor[2], C["Nameplates"].BadColor[3])
					if IsInGroup() or IsInRaid() then
						for i = 1, GetNumGroupMembers() do
							if UnitExists("raid"..i) and not UnitIsUnit("raid"..i, "player") then
								local isTanking = UnitDetailedThreatSituation("raid"..i, self.unit)
								if isTanking and UnitGroupRolesAssigned("raid"..i) == "TANK" then
									self.Health:SetStatusBarColor(C["Nameplates"].OffTankColor[1], C["Nameplates"].OffTankColor[2], C["Nameplates"].OffTankColor[3])
								end
							end
						end
					end
				else
					self.Health:SetStatusBarColor(C["Nameplates"].GoodColor[1], C["Nameplates"].GoodColor[2], C["Nameplates"].GoodColor[3])
				end
			end
		end
	elseif (not forced and self.Health.ForceUpdate) then
		self.Health:ForceUpdate()
	end
end

local function UpdateTarget(self)
	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		self:SetAlpha(1)
	else
		self:SetSize(C["Nameplates"].Width * K.NoScaleMult, C["Nameplates"].Height * K.NoScaleMult)
		self.Castbar.Icon:SetSize(C["Nameplates"].Height * 2 * K.NoScaleMult + 3, C["Nameplates"].Height * 2 * K.NoScaleMult + 3)
		self.Castbar.Icon:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, 0)
		if (UnitExists("target") and not UnitIsUnit(self.unit, "player")) then
			self:SetAlpha(C["Nameplates"].OORAlpha)
		else
			self:SetAlpha(1)
		end
	end
end

local function UpdateName(self)
	if C["Nameplates"].HealerIcon == true then
		local name = UnitName(self.unit)
		if name then
			if testing then
				self.HealerIcon:Show()
			else
				if healList[name] then
					if exClass[healList[name]] then
						self.HealerIcon:Hide()
					else
						self.HealerIcon:Show()
					end
				else
					self.HealerIcon:Hide()
				end
			end
		end
	end

	if C["Nameplates"].TotemIcons == true then
		local name = UnitName(self.unit)
		if name then
			if totemData[name] then
				self.Totem.Icon:SetTexture(totemData[name])
				self.Totem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				self.Totem:Show()
			else
				self.Totem:Hide()
			end
		end
	end
end

local function PostCastStart(castbar, unit, name)
	if unit == "vehicle" then unit = "player" end

	local text = castbar.Text
	if (text) then
		castbar.Text:SetText(name)
	end

	-- Get length of Time, then calculate available length for Text
	local timeWidth = castbar.Time:GetStringWidth()
	local textWidth = castbar:GetWidth() - timeWidth - 10
	local textStringWidth = castbar.Text:GetStringWidth()

	if timeWidth == 0 or textStringWidth == 0 then
		K.Delay(0.05, function() -- Delay may need tweaking
			textWidth = castbar:GetWidth() - castbar.Time:GetStringWidth() - 10
			textStringWidth = castbar.Text:GetStringWidth()
			if textWidth > 0 then castbar.Text:SetWidth(math_min(textWidth, textStringWidth)) end
		end)
	else
		castbar.Text:SetWidth(math_min(textWidth, textStringWidth))
	end

	castbar.Spark:SetSize(128, castbar:GetHeight())

	castbar.unit = unit

	local colors = K.Colors
	local r, g, b = colors.status.castColor[1], colors.status.castColor[2], colors.status.castColor[3]

	local t
	if C["Nameplates"].CastUnitReaction and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if castbar.notInterruptible and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3]
	end

	castbar:SetStatusBarColor(r, g, b)
end

local function PostCastStop(castbar)
	castbar.chainChannel = nil
	castbar.prevSpellCast = nil
end

local function PostCastFailedOrInterrupted(castbar, unit, name, castID)
	castbar:SetStatusBarColor(1, 0, 0)
	castbar:SetValue(castbar.max)

	local spark = castbar.Spark
	if (spark) then
		spark:SetPoint("CENTER", castbar, "RIGHT")
		spark:SetWidth(0.001) -- This should hide it without an issue.
	end

	local time = castbar.Time
	if (time) then
		time:SetText("")
	end
end

local function PostCastInterruptible(castbar, unit)
	if unit == "vehicle" or unit == "player" then return end

	local colors = K.Colors
	local r, g, b = colors.status.castColor[1], colors.status.castColor[2], colors.status.castColor[3]

	local t
	if C["Nameplates"].CastUnitReaction and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if castbar.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3]
	end

	castbar:SetStatusBarColor(r, g, b)
end

local function PostCastNotInterruptible(castbar)
	local colors = K.Colors
	castbar:SetStatusBarColor(colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3])
end

local function CustomCastDelayText(castbar, duration)
	if castbar.casting then
		duration = castbar.max - duration
	end

	if castbar.channeling then
		castbar.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(duration, castbar.delay))
	else
		castbar.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(math_abs(duration - castbar.max), "+", castbar.delay))
	end
end

local function CustomTimeText(castbar, duration)
	if castbar.max > 600 then
		return castbar.Time:SetText("")
	end

	if castbar.channeling then
		castbar.Time:SetText(("%.1f"):format(duration))
	else
		castbar.Time:SetText(("%.1f"):format(math_abs(duration - castbar.max)))
	end
end

local function CallbackUpdate(self, event, unit)
	if unit then
		local name = UnitName(unit)
		if name and K.PlateBlacklist[name] then
			self:Hide()
		else
			self:Show()
		end

		if UnitIsUnit(unit, "player") then
			self.Power:Show()
			self.Name:Hide()
			self.Castbar:SetAlpha(0)
			self.RaidTargetIndicator:SetAlpha(0)
		else
			self.Power:Hide()
			self.Name:Show()
			self.Castbar:SetAlpha(1)
			self.RaidTargetIndicator:SetAlpha(1)
		end
	end
end

local function StyleUpdate(self, unit)
	local nameplate = C_NamePlate_GetNamePlateForUnit(unit)
	local main = self
	self.unit = unit

	self:SetPoint("CENTER", nameplate, "CENTER")
	self:SetSize(C["Nameplates"].Width * K.NoScaleMult, C["Nameplates"].Height * K.NoScaleMult)

	-- Health Bar
	self.Health = CreateFrame("StatusBar", "$parentHealthBar", self)
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(NameplateTexture)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorHealth = true
	self.Health.Cutaway = C["Nameplates"].Cutaway
	self.Health.Smooth = C["Nameplates"].Smooth
	self.Health.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10
	self.Health.frequentUpdates = true
	CreateVirtualFrame(self.Health)

	self.HealthPrediction = K.CreateHealthPrediction(self)

	-- Create Health Text
	if C["Nameplates"].HealthValue == true then
		self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
		self.Health.value:SetFont(C["Media"].Font, C["Nameplates"].FontSize * K.NoScaleMult, C["Nameplates"].Outline and "OUTLINE" or "")
		self.Health.value:SetShadowOffset(C["Nameplates"].Outline and 0 or 1, C["Nameplates"].Outline and -0 or -1)
		self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.value, "[KkthnxUI:NameplateHealth]")
	end

	-- Create Player Power bar
	self.Power = CreateFrame("StatusBar", "$parentPowerBar", self)
	self.Power:SetStatusBarTexture(NameplateTexture)
	self.Power:ClearAllPoints()
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -3-(C["Nameplates"].Height * K.NoScaleMult / 2))
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.Cutaway = C["Nameplates"].Cutaway
	self.Power.Smooth = C["Nameplates"].Smooth
	self.Power.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10
	CreateVirtualFrame(self.Power)

	-- Create Name Text
	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetFont(C["Media"].Font, C["Nameplates"].FontSize * K.NoScaleMult, C["Nameplates"].Outline and "OUTLINE" or "")
	self.Name:SetShadowOffset(C["Nameplates"].Outline and 0 or 1, C["Nameplates"].Outline and -0 or -1)
	self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 2)
	self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 3, 2)

	if C["Nameplates"].NameAbbreviate == true then
		self:Tag(self.Name, "[KkthnxUI:NameplateNameColor][KkthnxUI:NameMediumAbbrev]")
	else
		self:Tag(self.Name, "[KkthnxUI:NameplateNameColor][KkthnxUI:NameMedium]")
	end

	-- Create Level
	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetFont(C["Media"].Font, C["Nameplates"].FontSize * K.NoScaleMult, C["Nameplates"].Outline and "OUTLINE" or "")
	self.Level:SetShadowOffset(C["Nameplates"].Outline and 0 or 1, C["Nameplates"].Outline and -0 or -1)
	self.Level:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:NameplateSmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	-- Create Cast Bar
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(NameplateTexture)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -3 -(C["Nameplates"].Height * K.NoScaleMult))
	CreateVirtualFrame(self.Castbar)

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetSize(128, self:GetHeight())
	self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
	self.Castbar.Spark:SetBlendMode("ADD")

	-- Create Cast Time Text
	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", 0, 0)
	self.Castbar.Time:SetFont(C["Media"].Font, C["Nameplates"].FontSize * K.NoScaleMult, C["Nameplates"].Outline and "OUTLINE" or "")

	self.Castbar.timeToHold = 0.4
	self.Castbar.PostCastStart = PostCastStart
	self.Castbar.PostChannelStart = PostCastStart
	self.Castbar.PostCastStop = PostCastStop
	self.Castbar.PostChannelStop = PostCastStop
	self.Castbar.PostCastInterruptible = PostCastInterruptible
	self.Castbar.PostCastNotInterruptible = PostCastNotInterruptible
	self.Castbar.PostCastFailed = PostCastFailedOrInterrupted
	self.Castbar.PostCastInterrupted = PostCastFailedOrInterrupted

	-- Create Cast Name Text
	if C["Nameplates"].CastbarName == true then
		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 3, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -1, 0)
		self.Castbar.Text:SetFont(C["Media"].Font, C["Nameplates"].FontSize * K.NoScaleMult, C["Nameplates"].Outline and "OUTLINE" or "")
		self.Castbar.Text:SetShadowOffset(C["Nameplates"].Outline and 0 or 1, C["Nameplates"].Outline and -0 or -1)
		self.Castbar.Text:SetHeight(C["Media"].FontSize)
		self.Castbar.Text:SetJustifyH("LEFT")
	end

	-- Create CastBar Icon
	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	self.Castbar.Icon:SetDrawLayer("ARTWORK")
	self.Castbar.Icon:SetSize(C["Nameplates"].Height * 2 * K.NoScaleMult + 3, C["Nameplates"].Height * 2 * K.NoScaleMult + 3)
	self.Castbar.Icon:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, 0)
	CreateVirtualFrame(self.Castbar, self.Castbar.Icon)

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]])
	self.Castbar.Shield:SetSize(40, 40)
	self.Castbar.Shield:SetPoint("RIGHT", self.Castbar, "LEFT", 20, 8)

	if C["Nameplates"].ThreatPercent == true then
		self.ThreatPercentText = self.Health:CreateFontString(nil, "OVERLAY")
		self.ThreatPercentText:SetPoint("RIGHT", self.Health, "LEFT", -4, 12)
		self.ThreatPercentText:SetFont(C["Media"].Font, C["Nameplates"].FontSize * K.NoScaleMult - 1, C["Nameplates"].Outline and "OUTLINE" or "")
		self.ThreatPercentText:SetShadowOffset(C["Nameplates"].Outline and 0 or 1, C["Nameplates"].Outline and -0 or -1)
		self:Tag(self.ThreatPercentText, "[KkthnxUI:NameplateThreatColor][KkthnxUI:NameplateThreat]")
	end

	-- Raid Icon
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
	self.RaidTargetIndicator:SetSize((C["Nameplates"].Height * 2 * K.NoScaleMult) + 8, (C["Nameplates"].Height * 2 * K.NoScaleMult) + 8)
	self.RaidTargetIndicator:SetPoint("BOTTOM", self.Health, "TOP", 0, C["Nameplates"].TrackAuras == true and 38 or 16)

	-- Create Totem Icon
	if C["Nameplates"].TotemIcons == true then
		self.Totem = CreateFrame("Frame", nil, self)
		self.Totem.Icon = self.Totem:CreateTexture(nil, "OVERLAY")
		self.Totem.Icon:SetSize((C["Nameplates"].Height * 2 * K.NoScaleMult) + 8, (C["Nameplates"].Height * 2 * K.NoScaleMult) + 8)
		self.Totem.Icon:SetPoint("BOTTOM", self.Health, "TOP", 0, 16)
		CreateVirtualFrame(self.Totem, self.Totem.Icon)
	end

	-- Create Healer Icon
	if C["Nameplates"].HealerIcon == true then
		self.HealerIcon = self.Health:CreateTexture(nil, "OVERLAY")
		self.HealerIcon:SetPoint("RIGHT", self.Health, "LEFT", -6, 0)
		self.HealerIcon:SetSize(32, 32)
		self.HealerIcon:SetTexture([[Interface\AddOns\KkthnxUI\Media\Nameplates\HealerIcon.tga]])
	end

	-- Quest Indicator
	self.QuestIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.QuestIndicator:SetSize(14, 14)
	self.QuestIndicator:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -7, 7)

	local function CreateAuraTimer(self, elapsed)
		self.expirationSaved = self.expirationSaved - elapsed
		if self.nextupdate > 0 then
			self.nextupdate = self.nextupdate - elapsed
			return
		end

		if self.expirationSaved <= 0 then
			self:SetScript("OnUpdate", nil)
			if (self.text:GetFont()) then
				self.text:SetText("")
			end
			return
		end

		local timervalue, formatid
		timervalue, formatid, self.nextupdate = K.GetTimeInfo(self.expirationSaved, 4)
		if self.text:GetFont() then
			self.text:SetFormattedText(string_format("%s%s|r", K.TimeColors[formatid], K.TimeFormats[formatid][2]), timervalue)
		end
	end

	local function PostCreateAura(self, button)
		CreateVirtualFrame(button)
		button:SetScale(K.NoScaleMult)

		button.text = button.cd:CreateFontString(nil, "OVERLAY")
		button.text:FontTemplate(nil, self.size * 0.46)
		button.text:SetPoint("CENTER", 1, 1)
		button.text:SetJustifyH("CENTER")

		button.cd.noOCC = true
		button.cd.noCooldownCount = true
		button.cd:SetReverse(true)
		button.cd:SetAllPoints()
		button.cd:SetHideCountdownNumbers(true)

		button.icon:SetAllPoints(button)
		button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		button.icon:SetDrawLayer("ARTWORK")

		button.count:FontTemplate(nil, self.size * 0.40)
		button.count:ClearAllPoints()
		button.count:SetPoint("BOTTOMRIGHT", 1, 1)
		button.count:SetJustifyH("RIGHT")
	end

	local function PostUpdateAura(self, unit, button, index)
		local name, _, _, _, debuffType, duration, expiration, caster = UnitAura(unit, index, button.filter)

		if button.isDebuff then
			local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and K.Class ~= "WARLOCK" then
				SetVirtualBorder(button, 0.05, 0.85, 0.94)
			else
				SetVirtualBorder(button, color.r, color.g, color.b)
			end
			button.icon:SetDesaturated(false)
			button:EnableMouse(false)
		end

		if expiration and duration and (duration ~= 0) then
			local getTime = GetTime()
			if not button:GetScript("OnUpdate") then
				button.expirationTime = expiration
				button.expirationSaved = expiration - getTime
				button.nextupdate = -1
				button:SetScript("OnUpdate", CreateAuraTimer)
			end
			if (button.expirationTime ~= expiration) or (button.expirationSaved ~= (expiration - getTime)) then
				button.expirationTime = expiration
				button.expirationSaved = expiration - getTime
				button.nextupdate = -1
			end
		end

		if expiration and duration and (duration == 0 or expiration <= 0) then
			button.expirationTime = nil
			button.expirationSaved = nil
			button:SetScript("OnUpdate", nil)
			if button.text:GetFont() then
				button.text:SetText("")
			end
		end
	end

	-- Aura tracking
	if C["Nameplates"].TrackAuras == true then
		local Auras = CreateFrame("Frame", self:GetName().."Auras", self)
		Auras:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2 * K.NoScaleMult, C["Nameplates"].FontSize + 3)
		Auras.initialAnchor = "BOTTOMLEFT"
		Auras["growth-y"] = "UP"
		Auras["growth-x"] = "RIGHT"
		Auras.numDebuffs = 6 or 0
		Auras.numBuffs = 4 or 0
		Auras.PostCreateIcon = PostCreateAura
		Auras.PostUpdateIcon = PostUpdateAura
		Auras.CustomFilter = CustomFilterList
		Auras:SetSize(18 + C["Nameplates"].Width, C["Nameplates"].AurasSize)
		Auras.spacing = 4
		Auras.size = C["Nameplates"].AurasSize

		self.Auras = Auras
	end

	self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	self.Health:RegisterEvent("UNIT_TARGET")

	self.Health:SetScript("OnEvent", function(self, event)
		ThreatColor(main)
	end)

	self.Health.PostUpdate = function(self, unit, min, max)
		local perc = 0
		if max and max > 0 then
			perc = min / max
		end

		local r, g, b
		local unitReaction = UnitReaction(unit, "player")
		if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (unitReaction and unitReaction >= 5) then
			r, g, b = unpack(K.Colors.power["MANA"])
			self:SetStatusBarColor(r, g, b)
		elseif not UnitIsTapDenied(unit) and not UnitIsPlayer(unit) then
			local reaction = K.Colors.reaction[unitReaction]
			if reaction then
				r, g, b = reaction[1], reaction[2], reaction[3]
			else
				r, g, b = UnitSelectionColor(unit, true)
			end

			self:SetStatusBarColor(r, g, b)
		end

		if UnitIsPlayer(unit) then
			if perc <= 0.5 and perc >= 0.2 then
				SetVirtualBorder(self, 1, 1, 0)
			elseif perc < 0.2 then
				SetVirtualBorder(self, 1, 0, 0)
			else
				SetVirtualBorder(self, 0, 0, 0)
			end
		elseif not UnitIsPlayer(unit) and C["Nameplates"].EnhancedThreat == true then
			SetVirtualBorder(self, 0, 0, 0)
		end

		ThreatColor(main, true)
	end

	-- Every event should be register with this
	table_insert(self.__elements, UpdateName)
	self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)

	table_insert(self.__elements, UpdateTarget)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTarget)
end

oUF:RegisterStyle("KkthnxUINamePlates", StyleUpdate)
oUF:SetActiveStyle("KkthnxUINamePlates")
oUF:SpawnNamePlates("KkthnxUINamePlates", CallbackUpdate, CVarUpdate)