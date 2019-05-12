local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Unitframes.lua code!")
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

function Module:CreateTargetOfTarget()
	local UnitframeFont = K.GetFont(C["Unitframe"].Font)
	local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", function(self)
		UnitFrame_OnEnter(self)

		if (self.Highlight and not self.Highlight:IsShown()) then
			self.Highlight:Show()
		end
	end)

	self:SetScript("OnLeave", function(self)
		UnitFrame_OnLeave(self)

		if (self.Highlight and self.Highlight:IsShown()) then
			self.Highlight:Hide()
		end
	end)

	self.Health = CreateFrame("StatusBar", "$parent.Healthbar", self)
	self.Health:SetSize(74, 12)
	self.Health:SetPoint("CENTER", self, "CENTER", -15, 7)
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.Smooth = C["Unitframe"].Smooth
	self.Health.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = false

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 10, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[KkthnxUI:HealthPercent]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetSize(74, 8)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.Smooth = C["Unitframe"].Smooth
	self.Power.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	if C["Unitframe"].ShowPortrait then
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait = CreateFrame("PlayerModel", nil, self)
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
			self.Portrait:SetAlpha(0.9)

			self.Portrait.Borders = CreateFrame("Frame", nil, self)
			self.Portrait.Borders:SetPoint("RIGHT", self, -4, 0)
			self.Portrait.Borders:SetSize(26, 26)
			self.Portrait.Borders:CreateBorder()
			self.Portrait.Borders:CreateInnerShadow()
		elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
			self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)

			self.Portrait.Borders = CreateFrame("Frame", nil, self)
			self.Portrait.Borders:SetPoint("RIGHT", self, -4, 0)
			self.Portrait.Borders:SetSize(26, 26)
			self.Portrait.Borders:CreateBorder()
			if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOM", self.Power, "BOTTOM", 0, -16)
	self.Name:SetWidth(self.Power:GetWidth())
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameShort]")

	if C["Unitframe"].MouseoverHighlight then
		Module.MouseoverHealth(self, "targettarget")
	end

	Module.CreateAuras(self, "targettarget")
	Module.CreateRaidTargetIndicator(self, 12)
	Module.CreateThreatIndicator(self)

	self.Threat = {
		Hide = K.Noop, -- oUF stahp
		IsObjectType = K.Noop,
		Override = Module.CreateThreatIndicator,
	}

	self.Range = Module.CreateRangeIndicator(self)
end
