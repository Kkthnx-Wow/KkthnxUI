local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

-- Credit: Cloudy Unit Info, by Cloudyfa
local select, max, strfind, format, strsplit = select, math.max, string.find, string.format, string.split
local GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown = GetTime, CanInspect, NotifyInspect, ClearInspectPlayer, IsShiftKeyDown
local UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi = UnitGUID, UnitClass, UnitIsUnit, UnitIsPlayer, UnitIsVisible, UnitIsDeadOrGhost, UnitOnTaxi
local GetInventoryItemTexture, GetInventoryItemLink, GetItemInfo, GetItemGem, GetAverageItemLevel = GetInventoryItemTexture, GetInventoryItemLink, GetItemInfo, GetItemGem, GetAverageItemLevel
local HEIRLOOMS = HEIRLOOMS

local levelPrefix = STAT_AVERAGE_ITEM_LEVEL .. ": " .. K.InfoColor
local isPending = LFG_LIST_LOADING
local resetTime, frequency = 900, 0.5
local cache, weapon, currentUNIT, currentGUID = {}, {}

local Tooltip_TierSets = {
	-- HUNTER
	[229269] = true,
	[229270] = true,
	[229271] = true,
	[229272] = true,
	[229274] = true,
	-- WARRIOR
	[229233] = true,
	[229234] = true,
	[229235] = true,
	[229236] = true,
	[229238] = true,
	-- PALADIN
	[229242] = true,
	[229243] = true,
	[229244] = true,
	[229245] = true,
	[229247] = true,
	-- ROGUE
	[229287] = true,
	[229288] = true,
	[229289] = true,
	[229290] = true,
	[229292] = true,
	-- PRIEST
	[229332] = true,
	[229333] = true,
	[229334] = true,
	[229335] = true,
	[229337] = true,
	-- DEATHKNIGHT
	[229251] = true,
	[229252] = true,
	[229253] = true,
	[229254] = true,
	[229256] = true,
	-- SHAMAN
	[229260] = true,
	[229261] = true,
	[229262] = true,
	[229263] = true,
	[229265] = true,
	-- MAGE
	[229341] = true,
	[229342] = true,
	[229343] = true,
	[229344] = true,
	[229346] = true,
	-- WARLOCK
	[229323] = true,
	[229328] = true,
	[229324] = true,
	[229325] = true,
	[229326] = true,
	-- MONK
	[229296] = true,
	[229297] = true,
	[229298] = true,
	[229299] = true,
	[229301] = true,
	-- DRUID
	[229305] = true,
	[229306] = true,
	[229307] = true,
	[229308] = true,
	[229310] = true,
	-- DEMONHUNTER
	[229314] = true,
	[229315] = true,
	[229316] = true,
	[229317] = true,
	[229319] = true,
	-- EVOKER
	[229278] = true,
	[229279] = true,
	[229280] = true,
	[229281] = true,
	[229283] = true,
}

local formatSets = {
	[1] = " |cff14b200(1/4)", -- green
	[2] = " |cff0091f2(2/4)", -- blue
	[3] = " |cff0091f2(3/4)", -- blue
	[4] = " |cffc745f9(4/4)", -- purple
	[5] = " |cffc745f9(5/5)", -- purple
}

function Module:InspectOnUpdate(elapsed)
	self.elapsed = (self.elapsed or frequency) + elapsed
	if self.elapsed > frequency then
		self.elapsed = 0
		self:Hide()
		ClearInspectPlayer()

		if currentUNIT and UnitGUID(currentUNIT) == currentGUID then
			K:RegisterEvent("INSPECT_READY", Module.GetInspectInfo)
			NotifyInspect(currentUNIT)
		end
	end
end

local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", Module.InspectOnUpdate)
updater:Hide()

local lastTime = 0
function Module:GetInspectInfo(...)
	if self == "UNIT_INVENTORY_CHANGED" then
		local thisTime = GetTime()
		if thisTime - lastTime > 0.1 then
			lastTime = thisTime

			local unit = ...
			if UnitGUID(unit) == currentGUID then
				Module:InspectUnit(unit, true)
			end
		end
	elseif self == "INSPECT_READY" then
		local guid = ...
		if guid == currentGUID then
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

function Module:SetupItemLevel(level)
	local _, unit = GameTooltip:GetUnit()
	if not unit or UnitGUID(unit) ~= currentGUID then
		return
	end

	local levelLineFound = false
	for i = 2, GameTooltip:NumLines() do
		local line = _G[GameTooltip:GetName() .. "TextLeft" .. i]
		local text = line:GetText()
		if text and strfind(text, levelPrefix) then
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
	if not unit or UnitGUID(unit) ~= currentGUID then
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

						local itemID = GetItemInfoFromHyperlink(itemLink)
						if Tooltip_TierSets[itemID] then
							sets = sets + 1
						end

						if unit ~= "player" then
							level = K.GetItemLevel(itemLink) or level
							if i < 16 then
								total = total + level
							elseif i > 15 and quality == Enum.ItemQuality.Artifact then
								local relics = { select(4, strsplit(":", itemLink)) }
								for i = 1, 3 do
									local relicID = relics[i] ~= "" and relics[i]
									local relicLink = select(2, GetItemGem(itemLink, i))
									if relicID and not relicLink then
										delay = true
										break
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
				local higher = max(weapon[1], weapon[2])
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
			ilvl = format("%.1f", ilvl)
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
		if not unit or UnitGUID(unit) ~= currentGUID then
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
	currentUNIT, currentGUID = unit, UnitGUID(unit)
	if not cache[currentGUID] then
		cache[currentGUID] = {}
	end

	Module:InspectUnit(unit)
end
