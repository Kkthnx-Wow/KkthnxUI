--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Adds profession-specific tabs to the trade skill frame for quick switching.
-- - Design: Dynamically scans the player's profession book and creates secure action buttons on the ProfessionsFrame.
-- - Events: TRADE_SKILL_SHOW, TRADE_SKILL_CLOSE, CURRENT_SPELL_CAST_CHANGED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local pairs = _G.pairs
local select = _G.select
local string_match = _G.string.match
local table_insert = _G.table.insert
local unpack = _G.unpack

local _G = _G
local C_Item_GetItemCooldown = _G.C_Item.GetItemCooldown
local C_Item_GetItemCount = _G.C_Item.GetItemCount
local C_Item_GetItemIconByID = _G.C_Item.GetItemIconByID
local C_Item_GetItemNameByID = _G.C_Item.GetItemNameByID
local C_SpellBook_GetSpellBookItemInfo = _G.C_SpellBook.GetSpellBookItemInfo
local C_Spell_GetSpellCooldown = _G.C_Spell.GetSpellCooldown
local C_Spell_GetSpellName = _G.C_Spell.GetSpellName
local C_Spell_GetSpellTexture = _G.C_Spell.GetSpellTexture
local C_Spell_IsCurrentSpell = _G.C_Spell.IsCurrentSpell
local C_ToyBox_GetToyInfo = _G.C_ToyBox.GetToyInfo
local C_TradeSkillUI_GetOnlyShowMakeableRecipes = _G.C_TradeSkillUI.GetOnlyShowMakeableRecipes
local C_TradeSkillUI_GetOnlyShowSkillUpRecipes = _G.C_TradeSkillUI.GetOnlyShowSkillUpRecipes
local C_TradeSkillUI_SetOnlyShowMakeableRecipes = _G.C_TradeSkillUI.SetOnlyShowMakeableRecipes
local C_TradeSkillUI_SetOnlyShowSkillUpRecipes = _G.C_TradeSkillUI.SetOnlyShowSkillUpRecipes
local CreateFrame = _G.CreateFrame
local GetProfessionInfo = _G.GetProfessionInfo
local GetProfessions = _G.GetProfessions
local HookSecureFunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local IsPlayerSpell = _G.IsPlayerSpell
local PlayerHasToy = _G.PlayerHasToy

-- SG: Constants
local BOOKTYPE_PROFESSION = _G.BOOKTYPE_PROFESSION or 0
local RUNEFORGING_SPELL_ID = 53428
local PICK_LOCK_SPELL_ID = 1804
local CHEF_HAT_ITEM_ID = 134020
local THERMAL_ANVIL_ITEM_ID = 87216

local tradeTabList = {}
local PRIMARY_PROFESSION_MAP = {
	[171] = true, -- Alchemy
	[182] = true, -- Herbalism
	[186] = true, -- Mining
	[202] = true, -- Engineering
	[356] = true, -- Fishing
	[393] = true, -- Skinning
}

function Module:updateProfessionData()
	local firstProfession, secondProfession, _, fishingProfession, cookingProfession = GetProfessions()
	local professionTable = { firstProfession, secondProfession, fishingProfession, cookingProfession }

	if K.Class == "DEATHKNIGHT" then
		Module:createNewTradeTab(RUNEFORGING_SPELL_ID)
	elseif K.Class == "ROGUE" and IsPlayerSpell(PICK_LOCK_SPELL_ID) then
		Module:createNewTradeTab(PICK_LOCK_SPELL_ID)
	end

	local hasCookingProfession = false
	for _, professionIndex in pairs(professionTable) do
		local _, _, _, _, spellCount, spellOffsetIndex, professionID = GetProfessionInfo(professionIndex)
		if professionID == 185 then
			hasCookingProfession = true
		end

		spellCount = PRIMARY_PROFESSION_MAP[professionID] and 1 or spellCount
		if spellCount > 0 then
			for i = 1, spellCount do
				local bookSlotID = i + spellOffsetIndex
				local spellBookInfo = C_SpellBook_GetSpellBookItemInfo(bookSlotID, BOOKTYPE_PROFESSION)
				if not spellBookInfo.isPassive then
					Module:createNewTradeTab(spellBookInfo.spellID)
				end
			end
		end
	end

	-- REASON: Adds specialized cooking/utility items as tabs if the player has them in their inventory or toybox.
	if hasCookingProfession and PlayerHasToy(CHEF_HAT_ITEM_ID) then
		Module:createNewTradeTab(nil, CHEF_HAT_ITEM_ID)
	end
	if C_Item_GetItemCount(THERMAL_ANVIL_ITEM_ID) > 0 then
		Module:createNewTradeTab(nil, nil, THERMAL_ANVIL_ITEM_ID)
	end
