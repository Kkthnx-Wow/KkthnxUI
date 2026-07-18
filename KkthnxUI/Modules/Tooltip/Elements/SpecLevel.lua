--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Inspects units to display their average item level and tier sets.
-- - Design: Throttled NotifyInspect + GUID cache.
-- - Events: INSPECT_READY, UNIT_INVENTORY_CHANGED
-- Incident (SpecLevel, Jul 2026): C_Item.GetItemInfo returns multi-values, not a
-- table — treating it as `{itemQuality=…}` made every scan `delay` forever.
-- Clear inspect on OnHide only — OnTooltipCleared fires mid-rebuild and aborted
-- NotifyInspect before INSPECT_READY.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

local _G = _G
local math_max = _G.math.max
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_split = _G.string.split
local tonumber = _G.tonumber
local wipe = _G.wipe
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
local UnitIsVisible = _G.UnitIsVisible
local UnitOnTaxi = _G.UnitOnTaxi

local NotSecret = K.NotSecret
local IsSecret = K.IsSecret
local issecretvalue = rawget(_G, "issecretvalue")

-- SECRET (12.0): UnitGUID can flip opaque on mouseover mid-inspect.
local function checkUnitGUID(unit)
	if not unit then
		return nil
	end
	local guid = UnitGUID(unit)
	if not guid then
		return nil
	end
	if issecretvalue and issecretvalue(guid) then
		return nil
	end
	return guid
end

local GetAverageItemLevel = _G.GetAverageItemLevel
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetItemGem = _G.GetItemGem
local GetItemInfo = C_Item.GetItemInfo
local GetItemInfoInstant = C_Item.GetItemInfoInstant
local HEIRLOOMS = _G.HEIRLOOMS
local LFG_LIST_LOADING = _G.LFG_LIST_LOADING
local STAT_AVERAGE_ITEM_LEVEL = _G.STAT_AVERAGE_ITEM_LEVEL

local levelPrefix = STAT_AVERAGE_ITEM_LEVEL .. ": " .. K.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, 0.5
local cache, weapon = {}, {}
local relicScratch = {}
local cacheCount, CACHE_MAX = 0, 200
local currentUNIT, currentGUID, tipShownGUID
local lastTime = 0
local userInspectUntil = 0

-- Don't fight Blizzard's Inspect UI — pause our NotifyInspect briefly after user opens inspect.
hooksecurefunc("InspectUnit", function()
	userInspectUntil = GetTime() + 2
end)

local function matchesCurrentGUID(unit)
	if not (unit and currentGUID and NotSecret(currentGUID)) then
		return false
	end
	local liveGUID = checkUnitGUID(unit)
	return liveGUID ~= nil and liveGUID == currentGUID
end

local Tooltip_TierSets = {
	-- WARRIOR
	[237608] = true,
	[237609] = true,
	[237610] = true,
	[237611] = true,
	[237613] = true,
	-- PALADIN
	[237617] = true,
	[237618] = true,
	[237619] = true,
	[237620] = true,
	[237622] = true,
	-- HUNTER
	[237644] = true,
	[237645] = true,
	[237646] = true,
	[237647] = true,
	[237649] = true,
	-- ROGUE
	[237662] = true,
	[237663] = true,
	[237664] = true,
	[237665] = true,
	[237667] = true,
	-- PRIEST
	[237707] = true,
	[237712] = true,
	[237708] = true,
	[237709] = true,
	[237710] = true,
	-- DEATHKNIGHT
	[237626] = true,
	[237627] = true,
	[237628] = true,
	[237629] = true,
	[237631] = true,
	-- SHAMAN
	[237635] = true,
	[237636] = true,
	[237637] = true,
	[237638] = true,
	[237640] = true,
	-- MAGE
	[237718] = true,
	[237716] = true,
	[237721] = true,
	[237719] = true,
	[237717] = true,
	-- WARLOCK
	[237698] = true,
	[237703] = true,
	[237699] = true,
	[237700] = true,
	[237701] = true,
	-- MONK
	[237671] = true,
	[237672] = true,
	[237673] = true,
	[237674] = true,
	[237676] = true,
	-- DRUID
	[237682] = true,
	[237680] = true,
	[237685] = true,
	[237683] = true,
	[237681] = true,
	-- DEMONHUNTER
	[237689] = true,
	[237690] = true,
	[237691] = true,
	[237692] = true,
	[237694] = true,
	-- EVOKER
	[237653] = true,
	[237654] = true,
	[237655] = true,
	[237656] = true,
	[237658] = true,
}

