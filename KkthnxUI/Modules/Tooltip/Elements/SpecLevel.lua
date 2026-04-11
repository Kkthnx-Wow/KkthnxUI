--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Inspects units to display their average item level and tier sets.
-- - Design: Hooks tooltip and uses NotifyInspect with a local cache/throttle.
-- - Events: INSPECT_READY, UNIT_INVENTORY_CHANGED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Tooltip")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local math_max = _G.math.max
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_split = _G.string.split
local GetTime = _G.GetTime

local C_Item = _G.C_Item
local CanInspect = _G.CanInspect
local ClearInspectPlayer = _G.ClearInspectPlayer
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local InspectFrame = _G.InspectFrame
local IsShiftKeyDown = _G.IsShiftKeyDown
local NotifyInspect = _G.NotifyInspect
local UnitClass = _G.UnitClass
local UnitGUID = _G.UnitGUID
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitIsVisible = _G.UnitIsVisible
local UnitOnTaxi = _G.UnitOnTaxi

local GetAverageItemLevel = _G.GetAverageItemLevel
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetItemGem = _G.GetItemGem
local GetItemInfo = _G.GetItemInfo
local HEIRLOOMS = _G.HEIRLOOMS
local LFG_LIST_LOADING = _G.LFG_LIST_LOADING
local STAT_AVERAGE_ITEM_LEVEL = _G.STAT_AVERAGE_ITEM_LEVEL

local C_Item_GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant

local levelPrefix = STAT_AVERAGE_ITEM_LEVEL .. ": " .. K.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, 0.5
local cache, weapon, currentUNIT, currentGUID = {}, {}

local Tooltip_TierSets = {
	-- WARRIOR
	[249950] = true,
	[249951] = true,
	[249952] = true,
	[249953] = true,
	[249955] = true,
	-- PALADIN
	[249959] = true,
	[249960] = true,
	[249961] = true,
	[249962] = true,
	[249964] = true,
	-- HUNTER
	[249986] = true,
	[249987] = true,
	[249988] = true,
	[249989] = true,
	[249991] = true,
	-- ROGUE
	[250004] = true,
	[250005] = true,
	[250006] = true,
	[250007] = true,
	[250009] = true,
	-- PRIEST
	[250049] = true,
	[250054] = true,
	[250050] = true,
	[250051] = true,
	[250052] = true,
	-- DEATHKNIGHT
	[249968] = true,
	[249969] = true,
	[249970] = true,
	[249971] = true,
	[249973] = true,
	-- SHAMAN
	[249977] = true,
	[249978] = true,
	[249979] = true,
	[249980] = true,
	[249982] = true,
	-- MAGE
	[250058] = true,
	[250059] = true,
	[250060] = true,
	[250061] = true,
	[250063] = true,
	-- WARLOCK
	[250040] = true,
	[250041] = true,
	[250042] = true,
	[250043] = true,
	[250045] = true,
	-- MONK
	[250013] = true,
	[250014] = true,
	[250015] = true,
	[250016] = true,
	[250018] = true,
	-- DRUID
	[250022] = true,
	[250023] = true,
	[250024] = true,
	[250025] = true,
	[250027] = true,
	-- DEMONHUNTER
	[250031] = true,
	[250032] = true,
	[250033] = true,
	[250034] = true,
	[250036] = true,
	-- EVOKER
	[249995] = true,
	[249996] = true,
	[249997] = true,
	[249998] = true,
	[250000] = true,
}

local formatSets = {
	[1] = " |cff14b200(1/4)", -- green
	[2] = " |cff0091f2(2/4)", -- blue
	[3] = " |cff0091f2(3/4)", -- blue
	[4] = " |cffc745f9(4/4)", -- purple
	[5] = " |cffc745f9(5/5)", -- purple
}

local function checkUnitGUID(unit)
	local guid = UnitGUID(unit)
	return K.NotSecretValue(guid) and guid
end