end

function Module:updateTradeTabsState()
	for _, tradeTab in pairs(tradeTabList) do
		local professionSpellID = tradeTab.spellID
		local itemIDValue = tradeTab.itemID

		if professionSpellID and C_Spell_IsCurrentSpell(professionSpellID) then
			tradeTab:SetChecked(true)
			tradeTab.cover:Show()
		else
			tradeTab:SetChecked(false)
			tradeTab.cover:Hide()
		end

		local cooldownStart, cooldownDuration
		if itemIDValue then
			cooldownStart, cooldownDuration = C_Item_GetItemCooldown(itemIDValue)
		elseif professionSpellID then
			local cooldownData = C_Spell_GetSpellCooldown(professionSpellID)
			cooldownStart = cooldownData and cooldownData.startTime
			cooldownDuration = cooldownData and cooldownData.duration
		end

		if cooldownStart and cooldownDuration and cooldownDuration > 1.5 then
			tradeTab.CD:SetCooldown(cooldownStart, cooldownDuration)
		end
	end
end

function Module:applyTradeTabSkins()
	for _, tradeTab in pairs(tradeTabList) do
		tradeTab:CreateBorder()
		tradeTab:StyleButton()
		local normalTexture = tradeTab:GetNormalTexture()
		if normalTexture then
			normalTexture:SetTexCoord(unpack(K.TexCoords))
		end
	end
end

local tradeTabIndex = 1
function Module:createNewTradeTab(professionSpellID, toyIDValue, itemIDValue)
	local tabName, tradeTabTexture
	if toyIDValue then
		_, tabName, tradeTabTexture = C_ToyBox_GetToyInfo(toyIDValue)
	elseif itemIDValue then
		tabName, tradeTabTexture = C_Item_GetItemNameByID(itemIDValue), C_Item_GetItemIconByID(itemIDValue)
	else
		tabName, tradeTabTexture = C_Spell_GetSpellName(professionSpellID), C_Spell_GetSpellTexture(professionSpellID)
	end

	if not tabName then
		return
	end

	local professionsFrame = _G.ProfessionsFrame
	local tradeTab = CreateFrame("CheckButton", nil, professionsFrame, "SecureActionButtonTemplate")
	tradeTab:SetSize(32, 32)
	tradeTab.tooltip = tabName
	tradeTab.spellID = professionSpellID
	tradeTab.itemID = toyIDValue or itemIDValue
	tradeTab.type = (toyIDValue and "toy") or (itemIDValue and "item") or "spell"
	tradeTab:RegisterForClicks("AnyUp", "AnyDown")

	if professionSpellID == 818 then -- SG: Cooking Fire macro support
		tradeTab:SetAttribute("type", "macro")
		tradeTab:SetAttribute("macrotext", "/cast [@player]" .. tabName)
	else
		tradeTab:SetAttribute("type", tradeTab.type)
		tradeTab:SetAttribute(tradeTab.type, professionSpellID or tabName)
	end
	tradeTab:SetNormalTexture(tradeTabTexture)
	tradeTab:Show()

	tradeTab.CD = CreateFrame("Cooldown", nil, tradeTab, "CooldownFrameTemplate")
	tradeTab.CD:SetAllPoints()

	tradeTab.cover = CreateFrame("Frame", nil, tradeTab)
	tradeTab.cover:SetAllPoints()
	tradeTab.cover:EnableMouse(true)

	tradeTab:SetPoint("TOPLEFT", professionsFrame, "TOPRIGHT", 6, -tradeTabIndex * 40)
	table_insert(tradeTabList, tradeTab)
	tradeTabIndex = tradeTabIndex + 1
