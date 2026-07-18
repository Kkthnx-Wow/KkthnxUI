--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Core module for Tooltip enhancements and skinning.
-- - Design: Hooks into TooltipDataProcessor and Blizzard's tooltip system to provide custom layouts, colors, and extra information (ID, realm, etc.).
-- - Events: ADDON_LOADED, MODIFIER_STATE_CHANGED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Tooltip")

local function IsTooltipModuleEnabled()
	return C["Tooltip"].Enable ~= false
end

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local ipairs = _G.ipairs
local pairs = _G.pairs
local pcall = _G.pcall
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_len = _G.string.len
local string_upper = _G.string.upper
local type = _G.type

local AFK = _G.AFK
local BOSS = _G.BOSS
local error = _G.error
local C_ChallengeMode_GetDungeonScoreRarityColor = _G.C_ChallengeMode and _G.C_ChallengeMode.GetDungeonScoreRarityColor
local C_Item_GetItemInfo = _G.C_Item and _G.C_Item.GetItemInfo
local C_Item_GetItemLinkByGUID = _G.C_Item and _G.C_Item.GetItemLinkByGUID
local C_PetBattles_GetAuraInfo = _G.C_PetBattles.GetAuraInfo
local C_PetBattles_GetNumAuras = _G.C_PetBattles.GetNumAuras
local C_PlayerInfo_GetPlayerMythicPlusRatingSummary = _G.C_PlayerInfo and _G.C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local CreateFrame = _G.CreateFrame
local DAMAGE = _G.DAMAGE
local DEAD = _G.DEAD
local DND = _G.DND
local DUNGEON_SCORE_LEADER = _G.DUNGEON_SCORE_LEADER
local Enum = _G.Enum
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE
local FACTION_HORDE = _G.FACTION_HORDE
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL
local GameTooltip = _G.GameTooltip
local GameTooltipStatusBar = _G.GameTooltipStatusBar
local GameTooltipTextLeft1 = _G.GameTooltipTextLeft1
local GameTooltipTextLeft2 = _G.GameTooltipTextLeft2
local GameTooltip_ClearMoney = _G.GameTooltip_ClearMoney
local GameTooltip_ClearProgressBars = _G.GameTooltip_ClearProgressBars
local GameTooltip_ClearStatusBars = _G.GameTooltip_ClearStatusBars
local GameTooltip_ClearWidgetSet = _G.GameTooltip_ClearWidgetSet
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local GetGuildInfo = _G.GetGuildInfo
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local HEALER = _G.HEALER
local HIGHLIGHT_FONT_COLOR = _G.HIGHLIGHT_FONT_COLOR
local ICON_LIST = _G.ICON_LIST
local INTERACTIVE_SERVER_LABEL = _G.INTERACTIVE_SERVER_LABEL
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local IsInRaid = _G.IsInRaid
local IsShiftKeyDown = _G.IsShiftKeyDown
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumSubgroupMembers = _G.GetNumSubgroupMembers
local ITEM_QUALITY3_DESC = _G.ITEM_QUALITY3_DESC
local LE_REALM_RELATION_COALESCED = _G.LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL
local LEVEL = _G.LEVEL
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local PVP = _G.PVP
local ROLE = _G.ROLE
local SPECIALIZATION = _G.SPECIALIZATION
local TANK = _G.TANK
local TARGET = _G.TARGET
local TooltipComparisonManager = _G.TooltipComparisonManager
local TooltipDataProcessor = _G.TooltipDataProcessor
local UIParent = _G.UIParent
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitCreatureType = _G.UnitCreatureType
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGUID = _G.UnitGUID
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsAFK = _G.UnitIsAFK
local UnitIsBattlePetCompanion = _G.UnitIsBattlePetCompanion
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDND = _G.UnitIsDND
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitIsWildBattlePet = _G.UnitIsWildBattlePet
local UnitLevel = _G.UnitLevel
local UnitName = _G.UnitName
local UnitPVPName = _G.UnitPVPName
local UnitRace = _G.UnitRace
local UnitReaction = _G.UnitReaction
local UnitRealmRelationship = _G.UnitRealmRelationship
local UnitTokenFromGUID = _G.UnitTokenFromGUID
local YOU = _G.YOU
local hooksecurefunc = _G.hooksecurefunc

local IsSecret = K.IsSecret

local classification = {
	worldboss = string_format("|cffAF5050 %s|r", BOSS),
	rareelite = string_format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = string_format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC),
}
local npcIDstring = "%s " .. K.InfoColor .. "%s"
local specPrefix = "|cffFFCC00" .. SPECIALIZATION .. ": " .. K.InfoColor

