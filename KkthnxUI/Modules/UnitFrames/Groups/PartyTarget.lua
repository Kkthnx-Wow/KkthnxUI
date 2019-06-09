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

function Module:CreatePartyTarget()
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
	self.Health:SetSize(26, 26)
	self.Health:SetPoint("CENTER", self, "CENTER", 19, 7)
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = Module.UpdateHealth
	self.Health.Smooth = C["Party"].Smooth
	self.Health.SmoothSpeed = C["Party"].SmoothSpeed * 10
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.SetFrequentUpdates = true

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT")
	self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT")
	--self.Name:SetWidth(self.Health:GetWidth())
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameShort]")

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
				if isPlayer then
					local _, class = UnitClass(unit)
					if class then
						local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
						if color then
							if self.TargetHighlight then
								self.TargetHighlight:Show()
								self.TargetHighlight:SetVertexColor(color.r, color.g, color.b, 1)
							end
						end
					end
				elseif reaction then
					local color = FACTION_BAR_COLORS[reaction]
					if color then
						if self.TargetHighlight then
							self.TargetHighlight:Show()
							self.TargetHighlight:SetVertexColor(color.r, color.g, color.b, 1)
						end
					end
				end
			else
				if self.TargetHighlight then
					self.TargetHighlight:Hide()
				end
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdatePartyTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdatePartyTargetGlow, true)  -- Watch this.
	end

	if C["Unitframe"].DebuffHighlight then
		Module.CreateDebuffHighlight(self)
	end

	self.HealthPrediction = Module.CreateHealthPrediction(self, 114)

	self.Threat = {
		Hide = K.Noop,
		IsObjectType = K.Noop,
		Override = Module.CreateThreatIndicator
	}

	self.Range = Module.CreateRangeIndicator(self)
end