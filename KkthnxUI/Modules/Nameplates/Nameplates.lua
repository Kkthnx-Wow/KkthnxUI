local K, C, L = unpack(select(2, ...))
if C.Nameplates.Enable ~= true then return end

-- Lua API
local _G = _G
local math_abs = math.abs
local math_floor = math.floor
local math_huge = math.huge
local string_format = string.format
local table_insert = table.insert
local unpack = unpack

-- Wow API
local CreateFrame = _G.CreateFrame
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetBattlefieldScore = _G.GetBattlefieldScore
local GetCVarDefault = _G.GetCVarDefault
local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local SetCVar = _G.SetCVar
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitDebuff = _G.UnitDebuff
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsPVPSanctuary = _G.UnitIsPVPSanctuary
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitReaction = _G.UnitReaction
local UnitSelectionColor = _G.UnitSelectionColor

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: C_NamePlate, ShowUIPanel, GameTooltip, UnitAura, DebuffTypeColor

-- oUF_Kkthnx Nameplates
local _, ns = ...
local oUF = ns.oUF

local KkthnxUINamePlates = CreateFrame("Frame")
KkthnxUINamePlates:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

-- NOTE: We should determine what Vars tend to bug out the nameplates and make sure we always have these defaulted. If not, we fetch the defaulted settings and reset them.
-- NOTE: This is the safest way to prevent any unknown issues currently.

-- Default some CVars, can help when coming from other UIs that also modify these!
K:LockCVar("nameplateGlobalScale", GetCVarDefault("nameplateGlobalScale"))
K:LockCVar("nameplateLargeBottomInset", GetCVarDefault("nameplateLargeBottomInset"))
K:LockCVar("nameplateLargeTopInset", GetCVarDefault("nameplateLargeTopInset"))
K:LockCVar("nameplateMaxAlphaDistance", GetCVarDefault("nameplateMaxAlphaDistance"))
K:LockCVar("nameplateMaxScaleDistance", GetCVarDefault("nameplateMaxScaleDistance"))
K:LockCVar("nameplateMinScaleDistance", GetCVarDefault("nameplateMinScaleDistance"))
K:LockCVar("nameplateMotionSpeed", GetCVarDefault("nameplateMotionSpeed"))
K:LockCVar("nameplateOtherBottomInset", GetCVarDefault("nameplateOtherBottomInset"))
K:LockCVar("nameplateOtherTopInset", GetCVarDefault("nameplateOtherTopInset"))
K:LockCVar("nameplateOverlapH", GetCVarDefault("nameplateOverlapH"))
K:LockCVar("nameplateOverlapV", GetCVarDefault("nameplateOverlapV"))
K:LockCVar("nameplateSelfAlpha", GetCVarDefault("nameplateSelfAlpha"))
K:LockCVar("nameplateShowAll", GetCVarDefault("nameplateShowAll"))
K:LockCVar("nameplateShowFriendlyNPCs", GetCVarDefault("nameplateShowFriendlyNPCs"))

-- Set what we want for the nameplates. Only certain ones will work for oUF.
local UpdateCVars = {}
if C.Nameplates.EnhancedThreat == true then
	UpdateCVars["threatWarning"] = 3
	-- print(GetCVarDefault("threatWarning")) -- Be sure this is changing as needed.
end
UpdateCVars["nameplateLargerScale"] = 1
UpdateCVars["nameplateMaxAlpha"] = 1
UpdateCVars["nameplateMaxDistance"] = C.Nameplates.Distance or 40
UpdateCVars["namePlateMaxScale"] = 1
UpdateCVars["nameplateMinAlpha"] = 1
UpdateCVars["nameplateMinScale"] = 1
UpdateCVars["nameplateOtherBottomInset"] = C.Nameplates.Clamp and 0.1 or -1
UpdateCVars["nameplateOtherTopInset"] = C.Nameplates.Clamp and 0.08 or -1

KkthnxUINamePlates.UpdateCVars = UpdateCVars

local healList, exClass, healerSpecs = {}, {}, {}
local testing = false

