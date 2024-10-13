local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Tooltip")

local strfind, format, strupper, strlen, pairs, unpack = string.find, string.format, string.upper, string.len, pairs, unpack
local ICON_LIST = ICON_LIST
local HIGHLIGHT_FONT_COLOR = HIGHLIGHT_FONT_COLOR
local PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE = PVP, LEVEL, FACTION_HORDE, FACTION_ALLIANCE
local YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE = YOU, TARGET, AFK, DND, DEAD, PLAYER_OFFLINE
local FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL = FOREIGN_SERVER_LABEL, INTERACTIVE_SERVER_LABEL
local LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_COALESCED, LE_REALM_RELATION_VIRTUAL
local UnitIsPVP, UnitFactionGroup, UnitRealmRelationship, UnitGUID = UnitIsPVP, UnitFactionGroup, UnitRealmRelationship, UnitGUID
local UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND, UnitReaction = UnitIsConnected, UnitIsDeadOrGhost, UnitIsAFK, UnitIsDND, UnitReaction
local InCombatLockdown, IsShiftKeyDown, GetMouseFocus, GetItemInfo = InCombatLockdown, IsShiftKeyDown, GetMouseFocus, GetItemInfo
local GetCreatureDifficultyColor, UnitCreatureType, UnitClassification = GetCreatureDifficultyColor, UnitCreatureType, UnitClassification
local UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel = UnitIsWildBattlePet, UnitIsBattlePetCompanion, UnitBattlePetLevel
local UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel = UnitIsPlayer, UnitName, UnitPVPName, UnitClass, UnitRace, UnitLevel
local GetRaidTargetIndex, UnitGroupRolesAssigned, GetGuildInfo, IsInGuild = GetRaidTargetIndex, UnitGroupRolesAssigned, GetGuildInfo, IsInGuild
local C_PetBattles_GetNumAuras, C_PetBattles_GetAuraInfo = C_PetBattles.GetNumAuras, C_PetBattles.GetAuraInfo
local C_ChallengeMode_GetDungeonScoreRarityColor = C_ChallengeMode.GetDungeonScoreRarityColor
local C_PlayerInfo_GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local GameTooltip_ClearMoney, GameTooltip_ClearStatusBars, GameTooltip_ClearProgressBars, GameTooltip_ClearWidgetSet = GameTooltip_ClearMoney, GameTooltip_ClearStatusBars, GameTooltip_ClearProgressBars, GameTooltip_ClearWidgetSet

local classification = {
	worldboss = format("|cffAF5050 %s|r", BOSS),
	rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC),
}
local npcIDstring = "%s " .. K.InfoColor .. "%s"
local specPrefix = "|cffFFCC00" .. SPECIALIZATION .. ": " .. K.InfoColor

function Module:GetUnit()
	local data = self:GetTooltipData()
	local guid = data and data.guid
	local unit = guid and UnitTokenFromGUID(guid)
	return unit, guid
end

local FACTION_COLORS = {
	[FACTION_ALLIANCE] = "|cff4080ff%s|r",
	[FACTION_HORDE] = "|cffff5040%s|r",
}

local function replaceSpecInfo(str)
	return strfind(str, "%s") and specPrefix .. str or str
end

function Module:UpdateFactionLine(lineData)
	if self:IsForbidden() then
		return
	end
	if not self:IsTooltipType(Enum.TooltipDataType.Unit) then
		return
	end

	local unit = Module.GetUnit(self)
	local unitClass = unit and UnitIsPlayer(unit) and UnitClass(unit)
	local unitCreature = unit and UnitCreatureType(unit)
	local linetext = lineData.leftText

	if linetext == PVP then
		return true
	elseif FACTION_COLORS[linetext] then
		if C["Tooltip"].FactionIcon then
			return true
		else
			lineData.leftText = format(FACTION_COLORS[linetext], linetext)
		end
	elseif unitClass and strfind(linetext, unitClass) then
		lineData.leftText = gsub(linetext, "(.-)%S+$", replaceSpecInfo)
	elseif unitCreature and linetext == unitCreature then
		return true
	end
end

function Module:GetLevelLine()
	for i = 2, self:NumLines() do
		local tiptext = _G[self:GetName() .. "TextLeft" .. i]
		if not tiptext then
			break
		end

		local linetext = tiptext:GetText()
		if linetext and strfind(linetext, LEVEL) then
			return tiptext
		end
	end
end

function Module:GetTarget(unit)
	if UnitIsUnit(unit, "player") then
		return format("|cffff0000%s|r", ">" .. strupper(YOU) .. "<")
	else
		return K.RGBToHex(K.UnitColor(unit)) .. UnitName(unit) .. "|r"
	end
end

function Module:InsertFactionFrame(faction)
	if not self.factionFrame then
		local f = self:CreateTexture(nil, "OVERLAY")
		f:SetPoint("TOPRIGHT", -10, -10)
		f:SetBlendMode("ADD")
		-- f:SetScale(0.9)
		-- f:SetAlpha(0.7)
		self.factionFrame = f
	end
	self.factionFrame:SetAtlas("MountJournalIcons-" .. faction, true) --  charcreatetest-logo-horde
	self.factionFrame:Show()
