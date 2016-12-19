local K, C, L = unpack(select(2, ...))
if C.Tooltip.Enable ~= true or C.Tooltip.Talents ~= true then return end

-- Lua API
local floor = math.floor
local format = string.format
local ipairs = ipairs
local select = select
local tremove = table.remove

-- Wow API
local GetDetailedItemLevelInfo = GetDetailedItemLevelInfo
local GetInspectSpecialization = GetInspectSpecialization
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemInfo = GetItemInfo
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetSpecializationRoleByID = GetSpecializationRoleByID
local GetTime = GetTime
local NotifyInspect = NotifyInspect
local UnitGUID = UnitGUID

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ArtifactEquipped, InspectFrame, GameTooltip, ClearInspectPlayer, Talents

local Tooltip = K.Tooltip
local Talents = CreateFrame("Frame")

Talents.Cache = {}
Talents.LastInspectRequest = 0
Talents.SlotNames = {
	"Head",
	"Neck",
	"Shoulder",
	"Back",
	"Chest",
	"Wrist",
	"Hands",
	"Waist",
	"Legs",
	"Feet",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"MainHand",
	"SecondaryHand"
}

function Talents:GetItemLevel(unit)
	local Total, Item = 0, 0
	local ArtefactEquiped = false
	local TotalSlots = 16

	for i = 1, #Talents.SlotNames do
		local ItemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(("%sSlot"):format(Talents.SlotNames[i])))

		if (ItemLink ~= nil) then
			local _, _, Rarity, _, _, _, _, _, EquipLoc = GetItemInfo(ItemLink)

			--Check if we have an artifact equipped in main hand
			if (EquipLoc and EquipLoc == "INVTYPE_WEAPONMAINHAND" and Rarity and Rarity == 6) then
				ArtifactEquipped = true
			end

			--If we have artifact equipped in main hand, then we should not count the offhand as it displays an incorrect item level
			if (not ArtifactEquipped or (ArtifactEquipped and EquipLoc and EquipLoc ~= "INVTYPE_WEAPONOFFHAND")) then
				local ItemLevel

				ItemLevel = GetDetailedItemLevelInfo(ItemLink)

				if(ItemLevel and ItemLevel > 0) then
					Item = Item + 1
					Total = Total + ItemLevel
				end

				-- Total slots depend if one/two handed weapon
				if (i == 15) then
					if (ArtifactEquipped or (EquipLoc and EquipLoc == "INVTYPE_2HWEAPON")) then
						TotalSlots = 15
					end
				end
			end
		end
	end

	if(Total < 1 or Item < TotalSlots) then
		return
	end

	return floor(Total / Item)
end

function Talents:GetTalentSpec(unit)
	local Spec

	if not unit then
		Spec = GetSpecialization()
	else
		Spec = GetInspectSpecialization(unit)
	end

	if(Spec and Spec > 0) then
		if (unit) then
			local Role = GetSpecializationRoleByID(Spec)

			if (Role) then
				local Name = select(2, GetSpecializationInfoByID(Spec))

				return Name
			end
		else
			local Name = select(2, GetSpecializationInfo(Spec))

			return Name
		end
	end
end

Talents:SetScript("OnUpdate", function(self, elapsed)
	if not (C.Tooltip.Talents) then
		self:Hide()
		self:SetScript("OnUpdate", nil)
	end

	self.NextUpdate = (self.NextUpdate or 0) - elapsed

	if (self.NextUpdate) <= 0 then
		self:Hide()

		local GUID = UnitGUID("mouseover")

		if not GUID then
			return
		end

		if (GUID == self.CurrentGUID) and (not (InspectFrame and InspectFrame:IsShown())) then
			self.LastGUID = self.CurrentGUID
			self.LastInspectRequest = GetTime()
			self:RegisterEvent("INSPECT_READY")
			NotifyInspect(self.CurrentUnit)
		end
	end
end)

Talents:SetScript("OnEvent", function(self, event, GUID)
	if GUID ~= self.LastGUID or (InspectFrame and InspectFrame:IsShown()) then
		self:UnregisterEvent("INSPECT_READY")

		return
	end

	local ILVL = self:GetItemLevel("mouseover")
	local TalentSpec = self:GetTalentSpec("mouseover")
	local CurrentTime = GetTime()
	local MatchFound

	for i, Cache in ipairs(self.Cache) do
		if Cache.GUID == GUID then
			Cache.ItemLevel = ILVL
			Cache.TalentSpec = TalentSpec
			Cache.LastUpdate = floor(CurrentTime)

			MatchFound = true

			break
		end
	end

	if (not MatchFound) then
		local GUIDInfo = {
			["GUID"] = GUID,
			["ItemLevel"] = ILVL,
			["TalentSpec"] = TalentSpec,
			["LastUpdate"] = floor(CurrentTime)
		}

		self.Cache[#self.Cache + 1] = GUIDInfo
	end

	if (#self.Cache > 50) then
		tremove(self.Cache, 1)
	end

	GameTooltip:SetUnit("mouseover")

	ClearInspectPlayer()

	self:UnregisterEvent("INSPECT_READY")
end)

Tooltip.Talents = Talents