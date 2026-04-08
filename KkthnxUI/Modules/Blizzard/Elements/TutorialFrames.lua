--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically dismisses and disables various Blizzard tutorial and help tip frames.
-- - Design: Hooks into the HelpTip system and shuts down various tutorial managers (TM, GT, NPE).
-- - Events: Hooked into HelpTip:Show and uses a delayed initialization check.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs
local table_wipe = table.wipe

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function autoCompleteHelpTips()
	-- REASON: Iterates through all active help tips and automatically acknowledges them to clear the UI.
	local helpTipPool = _G.HelpTip and _G.HelpTip.framePool
	if not helpTipPool then
		return
	end

	for frame in helpTipPool:EnumerateActive() do
		if frame.Acknowledge then
			frame:Acknowledge()
		end
	end
end

function Module:AutoDismissHelpTips()
	-- REASON: Hooks the HelpTip:Show function to immediately dismiss any new help tips that appear.
	if not C["General"].NoTutorialButtons then
		return
	end

	local helpTip = _G.HelpTip
	if helpTip then
		hooksecurefunc(helpTip, "Show", autoCompleteHelpTips)
	end
	-- REASON: One-time delay check to catch any help tips that spawned during the initial loading process.
	K.Delay(1, autoCompleteHelpTips)
end

local function deactivateNewPlayerExperience()
	-- REASON: Forcefully shuts down the modern "New Player Experience" guided tutorial system.
	local npe = _G.NewPlayerExperience
	if npe and npe.GetIsActive and npe:GetIsActive() then
		if npe.Shutdown then
			npe:Shutdown()
		end
	end
end

local function deactivateTutorialManager()
	-- REASON: Disables the legacy TutorialManager and kills specific tutorial frames that may persist.
	local tutorialFrames = {
		"TutorialSingleKey_Frame",
		"TutorialMainFrame_Frame",
		"TutorialKeyboardMouseFrame_Frame",
		"TutorialWalk_Frame",
	}

	local tm = _G.TutorialManager
	if tm and tm.GetIsActive and tm:GetIsActive() then
		if tm.Shutdown then
			tm:Shutdown()
		end

		for _, frameName in ipairs(tutorialFrames) do
			local frame = _G[frameName]
			if frame and frame.Kill then
				frame:Kill()
			end
		end
	end
end

local function deactivateGameTutorials()
	-- REASON: Marks various character and profession-based tutorials as completed to prevent them from surfacing.
	local gameTutorialsList = {
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

	local gt = _G.GameTutorials
	if gt then
		for _, tutorialClass in ipairs(gameTutorialsList) do
			local tutorial = _G[tutorialClass]
			if tutorial and tutorial.Complete then
				tutorial:Complete()
			end
		end
	end
end

local function clearTutorialDispatcher()
	-- REASON: Clears the event dispatcher for tutorials to stop any pending or scheduled tutorial triggers.
	local td = _G.Dispatcher
	if td then
		if td.Events then
			table_wipe(td.Events)
		end
		if td.Scripts then
			table_wipe(td.Scripts)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Module Implementation
-- ---------------------------------------------------------------------------
function Module:ShutdownAllTutorials()
	-- REASON: Centralized function to invoke all tutorial deactivation logic.
	deactivateNewPlayerExperience()
	deactivateGameTutorials()
	deactivateTutorialManager()
	clearTutorialDispatcher()
end

function Module:CreateTutorialDisabling()
	-- REASON: Entry point for the tutorial disabling feature; checks user configuration before proceeding.
	if not C["General"].NoTutorialButtons then
		return
	end

	Module:AutoDismissHelpTips()
	Module:ShutdownAllTutorials()
end