local formatSets = {
	[1] = " |cff14b200(1/4)",
	[2] = " |cff0091f2(2/4)",
	[3] = " |cff0091f2(3/4)",
	[4] = " |cffc745f9(4/4)",
	[5] = " |cffc745f9(5/5)",
}

-- ---------------------------------------------------------------------------
-- Paint line — keyed by tipShownGUID, not GameTooltip:GetUnit() (can be nil/secret mid-refresh)
-- ---------------------------------------------------------------------------
function Module:SetupItemLevel(level)
	if not GameTooltip:IsShown() then
		return
	end
	if not tipShownGUID or IsSecret(tipShownGUID) or tipShownGUID ~= currentGUID then
		return
	end
	if Module._tipShownGUID ~= tipShownGUID then
		return
	end

	local levelLine
	for i = 2, GameTooltip:NumLines() do
		local line = _G["GameTooltipTextLeft" .. i]
		local text = line and line:GetText()
		if text and NotSecret(text) and string_find(text, levelPrefix) then
			levelLine = line
			break
		end
	end

	local painted = levelPrefix .. (level or isPending)
	if levelLine then
		levelLine:SetText(painted)
	else
		GameTooltip:AddLine(painted)
		GameTooltip:Show()
	end
end

-- ---------------------------------------------------------------------------
-- Slot scan
-- ---------------------------------------------------------------------------
function Module:GetUnitItemLevel(unit)
	if not unit or checkUnitGUID(unit) ~= currentGUID then
		return
	end

	local class = select(2, UnitClass(unit))
	local boa, total, haveWeapon, twohand = 0, 0, 0, 0
	local ilvl, sets = nil, 0
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
					-- C_Item.GetItemInfo is multi-return, not a table (Resources ItemDocumentation).
					local _, _, quality, level, _, _, _, _, slot = GetItemInfo(itemLink)
					if (not quality) or not level then
						delay = true
					else
						if quality == Enum.ItemQuality.Heirloom then
							boa = boa + 1
						end

						local itemID = GetItemInfoInstant and GetItemInfoInstant(itemLink)
						if itemID and Tooltip_TierSets[itemID] then
							sets = sets + 1
						end

						if unit ~= "player" then
							level = K.GetItemLevel(itemLink) or level
							if i < 16 then
								total = total + level
							elseif i > 15 and quality == Enum.ItemQuality.Artifact then
								if GetItemGem then
									relicScratch[1], relicScratch[2], relicScratch[3] = select(4, string_split(":", itemLink))
									for r = 1, 3 do
										local relicID = relicScratch[r] and relicScratch[r] ~= "" and relicScratch[r]
										local relicLink = select(2, GetItemGem(itemLink, r))
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

	if delay then
		return
	end

	if unit == "player" then
		ilvl = select(2, GetAverageItemLevel())
	else
		if hasArtifact or twohand == 2 then
			total = total + math_max(weapon[1], weapon[2]) * 2
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

	if ilvl and ilvl > 0 then
		ilvl = string_format("%.1f", ilvl)
	end
	if boa > 0 then
		ilvl = ilvl .. " - |cff00ccff" .. boa .. " " .. HEIRLOOMS
	end
	if sets > 0 then
		ilvl = ilvl .. (formatSets[sets] or "")
	end

	return ilvl
end

-- ---------------------------------------------------------------------------
-- Inspect throttle + events
-- ---------------------------------------------------------------------------
local updater = CreateFrame("Frame")
updater:Hide()
updater:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self:Hide()
		ClearInspectPlayer()
		-- Only inspect while this tip is still the shown one.
		if not currentUNIT or not currentGUID or Module._tipShownGUID ~= tipShownGUID then
			return
		end
		if checkUnitGUID(currentUNIT) == currentGUID then
			K:RegisterEvent("INSPECT_READY", Module.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end)

