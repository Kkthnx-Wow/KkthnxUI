local K, C = unpack(KkthnxUI)
local Module = K:NewModule("Tooltip")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_len = _G.string.len
local string_upper = _G.string.upper

local AFK = _G.AFK
local BOSS = _G.BOSS
local C_ChallengeMode_GetDungeonScoreRarityColor = _G.C_ChallengeMode.GetDungeonScoreRarityColor
local C_MountJournal_GetMountIDs = _G.C_MountJournal.GetMountIDs
local C_MountJournal_GetMountInfoByID = _G.C_MountJournal.GetMountInfoByID
local C_MountJournal_GetMountInfoExtraByID = _G.C_MountJournal.GetMountInfoExtraByID
local C_PlayerInfo_GetPlayerMythicPlusRatingSummary = _G.C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local DAMAGE = _G.DAMAGE
local DEAD = _G.DEAD
local DND = _G.DND
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE
local FACTION_HORDE = _G.FACTION_HORDE
local FOREIGN_SERVER_LABEL = _G.FOREIGN_SERVER_LABEL
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local GetGuildInfo = _G.GetGuildInfo
local GetItemInfo = _G.GetItemInfo
local GetMouseFocus = _G.GetMouseFocus
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local HEALER = _G.HEALER
local HIGHLIGHT_FONT_COLOR = _G.HIGHLIGHT_FONT_COLOR
local ICON_LIST = _G.ICON_LIST
local INTERACTIVE_SERVER_LABEL = _G.INTERACTIVE_SERVER_LABEL
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local LEVEL = _G.LEVEL
local LE_REALM_RELATION_COALESCED = _G.LE_REALM_RELATION_COALESCED
local LE_REALM_RELATION_VIRTUAL = _G.LE_REALM_RELATION_VIRTUAL
local PLAYER_OFFLINE = _G.PLAYER_OFFLINE
local PVP = _G.PVP
local TANK = _G.TANK
local TARGET = _G.TARGET
local UIDROPDOWNMENU_MAXLEVELS = _G.UIDROPDOWNMENU_MAXLEVELS
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
local UnitRealmRelationship = _G.UnitRealmRelationship
local YOU = _G.YOU
local hooksecurefunc = _G.hooksecurefunc

local tipTable = {}
local GameTooltip_Mover

local classification = {
	worldboss = string_format("|cffAF5050 %s|r", BOSS),
	rareelite = string_format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = string_format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC),
}
local npcIDstring = "%s " .. K.InfoColor .. "%s"
local blanchyFix = "|n%s*|n" -- thanks blizz -x- lol

function Module:GetUnit()
	local _, unit = self:GetUnit()
	if not unit then
		local mFocus = GetMouseFocus()
		unit = mFocus and (mFocus.unit or (mFocus.GetAttribute and mFocus:GetAttribute("unit")))
	end

	return unit
end

function Module:HideLines()
	if self:IsForbidden() then
		return
	end

	for i = 3, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft" .. i]
		local linetext = tiptext:GetText()
		if linetext then
			if linetext == PVP then
				tiptext:SetText(nil)
				tiptext:Hide()
			elseif linetext == FACTION_HORDE then
				if C["Tooltip"].FactionIcon then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cffff5040" .. linetext .. "|r")
				end
			elseif linetext == FACTION_ALLIANCE then
				if C["Tooltip"].FactionIcon then
					tiptext:SetText(nil)
					tiptext:Hide()
				else
					tiptext:SetText("|cff4080ff" .. linetext .. "|r")
				end
			end
		end
	end
end

function Module:GetLevelLine()
	if self:IsForbidden() then
		return
	end

	for i = 2, self:NumLines() do
		local tiptext = _G["GameTooltipTextLeft" .. i]
		local linetext = tiptext:GetText()
		if linetext and string_find(linetext, LEVEL) then
			return tiptext
		end
	end
end

function Module:GetTarget(unit)
	if UnitIsUnit(unit, "player") then
		return string_format("|cffff0000%s|r", ">" .. string_upper(YOU) .. "<")
	else
		return K.RGBToHex(K.UnitColor(unit)) .. UnitName(unit) .. "|r"
	end
end

