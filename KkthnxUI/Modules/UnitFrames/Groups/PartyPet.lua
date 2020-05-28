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
local select = select

local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitIsUnit = _G.UnitIsUnit
local UnitThreatSituation = _G.UnitThreatSituation

local function UpdateRaidThreat(self, _, unit)
	if unit ~= self.unit then
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

function Module:CreatePartyPet()
	local RaidframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local RaidframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(6)

	Module.CreateHeader(self)

	self:CreateBorder()

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameLevel(self:GetFrameLevel())
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(RaidframeTexture)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, 0, -9)
	self.Health.Value:SetFontObject(RaidframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 11, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[raidhp]")

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Party"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Party"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
	self.Portrait:SetFrameLevel(self.Health:GetFrameLevel())
	self.Portrait:SetAllPoints()
	self.Portrait:SetAlpha(0.2)

	self.Name = self.Overlay:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self.Overlay, "TOPLEFT", 3, -15)
	self.Name:SetPoint("BOTTOMRIGHT", self.Overlay, "TOPRIGHT", -3, -15)
	self.Name:SetFontObject(RaidframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[name]")

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(30, 30)
	self.ResurrectIndicator:SetPoint("CENTER", 0, -3)

	if C["Party"].TargetHighlight then
		self.OverlayFrame = CreateFrame("Frame", nil, self)
		self.OverlayFrame:SetFrameLevel(self:GetFrameLevel() + 2)
		self.OverlayFrame:SetAllPoints()

		self.TargetHighlight = self.OverlayFrame:CreateTexture(nil, "OVERLAY")
		self.TargetHighlight:SetTexture([[Interface\RAIDFRAME\Raid-FrameHighlights]])
		self.TargetHighlight:SetTexCoord(0.00781250, 0.55468750, 0.28906250, 0.55468750)
		self.TargetHighlight:SetVertexColor(0.84, 0.75, 0.65)
		self.TargetHighlight:SetAllPoints()
		self.TargetHighlight:Hide()

		local function UpdateRaidTargetGlow()
			if UnitIsUnit("target", self.unit) then
				self.TargetHighlight:Show()
			else
				self.TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateRaidTargetGlow, true)
	end

	self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(C["Media"].Blank)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")
	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true
	self.DebuffHighlightFilterTable = K.DebuffHighlightColors

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = UpdateRaidThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end