exClass.DEATHKNIGHT = true
exClass.MAGE = true
exClass.ROGUE = true
exClass.WARLOCK = true
exClass.WARRIOR = true
if C.Nameplates.HealerIcon == true then
	local t = CreateFrame("Frame")
	t.factions = {
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

	local lastCheck = 20
	local function CheckHealers(self, elapsed)
		lastCheck = lastCheck + elapsed
		if lastCheck > 25 then
			lastCheck = 0
			healList = {}
			for i = 1, GetNumBattlefieldScores() do
				local name, _, _, _, _, faction, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)

				if name and healerSpecs[talentSpec] and t.factions[UnitFactionGroup("player")] == faction then
					name = name:match("(.+)%-.+") or name
					healList[name] = talentSpec
				end
			end
		end
	end

	local function CheckArenaHealers(self, elapsed)
		lastCheck = lastCheck + elapsed
		if lastCheck > 25 then
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

	local function CheckLoc(self, event)
		if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_ENTERING_BATTLEGROUND" then
			local _, instanceType = IsInInstance()
			if instanceType == "pvp" then
				t:SetScript("OnUpdate", CheckHealers)
			elseif instanceType == "arena" then
				t:SetScript("OnUpdate", CheckArenaHealers)
			else
				healList = {}
				t:SetScript("OnUpdate", nil)
			end
		end
	end

	t:RegisterEvent("PLAYER_ENTERING_WORLD")
	t:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
	t:SetScript("OnEvent", CheckLoc)
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

local function CreateVirtualFrame(frame, point)
	if point == nil then point = frame end
	if point.backdrop then return end

	frame.backdrop = CreateFrame("Frame", nil , frame)
	frame.backdrop:SetAllPoints()
	frame.backdrop:SetBackdrop({
		bgFile = C.Media.Blank,
		edgeFile = C.Media.Glow,
		edgeSize = 3 * K.NoScaleMult,
		insets = {top = 3 * K.NoScaleMult, left = 3 * K.NoScaleMult, bottom = 3 * K.NoScaleMult, right = 3 * K.NoScaleMult}
	})
	frame.backdrop:SetPoint("TOPLEFT", point, -3 * K.NoScaleMult, 3 * K.NoScaleMult)
	frame.backdrop:SetPoint("BOTTOMRIGHT", point, 3 * K.NoScaleMult, -3 * K.NoScaleMult)
	frame.backdrop:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	frame.backdrop:SetBackdropBorderColor(C.Media.Nameplate_BorderColor[1], C.Media.Nameplate_BorderColor[2], C.Media.Nameplate_BorderColor[3])

	if frame:GetFrameLevel() - 1 > 0 then
		frame.backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
	else
		frame.backdrop:SetFrameLevel(0)
	end
end

local function SetVirtualBorder(frame, r, g, b)
	frame.backdrop:SetBackdropBorderColor(r, g, b)
end