function Module:InsertFactionFrame(faction)
	if not self.factionFrame then
		self.factionFrame = self:CreateTexture(nil, "OVERLAY")
		self.factionFrame:SetPoint("TOPRIGHT", 0, -4)
		self.factionFrame:SetBlendMode("ADD")
		self.factionFrame:SetSize(38, 38)
	end

	self.factionFrame:SetTexture("Interface\\Timer\\" .. faction .. "-Logo")
	self.factionFrame:SetAlpha(0.3)
end

function Module:InsertRoleFrame(unit)
	local role = UnitGroupRolesAssigned(unit)
	if role ~= "NONE" then
		if role == "HEALER" then
			role = "|CFF00FF96" .. HEALER .. "|r"
		elseif role == "TANK" then
			role = "|CFF294F9C" .. TANK .. "|r"
		elseif role == "DAMAGER" then
			role = "|CFFC41F3D" .. DAMAGE .. "|r"
		end

		self:AddLine(string_format("%s: %s", _G.ROLE, role))
	end
end

function Module:OnTooltipCleared()
	if self:IsForbidden() then
		return
	end

	if self.factionFrame and self.factionFrame:GetAlpha() ~= 0 then
		self.factionFrame:SetAlpha(0)
	end

	if self.ItemTooltip then
		self.ItemTooltip:Hide()
	end

	GameTooltip_ClearMoney(self)
	GameTooltip_ClearStatusBars(self)
	GameTooltip_ClearProgressBars(self)
	GameTooltip_ClearWidgetSet(self)
end

function Module.GetDungeonScore(score)
	local color = C_ChallengeMode_GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
	return color:WrapTextInColorCode(score)
end

function Module:ShowUnitMythicPlusScore(unit)
	if K.CheckAddOnState("RaiderIO") then
		return
	end

	if not C["Tooltip"].MDScore then
		return
	end

	local summary = C_PlayerInfo_GetPlayerMythicPlusRatingSummary(unit)
	local score = summary and summary.currentSeasonScore
	if score and score > 0 then
		GameTooltip:AddLine(string_format(DUNGEON_SCORE_LEADER, Module.GetDungeonScore(score)))
	end
end

function Module:OnTooltipSetUnit()
	if self:IsForbidden() then
		return
	end

	if C["Tooltip"].CombatHide and InCombatLockdown() then
		self:Hide()
		return
	end

	Module.HideLines(self)

	local unit = Module.GetUnit(self)
	if not unit or not UnitExists(unit) then
		return
	end

	local isShiftKeyDown = IsShiftKeyDown()
	local isPlayer = UnitIsPlayer(unit)
	if isPlayer then
		local name, realm = UnitName(unit)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)
		if not C["Tooltip"].HideTitle and pvpName then
			name = pvpName
		end

		if realm and realm ~= "" then
			if isShiftKeyDown or not C["Tooltip"].HideRealm then
				name = name .. "-" .. realm
			elseif relationship == LE_REALM_RELATION_COALESCED then
				name = name .. FOREIGN_SERVER_LABEL
			elseif relationship == LE_REALM_RELATION_VIRTUAL then
				name = name .. INTERACTIVE_SERVER_LABEL
			end
		end

		local status = (UnitIsAFK(unit) and AFK) or (UnitIsDND(unit) and DND) or (not UnitIsConnected(unit) and PLAYER_OFFLINE)
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
			local role = UnitGroupRolesAssigned(unit)
			if IsInGroup() and (UnitInParty(unit) or UnitInRaid(unit)) and (role ~= "NONE") then
				Module.InsertRoleFrame(self, role)
			end
		end

		local guildName, rank, rankIndex, guildRealm = GetGuildInfo(unit)
		local hasText = GameTooltipTextLeft2:GetText()
		if guildName and hasText then
			local myGuild, _, _, myGuildRealm = GetGuildInfo("player")
			if IsInGuild() and guildName == myGuild and guildRealm == myGuildRealm then
				GameTooltipTextLeft2:SetTextColor(0.25, 1, 0.25)
			else
				GameTooltipTextLeft2:SetTextColor(0.5, 0.7, 1)
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
		if ricon and ricon > 8 then
			ricon = nil
		end
		ricon = ricon and ICON_LIST[ricon] .. "18|t " or ""
		GameTooltipTextLeft1:SetFormattedText("%s%s%s", ricon, hexColor, text)
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
			local pvpFlag = isPlayer and UnitIsPVP(unit) and format(" |cffff0000%s|r", PVP) or ""
			local unitClass = isPlayer and format("%s %s", UnitRace(unit) or "", hexColor .. (UnitClass(unit) or "") .. "|r") or UnitCreatureType(unit) or ""
			tiptextLevel:SetFormattedText("%s%s %s %s", textLevel, pvpFlag, unitClass, (not alive and "|cffCCCCCC" .. DEAD .. "|r" or ""))
		end
	end

	if UnitExists(unit .. "target") then
		local tarRicon = GetRaidTargetIndex(unit .. "target")
		if tarRicon and tarRicon > 8 then
			tarRicon = nil
		end
		local tar = string_format("%s%s", (tarRicon and ICON_LIST[tarRicon] .. "10|t") or "", Module:GetTarget(unit .. "target"))
		self:AddLine(TARGET .. ": " .. tar)
	end

	if not isPlayer and isShiftKeyDown then
		local guid = UnitGUID(unit)
		local npcID = guid and K.GetNPCID(guid)
		if npcID then
			local reaction = UnitReaction(unit, "player")
			local standingText = reaction and hexColor .. _G["FACTION_STANDING_LABEL" .. reaction]
			self:AddDoubleLine(string_format(npcIDstring, standingText or "", npcID))
		end
	end

	self.StatusBar:SetStatusBarColor(r, g, b)

	Module.InspectUnitSpecAndLevel(self, unit)
	Module.ShowUnitMythicPlusScore(self, unit)
