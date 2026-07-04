--[[-----------------------------------------------------------------------------
-- Aura filter persistence, custom-unit tables, group role cache, power whitelist.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")
local NP = Module.NP

local table_wipe = table.wipe
local tonumber = tonumber
local pairs = pairs
local UnitExists = UnitExists
local UnitName = UnitName
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers

local customUnits = NP.customUnits
local showPowerList = NP.showPowerList
local groupRoles = NP.groupRoles

local AURA_FILTER_CATEGORIES = {
	"NameplateWhiteList",
	"NameplateBlackList",
	"NameplateCustomUnits",
	"NameplateTargetNPCs",
	"NameplateTrashUnits",
	"MajorSpells",
}

function Module:ApplyNameplateAuraOverrides()
	if not KkthnxUIDB or type(KkthnxUIDB.Variables) ~= "table" then
		return
	end

	local realmData = KkthnxUIDB.Variables[K.Realm]
	local charData = realmData and realmData[K.Name]
	local store = charData and charData.NameplateAuraFilters
	if type(store) ~= "table" then
		return
	end

	for i = 1, #AURA_FILTER_CATEGORIES do
		local category = AURA_FILTER_CATEGORIES[i]
		local catStore = store[category]
		local baseTable = C[category]
		if type(baseTable) == "table" and type(catStore) == "table" then
			if type(catStore.removed) == "table" then
				for id in pairs(catStore.removed) do
					baseTable[tonumber(id) or id] = nil
				end
			end
			if type(catStore.added) == "table" then
				for id in pairs(catStore.added) do
					baseTable[tonumber(id) or id] = true
				end
			end
		end
	end
end

function Module:CreateUnitTable()
	table_wipe(customUnits)
	if not C["Nameplate"].CustomUnitColor then
		return
	end

	K.CopyTable(C.NameplateCustomUnits, customUnits)
	K.SplitList(customUnits, C["Nameplate"].CustomUnitList)
end

function Module:CreatePowerUnitTable()
	table_wipe(showPowerList)
	K.CopyTable(C.NameplateShowPowerList, showPowerList)
	K.SplitList(showPowerList, C["Nameplate"].PowerUnitList)
end

function Module:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
	if shouldShowPower then
		self.powerText:Show()
	else
		self.powerText:Hide()
	end
end

local function refreshGroupRoles()
	local isRaid = IsInRaid()
	NP.isInGroup = isRaid or IsInGroup()

	table_wipe(groupRoles)

	if NP.isInGroup then
		local numPlayers = (isRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()
		local unitPrefix = (isRaid and "raid") or "party"

		for i = 1, numPlayers do
			local unit = unitPrefix .. i
			if UnitExists(unit) then
				groupRoles[UnitName(unit)] = UnitGroupRolesAssigned(unit)
			end
		end
	end
end

local function resetGroupRoles()
	NP.isInGroup = IsInRaid() or IsInGroup()
	table_wipe(groupRoles)
end

function Module:UpdateGroupRoles()
	refreshGroupRoles()

	K:UnregisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	K:UnregisterEvent("GROUP_LEFT", resetGroupRoles)

	K:RegisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	K:RegisterEvent("GROUP_LEFT", resetGroupRoles)
end
