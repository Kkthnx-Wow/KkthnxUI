local K, C, L = unpack(select(2, ...))
if C.Raidframe.Enable ~= true then return end

-- Lua API
local format = string.format
local tinsert = table.insert
local unpack = unpack

-- Wow API
local GetThreatStatusColor = GetThreatStatusColor
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local UnitHasMana = UnitHasMana
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPowerType = UnitPowerType
local UnitThreatSituation = UnitThreatSituation

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: DEAD, PLAYER_OFFLINE, CreateFrame, UnitFrame_OnEnter, UnitFrame_OnLeave

-- Credits to Neav, Renstrom, Grimsbain
local _, ns = ...
local oUF = ns.oUF or oUF
local Movers = K.Movers

local function UpdateThreat(self, _, unit)
	if (self.unit ~= unit) then
		return
	end

	local threatStatus = UnitThreatSituation(unit) or 0
	if (threatStatus == 3) then
		if (self.ThreatText) then
			self.ThreatText:Show()
		end
	end

	if (threatStatus and threatStatus >= 2) then
		local r, g, b = GetThreatStatusColor(threatStatus)
		self.ThreatGlow:SetBackdropBorderColor(r, g, b, 1)
	else
		self.ThreatGlow:SetBackdropBorderColor(0, 0, 0, 0)

		if (self.ThreatText) then
			self.ThreatText:Hide()
		end
	end
end

local function UpdatePower(self, _, unit)
	if (self.unit ~= unit) then
		return
	end

	local _, powerToken = UnitPowerType(unit)

	if (powerToken == "MANA" and UnitHasMana(unit)) then
		if (not self.Power:IsVisible()) then
			self.Health:ClearAllPoints()
			if (C.Raidframe.ManabarHorizontal) then
				self.Health:SetPoint("BOTTOMLEFT", self, 0, 3)
				self.Health:SetPoint("TOPRIGHT", self)
			else
				self.Health:SetPoint("BOTTOMLEFT", self)
				self.Health:SetPoint("TOPRIGHT", self, -3.5, 0)
			end

			self.Power:Show()
		end
	else
		if (self.Power:IsVisible()) then
			self.Health:ClearAllPoints()
			self.Health:SetAllPoints(self)
			self.Power:Hide()
		end
	end
end

local function DeficitValue(self)
	if (self >= 1000) then
		return format("-%.1f", self/1000)
	else
		return self
	end
end

local function GetUnitStatus(unit)
	if (UnitIsDead(unit)) then
		return DEAD
	elseif (UnitIsGhost(unit)) then
		return "Ghost"
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
		if ((cur / max) < C.Raidframe.DeficitThreshold) then
			healthString = format("|cff%02x%02x%02x%s|r", 0.9 * 255, 0 * 255, 0 * 255, DeficitValue(max-cur))
		else
			healthString = ""
		end
	end

	return healthString
end

