local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Tooltip", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")
local ModuleSkins -- used to hold the skin module when we need it

local _G = _G
local ipairs = ipairs
local math_floor = math.floor
local select = select
local string_find = string.find
local string_format = string.format
local string_gmatch = string.gmatch
local string_match = string.match
local string_sub = string.sub
local table_insert = table.insert
local table_wipe = table.wipe
local tonumber = tonumber
local unpack = unpack

local BOSS = _G.BOSS
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local C_MountJournal_GetMountIDs = _G.C_MountJournal.GetMountIDs
local C_MountJournal_GetMountInfoByID = _G.C_MountJournal.GetMountInfoByID
local C_MountJournal_GetMountInfoExtraByID = _G.C_MountJournal.GetMountInfoExtraByID
local C_PetBattles_IsInBattle = _G.C_PetBattles.IsInBattle
local C_PetJournal_FindPetIDByName = _G.C_PetJournal.FindPetIDByName
local C_PetJournal_GetPetStats = _G.C_PetJournal.GetPetStats
local C_PetJournal_GetPetTeamAverageLevel = _G.C_PetJournal.GetPetTeamAverageLevel
local CanInspect = _G.CanInspect
local CreateFrame = _G.CreateFrame
local DEAD = _G.DEAD
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local FACTION_HORDE = _G.FACTION_HORDE
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL
local FROM = _G.FROM
local GameTooltipHeaderText = _G.GameTooltipHeaderText
local GameTooltipText = _G.GameTooltipText
local GameTooltipTextSmall = _G.GameTooltipTextSmall
local GameTooltip_ClearMoney = _G.GameTooltip_ClearMoney
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local GetGuildInfo = _G.GetGuildInfo
local GetInspectSpecialization = _G.GetInspectSpecialization
local GetItemCount = _G.GetItemCount
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMouseFocus = _G.GetMouseFocus
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetRelativeDifficultyColor = _G.GetRelativeDifficultyColor
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetTime = _G.GetTime
local HEALER = _G.HEALER
local ID = _G.ID
local INTERACTIVE_SERVER_LABEL = _G.INTERACTIVE_SERVER_LABEL
local ITEM_QUALITY3_DESC = _G.ITEM_QUALITY3_DESC
local IsControlKeyDown = _G.IsControlKeyDown
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsShiftKeyDown = _G.IsShiftKeyDown
local ItemRefTooltip = _G.ItemRefTooltip
local LE_REALM_RELATION_COALESCED = _G.LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL
local MOUNT = _G.MOUNT
local NotifyInspect = _G.NotifyInspect
local PVP = _G.PVP
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local ROLE = _G.ROLE
local SPECIALIZATION = _G.SPECIALIZATION
local STAT_AVERAGE_ITEM_LEVEL = _G.STAT_AVERAGE_ITEM_LEVEL
local STAT_DPS_SHORT = _G.STAT_DPS_SHORT
local SetTooltipMoney = _G.SetTooltipMoney
local ShoppingTooltip1TextLeft1 = _G.ShoppingTooltip1TextLeft1
local ShoppingTooltip1TextLeft2 = _G.ShoppingTooltip1TextLeft2
local ShoppingTooltip1TextLeft3 = _G.ShoppingTooltip1TextLeft3
local ShoppingTooltip1TextLeft4 = _G.ShoppingTooltip1TextLeft4
local ShoppingTooltip1TextRight1 = _G.ShoppingTooltip1TextRight1
local ShoppingTooltip1TextRight2 = _G.ShoppingTooltip1TextRight2
local ShoppingTooltip1TextRight3 = _G.ShoppingTooltip1TextRight3
local ShoppingTooltip1TextRight4 = _G.ShoppingTooltip1TextRight4
local ShoppingTooltip2TextLeft1 = _G.ShoppingTooltip2TextLeft1
local ShoppingTooltip2TextLeft2 = _G.ShoppingTooltip2TextLeft2
local ShoppingTooltip2TextLeft3 = _G.ShoppingTooltip2TextLeft3
local ShoppingTooltip2TextLeft4 = _G.ShoppingTooltip2TextLeft4
local ShoppingTooltip2TextRight1 = _G.ShoppingTooltip2TextRight1
local ShoppingTooltip2TextRight2 = _G.ShoppingTooltip2TextRight2
local ShoppingTooltip2TextRight3 = _G.ShoppingTooltip2TextRight3
local ShoppingTooltip2TextRight4 = _G.ShoppingTooltip2TextRight4
local TANK = _G.TANK
local TARGET = _G.TARGET
local TOOLTIP_UNIT_LEVEL = _G.TOOLTIP_UNIT_LEVEL
local TOOLTIP_UNIT_LEVEL_CLASS = _G.TOOLTIP_UNIT_LEVEL_CLASS
local TUTORIAL_TITLE19 = _G.TUTORIAL_TITLE19
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitBattlePetType = _G.UnitBattlePetType
local UnitBuff = _G.UnitBuff
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitCreatureType = _G.UnitCreatureType
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGUID = _G.UnitGUID
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsAFK = _G.UnitIsAFK
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsDND = _G.UnitIsDND
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsUnit = _G.UnitIsUnit
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPVPName = _G.UnitPVPName
local UnitRace = _G.UnitRace
local UnitReaction = _G.UnitReaction
local UnitRealmRelationship = _G.UnitRealmRelationship

