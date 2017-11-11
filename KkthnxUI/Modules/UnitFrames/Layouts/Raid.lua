local K, C, L = unpack(select(2, ...))
if C["Raidframe"].Enable ~= true then return end

-- Lua API
local _G = _G
local string_format = string.format
local table_insert = table.insert

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

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: DEAD, PLAYER_OFFLINE, CreateFrame, UnitFrame_OnEnter, UnitFrame_OnLeave

-- Credits to Neav, Renstrom, Grimsbain
local _, ns = ...
local oUF = ns.oUF or oUF
local Movers = K.Movers

local GHOST = GetSpellInfo(8326)
if GetLocale() == "deDE" then
	GHOST = "Geist"
end

local function UpdateThreat(self, _, unit)
	if unit ~= self.unit then return end
    local status = UnitThreatSituation(unit)
    local threat = self.Threat

    local r, g, b
    if status and status > 0 then
        r,g,b = GetThreatStatusColor(status)
        threat:SetBackdropBorderColor(r, g, b, .5)
        threat:Show()
    else
        threat:Hide()
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

local function CreateRaidLayout(self, unit)
	self:RegisterForClicks("AnyUp")

	self:SetScript("OnEnter", function(self)
		UnitFrame_OnEnter(self)
		if (self.Mouseover) then
			self.Mouseover:SetAlpha(0.175)
		end
	end)

	self:SetScript("OnLeave", function(self)
		UnitFrame_OnLeave(self)
		if (self.Mouseover) then
			self.Mouseover:SetAlpha(0)
		end
	end)

    self.Threat = CreateFrame("Frame", nil, self.Health)
    self.Threat:SetTemplate()
    self.Threat:SetAllPoints()
    self.Threat:Hide()
    self.Threat.Override = UpdateThreat

	-- Health bar
	self.Health = CreateFrame("StatusBar", "$parentHealthBar", self)
	self.Health:SetPoints(self)
    self.Health.colorDisconnected = true
    self.Health.colorReaction = true
    self.Health.colorTapping = true
    self.Health.colorClass = true
    self.Health.PostUpdate = UpdateHealth
    self.Health.frequentUpdates = true
	self.Health.Smooth = C["Raidframe"].Smooth
	self.Health.SmoothSpeed = C["Raidframe"].SmoothSpeed * 10

	self.Health:SetTemplate("Transparent", true)

	self.HealthPrediction = K.CreateHealthPrediction(self)

	 -- text/high frame overlay
    self.Overlay = CreateFrame("Frame", nil, self.Health)
    self.Overlay:SetAllPoints(self.Health)
    self.Overlay:SetFrameLevel(self:GetFrameLevel() + 4)

	-- Health text
	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("TOP", self.Health, "CENTER", 0, 4)
	self.Health.Value:SetFont(C["Media"].Font, 11, C["Raidframe"].Outline and "OUTLINE" or "")
	self.Health.Value:SetShadowOffset(C["Raidframe"].Outline and 0 or K.Mult, C["Raidframe"].Outline and -0 or -K.Mult)

	-- Name text
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOM", self.Overlay, "CENTER", 0, 3)
	self.Name:SetFont(C["Media"].Font, C["Media"].FontSize, C["Raidframe"].Outline and "OUTLINE" or "")
	self.Name:SetShadowOffset(C["Raidframe"].Outline and 0 or K.Mult, C["Raidframe"].Outline and -0 or -K.Mult)
	self:Tag(self.Name, "[KkthnxUI:NameVeryShort]")

	-- Afk /offline timer, using frequentUpdates function from oUF tags
	if (C["Raidframe"].ShowNotHereTimer) then
		self.AFKIndicator = self.Overlay:CreateFontString(nil, "OVERLAY")
		self.AFKIndicator:SetPoint("CENTER", self, "BOTTOM", 0, 6)
		self.AFKIndicator:SetFont(C["Media"].Font, 9, "THINOUTLINE")
		self.AFKIndicator:SetShadowOffset(0, 0)
		self.AFKIndicator:SetTextColor(0, 1, 0)
		self:Tag(self.AFKIndicator, "[KkthnxUI:AFK]")
	end

	-- Mouseover darklight
	if (C["Raidframe"].ShowMouseoverHighlight) then
		self.Mouseover = self.Health:CreateTexture(nil, "OVERLAY")
		self.Mouseover:SetAllPoints(self.Health)
		self.Mouseover:SetTexture(C.Media.Texture)
		self.Mouseover:SetVertexColor(0, 0, 0)
		self.Mouseover:SetAlpha(0)
	end

	self.RaidStatusIndicator = self.Overlay:CreateFontString(nil, "OVERLAY")
	self.RaidStatusIndicator:SetFont(C["Media"].Font, 10, "THINOUTLINE")
	self.RaidStatusIndicator:SetAlpha(.8)
	self:Tag(self.RaidStatusIndicator, "[KkthnxUI:RaidStatus]")

	-- Masterlooter icons
	self.MasterLooterIndicator = self.Overlay:CreateTexture(nil, "OVERLAY", self)
	self.MasterLooterIndicator:SetSize(11, 11)
	self.MasterLooterIndicator:SetPoint("TOPLEFT", 8, 6)
	self.MasterLooterIndicator:Show()

	-- Leader icons
	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY", self)
	self.LeaderIndicator:SetSize(12, 12)
	self.LeaderIndicator:SetPoint("TOPLEFT", 1, 6)

	-- Raid icons
	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(12, 12)
	self.RaidTargetIndicator:SetPoint("TOPRIGHT")

	-- Readycheck icons
	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetPoint("CENTER", 0, -8)
	self.ReadyCheckIndicator:SetSize(20, 20)

	-- AuraWatch (corner and center icon)
	if C["Raidframe"].AuraWatch == true then
		K.CreateAuraWatch(self)

		self.RaidDebuffs = CreateFrame("Frame", nil, self.Overlay)
		self.RaidDebuffs:SetHeight(22)
		self.RaidDebuffs:SetWidth(22)
		self.RaidDebuffs:SetPoint("CENTER", self.Health)
		self.RaidDebuffs:SetFrameLevel(self.Health:GetFrameLevel() + 20)
		K.CreateBorder(self.RaidDebuffs, 5)

		self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, "ARTWORK")
		self.RaidDebuffs.icon:SetTexCoord(.1, .9, .1, .9)
		self.RaidDebuffs.icon:SetInside(self.RaidDebuffs)

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

	-- Role indicator
	if (C["Raidframe"].ShowRolePrefix) then
		self.LFDRoleText = self.Health:CreateFontString(nil, "ARTWORK")
		self.LFDRoleText:SetPoint("BOTTOMLEFT", self.Health, 2, 2)
		self.LFDRoleText:SetFont(C["Media"].Font, 10, C["Raidframe"].Outline and "OUTLINE" or "")
		self.LFDRoleText:SetShadowOffset(C["Raidframe"].Outline and 0 or K.Mult, C["Raidframe"].Outline and -0 or -K.Mult)
		self:Tag(self.LFDRoleText, "[KkthnxUI:RaidRole]")
	end

	-- Ressurection icon
	if (C["Raidframe"].ShowResurrection) then
		self.ResurrectIcon = self:CreateTexture(nil, "OVERLAY")
        self.ResurrectIcon:SetPoint("CENTER", 0, 0)
        self.ResurrectIcon:SetSize(22, 22)
        self.ResurrectIcon:Hide()
	end

	self.Range = {
		insideAlpha = 1,
		outsideAlpha = C["UnitframePlugins"].OORAlpha,
	}

	return self
