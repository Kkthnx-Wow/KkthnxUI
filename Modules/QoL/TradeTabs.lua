--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/TradeTabs.lua
	Purpose:
		A column of icons down the side of the professions window, one per
		profession you know, so moving from alchemy to enchanting is a click instead
		of a trip to the spellbook. Death Knights also get Runeforging.

		Each icon is a secure button that casts the profession's own spell, exactly
		as clicking it in the spellbook does. The buttons are made once, out of
		combat, the first time the window opens, and they are children of the
		window made here, so nothing on Blizzard's window is changed. A window that
		first opens in combat gets its icons when combat ends.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local ipairs = ipairs
local GetProfessions, GetProfessionInfo = GetProfessions, GetProfessionInfo
local C_SpellBook, C_Spell = C_SpellBook, C_Spell

local SIZE = 32
local GAP = 4
local RUNEFORGING = 53428

-- Professions whose first spell is the whole profession. The rest list extra
-- spells worth having, like the cooking fire.
local SINGLE_SPELL = { [171] = true, [182] = true, [186] = true, [202] = true, [356] = true, [393] = true }

-- GetProfessions returns primary, primary, archaeology, fishing, cooking. Archaeology
-- has no tab, so it is left out.
local PROFESSION_SLOTS = { 1, 2, 4, 5 }

local tabs = {}
local built

local function AddTab(spellID)
	local name, texture = C_Spell.GetSpellName(spellID), C_Spell.GetSpellTexture(spellID)
	if not name then
		return
	end

	local window = _G.ProfessionsFrame
	local tab = CreateFrame("CheckButton", nil, window, "SecureActionButtonTemplate")
	tab:SetSize(SIZE, SIZE)
	tab.spellID = spellID
	tab:RegisterForClicks("AnyUp", "AnyDown")
	tab:SetAttribute("type", "spell")
	tab:SetAttribute("spell", spellID)
	tab:SetNormalTexture(texture)
	tab:GetNormalTexture():SetTexCoord(0.08, 0.92, 0.08, 0.92)
	tab:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
	tab:GetCheckedTexture():SetBlendMode("ADD")
	tab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	K.CreateBorder(tab)

	tab:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(name)
		GameTooltip:Show()
	end)
	tab:SetScript("OnLeave", GameTooltip_Hide)

	if #tabs == 0 then
		tab:SetPoint("TOPLEFT", window, "TOPRIGHT", 4, -36)
	else
		tab:SetPoint("TOPLEFT", tabs[#tabs], "BOTTOMLEFT", 0, -GAP)
	end
	tabs[#tabs + 1] = tab
end

local function UpdateChecked()
	for _, tab in ipairs(tabs) do
		tab:SetChecked(C_Spell.IsCurrentSpell(tab.spellID))
	end
end

local function Build()
	if built or not _G.ProfessionsFrame then
		return
	end
	if InCombatLockdown() then
		K.DeferCombat("TradeTabs", Build)
		return
	end
	built = true

	if K.Class == "DEATHKNIGHT" and C_SpellBook.IsSpellKnown(RUNEFORGING) then
		AddTab(RUNEFORGING)
	end

	-- Read the slots by position: a character with no primary profession can still
	-- have fishing or cooking, and a nil in a list would end an ipairs walk early.
	local slots = { GetProfessions() }
	for _, position in ipairs(PROFESSION_SLOTS) do
		local index = slots[position]
		if index then
			local _, _, _, _, count, offset, skillLine = GetProfessionInfo(index)
			if count and count > 0 then
				for item = 1, SINGLE_SPELL[skillLine] and 1 or count do
					local slot = offset + item
					local info = C_SpellBook.GetSpellBookItemInfo(slot, Enum.SpellBookSpellBank.Player)
					if info and info.spellID and not info.isPassive then
						AddTab(info.spellID)
					end
				end
			end
		end
	end

	UpdateChecked()
end

local hooked

local function Hook()
	if not hooked and _G.ProfessionsFrame then
		hooked = true
		_G.ProfessionsFrame:HookScript("OnShow", Build)
	end
end

local function OnAddOnLoaded(_, _, addon)
	if addon == "Blizzard_Professions" then
		Hook()
	end
end

function Module:SetupTradeTabs()
	Hook()
	if not hooked then
		self:RegisterEvent("ADDON_LOADED", OnAddOnLoaded)
	end
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", UpdateChecked)
end
