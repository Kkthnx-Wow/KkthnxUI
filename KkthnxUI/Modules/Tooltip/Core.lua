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

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local format = _G.format
local ipairs = _G.ipairs
local next = _G.next
local pairs = _G.pairs
local pcall = _G.pcall
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_len = _G.string.len
local string_upper = _G.string.upper
local type = _G.type
local unpack = _G.unpack

local AFK = _G.AFK
local BOSS = _G.BOSS
local error = _G.error
local format = _G.format
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
local IsShiftKeyDown = _G.IsShiftKeyDown
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
local TooltipDataProcessor = _G.TooltipDataProcessor
local UIParent = _G.UIParent
local UnitBattlePetLevel = _G.UnitBattlePetLevel
local UnitClass = _G.UnitClass
local UnitClassification = _G.UnitClassification
local UnitCreatureType = _G.UnitCreatureType
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitHealthMax = _G.UnitHealthMax
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

local classification = {
	worldboss = string_format("|cffAF5050 %s|r", BOSS),
	rareelite = string_format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = string_format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC),
}
local npcIDstring = "%s " .. K.InfoColor .. "%s"
local ignoreString = "|cffff0000" .. IGNORED .. ":|r %s"
local specPrefix = "|cffFFCC00" .. SPECIALIZATION .. ": " .. K.InfoColor

-- REASON: Utility to retrieve unit and GUID from tooltip data.
function Module:GetUnit()
	local data = self:GetTooltipData()
	local guid = data and K.NotSecretValue(data.guid) and data.guid
	local mouseover = UnitExists("mouseover") and "mouseover"
	local unit = guid and UnitTokenFromGUID(guid) or mouseover
	return unit, guid
end

function Module:UnitExists(unit)
	if ShouldUnitIdentityBeSecret and ShouldUnitIdentityBeSecret(unit) then
		return
	end

	return unit and UnitExists(unit)
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
	if self:IsForbidden() then
		return
	end

	if not self:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local unit = Module.GetUnit(self)
	if not unit then
		return
	end

	local unitClass = unit and UnitIsPlayer(unit) and UnitClass(unit)
	local unitCreature = unit and UnitCreatureType(unit)

	local linetext = lineData.leftText
	if K.IsSecretValue(linetext) then
		return
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
	elseif unitCreature and K.NotSecretValue(unitCreature) and linetext == unitCreature then
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

		local linetext = tiptext:GetText()
		if linetext and K.NotSecretValue(linetext) and string_find(linetext, LEVEL) then
			return tiptext
		end
	end
end

-- REASON: Retrieves the unit's target name with class/relationship coloring.
function Module:GetTarget(unit)
	if K.IsSecretValue(unit) then
		return
	end
	local isYou = UnitIsUnit(unit, "player")
	if K.NotSecretValue(isYou) and isYou then
		return format("|cffff0000%s|r", ">" .. strupper(YOU) .. "<")
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
function Module:OnTooltipCleared()
	if self:IsForbidden() then
		return
	end

	if self.factionFrame and self.factionFrame:IsShown() then
		self.factionFrame:Hide()
	end

	-- GameTooltip_ClearMoney(self)
	-- GameTooltip_ClearStatusBars(self)
	-- GameTooltip_ClearProgressBars(self)
	-- GameTooltip_ClearWidgetSet(self)

	-- if self.StatusBar then
	-- 	self.StatusBar:ClearWatch()
	-- end
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

local function CheckUnitStatus(func, unit, text)
	local status = func(unit)
	return K.NotSecretValue(status) and status and text
end