end

oUF:RegisterStyle("oUF_KkthnxRaid", CreateRaidLayout)
oUF:SetActiveStyle("oUF_KkthnxRaid")

if not C["Raidframe"].UseHealLayout then
	local raid = oUF:SpawnHeader("oUF_KkthnxRaid", nil, C["Raidframe"].RaidAsParty and "custom [group:party][group:raid] show; hide" or C["Raidframe"].Enable and "custom [@raid6, exists] show; hide" or "solo, party, raid",
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"showParty", true,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"point", "TOP",
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", "GROUP", -- C.Raid.GroupByValue
	"maxColumns", math.ceil(40 / 5),
	"unitsPerColumn", C["Raidframe"].MaxUnitPerColumn,
	"columnAnchorPoint", "LEFT",
	"initial-width", C["Raidframe"].Width,
	"initial-height", C["Raidframe"].Height,
	"columnSpacing", 6,
	"yOffset", -6,
	"xOffset", 6)

	raid:SetScale(C["Raidframe"].Scale or 1)
	raid:SetFrameStrata("LOW")
	raid:SetPoint(C.Position.UnitFrames.Raid[1], C.Position.UnitFrames.Raid[2], C.Position.UnitFrames.Raid[3], C.Position.UnitFrames.Raid[4], C.Position.UnitFrames.Raid[5])
	Movers:RegisterFrame(raid)
end

-- Main Tank/Assist Frames
if C["Raidframe"].MainTankFrames then
	local raidtank = oUF:SpawnHeader("oUF_Kkthnx_Raid_MT", nil, "raid",
	"oUF-initialConfigFunction", ([[
	self:SetWidth(70)
	self:SetHeight(40)
	]]),
	"showRaid", true,
	"yOffset", -8,
	"groupFilter", "MAINTANK",
	"template", "oUF_Kkthnx_Raid_MT"
	)
	raidtank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
	Movers:RegisterFrame(raidtank)
end