local CreateAuraTimer = function(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= .1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = K.FormatTime(self.timeLeft)
				self.remaining:SetText(time)
				if self.timeLeft <= 2.5 then
					self.remaining:SetTextColor(1, 0, 0)
				else
					self.remaining:SetTextColor(1, 1, 0)
				end
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

local function CreateAuraIcon(parent)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(C.Nameplates.AurasSize, C.Nameplates.AurasSize)
	button:SetScale(K.NoScaleMult)

	button.backdrop = CreateFrame("Frame", nil , button)
	button.backdrop:SetFrameLevel(0)
	button.backdrop:SetBackdrop({
		bgFile = C.Media.Blank,
		edgeFile = C.Media.Glow,
		edgeSize = 4 * K.NoScaleMult,
		insets = {top = 4 * K.NoScaleMult, left = 4 * K.NoScaleMult, bottom = 4 * K.NoScaleMult, right = 4 * K.NoScaleMult}
	})
	button.backdrop:SetPoint("TOPLEFT", -2 * K.NoScaleMult, 2 * K.NoScaleMult)
	button.backdrop:SetPoint("BOTTOMRIGHT", 2 * K.NoScaleMult, -2 * K.NoScaleMult)
	button.backdrop:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	button.backdrop:SetBackdropBorderColor(C.Media.Nameplate_BorderColor[1], C.Media.Nameplate_BorderColor[2], C.Media.Nameplate_BorderColor[3])

	button.icon = button:CreateTexture(nil, "OVERLAY")
	button.icon:SetPoint("TOPLEFT", 2, -2)
	button.icon:SetPoint("BOTTOMRIGHT", -2, 2)
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

	button.cd = CreateFrame("Cooldown", "$parentCooldown", button, "CooldownFrameTemplate")
	button.cd:SetDrawEdge(false)
	button.cd:SetReverse(true)
	button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
	button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	button.remaining = K.SetFontString(button, C.Media.Font, C.Nameplates.FontSize, C.Media.Font_Style, "CENTER")
	button.remaining:SetShadowOffset(0, 0)
	button.remaining:SetPoint("CENTER", button, "CENTER", 1, 1)
	button.remaining:SetJustifyH("CENTER")

	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(C.Media.Font, C.Nameplates.FontSize, C.Media.Font_Style)
	button.count:SetShadowOffset(0, 0)

	button.parent = CreateFrame("Frame", nil, button)
	button.parent:SetFrameLevel(button.cd:GetFrameLevel() + 1)
	button.count:SetParent(button.parent)
	button.remaining:SetParent(button.parent)
	button:EnableMouse(false)

	return button
end

local function UpdateAuraIcon(button, unit, index, filter)
	local name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)

	if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
		button:SetSize(C.Nameplates.AurasSize + C.Nameplates.AdditionalSize, C.Nameplates.AurasSize + C.Nameplates.AdditionalSize)
	else
		button:SetSize(C.Nameplates.AurasSize, C.Nameplates.AurasSize)
	end

	button.icon:SetTexture(icon)
	button.expirationTime = expirationTime
	button.duration = duration
	button.spellID = spellID
	button.cd:SetCooldown(expirationTime - duration, duration)
	button.cd:Show()

	local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
	if (name == "Unstable Affliction" or name == "Vampiric Touch") and K.Class ~= "WARLOCK" then
		button.backdrop:SetBackdropBorderColor(0.05, 0.85, 0.94)
	else
		button.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	end

	if count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end

	if duration and duration > 0 then
		button.remaining:Show()
		button.timeLeft = expirationTime
		button:SetScript("OnUpdate", CreateAuraTimer)
	else
		button.remaining:Hide()
		button.timeLeft = math_huge
		button:SetScript("OnUpdate", nil)
	end
	button.first = true

	button:Show()
end

local function DebuffFilter(name, caster, spellId, nameplateShowPersonal, nameplateShowAll, unit)
	if caster == "player" then
		if ((nameplateShowPersonal or nameplateShowAll) and not K.DebuffBlackList[name]) then
			return true
		elseif K.DebuffWhiteList[name] then
			return true
		end
	end

	-- -- Star Augur Etraeus debuffs -- Pointless since patch 7.2
	-- if spellId == 205445 or spellId == 205429 or spellId == 216345 or spellId == 216344 then
	-- 	local playermark = select(1, UnitDebuff("player", "Star Sign: Crab")) or nil
	-- 	playermark = playermark or select(1, UnitDebuff("player", "Star Sign: Wolf")) or nil
	-- 	playermark = playermark or select(1, UnitDebuff("player", "Star Sign: Dragon")) or nil
	-- 	playermark = playermark or select(1, UnitDebuff("player", "Star Sign: Hunter")) or nil
	--
	-- 	local unitmark = select(1, UnitDebuff(unit, "Star Sign: Crab")) or nil
	-- 	unitmark = unitmark or select(1, UnitDebuff(unit, "Star Sign: Wolf")) or nil
	-- 	unitmark = unitmark or select(1, UnitDebuff(unit, "Star Sign: Dragon")) or nil
	-- 	unitmark = unitmark or select(1, UnitDebuff(unit, "Star Sign: Hunter")) or nil
	--
	-- 	return true, true
	-- end

	return false
end

local function UpdateAuras(self)
	if not C.Nameplates.TrackAuras or UnitIsUnit(self.unit, "player") then return end
	local i = 1
	local r, g, b

	for index = 1, 40 do
		if i > C.Nameplates.Width / C.Nameplates.AurasSize then return end
		local name, _, _, _, _, _, _, caster, _, nameplateShowPersonal, spellId, _, _, _, nameplateShowAll = UnitAura(self.unit, index, "HARMFUL")

		local allow, boss = DebuffFilter(name, caster, spellId, nameplateShowPersonal, nameplateShowAll, self.unit)
		if name and allow then
			if not self.DebuffIcons[i] then
				self.DebuffIcons[i] = CreateAuraIcon(self)
			end
			UpdateAuraIcon(self.DebuffIcons[i], self.unit, index, "HARMFUL")
			if boss then
				self.DebuffIcons[i].icon:SetVertexColor(r, g, b)
			else
				self.DebuffIcons[i].icon:SetVertexColor(1, 1, 1)
			end
			if i == 1 then
				self.DebuffIcons[i]:SetPoint("BOTTOMLEFT", self.DebuffIcons, "BOTTOMLEFT")
			elseif i ~= 1 then
				self.DebuffIcons[i]:SetPoint("LEFT", self.DebuffIcons[i-1], "RIGHT", 2, 0)
			end
			i = i + 1
		end
	end

	for index = i, #self.DebuffIcons do
		self.DebuffIcons[index]:Hide()
	end
