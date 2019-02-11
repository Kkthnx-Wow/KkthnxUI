local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Tooltip", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")
local LibInspect = LibStub("LibInspect")
local LibItemLevel = LibStub("LibItemLevel-KkthnxUI")

local _G = _G
local find = string.find
local format = string.format
local math_floor = math.floor
local next = next
local select = select
local sub = string.sub
local table_wipe = table.wipe
local tonumber = tonumber

local C_PetBattles_IsInBattle = _G.C_PetBattles.IsInBattle
local C_PetJournal_FindPetIDByName = _G.C_PetJournal.FindPetIDByName
local C_PetJournal_GetPetStats = _G.C_PetJournal.GetPetStats
local C_PetJournalGetPetTeamAverageLevel = _G.C_PetJournal.GetPetTeamAverageLevel
local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local DEAD = _G.DEAD
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local FACTION_HORDE = _G.FACTION_HORDE
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL
local GameTooltip_ClearMoney = _G.GameTooltip_ClearMoney
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local GetGuildInfo = _G.GetGuildInfo
local GetItemCount = _G.GetItemCount
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMouseFocus = _G.GetMouseFocus
local GetRelativeDifficultyColor = _G.GetRelativeDifficultyColor
local GetTime = _G.GetTime
local ID = _G.ID
local INTERACTIVE_SERVER_LABEL = _G.INTERACTIVE_SERVER_LABEL
local IsInGroup = _G.IsInGroup
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_REALM_RELATION_COALESCED = _G.LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL
local PVP = _G.PVP
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local SetTooltipMoney = _G.SetTooltipMoney
local SPECIALIZATION = _G.SPECIALIZATION
local STAT_AVERAGE_ITEM_LEVEL = _G.STAT_AVERAGE_ITEM_LEVEL
local TARGET = _G.TARGET
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitBattlePetType = _G.UnitBattlePetType
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitCreatureType = _G.UnitCreatureType
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitGUID = _G.UnitGUID
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsAFK = _G.UnitIsAFK
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsDND = _G.UnitIsDND
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsPVP = _G.UnitIsPVP
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPVPName = _G.UnitPVPName
local UnitRace = _G.UnitRace
local UnitReaction = _G.UnitReaction
local UnitRealmRelationship = _G.UnitRealmRelationship

local GameTooltip, GameTooltipStatusBar = _G["GameTooltip"], _G["GameTooltipStatusBar"]
local inspectCache, inspectAge = {}, 900
local TAPPED_COLOR = {r = .6, g = .6, b = .6}
local AFK_LABEL = " |cffFFFFFF[|r|cffFF0000" .. "AFK" .. "|r|cffFFFFFF]|r"
local DND_LABEL = " |cffFFFFFF[|r|cffFFFF00" .. "DND" .. "|r|cffFFFFFF]|r"
local TOOLTOP_BUG = nil

local LOCALE = {
	PVP = PVP,
	FACTION_HORDE = FACTION_HORDE,
	FOREIGN_SERVER_LABEL = FOREIGN_SERVER_LABEL,
	ID = ID,
	INTERACTIVE_SERVER_LABEL = INTERACTIVE_SERVER_LABEL,
	TARGET = TARGET,
	DEAD = DEAD,
	FACTION_ALLIANCE = FACTION_ALLIANCE,
	NONE = _G.NONE,
	ROLE = _G.ROLE,

	-- Custom to find LEVEL string on tooltip
	LEVEL1 = _G.TOOLTIP_UNIT_LEVEL:gsub("%s?%%s%s?%-?", ""),
	LEVEL2 = _G.TOOLTIP_UNIT_LEVEL_CLASS:gsub("^%%2$s%s?(.-)%s?%%1$s", "%1"):gsub("^%-?г?о?%s?", ""):gsub("%s?%%s%s?%-?", "")
}

local ignoreSubType = {
	L["Tooltip"].Other == true,
	L["Tooltip"].Item_Enhancement == true
}

