local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit

function Module:CreatePartyPet()
	self.mystyle = "partypet"

	local PartyPetframeFont = K.UIFont
	local PartyPetframeTexture = K.GetTexture(C["General"].Texture)

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

	if C["Party"].HealthbarColor == 3 then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Party"].HealthbarColor == 2 then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	-- self.Power = CreateFrame("StatusBar", nil, self)
	-- self.Power:SetFrameStrata("LOW")
	-- self.Power:SetFrameLevel(self:GetFrameLevel())
	-- self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
	-- self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
	-- self.Power:SetHeight(5.5)
	-- self.Power:SetStatusBarTexture(PartyPetframeTexture)

	-- self.Power.colorPower = true
	-- self.Power.frequentUpdates = false

	-- self.Power.Background = self.Power:CreateTexture(nil, "BORDER")
	-- self.Power.Background:SetAllPoints(self.Power)
	-- self.Power.Background:SetColorTexture(0.2, 0.2, 0.2)
	-- self.Power.Background.multiplier = 0.3

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
		self.PartyPetHighlight:SetBackdrop({ edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12 })
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
	self.DebuffHighlight:SetTexture(C["Media"].Textures.White8x8Texture)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")
	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, 0.5, 1)
	self.Highlight:SetVertexColor(0.6, 0.6, 0.6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = {
		Override = Module.UpdateRange,
	}
end
