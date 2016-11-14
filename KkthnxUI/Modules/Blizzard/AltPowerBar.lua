local K, C, L = select(2, ...):unpack()

local AltPowerBar = CreateFrame("Button")

function AltPowerBar:Update()
	local Status = self.Status
	local Power = UnitPower("player", ALTERNATE_POWER_INDEX)
	local MaxPower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
	local R, G, B = K.ColorGradient(Power, MaxPower, 0, .8, 0, .8, .8, 0, .8, 0, 0)
	local PowerName = select(11 , UnitAlternatePowerInfo("player")) or UNKNOWN

	Status:SetMinMaxValues(0, MaxPower)
	Status:SetValue(Power)
	Status:SetStatusBarColor(R, G, B)
	Status.Text:SetText(PowerName..": "..Power.." / "..MaxPower)
end

function AltPowerBar:OnEvent(event, unit, power)
	local AltPowerInfo = UnitAlternatePowerInfo("player")

	if (not AltPowerInfo or event == "UNIT_POWER_BAR_HIDE") then
		self:Hide()
	else
		if ((event == "UNIT_POWER" or event == "UNIT_MAXPOWER") and power ~= "ALTERNATE") then
			return
		end

		self:Show()
		self:Update()
	end
end

function AltPowerBar:DisableBlizzardBar()
	PlayerPowerBarAlt:UnregisterAllEvents()
end

function AltPowerBar:Create()

	self:DisableBlizzardBar()
	self:SetSize(221, 25)
	self:SetParent(UIParent)
	self:SetPoint(unpack(C.Position.AltPowerBar))
	K.CreateBorder(self, 10, 1)
	self:SetBackdrop(K.BorderBackdrop)
	self:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	self:RegisterEvent("UNIT_POWER_BAR_SHOW")
	self:RegisterEvent("UNIT_POWER_BAR_HIDE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterUnitEvent("UNIT_POWER", "player")
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	self:SetScript("OnEvent", self.OnEvent)
	self:SetScript("OnClick", self.Hide)

	self.Status = CreateFrame("StatusBar", nil, self)
	self.Status:SetFrameLevel(self:GetFrameLevel() + 1)
	self.Status:SetStatusBarTexture(C.Media.Texture)
	self.Status:SetMinMaxValues(0, 100)
	self.Status:SetInside(self)

	self.Status.Text = self.Status:CreateFontString(nil, "OVERLAY")
	self.Status.Text:SetFont(C.Media.Font, C.Media.Font_Size)
	self.Status.Text:SetPoint("CENTER", self, "CENTER", 0, 0)
	self.Status.Text:SetShadowColor(0, 0, 0)
	self.Status.Text:SetShadowOffset(1.25, -1.25)
end

AltPowerBar:RegisterEvent("PLAYER_LOGIN")
AltPowerBar:SetScript("OnEvent", AltPowerBar.Create)
