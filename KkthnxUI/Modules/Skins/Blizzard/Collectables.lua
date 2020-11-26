local _, C = unpack(select(2, ...))

local _G = _G

C.themes["Blizzard_Collections"] = function()
	if C["General"].NoTutorialButtons then
		_G.PetJournalTutorialButton:Kill()
	end
end