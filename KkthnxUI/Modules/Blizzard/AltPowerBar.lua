local K, C, L = unpack(select(2, ...))
-- if C.Blizzard.AltPowerBar ~= true then return end
local AltPowerBar = CreateFrame("Frame", nil, UIParent)

local select = select
local CreateFrame = CreateFrame

local UnitPower, UnitPowerMax, UnitAlternatePowerTextureInfo, UnitAlternatePowerInfo = UnitPower, UnitPowerMax, UnitAlternatePowerTextureInfo, UnitAlternatePowerInfo
local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX
local UNKNOWN = UNKNOWN

local Elapsed = 1

local AltPowerBarColors = {-- Update this list as time goes.
	["INTERFACE\\UNITPOWERBARALT\\AMBER_HORIZONTAL_FILL.BLP"] = {r = 0.97, g = 0.81, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\ARCANE_CIRCULAR_FILL.BLP"] = {r = 0.52, g = 0.44, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\ARSENAL_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0, b = 0.2},
	["INTERFACE\\UNITPOWERBARALT\\BREWINGSTORM_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.84, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\BULLETBAR_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\CHOGALL_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\FELCORRUPTIONRED_HORIZONTAL_FILL.BLP"] = {r = 0.8, g = 0.05, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\GARROSHENERGY_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\KARGATHROARCROWD_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\LIGHTNING_HORIZONTAL_FILL.BLP"] = {r = 0.12, g = 0.56, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\MAP_HORIZONTAL_FILL.BLP"] = {r = 0.97, g = 0.81, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\MOLTENFEATHERS_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\NAARUCHARGE_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\ONYXIA_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\PRIDE_HORIZONTAL_FILL.BLP"] = {r = 0.2, g = 0.4, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\RHYOLITH_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\SHADOWPALADINBAR_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\SHAWATER_HORIZONTAL_FILL.BLP"] = {r = 0.1, g = 0.6, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\STONEGUARDAMETHYST_HORIZONTAL_FILL.BLP"] = {r = 0.67, g = 0, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\STONEGUARDCOBALT_HORIZONTAL_FILL.BLP"] = {r = 0.1, g = 0.4, b = 0.95},
	["INTERFACE\\UNITPOWERBARALT\\STONEGUARDJADE_HORIZONTAL_FILL.BLP"] = {r = 0.13, g = 0.55, b = 0.13},
	["INTERFACE\\UNITPOWERBARALT\\STONEGUARDJASPER_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\THUNDERKING_HORIZONTAL_FILL.BLP"] = {r = 0.12, g = 0.56, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\TWINOGRONDISTANCE_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\XAVIUS_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.1, b = 0.6},
}

local DisableElements = function()
	PlayerPowerBarAlt:UnregisterAllEvents()
end

local OnUpdate = function(self, elapsed)
	Elapsed = Elapsed + elapsed

	if (Elapsed >= 1) then
		local Power = UnitPower("player", ALTERNATE_POWER_INDEX)
		local MaxPower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
		local Texture, R, G, B = UnitAlternatePowerTextureInfo("player", 2, 0)
		local PowerName = select(11 , UnitAlternatePowerInfo("player")) or UNKNOWN

		if (Texture and AltPowerBarColors.Texture) then
			R, G, B = AltPowerBarColors.Texture.r, AltPowerBarColors.Texture.g, AltPowerBarColors.Texture.b
		else
			R, G, B = K.ColorGradient(Power, MaxPower, 0, 0.8, 0, 0.8, 0.8, 0, 0.8, 0, 0)
		end

		self.Status:SetMinMaxValues(0, MaxPower)
		self.Status:SetValue(Power)
		self.Status:SetStatusBarColor(R, G, B)
		self.Text:SetText(PowerName .. ": " .. Power .. " / " .. MaxPower)

		Elapsed = 0
	end
end

local OnEvent = function(self, event, unit, power)
	local AltPowerInfo = UnitAlternatePowerInfo("player")

	if (not AltPowerInfo or event == "UNIT_POWER_BAR_HIDE") then
		self:Hide()
		self:SetScript("OnUpdate", nil)
	else
		if ((event == "UNIT_POWER" or event == "UNIT_MAXPOWER") and power ~= "ALTERNATE") then
			return
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		self:Show()
		self:SetScript("OnUpdate", OnUpdate)
	end
end

local CreateBar = function()
	DisableElements()

	AltPowerBar:SetParent(UIParent)
	AltPowerBar:SetSize(222, 26)
	AltPowerBar:SetPoint(unpack(C.Position.AltPowerBar))
	AltPowerBar:CreateBackdrop(size, 2)
	AltPowerBar:SetFrameStrata("HIGH")

	AltPowerBar.Status = CreateFrame("StatusBar", nil, AltPowerBar)
	AltPowerBar.Status:SetFrameLevel(AltPowerBar:GetFrameLevel() + 1)
	AltPowerBar.Status:SetStatusBarTexture(C.Media.Texture)
	AltPowerBar.Status:SetMinMaxValues(0, 100)
	AltPowerBar.Status:SetInside(AltPowerBar)

	AltPowerBar.Text = K.SetFontString(AltPowerBar.Status, C.Media.Font, 12, "OUTLINE", "CENTER")
	AltPowerBar.Text:SetPoint("CENTER", AltPowerBar.Status, "CENTER", 0, 1)

	AltPowerBar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	AltPowerBar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	AltPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")
	AltPowerBar:RegisterUnitEvent("UNIT_POWER", "player")
	AltPowerBar:RegisterUnitEvent("UNIT_MAXPOWER", "player")
	AltPowerBar:SetScript("OnEvent", OnEvent)
end

AltPowerBar:RegisterEvent("PLAYER_LOGIN")
AltPowerBar:SetScript("OnEvent", CreateBar)
