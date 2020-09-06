local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G

local IsAddOnLoaded = _G.IsAddOnLoaded

local tutorialFrameScripts = {
	"OnClick",
	"OnEnter",
	"OnEvent",
	"OnHide",
	"OnLeave",
	"OnMouseDown",
	"OnMouseUp",
	"OnShow",
	"OnUpdate",
	"OnValueChanged",
}

local tutorialFrames = {
	SpellBookFrameTutorialButton,
	HelpOpenTicketButtonTutorial,
	HelpPlate,
	HelpPlateTooltip,
	WorldMapFrame.BorderFrame.Tutorial,
	CharacterMicroButtonAlert,
	CollectionsMicroButtonAlert,
	EJMicroButtonAlert,
	LFDMicroButtonAlert,
	TutorialFrameAlertButton,
	TalentMicroButtonAlert,
	--QuickJoinToastButton,
}

local function DisableAllScripts(frame)
	for _, script in next, tutorialFrameScripts do
		if frame:HasScript(script) then
			frame:SetScript(script, nil)
		end
	end
end

function Module:SetupNoTutorials()
	for _, frame in next, tutorialFrames do
		if frame.UnregisterAllEvents then
			frame:UnregisterAllEvents()
		end

		DisableAllScripts(frame)
	end

	for _, frame in next, tutorialFrames do
		frame:SetParent(K.UIFrameHider)
	end
end

function Module:ForceCollections(_, name)
    if name == "Blizzard_Collections" then
		K:UnregisterEvent("ADDON_LOADED", Module.ForceCollections)
	end
end

function Module:ForceTalents(_, name)
    if name == "Blizzard_TalentUI" then
		K:UnregisterEvent("ADDON_LOADED", Module.ForceTalents)
	end
end

function Module:CreateNoTutorials()
	if not C["General"].DisableTutorialButtons then
		return
	end

	-- Idk what I am doing at this point?
	if not (IsAddOnLoaded("Blizzard_Collections")) then
		K:RegisterEvent("ADDON_LOADED", Module.ForceCollections)
		UIParentLoadAddOn("Blizzard_Collections")

		table.insert(tutorialFrames, PetJournalTutorialButton) -- Table this?
	end

	if not (IsAddOnLoaded("Blizzard_TalentUI")) then
		K:RegisterEvent("ADDON_LOADED", Module.ForceTalents)
		UIParentLoadAddOn("Blizzard_TalentUI")

		table.insert(tutorialFrames, Blizzard_Collections)
		table.insert(tutorialFrames, PlayerTalentFrameSpecializationTutorialButton)
		table.insert(tutorialFrames, PlayerTalentFrameTalentsTutorialButton)
		table.insert(tutorialFrames, PlayerTalentFramePetSpecializationTutorialButton)
		table.insert(tutorialFrames, PlayerTalentFrameTalentsPvpTalentFrame.TrinketSlot.HelpBox)
		table.insert(tutorialFrames, PlayerTalentFrameTalentsPvpTalentFrame.WarmodeTutorialBox)
	end

	local function delaySetup()
		Module:SetupNoTutorials()
	end

	K.Delay(5, delaySetup)
end