end

local function ThreatColor(self, forced)
	if not self.Health:IsShown() or UnitIsPlayer(self.unit) then return end
	local combatStatus = UnitAffectingCombat("player")
	local _, threatStatus = UnitDetailedThreatSituation("player", self.unit)
	local unitPerc = (UnitHealth(self.unit) / UnitHealthMax(self.unit)) * 100
	local unitName = UnitName(self.unit) or ""

	if C.Nameplates.EnhancedThreat ~= true then
		SetVirtualBorder(self.Health, C.Media.Nameplate_BorderColor[1], C.Media.Nameplate_BorderColor[2], C.Media.Nameplate_BorderColor[3])
	end
	if UnitIsTapDenied(self.unit) then
		self.Health:SetStatusBarColor(0.6, 0.6, 0.6)
	elseif combatStatus then
		if threatStatus == 3 then -- securely tanking, highest threat
			if K.Role == "Tank" then
				if C.Nameplates.EnhancedThreat == true then
					self.Health:SetStatusBarColor(C.Nameplates.GoodColor[1], C.Nameplates.GoodColor[2], C.Nameplates.GoodColor[3])
				else
					SetVirtualBorder(self.Health, C.Nameplates.BadColor[1], C.Nameplates.BadColor[2], C.Nameplates.BadColor[3])
				end
			else
				if C.Nameplates.EnhancedThreat == true then
					self.Health:SetStatusBarColor(C.Nameplates.BadColor[1], C.Nameplates.BadColor[2], C.Nameplates.BadColor[3])
				else
					SetVirtualBorder(self.Health, C.Nameplates.BadColor[1], C.Nameplates.BadColor[2], C.Nameplates.BadColor[3])
				end
			end
		elseif threatStatus == 2 then -- insecurely tanking, another unit have higher threat but not tanking
			if C.Nameplates.EnhancedThreat == true then
				self.Health:SetStatusBarColor(C.Nameplates.NearColor[1], C.Nameplates.NearColor[2], C.Nameplates.NearColor[3])
			else
				SetVirtualBorder(self.Health, C.Nameplates.NearColor[1], C.Nameplates.NearColor[2], C.Nameplates.NearColor[3])
			end
		elseif threatStatus == 1 then -- not tanking, higher threat than tank
			if C.Nameplates.EnhancedThreat == true then
				self.Health:SetStatusBarColor(C.Nameplates.NearColor[1], C.Nameplates.NearColor[2], C.Nameplates.NearColor[3])
			else
				SetVirtualBorder(self.Health, C.Nameplates.NearColor[1], C.Nameplates.NearColor[2], C.Nameplates.NearColor[3])
			end
		elseif threatStatus == 0 then -- not tanking, lower threat than tank
			if C.Nameplates.EnhancedThreat == true then
				if K.Role == "Tank" then
					self.Health:SetStatusBarColor(C.Nameplates.BadColor[1], C.Nameplates.BadColor[2], C.Nameplates.BadColor[3])
					if IsInGroup() or IsInRaid() then
						for i = 1, GetNumGroupMembers() do
							if UnitExists("raid"..i) and not UnitIsUnit("raid"..i, "player") then
								local isTanking = UnitDetailedThreatSituation("raid"..i, self.unit)
								if isTanking and UnitGroupRolesAssigned("raid"..i) == "TANK" then
									self.Health:SetStatusBarColor(C.Nameplates.OffTankColor[1], C.Nameplates.OffTankColor[2], C.Nameplates.OffTankColor[3])
								end
							end
						end
					end
				else
					self.Health:SetStatusBarColor(C.Nameplates.GoodColor[1], C.Nameplates.GoodColor[2], C.Nameplates.GoodColor[3])
				end
			end
		end
	elseif (not forced) then
		self.Health:ForceUpdate()
	end