-- REASON: Resolve the unit token shown on a tooltip (Midnight-safe).
-- SECRET (12.0): data.guid is secret on restricted units; never pass it to
-- UnitTokenFromGUID when secret. Falls back to raid/party walk, live candidates,
-- mouseover, and owner unit (CleanToken / MatchLiveToken).
local function CleanTokenForGUID(guid)
	if not guid or IsSecret(guid) then
		return
	end
	local playerGUID = UnitGUID("player")
	if playerGUID and K.NotSecret(playerGUID) and playerGUID == guid then
		return "player"
	end
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			local tk = "raid" .. i
			local tg = UnitGUID(tk)
			if tg and K.NotSecret(tg) and tg == guid then
				return tk
			end
		end
	elseif IsInGroup() then
		for i = 1, GetNumSubgroupMembers() do
			local tk = "party" .. i
			local tg = UnitGUID(tk)
			if tg and K.NotSecret(tg) and tg == guid then
				return tk
			end
		end
	end
end

local function MatchLiveTokenForGUID(guid)
	if not guid then
		return
	end
	local candidates = { "mouseover", "target", "focus", "targettarget" }
	for i = 1, #candidates do
		local cand = candidates[i]
		local exists = UnitExists(cand)
		if K.NotSecret(exists) and exists then
			local cg = UnitGUID(cand)
			if cg and K.NotSecret(cg) and cg == guid then
				return cand
			end
		end
	end
end

function Module:GetDisplayedUnit(tt)
	tt = tt or self
	if tt.GetPrimaryTooltipData then
		if tt.IsTooltipType and not tt:IsTooltipType(Enum.TooltipDataType.Unit) then
			return
		end
		local data = tt:GetPrimaryTooltipData()
		local guid = data and data.guid
		if guid and IsSecret(guid) then
			guid = nil
		end
		if guid then
			local token = CleanTokenForGUID(guid)
			if token then
				return token
			end
			if UnitTokenFromGUID then
				local tu = UnitTokenFromGUID(guid)
				if tu and K.NotSecret(tu) then
					local exists = UnitExists(tu)
					if K.NotSecret(exists) and exists then
						return tu
					end
				end
			end
			return MatchLiveTokenForGUID(guid)
		end
		return
	end

	local _, unit = tt:GetUnit()
	return unit
end

function Module:GetUnitToken(tt)
	tt = tt or self
	if not tt or tt:IsForbidden() then
		return
	end

	local mouseoverExists = UnitExists("mouseover")
	local mouseover = (K.NotSecret(mouseoverExists) and mouseoverExists) and "mouseover" or nil

	local unit = Module.GetDisplayedUnit(tt)

	-- Health-bar watch GUID is authoritative during UpdateUnitHealth ticks
	-- Resolve tip identity. Prefer it when tip GUID/token is missing
	-- or stale — that was why NPC tips fell to grey/green in instances.
	local bar = (tt.StatusBar or GameTooltipStatusBar)
	if bar and bar.GetAttribute then
		local bg = bar:GetAttribute("guid")
		if bg and K.NotSecret(bg) then
			local ug = unit and UnitGUID(unit)
			if not unit or not ug or IsSecret(ug) or ug ~= bg then
				local token = CleanTokenForGUID(bg) or MatchLiveTokenForGUID(bg)
				if not token and UnitTokenFromGUID then
					local tu = UnitTokenFromGUID(bg)
					if tu and K.NotSecret(tu) then
						local exists = UnitExists(tu)
						if K.NotSecret(exists) and exists then
							token = tu
						end
					end
				end
				if token then
					unit = token
				end
			end
		end
	end

	if unit then
		if K.IsSecretUnit(unit) then
			return mouseover
		end
		local exists = UnitExists(unit)
		return (K.NotSecret(exists) and exists and unit) or mouseover
	end

	local owner = tt.GetOwner and tt:GetOwner()
	local ownerUnit = owner and owner.GetAttribute and owner:GetAttribute("unit")
	if ownerUnit and K.NotSecret(ownerUnit) then
		if K.IsSecretUnit(ownerUnit) then
			return mouseover
		end
		local exists = UnitExists(ownerUnit)
		return (K.NotSecret(exists) and exists and ownerUnit) or mouseover
	end

	return mouseover
end

-- Backward-compatible: returns unit token and guid (guid may be nil when secret).
function Module:GetUnit()
	local unit = Module.GetUnitToken(self)
	local data = self:GetTooltipData()
	local guid = data and data.guid
	if IsSecret(guid) then
		guid = nil
	end
	return unit, guid
end

local FACTION_COLORS = {
	[FACTION_ALLIANCE] = "|cff4080ff%s|r",
	[FACTION_HORDE] = "|cffff5040%s|r",
}

-- REASON: Helper to format specialization info.
local function replaceSpecInfo(str)
	return string_find(str, "%s") and specPrefix .. str or str
end

