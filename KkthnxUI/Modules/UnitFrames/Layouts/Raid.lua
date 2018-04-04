local K, C, L = unpack(select(2, ...))
if C["Raidframe"].Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

-- Lua API
local _G = _G
local string_format = string.format
local table_insert = table.insert
local math_ceil = math.ceil

-- Wow API
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitHasIncomingResurrection = _G.UnitHasIncomingResurrection
local UnitHasMana = _G.UnitHasMana
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitPowerType = _G.UnitPowerType
local UnitThreatSituation = _G.UnitThreatSituation

local Movers = K.Movers

local GHOST = GetSpellInfo(8326)
if GetLocale() == "deDE" then
	GHOST = "Geist"
end

local function UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then return end

	local situation = UnitThreatSituation(unit)
	if (situation and situation > 0) then
		local r, g, b = GetThreatStatusColor(situation)
		self:SetBackdropBorderColor(1, 0, 0)
	else
		self:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
	end
end

local function UpdatePower(self, _, unit)
	if (self.unit ~= unit) then
		return
	end

	local _, powerToken = UnitPowerType(unit)
	if (powerToken == "MANA" and UnitHasMana(unit)) then
		if (not self.Power:IsVisible()) then
			self.Health:SetPoint("BOTTOMLEFT", self, 0, 5)
			self.Health:SetPoint("TOPRIGHT", self)
			self.Power:Show()
		end
	else
		if (self.Power:IsVisible()) then
			self.Health:SetAllPoints(self)
			self.Power:Hide()
		end
	end
end

local function DeficitValue(self)
	if (self >= 1000) then
		return string_format("-%.1f", self/1000)
	else
		return self
	end
end

local function GetUnitStatus(unit)
	if (UnitIsDead(unit)) then
		return L.Unitframes.Dead -- local Raidunitframe Dead
	elseif (UnitIsGhost(unit)) then
		return L.Unitframes.Ghost -- local Raidunitframe Ghost
	elseif (not UnitIsConnected(unit)) then
		return PLAYER_OFFLINE
	else
		return ""
	end
end

local function GetHealthText(unit, cur, max)
	local healthString
	if (UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)) then
		healthString = GetUnitStatus(unit)
	else
		if ((cur / max) < C["Raidframe"].DeficitThreshold) then
			healthString = string_format("|cff%02x%02x%02x%s|r", 0.9 * 255, 0 * 255, 0 * 255, DeficitValue(max-cur))
		else
			healthString = ""
		end
	end

	return healthString
end

local function UpdateHealth(self, unit, cur, max)
	if (not cur) or (not max) then return end

	if (not UnitIsPlayer(unit)) then
		local r, g, b = K.ColorGradient(cur / max, 0, 0.8, 0, 0.8, 0.8, 0, 0.8, 0, 0)
		self:SetStatusBarColor(r, g, b)
	end

	self.Value:SetText(GetHealthText(unit, cur, max))
end