local classification = {
	worldboss = format("|cffAF5050 %s|r", _G.BOSS),
	rareelite = format("|cffAF5050+ %s|r", _G.ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", _G.ITEM_QUALITY3_DESC)
}

local SlotName = {
	INVSLOT_HEAD, INVSLOT_NECK, INVSLOT_SHOULDER, INVSLOT_BACK, INVSLOT_CHEST,
	INVSLOT_WRIST, INVSLOT_HAND, INVSLOT_WAIST, INVSLOT_LEGS, INVSLOT_FEET,
	INVSLOT_FINGER1, INVSLOT_FINGER2, INVSLOT_TRINKET1, INVSLOT_TRINKET2,
	INVSLOT_MAINHAND, INVSLOT_OFFHAND
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

function Module:CleanUpTrashLines(tt)
	if tt:IsForbidden() then
		return
	end

	for i = 3, tt:NumLines() do
		local tiptext = _G["GameTooltipTextLeft" .. i]
		local linetext = tiptext:GetText()

		if (linetext == LOCALE.PVP or linetext == LOCALE.FACTION_ALLIANCE or linetext == LOCALE.FACTION_HORDE) then
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
		if tipText and (tipText:find(LOCALE.LEVEL1) or tipText:find(LOCALE.LEVEL2)) then
			return tipLine
		end
	end
end

function Module:GetItemLvL(items, talents)
	if not items or not talents then
		return "?"
	end

	local total = 0
	local artifactEquipped = false
	for i = 1, #SlotName do
		local currentSlot = SlotName[i]
		local itemLink = items[currentSlot]
		if (itemLink) then
			local _, _, rarity, itemLevelOriginal, _, _, _, _, equipSlot = GetItemInfo(itemLink)

			-- Check if we have an artifact equipped in main hand
			if (currentSlot == INVSLOT_MAINHAND and rarity and rarity == 6) then
				artifactEquipped = true
			end

			-- If we have artifact equipped in main hand, then we should not count the offhand as it displays an incorrect item level
			if (not artifactEquipped or (artifactEquipped and currentSlot ~= INVSLOT_OFFHAND)) then
				local _, itemLevelLib = LibItemLevel:GetItemInfo(itemLink)
				local itemLevelFinal = 0

				if (itemLevelOriginal and itemLevelLib) then
					if itemLevelFinal == 0 then
						itemLevelFinal = itemLevelOriginal
					end

					itemLevelFinal = (itemLevelOriginal ~= itemLevelLib) and itemLevelLib or itemLevelOriginal
				else
					itemLevelFinal = itemLevelLib or itemLevelOriginal
				end

				if (itemLevelFinal > 0) then
					if ((currentSlot == INVSLOT_MAINHAND and artifactEquipped)
					or ((equipSlot == "INVTYPE_2HWEAPON"
					or equipSlot == "INVTYPE_RANGEDRIGHT"
					or equipSlot == "INVTYPE_RANGED") and talents.id ~= 72)) and (not items[INVSLOT_OFFHAND]
					or artifactEquipped) then
						itemLevelFinal = itemLevelFinal * 2
					end

					total = total + itemLevelFinal
				end
			end
		end
	end

	if (total > 0) then
		return math_floor(total / #SlotName)
	else
		return "?"
	end
end

function Module:GetTalentSpec(talents)
	return (talents and talents.icon and talents.name) and ("|T"..talents.icon..":12:12:0:0:64:64:5:59:5:59|t "..talents.name) or "?"
end

function Module:InspectReady(guid, data)
	if (not (guid and data and data.items and data.talents)) then
		return
	end

	if (not inspectCache[guid]) then
		inspectCache[guid] = {}
	end

	inspectCache[guid].age = GetTime()
	inspectCache[guid].itemLevel = self:GetItemLvL(data.items, data.talents)
	inspectCache[guid].talent = self:GetTalentSpec(data.talents)

	if not GameTooltip:IsForbidden() then
		GameTooltip:SetUnit("mouseover")
	end
end

function Module:ShowInspectInfo(tt, unit, r, g, b)
	if tt:IsForbidden() then
		return
	end

	local unitGUID = UnitGUID(unit)

	if (inspectCache[unitGUID] and inspectCache[unitGUID].age and (GetTime() - inspectCache[unitGUID].age) < inspectAge) then
		tt:AddDoubleLine(SPECIALIZATION, inspectCache[unitGUID].talent, nil, nil, nil, r, g, b)
		tt:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL, inspectCache[unitGUID].itemLevel, nil, nil, nil, 1, 1, 1)
	elseif (not InspectFrame or (InspectFrame and not InspectFrame:IsShown())) then
		LibInspect:RequestItems(unit, true)
	end
end

function Module:GameTooltip_OnTooltipSetUnit(tt)
	if tt:IsForbidden() then
		return
	end

	local unit = select(2, tt:GetUnit())

	if (not unit) then
		local GMF = GetMouseFocus()
		if (GMF and GMF.GetAttribute and GMF:GetAttribute("unit")) then
			unit = GMF:GetAttribute("unit")
		end

		if (not unit or not UnitExists(unit)) then
			return
		end
	end

	self:CleanUpTrashLines(tt) -- keep an eye on this may be buggy
	local level = UnitLevel(unit)
	local isShiftKeyDown = IsShiftKeyDown()

	local color
	if (UnitIsPlayer(unit)) then
		local localeClass, class = UnitClass(unit)
		local name, realm = UnitName(unit)
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)
		if not localeClass or not class then
			return
		end
		color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]

		if (C["Tooltip"].PlayerTitles and pvpName) then
			name = pvpName
		end

		if (realm and realm ~= "") then
			if (isShiftKeyDown) then
				name = name .. "-" .. realm
			elseif (relationship == LE_REALM_RELATION_COALESCED) then
				name = name .. LOCALE.FOREIGN_SERVER_LABEL
			elseif (relationship == LE_REALM_RELATION_VIRTUAL) then
				name = name .. LOCALE.INTERACTIVE_SERVER_LABEL
			end
		end

		if (UnitIsAFK(unit)) then
			name = name .. AFK_LABEL
		elseif (UnitIsDND(unit)) then
			name = name .. DND_LABEL
		end

		_G["GameTooltipTextLeft1"]:SetFormattedText("|c%s%s|r", color.colorStr, name)

		local lineOffset = 2
		if (guildName) then
			if (guildRealm and isShiftKeyDown) then
				guildName = guildName .. "-" .. guildRealm
			end

			if (C["Tooltip"].GuildRanks) and IsShiftKeyDown() then
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r> [|cff00ff10%s|r]"):format(guildName, guildRankName))
			else
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r>"):format(guildName))
			end
			lineOffset = 3
		end

		local levelLine = self:GetLevelLine(tt, lineOffset)
		if (levelLine) then
			local diffColor = GetCreatureDifficultyColor(level)
			local race, englishRace = UnitRace(unit)
			local _, factionGroup = UnitFactionGroup(unit)

			if (factionGroup and englishRace == "Pandaren") then
				race = factionGroup .. " " .. race
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s |c%s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or "", color.colorStr, localeClass)
		end

		if C["Tooltip"].Role then
			local r, g, b, role = 1, 1, 1, UnitGroupRolesAssigned(unit)
			if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= "NONE") then
				if role == "HEALER" then
					role, r, g, b = "Healer", 0, 1, .59
				elseif role == "TANK" then
					role, r, g, b = "Tank", .16, .31, .61
				elseif role == "DAMAGER" then
					role, r, g, b = "DPS", .77, .12, .24
				end

				GameTooltip:AddDoubleLine(LOCALE.ROLE, role, nil, nil, nil, r, g, b)
			end
		end

		-- High CPU usage, restricting it to shift key down only.
		if (C["Tooltip"].InspectInfo and isShiftKeyDown) then
			self:ShowInspectInfo(tt, unit, color.r, color.g, color.b)
		end
	else
		if UnitIsTapDenied(unit) then
			color = TAPPED_COLOR
		else
			local unitReaction = UnitReaction(unit, "player")
			if unitReaction then
				unitReaction = format("%s", unitReaction) -- Cast to string because our table is indexed by string keys
				color = K.Colors.factioncolors[unitReaction]
			end
		end

		local levelLine = self:GetLevelLine(tt, 2)
		if (levelLine) then
			local isPetWild, isPetCompanion = UnitIsWildBattlePet(unit), UnitIsBattlePetCompanion(unit)
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local diffColor
			if (isPetWild or isPetCompanion) then
				level = UnitBattlePetLevel(unit)

				local petType = _G["BATTLE_PET_NAME_" .. UnitBattlePetType(unit)]
				if creatureType then
					creatureType = format("%s %s", creatureType, petType)
				else
					creatureType = petType
				end

				local teamLevel = C_PetJournalGetPetTeamAverageLevel()
				if (teamLevel) then
					diffColor = GetRelativeDifficultyColor(teamLevel, level)
				else
					diffColor = GetCreatureDifficultyColor(level)
				end
			else
				diffColor = GetCreatureDifficultyColor(level)
			end

			if (UnitIsPVP(unit)) then
				pvpFlag = format(" (%s)", LOCALE.PVP)
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)
		end
	end

	local unitTarget = unit .. "target"
	if (unit ~= "player" and UnitExists(unitTarget)) then
		local targetColor
		if (UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget)) then
			local _, class = UnitClass(unitTarget)
			targetColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
		else
			targetColor =
			K.Colors.factioncolors["" .. UnitReaction(unitTarget, "player")] or
			FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
		end

		GameTooltip:AddDoubleLine(format("%s:", LOCALE.TARGET), format("|cff%02x%02x%02x%s|r", targetColor.r * 255, targetColor.g * 255, targetColor.b * 255, UnitName(unitTarget, true)))
	end

	-- NPC ID's
	if unit and C["Tooltip"].SpellID then
		if C_PetBattles_IsInBattle() then
			return
		end

		local guid = UnitGUID(unit) or ""
		local id = tonumber(guid:match("%-(%d-)%-%x-$"), 10)
		if id and guid:match("%a+") ~= "Player" then
			GameTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(LOCALE.ID, id))
		end
	end

	if (color) then
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
		tt.text:SetText(LOCALE.DEAD)
	else
		tt.text:SetText(K.ShortValue(value) .. " / " .. K.ShortValue(max))
	end