-- REASON: Restyles the faction line in the tooltip (e.g., Horde/Alliance coloring).
function Module:UpdateFactionLine(lineData)
	if not IsTooltipModuleEnabled() then
		return
	end
	if self:IsForbidden() then
		return
	end

	if not self:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local linetext = lineData.leftText
	-- SECRET (12.0): the line text can be a secret string on restricted units;
	-- comparing it below would error, so bail early .
	if IsSecret(linetext) then
		return
	end

	local unit = Module.GetUnitToken(self)
	if not unit or K.IsSecretUnit(unit) then
		return
	end

	local isPlayer = UnitIsPlayer(unit)
	isPlayer = K.NotSecret(isPlayer) and isPlayer
	local unitClass = isPlayer and UnitClass(unit)
	if unitClass and IsSecret(unitClass) then
		unitClass = nil
	end
	local unitCreature = UnitCreatureType(unit)
	if unitCreature and IsSecret(unitCreature) then
		unitCreature = nil
	end

	if linetext == PVP then
		return true
	elseif FACTION_COLORS[linetext] then
		if C["Tooltip"].FactionIcon then
			return true
		else
			lineData.leftText = string_format(FACTION_COLORS[linetext], linetext)
		end
	elseif unitClass and string_find(linetext, unitClass) then
		lineData.leftText = string_gsub(linetext, "(.-)%S+$", replaceSpecInfo)
	elseif unitCreature and linetext == unitCreature then
		return true
	end
end

-- REASON: Utility to locate the level information line in the tooltip.
function Module:GetLevelLine()
	for i = 2, self:NumLines() do
		local tiptext = _G[self:GetName() .. "TextLeft" .. i]
		if not tiptext then
			break
		end

		-- SECRET (12.0): tooltip line text can be secret while tainted; string.find
		-- on a secret string errors, so skip lines we cannot safely read.
		local linetext = tiptext:GetText()
		if linetext and K.NotSecret(linetext) and string_find(linetext, LEVEL) then
			return tiptext
		end
	end
end

-- REASON: Retrieves the unit's target name with class/relationship coloring.
-- SECRET (12.0): the target token's identity can be secret in instances, so a
-- secret unit (or a secret UnitIsUnit result) must not hit a boolean test.
function Module:GetTarget(unit)
	if IsSecret(unit) then
		return ""
	end

	local isYou = UnitIsUnit(unit, "player")
	if K.NotSecret(isYou) and isYou then
		return string_format("|cffff0000%s|r", ">" .. string_upper(YOU) .. "<")
	else
		return K.RGBToHex(K.UnitColor(unit)) .. UnitName(unit) .. "|r"
	end
end

-- REASON: Dynamically adds a faction icon (atlas) to the tooltip.
function Module:InsertFactionFrame(faction)
	if not self.factionFrame then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", -10, -10)
		f:SetBlendMode("ADD")
		self.factionFrame = f
	end

	self.factionFrame:SetAtlas("MountJournalIcons-" .. faction, true)
	self.factionFrame:Show()
end

-- REASON: Resets custom tooltip state (faction frames, status bars) on clear.
-- Do NOT clear item-level inspect here — OnTooltipCleared fires mid-rebuild
-- while NotifyInspect is in flight (clear inspect state on OnHide only).
function Module:OnTooltipCleared()
	if self:IsForbidden() then
		return
	end

	if self.factionFrame and self.factionFrame:IsShown() then
		self.factionFrame:Hide()
	end

	GameTooltip_ClearMoney(self)
	GameTooltip_ClearStatusBars(self)
	GameTooltip_ClearProgressBars(self)
	GameTooltip_ClearWidgetSet(self)

	if self.StatusBar then
		self.StatusBar:ClearWatch()
	end
end

local function OnGameTooltipHide()
	if GameTooltip:IsForbidden() then
		return
	end
	Module._tipShownGUID = nil
	if Module.ClearItemLevelInspectState then
		Module:ClearItemLevelInspectState()
	end
end

-- REASON: Utility to wrap dungeon score with rarity color.
function Module.GetDungeonScore(score)
	local color = C_ChallengeMode_GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
	return color:WrapTextInColorCode(score)
end

-- REASON: Adds Mythic+ score to the unit tooltip.
function Module:ShowUnitMythicPlusScore(unit)
	if not C["Tooltip"].MDScore then
		return
	end

	local summary = C_PlayerInfo_GetPlayerMythicPlusRatingSummary(unit)
	local score = summary and summary.currentSeasonScore
	if score and score > 0 then
		GameTooltip:AddLine(string_format(DUNGEON_SCORE_LEADER, Module.GetDungeonScore(score)))
	end
end