local function CreateRaidLayout(self)
	local RaidframeFont = K.GetFont(C["Raidframe"].Font)
	local RaidframeTexture = K.GetTexture(C["Raidframe"].Texture)

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", function(self)
		UnitFrame_OnEnter(self)
		if (self.Mouseover) then
			self.Mouseover:SetAlpha(0.2)
		end
	end)

	self:SetScript("OnLeave", function(self)
		UnitFrame_OnLeave(self)
		if (self.Mouseover) then
			self.Mouseover:SetAlpha(0)
		end
	end)

	self:SetTemplate("Transparent", true)

	self.Health = CreateFrame("StatusBar", "$parentHealthBar", self)
	self.Health:SetFrameStrata("LOW")
	self.Health:SetFrameLevel(self:GetFrameLevel() - 0)
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(RaidframeTexture)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY", 1)
	self.Health.Value:SetFontObject(RaidframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, 0, -5)
	self.Health.Value:SetFont(C["Media"].Font, 10, C["Raidframe"].Outline and "OUTLINE" or "")
	self.Health.Value:SetShadowOffset(C["Raidframe"].Outline and 0 or K.Mult, C["Raidframe"].Outline and -0 or -K.Mult)

	self.Health.PostUpdate = UpdateHealth

	self.Health.frequentUpdates = true
	self.Health.colorDisconnected = true
	self.Health.colorReaction = true
	self.Health.colorTapping = true
	self.Health.colorClass = true
	self.Health.Cutaway = C["Raidframe"].Cutaway
	self.Health.Smooth = C["Raidframe"].Smooth
	self.Health.SmoothSpeed = C["Raidframe"].SmoothSpeed * 10

	-- Power
	if (C["Raidframe"].ManabarShow) then
		self.Power = CreateFrame("StatusBar", "$parentPower", self)
		self.Power:SetFrameStrata("LOW")
		self.Power:SetFrameLevel(self:GetFrameLevel())
		self.Power:SetHeight(3)
		self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
		self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
		self.Power:SetStatusBarTexture(RaidframeTexture)

		self.Power.frequentUpdates = true
		self.Power.Cutaway = C["Raidframe"].Cutaway
		self.Power.colorPower = true
		self.Power.Smooth = C["Raidframe"].Smooth
		self.Power.SmoothSpeed = C["Raidframe"].SmoothSpeed * 10

		self.Power.Background = self.Power:CreateTexture(nil, "BORDER")
		self.Power.Background:SetAllPoints(self.Power)
		self.Power.Background:SetColorTexture(.2, .2, .2)
		self.Power.Background.multiplier = 0.3

		table_insert(self.__elements, UpdatePower)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UpdatePower)
		UpdatePower(self, _, unit)
	end

	self.Name = self.Health:CreateFontString(nil, "OVERLAY", 1)
	self.Name:SetPoint("TOP", 0, -2)
	self.Name:SetFontObject(RaidframeFont)
	self:Tag(self.Name, "[KkthnxUI:NameRaidShort]")

	-- We need this to overlay self
	self.Overlay = CreateFrame("Frame", nil, self.Health)
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(self:GetFrameLevel() + 4)

	self.ReadyCheckIndicator = self.Health:CreateTexture(nil, "OVERLAY", 2)
	self.ReadyCheckIndicator:SetSize(12, 12)
	self.ReadyCheckIndicator:SetPoint("CENTER")

	if (C["Raidframe"].ShowRolePrefix) then
		self.RaidRoleText = self.Health:CreateFontString(nil, "OVERLAY")
		self.RaidRoleText:SetPoint("BOTTOMLEFT", self.Health, 2, 2)
		self.RaidRoleText:SetFont(C["Media"].Font, 11, C["Raidframe"].Outline and "OUTLINE" or "")
		self.RaidRoleText:SetShadowOffset(C["Raidframe"].Outline and 0 or K.Mult, C["Raidframe"].Outline and -0 or -K.Mult)
		self:Tag(self.RaidRoleText, "[KkthnxUI:RaidRole]")
	end

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(30, 30)
	self.ResurrectIndicator:SetPoint("CENTER", 0, -3)

	-- Masterlooter icons
	self.MasterLooterIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.MasterLooterIndicator:SetSize(11, 11)
	self.MasterLooterIndicator:SetPoint("TOPLEFT", 8, 6)
	self.MasterLooterIndicator:Show()

	-- Leader icons
	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(12, 12)
	self.LeaderIndicator:SetPoint("TOPLEFT", -2, 7)

	-- Afk /offline timer, using frequentUpdates function from oUF tags
	if (C["Raidframe"].ShowNotHereTimer) then
		self.AFKIndicator = self.Overlay:CreateFontString(nil, "OVERLAY")
		self.AFKIndicator:SetPoint("CENTER", self, "BOTTOM", 0, 6)
		self.AFKIndicator:SetFont(C["Media"].Font, 9, "THINOUTLINE")
		self.AFKIndicator:SetShadowOffset(0, 0)
		self.AFKIndicator:SetTextColor(0, 1, 0)
		self:Tag(self.AFKIndicator, "[KkthnxUI:AFK]")
	end

	self.Range = K.CreateRange(self)
	self.HealthPrediction = K.CreateHealthPrediction(self)

	-- AuraWatch (corner and center icon)
	if C["Raidframe"].AuraWatch == true then
		K.CreateAuraWatch(self)

		self.RaidDebuffs = CreateFrame("Frame", nil, self.Health)
		self.RaidDebuffs:SetHeight(C["Raidframe"].AuraDebuffIconSize)
		self.RaidDebuffs:SetWidth(C["Raidframe"].AuraDebuffIconSize)
		self.RaidDebuffs:SetPoint("CENTER", self.Health)
		self.RaidDebuffs:SetFrameLevel(self.Health:GetFrameLevel() + 20)
		K.CreateBorder(self.RaidDebuffs, 4)

		self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, "ARTWORK")
		self.RaidDebuffs.icon:SetTexCoord(.1, .9, .1, .9)
		self.RaidDebuffs.icon:SetAllPoints(self.RaidDebuffs)

		self.RaidDebuffs.cd = CreateFrame("Cooldown", nil, self.RaidDebuffs)
		self.RaidDebuffs.cd:SetAllPoints(self.RaidDebuffs)
		self.RaidDebuffs.cd:SetHideCountdownNumbers(true)

		self.RaidDebuffs.ShowDispelableDebuff = true
		self.RaidDebuffs.FilterDispelableDebuff = true
		self.RaidDebuffs.MatchBySpellName = false
		self.RaidDebuffs.ShowBossDebuff = true
		self.RaidDebuffs.BossDebuffPriority = 5

		self.RaidDebuffs.count = self.RaidDebuffs:CreateFontString(nil, "OVERLAY")
		self.RaidDebuffs.count:SetFont(C["Media"].Font, 12, "OUTLINE")
		self.RaidDebuffs.count:SetPoint("BOTTOMRIGHT", self.RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		self.RaidDebuffs.count:SetTextColor(1, .9, 0)

		self.RaidDebuffs.SetDebuffTypeColor = self.RaidDebuffs.SetBackdropBorderColor
		self.RaidDebuffs.Debuffs = K.RaidDebuffs

		self.RaidDebuffs.PostUpdate = function(self)
			local button = self.RaidDebuffs
			-- we don"t want those "1""s cluttering up the display
			if button then
				local count = tonumber(button.count:GetText())
				if count and count > 1 then
					self.RaidDebuffs.count:SetText(count)
					self.RaidDebuffs.count:Show()
				else
					self.RaidDebuffs.count:Hide()
				end
			end
		end
	end

	-- ThreatIndicator
	self.ThreatIndicator = {}
	self.ThreatIndicator.IsObjectType = function() end
	self.ThreatIndicator.Override = UpdateThreat

	if (C["Raidframe"].ShowMouseoverHighlight) then
		self.Mouseover = self.Health:CreateTexture(nil, "OVERLAY")
		self.Mouseover:SetAllPoints(self.Health)
		self.Mouseover:SetTexture(C.Media.Texture)
		self.Mouseover:SetVertexColor(0, 0, 0)
		self.Mouseover:SetAlpha(0)
	end
end

oUF:RegisterStyle("oUF_KkthnxUI_Raidframes", CreateRaidLayout)
oUF:SetActiveStyle("oUF_KkthnxUI_Raidframes")

if (C["Raidframe"].Enable) then
	local raid = oUF:SpawnHeader("oUF_Raid", nil, C["Unitframe"].PartyAsRaid and "custom [group:party] show" or "custom [group:raid] show; hide",
	"oUF-initialConfigFunction", [[
		local header = self:GetParent()
		self:SetWidth(header:GetAttribute("initial-width"))
		self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"initial-width", C["Raidframe"].Width,
	"initial-height", C["Raidframe"].Height,
	"showParty", true,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"yOffset", -6,
	"xOffset", 6,
	"point", "TOP",
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", C["Raidframe"].GroupBy.Value,
	"maxColumns", 5,
	"unitsPerColumn", C["Raidframe"].MaxUnitPerColumn or 1,
	"columnSpacing", 6,
	"columnAnchorPoint", "LEFT")

	raid:SetScale(C["Raidframe"].Scale or 1)
	raid:SetFrameStrata("LOW")
	raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 8, -200)
	Movers:RegisterFrame(raid)
end

-- Main Tank/Assist Frames
if C["Raidframe"].MainTankFrames then
	local raidtank = oUF:SpawnHeader("oUF_Raid_MT", nil, "raid",
	"oUF-initialConfigFunction", [[
		self:SetWidth(70)
		self:SetHeight(40)
	]],
	"showRaid", true,
	"yOffset", -8,
	"groupFilter", "MAINTANK",
	"template", "oUF_Raid_MT"
	)
	raidtank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
	raidtank:SetScale(C["Raidframe"].Scale or 1)
	Movers:RegisterFrame(raidtank)
end