end

function Module:setupTradeSkillFilterIcons()
	local filterButtonData = {
		[1] = { "Atlas:bags-greenarrow", _G.TRADESKILL_FILTER_HAS_SKILL_UP, C_TradeSkillUI_GetOnlyShowSkillUpRecipes, C_TradeSkillUI_SetOnlyShowSkillUpRecipes },
		[2] = { "Interface\\RAIDFRAME\\ReadyCheck-Ready", _G.CRAFT_IS_MAKEABLE, C_TradeSkillUI_GetOnlyShowMakeableRecipes, C_TradeSkillUI_SetOnlyShowMakeableRecipes },
	}

	local function onFilterClick(clickedButton)
		local valueData = clickedButton.__value
		if valueData[3]() then
			valueData[4](false)
			K.SetBorderColor(clickedButton.KKUI_Border)
		else
			valueData[4](true)
			clickedButton.KKUI_Border:SetVertexColor(1, 0.8, 0)
		end
	end

	local filterButtons = {}
	local recipesFrame = _G.ProfessionsFrame.CraftingPage.RecipeList
	for index, valueData in pairs(filterButtonData) do
		local filterButton = CreateFrame("Button", nil, recipesFrame, "BackdropTemplate")
		filterButton:SetSize(22, 22)
		filterButton:SetPoint("BOTTOMRIGHT", recipesFrame.FilterDropdown, "TOPRIGHT", -(index - 1) * 28 + 6, 10)
		filterButton:CreateBorder()

		filterButton.Icon = filterButton:CreateTexture(nil, "ARTWORK")
		local atlasName = string_match(valueData[1], "Atlas:(.+)$")
		if atlasName then
			filterButton.Icon:SetAtlas(atlasName)
		else
			filterButton.Icon:SetTexture(valueData[1])
		end

		filterButton.Icon:SetPoint("TOPLEFT", filterButton, "TOPLEFT", 2, -2)
		filterButton.Icon:SetPoint("BOTTOMRIGHT", filterButton, "BOTTOMRIGHT", -2, 2)
		filterButton.Icon:SetTexCoord(_G.unpack(K.TexCoords))
		K.AddTooltip(filterButton, "ANCHOR_TOP", valueData[2])
		filterButton.__value = valueData
		filterButton:SetScript("OnClick", onFilterClick)

		filterButtons[index] = filterButton
	end

	local function updateFilterIconStatus()
		for index, valueData in pairs(filterButtonData) do
			if valueData[3]() then
				filterButtons[index].KKUI_Border:SetVertexColor(1, 0.8, 0)
			else
				K.SetBorderColor(filterButtons[index].KKUI_Border)
			end
		end
	end
	K:RegisterEvent("TRADE_SKILL_LIST_UPDATE", updateFilterIconStatus)
end

local isModuleInitialized
function Module:onTradeTabsModuleLoad()
	isModuleInitialized = true

	Module:updateProfessionData()
	Module:applyTradeTabSkins()
	Module:updateTradeTabsState()

	K:RegisterEvent("TRADE_SKILL_SHOW", Module.updateTradeTabsState)
	K:RegisterEvent("TRADE_SKILL_CLOSE", Module.updateTradeTabsState)
	K:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.updateTradeTabsState)

	Module:setupTradeSkillFilterIcons()
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.onTradeTabsModuleLoad)
end

local function loadTradeTabsModuleNow()
	if isModuleInitialized then
		return
	end

	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.onTradeTabsModuleLoad)
	else
		Module:onTradeTabsModuleLoad()
	end
end

function Module:createImprovedTradeTabs()
	if not C["Misc"].TradeTabs then
		return
	end

	local professionsFrame = _G.ProfessionsFrame
	if professionsFrame then
		professionsFrame:HookScript("OnShow", loadTradeTabsModuleNow)
	else
		K:RegisterEvent("ADDON_LOADED", function(_, addonName)
			if addonName == "Blizzard_Professions" then
				loadTradeTabsModuleNow()
			end
		end)
	end
end

Module:RegisterMisc("TradeTabs", Module.createImprovedTradeTabs)
