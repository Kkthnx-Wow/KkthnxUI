--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays pet battle icons and IDs in unit tooltips.
-- - Design: Hooks unit tooltips to add pet species icons and IDs for battle pets.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Tooltip")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local UnitBattlePetSpeciesID = _G.UnitBattlePetSpeciesID
local UnitBattlePetType = _G.UnitBattlePetType
local UnitIsBattlePet = _G.UnitIsBattlePet
local GameTooltip = _G.GameTooltip

local ID = _G.ID
local PET = _G.PET
local UNKNOWN = _G.UNKNOWN
local PET_TYPE_SUFFIX = _G.PET_TYPE_SUFFIX

-- REASON: Updates the pet species icon in the tooltip.
function Module:UpdatePetInfo(petType)
	if not self.petIcon then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", -5, -5)
		f:SetSize(35, 35)
		f:SetBlendMode("ADD")
		f:SetTexCoord(0.188, 0.883, 0, 0.348)
		self.petIcon = f
	end

	if PET_TYPE_SUFFIX[petType] then
		self.petIcon:SetTexture("Interface\\PetBattles\\PetIcon-" .. PET_TYPE_SUFFIX[petType])
		self.petIcon:SetAlpha(1)
	end
end

-- REASON: Resets the pet icon visibility when the tooltip is cleared.
function Module:ResetPetInfo()
	if self.petIcon and self.petIcon:GetAlpha() ~= 0 then
		self.petIcon:SetAlpha(0)
	end
end
GameTooltip:HookScript("OnTooltipCleared", Module.ResetPetInfo)

-- REASON: Main entry point for adding pet-specific information to unit tooltips.
function Module:CreatePetInfo(unit)
	if not unit then
		return
	end

	if not UnitIsBattlePet(unit) then
		return
	end

	-- Pet Species icon
	Module.UpdatePetInfo(self, UnitBattlePetType(unit))

	-- Pet ID
	local speciesID = UnitBattlePetSpeciesID(unit)
	self:AddDoubleLine(PET .. ID .. ":", speciesID and (K.InfoColor .. speciesID .. "|r") or (K.GreyColor .. UNKNOWN .. "|r"))
end
