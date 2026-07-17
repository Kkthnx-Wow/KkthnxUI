--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Creates and updates the Party Pet unit frame.
-- - Design: Features Health, Portrait, and basic indicators.
-- - Events: UNIT_HEALTH, UNIT_AURA, etc. handled by oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize Globals
local CreateFrame = _G.CreateFrame
local UnitIsUnit = _G.UnitIsUnit

function Module:CreatePartyPet()
	self.mystyle = "partypet"

	local PartyPetframeFont = K.UIFont
	local PartyPetframeTexture = K.GetTexture(C["General"].Texture)

	-- REASON: Overlay frame for borders and indicators.
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(6)

	Module.CreateHeader(self)

	self:CreateBorder()

	-- REASON: Health Bar Setup
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

	Module:CreateUnitPortrait(self, { style = 4, overlayAlpha = 0.4 })

	Module:CreateUnitNameString(self, { parent = self.Overlay, layout = "aboveOverlay" })
	self:Tag(self.Name, "[name]")

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	-- REASON: Target Highlight
	if C["Party"].TargetHighlight then
		self.PartyPetHighlight = CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
		self.PartyPetHighlight:SetBackdrop({ edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay", edgeSize = 12 })
		self.PartyPetHighlight:SetPoint("TOPLEFT", self, -6, 6)
		self.PartyPetHighlight:SetPoint("BOTTOMRIGHT", self, 6, -6)
		self.PartyPetHighlight:SetBackdropBorderColor(1, 1, 0)
		self.PartyPetHighlight:Hide()

		local function UpdatePartyPetTargetGlow()
			if K.UnitIsUnit("target", self.unit) then
				self.PartyPetHighlight:Show()
			else
				self.PartyPetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdatePartyPetTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdatePartyPetTargetGlow, true)
	end

	Module:CreateDebuffHighlight(self)

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

	-- REASON: Range Fader Settings
	-- BUGFIX: was `self.Range = { Override = Module.UpdateRange }` — the registered
	-- oUF element is "RangeFader" (Elements/Range.lua), and Module.UpdateRange was
	-- never defined anywhere, so party pet frames silently got no range fading at all.
	self.RangeFader = {
		insideAlpha = 1,
		outsideAlpha = 0.55,
		MaxAlpha = 1,
		MinAlpha = 0.3,
	}
end
