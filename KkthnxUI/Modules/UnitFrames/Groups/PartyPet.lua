local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF
if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping PartyPet.lua code!")
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitIsUnit = _G.UnitIsUnit
local UnitThreatSituation = _G.UnitThreatSituation

local function UpdatePartyPetThreat(self, _, unit)
	if unit ~= self.unit then
		return
	end

	local situation = UnitThreatSituation(unit)
	if (situation and situation > 0) then
		local r, g, b = GetThreatStatusColor(situation)
		self.KKUI_Border:SetVertexColor(r, g, b)
	else
		self.KKUI_Border:SetVertexColor(1, 1, 1)
	end
end

local function UpdatePartyPetPower(self, _, unit)
	if self.unit ~= unit then
		return
	end

	if not self.Power:IsVisible() then
		self.Health:ClearAllPoints()
		self.Health:SetPoint("BOTTOMLEFT", self, 0, 6)
		self.Health:SetPoint("TOPRIGHT", self)
	end
end

function Module:CreatePartyPet()
	local PartyPetframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local PartyPetframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(6)

	Module.CreateHeader(self)

	self:CreateBorder()

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameLevel(self:GetFrameLevel())
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(PartyPetframeTexture)

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

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata("LOW")
	self.Power:SetFrameLevel(self:GetFrameLevel())
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
	self.Power:SetHeight(5.5)
	self.Power:SetStatusBarTexture(PartyPetframeTexture)

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	self.Power.Background = self.Power:CreateTexture(nil, "BORDER")
	self.Power.Background:SetAllPoints(self.Power)
	self.Power.Background:SetColorTexture(.2, .2, .2)
	self.Power.Background.multiplier = 0.3

	table.insert(self.__elements, UpdatePartyPetPower)
	self:RegisterEvent("UNIT_DISPLAYPOWER", UpdatePartyPetPower)
	UpdatePartyPetPower(self, _, unit)

	self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
	self.Portrait:SetFrameLevel(self.Health:GetFrameLevel())
	self.Portrait:SetAllPoints()
	self.Portrait:SetAlpha(0.4)

	self.Name = self.Overlay:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self.Overlay, "TOPLEFT", 3, -15)
	self.Name:SetPoint("BOTTOMRIGHT", self.Overlay, "TOPRIGHT", -3, -15)
	self.Name:SetFontObject(PartyPetframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[name]")

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	if C["Party"].TargetHighlight then
		self.PartyPetHighlight = CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
		self.PartyPetHighlight:SetBackdrop({edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12})
		self.PartyPetHighlight:SetPoint("TOPLEFT", self, -6, 6)
		self.PartyPetHighlight:SetPoint("BOTTOMRIGHT", self, 6, -6)
		self.PartyPetHighlight:SetBackdropBorderColor(1, 1, 0)
		self.PartyPetHighlight:Hide()

		local function UpdatePartyPetTargetGlow()
			if UnitIsUnit("target", self.unit) then
				self.PartyPetHighlight:Show()
			else
				self.PartyPetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdatePartyPetTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdatePartyPetTargetGlow, true)
	end

	self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(C["Media"].Blank)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")
	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = UpdatePartyPetThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end