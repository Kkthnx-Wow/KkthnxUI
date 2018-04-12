local K, C, L = unpack(select(2, ...))
if C["Raidframe"].Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

-- Lua API
local _G = _G
local string_format = string.format
local table_insert = table.insert
local tonumber = tonumber

-- Wow API
local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GetThreatStatusColor = _G.GetThreatStatusColor
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave
local UnitHasMana = _G.UnitHasMana
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction
local UnitThreatSituation = _G.UnitThreatSituation

local RaidframeFont = K.GetFont(C["Raidframe"].Font)
local RaidframeTexture = K.GetTexture(C["Raidframe"].Texture)
local Movers = K["Movers"]

local GHOST = GetSpellInfo(8326)
if GetLocale() == "deDE" then
	GHOST = "Geist"
end

local function UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then
		return
	end

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

local function CreateRaidLayout(self, unit)
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
	self:Tag(self.Health.Value, "[KkthnxUI:HealthDeficit]")

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
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdatePower)
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
		self.RaidRoleText:SetFont(C["Media"].Font, 10, C["Raidframe"].Outline and "OUTLINE" or "")
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
			-- we don't want those "1"'s cluttering up the display
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

	if (C["Raidframe"].TargetHighlight) then
		self.TargetHighlight = CreateFrame("Frame", nil, self)
		self.TargetHighlight:SetBackdrop({edgeFile = [[Interface\AddOns\KkthnxUI\Media\Border\BorderTickGlow.tga]], edgeSize = 10})
		self.TargetHighlight:SetPoint("TOPLEFT", -7, 7)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", 7, -7)
		self.TargetHighlight:SetFrameStrata("BACKGROUND")
		self.TargetHighlight:SetFrameLevel(0)
		self.TargetHighlight:Hide()

		local function UpdateTargetGlow(self)
			if not self.unit then
				return
			end
			local unit = self.unit

			if (UnitIsUnit("target", self.unit)) then
				self.TargetHighlight:Show()
				local reaction = UnitReaction(unit, 'player')
				if UnitIsPlayer(unit) then
					local _, class = UnitClass(unit)
					if class then
						local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
						self.TargetHighlight:SetBackdropBorderColor(color.r, color.g, color.b)
					else
						self.TargetHighlight:SetBackdropBorderColor(1, 1, 1)
					end
				elseif reaction then
					local color = FACTION_BAR_COLORS[reaction]
					self.TargetHighlight:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					self.TargetHighlight:SetBackdropBorderColor(1, 1, 1)
				end
			else
				self.TargetHighlight:Hide()
			end
		end

		table_insert(self.__elements, UpdateTargetGlow)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTargetGlow)
	end
end