end

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

function Module.GetDungeonScore(score)
	local color = C_ChallengeMode_GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
	return color:WrapTextInColorCode(score)
end

function Module:ShowUnitMythicPlusScore(unit)
	if not C["Tooltip"].MDScore then
		return
	end

	local summary = C_PlayerInfo_GetPlayerMythicPlusRatingSummary(unit)
	local score = summary and summary.currentSeasonScore
	if score and score > 0 then
		GameTooltip:AddLine(format(DUNGEON_SCORE_LEADER, Module.GetDungeonScore(score)))
	end
end

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
	if isPlayer then
		local name, realm = UnitName(unit)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit)
		if not C["Tooltip"].HideTitle and pvpName and pvpName ~= "" then
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
			status = format(" |cffffcc00[%s]|r", status)
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
				if strlen(guildName) > 31 then
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
			local reaction = UnitReaction(unit, "player")
			local standingText = not isPlayer and reaction and hexColor .. _G["FACTION_STANDING_LABEL" .. reaction] .. "|r " or ""
			local pvpFlag = isPlayer and UnitIsPVP(unit) and format(" |cffff0000%s|r", PVP) or ""
			local unitClass = isPlayer and format("%s %s", UnitRace(unit) or "", hexColor .. (UnitClass(unit) or "") .. "|r") or UnitCreatureType(unit) or ""

			tiptextLevel:SetFormattedText("%s%s %s %s", textLevel, pvpFlag, standingText .. unitClass, (not alive and "|cffCCCCCC" .. DEAD .. "|r" or ""))
		end
	end

	if UnitExists(unit .. "target") then
		local tarRicon = GetRaidTargetIndex(unit .. "target")
		if tarRicon and tarRicon > 8 then
			tarRicon = nil
		end
		local tar = format("%s%s", (tarRicon and ICON_LIST[tarRicon] .. "10|t") or "", Module:GetTarget(unit .. "target"))
		self:AddLine(TARGET .. ": " .. tar)
	end

	if not isPlayer and isShiftKeyDown then
		local npcID = K.GetNPCID(guid)
		if npcID then
			self:AddLine(format(npcIDstring, "NpcID:", npcID))
		end
	end

	if isPlayer then
		Module.InspectUnitItemLevel(self, unit)
		Module.ShowUnitMythicPlusScore(self, unit)
	end
	Module.ScanTargets(self, unit)
	Module.CreatePetInfo(self, unit)
end

function Module:RefreshStatusBar(value)
	if not self.text then
		self.text = K.CreateFontString(self, 11, nil, "")
	end
	local unit = self.guid and UnitTokenFromGUID(self.guid)
	local unitHealthMax = unit and UnitHealthMax(unit)
	if unitHealthMax and unitHealthMax ~= 0 then
		self.text:SetText(K.ShortValue(value * unitHealthMax) .. " - " .. K.ShortValue(unitHealthMax))
		self:SetStatusBarColor(K.UnitColor(unit))
	else
		self.text:SetFormattedText("%d%%", value * 100)
	end
end

function Module:ReskinStatusBar()
	self.StatusBar:ClearAllPoints()
	self.StatusBar:SetPoint("BOTTOMLEFT", self.bg, "TOPLEFT", 0, 6)
	self.StatusBar:SetPoint("BOTTOMRIGHT", self.bg, "TOPRIGHT", -0, 6)
	self.StatusBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.StatusBar:SetHeight(11)
	self.StatusBar:CreateBorder()
end

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
function Module:GameTooltip_SetDefaultAnchor(parent)
	if self:IsForbidden() then
		return
	end
	if not parent then
		return
	end

	local mode = C["Tooltip"].CursorMode.Value
	self:SetOwner(parent, cursorIndex[mode])
	if mode == 1 then
		if not mover then
			mover = K.Mover(self, "Tooltip", "GameTooltip", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -230, 38 }, 100, 100)
		end
		self:ClearAllPoints()
		self:SetPoint(anchorIndex[C["Tooltip"].TipAnchor.Value], mover)
	end
end

-- Tooltip skin
function Module:ReskinTooltip()
	if not self then
		if K.isDeveloper then
			print("Unknown tooltip spotted.")
		end
		return
	end
	if self:IsForbidden() then
		return
	end

	if not self.tipStyled then
		self:HideBackdrop()
		self:DisableDrawLayer("BACKGROUND")
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
		local link = data.guid and C_Item.GetItemLinkByGUID(data.guid) or data.hyperlink
		if link then
			local quality = select(3, C_Item.GetItemInfo(link))
			local color = K.QualityColors[quality or 1]
			if color then
				self.bg.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end
end

function Module:FixRecipeItemNameWidth()
	if not self.GetName then
		return
	end

	local name = self:GetName()
	for i = 1, self:NumLines() do
		local line = _G[name .. "TextLeft" .. i]
		if line and line:GetHeight() > 40 then
			line:SetWidth(line:GetWidth() + 2)
		end
	end
end