local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]
local targetList = {}
local TAPPED_COLOR = {r = .6, g = .6, b = .6}
local AFK_LABEL = " |cffFFFFFF[|r|cffFF0000" .. "AFK" .. "|r|cffFFFFFF]|r"
local DND_LABEL = " |cffFFFFFF[|r|cffFFFF00" .. "DND" .. "|r|cffFFFFFF]|r"
local TOOLTOP_BUG = false

-- Custom to find LEVEL string on tooltip
local LEVEL1 = TOOLTIP_UNIT_LEVEL:gsub("%s?%%s%s?%-?", "")
local LEVEL2 = TOOLTIP_UNIT_LEVEL_CLASS:gsub("^%%2$s%s?(.-)%s?%%1$s", "%1"):gsub("^%-?г?о?%s?", ""):gsub("%s?%%s%s?%-?", "")

local ignoreSubType = {
	L["Tooltip"].Other == true,
	L["Tooltip"].Item_Enhancement == true
}

local classification = {
	worldboss = string_format("|cffAF5050 %s|r", BOSS),
	rareelite = string_format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = string_format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}

function Module:GameTooltip_SetDefaultAnchor(tt, parent)
	if tt:IsForbidden() then
		return
	end

	if C["Tooltip"].Enable ~= true then
		return
	end

	if (parent) then
		if (not GameTooltipStatusBar.anchoredToTop and GameTooltipStatusBar) then
			GameTooltipStatusBar:ClearAllPoints()
			GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 3, 3)
			GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -3, 3)
			GameTooltipStatusBar.text:SetPoint("CENTER", GameTooltipStatusBar, 0, 6)
			GameTooltipStatusBar.anchoredToTop = true
		end

		if (C["Tooltip"].CursorAnchor) then
			tt:SetOwner(parent, "ANCHOR_CURSOR_RIGHT", C["Tooltip"].CursorAnchorX, C["Tooltip"].CursorAnchorY)
			return
		else
			tt:SetOwner(parent, "ANCHOR_NONE")
		end
	end

	tt:SetPoint("BOTTOMRIGHT", GameTooltipAnchor, "BOTTOMRIGHT", 2, -2)
end

function Module:RemoveTrashLines(tt)
	if tt:IsForbidden() then
		return
	end

	for i = 3, tt:NumLines() do
		local tiptext = _G["GameTooltipTextLeft" .. i]
		local linetext = tiptext:GetText()

		if (linetext == PVP or linetext == FACTION_ALLIANCE or linetext == FACTION_HORDE) then
			tiptext:SetText(nil)
			tiptext:Hide()
		end
	end
end

function Module:GetLevelLine(tt, offset)
	if tt:IsForbidden() then
		return
	end

	for i = offset, tt:NumLines() do
		local tipLine = _G["GameTooltipTextLeft" .. i]
		local tipText = tipLine and tipLine.GetText and tipLine:GetText()
		if tipText and (tipText:find(LEVEL1) or tipText:find(LEVEL2)) then
			return tipLine
		end
	end