end

function Module:StatusBar_OnValueChanged(value)
	if self:IsForbidden() or not value then
		return
	end

	local min, max = self:GetMinMaxValues()
	if (value < min) or (value > max) then
		return
	end

	if not self.text then
		self.text = K.CreateFontString(self, 11, nil, "")
	end

	if value > 0 and max == 1 then
		self.text:SetFormattedText("%d%%", value * 100)
		self:SetStatusBarColor(0.6, 0.6, 0.6) -- Wintergrasp building
	else
		self.text:SetText(K.ShortValue(value) .. " - " .. K.ShortValue(max))
	end
end

function Module:ReskinStatusBar()
	if not self or self:IsForbidden() or not self.StatusBar then
		return
	end

	self.StatusBar:ClearAllPoints()
	self.StatusBar:SetPoint("BOTTOMLEFT", self.tooltipStyle, "TOPLEFT", 0, 6)
	self.StatusBar:SetPoint("BOTTOMRIGHT", self.tooltipStyle, "TOPRIGHT", -0, 6)
	self.StatusBar:SetStatusBarTexture(K.GetTexture(C["UITextures"].TooltipTextures))
	self.StatusBar:SetHeight(11)
	self.StatusBar:CreateBorder()
end

function Module:GameTooltip_ShowStatusBar()
	if not self or self:IsForbidden() or not self.statusBarPool then
		return
	end

	local bar = self.statusBarPool:GetNextActive()
	if (not bar or not bar.text) or bar.isStyled then
		return
	end

	bar:StripTextures()
	bar:CreateBorder()
	bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].TooltipTextures))

	bar.isStyled = true
end

function Module:GameTooltip_ShowProgressBar()
	if not self or self:IsForbidden() or not self.progressBarPool then
		return
	end

	local bar = self.progressBarPool:GetNextActive()
	if (not bar or not bar.Bar) or bar.isStyled then
		return
	end

	bar.Bar:StripTextures()
	bar.Bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].TooltipTextures))
	bar.Bar:CreateBorder()

	bar.isStyled = true
end

-- Anchor and mover
function Module:GameTooltip_SetDefaultAnchor(parent)
	if self:IsForbidden() then
		return
	end

	if not parent then
		return
	end

	if C["Tooltip"].Cursor then
		self:SetOwner(parent, "ANCHOR_CURSOR_RIGHT")
	else
		if not GameTooltip_Mover then
			GameTooltip_Mover = K.Mover(self, "Tooltip", "GameTooltip", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -182, 36 }, 240, 120)
		end

		self:SetOwner(parent, "ANCHOR_NONE")
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", GameTooltip_Mover)
	end
end

