--[[-----------------------------------------------------------------------------
-- Shared interrupt spell lookup.
-- Used by unit-frame castbar kick ticks and future nameplate kick markers.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local KICK_SPELLS_BY_CLASS = {
	DEATHKNIGHT = { 47528 },
	WARRIOR = { 6552 },
	WARLOCK = { 19647, 89766, 119910, 1276467, 132409 },
	SHAMAN = { 57994 },
	ROGUE = { 1766 },
	PRIEST = { 15487 },
	PALADIN = { 31935, 96231 },
	MONK = { 116705 },
	MAGE = { 2139 },
	HUNTER = { 187707, 147362 },
	EVOKER = { 351338 },
	DRUID = { 38675, 78675, 106839 },
	DEMONHUNTER = { 183752 },
}

local activeKickSpell

local function RefreshKickAbility()
	local playerClass = UnitClassBase("player")
	local classKicks = KICK_SPELLS_BY_CLASS[playerClass]
	activeKickSpell = nil
	if not classKicks then
		return
	end

	for i = 1, #classKicks do
		local spellID = classKicks[i]
		if C_SpellBook and C_SpellBook.IsSpellKnownOrInSpellBook then
			local known = C_SpellBook.IsSpellKnownOrInSpellBook(spellID)
			local petKnown = Enum and Enum.SpellBookSpellBank
				and C_SpellBook.IsSpellKnownOrInSpellBook(spellID, Enum.SpellBookSpellBank.Pet)
			if known or petKnown then
				activeKickSpell = spellID
			end
		elseif IsSpellKnown and IsSpellKnown(spellID) then
			activeKickSpell = spellID
		end
	end
end

function K.GetActiveKickSpell()
	return activeKickSpell
end

function K.RefreshKickAbility()
	RefreshKickAbility()
end

-- SECRET-safe: blends base cast color → interrupt-ready tint via kick CD IsZero.
-- Returns possibly-secret RGB; pass straight to SetVertexColor / ColorMixin:SetRGB.
function K.ComputeCastBarTint(readyTint, baseTint)
	if not activeKickSpell or not readyTint or not baseTint then
		return baseTint.r, baseTint.g, baseTint.b
	end
	if not (C_Spell and C_Spell.GetSpellCooldownDuration) then
		return baseTint.r, baseTint.g, baseTint.b
	end
	if not (C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean) then
		return baseTint.r, baseTint.g, baseTint.b
	end
	local cdTime = C_Spell.GetSpellCooldownDuration(activeKickSpell)
	if not (cdTime and cdTime.IsZero) then
		return baseTint.r, baseTint.g, baseTint.b
	end
	local offCooldown = cdTime:IsZero()
	local evaluate = C_CurveUtil.EvaluateColorValueFromBoolean
	return evaluate(offCooldown, baseTint.r, readyTint.r), evaluate(offCooldown, baseTint.g, readyTint.g), evaluate(offCooldown, baseTint.b, readyTint.b)
end

local kickFrame = CreateFrame("Frame")
kickFrame:RegisterEvent("PLAYER_LOGIN")
kickFrame:RegisterEvent("SPELLS_CHANGED")
kickFrame:SetScript("OnEvent", RefreshKickAbility)

if UnitGUID("player") then
	RefreshKickAbility()
end