end

function Module:FixTooltipBug()
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

	tt.itemCleared = nil

	if TOOLTOP_BUG and tt:NumLines() == 0 then
		tt:Hide()
		TOOLTOP_BUG = nil
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
			left = (("|cFFCA3C3C%s|r %s"):format(LOCALE.ID, link)):match(":(%w+)")
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

			local name, _, quality, _, _, type, subType, _, _, _, _ = GetItemInfo(link)

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
	if not tt or tt:IsForbidden() then
		return
	end

	if not tt.progressBarPool then
		return
	end

	local sb = tt.progressBarPool:Acquire()
	if not sb or not sb.Bar then
		return
	end

	sb.Bar:SetStatusBarTexture(K.GetTexture(C["Tooltip"].Texture))

	tt.pbBar = sb.Bar
end

function Module:GameTooltip_ShowStatusBar(tt)
	if not tt or tt:IsForbidden() then
		return
	end

	local statusBar = _G[tt:GetName() .. "StatusBar"]
	if statusBar and not statusBar.skinned then
		statusBar:SetStatusBarTexture(K.GetTexture(C["Tooltip"].Texture))
		statusBar.skinned = true
	end
end

function Module:CheckBackdropColor(tt)
	if not tt or tt:IsForbidden() then
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
		tile = false, tileSize = 0, edgeSize = 12,
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