-- REASON: Extensive handler for unit tooltips, adding name, title, realm, status, guild, role, level, and target info.
function Module:OnTooltipSetUnit()
	if not IsTooltipModuleEnabled() then
		return
	end

	if self:IsForbidden() or self ~= GameTooltip then
		return
	end

	if C["Tooltip"].CombatHide and InCombatLockdown() then
		self:Hide()
		return
	end

	local unit = Module.GetUnitToken(self)
	if not unit or K.IsSecretUnit(unit) then
		return
	end

	local exists = UnitExists(unit)
	if not (K.NotSecret(exists) and exists) then
		return
	end

	local data = self.GetPrimaryTooltipData and self:GetPrimaryTooltipData() or self:GetTooltipData()
	local guid = data and data.guid
	if IsSecret(guid) then
		guid = nil
	end

	local isShiftKeyDown = IsShiftKeyDown()
	local isPlayer = UnitIsPlayer(unit)
	if IsSecret(isPlayer) then
		return
	end

	if isPlayer then
		local name, realm = UnitName(unit)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)

		if not C["Tooltip"].HideTitle and pvpName and K.NotSecret(pvpName) and pvpName ~= "" then
			name = pvpName
		end

		if realm and K.NotSecret(realm) and realm ~= "" then
			if isShiftKeyDown or not C["Tooltip"].HideRealm then
				name = name .. "-" .. realm
			elseif K.NotSecret(relationship) and relationship == LE_REALM_RELATION_COALESCED then
				name = name .. FOREIGN_SERVER_LABEL
			elseif K.NotSecret(relationship) and relationship == LE_REALM_RELATION_VIRTUAL then
				name = name .. INTERACTIVE_SERVER_LABEL
			end
		end

		-- SECRET (12.0): these unit-state APIs can return secret booleans on
		-- restricted tooltips. Never use them directly in boolean chains.
		local status
		local isAFK = UnitIsAFK(unit)
		if K.NotSecret(isAFK) and isAFK then
			status = AFK
		else
			local isDND = UnitIsDND(unit)
			if K.NotSecret(isDND) and isDND then
				status = DND
			else
				local isConnected = UnitIsConnected(unit)
				if K.NotSecret(isConnected) and not isConnected then
					status = PLAYER_OFFLINE
				end
			end
		end
		if status then
			status = string_format(" |cffffcc00[%s]|r", status)
		end
		GameTooltipTextLeft1:SetFormattedText("%s", name .. (status or ""))

		if C["Tooltip"].FactionIcon then
			local faction = UnitFactionGroup(unit)
			if faction and K.NotSecret(faction) and faction ~= "Neutral" then
				Module.InsertFactionFrame(self, faction)
			end
		end

		if C["Tooltip"].LFDRole then
			local unitColor
			local unitRole = UnitGroupRolesAssigned(unit)
			local inParty = UnitInParty(unit)
			local inRaid = UnitInRaid(unit)

			if IsInGroup() and K.NotSecret(inParty) and K.NotSecret(inRaid) and (inParty or inRaid) and K.NotSecret(unitRole) and (unitRole ~= "NONE") then
				if unitRole == "HEALER" then
					unitRole = HEALER
					unitColor = "|cff00ff96" -- RGB: 0, 255, 150
				elseif unitRole == "TANK" then
					unitRole = TANK
					unitColor = "|cff2850a0" -- RGB: 40, 80, 160
				elseif unitRole == "DAMAGER" then
					unitRole = DAMAGE
					unitColor = "|cffc41f3b" -- RGB: 196, 31, 59
				end

				self:AddLine(ROLE .. ": " .. unitColor .. unitRole .. "|r")
			end
		end

		local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
		local hasText = GameTooltipTextLeft2:GetText()

		if guildName and K.NotSecret(guildName) and hasText and K.NotSecret(hasText) then
			local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
			local sameGuild = IsInGuild() and myGuild and K.NotSecret(myGuild) and K.NotSecret(guildRealm) and K.NotSecret(myGuildRealm) and guildName == myGuild and guildRealm == myGuildRealm
			if sameGuild then
				GameTooltipTextLeft2:SetTextColor(0.25, 1, 0.25)
			else
				GameTooltipTextLeft2:SetTextColor(0.6, 0.8, 1)
			end

			if K.NotSecret(rankIndex) then
				rankIndex = rankIndex + 1
			else
				rankIndex = 0
			end
			if C["Tooltip"].HideRank then
				rank = ""
			elseif rank and IsSecret(rank) then
				rank = ""
			end

			if guildRealm and K.NotSecret(guildRealm) and isShiftKeyDown then
				guildName = guildName .. "-" .. guildRealm
			end

			if C["Tooltip"].HideJunkGuild and not isShiftKeyDown then
				if string_len(guildName) > 31 then
					guildName = "..."
				end
			end

			GameTooltipTextLeft2:SetText("<" .. guildName .. "> " .. rank .. "(" .. rankIndex .. ")")
		end
	end

	local r, g, b = K.UnitColor(unit)
	local hexColor = K.RGBToHex(r, g, b)
	local text = GameTooltipTextLeft1:GetText()

	if text then
		-- SECRET (12.0): GetRaidTargetIndex can return a secret number; only read
		-- it when it's safe to compare .
		local ricon = GetRaidTargetIndex(unit)
		local riconStr = (ricon and K.NotSecret(ricon) and ricon <= 8) and (ICON_LIST[ricon] .. "18|t ") or ""
		GameTooltipTextLeft1:SetFormattedText("%s%s%s", riconStr, hexColor, text)
	end

	local alive = not UnitIsDeadOrGhost(unit)
	local level

	if UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) then
		level = UnitBattlePetLevel(unit)
	else
		level = UnitLevel(unit)
	end

	if level then
		local boss
		if level == -1 then
			boss = "|cffff0000??|r"
		end

		local diff = GetCreatureDifficultyColor(level)
		local classify = UnitClassification(unit)
		local textLevel = format("%s%s%s|r", K.RGBToHex(diff), boss or format("%d", level), classification[classify] or "")
		local tiptextLevel = Module.GetLevelLine(self)

		if tiptextLevel then
			local reaction = UnitReaction(unit, "player")
			local standingText = not isPlayer and reaction and hexColor .. (_G["FACTION_STANDING_LABEL" .. reaction] or "") .. "|r " or ""
			local pvpFlag = isPlayer and UnitIsPVP(unit) and string_format(" |cffff0000%s|r", PVP) or ""
			-- UnitClass className can be ConditionalSecret; prefer filename. CreatureType is identity-restricted.
			local unitClass = ""
			if isPlayer then
				local race = UnitRace(unit)
				local _, classFile = UnitClass(unit)
				if race and IsSecret(race) then
					race = nil
				end
				if classFile and IsSecret(classFile) then
					classFile = nil
				end
				unitClass = string_format("%s %s", race or "", hexColor .. (classFile or "") .. "|r")
			else
				local ctype = UnitCreatureType(unit)
				unitClass = (ctype and not IsSecret(ctype) and ctype) or ""
			end

			tiptextLevel:SetFormattedText("%s%s %s %s", textLevel, pvpFlag, standingText .. unitClass, (not alive and "|cffCCCCCC" .. DEAD .. "|r" or ""))
		end
	end

	if UnitExists(unit .. "target") then
		-- SECRET (12.0): same guard as the unit raid icon above.
		local tarRicon = GetRaidTargetIndex(unit .. "target")
		local tarRiconStr = (tarRicon and K.NotSecret(tarRicon) and tarRicon <= 8) and (ICON_LIST[tarRicon] .. "10|t") or ""
		local tar = string_format("%s%s", tarRiconStr, Module:GetTarget(unit .. "target"))
		self:AddLine(TARGET .. ": " .. tar)
	end

	if not isPlayer and isShiftKeyDown then
		local npcID = K.GetNPCID(guid)
		if npcID then
			local label = L["NpcID:"] or "NpcID:"
			self:AddLine(string_format(npcIDstring, label, npcID))
		end
	end

	if isPlayer then
		Module.InspectUnitItemLevel(self, unit, guid)
		Module.ShowUnitMythicPlusScore(self, unit)
	end

	Module.ScanTargets(self, unit)
	Module.CreatePetInfo(self, unit)
