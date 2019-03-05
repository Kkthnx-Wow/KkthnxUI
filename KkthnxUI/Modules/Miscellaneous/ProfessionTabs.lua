local K, C = unpack(select(2, ...))
if K.CheckAddOnState("TradeSkillMaster") then
	return
end

local Module = CreateFrame("Frame")

local _G = _G
local table_insert = table.insert

local BOOKTYPE_PROFESSION = _G.BOOKTYPE_PROFESSION
local C_ToyBox_GetToyInfo = _G.C_ToyBox.GetToyInfo
local C_ToyBox_IsToyUsable = _G.C_ToyBox.IsToyUsable
local CreateFrame = _G.CreateFrame
local GetItemCooldown = _G.GetItemCooldown
local GetProfessionInfo = _G.GetProfessionInfo
local GetProfessions = _G.GetProfessions
local GetSpellBookItemInfo = _G.GetSpellBookItemInfo
local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellInfo = _G.GetSpellInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsCurrentSpell = _G.IsCurrentSpell
local IsPassiveSpell = _G.IsPassiveSpell
local PlayerHasToy = _G.PlayerHasToy

local whitelist = {
	[129] = true, -- First Aid
	[164] = true, -- Blacksmithing
	[165] = true, -- Leatherworking
	[171] = true, -- Alchemy
	[182] = true, -- Herbalism
	[185] = true, -- Cooking
	[186] = true, -- Mining
	[197] = true, -- Tailoring
	[202] = true, -- Engineering
	[333] = true, -- Enchanting
	[356] = true, -- Fishing
	[393] = true, -- Skinning
	[755] = true, -- Jewelcrafting
	[773] = true, -- Inscription
}

local onlyPrimary = {
	[171] = true, -- Alchemy
	[182] = true, -- Herbalism
	[202] = true, -- Engineering
	[356] = true, -- Fishing
	[393] = true, -- Skinning
}

local RUNEFORGING = 53428 -- Runeforging spellid
local CHEF_HAT = 134020

function Module:OnEvent(event, addon)
	if not C["Misc"].ProfessionTabs then
		return
	end

	if event == "ADDON_LOADED" and addon == "Blizzard_TradeSkillUI" then
		self:UnregisterEvent(event)
		if InCombatLockdown() then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:Initialize()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent(event)
		self:Initialize()
	end
end

local function buildSpellList()
	local p1, p2, _, fishing, cooking = GetProfessions()
	local profs = {p1, p2, cooking, fishing}
	local tradeSpells = {}
	local extras = 0

	for _, prof in pairs(profs) do
		local _, _, _, _, abilities, offset, skillLine = GetProfessionInfo(prof)
		if whitelist[skillLine] then
			if onlyPrimary[skillLine] then
				abilities = 1
			end

			for i = 1, abilities do
				if not IsPassiveSpell(i + offset, BOOKTYPE_PROFESSION) then
					if i > 1 then
						table_insert(tradeSpells, i + offset)
						extras = extras + 1
					else
						table_insert(tradeSpells, #tradeSpells + 1 - extras, i + offset)
					end
				end
			end
		end
	end

	return tradeSpells
end

function Module:Initialize()
	-- Shouldn't need this, but I'm paranoid
	if self.initialized or not IsAddOnLoaded("Blizzard_TradeSkillUI") then
		return
	end

	local parent = TradeSkillFrame
	local tradeSpells = buildSpellList()
	local i = 1
	local prev, foundCooking

	-- if player is a DK, insert runeforging at the top
	if K.Class == "DEATHKNIGHT" then
		prev = self:CreateTab(i, parent, RUNEFORGING)
		prev:SetPoint("TOPLEFT", parent, "TOPRIGHT", 2, -44)
		i = i + 1
	end

	for i, slot in ipairs(tradeSpells) do
		local _, spellID = GetSpellBookItemInfo(slot, BOOKTYPE_PROFESSION)
		local tab = self:CreateTab(i, parent, spellID)
		if spellID == 818 then foundCooking = true end
		i = i + 1

		local point, relPoint, x, y = "TOPLEFT", "BOTTOMLEFT", 0, -6
		if not prev then
			prev, relPoint, x, y = parent, "TOPRIGHT", 2, -22
		end
		tab:SetPoint(point, prev, relPoint, x, y)

		prev = tab
	end

	if foundCooking and PlayerHasToy(CHEF_HAT) and C_ToyBox_IsToyUsable(CHEF_HAT) then
		local tab = self:CreateTab(i, parent, CHEF_HAT, true)
		tab:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	end

	self.initialized = true
end

local function onEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tooltip)
	self:GetParent():LockHighlight()
end

local function onLeave(self)
	GameTooltip:Hide()
	self:GetParent():UnlockHighlight()
end

local function updateSelection(self)
	if IsCurrentSpell(self.spellID) then
		self:SetChecked(true)
		self.clickStopper:Show()
	else
		self:SetChecked(false)
		self.clickStopper:Hide()
	end

	local start, duration
	if self.type == "toy" then
		start, duration = GetItemCooldown(self.spellID)
	else
		start, duration = GetSpellCooldown(self.spellID)
	end

	if start and duration and duration > 1.5 then
		self.CD:SetCooldown(start, duration)
	end
end

local function createClickStopper(button)
	local f = CreateFrame("Frame", nil, button)
	f:SetAllPoints(button)
	f:EnableMouse(true)
	f:SetScript("OnEnter", onEnter)
	f:SetScript("OnLeave", onLeave)
	button.clickStopper = f
	f.tooltip = button.tooltip
	f:Hide()
end

local function reskinTabs(button)
	button:GetRegions():Hide()
	button:CreateBorder()
	button:StyleButton()
	button:GetNormalTexture():SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
end

function Module:CreateTab(_, parent, spellID, isToy)
	local name, texture, _
	if isToy then
		_, name, texture = C_ToyBox_GetToyInfo(spellID)
	else
		name, _, texture = GetSpellInfo(spellID)
	end

	local button = CreateFrame("CheckButton", nil, parent, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	button.tooltip = name
	button.spellID = spellID
	button.spell = name
	button:Show()
	button.type = isToy and "toy" or "spell"
	button:SetAttribute("type", button.type)
	button:SetAttribute(button.type, name)

	button:SetNormalTexture(texture)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	reskinTabs(button)
	button.CD = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.CD:SetAllPoints()

	button:SetScript("OnEvent", updateSelection)
	button:RegisterEvent("TRADE_SKILL_SHOW")
	button:RegisterEvent("TRADE_SKILL_CLOSE")
	button:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")

	createClickStopper(button)
	updateSelection(button)
	return button
end

Module:RegisterEvent("ADDON_LOADED")
Module:SetScript("OnEvent", Module.OnEvent)