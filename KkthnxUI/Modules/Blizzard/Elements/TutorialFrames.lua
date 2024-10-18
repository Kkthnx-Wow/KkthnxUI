local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

local _G = _G
local wipe = wipe
local hooksecurefunc = hooksecurefunc

local function AutoCompleteHelpTips()
	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end

function Module:AutoDismissHelpTips()
	if not C["General"].NoTutorialButtons then
		return
	end

	hooksecurefunc(_G.HelpTip, "Show", AutoCompleteHelpTips)
	K.Delay(1, AutoCompleteHelpTips)
end

local function DeactivateNewPlayerExperience()
	local NPE = _G.NewPlayerExperience
	if NPE and NPE:GetIsActive() then
		NPE:Shutdown()
	end
end

local function DeactivateTutorialManager()
	local tutorialFrames = {
		"TutorialSingleKey_Frame",
		"TutorialMainFrame_Frame",
		"TutorialKeyboardMouseFrame_Frame",
		"TutorialWalk_Frame",
	}

	local TM = _G.TutorialManager
	if TM and TM:GetIsActive() then
		TM:Shutdown()

		for _, frameName in ipairs(tutorialFrames) do
			local frame = _G[frameName]
			if frame then
				frame:Kill()
			end
		end
	end
end

local function DeactivateGameTutorials()
	local gameTutorials = {
		"Class_ProfessionInventoryWatcher",
		"Class_ProfessionGearCheckingService",
		"Class_EquipProfessionGear",
		"Class_FirstProfessionWatcher",
		"Class_FirstProfessionTutorial",
		"Class_DracthyrEssenceWatcher",
		"Class_StarterTalentWatcher",
		"Class_TalentPoints",
		"Class_ChangeSpec",
	}

	local GT = _G.GameTutorials
	if GT then
		for _, tutorialClass in ipairs(gameTutorials) do
			local tutorial = _G[tutorialClass]
			if tutorial then
				tutorial:Complete()
			end
		end
	end
end

local function ClearTutorialDispatcher()
	local TD = _G.Dispatcher
	if TD then
		wipe(TD.Events)
		wipe(TD.Scripts)
	end
end

function Module:ShutdownAllTutorials()
	DeactivateNewPlayerExperience()
	DeactivateGameTutorials()
	DeactivateTutorialManager()
	ClearTutorialDispatcher()
end

function Module:CreateTutorialDisabling()
	if not C["General"].NoTutorialButtons then
		return
	end

	Module:AutoDismissHelpTips()
	Module:ShutdownAllTutorials()
end