end

-- REASON: Hooks progress bar creation to apply custom styling.
function Module:GameTooltip_ShowProgressBar()
	if not self or self:IsForbidden() then
		return
	end

	if not self.progressBarPool then
		return
	end

	local bar = self.progressBarPool:GetNextActive()
	if bar and not bar.styled then
		bar.Bar:StripTextures()
		bar.Bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		bar.Bar:CreateBorder()

		bar.styled = true
	end
end

-- Anchor and mover
local cursorIndex = {
	[1] = "ANCHOR_NONE",
	[2] = "ANCHOR_CURSOR_LEFT",
	[3] = "ANCHOR_CURSOR",
	[4] = "ANCHOR_CURSOR_RIGHT",
}
local anchorIndex = {
	[1] = "TOPLEFT",
	[2] = "TOPRIGHT",
	[3] = "BOTTOMLEFT",
	[4] = "BOTTOMRIGHT",
}

local mover
-- REASON: Customizes tooltip anchor based on user settings (CursorMode, TipAnchor).
function Module:GameTooltip_SetDefaultAnchor(parent)
	if not IsTooltipModuleEnabled() then
		return
	end

	if self:IsForbidden() then
		return
	end

	if not parent then
		return
	end

	local mode = C["Tooltip"].CursorMode
	self:SetOwner(parent, cursorIndex[mode])

	if mode == 1 then
		if not mover then
			mover = K.Mover(self, "Tooltip", "GameTooltip", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -230, 38 }, 100, 100)
		end
		self:ClearAllPoints()
		self:SetPoint(anchorIndex[C["Tooltip"].TipAnchor], mover)
	end
end

function Module:UpdateAnchor()
	if C["Tooltip"].CursorMode ~= 1 or not mover then
		return
	end

	if GameTooltip:IsShown() then
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint(anchorIndex[C["Tooltip"].TipAnchor], mover)
	end
end

function Module:UpdateCursorMode()
	if not GameTooltip:IsShown() then
		return
	end

	local owner = GameTooltip:GetOwner() or UIParent
	GameTooltip:SetOwner(owner, cursorIndex[C["Tooltip"].CursorMode])
	Module:UpdateAnchor()
end

