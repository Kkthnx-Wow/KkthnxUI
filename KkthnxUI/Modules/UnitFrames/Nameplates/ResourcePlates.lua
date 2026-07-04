--[[-----------------------------------------------------------------------------
-- Personal resource plate, target-anchored class power, GCD ticker.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

function Module:PlateVisibility(event)
	local auras = self.Auras
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and K.UnitIsUnit("player", self.unit) then
		K.UIFrameFadeIn(self.Health, 0.2, self.Health:GetAlpha(), 1)
		K.UIFrameFadeIn(self.Power, 0.2, self.Power:GetAlpha(), 1)
		if auras then
			K.UIFrameFadeIn(auras, 0.2, auras:GetAlpha(), 1)
		end
	else
		K.UIFrameFadeOut(self.Health, 0.2, self.Health:GetAlpha(), 0)
		K.UIFrameFadeOut(self.Power, 0.2, self.Power:GetAlpha(), 0)
		if auras then
			K.UIFrameFadeOut(auras, 0.2, auras:GetAlpha(), 0)
		end
	end
end

function Module:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"

	local iconSize, margin = C["Nameplate"].PPIconSize, 2
	self:SetSize(iconSize * 5 + margin * 4, C["Nameplate"].PPHeight)
	self:EnableMouse(false)
	self.iconSize = iconSize

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Health:SetStatusBarColor(0.1, 0.1, 0.1)
	self.Health:CreateShadow(true)
	self.Health.colorClass = true

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Power:SetHeight(C["Nameplate"].PPPHeight)
	self.Power:SetWidth(self:GetWidth())
	self.Power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Power:CreateShadow(true)
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	Module:CreateClassPower(self)

	if K.Class == "MONK" then
		self.Stagger = CreateFrame("StatusBar", self:GetName() .. "Stagger", self)
		self.Stagger:SetPoint("TOPLEFT", self.Health, 0, 8)
		self.Stagger:SetSize(self:GetWidth(), self:GetHeight())
		self.Stagger:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		self.Stagger:CreateShadow(true)

		self.Stagger.Value = self.Stagger:CreateFontString(nil, "OVERLAY")
		self.Stagger.Value:SetFontObject(K.UIFont)
		self.Stagger.Value:SetPoint("CENTER", self.Stagger, "CENTER", 0, 0)
		self:Tag(self.Stagger.Value, "[monkstagger]")
	end

	local textFrame = CreateFrame("Frame", nil, self.Power)
	textFrame:SetAllPoints()
	self.powerText = K.CreateFontString(textFrame, 12, "")
	self:Tag(self.powerText, "[pppower]")

	Module:TogglePlatePower()
	Module:CreateGCDTicker(self)
	Module:UpdateTargetClassPower()
	Module:TogglePlateVisibility()
end

function Module:TogglePlayerPlate()
	local plate = _G.oUF_PlayerPlate
	if not plate then
		return
	end

	if C["Nameplate"].ShowPlayerPlate then
		plate:Enable()
	else
		plate:Disable()
	end
end

function Module:TogglePlatePower()
	local plate = _G.oUF_PlayerPlate
	if not plate then
		return
	end

	plate.powerText:SetShown(C["Nameplate"].PPPowerText)
end

function Module:TogglePlateVisibility()
	local plate = _G.oUF_PlayerPlate
	if not plate then
		return
	end

	if C["Nameplate"].PPHideOOC then
		plate:RegisterEvent("UNIT_EXITED_VEHICLE", Module.PlateVisibility)
		plate:RegisterEvent("UNIT_ENTERED_VEHICLE", Module.PlateVisibility)
		plate:RegisterEvent("PLAYER_REGEN_ENABLED", Module.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_REGEN_DISABLED", Module.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_ENTERING_WORLD", Module.PlateVisibility, true)
		Module.PlateVisibility(plate)
	else
		plate:UnregisterEvent("UNIT_EXITED_VEHICLE", Module.PlateVisibility)
		plate:UnregisterEvent("UNIT_ENTERED_VEHICLE", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.PlateVisibility)
		Module.PlateVisibility(plate, "PLAYER_REGEN_DISABLED")
	end
end

function Module:CreateTargetPlate()
	self.mystyle = "targetplate"
	self:EnableMouse(false)
	self:SetSize(10, 10)

	Module:CreateClassPower(self)
end

function Module:UpdateTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	local bar = plate.ClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")

	if nameplate and nameplate.unitFrame then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame, "TOP", 0, 24)
		bar:Show()
	else
		bar:Hide()
		bar:SetParent(plate)
		bar:ClearAllPoints()
	end
end

function Module:ToggleTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	local playerPlate = _G.oUF_PlayerPlate
	local isEnabled = C["Nameplate"].NameplateClassPower

	if isEnabled then
		plate:Enable()
		if plate.ClassPower then
			if not plate:IsElementEnabled("ClassPower") then
				plate:EnableElement("ClassPower")
				plate.ClassPower:ForceUpdate()
			end
			if playerPlate and playerPlate:IsElementEnabled("ClassPower") then
				playerPlate:DisableElement("ClassPower")
			end
		end

		if plate.Runes then
			if not plate:IsElementEnabled("Runes") then
				plate:EnableElement("Runes")
				plate.Runes:ForceUpdate()
			end
			if playerPlate and playerPlate:IsElementEnabled("Runes") then
				playerPlate:DisableElement("Runes")
			end
		end
	else
		plate:Disable()
		if plate.ClassPower then
			if plate:IsElementEnabled("ClassPower") then
				plate:DisableElement("ClassPower")
			end
			if playerPlate and not playerPlate:IsElementEnabled("ClassPower") then
				playerPlate:EnableElement("ClassPower")
				playerPlate.ClassPower:ForceUpdate()
			end
		end

		if plate.Runes then
			if plate:IsElementEnabled("Runes") then
				plate:DisableElement("Runes")
			end
			if playerPlate and not playerPlate:IsElementEnabled("Runes") then
				playerPlate:EnableElement("Runes")
				playerPlate.Runes:ForceUpdate()
			end
		end
	end
end

function Module:ResizeTargetPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	local barWidth = C["Nameplate"].PlateWidth
	local barHeight = C["Nameplate"].PlateHeight
	local bars = plate.ClassPower or plate.Runes
	if bars then
		plate.ClassPowerBar:SetSize(barWidth, barHeight)
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max - 1) * 6) / max)
		end
	end
end

function Module:CreateGCDTicker(self)
	if not C["Nameplate"].PPGCDTicker then
		return
	end

	local GCD = CreateFrame("Frame", nil, self.Power)
	GCD:SetWidth(self:GetWidth())
	GCD:SetHeight(C["Nameplate"].PPPHeight)
	GCD:SetPoint("LEFT", self.Power, "LEFT", 0, 0)

	GCD.Color = { 1, 1, 1, 0.6 }
	GCD.Texture = C["Media"].Textures.Spark128Texture
	GCD.Height = C["Nameplate"].PPPHeight
	GCD.Width = 64

	self.GCD = GCD
end
