--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Enables movement and repositioning for standard Blizzard UI frames.
-- - Design: Implements a recursive frame lookup and hooks mouse events (OnMouseDown/Up) to trigger StartMoving.
-- - Events: ADDON_LOADED
-----------------------------------------------------------------------------]]

local K, C = _G["KkthnxUI"][1], _G["KkthnxUI"][2]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local pairs = _G.pairs
local print = _G.print
local string_gmatch = _G.string.gmatch
local type = _G.type

local _G = _G

-- SG: Frame Lists
local MOVABLE_FRAMES = {
	["AddonList"] = false,
	["ChannelFrame"] = false,
	["ChatConfigFrame"] = false,
	["CommunitiesFrame"] = false,
	["CooldownViewerSettings"] = false,
	["DressUpFrame"] = false,
	["FriendsFrame"] = false,
	["GossipFrame"] = false,
	["GuildInviteFrame"] = false,
	["GuildRegistrarFrame"] = false,
	["HelpFrame"] = false,
	["ItemTextFrame"] = false,
	["LootFrame"] = false,
	["MailFrame"] = false,
	["MerchantFrame"] = false,
	["ModelPreviewFrame"] = false,
	["OpenMailFrame"] = false,
	["PaperDollFrame"] = true,
	["PetitionFrame"] = false,
	["PVEFrame"] = false,
	["QuestFrame"] = false,
	["RaidParentFrame"] = false,
	["ReputationFrame"] = true,
	["SendMailFrame"] = true,
	["SplashFrame"] = false,
	["StackSplitFrame"] = false,
	["TabardFrame"] = false,
	["TaxiFrame"] = false,
	["TokenFrame"] = true,
	["TutorialFrame"] = false,
	["SettingsPanel"] = false,
}

local LOD_MOVABLE_FRAMES = {
	Blizzard_AchievementUI = { ["AchievementFrame"] = false, ["AchievementFrameHeader"] = true, ["AchievementFrameCategoriesContainer"] = "AchievementFrame", ["AchievementFrame.searchResults"] = false },
	Blizzard_AdventureMap = { ["AdventureMapQuestChoiceDialog"] = false },
	Blizzard_AlliedRacesUI = { ["AlliedRacesFrame"] = false },
	Blizzard_ArchaeologyUI = { ["ArchaeologyFrame"] = false },
	Blizzard_ArtifactUI = { ["ArtifactFrame"] = false, ["ArtifactRelicForgeFrame"] = false },
	Blizzard_AuctionHouseUI = { ["AuctionHouseFrame"] = false },
	Blizzard_AzeriteEssenceUI = { ["AzeriteEssenceUI"] = false },
	Blizzard_AzeriteRespecUI = { ["AzeriteRespecFrame"] = false },
	Blizzard_AzeriteUI = { ["AzeriteEmpoweredItemUI"] = false },
	Blizzard_BindingUI = { ["KeyBindingFrame"] = false, ["QuickKeybindFrame"] = false },
	Blizzard_BlackMarketUI = { ["BlackMarketFrame"] = false },
	Blizzard_Calendar = { ["CalendarFrame"] = false, ["CalendarCreateEventFrame"] = true, ["CalendarEventPickerFrame"] = false },
	Blizzard_ChallengesUI = { ["ChallengesKeystoneFrame"] = false },
	Blizzard_ClassTalentUI = { ["ClassTalentFrame"] = false },
	Blizzard_ClickBindingUI = { ["ClickBindingFrame"] = false },
	Blizzard_Collections = { ["WardrobeFrame"] = false, ["WardrobeOutfitEditFrame"] = false },
	Blizzard_CovenantRenown = { ["CovenantRenownFrame"] = false },
	Blizzard_CovenantSanctum = { ["CovenantSanctumFrame"] = false },
	Blizzard_EncounterJournal = { ["EncounterJournal"] = false },
	Blizzard_FlightMap = { ["FlightMapFrame"] = false },
	Blizzard_GenericTraitUI = { ["GenericTraitFrame"] = false },
	Blizzard_GMSurveyUI = { ["GMSurveyFrame"] = false },
	Blizzard_GuildBankUI = { ["GuildBankFrame"] = false, ["GuildBankEmblemFrame"] = true },
	Blizzard_GuildControlUI = { ["GuildControlUI"] = false },
	Blizzard_GuildRecruitmentUI = { ["CommunitiesGuildRecruitmentFrame"] = false },
	Blizzard_GuildUI = { ["GuildFrame"] = false, ["GuildRosterFrame"] = true, ["GuildFrame.TitleMouseover"] = true },
	Blizzard_InspectUI = { ["InspectFrame"] = false, ["InspectPVPFrame"] = true, ["InspectTalentFrame"] = true },
	Blizzard_IslandsPartyPoseUI = { ["IslandsPartyPoseFrame"] = false },
	Blizzard_IslandsQueueUI = { ["IslandsQueueFrame"] = false },
	Blizzard_ItemSocketingUI = { ["ItemSocketingFrame"] = false },
	Blizzard_ItemUpgradeUI = { ["ItemUpgradeFrame"] = false },
	Blizzard_LookingForGuildUI = { ["LookingForGuildFrame"] = false },
	Blizzard_MacroUI = { ["MacroFrame"] = false },
	Blizzard_ObliterumUI = { ["ObliterumForgeFrame"] = false },
	Blizzard_OrderHallUI = { ["OrderHallTalentFrame"] = false },
	Blizzard_ScrappingMachineUI = { ["ScrappingMachineFrame"] = false },
	Blizzard_Professions = { ["InspectRecipeFrame"] = false, ["ProfessionsFrame"] = false },
	Blizzard_ProfessionsCustomerOrders = { ["ProfessionsCustomerOrdersFrame"] = false },
	Blizzard_TalentUI = { ["PlayerTalentFrame"] = false, ["PVPTalentPrestigeLevelDialog"] = false },
	Blizzard_TimeManager = { ["TimeManagerFrame"] = false },
	Blizzard_TokenUI = { ["TokenFrame"] = true },
	Blizzard_TradeSkillUI = { ["TradeSkillFrame"] = false },
	Blizzard_TrainerUI = { ["ClassTrainerFrame"] = false },
	Blizzard_VoidStorageUI = { ["VoidStorageFrame"] = false, ["VoidStorageBorderFrameMouseBlockFrame"] = "VoidStorageFrame" },
	Blizzard_WeeklyRewards = { ["WeeklyRewardsFrame"] = false },
}