end

function Module:SetUnitText(tt, unit, level, isShiftKeyDown)
	local color
	if UnitIsPlayer(unit) then
		local localeClass, class = UnitClass(unit)
		local name, realm = UnitName(unit)
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)

		if not localeClass or not class then
			return
		end

		color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]

		if C["Tooltip"].PlayerTitles and pvpName then
			name = pvpName
		end

		if realm and realm ~= "" then
			if (isShiftKeyDown)then
				name = name .. "-" .. realm
			elseif(relationship == LE_REALM_RELATION_COALESCED) then
				name = name .. FOREIGN_SERVER_LABEL
			elseif(relationship == LE_REALM_RELATION_VIRTUAL) then
				name = name .. INTERACTIVE_SERVER_LABEL
			end
		end

		if UnitIsAFK(unit) then
			name = name .. AFK_LABEL
		elseif UnitIsDND(unit) then
			name = name .. DND_LABEL
		end

		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", color.colorStr, name)

		local lineOffset = 2
		if guildName then
			if guildRealm and isShiftKeyDown then
				guildName = guildName .. "-" .. guildRealm
			end

			if C["Tooltip"].GuildRanks then
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r> [|cff00ff10%s|r]"):format(guildName, guildRankName))
			else
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r>"):format(guildName))
			end

			lineOffset = 3
		end

		local levelLine = self:GetLevelLine(tt, lineOffset)
		if levelLine then
			local diffColor = GetCreatureDifficultyColor(level)
			local race, englishRace = UnitRace(unit)
			local _, factionGroup = UnitFactionGroup(unit)

			if (factionGroup and englishRace == "Pandaren") then
				race = factionGroup .. " " .. race
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s |c%s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or "", color.colorStr, localeClass)
		end

		if C["Tooltip"].PlayerRoles then
			local r, g, b, role = 1, 1, 1, UnitGroupRolesAssigned(unit)
			if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= "NONE") then
				if role == "HEALER" then
					role, r, g, b = HEALER, 0.0, 1.0, 0.59
				elseif role == "TANK" then
					role, r, g, b = TANK, 0.16, 0.31, 0.61
				elseif role == "DAMAGER" then
					role, r, g, b = STAT_DPS_SHORT, 0.77, 0.12, 0.24
				end

				GameTooltip:AddDoubleLine(string_format("%s:", ROLE), role, nil, nil, nil, r, g, b)
			end
		end
	else
		if UnitIsTapDenied(unit) then
			color = TAPPED_COLOR
		else
			local unitReaction = UnitReaction(unit, "player")
			if unitReaction then
				unitReaction = string_format("%s", unitReaction) -- Cast to string because our table is indexed by string keys
				color = K.Colors.factioncolors[unitReaction]
			end
		end

		local levelLine = self:GetLevelLine(tt, 2)
		if levelLine then
			local isPetWild, isPetCompanion = UnitIsWildBattlePet(unit), UnitIsBattlePetCompanion(unit)
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local diffColor
			if (isPetWild or isPetCompanion) then
				level = UnitBattlePetLevel(unit)

				local petType = _G["BATTLE_PET_NAME_"..UnitBattlePetType(unit)]
				if creatureType then
					creatureType = string_format("%s %s", creatureType, petType)
				else
					creatureType = petType
				end

				local teamLevel = C_PetJournal_GetPetTeamAverageLevel()
				if (teamLevel) then
					diffColor = GetRelativeDifficultyColor(teamLevel, level)
				else
					diffColor = GetCreatureDifficultyColor(level)
				end
			else
				diffColor = GetCreatureDifficultyColor(level)
			end

			if (UnitIsPVP(unit)) then
				pvpFlag = string_format(" (%s)", PVP)
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)
		end
	end

	return color or RAID_CLASS_COLORS.PRIEST
end

