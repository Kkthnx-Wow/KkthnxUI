local _, ns = ...
local oUF = ns.oUF or oUF

local function Absorb_Update(self, event, unit)
	if self.unit ~= unit then return end

	local absorbs = UnitGetTotalAbsorbs(unit) or 0

	if absorbs <= 0 then
		self.Absorb.bar:SetValue(0)
		self.Absorb.bar:Hide()
		self.Absorb.spark:Hide()
		return
	else
		self.Absorb.bar:Show()
	end

	local maxHealth = UnitHealthMax(unit)
	local overAbsorb

	if absorbs > maxHealth then
		overAbsorb = absorbs - maxHealth
		absorbs = maxHealth

		self.Absorb.spark:Show()
	else
		self.Absorb.spark:Hide()
	end

	self.Absorb.bar:SetMinMaxValues(0,maxHealth)
	self.Absorb.bar:SetValue(absorbs)

	if self.Absorb.tile then
		-- re-set the texture after SetValue so that it tiles correctly
		-- (a blizzard thing)
		self.Absorb.bar:SetStatusBarTexture(self.Absorb.texture)
	end
end

local function Absorb_Enable(self,unit)
	if not self.Absorb then return end
	if self.HealPrediction and self.HealPrediction.absorbBar then return end

	self.Absorb.bar = CreateFrame('StatusBar', nil, self.Health)
	self.Absorb.bar:SetStatusBarTexture(self.Absorb.texture)
	self.Absorb.bar:SetStatusBarColor(unpack(self.Absorb.colour))
	self.Absorb.bar:SetAlpha(self.Absorb.alpha)
	self.Absorb.bar:SetAllPoints(self.Health)
	self.Absorb.bar:SetMinMaxValues(0, 1)
	self.Absorb.bar:SetValue(0)

	do
		local t = self.Absorb.bar:GetStatusBarTexture()
		if t then
			if self.Absorb.drawLayer then
				t:SetDrawLayer(unpack(self.Absorb.drawLayer))
			end
			if self.Absorb.tile then
				t:SetHorizTile(true)
				t:SetVertTile(true)
			end
		end
	end

	self.Absorb.spark = self.Health:CreateTexture(nil,'ARTWORK')
	self.Absorb.spark:SetTexture('Interface\\AddOns\\Kui_Media\\t\\spark')
	self.Absorb.spark:SetDrawLayer(unpack(self.Absorb.drawLayer))
	self.Absorb.spark:SetPoint('TOP', self.Health, 'TOPRIGHT', -1, 5)
	self.Absorb.spark:SetPoint('BOTTOM', self.Health, 'BOTTOMRIGHT', -1, -5)
	self.Absorb.spark:SetVertexColor(unpack(self.Absorb.colour))
	self.Absorb.spark:SetWidth(5)
	self.Absorb.spark:Hide()

	self:RegisterEvent('UNIT_MAXHEALTH', Absorb_Update)
	self:RegisterEvent('UNIT_ABSORB_AMOUNT_CHANGED', Absorb_Update)

	return true
end

oUF:AddElement('Absorb', Absorb_Update, Absorb_Enable)