-- SG: Caches
local parentFrameCache = {}
local hookedFrames = {}

-- REASON: Handles the start of a drag operation on the left mouse button, using a cached parent frame reference if applicable.
local function onFrameMouseDown(frame, mouseButton)
	if not C["General"].MoveBlizzardFrames then
		return
	end

	if mouseButton ~= "LeftButton" then
		return
	end

	local targetFrame = parentFrameCache[frame] or frame
	if targetFrame then
		targetFrame:StartMoving()
		targetFrame:SetUserPlaced(false)
	end
end

-- REASON: Terminates a drag operation on the left mouse button release.
local function onFrameMouseUp(frame, mouseButton)
	if not C["General"].MoveBlizzardFrames then
		return
	end

	if mouseButton ~= "LeftButton" then
		return
	end

	local targetFrame = parentFrameCache[frame] or frame
	if targetFrame then
		targetFrame:StopMovingOrSizing()
	end
end

-- REASON: hookFrameScript removed; replaced with Blizzard's taint-safe HookScript API.
-- WARNING: The manual SetScript pattern risked taint on protected Blizzard frames.

-- REASON: Resolves and hooks a specific frame by name, supporting dot-notation for nested child frames and optional parent-repositioning.
local function makeFrameMovable(frameName, moveParent)
	if hookedFrames[frameName] then
		return
	end

	local targetFrame = _G
	for segment in string_gmatch(frameName, "%w+") do
		if not targetFrame then
			break
		end
		targetFrame = targetFrame[segment]
	end

	if targetFrame == _G or not targetFrame then
		return
	end

	local actualParent
	if moveParent then
		if type(moveParent) == "string" then
			actualParent = _G[moveParent]
		else
			actualParent = targetFrame:GetParent()
		end

		if not actualParent then
			if K.isDeveloper then
				print("Parent frame not found for: " .. frameName)
			end
			return
		end

		parentFrameCache[targetFrame] = actualParent
		actualParent:SetMovable(true)
		actualParent:SetClampedToScreen(false)
	end

	targetFrame:EnableMouse(true)
	targetFrame:SetMovable(true)
	targetFrame:SetClampedToScreen(false)
	-- REASON: HookScript is taint-safe and chains handlers automatically; replaces manual hookFrameScript.
	targetFrame:HookScript("OnMouseDown", onFrameMouseDown)
	targetFrame:HookScript("OnMouseUp", onFrameMouseUp)

	hookedFrames[frameName] = true
end

local function makeFramesMovable(frameList)
	if not frameList then
		return
	end

	for frameName, moveParent in pairs(frameList) do
		makeFrameMovable(frameName, moveParent)
	end
end

-- REASON: Verification function to ensure all registered frames exist in the global environment, restricted to developer mode.
local function checkFrameExistence()
	if not K.isDeveloper then
		return
	end

	for frameName in pairs(MOVABLE_FRAMES) do
		if not _G[frameName] then
			print("Frame not found:", frameName)
		end
	end
end

function Module:CreateMoveBlizzardFrames()
	if Module._blizzardFramesMovable then
		return
	end

	if not C["General"].MoveBlizzardFrames then
		return
	end

	Module._blizzardFramesMovable = true

	makeFramesMovable(MOVABLE_FRAMES)
	checkFrameExistence()

	-- REASON: Bridges addon loading events with frame movement initialization for load-on-demand Blizzard UIs.
	local function onAddonLoaded(_, addonName)
		local addonFrameList = LOD_MOVABLE_FRAMES[addonName]
		if addonFrameList then
			makeFramesMovable(addonFrameList)
		end
	end

	K:RegisterEvent("ADDON_LOADED", onAddonLoaded)
end

function Module:UpdateMoveBlizzardFrames()
	if C["General"].MoveBlizzardFrames then
		Module:CreateMoveBlizzardFrames()
	end
end