local function UpdateHealth(Health, unit, cur, max)
	if (not UnitIsPlayer(unit)) then
		local r, g, b = K.ColorGradient(cur, max, 0, .8 ,0 ,.8 ,.8 ,0 ,.8 ,0 ,0)
		Health:SetStatusBarColor(r, g, b)
		Health.Background:SetVertexColor(r * 0.1, g * 0.1, b * 0.1)
	end

	Health.Value:SetText(GetHealthText(unit, cur, max))
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

	self:SetBackdrop({
		bgFile = C.Media.Blank,
		insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult},
	})
	self:SetBackdropColor(0.019, 0.019, 0.019, 0.9)

	K.CreateBorder(self)
	self:SetBorderColor(unpack(C.Media.Border_Color))

	-- Health bar
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(C.Media.Texture, "ARTWORK")
	self.Health:SetAllPoints(self)
	self.Health:SetOrientation(C.Raidframe.HorizontalHealthBars and "HORIZONTAL" or "VERTICAL")

	-- Health background
	self.Health.Background = self.Health:CreateTexture(nil, "BORDER")
	self.Health.Background:SetAllPoints()
	self.Health.Background:SetTexture(C.Media.Blank)
	self.Health.Background:SetColorTexture(0.019, 0.019, 0.019, 0.9)

	self.Health.PostUpdate = UpdateHealth
	self.Health.frequentUpdates = true

	self.Health.colorClass = true
	self.Health.colorDisconnected = true
	self.Health.Smooth = true
	self.Health.colorTapping = true
	self.Health.colorReaction = true

	-- Health text
	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("TOP", self.Health, "CENTER", 0, 4)
	self.Health.Value:SetFont(C.Media.Font, 11)
	self.Health.Value:SetShadowOffset(K.Mult, -K.Mult)

	-- Name text
	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOM", self.Health, "CENTER", 0, 3)
	self.Name:SetFont(C.Media.Font, C.Media.Font_Size)
	self.Name:SetShadowOffset(K.Mult, -K.Mult)
	self:Tag(self.Name, "[KkthnxUI:NameColor][KkthnxUI:NameVeryShort]")

	-- Power bar
	if (C.Raidframe.ManabarShow) then
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetStatusBarTexture(C.Media.Texture, "ARTWORK")

		if (C.Raidframe.ManabarHorizontal) then
			self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
			self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
			self.Power:SetOrientation("HORIZONTAL")
			self.Power:SetHeight(2.5)
		else
			self.Power:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 1, 0)
			self.Power:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", 1, 0)
			self.Power:SetOrientation("VERTICAL")
			self.Power:SetWidth(2.5)
		end

		self.Power.colorPower = true
		self.Power.Smooth = true

		self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetColorTexture(.6, .6, .6)
		self.Power.bg.multiplier = 0.2

		tinsert(self.__elements, UpdatePower)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UpdatePower)
		UpdatePower(self, _, unit)
	end

	-- Heal prediction
	local mhpb = CreateFrame("StatusBar", nil, self)
	mhpb:SetStatusBarTexture(C.Media.Texture, "ARTWORK")
	mhpb:SetStatusBarColor(1, 1, 0, 0.6)

	local ohpb = CreateFrame("StatusBar", nil, self)
	ohpb:SetStatusBarTexture(C.Media.Texture, "ARTWORK")
	ohpb:SetStatusBarColor(0, 1, 0.5, 0.6)

	local ahpb = CreateFrame("StatusBar", nil, self)
	ahpb:SetStatusBarTexture(C.Media.Texture, "ARTWORK")
	ahpb:SetStatusBarColor(1, 1, 0, 0.6)

	if (C.Raidframe.HorizontalHealthBars) then
		mhpb:SetOrientation("HORIZONTAL")
		mhpb:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
		mhpb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
		mhpb:SetWidth(self:GetWidth(true))

		ohpb:SetOrientation("HORIZONTAL")
		ohpb:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
		ohpb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
		ohpb:SetWidth(self:GetWidth(true))

		ahpb:SetOrientation("HORIZONTAL")
		ahpb:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
		ahpb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT")
		ahpb:SetWidth(self:GetWidth(true))
	else
		mhpb:SetOrientation("VERTICAL")
		mhpb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "TOPLEFT")
		mhpb:SetPoint("BOTTOMRIGHT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
		mhpb:SetWidth(self:GetHeight(true))

		ohpb:SetOrientation("VERTICAL")
		ohpb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "TOPLEFT")
		ohpb:SetPoint("BOTTOMRIGHT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
		ohpb:SetWidth(self:GetHeight(true))

		ahpb:SetOrientation("VERTICAL")
		ahpb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "TOPLEFT")
		ahpb:SetPoint("BOTTOMRIGHT", self.Health:GetStatusBarTexture(), "TOPRIGHT")
		ahpb:SetWidth(self:GetHeight(true))
	end

	self.HealPrediction = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = ahpb,
		maxOverflow = 1,
		frequentUpdates = true
	}

	-- Afk /offline timer, using frequentUpdates function from oUF tags
	if (C.Raidframe.ShowNotHereTimer) then
		self.NotHere = self.Health:CreateFontString(nil, "OVERLAY")
		self.NotHere:SetPoint("CENTER", self, "BOTTOM")
		self.NotHere:SetFont(C.Media.Font, 10, "THINOUTLINE")
		self.NotHere:SetShadowOffset(0, 0)
		self.NotHere:SetTextColor(0, 1, 0)
		self:Tag(self.NotHere, "[KkthnxUI:StatusTimer]")
	end

	-- Mouseover darklight
	if (C.Raidframe.ShowMouseoverHighlight) then
		self.Mouseover = self.Health:CreateTexture(nil, "OVERLAY")
		self.Mouseover:SetAllPoints(self.Health)
		self.Mouseover:SetTexture(C.Media.Texture)
		self.Mouseover:SetVertexColor(0, 0, 0)
		self.Mouseover:SetAlpha(0)
	end

	-- Threat glow
	self.ThreatGlow = CreateFrame("Frame", nil, self)
	self.ThreatGlow:SetPoint("TOPLEFT", self, "TOPLEFT", -5, 5)
	self.ThreatGlow:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 5, -5)
	self.ThreatGlow:SetBackdrop({edgeFile = C.Media.Glow, edgeSize = 3})
	self.ThreatGlow:SetBackdropBorderColor(0, 0, 0, 0)
	self.ThreatGlow:SetFrameLevel(self:GetFrameLevel() - 1)
	self.ThreatGlow.ignore = true

	-- Threat text
	if (C.Raidframe.ShowThreatText) then
		self.ThreatText = self.Health:CreateFontString(nil, "OVERLAY")
		self.ThreatText:SetPoint("CENTER", self, "BOTTOM")
		self.ThreatText:SetFont(C.Media.Font, 11, "THINOUTLINE")
		self.ThreatText:SetShadowOffset(0, 0)
		self.ThreatText:SetTextColor(1, 0, 0)
		self.ThreatText:SetText("AGGRO")
	end

	tinsert(self.__elements, UpdateThreat)
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", UpdateThreat)
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", UpdateThreat)

	-- Masterlooter icons
	self.MasterLooter = self.Health:CreateTexture(nil, "OVERLAY", self)
	self.MasterLooter:SetSize(11, 11)
	self.MasterLooter:SetPoint("RIGHT", self, "TOPRIGHT", -1, 1)

	-- Leader icons
	self.Leader = self.Health:CreateTexture(nil, "OVERLAY", self)
	self.Leader:SetSize(12, 12)
	self.Leader:SetPoint("LEFT", self.Health, "TOPLEFT", 1, 2)

	-- Raid icons
	self.RaidIcon = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidIcon:SetSize(16, 16)
	self.RaidIcon:SetPoint("CENTER", self, "TOP")

	-- Readycheck icons
	self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
	self.ReadyCheck:SetPoint("CENTER")
	self.ReadyCheck:SetSize(20, 20)
	self.ReadyCheck.delayTime = 2
	self.ReadyCheck.fadeTime = 1

	-- AuraWatch (corner and center icon)
	if C.Raidframe.AuraWatch then
		K.CreateAuraWatch(self)
		local RaidDebuffs = CreateFrame("Frame", nil, self)
		RaidDebuffs:SetHeight(22)
		RaidDebuffs:SetWidth(22)
		RaidDebuffs:SetPoint("CENTER", self.Health)
		RaidDebuffs:SetFrameLevel(self.Health:GetFrameLevel() + 20)
		RaidDebuffs:SetBackdrop(K.BorderBackdrop)
		RaidDebuffs:SetBackdropColor(0, 0, 0)
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "ARTWORK")
		RaidDebuffs.icon:SetTexCoord(.1, .9, .1, .9)
		RaidDebuffs.icon:SetInside(RaidDebuffs)
		RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs)
		RaidDebuffs.cd:SetAllPoints(RaidDebuffs)
		RaidDebuffs.cd:SetHideCountdownNumbers(true)
		RaidDebuffs.ShowDispelableDebuff = true
		RaidDebuffs.FilterDispelableDebuff = true
		RaidDebuffs.MatchBySpellName = true
		RaidDebuffs.ShowBossDebuff = true
		RaidDebuffs.BossDebuffPriority = 5
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, "OVERLAY")
		RaidDebuffs.count:SetFont(C.Media.Font, 12, "OUTLINE")
		RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		RaidDebuffs.count:SetTextColor(1, .9, 0)
		RaidDebuffs.SetDebuffTypeColor = RaidDebuffs.SetBackdropColor
		RaidDebuffs.Debuffs = K.RaidDebuffsTracking

		self.RaidDebuffs = RaidDebuffs
	end

	-- Role indicator
	if (C.Raidframe.ShowRolePrefix) then
		self.LFDRoleText = self.Health:CreateFontString(nil, "ARTWORK")
		self.LFDRoleText:SetPoint("BOTTOMLEFT", self.Health, 2, 2)
		self.LFDRoleText:SetFont(C.Media.Font, 10)
		self.LFDRoleText:SetShadowOffset(K.Mult, -K.Mult)
		self:Tag(self.LFDRoleText, "[KkthnxUI:RaidRole]")
	end

	-- Ressurection icon....ehm text!
	if (C.Raidframe.ShowResurrectText) then
		self.ResurrectIcon = self.Health:CreateFontString(nil, "OVERLAY")
		self.ResurrectIcon:SetPoint("CENTER", self, "BOTTOM", 0, 1)
		self.ResurrectIcon:SetFont(C.Media.Font, 11, "THINOUTLINE")
		self.ResurrectIcon:SetShadowOffset(0, 0)
		self.ResurrectIcon:SetTextColor(0.1, 1, 0.1)
		self.ResurrectIcon:SetText("RES") -- RESURRECT

		self.ResurrectIcon.Override = function()
			local incomingResurrect = UnitHasIncomingResurrection(self.unit)

			if (incomingResurrect) then
				self.ResurrectIcon:Show()

				if (self.NotHere) then
					self.NotHere:Hide()
				end
			else
				self.ResurrectIcon:Hide()

				if (self.NotHere) then
					self.NotHere:Show()
				end
			end
		end
	end

	-- Playertarget border
	self:RegisterEvent("PLAYER_TARGET_CHANGED", function()
		if (UnitIsUnit("target", self.unit)) then
			self:SetBorderColor(1, 1, 1)
		else
			self:SetBorderColor(unpack(C.Media.Border_Color))
		end
	end)

	-- Range check
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.3,
	}

	self.SpellRange = {
		insideAlpha = 1,
		outsideAlpha = 0.3,
	}

	return self
