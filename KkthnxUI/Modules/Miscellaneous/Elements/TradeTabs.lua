local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format
local table_insert = _G.table.insert
local unpack = _G.unpack

local BOOKTYPE_PROFESSION = _G.BOOKTYPE_PROFESSION
local C_ToyBox_GetToyInfo = _G.C_ToyBox.GetToyInfo
local C_ToyBox_IsToyUsable = _G.C_ToyBox.IsToyUsable
local C_TradeSkillUI_GetOnlyShowMakeableRecipes = _G.C_TradeSkillUI.GetOnlyShowMakeableRecipes
local C_TradeSkillUI_GetOnlyShowSkillUpRecipes = _G.C_TradeSkillUI.GetOnlyShowSkillUpRecipes
local C_TradeSkillUI_GetRecipeInfo = _G.C_TradeSkillUI.GetRecipeInfo
local C_TradeSkillUI_GetTradeSkillLine = _G.C_TradeSkillUI.GetTradeSkillLine
local C_TradeSkillUI_SetOnlyShowMakeableRecipes = _G.C_TradeSkillUI.SetOnlyShowMakeableRecipes
local C_TradeSkillUI_SetOnlyShowSkillUpRecipes = _G.C_TradeSkillUI.SetOnlyShowSkillUpRecipes
local CreateFrame = _G.CreateFrame
local GetItemCooldown = _G.GetItemCooldown
local GetItemCount = _G.GetItemCount
local GetItemInfo = _G.GetItemInfo
local GetProfessionInfo = _G.GetProfessionInfo
local GetProfessions = _G.GetProfessions
local GetSpellBookItemInfo = _G.GetSpellBookItemInfo
local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellInfo = _G.GetSpellInfo
local InCombatLockdown = _G.InCombatLockdown
local IsCurrentSpell = _G.IsCurrentSpell
local IsPassiveSpell = _G.IsPassiveSpell
local IsPlayerSpell = _G.IsPlayerSpell
local PlayerHasToy = _G.PlayerHasToy

local CHEF_HAT = 134020
local ENCHANTING_VELLUM = 38682
local PICK_LOCK = 1804
local RUNEFORGING_ID = 53428
local THERMAL_ANVIL = 87216
local index = 1
local isEnchanting
local tabList = {}
local tooltipString = "|cffffffff%s(%d)"

local onlyPrimary = {
	[171] = true, -- Alchemy
	[202] = true, -- Engineering
	[182] = true, -- Herbalism
	[393] = true, -- Skinning
	[356] = true, -- Fishing
}

function Module:UpdateProfessions()
	local prof1, prof2, _, fish, cook = GetProfessions()
	local profs = { prof1, prof2, fish, cook }

	if K.Class == "DEATHKNIGHT" then
		Module:TradeTabs_Create(RUNEFORGING_ID)
	elseif K.Class == "ROGUE" and IsPlayerSpell(PICK_LOCK) then
		Module:TradeTabs_Create(PICK_LOCK)
	end

	local isCook
	for _, prof in pairs(profs) do
		local _, _, _, _, numSpells, spelloffset, skillLine = GetProfessionInfo(prof)
		if skillLine == 185 then
			isCook = true
		end

		numSpells = onlyPrimary[skillLine] and 1 or numSpells
		if numSpells > 0 then
			for i = 1, numSpells do
				local slotID = i + spelloffset
				if not IsPassiveSpell(slotID, BOOKTYPE_PROFESSION) then
					local spellID = select(2, GetSpellBookItemInfo(slotID, BOOKTYPE_PROFESSION))
					if i == 1 then
						Module:TradeTabs_Create(spellID)
					else
						Module:TradeTabs_Create(spellID)
					end
				end
			end
		end
	end

	if isCook and PlayerHasToy(CHEF_HAT) and C_ToyBox_IsToyUsable(CHEF_HAT) then
		Module:TradeTabs_Create(nil, CHEF_HAT)
	end

	if GetItemCount(THERMAL_ANVIL) > 0 then
		Module:TradeTabs_Create(nil, nil, THERMAL_ANVIL)
	end
end

function Module:TradeTabs_Update()
	for _, tab in pairs(tabList) do
		local spellID = tab.spellID
		local itemID = tab.itemID

		if IsCurrentSpell(spellID) then
			tab:SetChecked(true)
			tab.cover:Show()
		else
			tab:SetChecked(false)
			tab.cover:Hide()
		end

		local start, duration
		if itemID then
			start, duration = GetItemCooldown(itemID)
		else
			start, duration = GetSpellCooldown(spellID)
		end
		if start and duration and duration > 1.5 then
			tab.CD:SetCooldown(start, duration)
		end
	end
end

function Module:TradeTabs_Reskin()
	for _, tab in pairs(tabList) do
		tab:GetRegions():Hide()
		tab:CreateBorder()

		local texture = tab:GetNormalTexture()
		if texture then
			texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		end
	end
end