-- REASON: Throttles inspect requests to prevent server spam and Blizzard API limits.
function Module:InspectOnUpdate(elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self.retries = (self.retries or 0) + 1

		if self.retries > 10 then -- safety: stop after ~5s (10 * 0.5)
			self:Hide()
			self.retries = 0
			return
		end

		self:Hide()
		ClearInspectPlayer()

		if currentUNIT and checkUnitGUID(currentUNIT) == currentGUID then
			K:RegisterEvent("INSPECT_READY", Module.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", Module.InspectOnUpdate)
updater:Hide()

local lastTime = 0
-- REASON: Event handler for inspect results and inventory updates.
function Module:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		local thisTime = GetTime()
		if thisTime - lastTime > 0.1 then
			lastTime = thisTime

			local unit = ...
			if checkUnitGUID(unit) == currentGUID then
				Module:InspectUnit(unit, true)
			end
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if K.NotSecretValue(guid) and guid == currentGUID then
			local level = Module:GetUnitItemLevel(currentUNIT)
			cache[guid].level = level
			cache[guid].getTime = GetTime()

			if level then
				Module:SetupItemLevel(level)
			else
				Module:InspectUnit(currentUNIT, true)
			end
		end
		K:UnregisterEvent(self, Module.GetInspectInfo)
	end
end
K:RegisterEvent("UNIT_INVENTORY_CHANGED", Module.GetInspectInfo)

-- REASON: Injects or updates the item level line in the GameTooltip.
function Module:SetupItemLevel(level)
	local _, unit = GameTooltip:GetUnit()
	if not unit or UnitGUID(unit) ~= currentGUID then
		return
	end

	local levelLineFound = false
	for i = 2, GameTooltip:NumLines() do
		local line = _G[GameTooltip:GetName() .. "TextLeft" .. i]
		local text = line:GetText()

		if text and K.NotSecretValue(text) and string_find(text, levelPrefix) then
			levelLineFound = true
			line:SetText(levelPrefix .. (level or isPending))
			break
		end
	end

	if not levelLineFound then
		GameTooltip:AddLine(levelPrefix .. (level or isPending))
	end
end

function Module:GetUnitItemLevel(unit)
	if not unit or checkUnitGUID(unit) ~= currentGUID then
		return
	end

	local class = select(2, UnitClass(unit))
	local ilvl, boa, total, haveWeapon, twohand, sets = nil, 0, 0, 0, 0, 0 -- Change "0" to nil
	local delay, mainhand, offhand, hasArtifact
	weapon[1], weapon[2] = 0, 0

	for i = 1, 17 do
		if i ~= 4 then
			local itemTexture = GetInventoryItemTexture(unit, i)

			if itemTexture then
				local itemLink = GetInventoryItemLink(unit, i)

				if not itemLink then
					delay = true
				else
					local _, _, quality, level, _, _, _, _, slot = GetItemInfo(itemLink)
					if (not quality) or not level then
						delay = true
					else
						if quality == Enum.ItemQuality.Heirloom then
							boa = boa + 1
						end

						local itemID = C_Item_GetItemInfoInstant and C_Item_GetItemInfoInstant(itemLink)
						if Tooltip_TierSets[itemID] then
							sets = sets + 1
						end

						if unit ~= "player" then
							level = K.GetItemLevel(itemLink) or level
							if i < 16 then
								total = total + level
							elseif i > 15 and quality == Enum.ItemQuality.Artifact then
								-- Legacy artifact relic scan; skip if API removed
								if GetItemGem then
									local relics = { select(4, string_split(":", itemLink)) }
									for i = 1, 3 do
										local relicID = relics[i] ~= "" and relics[i]
										local relicLink = select(2, GetItemGem(itemLink, i))
										if relicID and not relicLink then
											delay = true
											break
										end
									end
								end
							end

							if i == 16 then
								if quality == Enum.ItemQuality.Artifact then
									hasArtifact = true
								end

								weapon[1] = level
								haveWeapon = haveWeapon + 1
								if slot == "INVTYPE_2HWEAPON" or slot == "INVTYPE_RANGED" or (slot == "INVTYPE_RANGEDRIGHT" and class == "HUNTER") then
									mainhand = true
									twohand = twohand + 1
								end
							elseif i == 17 then
								weapon[2] = level
								haveWeapon = haveWeapon + 1
								if slot == "INVTYPE_2HWEAPON" then
									offhand = true
									twohand = twohand + 1
								end
							end
						end
					end
				end
			end
		end
	end

	if not delay then
		if unit == "player" then
			ilvl = select(2, GetAverageItemLevel())
		else
			if hasArtifact or twohand == 2 then
				local higher = math_max(weapon[1], weapon[2])
				total = total + higher * 2
			elseif twohand == 1 and haveWeapon == 1 then
				total = total + weapon[1] * 2 + weapon[2] * 2
			elseif twohand == 1 and haveWeapon == 2 then
				if mainhand and weapon[1] >= weapon[2] then
					total = total + weapon[1] * 2
				elseif offhand and weapon[2] >= weapon[1] then
					total = total + weapon[2] * 2
				else
					total = total + weapon[1] + weapon[2]
				end
			else
				total = total + weapon[1] + weapon[2]
			end
			ilvl = total / 16
		end

		if ilvl and ilvl > 0 then -- Add a check for nil before comparing
			ilvl = string_format("%.1f", ilvl)
		end
		if boa > 0 then
			ilvl = ilvl .. " - |cff00ccff" .. boa .. " " .. HEIRLOOMS
		end
		if sets > 0 then
			ilvl = ilvl .. formatSets[sets]
		end
	end

	return ilvl
end

function Module:InspectUnit(unit, forced)
	local level

	if UnitIsUnit(unit, "player") then
		level = self:GetUnitItemLevel("player")
		self:SetupItemLevel(level)
	else
		if not unit or checkUnitGUID(unit) ~= currentGUID then
			return
		end

		if not UnitIsPlayer(unit) then
			return
		end

		local currentDB = cache[currentGUID]
		level = currentDB.level
		self:SetupItemLevel(level)

		if not C["Tooltip"].SpecLevelByShift and IsShiftKeyDown() then
			forced = true
		end
		if level and not forced and (GetTime() - currentDB.getTime < resetTime) then
			updater.elapsed = frequency
			return
		end
		if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
			return
		end
		if InspectFrame and InspectFrame:IsShown() then
			return
		end

		self:SetupItemLevel()
		updater.retries = 0
		updater:Show()
	end
end

function Module:InspectUnitItemLevel(unit)
	if C["Tooltip"].SpecLevelByShift and not IsShiftKeyDown() then
		return
	end

	if not unit or not CanInspect(unit) then
		return
	end
	currentUNIT, currentGUID = unit, checkUnitGUID(unit)
	if not cache[currentGUID] then
		cache[currentGUID] = {}
	end

	Module:InspectUnit(unit)
end