local inspectGUIDCache = {}
local inspectColorFallback = {1, 1, 1}
function Module:PopulateInspectGUIDCache(unitGUID, itemLevel)
	local specName = self:GetSpecializationInfo('mouseover')
	if specName and itemLevel then
		local unitColor = inspectGUIDCache[unitGUID].unitColor

		inspectGUIDCache[unitGUID].time = GetTime()
		inspectGUIDCache[unitGUID].itemLevel = itemLevel
		inspectGUIDCache[unitGUID].specName = specName

		GameTooltip:AddDoubleLine(SPECIALIZATION..":", specName, nil, nil, nil, unpack(unitColor or inspectColorFallback))
		GameTooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", itemLevel, nil, nil, nil, 1, 1, 1)
		GameTooltip:Show()
	end
end

function Module:INSPECT_READY(event, unitGUID)
	if UnitExists("mouseover") and UnitGUID("mouseover") == unitGUID then
		local itemLevel, retryUnit, retryTable, iLevelDB = K.GetUnitItemLevel("mouseover")
		if itemLevel == 'tooSoon' then
			K.Delay(0.05, function()
				local canUpdate = true
				for _, x in ipairs(retryTable) do
					local iLvl = K.GetGearSlotInfo(retryUnit, x)
					if iLvl == 'tooSoon' then
						canUpdate = false
					else
						iLevelDB[x] = iLvl
					end
				end

				if canUpdate then
					local calculateItemLevel = K.CalculateAverageItemLevel(iLevelDB, retryUnit)
					Module:PopulateInspectGUIDCache(unitGUID, calculateItemLevel)
				end
			end)
		else
			Module:PopulateInspectGUIDCache(unitGUID, itemLevel)
		end
	end

	if event then
		self:UnregisterEvent(event)
	end
end

function Module:GetSpecializationInfo(unit, isPlayer)
	local spec = (isPlayer and GetSpecialization()) or (unit and GetInspectSpecialization(unit))
	if spec and spec > 0 then
		if isPlayer then
			return select(2, GetSpecializationInfo(spec))
		else
			return select(2, GetSpecializationInfoByID(spec))
		end
	end
end

local lastGUID
function Module:AddInspectInfo(tooltip, unit, numTries, r, g, b)
	if (not unit) or (numTries > 3) or not CanInspect(unit) then
		return
	end

	local unitGUID = UnitGUID(unit)
	if not unitGUID then
		return
	end

	if unitGUID == K.GUID then
		tooltip:AddDoubleLine(SPECIALIZATION..":", self:GetSpecializationInfo(unit, true), nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", K.GetUnitItemLevel(unit), nil, nil, nil, 1, 1, 1)
	elseif inspectGUIDCache[unitGUID] and inspectGUIDCache[unitGUID].time then
		local specName = inspectGUIDCache[unitGUID].specName
		local itemLevel = inspectGUIDCache[unitGUID].itemLevel
		if not (specName and itemLevel) or (GetTime() - inspectGUIDCache[unitGUID].time > 120) then
			inspectGUIDCache[unitGUID].time = nil
			inspectGUIDCache[unitGUID].specName = nil
			inspectGUIDCache[unitGUID].itemLevel = nil
			return K.Delay(0.33, function()
				self:AddInspectInfo(tooltip, unit, numTries + 1, r, g, b)
			end)
		end

		tooltip:AddDoubleLine(SPECIALIZATION..":", specName, nil, nil, nil, r, g, b)
		tooltip:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL..":", itemLevel, nil, nil, nil, 1, 1, 1)
	elseif unitGUID then
		if not inspectGUIDCache[unitGUID] then
			inspectGUIDCache[unitGUID] = {unitColor = {r, g, b}}
		end

		if lastGUID ~= unitGUID then
			lastGUID = unitGUID
			NotifyInspect(unit)
			self:RegisterEvent("INSPECT_READY")
		else
			self:INSPECT_READY(nil, unitGUID)
		end
	end
end