-- REASON: Main function to apply KkthnxUI borders and quality colors to various tooltips.
function Module:ReskinTooltip()
	if not IsTooltipModuleEnabled() then
		return
	end

	if not self then
		return
	end

	if self:IsForbidden() then
		return
	end

	if not self.tipStyled then
		self:HideBackdrop()
		if self.background then
			self.background:Hide()
		end

		self.bg = CreateFrame("Frame", nil, self)
		self.bg:ClearAllPoints()
		self.bg:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
		self.bg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 2)
		self.bg:SetFrameLevel(self:GetFrameLevel())
		self.bg:CreateBorder()

		if self.StatusBar then
			Module.ReskinStatusBar(self)
		end

		self.tipStyled = true
	end

	K.SetBorderColor(self.bg.KKUI_Border)

	if not C["Tooltip"].ClassColor then
		return
	end

	local data = self.GetTooltipData and self:GetTooltipData()
	if data then
		-- SECRET (12.0): data.guid can be secret on restricted items and must not be
		-- passed to C_Item.GetItemLinkByGUID. Fall back to the hyperlink .
		local guid = data.guid
		local link = (guid and K.NotSecret(guid) and C_Item_GetItemLinkByGUID(guid)) or data.hyperlink
		if link and K.NotSecret(link) then
			local quality = select(3, C_Item_GetItemInfo(link))
			-- SECRET (12.0): quality is used as a table key below; a secret key errors.
			if K.NotSecret(quality) then
				local color = K.QualityColors[quality or 1]
				if color then
					self.bg.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
				end
			end
		end
	end
end

-- REASON: FIX: Workaround for Blizzard's recipe item name wrapping issues.
function Module:FixRecipeItemNameWidth()
	if not IsTooltipModuleEnabled() then
		return
	end

	if not self.GetName then
		return
	end

	local name = self:GetName()
	for i = 1, self:NumLines() do
		local line = _G[name .. "TextLeft" .. i]
		if line then
			-- SECRET (12.0): bag item tooltip font metrics can be secret while tainted.
			-- This resize is only cosmetic, so skip it unless both reads are safe.
			local height = line:GetHeight()
			if K.NotSecret(height) and height > 40 then
				local width = line:GetWidth()
				if K.NotSecret(width) then
					line:SetWidth(width + 2)
				end
			end
		end
	end
end

-- REASON: Forces a tooltip data refresh when shift is held (extended info).
local function IsSecretTooltipPipelineError(err)
	if type(err) ~= "string" then
		return false
	end
	local lower = string.lower(err)
	return string_find(lower, "secret") ~= nil or string_find(lower, "unitplayercontrolled") ~= nil
end

function Module.ResetUnit(event, btn)
	if btn ~= "LSHIFT" or not IsShiftKeyDown() then
		return
	end

	if not GameTooltip:IsShown() then
		return
	end

	local mouseoverExists = UnitExists("mouseover")
	if not (K.NotSecret(mouseoverExists) and mouseoverExists) then
		return
	end

	if K.IsSecretUnit("mouseover") then
		return
	end

	local unit = Module.GetUnitToken(GameTooltip)
	if not unit or K.IsSecret(unit) or K.IsSecretUnit(unit) then
		return
	end

	-- SECRET (12.0): RefreshData re-runs Blizzard's tooltip pipeline
	-- (GameTooltip_UnitColor -> UnitPlayerControlled). That throws when the unit
	-- token is secret and our handler has tainted execution — skip instead of
	-- fighting Blizzard's secure path.
	local ok, err = pcall(GameTooltip.RefreshData, GameTooltip)
	if not ok and not IsSecretTooltipPipelineError(err) then
		error(err, 0)
	end
end

-- REASON: FIX: Prevents a nil error and unwanted tooltips for the Stone Soup widget.
function Module:FixStoneSoupError()
	local blockTooltips = {
		[556] = true, -- Stone Soup
	}
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		if self:IsForbidden() and blockTooltips[self.widgetSetID] and self.Bar then
			self.Bar.tooltip = nil
		end
	end)
end

-- REASON: Fixes and repositions comparison tooltips to prevent overlapping and ensure proper anchoring.
function Module:AnchorShoppingTooltips(_, secondaryItemShown)
	local tooltip = self.tooltip
	local shoppingTooltip1 = tooltip.shoppingTooltips[1]
	local shoppingTooltip2 = tooltip.shoppingTooltips[2]
	local point = shoppingTooltip1:GetPoint(2)

	if secondaryItemShown then
		if point == "TOP" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", self.anchorFrame, "TOPRIGHT", 4, -10)
			shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 4, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", self.anchorFrame, "TOPLEFT", -4, -10)
			shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -4, 0)
		end
	else
		if point == "LEFT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", self.anchorFrame, "TOPRIGHT", 4, -10)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", self.anchorFrame, "TOPLEFT", -4, -10)
		end
	end
end

