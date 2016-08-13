local K, C, L, _ = select(2, ...):unpack()

local PlayerPowerBarAlt = PlayerPowerBarAlt
local UnitPowerMax = UnitPowerMax
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local ALTERNATE_POWER_INDEX = ALTERNATE_POWER_INDEX

local PowerTextures = {
	["INTERFACE\\UNITPOWERBARALT\\TWINOGRONDISTANCE_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\SHADOWPALADINBAR_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\NAARUCHARGE_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\KARGATHROARCROWD_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\BULLETBAR_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\FELCORRUPTIONRED_HORIZONTAL_FILL.BLP"] = {r = 0.8, g = 0.05, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\FELCORRUPTION_HORIZONTAL_FILL.BLP"] = {r = 0.13, g = 0.55, b = 0.13},
	["INTERFACE\\UNITPOWERBARALT\\GARROSHENERGY_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\ARSENAL_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0, b = 0.2},
	["INTERFACE\\UNITPOWERBARALT\\PRIDE_HORIZONTAL_FILL.BLP"] = {r = 0.2, g = 0.4, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\LIGHTNING_HORIZONTAL_FILL.BLP"] = {r = 0.12, g = 0.56, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\THUNDERKING_HORIZONTAL_FILL.BLP"] = {r = 0.12, g = 0.56, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\AMBER_HORIZONTAL_FILL.BLP"] = {r = 0.97, g = 0.81, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\STONEGUARDAMETHYST_HORIZONTAL_FILL.BLP"] = {r = 0.67, g = 0, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\STONEGUARDCOBALT_HORIZONTAL_FILL.BLP"] = {r = 0.1, g = 0.4, b = 0.95},
	["INTERFACE\\UNITPOWERBARALT\\STONEGUARDJADE_HORIZONTAL_FILL.BLP"] = {r = 0.13, g = 0.55, b = 0.13},
	["INTERFACE\\UNITPOWERBARALT\\STONEGUARDJASPER_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\BREWINGSTORM_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.84, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\SHAWATER_HORIZONTAL_FILL.BLP"] = {r = 0.1, g = 0.6, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\ARCANE_CIRCULAR_FILL.BLP"] = {r = 0.52, g = 0.44, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\MOLTENFEATHERS_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\RHYOLITH_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\CHOGALL_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\ONYXIA_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\MAP_HORIZONTAL_FILL.BLP"] = {r = 0.97, g = 0.81, b = 0},
}

PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_SHOW")
PlayerPowerBarAlt:UnregisterEvent("UNIT_POWER_BAR_HIDE")
PlayerPowerBarAlt:UnregisterEvent("PLAYER_ENTERING_WORLD")

local AltPowerBar = CreateFrame("Frame", "UIAltPowerBar", UIParent)
AltPowerBar:SetPoint(unpack(C.Position.AltPowerBar))
AltPowerBar:SetSize(232, 20)
AltPowerBar:SetBackdrop(K.BorderBackdrop)
AltPowerBar:SetBackdropColor(unpack(C.Media.Backdrop_Color))
AltPowerBar:CreatePixelShadow(2)
AltPowerBar:SetFrameStrata("MEDIUM")
AltPowerBar:SetFrameLevel(0)
AltPowerBar:EnableMouse(true)

local AltPowerBarStatus = CreateFrame("StatusBar", "AltPowerBarStatus", AltPowerBar)
AltPowerBarStatus:SetFrameLevel(AltPowerBar:GetFrameLevel() + 1)
AltPowerBarStatus:SetStatusBarTexture(C.Media.Texture)
AltPowerBarStatus:SetMinMaxValues(0, 100)
AltPowerBarStatus:SetPoint("TOPLEFT", AltPowerBar, "TOPLEFT", 1, -1)
AltPowerBarStatus:SetPoint("BOTTOMRIGHT", AltPowerBar, "BOTTOMRIGHT", -1, 1)

local AltPowerText = AltPowerBarStatus:CreateFontString("DuffedUIAltPowerBarText", "OVERLAY")
AltPowerText:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
AltPowerText:SetPoint("CENTER", AltPowerBar, "CENTER", 0, 0)

AltPowerBar:RegisterEvent("UNIT_POWER")
AltPowerBar:RegisterEvent("UNIT_POWER_BAR_SHOW")
AltPowerBar:RegisterEvent("UNIT_POWER_BAR_HIDE")
AltPowerBar:RegisterEvent("PLAYER_ENTERING_WORLD")

local function OnEvent(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	if UnitAlternatePowerInfo("player") then self:Show() else self:Hide() end
end
AltPowerBar:SetScript("OnEvent", OnEvent)

local TimeSinceLastUpdate = 1
AltPowerBarStatus:SetScript("OnUpdate", function(self, elapsed)
	if not AltPowerBar:IsShown() then return end
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed

	if (TimeSinceLastUpdate >= 1) then
		self:SetMinMaxValues(0, UnitPowerMax("player", ALTERNATE_POWER_INDEX))
		local Power = UnitPower("player", ALTERNATE_POWER_INDEX)
		local MPower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
		self:SetValue(Power)
		AltPowerText:SetText(Power.." / "..MPower)
		local texture, r, g, b = UnitAlternatePowerTextureInfo("player", 2, 0) -- 2 = status bar index, 0 = displayed bar
		if texture and PowerTextures[texture] then r, g, b = PowerTextures[texture].r, PowerTextures[texture].g, PowerTextures[texture].b
		elseif not texture then
			r, g, b = 0.3, 0.7, 0.3
		end
		AltPowerBarStatus:SetStatusBarColor(r, g, b)
		self.TimeSinceLastUpdate = 0
	end
end)