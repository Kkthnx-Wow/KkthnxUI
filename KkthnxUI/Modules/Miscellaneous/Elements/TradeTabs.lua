local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- General Lua functions
local pairs = pairs
local tinsert = tinsert
local select = select

-- WoW API functions related to spells and items
local IsPlayerSpell = IsPlayerSpell

-- WoW API functions related to professions and trade skills
local GetProfessions = GetProfessions
local GetProfessionInfo = GetProfessionInfo
local PlayerHasToy = PlayerHasToy

-- Cache WoW C API functions
local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo
local C_TradeSkillUI_GetOnlyShowSkillUpRecipes = C_TradeSkillUI.GetOnlyShowSkillUpRecipes
local C_TradeSkillUI_SetOnlyShowSkillUpRecipes = C_TradeSkillUI.SetOnlyShowSkillUpRecipes
local C_TradeSkillUI_GetOnlyShowMakeableRecipes = C_TradeSkillUI.GetOnlyShowMakeableRecipes
local C_TradeSkillUI_SetOnlyShowMakeableRecipes = C_TradeSkillUI.SetOnlyShowMakeableRecipes
local C_Item_GetItemCount = C_Item.GetItemCount
local C_Item_GetItemCooldown = C_Item.GetItemCooldown
local C_Item_GetItemIconByID = C_Item.GetItemIconByID
local C_Spell_GetSpellBookItemInfo = C_SpellBook.GetSpellBookItemInfo
local C_Spell_GetSpellName = C_Spell.GetSpellName
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
local C_Spell_IsCurrentSpell = C_Spell.IsCurrentSpell

local BOOKTYPE_PROFESSION = BOOKTYPE_PROFESSION or 0
local RUNEFORGING_ID = 53428
local PICK_LOCK = 1804
local CHEF_HAT = 134020
local THERMAL_ANVIL = 87216
local tabList = {}

local onlyPrimary = {
	[171] = true, -- Alchemy
	[182] = true, -- Herbalism
	[186] = true, -- Mining
	[202] = true, -- Engineering
	[356] = true, -- Fishing
	[393] = true, -- Skinning
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
				if not C_Spell_GetSpellBookItemInfo(slotID, BOOKTYPE_PROFESSION).isPassive then
					local spellID = C_Spell_GetSpellBookItemInfo(slotID, BOOKTYPE_PROFESSION).spellID
					Module:TradeTabs_Create(spellID)
				end
			end
		end
	end

	if isCook and PlayerHasToy(CHEF_HAT) then
		Module:TradeTabs_Create(nil, CHEF_HAT)
	end
	if C_Item_GetItemCount(THERMAL_ANVIL) > 0 then
		Module:TradeTabs_Create(nil, nil, THERMAL_ANVIL)
	end
end

function Module:TradeTabs_Update()
	for _, tab in pairs(tabList) do
		local spellID = tab.spellID
		local itemID = tab.itemID

		if spellID and C_Spell_IsCurrentSpell(spellID) then
			tab:SetChecked(true)
			tab.cover:Show()
		else
			tab:SetChecked(false)
			tab.cover:Hide()
		end

		local start, duration
		if itemID then
			start, duration = C_Item_GetItemCooldown(itemID)
		else
			local cooldownInfo = C_Spell_GetSpellCooldown(spellID)
			start = cooldownInfo and cooldownInfo.startTime
			duration = cooldownInfo and cooldownInfo.duration
		end

		if start and duration and duration > 1.5 then
			tab.CD:SetCooldown(start, duration)
		end
	end
end

function Module:TradeTabs_Reskin()
	for _, tab in pairs(tabList) do
		tab:CreateBorder()
		tab:StyleButton()
		local texture = tab:GetNormalTexture()
		if texture then
			texture:SetTexCoord(unpack(K.TexCoords))
		end
	end
end

local index = 1
function Module:TradeTabs_Create(spellID, toyID, itemID)
	local name, _, texture
	if toyID then
		_, name, texture = C_ToyBox_GetToyInfo(toyID)
	elseif itemID then
		name, texture = C_Item_GetItemNameByID(itemID), C_Item_GetItemIconByID(itemID)
	else
		name, texture = C_Spell_GetSpellName(spellID), C_Spell_GetSpellTexture(spellID)
	end

	if not name then -- precaution
		return
	end

	local tab = CreateFrame("CheckButton", nil, ProfessionsFrame, "SecureActionButtonTemplate")
	tab:SetSize(32, 32)
	tab.tooltip = name
	tab.spellID = spellID
	tab.itemID = toyID or itemID
	tab.type = (toyID and "toy") or (itemID and "item") or "spell"
	tab:RegisterForClicks("AnyUp", "AnyDown")
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

	tab:SetPoint("TOPLEFT", ProfessionsFrame, "TOPRIGHT", 6, -index * 40)
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
			K.SetBorderColor(self.KKUI_Border)
		else
			value[4](true)
			self.KKUI_Border:SetVertexColor(1, 0.8, 0)
		end
	end

	local buttons = {}
	for index, value in pairs(buttonList) do
		local bu = CreateFrame("Button", nil, ProfessionsFrame.CraftingPage.RecipeList, "BackdropTemplate")
		bu:SetSize(22, 22)
		-- bu:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterButton, "TOPRIGHT", -(index - 1) * 28, 10)
		bu:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown, "TOPRIGHT", -(index - 1) * 28 + 6, 10)
		bu:CreateBorder()
		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		local atlas = string.match(value[1], "Atlas:(.+)$")
		if atlas then
			bu.Icon:SetAtlas(atlas)
		else
			bu.Icon:SetTexture(value[1])
		end
		bu.Icon:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
		bu.Icon:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
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
				K.SetBorderColor(buttons[index].KKUI_Border)
			end
		end
	end
	K:RegisterEvent("TRADE_SKILL_LIST_UPDATE", updateFilterStatus)
end

local init
function Module:TradeTabs_OnLoad()
	init = true

	Module:UpdateProfessions()

	Module:TradeTabs_Reskin()
	Module:TradeTabs_Update()
	K:RegisterEvent("TRADE_SKILL_SHOW", Module.TradeTabs_Update)
	K:RegisterEvent("TRADE_SKILL_CLOSE", Module.TradeTabs_Update)
	K:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.TradeTabs_Update)

	Module:TradeTabs_FilterIcons()

	K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.TradeTabs_OnLoad)
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

function Module:CreateTradeTabs()
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

Module:RegisterMisc("TradeTabs", Module.CreateTradeTabs)
