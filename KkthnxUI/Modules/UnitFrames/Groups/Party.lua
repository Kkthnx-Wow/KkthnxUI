local K, C = unpack(select(2, ...))
if C["Party"].Enable ~= true then
	return
end
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
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[KkthnxUI:Leader][KkthnxUI:Role][KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("TOP", self.Portrait, 0, 15)
	self.Level:SetFontObject(UnitframeFont)
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	if (C["Party"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "FocusCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
		self.Castbar:SetClampedToScreen(true)

		self.Castbar.Background = self.Castbar:CreateTexture(nil, "BACKGROUND", -1)
		self.Castbar.Background:SetAllPoints()
		self.Castbar.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		self.Castbar.Border = CreateFrame("Frame", nil, self.Castbar)
		self.Castbar.Border:SetAllPoints()
		K.CreateBorder(self.Castbar.Border)

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("LEFT", C["Party"].CastbarIcon and 26 or 4, 0)
		self.Castbar:SetPoint("RIGHT", -4, 0)
		self.Castbar:SetPoint("TOP", 0, 18)
		self.Castbar:SetHeight(16)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetFont(select(1, self.Castbar.Time:GetFont()), 11, select(3, self.Castbar.Time:GetFont()))
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.timeToHold = 0.4
		self.Castbar.CustomDelayText = Module.CustomCastDelayText
		self.Castbar.CustomTimeText = Module.CustomTimeText
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostChannelStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostChannelStop = Module.PostCastStop
		self.Castbar.PostChannelUpdate = Module.PostChannelUpdate
		self.Castbar.PostCastInterruptible = Module.PostCastInterruptible
		self.Castbar.PostCastNotInterruptible = Module.PostCastNotInterruptible
		self.Castbar.PostCastFailed = Module.PostCastFailedOrInterrupted
		self.Castbar.PostCastInterrupted = Module.PostCastFailedOrInterrupted

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Text:SetFont(select(1, self.Castbar.Text:GetFont()), 11, select(3, self.Castbar.Text:GetFont()))
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		if (C["Party"].CastbarIcon) then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(16, 16)

			self.Castbar.Button.Backgrounds = self.Castbar.Button:CreateTexture(nil, "BACKGROUND", -1)
			self.Castbar.Button.Backgrounds:SetAllPoints(self.Castbar.Button)
			self.Castbar.Button.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			self.Castbar.Button.Borders = CreateFrame("Frame", nil, self.Castbar.Button)
			self.Castbar.Button.Borders:SetAllPoints(self.Castbar.Button)
			K.CreateBorder(self.Castbar.Button.Borders)
			self.Castbar.Button.Borders:SetBackdropBorderColor()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("RIGHT", self.Castbar, "LEFT", -6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end
	end

	if C["Party"].MouseoverHighlight then
		Module.MouseoverHealth(self, "party")
	end

	if (C["Party"].TargetHighlight) then
		self.TargetHighlight = self:CreateTexture("$parentHighlight", "ARTWORK", nil, 1)
		self.TargetHighlight:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\Shader.tga]])
		self.TargetHighlight:SetPoint("TOPLEFT", self.Name, -8, 8)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", self.Name, 8, -8)
		self.TargetHighlight:Hide()

		local function UpdatePartyTargetGlow()
			if not self.unit then
				return
			end

			local unit = self.unit
			local isPlayer = unit and UnitIsPlayer(unit)
			local reaction = unit and UnitReaction(unit, "player")

			if UnitIsUnit(unit, "target") then
				if not self.TargetHighlight:IsShown() then
					self.TargetHighlight:Show()
				end
				if isPlayer then
					local _, class = UnitClass(unit)
					if class then
						local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
						if color then
							self.TargetHighlight:SetVertexColor(color.r, color.g, color.b, 1)
						end
					end
				elseif reaction then
					local color = FACTION_BAR_COLORS[reaction]
					if color then
						self.TargetHighlight:SetVertexColor(color.r, color.g, color.b, 1)
					end
				else
					if self.TargetHighlight:IsShown() then
						self.TargetHighlight:Hide()
					end
				end
			else
				if self.TargetHighlight:IsShown() then
					self.TargetHighlight:Hide()
				end
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdatePartyTargetGlow)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdatePartyTargetGlow) -- Watch this.
	end

	Module.CreateAuras(self, "party")
	if C["Party"].PortraitTimers then
		Module.CreatePortraitTimers(self)
	end
	Module.CreatePhaseIndicator(self)
	Module.CreateRaidTargetIndicator(self)
	Module.CreateReadyCheckIndicator(self)
	Module.CreateResurrectIndicator(self)
	Module.CreateThreatIndicator(self)
	Module.CreateDebuffHighlight(self)

	self.HealthPrediction = Module.CreateHealthPrediction(self, 114)

	self.Threat = {
		Hide = K.Noop,
		IsObjectType = K.Noop,
		Override = Module.CreateThreatIndicator
	}

	self.Range = Module.CreateRange(self)
end