-- Fix comparison error on cursor
function Module:GameTooltip_ComparisonFix(anchorFrame, shoppingTooltip1, shoppingTooltip2, _, secondaryItemShown)
	local point = shoppingTooltip1:GetPoint(2)
	if secondaryItemShown then
		if point == "TOP" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, 0)
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip2:SetPoint("TOPLEFT", shoppingTooltip1, "TOPRIGHT", 3, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, 0)
			shoppingTooltip2:ClearAllPoints()
			shoppingTooltip2:SetPoint("TOPRIGHT", shoppingTooltip1, "TOPLEFT", -3, 0)
		end
	else
		if point == "LEFT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 3, 0)
		elseif point == "RIGHT" then
			shoppingTooltip1:ClearAllPoints()
			shoppingTooltip1:SetPoint("TOPRIGHT", anchorFrame, "TOPLEFT", -3, 0)
		end
	end
end

function Module:ReskinTooltip()
	if not self then
		if K.isDeveloper then
			K.Print("Unknown tooltip spotted!")
		end
		return
	end

	if self:IsForbidden() then
		return
	end

	if not self.isTipStyled then
		self:HideBackdrop()
		self:DisableDrawLayer("BACKGROUND")

		self.tooltipStyle = CreateFrame("Frame", nil, self)
		self.tooltipStyle:SetPoint("TOPLEFT", self, 2, -2)
		self.tooltipStyle:SetPoint("BOTTOMRIGHT", self, -2, 2)
		self.tooltipStyle:SetFrameLevel(self:GetFrameLevel())
		self.tooltipStyle:CreateBorder()

		if self.StatusBar then
			Module.ReskinStatusBar(self)
		end

		self.isTipStyled = true
	end

	if C["General"].ColorTextures then
		self.tooltipStyle.KKUI_Border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
	else
		self.tooltipStyle.KKUI_Border:SetVertexColor(1, 1, 1)
	end

	if C["Tooltip"].ClassColor and self.GetItem then
		local _, item = self:GetItem()
		if item then
			local quality = select(3, GetItemInfo(item))
			local color = K.QualityColors[quality or 1]
			if color then
				self.tooltipStyle.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end
end

function Module:FixRecipeItemNameWidth()
	local name = self:GetName()
	for i = 1, self:NumLines() do
		local line = _G[name .. "TextLeft" .. i]
		if line:GetHeight() > 40 then
			line:SetWidth(line:GetWidth() + 1)
		end
	end
end

function Module:ResetUnit(btn)
	if btn == "LSHIFT" and UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end

function Module:AddMountSource(unit, index, filter)
	if not self or self:IsForbidden() or not C["Tooltip"].ShowMount then
		return
	end

	if UnitIsUnit(unit, "player") then
		return
	end

	local _, _, _, _, _, _, _, _, _, spellID = UnitAura(unit, index, filter)
	if not spellID then
		return
	end

	local mountID = Module.MountIDs[spellID]
	if mountID and IsControlKeyDown() then
		local _, _, sourceText = C_MountJournal_GetMountInfoExtraByID(mountID)
		local mountText = sourceText and gsub(sourceText, blanchyFix, "|n")

		if mountText then
			self:AddLine(" ")
			self:AddLine(mountText, 1, 1, 1)
			self:Show()
		end
	end
end

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

function Module:OnEnable()
	if not C["Tooltip"].Enable then
		return
	end

	Module.MountIDs = {}
	local mountIDs = C_MountJournal_GetMountIDs()
	for _, mountID in ipairs(mountIDs) do
		local _, spellID = C_MountJournal_GetMountInfoByID(mountID)
		Module.MountIDs[spellID] = mountID
	end

	GameTooltip.StatusBar = GameTooltipStatusBar
	GameTooltip:HookScript("OnTooltipCleared", Module.OnTooltipCleared)
	GameTooltip:HookScript("OnTooltipSetUnit", Module.OnTooltipSetUnit)
	GameTooltip.StatusBar:SetScript("OnValueChanged", Module.StatusBar_OnValueChanged)
	hooksecurefunc("GameTooltip_ShowStatusBar", Module.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", Module.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", Module.GameTooltip_SetDefaultAnchor)
	hooksecurefunc("GameTooltip_AnchorComparisonTooltips", Module.GameTooltip_ComparisonFix)
	GameTooltip:HookScript("OnTooltipSetItem", Module.FixRecipeItemNameWidth)
	ItemRefTooltip:HookScript("OnTooltipSetItem", Module.FixRecipeItemNameWidth)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", Module.FixRecipeItemNameWidth)
	hooksecurefunc(GameTooltip, "SetUnitAura", Module.AddMountSource)
	Module:FixStoneSoupError()

	-- Elements
	self:CreateConduitCollectionData()
	self:CreateDominationRank()
	self:CreateTargetedInfo()
	self:CreateTooltipID()
	self:CreateTooltipIcons()
	K:RegisterEvent("MODIFIER_STATE_CHANGED", Module.ResetUnit)