function Module:PLAYER_ENTERING_WORLD()
	if next(inspectCache) then
		table_wipe(inspectCache)
	end
end

function Module:MODIFIER_STATE_CHANGED(_, key)
	if ((key == "LSHIFT" or key == "RSHIFT") and UnitExists("mouseover")) then
		GameTooltip:SetUnit("mouseover")
	end
end

function Module:SetUnitAura(tt, unit, index, filter)
	if tt:IsForbidden() then
		return
	end

	local _, _, _, _, _, _, caster, _, _, id = UnitAura(unit, index, filter)
	if id and C["Tooltip"].SpellID then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			if not color then
				color = RAID_CLASS_COLORS["PRIEST"]
			end
			tt:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(LOCALE.ID, id), format("|c%s%s|r", color.colorStr, name))
		else
			tt:AddLine(("|cFFCA3C3C%s|r %d"):format(LOCALE.ID, id))
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

	local displayString = ("|cFFCA3C3C%s|r %d"):format(LOCALE.ID, id)
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
	if find(link, "^spell:") and C["Tooltip"].SpellID then
		local id = sub(link, 7)
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

	K.ScanTooltip = CreateFrame("GameTooltip", "KkthnxUI_ScanTooltip", UIParent, "GameTooltipTemplate")
	K.ScanTooltip:SetPoint("CENTER")
	K.ScanTooltip:SetSize(200, 200)
	GameTooltip_SetDefaultAnchor(K.ScanTooltip, UIParent)

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

	self:SecureHook("GameTooltip_SetDefaultAnchor")
	self:SecureHook("SetItemRef")
	self:SecureHook(GameTooltip, "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitBuff", "SetUnitAura")
	self:SecureHook(GameTooltip, "SetUnitDebuff", "SetUnitAura")
	self:SecureHookScript(GameTooltip, "OnTooltipSetSpell", "GameTooltip_OnTooltipSetSpell")
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "FixTooltipBug")
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", "FixTooltipBug")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:SecureHookScript(GameTooltip, "OnTooltipCleared", "GameTooltip_OnTooltipCleared")
	self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "GameTooltip_OnTooltipSetUnit")
	self:SecureHookScript(GameTooltipStatusBar, "OnValueChanged", "GameTooltipStatusBar_OnValueChanged")
	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	LibInspect:AddHook("KkthnxUI", "items", function(guid, data, _)
		self:InspectReady(guid, data)
	end)
	LibInspect:SetMaxAge(inspectAge)
end