end

local function UpdateTarget(self)
	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		self:SetSize((C.Nameplates.Width + C.Nameplates.AdditionalSize) * K.NoScaleMult, (C.Nameplates.Height + C.Nameplates.AdditionalSize) * K.NoScaleMult)
		self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -8-((C.Nameplates.Height + C.Nameplates.AdditionalSize) * K.NoScaleMult))
		self.Castbar.Icon:SetSize(((C.Nameplates.Height + C.Nameplates.AdditionalSize) * 2 * K.NoScaleMult) + 8, ((C.Nameplates.Height + C.Nameplates.AdditionalSize) * 2 * K.NoScaleMult) + 8)
		self:SetAlpha(1)
	else
		self:SetSize(C.Nameplates.Width * K.NoScaleMult, C.Nameplates.Height * K.NoScaleMult)
		self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -8-(C.Nameplates.Height * K.NoScaleMult))
		self.Castbar.Icon:SetSize((C.Nameplates.Height * 2 * K.NoScaleMult) + 8, (C.Nameplates.Height * 2 * K.NoScaleMult) + 8)
		if (UnitExists("target") and not UnitIsUnit(self.unit, "player")) then
			self:SetAlpha(C.UnitframePlugins.OORAlpha)
		else
			self:SetAlpha(1)
		end
	end
end

local function UpdateName(self)
	if C.Nameplates.HealerIcon == true then
		local name = UnitName(self.unit)
		if name then
			if testing then
				self.HPHeal:Show()
			else
				if healList[name] then
					if exClass[healList[name]] then
						self.HPHeal:Hide()
					else
						self.HPHeal:Show()
					end
				else
					self.HPHeal:Hide()
				end
			end
		end
	end

	if C.Nameplates.TotemIcons == true then
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