end

-- Tooltip Skin Registration
function Module:RegisterTooltips(addon, func)
	if not C["Tooltip"].Enable then
		return
	end

	tipTable[addon] = func
end

local function addonStyled(_, addon)
	if not C["Tooltip"].Enable then
		return
	end

	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
K:RegisterEvent("ADDON_LOADED", addonStyled)

Module:RegisterTooltips("KkthnxUI", function()
	if not C["Tooltip"].Enable then
		return
	end

	local tooltips = {
		AutoCompleteBox,
		BattlePetTooltip,
		ChatMenu,
		EmbeddedItemTooltip,
		EmoteMenu,
		FloatingBattlePetTooltip,
		FloatingGarrisonFollowerAbilityTooltip,
		FloatingGarrisonFollowerTooltip,
		FloatingGarrisonMissionTooltip,
		FloatingGarrisonShipyardFollowerTooltip,
		FloatingPetBattleAbilityTooltip,
		FriendsTooltip,
		GameSmallHeaderTooltip,
		GameTooltip,
		GarrisonFollowerAbilityTooltip,
		GarrisonFollowerTooltip,
		GarrisonShipyardFollowerTooltip,
		GeneralDockManagerOverflowButtonList,
		IMECandidatesFrame,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ItemRefTooltip,
		LanguageMenu,
		NamePlateTooltip,
		PetBattlePrimaryAbilityTooltip,
		PetBattlePrimaryUnitTooltip,
		QuestScrollFrame.CampaignTooltip,
		QuestScrollFrame.StoryTooltip,
		QueueStatusFrame,
		QuickKeybindTooltip,
		ReputationParagonTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		VoiceMacroMenu,
		WarCampaignTooltip,
	}

	for _, f in pairs(tooltips) do
		f:HookScript("OnShow", Module.ReskinTooltip)
	end

	_G.ItemRefTooltip.CloseButton:SkinCloseButton()
	_G.FloatingBattlePetTooltip.CloseButton:SkinCloseButton()
	_G.FloatingPetBattleAbilityTooltip.CloseButton:SkinCloseButton()

	-- DropdownMenu
	local function reskinDropdown()
		for _, name in pairs({ "DropDownList", "L_DropDownList", "Lib_DropDownList" }) do
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				local menu = _G[name .. i .. "MenuBackdrop"]
				if menu and not menu.isStyled then
					menu:HookScript("OnShow", Module.ReskinTooltip)
					menu.isStyled = true
				end
			end
		end
	end
	hooksecurefunc("UIDropDownMenu_CreateFrames", reskinDropdown)

	-- IME
	local r, g, b = K.r, K.g, K.b
	IMECandidatesFrame.selection:SetVertexColor(r, g, b)

	-- Pet Tooltip
	PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
		self.Border:SetAlpha(0)
		if not self.isIconStyled then
			if self.glow then
				self.glow:Hide()
			end

			self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			self.isIconStyled = true
		end
	end)

	hooksecurefunc("PetBattleUnitTooltip_UpdateForUnit", function(self)
		local nextBuff, nextDebuff = 1, 1
		for i = 1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
			local _, _, _, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i)
			if isBuff and self.Buffs then
				local frame = self.Buffs.frames[nextBuff]
				if frame and frame.Icon then
					frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				end
				nextBuff = nextBuff + 1
			elseif not isBuff and self.Debuffs then
				local frame = self.Debuffs.frames[nextDebuff]
				if frame and frame.Icon then
					frame.DebuffBorder:Hide()
					frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				end
				nextDebuff = nextDebuff + 1
			end
		end
	end)

	-- Others
	C_Timer_After(6, function()
		-- BagSync
		if BSYC_EventAlertTooltip then
			Module.ReskinTooltip(BSYC_EventAlertTooltip)
		end

		-- Lib minimap icon
		if LibDBIconTooltip then
			Module.ReskinTooltip(LibDBIconTooltip)
		end

		-- TomTom
		if TomTomTooltip then
			Module.ReskinTooltip(TomTomTooltip)
		end

		-- RareScanner
		if RSMapItemToolTip then
			Module.ReskinTooltip(RSMapItemToolTip)
		end

		if LootBarToolTip then
			Module.ReskinTooltip(LootBarToolTip)
		end

		-- Narcissus
		if NarciGameTooltip then
			Module.ReskinTooltip(NarciGameTooltip)
		end

		if AceGUITooltip then
			Module.ReskinTooltip(AceGUITooltip)
		end

		if AceConfigDialogTooltip then
			Module.ReskinTooltip(AceConfigDialogTooltip)
		end

		if TomCatsVignetteTooltip then
			Module.ReskinTooltip(TomCatsVignetteTooltip)
		end
	end)

	if IsAddOnLoaded("BattlePetBreedID") then
		hooksecurefunc("BPBID_SetBreedTooltip", function(parent)
			if parent == FloatingBattlePetTooltip then
				Module.ReskinTooltip(BPBID_BreedTooltip2)
			else
				Module.ReskinTooltip(BPBID_BreedTooltip)
			end
		end)
	end

	-- MDT and DT
	if MDT and MDT.ShowInterface then
		local isMDTStyled
		hooksecurefunc(MDT, "ShowInterface", function()
			if not isMDTStyled then
				Module.ReskinTooltip(MDT.tooltip)
				Module.ReskinTooltip(MDT.pullTooltip)
				isMDTStyled = true
			end
		end)
	end