function Module:GameTooltip_OnTooltipSetUnit(tt)
	if tt:IsForbidden() then
		return
	end

	local unit = select(2, tt:GetUnit())
	local isShiftKeyDown = IsShiftKeyDown()
	local isControlKeyDown = IsControlKeyDown()
	local isPlayerUnit = UnitIsPlayer(unit)

	if not unit then
		local GMF = GetMouseFocus()
		if GMF and GMF.GetAttribute and GMF:GetAttribute("unit") then
			unit = GMF:GetAttribute("unit")
		end
		if not unit or not UnitExists(unit) then
			return
		end
	end

	self:RemoveTrashLines(tt) -- keep an eye on this may be buggy

	local color = self:SetUnitText(tt, unit, UnitLevel(unit), isShiftKeyDown)

	if C["Tooltip"].ShowMount and not isShiftKeyDown and unit ~= "player" and isPlayerUnit then
		for i = 1, 40 do
			local name, _, _, _, _, _, _, _, _, id = UnitBuff(unit, i)
			if not name then break end

			if self.MountIDs[id] then
				local _, _, sourceText = C_MountJournal_GetMountInfoExtraByID(self.MountIDs[id])
				tt:AddDoubleLine(string_format("%s:", MOUNT), name, nil, nil, nil, 1, 1, 1)

				if sourceText and isControlKeyDown then
					local sourceModified = sourceText:gsub("|n", "\10")
					for x in string_gmatch(sourceModified, "[^\10]+\10?") do
						local left, right = string_match(x, "(.-|r)%s?([^\10]+)\10?")
						if left and right then
							tt:AddDoubleLine(left, right, nil, nil, nil, 1, 1, 1)
						else
							tt:AddDoubleLine(FROM, sourceText:gsub("|c%x%x%x%x%x%x%x%x",""), nil, nil, nil, 1, 1, 1)
						end
					end
				end

				break
			end
		end
	end

	if not isShiftKeyDown and not isControlKeyDown then
		local unitTarget = unit.."target"
		if C["Tooltip"].TargetInfo and unit ~= "player" and UnitExists(unitTarget) then
			local targetColor
			if (UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget)) then
				local _, class = UnitClass(unitTarget)
				targetColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			else
				targetColor = K.Colors.factioncolors[""..UnitReaction(unitTarget, "player")] or FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
			end

			tt:AddDoubleLine(string_format("%s:", TARGET), string_format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget)))
		end

		if C["Tooltip"].TargetInfo and IsInGroup() then
			for i = 1, GetNumGroupMembers() do
				local groupUnit = (IsInRaid() and "raid"..i or "party"..i)
				if (UnitIsUnit(groupUnit.."target", unit)) and (not UnitIsUnit(groupUnit, "player")) then
					local _, class = UnitClass(groupUnit)
					local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
					if not classColor then
						classColor = RAID_CLASS_COLORS.PRIEST
					end
					table_insert(targetList, string_format("|c%s%s|r", classColor.colorStr, UnitName(groupUnit)))
				end
			end

			local numList = #targetList
			if (numList > 0) then
				tt:AddLine(string_format("%s (|cffffffff%d|r): %s", TUTORIAL_TITLE19, numList, table.concat(targetList, ", ")), nil, nil, nil, true)
				table_wipe(targetList)
			end
		end
	end

	if isShiftKeyDown and isPlayerUnit then
		self:AddInspectInfo(tt, unit, 0, color.r, color.g, color.b)
	end

	-- NPC ID's
	if unit and C["Tooltip"].NpcID and not isPlayerUnit then
		if C_PetBattles_IsInBattle() then
			return
		end

		local guid = UnitGUID(unit) or ""
		local id = tonumber(guid:match("%-(%d-)%-%x-$"), 10)
		if id then
			tt:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		end
	end

	if color then
		GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		GameTooltipStatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

	local textWidth = GameTooltipStatusBar.text:GetStringWidth()
	if textWidth then
		tt:SetMinimumWidth(textWidth)
	end
end

function Module:GameTooltipStatusBar_OnValueChanged(tt, value)
	if tt:IsForbidden() then
		return
	end

	if not value or not C["Tooltip"].HealthBarText or not tt.text then
		return
	end

	local unit = select(2, tt:GetParent():GetUnit())
	if (not unit) then
		local GMF = GetMouseFocus()
		if (GMF and GMF.GetAttribute and GMF:GetAttribute("unit")) then
			unit = GMF:GetAttribute("unit")
		end
	end

	local _, max = tt:GetMinMaxValues()
	if (value > 0 and max == 1) then
		tt.text:SetFormattedText("%d%%", math_floor(value * 100))
		tt:SetStatusBarColor(TAPPED_COLOR.r, TAPPED_COLOR.g, TAPPED_COLOR.b) -- most effeciant?
	elseif (value == 0 or (unit and UnitIsDeadOrGhost(unit))) then
		tt.text:SetText(DEAD)
	else
		tt.text:SetText(K.ShortValue(value) .. " / " .. K.ShortValue(max))
	end
