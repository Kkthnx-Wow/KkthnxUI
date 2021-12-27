local _, C = unpack(KkthnxUI)

local _G = _G

C.themes["Blizzard_TalentUI"] = function()
	if C["General"].NoTutorialButtons then
		_G.PlayerTalentFrameTalentsTutorialButton:Kill()
		_G.PlayerTalentFrameSpecializationTutorialButton:Kill()
	end
end