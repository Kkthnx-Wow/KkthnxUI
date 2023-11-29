local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- Basic Lua functions
local pairs = pairs
local tinsert = tinsert
local select = select

-- Spell related functions
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local IsPassiveSpell = IsPassiveSpell
local IsCurrentSpell = IsCurrentSpell
local IsPlayerSpell = IsPlayerSpell
local GetSpellBookItemInfo = GetSpellBookItemInfo

-- Item related functions
local GetItemCooldown = GetItemCooldown
local GetItemCount = GetItemCount
local GetItemInfo = GetItemInfo
local UseItemByName = UseItemByName
local PlayerHasToy = PlayerHasToy

-- Toy Box functions
local C_ToyBox_IsToyUsable = C_ToyBox.IsToyUsable
local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo

-- Trade Skill UI functions
local C_TradeSkillUI_GetOnlyShowSkillUpRecipes = C_TradeSkillUI.GetOnlyShowSkillUpRecipes
local C_TradeSkillUI_SetOnlyShowSkillUpRecipes = C_TradeSkillUI.SetOnlyShowSkillUpRecipes
local C_TradeSkillUI_GetOnlyShowMakeableRecipes = C_TradeSkillUI.GetOnlyShowMakeableRecipes
local C_TradeSkillUI_SetOnlyShowMakeableRecipes = C_TradeSkillUI.SetOnlyShowMakeableRecipes

local BOOKTYPE_PROFESSION = BOOKTYPE_PROFESSION
local RUNEFORGING_ID = 53428
local PICK_LOCK = 1804
local CHEF_HAT = 134020
local THERMAL_ANVIL = 87216
local ENCHANTING_VELLUM = 38682
local tabList = {}

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

local index = 1
function Module:TradeTabs_Create(spellID, toyID, itemID)
	local name, _, texture
	if toyID then
		_, name, texture = C_ToyBox_GetToyInfo(toyID)
	elseif itemID then
		name, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
	else
		name, _, texture = GetSpellInfo(spellID)
	end
	if not name then
		return
	end -- precaution

	local tab = CreateFrame("CheckButton", nil, ProfessionsFrame, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	tab.tooltip = name
	tab.spellID = spellID
	tab.itemID = toyID or itemID
	tab.type = (toyID and "toy") or (itemID and "item") or "spell"
	tab:RegisterForClicks("AnyDown")
	if spellID == 818 then -- cooking fire
		tab:SetAttribute("type", "macro")
		tab:SetAttribute("macrotext", "/cast [@player]" .. name)
	else
		tab:SetAttribute("type", tab.type)
		tab:SetAttribute(tab.type, spellID or name)
	end
	tab:SetNormalTexture(texture)
	tab:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
	tab:Show()

	tab.CD = CreateFrame("Cooldown", nil, tab, "CooldownFrameTemplate")
	tab.CD:SetAllPoints()

	tab.cover = CreateFrame("Frame", nil, tab)
	tab.cover:SetAllPoints()
	tab.cover:EnableMouse(true)

	tab:SetPoint("TOPLEFT", ProfessionsFrame, "TOPRIGHT", 3, -index * 42)
	tinsert(tabList, tab)
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
		local bu = CreateFrame("Button", nil, ProfessionsFrame.CraftingPage, "BackdropTemplate")
		bu:SetSize(22, 22)
		bu:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterButton, "TOPRIGHT", -(index - 1) * 27, 10)
		bu:CreateBorder()
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		local atlas = string.match(value[1], "Atlas:(.+)$")
		if atlas then
			bu.Icon:SetAtlas(atlas)
		else
			bu.Icon:SetTexture(value[1])
		end
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
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

local init
function Module:TradeTabs_OnLoad()
	init = true

	Module:UpdateProfessions()

	Module:TradeTabs_Update()
	K:RegisterEvent("TRADE_SKILL_SHOW", Module.TradeTabs_Update)
	K:RegisterEvent("TRADE_SKILL_CLOSE", Module.TradeTabs_Update)
	K:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.TradeTabs_Update)

	Module:TradeTabs_FilterIcons()
	Module:TradeTabs_QuickEnchanting()

	K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.TradeTabs_OnLoad)
end

local isEnchanting
local tooltipString = "|cffffffff%s(%d)"
function Module:TradeTabs_QuickEnchanting()
	if ProfessionsFrame.CraftingPage.ValidateControls then
		hooksecurefunc(ProfessionsFrame.CraftingPage, "ValidateControls", function(self)
			isEnchanting = nil
			local currentRecipeInfo = self.SchematicForm:GetRecipeInfo()
			if currentRecipeInfo and currentRecipeInfo.alternateVerb then
				local professionInfo = ProfessionsFrame:GetProfessionInfo()
				if professionInfo and professionInfo.parentProfessionID == 333 then
					isEnchanting = true
					self.CreateButton.tooltipText = format(tooltipString, "Right click to use Vellum", GetItemCount(ENCHANTING_VELLUM))
				end
			end
		end)
	end

	local createButton = ProfessionsFrame.CraftingPage.CreateButton
	createButton:RegisterForClicks("AnyUp")
	createButton:HookScript("OnClick", function(_, btn)
		if btn == "RightButton" and isEnchanting then
			UseItemByName(ENCHANTING_VELLUM)
		end
	end)
end

local function LoadTradeTabs()
	if init then
		return
	end
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.TradeTabs_OnLoad)
	else
		Module:TradeTabs_OnLoad()
	end
end

function Module:TradeTabs()
	if not C["Misc"].TradeTabs then
		return
	end

	if ProfessionsFrame then
		ProfessionsFrame:HookScript("OnShow", LoadTradeTabs)
	else
		K:RegisterEvent("ADDON_LOADED", function(_, addon)
			if addon == "Blizzard_Professions" then
				LoadTradeTabs()
			end
		end)
	end
end
Module:RegisterMisc("TradeTabs", Module.TradeTabs)