function Module:TradeTabs_Create(spellID, toyID, itemID)
	local name, _, texture
	if toyID then
		_, name, texture = C_ToyBox_GetToyInfo(toyID)
	elseif itemID then
		name, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
	else
		name, _, texture = GetSpellInfo(spellID)
	end

	local tab = CreateFrame("CheckButton", nil, TradeSkillFrame, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	tab.tooltip = name
	tab.spellID = spellID
	tab.itemID = toyID or itemID
	tab.type = (toyID and "toy") or (itemID and "item") or "spell"
	if spellID == 818 then -- cooking fire
		tab:SetAttribute("type", "macro")
		tab:SetAttribute("macrotext", "/cast [@player]" .. name)
	else
		tab:SetAttribute("type", tab.type)
		tab:SetAttribute(tab.type, spellID or name)
	end
	tab:SetNormalTexture(texture)
	tab:Show()

	tab.CD = CreateFrame("Cooldown", nil, tab, "CooldownFrameTemplate")
	tab.CD:SetAllPoints()

	tab.cover = CreateFrame("Frame", nil, tab)
	tab.cover:SetAllPoints()
	tab.cover:EnableMouse(true)

	tab:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", 4, -index * 38)
	table_insert(tabList, tab)
	index = index + 1
end

function Module:TradeTabs_FilterIcons()
	local buttonList = {
		[1] = { "Atlas:bags-greenarrow", TRADESKILL_FILTER_HAS_SKILL_UP, C_TradeSkillUI_GetOnlyShowSkillUpRecipes, C_TradeSkillUI_SetOnlyShowSkillUpRecipes },
		[2] = { "Interface\\RAIDFRAME\\ReadyCheck-Ready", CRAFT_IS_MAKEABLE, C_TradeSkillUI_GetOnlyShowMakeableRecipes, C_TradeSkillUI_SetOnlyShowMakeableRecipes },
	}

	local function filterClick(self)
		local value = self.__value
		if value[3]() then
			value[4](false)
			self.KKUI_Border:SetVertexColor(1, 1, 1)
		else
			value[4](true)
			self.KKUI_Border:SetVertexColor(1, 0.8, 0)
		end
	end

	local buttons = {}
	for index, value in pairs(buttonList) do
		local bu = CreateFrame("Button", nil, TradeSkillFrame, "BackdropTemplate")
		bu:SetSize(18, 18)
		bu:SetPoint("RIGHT", TradeSkillFrame.FilterButton, "LEFT", -5 - (index - 1) * 24, 0)
		bu:CreateBorder()

		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		local atlas = string.match(value[1], "Atlas:(.+)$")
		if atlas then
			bu.Icon:SetAtlas(atlas)
		else
			bu.Icon:SetTexture(value[1])
		end

		K.AddTooltip(bu, "ANCHOR_TOP", value[2])
		bu.__value = value
		bu:SetScript("OnClick", filterClick)

		buttons[index] = bu
	end

	local function updateFilterStatus()
		for index, value in pairs(buttonList) do
			if value[3]() then
				buttons[index].KKUI_Border:SetVertexColor(1, 0.8, 0)
			else
				buttons[index].KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end
	end

	K:RegisterEvent("TRADE_SKILL_LIST_UPDATE", updateFilterStatus)
end

function Module:TradeTabs_OnLoad()
	Module:UpdateProfessions()

	Module:TradeTabs_Reskin()
	Module:TradeTabs_Update()
	K:RegisterEvent("TRADE_SKILL_SHOW", Module.TradeTabs_Update)
	K:RegisterEvent("TRADE_SKILL_CLOSE", Module.TradeTabs_Update)
	K:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.TradeTabs_Update)

	Module:TradeTabs_FilterIcons()
	Module:TradeTabs_QuickEnchanting()
end

function Module.TradeTabs_OnEvent(event, addon)
	if event == "ADDON_LOADED" and addon == "Blizzard_TradeSkillUI" then
		K:UnregisterEvent(event, Module.TradeTabs_OnEvent)

		if InCombatLockdown() then
			K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.TradeTabs_OnEvent)
		else
			Module:TradeTabs_OnLoad()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent(event, Module.TradeTabs_OnEvent)
		Module:TradeTabs_OnLoad()
	end
end

local function IsRecipeEnchanting(self)
	isEnchanting = nil

	local recipeID = self.selectedRecipeID
	local recipeInfo = recipeID and C_TradeSkillUI_GetRecipeInfo(recipeID)
	if recipeInfo and recipeInfo.alternateVerb then
		local parentSkillLineID = select(6, C_TradeSkillUI_GetTradeSkillLine())
		if parentSkillLineID == 333 then
			isEnchanting = true
			self.CreateButton.tooltip = string_format(tooltipString, "Right click to use vellum", GetItemCount(ENCHANTING_VELLUM))
		end
	end
end

function Module:TradeTabs_QuickEnchanting()
	if not TradeSkillFrame then
		return
	end

	local detailsFrame = TradeSkillFrame.DetailsFrame
	hooksecurefunc(detailsFrame, "RefreshDisplay", IsRecipeEnchanting)

	local createButton = detailsFrame.CreateButton
	createButton:RegisterForClicks("AnyUp")
	createButton:HookScript("OnClick", function(_, btn)
		if btn == "RightButton" and isEnchanting then
			UseItemByName(ENCHANTING_VELLUM)
		end
	end)
end

function Module:CreateTradeTabs()
	if not C["Misc"].TradeTabs then
		return
	end

	if K.CheckAddOnState("TradeSkillMaster") then
		return
	end

	K:RegisterEvent("ADDON_LOADED", Module.TradeTabs_OnEvent)
end

Module:RegisterMisc("TradeTabs", Module.CreateTradeTabs)
