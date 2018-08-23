local K, C = unpack(select(2, ...))
--if C["Party"].Enable ~= true then
--	return
--end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Party.lua code!")
	return
end

local _G = _G

local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitReaction = _G.UnitReaction

function Module:CreateParty()
	local UnitframeFont = K.GetFont(C["Party"].Font)
	local UnitframeTexture = K.GetTexture(C["Party"].Texture)

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

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetSize(114, 18)
	self.Health:SetPoint("CENTER", self, "CENTER", 19, 7)
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.Smooth = C["Party"].Smooth
	self.Health.SmoothSpeed = C["Party"].SmoothSpeed * 10
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 10, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetSize(114, 8)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.Smooth = C["Party"].Smooth
	self.Power.SmoothSpeed = C["Party"].SmoothSpeed * 10
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if (C["Party"].PortraitStyle.Value == "ThreeDPortraits") then
		self.Portrait = CreateFrame("PlayerModel", nil, self)
		self.Portrait:SetSize(32, 32)
		self.Portrait:SetPoint("LEFT", self, 3, 0)

		self.Portrait.Borders = CreateFrame("Frame", nil, self)
		self.Portrait.Borders:SetPoint("LEFT", self, 3, 0)
		self.Portrait.Borders:SetSize(32, 32)
		self.Portrait.Borders:CreateBorder()
		self.Portrait.Borders:CreateInnerShadow()
	elseif (C["Party"].PortraitStyle.Value ~= "ThreeDPortraits") then
		self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(32, 32)
		self.Portrait:SetPoint("LEFT", self, 3, 0)

		self.Portrait.Borders = CreateFrame("Frame", nil, self)
		self.Portrait.Borders:SetPoint("LEFT", self, 3, 0)
		self.Portrait.Borders:SetSize(32, 32)
		self.Portrait.Borders:CreateBorder()

		if (C["Party"].PortraitStyle.Value == "ClassPortraits" or C["Party"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetWidth(self.Health:GetWidth())
	self.Name:SetFontObject(UnitframeFont)
	self:Tag(self.Name, "[KkthnxUI:Leader][KkthnxUI:Role][KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("TOP", self.Portrait, 0, 15)
	self.Level:SetFontObject(UnitframeFont)
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	if C["Party"].MouseoverHighlight then
		Module.MouseoverHealth(self, "party")
	end

	if (C["Party"].TargetHighlight) then
		self.TargetHighlight = self:CreateTexture("$parentHighlight", "ARTWORK", nil, 1)
		self.TargetHighlight:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\Shader.tga]])
		self.TargetHighlight:SetPoint("TOPLEFT", self.Name, -7, 7)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", self.Name, 7, -7)
		self.TargetHighlight:Hide()

		local function UpdateTargetGlow()
			if not self.unit then
				return
			end

			local unit = self.unit
			if (UnitIsUnit("target", self.unit)) then
				self.TargetHighlight:Show()
				local reaction = UnitReaction(unit, "player")
				if UnitIsPlayer(unit) then
					local _, class = UnitClass(unit)
					if class then
						local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
						self.TargetHighlight:SetVertexColor(color.r, color.g, color.b)
					else
						self.TargetHighlight:SetVertexColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
					end
				elseif reaction then
					local color = FACTION_BAR_COLORS[reaction]
					self.TargetHighlight:SetVertexColor(color.r, color.g, color.b)
				else
					self.TargetHighlight:SetVertexColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
				end
			else
				self.TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
		self:RegisterEvent("RAID_ROSTER_UPDATE", UpdateTargetGlow)
		self:RegisterEvent("PLAYER_FOCUS_CHANGED", UpdateTargetGlow)
	end

	Module.CreateAuras(self, "party")
	Module.CreatePhaseIndicator(self)
	Module.CreateRaidTargetIndicator(self)
	Module.CreateReadyCheckIndicator(self)
	Module.CreateResurrectIndicator(self, 14)
	Module.CreateThreatIndicator(self)

	self.HealthPrediction = Module.CreateHealthPrediction(self)

	self.Threat = {
		Hide = K.Noop,
		IsObjectType = K.Noop,
		Override = Module.CreateThreatIndicator
	}

	self.Range = Module.CreateRange(self)
end