local K, C, L = select(2, ...):unpack()
if C.Tooltip.Enable ~= true or C.Tooltip.ShowSpec ~= true then return end

local Tooltip = K.Tooltip
local Talent = CreateFrame("Frame")
local format = string.format

Talent.Cache = {}
Talent.LastInspectRequest = 0
Talent.SlotNames = {
	"Head","Neck","Shoulder","Back","Chest","Wrist",
	"Hands","Waist","Legs","Feet","Finger0","Finger1",
	"Trinket0","Trinket1","MainHand","SecondaryHand"
}

function Talent:GetItemLevel(unit)
	local total, item = 0, 0
	local artifactEquipped = false
	for i = 1, #Talent.SlotNames do
		local itemLink = GetInventoryItemLink(unit, GetInventorySlotInfo(("%sSlot"):format(Talent.SlotNames[i])))
		if (itemLink ~= nil) then
			local _, _, rarity, _, _, _, _, _, equipLoc = GetItemInfo(itemLink)
			-- Check if we have an artifact equipped in main hand
			if (equipLoc and equipLoc == "INVTYPE_WEAPONMAINHAND" and rarity and rarity == 6) then
				artifactEquipped = true
			end
			-- If we have artifact equipped in main hand, then we should not count the offhand as it displays an incorrect item level
			if (not artifactEquipped or (artifactEquipped and equipLoc and equipLoc ~= "INVTYPE_WEAPONOFFHAND")) then
				local itemLevel
				itemLevel = GetDetailedItemLevelInfo(itemLink)
				if(itemLevel and itemLevel > 0) then
					item = item + 1
					total = total + itemLevel
				end
			end
		end
	end
	if(total < 1 or item < 15) then
		return
	end
	return floor(total / item)
end

function Talent:GetTalentSpec(unit)
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

Talent:SetScript("OnUpdate", function(self, elapsed)
	if not (C.Tooltip.ShowSpec) then
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

Talent:SetScript("OnEvent", function(self, event, GUID)
	if GUID ~= self.LastGUID or (InspectFrame and InspectFrame:IsShown()) then
		self:UnregisterEvent("INSPECT_READY")

		return
	end

	local unit = "mouseover"
	local ItemLevel = self:GetItemLevel(unit)
	local TalentSpec = self:GetTalentSpec(unit)
	local CurrentTime = GetTime()
	local MatchFound

	for i, Cache in ipairs(self.Cache) do
		if Cache.GUID == GUID then
			Cache.ItemLevel = ItemLevel
			Cache.TalentSpec = TalentSpec
			Cache.LastUpdate = floor(CurrentTime)

			MatchFound = true

			break
		end
	end

	if (not MatchFound) then
		local GUIDInfo = {
			["GUID"] = GUID,
			["ItemLevel"] = ItemLevel,
			["TalentSpec"] = TalentSpec,
			["LastUpdate"] = floor(CurrentTime)
		}

		self.Cache[#self.Cache + 1] = GUIDInfo
	end

	if (#self.Cache > 50) then
		table.remove(self.Cache, 1)
	end

	GameTooltip:SetUnit("mouseover")

	ClearInspectPlayer()

	self:UnregisterEvent("INSPECT_READY")
end)

Tooltip.Talent = Talent