oUF:RegisterStyle("oUF_KkthnxUI_Raidframes", CreateRaidLayout)
oUF:SetActiveStyle("oUF_KkthnxUI_Raidframes")
if C["Raidframe"].Enable then
	if C["Raidframe"].RaidLayout.Value == "Healer" then
		local raid = {}
		for i = 1, C["Raidframe"].RaidGroups do
			local raidgroup = oUF:SpawnHeader("oUF_RaidHealer"..i, nil, C["Unitframe"].PartyAsRaid and "custom [group:party] show" or "custom [group:raid] show; hide",
			"oUF-initialConfigFunction", [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute("initial-width"))
			self:SetHeight(header:GetAttribute("initial-height"))
			]],
			"initial-width", 60,
			"initial-height", 26,
			"showParty", true,
			"showRaid", true,
			"showPlayer", true,
			"showSolo", false,
			"groupFilter", tostring(i),
			"groupBy", C["Raidframe"].GroupBy.Value and "ASSIGNEDROLE",
			"groupingOrder", C["Raidframe"].GroupBy.Value and "TANK, HEALER, DAMAGER, NONE",
			"sortMethod", C["Raidframe"].GroupBy.Value and "NAME",
			"point", "LEFT",
			"maxColumns", 5,
			"unitsPerColumn", 1,
			"columnSpacing", 6,
			"columnAnchorPoint", "LEFT"
			)
			if i == 1 then
				raidgroup:SetPoint("TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 86, -12)
			else
				raidgroup:SetPoint("TOPLEFT", raid[i-1], "BOTTOMLEFT", 0, -7)
			end
			Movers:RegisterFrame(raidgroup)
			raid[i] = raidgroup
		end
	elseif C["Raidframe"].RaidLayout.Value == "Damage" then
		local raid = {}
		for i = 1, C["Raidframe"].RaidGroups do
			local raidgroup = oUF:SpawnHeader("oUF_RaidDamage"..i, nil, C["Unitframe"].PartyAsRaid and "custom [group:party] show" or "custom [group:raid] show; hide",
			"oUF-initialConfigFunction", [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute("initial-width"))
			self:SetHeight(header:GetAttribute("initial-height"))
			]],
			"initial-width", 60,
			"initial-height", 30,
			"showParty", true,
			"showRaid", true,
			"showPlayer", true,
			"showSolo", false,
			"yOffset", -6,
			"point", "TOPLEFT",
			"groupFilter", tostring(i),
			"groupBy", C["Raidframe"].GroupBy.Value and "ASSIGNEDROLE",
			"groupingOrder", C["Raidframe"].GroupBy.Value and "TANK, HEALER, DAMAGER, NONE",
			"sortMethod", C["Raidframe"].GroupBy.Value and "NAME",
			"maxColumns", 5,
			"unitsPerColumn", 1,
			"columnSpacing", 6,
			"columnAnchorPoint", "TOP")
			if i == 1 then
				raidgroup:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -24)
			elseif i == 5 then
				raidgroup:SetPoint("TOPLEFT", raid[1], "TOPRIGHT", 7, 0)
			else
				raidgroup:SetPoint("TOPLEFT", raid[i-1], "BOTTOMLEFT", 0, -7)
			end
			Movers:RegisterFrame(raidgroup)
			raid[i] = raidgroup
		end
	end
else
	local raid = {}
	for i = 1, C["Raidframe"].RaidGroups do
		local raidgroup = oUF:SpawnHeader("oUF_RaidDamage"..i, nil, C["Unitframe"].PartyAsRaid and "custom [group:party] show" or "custom [group:raid] show; hide",
		"oUF-initialConfigFunction", [[
		local header = self:GetParent()
		self:SetWidth(header:GetAttribute("initial-width"))
		self:SetHeight(header:GetAttribute("initial-height"))
		]],
		"initial-width", 60,
		"initial-height", 30,
		"showParty", true,
		"showRaid", true,
		"showPlayer", true,
		"showSolo", false,
		"yOffset", -6,
		"point", "TOPLEFT",
		"groupFilter", tostring(i),
		"groupBy", C["Raidframe"].GroupBy.Value and "ASSIGNEDROLE",
		"groupingOrder", C["Raidframe"].GroupBy.Value and "TANK, HEALER, DAMAGER, NONE",
		"sortMethod", C["Raidframe"].GroupBy.Value and "NAME",
		"maxColumns", 5,
		"unitsPerColumn", 1,
		"columnSpacing", 6,
		"columnAnchorPoint", "TOP")
		if i == 1 then
			raidgroup:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -24)
		elseif i == 5 then
			raidgroup:SetPoint("TOPLEFT", raid[1], "TOPRIGHT", 7, 0)
		else
			raidgroup:SetPoint("TOPLEFT", raid[i-1], "BOTTOMLEFT", 0, -7)
		end
		Movers:RegisterFrame(raidgroup)
		raid[i] = raidgroup
	end
end

-- Main Tank/Assist Frames
if C["Raidframe"].MainTankFrames then
	local raidtank = oUF:SpawnHeader("oUF_Raid_MT", nil, "raid",
	"oUF-initialConfigFunction", [[
	self:SetWidth(62)
	self:SetHeight(34)
	]],
	"showRaid", true,
	"yOffset", -8,
	"groupFilter", "MAINTANK",
	"template", "oUF_Raid_MT"
	)
	raidtank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
	Movers:RegisterFrame(raidtank)
end