end)

Module:RegisterTooltips("Blizzard_DebugTools", function()
	Module.ReskinTooltip(FrameStackTooltip)
	FrameStackTooltip:SetScale(UIParent:GetScale())
end)

Module:RegisterTooltips("Blizzard_EventTrace", function()
	Module.ReskinTooltip(EventTraceTooltip)
end)

Module:RegisterTooltips("Blizzard_Collections", function()
	PetJournalPrimaryAbilityTooltip:HookScript("OnShow", Module.ReskinTooltip)
	PetJournalSecondaryAbilityTooltip:HookScript("OnShow", Module.ReskinTooltip)
	PetJournalPrimaryAbilityTooltip.Delimiter1:SetHeight(1)
	PetJournalPrimaryAbilityTooltip.Delimiter1:SetColorTexture(0, 0, 0)
	PetJournalPrimaryAbilityTooltip.Delimiter2:SetHeight(1)
	PetJournalPrimaryAbilityTooltip.Delimiter2:SetColorTexture(0, 0, 0)
end)

Module:RegisterTooltips("Blizzard_GarrisonUI", function()
	local Garrison_Tooltips = {
		GarrisonMissionMechanicTooltip,
		GarrisonMissionMechanicFollowerCounterTooltip,
		GarrisonShipyardMapMissionTooltip,
		GarrisonBonusAreaTooltip,
		GarrisonBuildingFrame.BuildingLevelTooltip,
		GarrisonFollowerAbilityWithoutCountersTooltip,
		GarrisonFollowerMissionAbilityWithoutCountersTooltip,
	}

	for _, f in pairs(Garrison_Tooltips) do
		f:HookScript("OnShow", Module.ReskinTooltip)
	end
end)

Module:RegisterTooltips("Blizzard_PVPUI", function()
	ConquestTooltip:HookScript("OnShow", Module.ReskinTooltip)
end)

Module:RegisterTooltips("Blizzard_Contribution", function()
	ContributionBuffTooltip:HookScript("OnShow", Module.ReskinTooltip)
	ContributionBuffTooltip.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	ContributionBuffTooltip.Border:SetAlpha(0)
end)

Module:RegisterTooltips("Blizzard_EncounterJournal", function()
	EncounterJournalTooltip:HookScript("OnShow", Module.ReskinTooltip)
	EncounterJournalTooltip.Item1.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	EncounterJournalTooltip.Item1.IconBorder:SetAlpha(0)
	EncounterJournalTooltip.Item2.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	EncounterJournalTooltip.Item2.IconBorder:SetAlpha(0)
end)

Module:RegisterTooltips("Blizzard_Calendar", function()
	CalendarContextMenu:HookScript("OnShow", Module.ReskinTooltip)
	CalendarInviteStatusContextMenu:HookScript("OnShow", Module.ReskinTooltip)
end)
