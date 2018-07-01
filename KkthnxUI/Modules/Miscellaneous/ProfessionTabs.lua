local K, C, L = unpack(select(2, ...))
if K.CheckAddOnState("TradeSkillMaster_Crafting") then
	return
end

local Module = K:NewModule("ProfessionTabs", "AceEvent-3.0")

local _G = _G
local next = next
local string_format = string.format

local CreateFrame = _G.CreateFrame
local GetProfessionInfo = _G.GetProfessionInfo
local GetProfessions = _G.GetProfessions
local GetSpellBookItemName = _G.GetSpellBookItemName
local GetSpellBookItemTexture = _G.GetSpellBookItemTexture
local GetSpellInfo = _G.GetSpellInfo
local InCombatLockdown = _G.InCombatLockdown
local IsCurrentSpell = _G.IsCurrentSpell
local IsSpellKnown = _G.IsSpellKnown
local PlayerHasToy = _G.PlayerHasToy

local ranks = PROFESSION_RANKS
local tabs, spells = {}, {}

local defaults = {
	-- Primary Professions
	[164] = {true, false}, -- Blacksmithing
	[165] = {true, false}, -- Leatherworking
	[171] = {true, false}, -- Alchemy
	[182] = {false, false}, -- Herbalism
	[186] = {true, false}, -- Mining
	[197] = {true, false}, -- Tailoring
	[202] = {true, false}, -- Engineering
	[333] = {true, true}, -- Enchanting
	[393] = {false, false}, -- Skinning
	[755] = {true, true}, -- Jewelcrafting
	[773] = {true, true}, -- Inscription
	-- Secondary Professions
	[129] = {true, false}, -- First Aid
	[185] = {true, true}, -- Cooking
	[356] = {false, false}, -- Fishing
	[794] = {false, false} -- Archaeology
}

if K.Class == "DEATHKNIGHT" then
	spells[#spells + 1] = 53428 -- Runeforging
end

if K.Class == "ROGUE" then
	spells[#spells + 1] = 1804 -- Pick Lock
end

local function UpdateSelectedTabs(object)
	Module:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
	for index = 1, #tabs[object] do
		local tab = tabs[object][index]
		tab:SetChecked(IsCurrentSpell(tab.name))
	end
end

local function ResetTabs(object)
	for index = 1, #tabs[object] do
		tabs[object][index]:Hide()
	end

	tabs[object].index = 0
end

local function UpdateTab(object, name, rank, texture, hat)
	local index = tabs[object].index + 1
	local tab =
		tabs[object][index] or
		CreateFrame(
			"CheckButton",
			"ProTabs" .. tabs[object].index,
			object,
			"SpellBookSkillLineTabTemplate SecureActionButtonTemplate"
		)

	tab:ClearAllPoints()

	tab:SetPoint("TOPLEFT", object, "TOPRIGHT", 0, (-44 * index) + 18)
	tab:SetNormalTexture(texture)

	if hat then
		tab:SetAttribute("type", "toy")
		tab:SetAttribute("toy", 134020)
	else
		tab:SetAttribute("type", "spell")
		tab:SetAttribute("spell", name)
	end

	tab:Show()

	tab.name = name
	tab.tooltip = rank and rank ~= "" and string_format("%s (%s)", name, rank) or name

	tabs[object][index] = tabs[object][index] or tab
	tabs[object].index = tabs[object].index + 1
end

local function GetProfessionRank(currentSkill)
	if currentSkill <= 74 then
		return APPRENTICE
	end

	for index = #ranks, 1, -1 do
		local requiredSkill, title = ranks[index][1], ranks[index][2]

		if currentSkill >= requiredSkill then
			return title
		end
	end
end

local function HandleProfession(object, professionID, hat)
	if professionID then
		local _, _, currentSkill, _, numAbilities, offset, skillID = GetProfessionInfo(professionID)

		if defaults[skillID] then
			for index = 1, numAbilities do
				if defaults[skillID][index] then
					local name = GetSpellBookItemName(offset + index, "profession")
					local rank = GetProfessionRank(currentSkill)
					local texture = GetSpellBookItemTexture(offset + index, "profession")

					if name and rank and texture then
						UpdateTab(object, name, rank, texture)
					end
				end
			end
		end

		if hat and PlayerHasToy(134020) then
			UpdateTab(object, GetSpellInfo(67556), nil, 236571, true)
		end
	end
end

local function HandleTabs(object)
	tabs[object] = tabs[object] or {}

	if InCombatLockdown() then
		Module:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		local firstProfession, secondProfession, archaeology, fishing, cooking, firstAid = GetProfessions()

		ResetTabs(object)

		HandleProfession(object, firstProfession)
		HandleProfession(object, secondProfession)
		HandleProfession(object, archaeology)
		HandleProfession(object, fishing)
		HandleProfession(object, cooking, true)
		HandleProfession(object, firstAid)

		for index = 1, #spells do
			if IsSpellKnown(spells[index]) then
				local name, rank, texture = GetSpellInfo(spells[index])
				UpdateTab(object, name, rank, texture)
			end
		end
	end

	UpdateSelectedTabs(object)
end

function Module:TRADE_SKILL_SHOW(event)
	local owner = ATSWFrame or MRTSkillFrame or SkilletFrame or TradeSkillFrame

	if K.CheckAddOnState("TradeSkillDW") and owner == TradeSkillFrame then
		self:UnregisterEvent(event)
	else
		HandleTabs(owner)
		self[event] = function()
			for object in next, tabs do
				UpdateSelectedTabs(object)
			end
		end
	end
end

function Module:TRADE_SKILL_CLOSE(event)
	for object in next, tabs do
		if object:IsShown() then
			UpdateSelectedTabs(object)
		end
	end
end

function Module:TRADE_SHOW(event)
	local owner = TradeFrame

	HandleTabs(owner)
	self[event] = function()
		UpdateSelectedTabs(owner)
	end
end

function Module:PLAYER_REGEN_ENABLED(event)
	self:UnregisterEvent(event)

	for object in next, tabs do
		HandleTabs(object)
	end
end

function Module:SKILL_LINES_CHANGED()
	for object in next, tabs do
		HandleTabs(object)
	end
end

function Module:CURRENT_SPELL_CAST_CHANGED(event)
	local numShown = 0

	for object in next, tabs do
		if object:IsShown() then
			numShown = numShown + 1
			UpdateSelectedTabs(object)
		end
	end

	if numShown == 0 then
		self:UnregisterEvent(event)
	end
end

function Module:OnInitialize()
	-- if C["Misc"].ProfessionTabs ~= true then return end

	self:RegisterEvent("TRADE_SKILL_SHOW")
	self:RegisterEvent("TRADE_SKILL_CLOSE")
	self:RegisterEvent("TRADE_SHOW")
	self:RegisterEvent("SKILL_LINES_CHANGED")
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
end
