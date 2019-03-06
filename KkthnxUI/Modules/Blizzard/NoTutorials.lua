local K, C = unpack(select(2, ...))
local Module = K:NewModule("NoTutorials")

local _G = _G

function Module:KillTutorials()
	_G.HelpOpenTicketButtonTutorial:Kill()
	_G.HelpPlate:Kill()
	_G.HelpPlateTooltip:Kill()
	_G.EJMicroButtonAlert:Kill()
	_G.WorldMapFrame.BorderFrame.Tutorial:Kill()
	_G.SpellBookFrameTutorialButton:Kill()
end

function Module:OnEnable()
	if not C["General"].DisableTutorialButtons or K.CheckAddOnState("TutorialBuster") then
		return
	end

	self:KillTutorials()
end
