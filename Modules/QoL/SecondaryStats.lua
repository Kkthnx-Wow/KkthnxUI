--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/SecondaryStats.lua
	Purpose:
		A small movable readout of critical strike, haste, mastery and versatility
		so the numbers can be watched without opening the character sheet.

		The game hides these stats from addons while unit stats are restricted
		(during an encounter or a Mythic Plus run). When that happens the readout
		simply keeps its last values, and it catches up the moment they are readable
		again. Updates are driven by the stat events and by changes to your own
		buffs, gathered into one refresh a fraction of a second later.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret
local format = string.format
local max = math.max
local GetCritChance, GetSpellCritChance, GetRangedCritChance = GetCritChance, GetSpellCritChance, GetRangedCritChance
local GetHaste, GetMasteryEffect = GetHaste, GetMasteryEffect
local GetCombatRatingBonus, GetVersatilityBonus = GetCombatRatingBonus, GetVersatilityBonus

local SPELL_SCHOOL_HOLY = 2
local DELAY = 0.2

local frame
local queued
local values = { crit = 0, haste = 0, mastery = 0, versatility = 0 }

local LABELS = {
	{ "crit", L["Crit"], 0.90, 0.35, 0.35 },
	{ "haste", L["Haste"], 0.95, 0.80, 0.30 },
	{ "mastery", L["Mastery"], 0.45, 0.75, 0.95 },
	{ "versatility", L["Vers"], 0.55, 0.90, 0.55 },
}

-- Read one stat. Returns nil while it is hidden, so the old value stays.
local function Read(fn, ...)
	local value = fn(...)
	if IsSecret(value) or value == nil then
		return nil
	end
	return value
end

local function Collect()
	local melee = Read(GetCritChance)
	local spell = Read(GetSpellCritChance, SPELL_SCHOOL_HOLY)
	local ranged = Read(GetRangedCritChance)
	if melee and spell and ranged then
		values.crit = max(melee, spell, ranged)
	end

	values.haste = Read(GetHaste) or values.haste
	values.mastery = Read(GetMasteryEffect) or values.mastery

	local rating = Read(GetCombatRatingBonus, _G.CR_VERSATILITY_DAMAGE_DONE)
	local bonus = Read(GetVersatilityBonus, _G.CR_VERSATILITY_DAMAGE_DONE)
	if rating and bonus then
		values.versatility = rating + bonus
	end
end

local function Render()
	local lines = {}
	for index, entry in ipairs(LABELS) do
		lines[index] = format("|cff%02x%02x%02x%s|r  %.2f%%", entry[3] * 255, entry[4] * 255, entry[5] * 255, entry[2], values[entry[1]])
	end
	frame.Text:SetText(table.concat(lines, "\n"))
	frame:SetSize(frame.Text:GetStringWidth() + 4, frame.Text:GetStringHeight() + 4)
end

local function Refresh()
	queued = nil
	Collect()
	Render()
end

local function Queue()
	if not queued then
		queued = true
		C_Timer.After(DELAY, Refresh)
	end
end

function Module:RestyleStats()
	if frame then
		K.SetFont(frame.Text, C.QoL.StatsSize or 13, "OUTLINE")
		Render()
	end
end

function Module:SetupSecondaryStats()
	frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(120, 60)
	frame:EnableMouse(false)
	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	frame.Text:SetPoint("TOPLEFT", 2, -2)
	frame.Text:SetJustifyH("LEFT")
	frame.Text:SetSpacing(2)
	K.CreateMover(frame, "SecondaryStats", L["Secondary Stats"], { "TOPLEFT", UIParent, "TOPLEFT", 12, -240 })
	self:RestyleStats()

	for _, event in ipairs({ "COMBAT_RATING_UPDATE", "MASTERY_UPDATE", "SPELL_POWER_CHANGED", "PLAYER_EQUIPMENT_CHANGED", "PLAYER_ENTERING_WORLD", "PLAYER_SPECIALIZATION_CHANGED" }) do
		self:RegisterEvent(event, Queue)
	end

	-- Your own buffs move these stats, and only your own are of interest, so this
	-- listens to the player alone rather than to every aura change in the game.
	local watcher = CreateFrame("Frame")
	watcher:RegisterUnitEvent("UNIT_AURA", "player")
	watcher:SetScript("OnEvent", Queue)

	Refresh()
end
