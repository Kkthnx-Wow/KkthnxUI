local K, C, L = unpack(select(2, ...))
if C.Announcements.SayThanks ~= true then return end

-- Wow API
local pairs = pairs
local SendChatMessage = SendChatMessage
local GetSpellLink = GetSpellLink
local print = print

-- Says thanks for some spells(SaySapped by Bitbyte, modified by m2jest1c)
local spells = {
	[20484] = true,		-- Rebirth
	[61999] = true,		-- Raise Ally
	[20707] = true,		-- Soulstone
	[50769] = true,		-- Revive
	[2006] = true,		-- Resurrection
	[7328] = true,		-- Redemption
	[2008] = true,		-- Ancestral Spirit
	[115178] = true,	-- Resuscitate
}

local SayThanks = CreateFrame("Frame")
SayThanks:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
SayThanks:SetScript("OnEvent", function(_, event, _, subEvent, _, _, buffer, _, _, _, player, _, _, spell, ...)
	for key, value in pairs(spells) do
		if spell == key and value == true and player == K.Name and buffer ~= K.Name and subEvent == "SPELL_CAST_SUCCESS" then
			SendChatMessage(L.Announce.SSThanks..GetSpellLink(spell)..", "..buffer:gsub("%-[^|]+", ""), "WHISPER", nil, buffer)
			print(GetSpellLink(spell)..L.Announce.Recieved..buffer)
		end
	end
end)