end

function Module:GameTooltip_OnTooltipBug()
	if GameTooltip:IsShown() then
		TOOLTOP_BUG = true
	end
end

function Module:BAG_UPDATE_DELAYED()
	if StuffingFrameBags and StuffingFrameBags:IsShown() then
		if GameTooltip:IsShown() then
			TOOLTOP_BUG = true
		end
	end
end

function Module:GameTooltip_OnTooltipCleared(tt)
	if tt:IsForbidden() then
		return
	end

	tt.itemCleared = false

	if TOOLTOP_BUG and tt:NumLines() == 0 then
		tt:Hide()
		TOOLTOP_BUG = false
	end
end

function Module:GameTooltip_OnTooltipSetItem(tt)
	if tt:IsForbidden() then
		return
	end

	if not tt.itemCleared then
		local _, link = tt:GetItem()
		local num = GetItemCount(link)
		local numall = GetItemCount(link, true)
		local left = " "
		local right = " "
		local bankCount = " "

		if link ~= nil and C["Tooltip"].SpellID and IsShiftKeyDown() then
			left = (("|cFFCA3C3C%s|r %s"):format(ID, link)):match(":(%w+)")
		end

		right = ("|cFFCA3C3C%s|r %d"):format(L["Tooltip"].Count, num)
		bankCount = ("|cFFCA3C3C%s|r %d"):format(L["Tooltip"].Bank, (numall - num))

		if left ~= " " or right ~= " " and IsShiftKeyDown() then
			tt:AddLine(" ")
			tt:AddDoubleLine(left, right)
		end

		if bankCount ~= " " and IsShiftKeyDown() then
			tt:AddDoubleLine(" ", bankCount)
		end

		tt.itemCleared = true
	end

	if C["Tooltip"].ItemQualityBorder then
		local _, link = tt:GetItem()

		if link ~= nil then
			tt.currentItem = link

			local name, _, quality, _, _, type, subType = GetItemInfo(link)

			if not quality then
				quality = 0
			end

			local r, g, b
			if type == L["Tooltip"].Quest then
				r, g, b = 1, 1, 0
			elseif type == L["Tooltip"].Tradeskill and not ignoreSubType[subType] and quality < 2 then
				r, g, b = 0.4, 0.73, 1
			elseif subType == L["Tooltip"].Companion_Pets then
				local _, id = C_PetJournal_FindPetIDByName(name)
				if id then
					local _, _, _, _, petQuality = C_PetJournal_GetPetStats(id)
					if petQuality then
						quality = petQuality - 1
					end
				end
			end

			if quality > 1 and not r then
				r, g, b = GetItemQualityColor(quality)
				tt:SetBackdropBorderColor(r, g, b)
			end

			if r then
				tt:SetBackdropBorderColor(r, g, b)
			end
		else
			if tt == ItemRefTooltip then
				tt:SetBackdropBorderColor(0.7, 0.7, 0.7)
			end
		end
	end
end

function Module:GameTooltip_AddQuestRewardsToTooltip(tt, questID)
	if not (tt and questID and tt.pbBar and tt.pbBar.GetValue) or tt:IsForbidden() then
		return
	end

	local cur = tt.pbBar:GetValue()
	if cur then
		local max, _
		if tt.pbBar.GetMinMaxValues then
			_, max = tt.pbBar:GetMinMaxValues()
		end

		if not ModuleSkins then
			ModuleSkins = K:GetModule("Skins")
		end

		ModuleSkins:StatusBarColorGradient(tt.pbBar, cur, max)
	end
end

function Module:GameTooltip_ShowProgressBar(tt)
	if not tt or tt:IsForbidden() or not tt.progressBarPool then
		return
	end

	local sb = tt.progressBarPool:GetNextActive()
	if (not sb or not sb.Bar) then
		return
	end

	sb.Bar:SetStatusBarTexture(K.GetTexture(C["Tooltip"].Texture) or C["Media"].Texture)

	tt.pbBar = sb.Bar
