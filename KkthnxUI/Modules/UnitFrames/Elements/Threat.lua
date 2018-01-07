local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor

local function UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then return end

	local situation = UnitThreatSituation(unit)
	if (situation and situation > 0) then
		local r, g, b = GetThreatStatusColor(situation)
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(r, g, b, 1)
		else
			self.Portrait.Background:SetBackdropBorderColor(r, g, b, 1)
		end
		self.Health:SetBackdropBorderColor(r, g, b, 1)
	elseif C["General"].ColorTextures then
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3], 1)
		else
			self.Portrait.Background:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		end
		self.Health:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
	else
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 1)
		else
			self.Portrait.Background:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end
		self.Health:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
	end
end

function K.AddThreatIndicator(self)
	local threat = {}
	threat.IsObjectType = function() end
	threat.Override = UpdateThreat

	self.ThreatIndicator = threat
end