end

oUF:RegisterStyle("oUF_Kkthnx_Raid", CreateRaidLayout)
oUF:RegisterStyle("oUF_Kkthnx_Raid_MT", CreateRaidLayout)
oUF:SetActiveStyle("oUF_Kkthnx_Raid")

if not C.Raidframe.UseHealLayout then
	local raid = oUF:SpawnHeader("oUF_Raid", nil, C.Raidframe.RaidAsParty and "custom [group:party][group:raid] show; hide" or C.Unitframe.Party and "custom [@raid6, exists] show; hide" or "solo, party, raid",
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
	"unitsPerColumn", C.Raidframe.MaxUnitPerColumn,
	"columnAnchorPoint", "LEFT",
	"initial-width", C.Raidframe.Width,
	"initial-height", C.Raidframe.Height,
	"columnSpacing", K.Scale(8),
	"yOffset", -K.Scale(8),
	"xOffset", K.Scale(8))

	raid:SetScale(C.Raidframe.Scale)
	raid:SetFrameStrata("LOW")
	raid:SetPoint(unpack(C.Position.UnitFrames.Raid))
	Movers:RegisterFrame(raid)
	raid:Show()
end

-- Main Tank/Assist Frames
if C.Raidframe.MainTankFrames then
	oUF:SetActiveStyle("oUF_Kkthnx_Raid_MT")

	local tanks = oUF:SpawnHeader("oUF_Kkthnx_Raid_MT", nil, "raid, party, solo",
	"oUF-initialConfigFunction", ([[
	self:SetWidth(%d)
	self:SetHeight(%d)
	]]):format(K.Scale(C.Raidframe.Width), K.Scale(C.Raidframe.Height)),
	"showRaid", true,
	"showParty", false,
	"yOffset", -K.Scale(8),
	"template", "oUF_KkthnxRaid_MT_Target_Template", -- Target
	"sortMethod", "INDEX",
	"groupFilter", "MAINTANK, MAINASSIST")

	tanks:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
	tanks:SetScale(1)
	tanks:SetFrameStrata("LOW")
	Movers:RegisterFrame(tanks)
	tanks:Show()
end