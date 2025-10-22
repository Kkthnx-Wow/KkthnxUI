local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- Cache global functions for performance (Lua 5.1)
local _G = _G
local pairs = pairs
local string_gmatch = string.gmatch
local type = type
local print = print

-- Frame data structures
local frames = {
	-- ["FrameName"] = true (the parent frame should be moved) or false (the frame itself should be moved)
	-- for child frames (i.e. frames that don't have a name, but only a parentKey="XX" use
	-- "ParentFrameName.XX" as frame name. more than one level is supported, e.g. "Foo.Bar.Baz")

	-- Blizz Frames
	["AddonList"] = false,
	["ChannelFrame"] = false,
	["ChatConfigFrame"] = false,
	["CommunitiesFrame"] = false, -- needs review
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
	-- ["TradeFrame"] = false,
	["TutorialFrame"] = false,
	["SettingsPanel"] = false,
}

-- Frame Existing Check (only runs in developer mode for debugging)
local function IsFrameExists()
	if not K.isDeveloper then
		return
	end

	for k in pairs(frames) do
		if not _G[k] then
			print("Frame not found:", k)
		end
	end
end

-- Frames provided by load on demand addons, hooked when the addon is loaded.
local lodFrames = {
	-- AddonName = { list of frames, same syntax as above }
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
	--Blizzard_ProfessionsBook	= { ["ProfessionsBookFrame"] = false },
	Blizzard_ProfessionsCustomerOrders = { ["ProfessionsCustomerOrdersFrame"] = false },
	Blizzard_TalentUI = { ["PlayerTalentFrame"] = false, ["PVPTalentPrestigeLevelDialog"] = false },
	Blizzard_TimeManager = { ["TimeManagerFrame"] = false },
	Blizzard_TokenUI = { ["TokenFrame"] = true },
	Blizzard_TradeSkillUI = { ["TradeSkillFrame"] = false },
	Blizzard_TrainerUI = { ["ClassTrainerFrame"] = false },
	Blizzard_VoidStorageUI = { ["VoidStorageFrame"] = false, ["VoidStorageBorderFrameMouseBlockFrame"] = "VoidStorageFrame" },
	Blizzard_WeeklyRewards = { ["WeeklyRewardsFrame"] = false },
}

-- Cache tables for frame tracking (reused to minimize allocations)
local parentFrame = {}
local hooked = {}

-- Mouse event handlers (optimized with early returns)
local function MouseDownHandler(frame, button)
	if button ~= "LeftButton" then
		return
	end

	-- Use cached parent frame if available
	local targetFrame = parentFrame[frame] or frame
	if targetFrame then
		targetFrame:StartMoving()
		targetFrame:SetUserPlaced(false)
	end
end

local function MouseUpHandler(frame, button)
	if button ~= "LeftButton" then
		return
	end

	-- Use cached parent frame if available
	local targetFrame = parentFrame[frame] or frame
	if targetFrame then
		targetFrame:StopMovingOrSizing()
	end
end

-- Optimized script hooking (avoids creating unnecessary closures)
local function HookScript(frame, script, handler)
	if not frame or not frame.GetScript then
		return
	end

	local oldHandler = frame:GetScript(script)
	if oldHandler then
		frame:SetScript(script, function(...)
			handler(...)
			oldHandler(...)
		end)
	else
		frame:SetScript(script, handler)
	end
end

-- Hook frame to make it movable (with caching)
local function HookFrame(name, moveParent)
	-- Early return if already hooked
	if hooked[name] then
		return
	end

	-- Find frame (name may contain dots for children, e.g. ReforgingFrame.InvisibleButton)
	local frame = _G
	for segment in string_gmatch(name, "%w+") do
		if not frame then
			break
		end
		frame = frame[segment]
	end

	-- Validate frame was found
	if frame == _G or not frame then
		return
	end

	-- Handle parent frame if specified
	local parent
	if moveParent then
		if type(moveParent) == "string" then
			parent = _G[moveParent]
		else
			parent = frame:GetParent()
		end

		if not parent then
			if K.isDeveloper then
				print("Parent frame not found: " .. name)
			end
			return
		end

		-- Cache parent frame reference
		parentFrame[frame] = parent

		-- Make parent movable
		parent:SetMovable(true)
		parent:SetClampedToScreen(false)
	end

	-- Make frame movable and hook mouse events
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(false)
	HookScript(frame, "OnMouseDown", MouseDownHandler)
	HookScript(frame, "OnMouseUp", MouseUpHandler)

	-- Mark as hooked to prevent duplicate hooks
	hooked[name] = true
end

-- Iterate and hook multiple frames (optimized)
local function HookFrames(list)
	if not list then
		return
	end

	for name, child in pairs(list) do
		HookFrame(name, child)
	end
end

-- Module initialization function
function Module:CreateMoveBlizzardFrames()
	-- Early return if module is disabled
	if not C["General"].MoveBlizzardFrames then
		return
	end

	-- Initialize default frames
	HookFrames(frames)
	IsFrameExists()

	-- Hook frames from load-on-demand addons when they load
	local function OnAddonLoaded(_, name)
		local frameList = lodFrames[name]
		if frameList then
			HookFrames(frameList)
		end
	end

	-- Register event for LOD addons
	K:RegisterEvent("ADDON_LOADED", OnAddonLoaded)
end
