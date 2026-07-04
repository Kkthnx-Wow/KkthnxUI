--[[-----------------------------------------------------------------------------
-- Threat status, threat border indicator, group off-tank detection.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")
local NP = Module.NP

local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitThreatSituation = UnitThreatSituation

local groupRoles = NP.groupRoles
local targetTokenCache = NP.targetTokenCache

local function GetTargetToken(unit)
	local token = targetTokenCache[unit]
	if not token then
		token = unit .. "target"
		targetTokenCache[unit] = token
	end
	return token
end

function Module:CheckThreatStatus(unit)
	if not UnitExists(unit) then
		return
	end

	local unitTarget = GetTargetToken(unit)
	local unitRole = "NONE"

	if NP.isInGroup and UnitExists(unitTarget) then
		local isPlayerTarget = UnitIsUnit(unitTarget, "player")
		if K.NotSecret(isPlayerTarget) and not isPlayerTarget then
			local targetName = UnitName(unitTarget)
			if targetName and K.NotSecret(targetName) then
				unitRole = groupRoles[targetName] or "NONE"
			end
		end
	end

	local status
	if K.Role == "Tank" and unitRole == "TANK" then
		status = UnitThreatSituation(unitTarget, unit)
		return true, (K.NotSecret(status) and status) or nil
	else
		status = UnitThreatSituation("player", unit)
		return false, (K.NotSecret(status) and status) or nil
	end
end

function Module:UpdateThreatIndicator(status, isCustomUnit)
	self.ThreatIndicator:Hide()
	if status and (isCustomUnit or (not C["Nameplate"].TankMode and K.Role ~= "Tank")) then
		if status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status == 2 or status == 1 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		end
	end
end

function Module:UpdateThreatColor(_, unit)
	if unit ~= self.unit then
		return
	end

	Module.UpdateColor(self, _, unit)
end

function Module:CreateThreatColor(self)
	local threatIndicator = self:CreateShadow()
	threatIndicator:SetPoint("TOPLEFT", self.Health.backdrop, "TOPLEFT", -1, 1)
	threatIndicator:SetPoint("BOTTOMRIGHT", self.Health.backdrop, "BOTTOMRIGHT", 1, -1)
	threatIndicator:Hide()

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = Module.UpdateThreatColor
end
