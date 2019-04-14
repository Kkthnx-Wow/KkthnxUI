local K, C = unpack(select(2, ...))
if C["Raid"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Raid.lua code!")
	return
end

local _G = _G
local table_insert = table.insert
local select = select

local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GetThreatStatusColor = _G.GetThreatStatusColor
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitPowerType = _G.UnitPowerType
local UnitReaction = _G.UnitReaction
local UnitThreatSituation = _G.UnitThreatSituation

local function UpdateThreat(self, _, unit)
	if (self.unit ~= unit) then
		return
	end

	local situation = UnitThreatSituation(unit)
	if (situation and situation > 0) then
		local r, g, b = GetThreatStatusColor(situation)
		self:SetBackdropBorderColor(r, g, b)
	else
		self:SetBackdropBorderColor()
	end
end

local function UpdateRaidPower(self, _, unit)
	if self.unit ~= unit then
		return
	end

	local _, powerToken = UnitPowerType(unit)
	if powerToken == "MANA" then
		if not self.Power:IsVisible() then
			self.Health:ClearAllPoints()
			self.Health:SetPoint("BOTTOMLEFT", self, 0, 7)
			self.Health:SetPoint("TOPRIGHT", self)
			self.Power:Show()
		end
	else
		if self.Power:IsVisible() then
			self.Health:ClearAllPoints()
			self.Health:SetAllPoints(self)
			self.Power:Hide()
		end
	end
end

function Module:CreateRaid()
	local RaidframeFont = K.GetFont(C["Raid"].Font)
	local RaidframeTexture = K.GetTexture(C["Raid"].Texture)

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", function(self)
		UnitFrame_OnEnter(self)

		if (self.Highlight) then
			self.Highlight:Show()
		end
	end)

	self:SetScript("OnLeave", function(self)
		UnitFrame_OnLeave(self)

		if (self.Highlight) then
			self.Highlight:Hide()
		end
	end)

	self:CreateBorder()

	self.Health = CreateFrame("StatusBar", "$parentHealthBar", self)
	self.Health:SetFrameStrata("LOW")
	self.Health:SetFrameLevel(self:GetFrameLevel() - 0)
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(RaidframeTexture)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, 0, -9)
	self.Health.Value:SetFontObject(RaidframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 11, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, C["Raid"].HealthFormat.Value)

	self.Health.Smooth = C["Raid"].Smooth
	self.Health.SmoothSpeed = C["Raid"].SmoothSpeed * 10
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	if C["Raid"].ManabarShow then
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetFrameStrata("LOW")
		self.Power:SetFrameLevel(self:GetFrameLevel())
		self.Power:SetHeight(5)
		self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
		self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
		self.Power:SetStatusBarTexture(RaidframeTexture)

		self.Power.Smooth = C["Raid"].Smooth
		self.Power.SmoothSpeed = C["Raid"].SmoothSpeed * 10
		self.Power.colorPower = true
		self.Power.frequentUpdates = true

		self.Power.Background = self.Power:CreateTexture(nil, "BORDER")
		self.Power.Background:SetAllPoints(self.Power)
		self.Power.Background:SetColorTexture(.2, .2, .2)
		self.Power.Background.multiplier = 0.3

		table_insert(self.__elements, UpdateRaidPower)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateRaidPower)
		UpdateRaidPower(self, _, unit)
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 3, -15)
	self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -3, -15)
	self.Name:SetFontObject(RaidframeFont)
	self.Name:SetWordWrap(false)
	if C["Raid"].ShowRolePrefix then
		self:Tag(self.Name, "[KkthnxUI:Role][KkthnxUI:NameShort]")
	else
		self:Tag(self.Name, "[KkthnxUI:NameShort]")
	end

	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(self:GetFrameLevel() + 4)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY", 2)
	self.ReadyCheckIndicator:SetSize(self:GetHeight() - 4, self:GetHeight() - 4)
	self.ReadyCheckIndicator:SetPoint("CENTER")
	self.ReadyCheckIndicator.finishedTime = 5
	self.ReadyCheckIndicator.fadeTime = 3

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(30, 30)
	self.ResurrectIndicator:SetPoint("CENTER", 0, -3)

	--self.SummonIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
 --	self.SummonIndicator:SetSize(30, 30)
 --	self.SummonIndicator:SetPoint("CENTER", 0, -3)

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(12, 12)
	self.LeaderIndicator:SetPoint("TOPLEFT", -2, 7)

	if C["Raid"].ShowNotHereTimer then
		self.AFKIndicator = self:CreateFontString(nil, "OVERLAY")
		self.AFKIndicator:SetPoint("CENTER", self.Overlay, "BOTTOM", 0, 6)
		self.AFKIndicator:SetFontObject(RaidframeFont)
		self.AFKIndicator:SetFont(select(1, self.AFKIndicator:GetFont()), 10, select(3, self.AFKIndicator:GetFont()))
		self.AFKIndicator:SetTextColor(1, 0, 0)
		self:Tag(self.AFKIndicator, "[KkthnxUI:AFK]")
	end

	if C["Raid"].AuraWatch then
		Module:CreateAuraWatch(self)

		self.RaidDebuffs = CreateFrame("Frame", nil, self.Health)
		self.RaidDebuffs:SetHeight(C["Raid"].AuraDebuffIconSize)
		self.RaidDebuffs:SetWidth(C["Raid"].AuraDebuffIconSize)
		self.RaidDebuffs:SetPoint("CENTER", self.Health)
		self.RaidDebuffs:SetFrameLevel(self.Health:GetFrameLevel() + 20)
		self.RaidDebuffs:CreateBorder()

		self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, "ARTWORK")
		self.RaidDebuffs.icon:SetTexCoord(.1, .9, .1, .9)
		self.RaidDebuffs.icon:SetAllPoints(self.RaidDebuffs)

		self.RaidDebuffs.cd = CreateFrame("Cooldown", nil, self.RaidDebuffs, "CooldownFrameTemplate")
		self.RaidDebuffs.cd:SetAllPoints(self.RaidDebuffs, 1, 1)
		self.RaidDebuffs.cd:SetReverse(true)
		self.RaidDebuffs.cd.noOCC = true
		self.RaidDebuffs.cd.noCooldownCount = true
		self.RaidDebuffs.cd:SetHideCountdownNumbers(true)

		self.RaidDebuffs.showDispellableDebuff = true
		self.RaidDebuffs.onlyMatchSpellID = true
		self.RaidDebuffs.FilterDispellableDebuff = true

		-- self.RaidDebuffs.forceShow = true -- TEST

		self.RaidDebuffs.time = self.RaidDebuffs:CreateFontString(nil, "OVERLAY")
		self.RaidDebuffs.time:SetFont(C["Media"].Font, 12, "OUTLINE")
		self.RaidDebuffs.time:SetPoint("CENTER", self.RaidDebuffs, 0, 0)

		self.RaidDebuffs.count = self.RaidDebuffs:CreateFontString(nil, "OVERLAY")
		self.RaidDebuffs.count:SetFont(C["Media"].Font, 12, "OUTLINE")
		self.RaidDebuffs.count:SetPoint("BOTTOMRIGHT", self.RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		self.RaidDebuffs.count:SetTextColor(1, .9, 0)
	end

	self.ThreatIndicator = {}
	self.ThreatIndicator.IsObjectType = function() end
	self.ThreatIndicator.Override = UpdateThreat

	if C["Raid"].ShowMouseoverHighlight then
		Module.MouseoverHealth(self, "raid")
	end

	if C["Raid"].TargetHighlight then
		self.TargetHighlight = CreateFrame("Frame", nil, self)
		self.TargetHighlight:SetBackdrop({edgeFile = [[Interface\AddOns\KkthnxUI\Media\Border\BorderTickGlow.tga]], edgeSize = 10})
		self.TargetHighlight:SetPoint("TOPLEFT", -7, 7)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", 7, -7)
		self.TargetHighlight:SetFrameStrata("BACKGROUND")
		self.TargetHighlight:SetFrameLevel(0)
		self.TargetHighlight:Hide()

		local function UpdateRaidTargetGlow()
			if not self.unit then
				return
			end

			local unit = self.unit
			local isPlayer = unit and UnitIsPlayer(unit)
			local reaction = unit and UnitReaction(unit, "player")

			if UnitIsUnit(unit, "target") then
				if isPlayer then
					local _, class = UnitClass(unit)
					if class then
						local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
						if color then
							if self.TargetHighlight then
								self.TargetHighlight:Show()
								self.TargetHighlight:SetBackdropBorderColor(color.r, color.g, color.b, 1)
							end
						end
					end
				elseif reaction then
					local color = FACTION_BAR_COLORS[reaction]
					if color then
						if self.TargetHighlight then
							self.TargetHighlight:Show()
							self.TargetHighlight:SetBackdropBorderColor(color.r, color.g, color.b, 1)
						end
					end
				end
			else
				if self.TargetHighlight then
					self.TargetHighlight:Hide()
				end
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateRaidTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateRaidTargetGlow, true)
	end

	self.HealthPrediction = Module.CreateHealthPrediction(self, C["Raid"].RaidLayout.Value == "Damage" and C["Raid"].Width or C["Raid"].Width - 12)

	if C["Unitframe"].DebuffHighlight then
		Module.CreateDebuffHighlight(self)
	end

	self.Range = Module.CreateRangeIndicator(self)
end