-- REASON: Registers hooks and events for tooltip data processing and Blizzard functions.
function Module:OnEnable()
	GameTooltip:HookScript("OnTooltipCleared", Module.OnTooltipCleared)
	GameTooltip:HookScript("OnHide", OnGameTooltipHide)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, Module.OnTooltipSetUnit)

	TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, Module.UpdateFactionLine)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, Module.FixRecipeItemNameWidth)

	hooksecurefunc("GameTooltip_ShowProgressBar", Module.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", Module.GameTooltip_SetDefaultAnchor)
	hooksecurefunc(TooltipComparisonManager, "AnchorShoppingTooltips", Module.AnchorShoppingTooltips)
	Module:FixStoneSoupError()

	-- REASON: Initialize sub-modules for icons, IDs, etc.
	local loadTooltipModules = {
		"CreateTooltipStatusBar",
		"CreateTooltipIcons",
		"CreateTooltipID",
		"CreateMountSource",
		"CreateVendorLocation",
		"CreateItemReagents",
		"CreateAchievementStatus",
		"CreateInstanceLockCompare",
		"SetupPawnIntegration",
	}

	for _, funcName in ipairs(loadTooltipModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	K:RegisterEvent("MODIFIER_STATE_CHANGED", Module.ResetUnit)
end

-- REASON: Registry for addon-specific tooltip skinning functions.
local tipTable = {}
function Module:RegisterTooltips(addon, func)
	tipTable[addon] = func
end

-- REASON: Handler to skin tooltips when an addon is loaded.
local function addonStyled(_, addon)
	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
K:RegisterEvent("ADDON_LOADED", addonStyled)

-- REASON: Skins a wide array of Blizzard and Addon tooltips.
Module:RegisterTooltips("KkthnxUI", function()
	local tooltips = {
		_G.ChatMenu,
		_G.EmoteMenu,
		_G.LanguageMenu,
		_G.VoiceMacroMenu,
		_G.GameTooltip,
		_G.EmbeddedItemTooltip,
		_G.ItemRefTooltip,
		_G.ItemRefShoppingTooltip1,
		_G.ItemRefShoppingTooltip2,
		_G.ShoppingTooltip1,
		_G.ShoppingTooltip2,
		_G.AutoCompleteBox,
		_G.FriendsTooltip,
		_G.QuestScrollFrame.StoryTooltip,
		_G.QuestScrollFrame.CampaignTooltip,
		_G.GeneralDockManagerOverflowButtonList,
		_G.ReputationParagonTooltip,
		_G.NamePlateTooltip,
		_G.QueueStatusFrame,
		_G.FloatingGarrisonFollowerTooltip,
		_G.FloatingGarrisonFollowerAbilityTooltip,
		_G.FloatingGarrisonMissionTooltip,
		_G.GarrisonFollowerAbilityTooltip,
		_G.GarrisonFollowerTooltip,
		_G.FloatingGarrisonShipyardFollowerTooltip,
		_G.GarrisonShipyardFollowerTooltip,
		_G.BattlePetTooltip,
		_G.PetBattlePrimaryAbilityTooltip,
		_G.PetBattlePrimaryUnitTooltip,
		_G.FloatingBattlePetTooltip,
		_G.FloatingPetBattleAbilityTooltip,
		_G.IMECandidatesFrame,
		_G.QuickKeybindTooltip,
		_G.GameSmallHeaderTooltip,
	}

	for _, f in pairs(tooltips) do
		if f then
			f:HookScript("OnShow", Module.ReskinTooltip)
		end
	end

	_G.ItemRefTooltip.CloseButton:SkinCloseButton()
	_G.FloatingBattlePetTooltip.CloseButton:SkinCloseButton()
	_G.FloatingPetBattleAbilityTooltip.CloseButton:SkinCloseButton()

	if _G.SettingsTooltip then
		Module.ReskinTooltip(_G.SettingsTooltip)
		_G.SettingsTooltip:SetScale(UIParent:GetScale())
	end

	-- REASON: Skins dynamically created dropdown menu backdrops.
	local dropdowns = { "DropDownList", "L_DropDownList", "Lib_DropDownList" }
	local function reskinDropdown()
		for _, name in pairs(dropdowns) do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G[name .. i .. "MenuBackdrop"]
				if menu and not menu.styled then
					menu:HookScript("OnShow", Module.ReskinTooltip)
					menu.styled = true
				end
			end
		end
	end
	hooksecurefunc("UIDropDownMenu_CreateFrames", reskinDropdown)

	-- REASON: Skins the IME candidates frame selection.
	local r, g, b = K.r, K.g, K.b
	_G.IMECandidatesFrame.selection:SetVertexColor(r, g, b)

	-- REASON: Skins the pet battle primary unit tooltip.
	_G.PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
		self.Border:SetAlpha(0)
		if not self.iconStyled then
			if self.glow then
				self.glow:Hide()
			end
			self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			self.iconStyled = true
		end
	end)

	-- REASON: Skins pet battle unit tooltip auras (buffs/debuffs).
	hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self)
		local nextBuff, nextDebuff = 1, 1
		for i = 1, C_PetBattles_GetNumAuras(self.petOwner, self.petIndex) do
			local _, _, _, isBuff = C_PetBattles_GetAuraInfo(self.petOwner, self.petIndex, i)
			if isBuff and self.Buffs then
				local frame = self.Buffs.frames[nextBuff]
				if frame and frame.Icon then
					frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				end
				nextBuff = nextBuff + 1
			elseif (not isBuff) and self.Debuffs then
				local frame = self.Debuffs.frames[nextDebuff]
				if frame and frame.Icon then
					frame.DebuffBorder:Hide()
					frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				end
				nextDebuff = nextDebuff + 1
			end
		end
	end)

	-- REASON: Delay skinning for specific addons/libraries that may load late.
	K.Delay(5, function()
		if _G.BSYC_EventAlertTooltip then
			Module.ReskinTooltip(_G.BSYC_EventAlertTooltip)
		end
		if _G.LibDBIconTooltip then
			Module.ReskinTooltip(_G.LibDBIconTooltip)
		end
		if _G.AceConfigDialogTooltip then
			Module.ReskinTooltip(_G.AceConfigDialogTooltip)
		end
		if _G.TomTomTooltip then
			Module.ReskinTooltip(_G.TomTomTooltip)
		end
		if _G.RSMapItemToolTip then
			Module.ReskinTooltip(_G.RSMapItemToolTip)
		end
		if _G.LootBarToolTip then
			Module.ReskinTooltip(_G.LootBarToolTip)
		end
		if _G.NarciGameTooltip then
			Module.ReskinTooltip(_G.NarciGameTooltip)
		end
		if _G.AltoTooltip then
			Module.ReskinTooltip(_G.AltoTooltip)
		end
		if _G.AppearanceTooltipTooltip then
			Module.ReskinTooltip(_G.AppearanceTooltipTooltip)
		end
	end)

	-- REASON: Support for BattlePetBreedID.
	if _G.C_AddOns.IsAddOnLoaded("BattlePetBreedID") then
		hooksecurefunc("BPBID_SetBreedTooltip", function(parent)
			if parent == _G.FloatingBattlePetTooltip then
				Module.ReskinTooltip(_G.BPBID_BreedTooltip2)
			else
				Module.ReskinTooltip(_G.BPBID_BreedTooltip)
			end
		end)
	end

	-- REASON: Support for Method Dungeon Tools (MDT).
	if _G.MDT and _G.MDT.ShowInterface then
		local styledMDT
		hooksecurefunc(_G.MDT, "ShowInterface", function()
			if not styledMDT then
				Module.ReskinTooltip(_G.MDT.tooltip)
				Module.ReskinTooltip(_G.MDT.pullTooltip)
				styledMDT = true
			end
		end)
	end
