local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping FocusTarget.lua code!")
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateFocusTarget()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(14)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

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
	self.Power:SetHeight(8)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOM", self.Power, "BOTTOM", 0, -16)
	self.Name:SetSize(74, 14)
	self.Name:SetJustifyV("BOTTOM")
	self.Name:SetJustifyH("CENTER")
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameShort]")

	if C["General"].PortraitStyle.Value == "ThreeDPortraits" then
		self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
		self.Portrait:SetFrameStrata(self:GetFrameStrata())
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)
		self.Portrait:CreateBorder()
		self.Portrait:CreateInnerShadow()
	elseif C["General"].PortraitStyle.Value ~= "ThreeDPortraits" then
		self.Portrait = self.Health:CreateTexture("PlayerPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)

		self.Portrait.Border = CreateFrame("Frame", nil, self)
		self.Portrait.Border:SetAllPoints(self.Portrait)
		self.Portrait.Border:CreateBorder()
		self.Portrait.Border:CreateInnerShadow()

		if (C["General"].PortraitStyle.Value == "ClassPortraits" or C["General"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT", self.Portrait:GetWidth() + 6, 0)
	self.Health:SetPoint("TOPRIGHT")

	-- Module.CreateHighlight(self)

	self.Threat = {
		Hide = K.Noop,
		IsObjectType = K.Noop,
		Override = Module.CreateThreatIndicator,
	}

	self.Range = Module.CreateRangeIndicator(self)
end