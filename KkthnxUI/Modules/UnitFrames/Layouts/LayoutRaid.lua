local K, C, L = unpack(select(2, ...))
if C.Raidframe.Enable ~= true then return end

-- Lua API
local _G = _G
local string_format = string.format
local table_insert = table.insert
local unpack = unpack

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

local function UpdateThreat(self, _, unit)
	if (self.unit ~= unit) or not unit then return end

	local threatStatus = UnitThreatSituation(unit) or 0
	if (threatStatus == 3) then
		if (self.ThreatText) then
			self.ThreatText:Show()
		end
	end

	if (threatStatus and threatStatus >= 2) then
		local r, g, b = GetThreatStatusColor(threatStatus)
		self:SetBackdropBorderColor(r, g, b, 1)
	else
		self:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3], 1)

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
			self.Health:SetPoint("BOTTOMLEFT", self, 0, 3)
			self.Health:SetPoint("TOPRIGHT", self)
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
		return string_format("-%.1f", self/1000)
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
		-- self.bg:SetVertexColor(r * 0.6, g * 0.6, b * 0.6)
		self.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2, 0.8)
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

	self:SetBackdrop({
		bgFile = C.Media.Blank,
		insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult},
	})
	self:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

	K.CreateBorder(self, -1)
	self:SetBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])

	-- Health bar
	self.Health = K.CreateStatusBar(self, "$parentHealthBar")
	self.Health:SetStatusBarTexture(C.Media.Texture, "ARTWORK")
	self.Health:SetAllPoints(self)

	-- Health background
	self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
	self.Health.bg:SetAllPoints()
	self.Health.bg:SetTexture(C.Media.Blank)
	self.Health.bg.multiplier = 0.2

	self.Health.PostUpdate = UpdateHealth
	self.Health.frequentUpdates = true

	self.Health.colorClass = true
	self.Health.colorDisconnected = true
	self.Health.colorTapping = true
	self.Health.colorReaction = true
	self.Health.Smooth = C.Raidframe.Smooth

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
		self.Power = K.CreateStatusBar(self, "$parenPowerBar")
		self.Power:SetStatusBarTexture(C.Media.Texture, "ARTWORK")
		self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
		self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
		self.Power:SetHeight(2.5)

		self.Power.colorPower = true
		self.Power.Smooth = C.Raidframe.Smooth

		self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
		self.Power.bg:SetAllPoints(self.Power)
		self.Power.bg:SetColorTexture(.6, .6, .6)
		self.Power.bg.multiplier = 0.2

		table_insert(self.__elements, UpdatePower)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UpdatePower)
		UpdatePower(self, _, unit)
	end

	-- Heal prediction
	self.Absorb = {
		texture = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Absorb",
		tile = true,
		drawLayer = {"BACKGROUND", 4},
		colour = {.3, .7, 1},
		alpha = .5
	}

	do
		local myBar = CreateFrame("StatusBar", nil, self.Health)
		myBar:SetStatusBarTexture(C.Media.Texture)
		myBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 2)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarColor(0, 1, .5, .5)
		myBar:SetWidth(self:GetWidth())
		myBar.Smooth = C.Raidframe.Smooth

		local otherBar = CreateFrame("StatusBar", nil, self.Health)
		otherBar:SetStatusBarTexture(C.Media.Texture)
		otherBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 3)
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarColor(0, 1, 0, .5)
		otherBar:SetWidth(self:GetWidth())
		otherBar.Smooth = C.Raidframe.Smooth

		local healAbsorbBar = CreateFrame("StatusBar", nil, self.Health)
		healAbsorbBar:SetStatusBarTexture(C.Media.Texture)
		healAbsorbBar:GetStatusBarTexture():SetDrawLayer("BACKGROUND", 5)
		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		healAbsorbBar:SetStatusBarColor(0, 0, 0, .5)
		healAbsorbBar:SetWidth(self:GetWidth())
		healAbsorbBar.Smooth = C.Raidframe.Smooth

		self.HealPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			healAbsorbBar = healAbsorbBar,
			maxOverflow = 1,
			frequentUpdates = true
		}
	end

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

	-- Threat text
	if (C.Raidframe.ShowThreatText) then
		self.ThreatText = self.Health:CreateFontString(nil, "OVERLAY")
		self.ThreatText:SetPoint("CENTER", self, "BOTTOM")
		self.ThreatText:SetFont(C.Media.Font, 10, "THINOUTLINE")
		self.ThreatText:SetShadowOffset(0, 0)
		self.ThreatText:SetTextColor(1, 0, 0)
		self.ThreatText:SetText("AGGRO")
	end

	table_insert(self.__elements, UpdateThreat)
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

	-- AuraWatch (corner and center icon)
	if C.Raidframe.AuraWatch == true then
		K.CreateAuraWatch(self)

		self.RaidDebuffs = CreateFrame("Frame", nil, self)
		self.RaidDebuffs:SetHeight(22)
		self.RaidDebuffs:SetWidth(22)
		self.RaidDebuffs:SetPoint("CENTER", self.Health)
		self.RaidDebuffs:SetFrameLevel(self.Health:GetFrameLevel() + 20)
		K.CreateBorder(self.RaidDebuffs, 1)

		self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, "ARTWORK")
		self.RaidDebuffs.icon:SetTexCoord(.1, .9, .1, .9)
		self.RaidDebuffs.icon:SetInside(self.RaidDebuffs)

		self.RaidDebuffs.cd = CreateFrame("Cooldown", nil, self.RaidDebuffs)
		self.RaidDebuffs.cd:SetAllPoints(self.RaidDebuffs)
		self.RaidDebuffs.cd:SetHideCountdownNumbers(true)

		self.RaidDebuffs.ShowDispelableDebuff = true
		self.RaidDebuffs.FilterDispelableDebuff = true
		self.RaidDebuffs.MatchBySpellName = true
		self.RaidDebuffs.ShowBossDebuff = true
		self.RaidDebuffs.BossDebuffPriority = 5

		self.RaidDebuffs.count = self.RaidDebuffs:CreateFontString(nil, "OVERLAY")
		self.RaidDebuffs.count:SetFont(C.Media.Font, 12, "OUTLINE")
		self.RaidDebuffs.count:SetPoint("BOTTOMRIGHT", self.RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		self.RaidDebuffs.count:SetTextColor(1, .9, 0)

		self.RaidDebuffs.SetDebuffTypeColor = self.RaidDebuffs.SetBackdropBorderColor
		self.RaidDebuffs.Debuffs = K.RaidDebuffs
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
			self:SetBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
		end
	end)

	self.Range = {
		insideAlpha = 1,
		outsideAlpha = C.UnitframePlugins.OORAlpha,
	}

	return self
