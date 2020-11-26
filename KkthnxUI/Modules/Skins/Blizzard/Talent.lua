local _, C = unpack(select(2, ...))

local _G = _G

C.themes["Blizzard_TalentUI"] = function()
	if C["General"].NoTutorialButtons then
		_G.PlayerTalentFrameTalentsTutorialButton:Kill()
		_G.PlayerTalentFrameSpecializationTutorialButton:Kill()
	end
end