function Module:ResetUnit(btn)
	if btn == "LSHIFT" and UnitExists("mouseover") then
		GameTooltip:RefreshData()
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

--	Fix compare tooltips(by Blizzard)(../FrameXML/GameTooltip.lua)
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

function Module:OnEnable()
	GameTooltip:HookScript("OnTooltipCleared", Module.OnTooltipCleared)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, Module.OnTooltipSetUnit)
	hooksecurefunc(GameTooltip.StatusBar, "SetValue", Module.RefreshStatusBar)
	TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, Module.UpdateFactionLine)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, Module.FixRecipeItemNameWidth)

	hooksecurefunc("GameTooltip_ShowStatusBar", Module.GameTooltip_ShowStatusBar)
	hooksecurefunc("GameTooltip_ShowProgressBar", Module.GameTooltip_ShowProgressBar)
	hooksecurefunc("GameTooltip_SetDefaultAnchor", Module.GameTooltip_SetDefaultAnchor)
	hooksecurefunc(TooltipComparisonManager, "AnchorShoppingTooltips", Module.AnchorShoppingTooltips)
	Module:FixStoneSoupError()

	-- Elements
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

-- Tooltip Skin Registration
local tipTable = {}
function Module:RegisterTooltips(addon, func)
	tipTable[addon] = func
end
local function addonStyled(_, addon)
	if tipTable[addon] then
		tipTable[addon]()
		tipTable[addon] = nil
	end
end
K:RegisterEvent("ADDON_LOADED", addonStyled)

Module:RegisterTooltips("KkthnxUI", function()
	local tooltips = {
		ChatMenu,
		EmoteMenu,
		LanguageMenu,
		VoiceMacroMenu,
		GameTooltip,
		EmbeddedItemTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ShoppingTooltip1,
		ShoppingTooltip2,
		AutoCompleteBox,
		FriendsTooltip,
		QuestScrollFrame.StoryTooltip,
		QuestScrollFrame.CampaignTooltip,
		GeneralDockManagerOverflowButtonList,
		ReputationParagonTooltip,
		NamePlateTooltip,
		QueueStatusFrame,
		FloatingGarrisonFollowerTooltip,
		FloatingGarrisonFollowerAbilityTooltip,
		FloatingGarrisonMissionTooltip,
		GarrisonFollowerAbilityTooltip,
		GarrisonFollowerTooltip,
		FloatingGarrisonShipyardFollowerTooltip,
		GarrisonShipyardFollowerTooltip,
		BattlePetTooltip,
		PetBattlePrimaryAbilityTooltip,
		PetBattlePrimaryUnitTooltip,
		FloatingBattlePetTooltip,
		FloatingPetBattleAbilityTooltip,
		IMECandidatesFrame,
		QuickKeybindTooltip,
		GameSmallHeaderTooltip,
	}
	for _, f in pairs(tooltips) do
		f:HookScript("OnShow", Module.ReskinTooltip)
	end

	ItemRefTooltip.CloseButton:SkinCloseButton()
	FloatingBattlePetTooltip.CloseButton:SkinCloseButton()
	FloatingPetBattleAbilityTooltip.CloseButton:SkinCloseButton()

	if SettingsTooltip then
		Module.ReskinTooltip(SettingsTooltip)
		SettingsTooltip:SetScale(UIParent:GetScale())
	end

	-- DropdownMenu
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

	-- IME
	local r, g, b = K.r, K.g, K.b
	IMECandidatesFrame.selection:SetVertexColor(r, g, b)

	-- Pet Tooltip
	PetBattlePrimaryUnitTooltip:HookScript("OnShow", function(self)
		self.Border:SetAlpha(0)
		if not self.iconStyled then
			if self.glow then
				self.glow:Hide()
			end
			self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			self.iconStyled = true
		end
	end)

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

	-- Others
	C_Timer.After(5, function()
		-- BagSync
		if BSYC_EventAlertTooltip then
			Module.ReskinTooltip(BSYC_EventAlertTooltip)
		end
		-- Libs
		if LibDBIconTooltip then
			Module.ReskinTooltip(LibDBIconTooltip)
		end
		if AceConfigDialogTooltip then
			Module.ReskinTooltip(AceConfigDialogTooltip)
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
		-- Altoholic
		if AltoTooltip then
			Module.ReskinTooltip(AltoTooltip)
		end
	end)

	if C_AddOns.IsAddOnLoaded("BattlePetBreedID") then
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
		local styledMDT
		hooksecurefunc(MDT, "ShowInterface", function()
			if not styledMDT then
				Module.ReskinTooltip(MDT.tooltip)
				Module.ReskinTooltip(MDT.pullTooltip)
				styledMDT = true
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
	local gt = {
		GarrisonMissionMechanicTooltip,
		GarrisonMissionMechanicFollowerCounterTooltip,
		GarrisonShipyardMapMissionTooltip,
		GarrisonBonusAreaTooltip,
		GarrisonBuildingFrame.BuildingLevelTooltip,
		GarrisonFollowerAbilityWithoutCountersTooltip,
		GarrisonFollowerMissionAbilityWithoutCountersTooltip,
	}
	for _, f in pairs(gt) do
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