end

function Module:GameTooltip_ShowStatusBar(tt)
	if not tt or tt:IsForbidden() or not tt.statusBarPool then
		return
	end

	local sb = tt.statusBarPool:GetNextActive()
	if (not sb or not sb.Text) then
		return
	end

	sb:SetStatusBarTexture(K.GetTexture(C["Tooltip"].Texture) or C["Media"].Texture)
end

function Module:CheckBackdropColor(tt)
	if (not tt) or tt:IsForbidden() then
		return
	end

	local r, g, b = tt:GetBackdropColor()
	if r and g and b then
		r, g, b = K.Round(r, 1), K.Round(g, 1), K.Round(b, 1)

		local red, green, blue = C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3]
		if r ~= red or g ~= green or b ~= blue then
			tt:SetBackdropColor(red, green, blue, C["Media"].BackdropColor[4])
		end
	end
end

function Module:SetStyle(tt)
	if not tt or tt:IsForbidden() then
		return
	end

	tt:SetBackdrop({
		bgFile = C["Media"].Blank,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false,
		tileEdge = false,
		tileSize = 12,
		edgeSize = 12,
		insets = {left = 3, right = 3, top = 3, bottom = 3}
	})

	if C["General"].ColorTextures then
		tt:SetBackdropBorderColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
	else
		tt:SetBackdropBorderColor(0.7, 0.7, 0.7)
	end
	tt:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	local r, g, b = tt:GetBackdropColor()
	tt:SetBackdropColor(r, g, b, C["Media"].BackdropColor[4])
end

function Module:MODIFIER_STATE_CHANGED(_, key)
	if((key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL") and UnitExists("mouseover")) then
		GameTooltip:SetUnit("mouseover")
	end
end

function Module:SetUnitAura(tt, unit, index, filter)
	if tt:IsForbidden() then
		return
	end

	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)

	if id then
		if self.MountIDs[id] then
			local _, _, sourceText = C_MountJournal_GetMountInfoExtraByID(self.MountIDs[id])
			tt:AddLine(" ")
			tt:AddLine(sourceText, 1, 1, 1)
			tt:AddLine(" ")
		end

		if C["Tooltip"].SpellID then
			if caster then
				local name = UnitName(caster)
				local _, class = UnitClass(caster)
				local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				if not color then color = RAID_CLASS_COLORS.PRIEST end
				tt:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), string_format("|c%s%s|r", color.colorStr, name))
			else
				tt:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
			end
		end

		tt:Show()
	end
end

function Module:GameTooltip_OnTooltipSetSpell(tt)
	if tt:IsForbidden() then
		return
	end

	local id = select(2, tt:GetSpell())
	if not id or not C["Tooltip"].SpellID then
		return
	end

	local displayString = ("|cFFCA3C3C%s|r %d"):format(ID, id)
	local lines = tt:NumLines()
	local isFound
	for i = 1, lines do
		local line = _G[("GameTooltipTextLeft%d"):format(i)]
		if line and line:GetText() and line:GetText():find(displayString) then
			isFound = true
			break
		end
	end

	if not isFound then
		tt:AddLine(displayString)
		tt:Show()
	end
end

function Module:SetItemRef(link)
	if string_find(link, "^spell:") and C["Tooltip"].SpellID then
		local id = string_sub(link, 7)
		ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		ItemRefTooltip:Show()
	end
end

function Module:RepositionBNET(frame, _, anchor)
	if anchor ~= BNETMover then
		frame:ClearAllPoints()
		frame:SetPoint(BNETMover.anchorPoint or "TOPLEFT", BNETMover, BNETMover.anchorPoint or "TOPLEFT")
	end
end

