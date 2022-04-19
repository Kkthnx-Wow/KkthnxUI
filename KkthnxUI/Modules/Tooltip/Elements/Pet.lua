local K = unpack(KkthnxUI)
local Module = K:GetModule("Tooltip")

local _G = _G

local PET_TYPE_SUFFIX = _G.PET_TYPE_SUFFIX
local UnitIsBattlePet = _G.UnitIsBattlePet
local UnitBattlePetType = _G.UnitBattlePetType
local UnitBattlePetSpeciesID = _G.UnitBattlePetSpeciesID
local PET = _G.PET
local ID = _G.ID
local UNKNOWN = _G.UNKNOWN

function Module:PetInfoUpdate(petType)
	if not self.petIcon then
		self.petIcon = self:CreateTexture(nil, "OVERLAY")
		self.petIcon:SetPoint("TOPRIGHT", -5, -5)
		self.petIcon:SetSize(35, 35)
		self.petIcon:SetBlendMode("ADD")
		self.petIcon:SetTexCoord(0.188, 0.883, 0, 0.348)
	end
	self.petIcon:SetTexture("Interface\\PetBattles\\PetIcon-" .. PET_TYPE_SUFFIX[petType])
	self.petIcon:SetAlpha(1)
end

function Module:PetInfoReset()
	if self.petIcon and self.petIcon:GetAlpha() ~= 0 then
		self.petIcon:SetAlpha(0)
	end
end
GameTooltip:HookScript("OnTooltipCleared", Module.PetInfoReset)

function Module:PetInfoSetup()
	local _, unit = self:GetUnit()
	if not unit then
		return
	end

	if not UnitIsBattlePet(unit) then
		return
	end

	-- Pet Species icon
	Module.PetInfoUpdate(self, UnitBattlePetType(unit))

	-- Pet ID
	local speciesID = UnitBattlePetSpeciesID(unit)
	self:AddDoubleLine(PET .. ID .. ":", speciesID and (K.InfoColor .. speciesID .. "|r") or (K.GreyColor .. UNKNOWN .. "|r"))
end
GameTooltip:HookScript("OnTooltipSetUnit", Module.PetInfoSetup)
