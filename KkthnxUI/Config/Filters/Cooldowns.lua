local K, C, L, _ = select(2, ...):unpack()

--[[
	The best way to add or delete spell is to go at www.wowhead.com, search for a spell.
	Example: Rebirth -> http://www.wowhead.com/spell=20484
	Take the number ID at the end of the URL, and add it to the list
]]

if C.PulseCD.Enable == true then
	K.PulseIgnoredSpells = {
		--GetSpellInfo(6807),	-- Maul
		--GetSpellInfo(35395),	-- Crusader Strike
	}
end