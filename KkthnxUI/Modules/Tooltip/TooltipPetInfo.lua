local K = _G.unpack(_G.select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G

local GameTooltip = _G.GameTooltip
local ID = _G.ID
local PET = _G.PET
local PET_TYPE_SUFFIX = _G.PET_TYPE_SUFFIX
local UnitBattlePetType = _G.UnitBattlePetType
local UnitIsBattlePet = _G.UnitIsBattlePet
local UNKNOWN = _G.UNKNOWN

function Module:InsertPetIcon(petType)
	if not self.petIcon then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", -5, -5)
		f:SetSize(35, 35)
		f:SetBlendMode("ADD")
		f:SetTexCoord(.188, .883, 0, .348)
		self.petIcon = f
	end

	self.petIcon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType])
	self.petIcon:SetAlpha(1)
end

GameTooltip:HookScript("OnTooltipCleared", function(self)
	if self.petIcon and self.petIcon:GetAlpha() ~= 0 then
		self.petIcon:SetAlpha(0)
	end
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local _, unit = self:GetUnit()

	if not unit then
		return
	end

	if not UnitIsBattlePet(unit) then
		return
	end

	-- Pet Species icon
	Module.InsertPetIcon(self, UnitBattlePetType(unit))

	-- Pet ID
	local speciesID = UnitBattlePetSpeciesID(unit)
	self:AddLine(("|cFFCA3C3C%s|r %d"):format(PET..ID, speciesID or UNKNOWN))
end)