local K, C = unpack(select(2, ...))
if IsAddOnLoaded("SimplePowerBar") then
	return
end

local select = select
local strupper = string.upper

local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitAlternatePowerTextureInfo = UnitAlternatePowerTextureInfo
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax

local PowerBarAltTexture = K.GetTexture(C["Unitframe"].Texture)

-- Skin AltPowerBar(by Tukz)
local blizzColors = {
	["INTERFACE\\UNITPOWERBARALT\\AMBER_HORIZONTAL_FILL.BLP"] = {r = 0.97, g = 0.81, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\ARCANE_CIRCULAR_FILL.BLP"] = {r = 0.52, g = 0.44, b = 1},
	["INTERFACE\\UNITPOWERBARALT\\ARSENAL_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0, b = 0.2},
	["INTERFACE\\UNITPOWERBARALT\\BREWINGSTORM_HORIZONTAL_FILL.BLP"] = {r = 1, g = 0.84, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\BULLETBAR_HORIZONTAL_FILL.BLP"] = {r = 0.5, g = 0.4, b = 0},
	["INTERFACE\\UNITPOWERBARALT\\CHOGALL_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.05, b = 0.67},
	["INTERFACE\\UNITPOWERBARALT\\FELCORRUPTION_HORIZONTAL_FILL.BLP"] = {r = 0.13, g = 0.55, b = 0.13},
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
	["INTERFACE\\UNITPOWERBARALT\\XAVIUS_HORIZONTAL_FILL.BLP"] = {r = 0.4, g = 0.1, b = 0.6}
}

local Movers = K.Movers

-- Get rid of old AltPowerBar
PlayerPowerBarAlt:UnregisterAllEvents()
PlayerPowerBarAlt.ignoreFramePositionManager = true

local holder = CreateFrame("Frame", "AltPowerBarHolder", UIParent)
holder:SetPoint("TOP", UIParent, "TOP", 0, -24)
holder:SetSize(220, 22)
Movers:RegisterFrame(holder)

-- AltPowerBar
local bar = CreateFrame("Frame", "UIAltPowerBar", UIParent)
bar:SetSize(220, 22)
bar:SetAllPoints(AltPowerBarHolder)

bar.Background = bar:CreateTexture(nil, "BACKGROUND", -1)
bar.Background:SetAllPoints()
bar.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

bar.Border = CreateFrame("Frame", nil, bar)
bar.Border:SetAllPoints()
K.CreateBorder(bar.Border)

-- Event handling
bar:RegisterEvent("UNIT_POWER")
bar:RegisterEvent("UNIT_POWER_BAR_SHOW")
bar:RegisterEvent("UNIT_POWER_BAR_HIDE")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:SetScript("OnEvent", function(self)
	if UnitAlternatePowerInfo("player") then
		self:Show()
	else
		self:Hide()
	end
end)

-- Tooltip
bar:SetScript("OnEnter", function(self)
	local name = select(11, UnitAlternatePowerInfo("player"))
	local tooltip = select(12, UnitAlternatePowerInfo("player"))

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -5)
	GameTooltip:AddLine(name, 1, 1, 1)
	GameTooltip:AddLine(tooltip, nil, nil, nil, true)

	GameTooltip:Show()
end)
bar:SetScript("OnLeave", GameTooltip_Hide)

-- StatusBar
local status = CreateFrame("StatusBar", "UIAltPowerBarStatus", bar)
status:SetFrameLevel(bar:GetFrameLevel())
status:SetStatusBarTexture(PowerBarAltTexture)
status:SetMinMaxValues(0, 100)
status:SetAllPoints()

status.text = status:CreateFontString(nil, "OVERLAY")
status.text:SetFont(C["Media"].Font, C["Media"].FontSize)
status.text:SetShadowOffset(1.25, -1.25)
status.text:SetPoint("CENTER", bar, "CENTER", 0, 0)

-- Update Function
local update = 1
status:SetScript("OnUpdate", function(self, elapsed)
	if not bar:IsShown() then return end
	update = update + elapsed

	if update >= 1 then
		local power = UnitPower("player", ALTERNATE_POWER_INDEX)
		local mpower = UnitPowerMax("player", ALTERNATE_POWER_INDEX)
		local texture, r, g, b = UnitAlternatePowerTextureInfo("player", 2, 0)
		if texture then
			texture = strupper(texture)
		end
		if blizzColors[texture] then
			r, g, b = blizzColors[texture].r, blizzColors[texture].g, blizzColors[texture].b
		elseif not texture then
			r, g, b = 0.3, 0.7, 0.3
		end
		self:SetMinMaxValues(0, mpower)
		self:SetValue(power)
		self.text:SetText(power.." / "..mpower)
		self:SetStatusBarColor(r, g, b)
		update = 0
	end
end)