-- REASON: Extensive handler for unit tooltips, adding name, title, realm, status, guild, role, level, and target info.
function Module:OnTooltipSetUnit()
	if self:IsForbidden() or self ~= GameTooltip then
		return
	end

	if C["Tooltip"].CombatHide and InCombatLockdown() then
		self:Hide()
		return
	end

	local unit, guid = Module.GetUnit(self)
	if not unit or not UnitExists(unit) then
		return
	end

	local isShiftKeyDown = IsShiftKeyDown()
	local isPlayer = UnitIsPlayer(unit)
	local unitFullName

	if isPlayer then
		local name, realm = UnitName(unit)
		unitFullName = name .. "-" .. (realm or K.Realm)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)

		if not C["Tooltip"].HideTitle and pvpName and K.NotSecretValue(pvpName) and pvpName ~= "" then
			name = pvpName
		end

		if realm and K.NotSecretValue(realm) and realm ~= "" then
			if isShiftKeyDown or not C["Tooltip"].HideRealm then
				name = name .. "-" .. realm
			elseif relationship == LE_REALM_RELATION_COALESCED then
				name = name .. FOREIGN_SERVER_LABEL
			elseif relationship == LE_REALM_RELATION_VIRTUAL then
				name = name .. INTERACTIVE_SERVER_LABEL
			end
		end

		local status = CheckUnitStatus(UnitIsAFK, unit, AFK) or CheckUnitStatus(UnitIsDND, unit, DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
		if status then
			status = string_format(" |cffffcc00[%s]|r", status)
		end
		GameTooltipTextLeft1:SetFormattedText("%s", name .. (status or ""))

		if C["Tooltip"].FactionIcon then
			local faction = UnitFactionGroup(unit)
			if faction and faction ~= "Neutral" then
				Module.InsertFactionFrame(self, faction)
			end
		end

		if C["Tooltip"].LFDRole then
			local unitColor
			local unitRole = UnitGroupRolesAssigned(unit)

			if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (unitRole ~= "NONE") then
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

		if guildName and hasText then
			local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
			if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
				GameTooltipTextLeft2:SetTextColor(0.25, 1, 0.25)
			else
				GameTooltipTextLeft2:SetTextColor(0.6, 0.8, 1)
			end

			rankIndex = rankIndex + 1
			if C["Tooltip"].HideRank then
				rank = ""
			end

			if guildRealm and isShiftKeyDown then
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
		local ricon = GetRaidTargetIndex(unit)
		local rionStr = ""
		if ricon and K.NotSecretValue(ricon) and ricon <= 8 then
			rionStr = ICON_LIST[ricon] .. "18|t "
		end
		GameTooltipTextLeft1:SetFormattedText("%s%s%s", rionStr, hexColor, text)
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
		local unitClass = isPlayer and UnitClass(unit)

		if tiptextLevel then
			local reaction = UnitReaction(unit, "player")
			local standingText = not isPlayer and reaction and hexColor .. _G["FACTION_STANDING_LABEL" .. reaction] .. "|r " or ""
			local pvpFlag = isPlayer and UnitIsPVP(unit) and string_format(" |cffff0000%s|r", PVP) or ""
			local unitClassStr = isPlayer and format("%s %s", UnitRace(unit) or "", hexColor .. (unitClass or "") .. "|r") or UnitCreatureType(unit) or ""

			tiptextLevel:SetFormattedText("%s%s %s %s", textLevel, pvpFlag, standingText .. unitClassStr, (not alive and "|cffCCCCCC" .. DEAD .. "|r" or ""))
		end

		local specLine = index and _G["GameTooltipTextLeft" .. (index + 1)]
		local specText = specLine and specLine:GetText()
		if specText and unitClass and strfind(specText, unitClass) then
			specText = gsub(specText, "(.-)%S+$", replaceSpecInfo)
			specLine:SetText(specText)
		end
	end

	if UnitExists(unit .. "target") then
		local targetIcon = GetRaidTargetIndex(unit .. "target")
		local targetIconStr
		if targetIcon and K.NotSecretValue(targetIcon) and targetIcon <= 8 then
			targetIconStr = ICON_LIST[targetIcon] .. "10|t"
		end

		self:AddLine(TARGET .. ": " .. format("%s%s", targetIconStr or "", Module:GetTarget(unit .. "target")))
	end

	if not isPlayer and isShiftKeyDown then
		local npcID = K.GetNPCID(guid)
		if npcID then
			local label = L["NpcID:"] or "NpcID:"
			self:AddLine(string_format(npcIDstring, label, npcID))
		end
	end

	if isPlayer then
		Module.InspectUnitItemLevel(self, unit)
		Module.ShowUnitMythicPlusScore(self, unit)
	end
	-- Module.PetInfo_Setup(self, unit)

	-- Module.ScanTargets(self, unit)
	-- Module.CreatePetInfo(self, unit)

	-- Ignore note
	if unitFullName and K.NotSecretValue(unitFullName) then
		-- local ignoreNote = NDuiADB["IgnoreNotes"][unitFullName]
		-- if ignoreNote then
		-- 	self:AddLine(format(ignoreString, ignoreNote), 1, 1, 1, 1)
		-- end
	end
end

function Module:UpdateStatusBarColor()
	local unit = Module.GetUnit(self)
	if not unit then -- needs review
		return
	end

	if K.IsSecretValue(unit) then
		self.StatusBar:SetStatusBarColor(0, 1, 0)
	else
		self.StatusBar:SetStatusBarColor(K.UnitColor(unit))
	end
end

function Module:RefreshStatusBar()
	if not self.text then
		self.text = K.CreateFontString(self, 11, nil, "")
	end
	local unit = Module.GetUnit(self:GetParent())
	local ok, value = pcall(UnitHealth, unit)
	if ok and value then
		self.text:SetText(K.ShortValue(value))
	else
		self.text:SetText("")
	end
end

-- REASON: Applies KkthnxUI styling (position, texture, border) to the default tooltip status bar.
function Module:ReskinStatusBar()
	self.StatusBar:ClearAllPoints()
	self.StatusBar:SetPoint("BOTTOMLEFT", self.bg, "TOPLEFT", 0, 6)
	self.StatusBar:SetPoint("BOTTOMRIGHT", self.bg, "TOPRIGHT", -0, 6)
	self.StatusBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.StatusBar:SetHeight(12)
	self.StatusBar:CreateBorder()
end

-- REASON: Hooks status bar creation to apply custom styling.
function Module:GameTooltip_ShowStatusBar()
	if not self or self:IsForbidden() then
		return
	end

	if not self.statusBarPool then
		return
	end

	local bar = self.statusBarPool:GetNextActive()
	if bar and not bar.styled then
		bar:StripTextures()
		bar:CreateBorder()
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

		bar.styled = true
	end
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

-- REASON: Main function to apply KkthnxUI borders and quality colors to various tooltips.
function Module:ReskinTooltip()
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
		local link = data.guid and C_Item_GetItemLinkByGUID(data.guid) or data.hyperlink
		if link then
			local quality = select(3, C_Item_GetItemInfo(link))
			local color = K.QualityColors[quality or 1]
			if color then
				self.bg.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end
end

-- REASON: FIX: Workaround for Blizzard's recipe item name wrapping issues.
function Module:FixRecipeItemNameWidth()
	if not self.GetName then
		return
	end

	local name = self:GetName()
	for i = 1, self:NumLines() do
		local line = _G[name .. "TextLeft" .. i]
		if line and K.NotSecretValue(line:GetWidth()) and line:GetHeight() > 40 then
			line:SetWidth(line:GetWidth() + 2)
		end
	end
end

-- REASON: Forces a tooltip data refresh when a modifier key state changes.
function Module:ResetUnit(btn)
	if btn == "LSHIFT" and UnitExists("mouseover") then
		GameTooltip:RefreshData()
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
	GameTooltipStatusBar:SetScript("OnValueChanged", nil)
	GameTooltip:HookScript("OnTooltipCleared", Module.OnTooltipCleared)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, Module.OnTooltipSetUnit)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, Module.UpdateStatusBarColor)
	hooksecurefunc(GameTooltip.StatusBar, "UpdateUnitHealth", Module.RefreshStatusBar)
	TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, Module.UpdateFactionLine)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, Module.FixRecipeItemNameWidth)

	hooksecurefunc("GameTooltip_ShowStatusBar", Module.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", Module.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", Module.GameTooltip_SetDefaultAnchor)
	-- Module:SetupTooltipFonts()
	Module:FixStoneSoupError()

	-- REASON: Initialize sub-modules for icons, IDs, etc.
	local loadTooltipModules = {
		"CreateTooltipIcons",
		"CreateTooltipID",
		"CreateMountSource",
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