local inspectInventoryUnit

local function clearInspectInventoryWatch()
	if inspectInventoryUnit then
		K:UnregisterEvent("UNIT_INVENTORY_CHANGED", Module.GetInspectInfo)
		inspectInventoryUnit = nil
	end
end

local function setInspectInventoryWatch(unit)
	clearInspectInventoryWatch()
	if unit and not K.UnitIsUnit(unit, "player") then
		K:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", Module.GetInspectInfo, unit)
		inspectInventoryUnit = unit
	end
end

function Module.GetInspectInfo(event, ...)
	if event == "UNIT_INVENTORY_CHANGED" then
		if not currentGUID or Module._tipShownGUID ~= tipShownGUID then
			return
		end
		local thisTime = GetTime()
		if thisTime - lastTime > 0.1 then
			lastTime = thisTime
			local unit = ...
			if matchesCurrentGUID(unit) then
				Module:InspectUnit(unit, true)
			end
		end
	elseif event == "INSPECT_READY" then
		local guid = ...
		if NotSecret(guid) and guid == currentGUID and guid == tipShownGUID and Module._tipShownGUID == tipShownGUID and cache[guid] then
			local level = Module:GetUnitItemLevel(currentUNIT)
			cache[guid].level = level
			cache[guid].getTime = GetTime()
			if level then
				Module:SetupItemLevel(level)
			else
				Module:InspectUnit(currentUNIT, true)
			end
		end
		clearInspectInventoryWatch()
		K:UnregisterEvent("INSPECT_READY", Module.GetInspectInfo)
	end
end

function Module:InspectUnit(unit, forced)
	local level

	if K.UnitIsUnit(unit, "player") then
		clearInspectInventoryWatch()
		level = self:GetUnitItemLevel("player")
		self:SetupItemLevel(level)
		return
	end

	if not unit or checkUnitGUID(unit) ~= currentGUID then
		clearInspectInventoryWatch()
		return
	end
	if not UnitIsPlayer(unit) then
		return
	end

	local currentDB = cache[currentGUID]
	if not currentDB then
		return
	end

	level = currentDB.level
	self:SetupItemLevel(level)

	if not C["Tooltip"].SpecLevelByShift and IsShiftKeyDown() then
		forced = true
	end
	if level and not forced and (GetTime() - (currentDB.getTime or 0) < resetTime) then
		updater.elapsed = frequency
		return
	end
	if not UnitIsVisible(unit) or UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then
		return
	end
	if InspectFrame and InspectFrame:IsShown() then
		return
	end
	if GetTime() < userInspectUntil then
		return
	end

	self:SetupItemLevel()
	setInspectInventoryWatch(unit)
	updater.retries = 0
	updater:Show()
end

function Module:InspectUnitItemLevel(unit, guid)
	if C["Tooltip"].SpecLevelByShift and not IsShiftKeyDown() then
		return
	end

	if not unit or not CanInspect(unit) then
		return
	end

	currentUNIT = unit
	-- Prefer plain tip data.guid when UnitGUID(unit) is opaque.
	currentGUID = (guid and NotSecret(guid) and guid) or checkUnitGUID(unit)
	tipShownGUID = currentGUID
	Module._tipShownGUID = tipShownGUID

	if not currentGUID then
		return
	end
	if not cache[currentGUID] then
		if cacheCount >= CACHE_MAX then
			wipe(cache)
			cacheCount = 0
		end
		cache[currentGUID] = {}
		cacheCount = cacheCount + 1
	end

	Module:InspectUnit(unit)
end

-- Called from GameTooltip OnHide — not OnTooltipCleared (cleared fires mid-rebuild).
function Module:ClearItemLevelInspectState()
	currentUNIT, currentGUID, tipShownGUID = nil, nil, nil
	Module._tipShownGUID = nil
	clearInspectInventoryWatch()
	updater.elapsed = frequency
	updater.retries = 0
	updater:Hide()
	K:UnregisterEvent("INSPECT_READY", Module.GetInspectInfo)
end
