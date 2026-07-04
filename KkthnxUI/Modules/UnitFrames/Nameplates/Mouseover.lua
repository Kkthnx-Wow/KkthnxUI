--[[-----------------------------------------------------------------------------
-- Mouseover highlight on nameplate health bars (throttled OnUpdate).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = CreateFrame
local UnitExists = UnitExists

function Module:IsMouseoverUnit()
	if not self or not self.unit then
		return false
	end

	if self:IsVisible() and UnitExists("mouseover") then
		return K.UnitIsUnit("mouseover", self.unit)
	end

	return false
end

function Module:UpdateMouseoverShown()
	if not self or not self.unit then
		return
	end

	if self:IsShown() and K.UnitIsUnit("mouseover", self.unit) then
		self.HighlightIndicator:Show()
		self.HighlightUpdater:Show()
	else
		self.HighlightUpdater:Hide()
	end
end

function Module:HighlightOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		if not Module.IsMouseoverUnit(self.__owner) then
			self:Hide()
		end
		self.elapsed = 0
	end
end

function Module:HighlightOnHide()
	self.__owner.HighlightIndicator:Hide()
end

function Module:MouseoverIndicator(self)
	local highlight = CreateFrame("Frame", nil, self.Health)
	highlight:SetAllPoints(self)
	highlight:Hide()

	local texture = highlight:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetTexture(C["Media"].Textures.White8x8Texture)
	texture:SetVertexColor(1, 1, 1, 0.15)
	texture:SetBlendMode("ADD")

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Module.UpdateMouseoverShown, true)

	local updater = CreateFrame("Frame", nil, self)
	updater.__owner = self
	updater:SetScript("OnUpdate", Module.HighlightOnUpdate)
	updater:HookScript("OnHide", Module.HighlightOnHide)

	self.HighlightIndicator = highlight
	self.HighlightUpdater = updater
end