local function castColor(self, unit)
	if unit == "vehicle" or unit == "player" then return end

	-- Colors, you know Colours? ;)
	local colors = K.Colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if C.Nameplates.CastUnitReaction and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if (t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.interrupt and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
	if self.bg:IsShown() then
		self.bg:SetVertexColor(r * 0.18, g * 0.18, b * 0.18)
	end
end

local function castInterrupted(self, unit, name, castid)
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetStatusBarColor(1, 0, 0)

	self.Spark:SetPoint("CENTER", self, "RIGHT")
end

local function CallbackNamePlates(self, event, unit)
	local unit = unit or "target"
	local name = UnitName(unit)
	if name and K.PlateBlacklist[name] then
		self:Hide()
	else
		self:Show()
	end

	self:EnableMouse(false)
	self.Health:EnableMouse(false)

	if UnitIsUnit(unit, "player") then
		self.Power:Show()
		self.Name:Hide()
		self.Castbar:SetAlpha(0)
		self.RaidIcon:SetAlpha(0)
	else
		local unitReaction = UnitReaction(unit, "player")
		if (UnitIsPVPSanctuary(unit) or (UnitIsPlayer(unit) and UnitIsFriend("player", unit) and unitReaction and unitReaction >= 5)) then
			self.Health:SetAlpha(0)
			self.Castbar:SetAlpha(0)
			self.Level:SetAlpha(0)
		else
			self.Health:SetAlpha(1)
			self.Castbar:SetAlpha(1)
			self.Level:SetAlpha(1)
		end

		self.Power:Hide()
		self.Name:Show()
		-- self.Castbar:SetAlpha(1)
		self.RaidIcon:SetAlpha(1)
	end
end

local function StyleNamePlates(self, unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local main = self
	nameplate.ouf = self
	self:EnableMouse(false)
	self.unit = unit
	self:SetScript("OnEnter", function()
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetUnit(self.unit)
		GameTooltip:Show()
	end)
	self:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	self.hooked = true

	self:SetPoint("CENTER", nameplate, "CENTER")
	self:SetSize(C.Nameplates.Width * K.NoScaleMult, C.Nameplates.Height * K.NoScaleMult)

	-- Health Bar
	self.Health = K.CreateStatusBar(self, "$parentHealthBar")
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(C.Media.Texture)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorHealth = true
	self.Health.Smooth = C.Nameplates.Smooth
	self.Health.frequentUpdates = true

	CreateVirtualFrame(self.Health)
	self.Health:EnableMouse(false)

	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints()
	self.Health.bg:SetTexture(C.Media.Blank)
	self.Health.bg.multiplier = 0.18

	-- Create Health Text
	if C.Nameplates.HealthValue == true then
		self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
		self.Health.value:SetFont(C.Media.Font, C.Nameplates.FontSize * K.NoScaleMult, C.Media.Font_Style)
		self.Health.value:SetShadowOffset(0, 0)
		self.Health.value:SetPoint("RIGHT", self.Health, "RIGHT", 0, 0)
		self:Tag(self.Health.value, "[KkthnxUI:NameplateHealth]")
	end

	-- Create Player Power bar
	self.Power = K.CreateStatusBar(self, "$parentPowerBar")
	self.Power:SetStatusBarTexture(C.Media.Texture)
	self.Power:ClearAllPoints()
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -3-(C.Nameplates.Height * K.NoScaleMult / 2))
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.Smooth = C.Nameplates.Smooth
	CreateVirtualFrame(self.Power)

	self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
	self.Power.bg:SetAllPoints()
	self.Power.bg:SetTexture(C.Media.Blank)
	self.Power.bg.multiplier = 0.18

	-- Create Name Text
	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetFont(C.Media.Font, C.Nameplates.FontSize * K.NoScaleMult, C.Media.Font_Style)
	self.Name:SetShadowOffset(0, 0)
	self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 3, 4)

	if C.Nameplates.NameAbbreviate == true then
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameplateNameLongAbbrev]")
	else
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameplateNameLong]")
	end

	-- Create Level
	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetFont(C.Media.Font, C.Nameplates.FontSize * K.NoScaleMult, C.Media.Font_Style)
	self.Level:SetShadowOffset(0, 0)
	self.Level:SetPoint("RIGHT", self.Health, "LEFT", -2, 0)
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:NameplateLevel] [KkthnxUI:ClassificationColor][shortclassification]")

	-- Create Cast Bar
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(C.Media.Texture)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -3-(C.Nameplates.Height * K.NoScaleMult))
	CreateVirtualFrame(self.Castbar)

	self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.bg:SetAllPoints()
	self.Castbar.bg:SetTexture(C.Media.Blank)

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "ARTWORK", nil, 1)
	self.Castbar.Spark:SetBlendMode("ADD")
	self.Castbar.Spark:SetPoint("CENTER", self.Castbar:GetRegions(), "RIGHT", 1, 0)
	self.Castbar.Spark:SetSize(10, C.Nameplates.Height + 6)

	self.Castbar.PostCastStart = castColor
	self.Castbar.PostChannelStart = castColor
	self.Castbar.PostCastInterrupted = castInterrupted
	self.Castbar.PostCastNotInterruptible = castColor
	self.Castbar.PostCastInterruptible = castColor

	-- Create Cast Time Text
	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", 0, 0)
	self.Castbar.Time:SetFont(C.Media.Font, C.Nameplates.FontSize * K.NoScaleMult, C.Media.Font_Style)

	self.Castbar.timeToHold = 0.4

	self.Castbar.CustomTimeText = function(self, duration)
		if self.channeling then
			self.Time:SetText(("%.1f"):format(math_abs(duration - self.max)))
		else
			self.Time:SetText(("%.1f"):format(duration))
		end
	end

	-- Create Cast Name Text
	if C.Nameplates.CastbarName == true then
		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 3, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -1, 0)
		self.Castbar.Text:SetFont(C.Media.Font, C.Nameplates.FontSize * K.NoScaleMult, C.Media.Font_Style)
		self.Castbar.Text:SetShadowOffset(0, 0)
		self.Castbar.Text:SetHeight(C.Media.Font_Size)
		self.Castbar.Text:SetJustifyH("LEFT")
	end

	-- Create CastBar Icon
	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	self.Castbar.Icon:SetDrawLayer("ARTWORK")
	self.Castbar.Icon:SetSize((C.Nameplates.Height * 2 * K.NoScaleMult) + 8, (C.Nameplates.Height * 2 * K.NoScaleMult) + 8)
	self.Castbar.Icon:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 4, 0)
	CreateVirtualFrame(self.Castbar, self.Castbar.Icon)

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetTexture[[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]]
	self.Castbar.Shield:SetSize(46, 46)
	self.Castbar.Shield:SetPoint("RIGHT", self.Castbar, "LEFT", 24, 8)

	-- Raid Icon
	self.RaidIcon = self:CreateTexture(nil, "OVERLAY", nil, 7)
	self.RaidIcon:SetSize((C.Nameplates.Height * 2 * K.NoScaleMult) + 8, (C.Nameplates.Height * 2 * K.NoScaleMult) + 8)
	self.RaidIcon:SetPoint("BOTTOM", self.Health, "TOP", 0, C.Nameplates.TrackAuras == true and 38 or 16)

	-- Create Totem Icon
	if C.Nameplates.TotemIcons == true then
		self.Totem = CreateFrame("Frame", nil, self)
		self.Totem.Icon = self.Totem:CreateTexture(nil, "OVERLAY")
		self.Totem.Icon:SetSize((C.Nameplates.Height * 2 * K.NoScaleMult) + 8, (C.Nameplates.Height * 2 * K.NoScaleMult) + 8)
		self.Totem.Icon:SetPoint("BOTTOM", self.Health, "TOP", 0, 16)
		CreateVirtualFrame(self.Totem, self.Totem.Icon)
	end

	-- Create Healer Icon
	if C.Nameplates.HealerIcon == true then
		self.HPHeal = self.Health:CreateFontString(nil, "OVERLAY")
		self.HPHeal:SetFont(C.Media.Font, 32, C.Media.Font_Style)
		self.HPHeal:SetText("|cFFD53333+|r")
		self.HPHeal:SetPoint("BOTTOM", self.Name, "TOP", 0, C.Nameplates.TrackAuras == true and 26 or 0)
	end

	-- Aura tracking
	if C.Nameplates.TrackAuras == true then
		self.DebuffIcons = CreateFrame("Frame", nil, self)
		self.DebuffIcons:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0 * K.NoScaleMult, C.Media.Font_Size + 7)
		self.DebuffIcons:SetSize(20 + C.Nameplates.Width, C.Nameplates.AurasSize)
		self.DebuffIcons:EnableMouse(false)
	end

	K.EnableHealPredictionAndAbsorb(self)

	self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

	self.Health:SetScript("OnEvent", function(self, event)
		ThreatColor(main)
	end)

	self.Health.PostUpdate = function(self, unit, min, max)
		local perc = 0
		if max and max > 0 then
			perc = min / max
		end

		local r, g, b
		local mu = self.bg.multiplier
		local unitReaction = UnitReaction(unit, "player")
		if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (unitReaction and unitReaction >= 5) then
			r, g, b = unpack(K.Colors.power["MANA"])
			self:SetStatusBarColor(r, g, b)
			self.bg:SetVertexColor(r * mu, g * mu, b * mu)
		elseif not UnitIsTapDenied(unit) and not UnitIsPlayer(unit) then
			local reaction = K.Colors.reaction[unitReaction]
			if reaction then
				r, g, b = reaction[1], reaction[2], reaction[3]
			else
				r, g, b = UnitSelectionColor(unit, true)
			end

			self:SetStatusBarColor(r, g, b)
			self.bg:SetVertexColor(r * mu, g * mu, b * mu)
		end

		if UnitIsPlayer(unit) then
			if perc <= 0.5 and perc >= 0.2 then
				SetVirtualBorder(self, 1, 1, 0)
			elseif perc < 0.2 then
				SetVirtualBorder(self, 1, 0, 0)
			else
				SetVirtualBorder(self, C.Media.Nameplate_BorderColor[1], C.Media.Nameplate_BorderColor[2], C.Media.Nameplate_BorderColor[3])
			end
		elseif not UnitIsPlayer(unit) and C.Nameplates.EnhancedThreat == true then
			SetVirtualBorder(self, C.Media.Nameplate_BorderColor[1], C.Media.Nameplate_BorderColor[2], C.Media.Nameplate_BorderColor[3])
		end

		ThreatColor(main, true)
	end

	-- Every event should be register with this
	table_insert(self.__elements, UpdateName)
	self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)

	table_insert(self.__elements, UpdateTarget)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTarget)

	table_insert(self.__elements, UpdateAuras)
	self:RegisterEvent("UNIT_AURA", UpdateAuras)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateAuras)
end

oUF:RegisterStyle("KkthnxUINamePlates", StyleNamePlates)
oUF:SetActiveStyle("KkthnxUINamePlates")
oUF:SpawnNamePlates("KkthnxUINamePlates", CallbackNamePlates, KkthnxUINamePlates.UpdateCVars)