end

oUF:RegisterStyle("oUF_Kkthnx_Raid", CreateRaidLayout)
oUF:SetActiveStyle("oUF_Kkthnx_Raid")

if not C.Raidframe.UseHealLayout then
	local raid = oUF:SpawnHeader("oUF_Kkthnx_Raid", nil, C.Raidframe.RaidAsParty and "custom [group:party][group:raid] show; hide" or C.Raidframe.Enable and "custom [@raid6, exists] show; hide" or "solo, party, raid",
	-- local raid = oUF:SpawnHeader("oUF_Kkthnx_Raid", nil, C.Raidframe.Enable and "custom [@raid6, exists] show; hide" or "solo, party, raid")
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

	raid:SetScale(C.Raidframe.Scale or 1)
	raid:SetFrameStrata("LOW")
	raid:SetPoint(unpack(C.Position.UnitFrames.Raid))
	Movers:RegisterFrame(raid)
end

-- Main Tank/Assist Frames
if C.Raidframe.MainTankFrames then
	local raidtank = oUF:SpawnHeader("oUF_Kkthnx_Raid_MT", nil, "raid",
	"oUF-initialConfigFunction", ([[
	self:SetWidth(70)
	self:SetHeight(40)
	]]),
	"showRaid", true,
	"yOffset", -K.Scale(8),
	"groupFilter", "MAINTANK",
	"template", "oUF_Kkthnx_Raid_MT"
	)
	raidtank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
	Movers:RegisterFrame(raidtank)
end