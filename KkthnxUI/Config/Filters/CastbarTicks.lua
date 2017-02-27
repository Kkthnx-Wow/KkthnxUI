local K, C, L = unpack(select(2, ...))
if C.Unitframe.CastbarTicks ~= true then return end

local _G = _G
local lower = string.lower

local GetSpellInfo = _G.GetSpellInfo

-- The best way to add or delete spell is to go at www.wowhead.com, search for a spell.
-- Example: Polymorph -> http://www.wowhead.com/spell=118
-- Take the number ID at the end of the URL, and add it to the list

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id)
	if not name then
		print("|cff3c9bedKkthnxUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to KkthnxUI author.")
		return "Impale"
	else
		return name
	end
end

-- List of spells to display ticks
K.ChannelTicks = {
	--Warlock
	[SpellName(198590)] = 6, -- "Drain Soul"
	[SpellName(755)] = 6, -- Health Funnel
	[SpellName(117952)] = 6, -- Health Funnel
	--Priest
	[SpellName(64843)] = 4, -- Divine Hymn
	[SpellName(15407)] = 4, -- Mind Flay
	--Mage
	[SpellName(5143)] = 5, -- "Arcane Missiles"
	[SpellName(12051)] = 3, -- "Evocation"
	[SpellName(205021)] = 10, -- "Ray of Frost"
}

local priestTier17 = {115560, 115561, 115562, 115563, 115564}
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:SetScript("OnEvent", function()
	local class = select(2, UnitClass("player"))
	if lower(class) ~= "priest" then return; end

	local penanceTicks = 3
	local equippedPriestTier17 = 0
	for _, item in pairs(priestTier17) do
		if IsEquippedItem(item) then
			equippedPriestTier17 = equippedPriestTier17 + 1
		end
	end
	if equippedPriestTier17 >= 2 then
		penanceTicks = 4
	end
	K.ChannelTicks[SpellName(47540)] = penanceTicks --Penance
end)

K.ChannelTicksSize = {
	--Warlock
	[SpellName(198590)] = 1, -- "Drain Soul"
}

--Spells Effected By Haste
K.HastedChannelTicks = {
	[SpellName(205021)] = true, -- "Ray of Frost"
}