function Module:SetTooltipFonts()
	local font = C["Media"].Font
	local fontOutline = ""
	local headerSize = 12
	local textSize = 12
	local smallTextSize = 12

	GameTooltipHeaderText:SetFont(font, headerSize, fontOutline)
	GameTooltipText:SetFont(font, textSize, fontOutline)
	GameTooltipTextSmall:SetFont(font, smallTextSize, fontOutline)
	if GameTooltip.hasMoney then
		for i = 1, GameTooltip.numMoneyFrames do
			_G["GameTooltipMoneyFrame" .. i .. "PrefixText"]:SetFont(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame" .. i .. "SuffixText"]:SetFont(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame" .. i .. "GoldButtonText"]:SetFont(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame" .. i .. "SilverButtonText"]:SetFont(font, textSize, fontOutline)
			_G["GameTooltipMoneyFrame" .. i .. "CopperButtonText"]:SetFont(font, textSize, fontOutline)
		end
	end

	-- These show when you compare items ("Currently Equipped", name of item, item level)
	-- Since they appear at the top of the tooltip, we set it to use the header font size.
	ShoppingTooltip1TextLeft1:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip1TextLeft2:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip1TextLeft3:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip1TextLeft4:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip1TextRight1:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip1TextRight2:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip1TextRight3:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip1TextRight4:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip2TextLeft1:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip2TextLeft2:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip2TextLeft3:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip2TextLeft4:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip2TextRight1:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip2TextRight2:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip2TextRight3:SetFont(font, headerSize, fontOutline)
	ShoppingTooltip2TextRight4:SetFont(font, headerSize, fontOutline)
end

function Module:OnEnable()
	if C["Tooltip"].Enable ~= true then
		return
	end

	local TooltipFont = K.GetFont(C["Tooltip"].Font)

	self.MountIDs = {}
	local mountIDs = C_MountJournal_GetMountIDs()
	for _, mountID in ipairs(mountIDs) do
		self.MountIDs[select(2, C_MountJournal_GetMountInfoByID(mountID))] = mountID
	end

	local BNETMover = CreateFrame("Frame", "BNETMover", UIParent)
	BNETMover:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 6, 204)
	BNETMover:SetSize(250, 64)

	BNToastFrame:SetPoint("TOPRIGHT", BNETMover, "BOTTOMRIGHT", 0, -10)
	K.Movers:RegisterFrame(BNETMover)
	self:SecureHook(BNToastFrame, "SetPoint", "RepositionBNET")

	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	BNToastFrame.CloseButton:SetSize(32, 32)
	BNToastFrame.CloseButton:SetPoint("TOPRIGHT", 4, 4)
	BNToastFrame.CloseButton:SkinCloseButton()

	if GameTooltipStatusBar then
		GameTooltipStatusBar:SetHeight(C["Tooltip"].HealthbarHeight)
		GameTooltipStatusBar:SetScript("OnValueChanged", nil) -- Do we need to unset this?

		GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
		GameTooltipStatusBar.text:SetPoint("CENTER", GameTooltipStatusBar, 0, 6)
		GameTooltipStatusBar.text:SetFontObject(TooltipFont)
	end

	if not GameTooltip.hasMoney then
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		SetTooltipMoney(GameTooltip, 1, nil, "", "")
		GameTooltip_ClearMoney(GameTooltip)
	end
	self:SetTooltipFonts()

	local GameTooltipAnchor = CreateFrame("Frame", "GameTooltipAnchor", UIParent)
	GameTooltipAnchor:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4)
	GameTooltipAnchor:SetSize(130, 20)
	GameTooltipAnchor:SetFrameLevel(GameTooltipAnchor:GetFrameLevel() + 400)

	K.Movers:RegisterFrame(GameTooltipAnchor)

	self:SecureHook("SetItemRef")
	self:SecureHook("GameTooltip_SetDefaultAnchor")
	self:SecureHook(GameTooltip, "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitBuff", "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitDebuff", "SetUnitAura")
	self:SecureHookScript(GameTooltip, "OnTooltipSetSpell", "GameTooltip_OnTooltipSetSpell")
	self:SecureHookScript(GameTooltip, "OnTooltipCleared", "GameTooltip_OnTooltipCleared")
	self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "GameTooltip_OnTooltipSetUnit")
	self:SecureHookScript(GameTooltipStatusBar, "OnValueChanged", "GameTooltipStatusBar_OnValueChanged")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")

	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "GameTooltip_OnTooltipBug")
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", "GameTooltip_OnTooltipBug")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
end