end)

-- REASON: Skins Blizzard DebugTools (FrameStack) tooltips.
Module:RegisterTooltips("Blizzard_DebugTools", function()
	Module.ReskinTooltip(_G.FrameStackTooltip)
	_G.FrameStackTooltip:SetScale(UIParent:GetScale())
end)

-- REASON: Skins Blizzard EventTrace tooltips.
Module:RegisterTooltips("Blizzard_EventTrace", function()
	Module.ReskinTooltip(_G.EventTraceTooltip)
end)

-- REASON: Skins Blizzard Collections (Pet Journal) tooltips.
Module:RegisterTooltips("Blizzard_Collections", function()
	_G.PetJournalPrimaryAbilityTooltip:HookScript("OnShow", Module.ReskinTooltip)
	_G.PetJournalSecondaryAbilityTooltip:HookScript("OnShow", Module.ReskinTooltip)
	_G.PetJournalPrimaryAbilityTooltip.Delimiter1:SetHeight(1)
	_G.PetJournalPrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
	_G.PetJournalPrimaryAbilityTooltip.Delimiter2:SetHeight(1)
	_G.PetJournalPrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
end)

-- REASON: Skins Blizzard Garrison UI tooltips.
Module:RegisterTooltips("Blizzard_GarrisonUI", function()
	local gt = {
		_G.GarrisonMissionMechanicTooltip,
		_G.GarrisonMissionMechanicFollowerCounterTooltip,
		_G.GarrisonShipyardMapMissionTooltip,
		_G.GarrisonBonusAreaTooltip,
		_G.GarrisonBuildingFrame.BuildingLevelTooltip,
		_G.GarrisonFollowerAbilityWithoutCountersTooltip,
		_G.GarrisonFollowerMissionAbilityWithoutCountersTooltip,
	}
	for _, f in ipairs(gt) do
		if f then
			f:HookScript("OnShow", Module.ReskinTooltip)
		end
	end
end)

-- REASON: Skins Blizzard PVP UI tooltips.
Module:RegisterTooltips("Blizzard_PVPUI", function()
	_G.ConquestTooltip:HookScript("OnShow", Module.ReskinTooltip)
end)

-- REASON: Skins Blizzard Contribution UI tooltips.
Module:RegisterTooltips("Blizzard_Contribution", function()
	_G.ContributionBuffTooltip:HookScript("OnShow", Module.ReskinTooltip)
	_G.ContributionBuffTooltip.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	_G.ContributionBuffTooltip.Border:SetAlpha(0)
end)

-- REASON: Skins Blizzard Encounter Journal UI tooltips.
Module:RegisterTooltips("Blizzard_EncounterJournal", function()
	_G.EncounterJournalTooltip:HookScript("OnShow", Module.ReskinTooltip)
	_G.EncounterJournalTooltip.Item1.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	_G.EncounterJournalTooltip.Item1.IconBorder:SetAlpha(0)
	_G.EncounterJournalTooltip.Item2.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	_G.EncounterJournalTooltip.Item2.IconBorder:SetAlpha(0)
end)
