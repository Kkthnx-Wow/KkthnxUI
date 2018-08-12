local K, C = unpack(select(2, ...))
local Module = K:NewModule("MovableFrames", "AceEvent-3.0", "AceHook-3.0")

-- Sourced: Azilroka, Simpy
-- Desciption: Make Blizzard Frames Movable

local pairs, tinsert, sort = pairs, tinsert, sort
local _G = _G
local IsAddOnLoaded = IsAddOnLoaded

local Frames = {
	"AddonList",
	"AudioOptionsFrame",
	"BankFrame",
	"BonusRollFrame",
	"BonusRollLootWonFrame",
	"BonusRollMoneyWonFrame",
	"CharacterFrame",
	"DressUpFrame",
	"FriendsFrame",
	"FriendsFriendsFrame",
	"GameMenuFrame",
	"GhostFrame",
	"GossipFrame",
	"GuildInviteFrame",
	"GuildRegistrarFrame",
	"HelpFrame",
	"InterfaceOptionsFrame",
	"ItemTextFrame",
	"LFDRoleCheckPopup",
	"LFGDungeonReadyDialog",
	"LFGDungeonReadyStatus",
	"LootFrame",
	"MailFrame",
	"MerchantFrame",
	"OpenMailFrame",
	"PetitionFrame",
	"PetStableFrame",
	"PVEFrame",
	-- "PVPReadyDialog",
	"QuestFrame",
	"QuestLogPopupDetailFrame",
	"RaidBrowserFrame",
	"RaidInfoFrame",
	"RaidParentFrame",
	"ReadyCheckFrame",
	"ReportCheatingDialog",
	"RolePollPopup",
	"ScrollOfResurrectionSelectionFrame",
	"SpellBookFrame",
	"SplashFrame",
	"StackSplitFrame",
	"StaticPopup1",
	"StaticPopup2",
	"StaticPopup3",
	"StaticPopup4",
	"TabardFrame",
	"TaxiFrame",
	"TradeFrame",
	"TutorialFrame",
	"VideoOptionsFrame",
	"WorldStateScoreFrame",
}

local AddOnFrames = {
	["Blizzard_AchievementUI"] = {"AchievementFrame"},
	["Blizzard_ArchaeologyUI"] = {"ArchaeologyFrame"},
	["Blizzard_AuctionUI"] = {"AuctionFrame"},
	["Blizzard_BarberShopUI"] = {"BarberShopFrame"},
	["Blizzard_BindingUI"] = {"KeyBindingFrame"},
	["Blizzard_BlackMarketUI"] = {"BlackMarketFrame"},
	["Blizzard_Calendar"] = {"CalendarCreateEventFrame", "CalendarFrame", "CalendarViewEventFrame", "CalendarViewHolidayFrame"},
	["Blizzard_ChallengesUI"] = {"ChallengesKeystoneFrame"}, -- "ChallengesLeaderboardFrame"
	["Blizzard_Collections"] = {"CollectionsJournal"},
	["Blizzard_Communities"] = {"CommunitiesFrame"},
	["Blizzard_EncounterJournal"] = {"EncounterJournal"},
	["Blizzard_GarrisonUI"] = {"GarrisonLandingPage", "GarrisonMissionFrame", "GarrisonCapacitiveDisplayFrame", "GarrisonBuildingFrame", "GarrisonRecruiterFrame", "GarrisonRecruitSelectFrame", "GarrisonShipyardFrame"},
	["Blizzard_GMChatUI"] = {"GMChatStatusFrame"},
	["Blizzard_GMSurveyUI"] = {"GMSurveyFrame"},
	["Blizzard_GuildBankUI"] = {"GuildBankFrame"},
	["Blizzard_GuildControlUI"] = {"GuildControlUI"},
	["Blizzard_GuildUI"] = {"GuildFrame", "GuildLogFrame"},
	["Blizzard_InspectUI"] = {"InspectFrame"},
	["Blizzard_ItemAlterationUI"] = {"TransmogrifyFrame"},
	["Blizzard_ItemSocketingUI"] = {"ItemSocketingFrame"},
	["Blizzard_ItemUpgradeUI"] = {"ItemUpgradeFrame"},
	["Blizzard_LookingForGuildUI"] = {"LookingForGuildFrame"},
	["Blizzard_MacroUI"] = {"MacroFrame"},
	["Blizzard_OrderHallUI"] = {"OrderHallTalentFrame"},
	["Blizzard_QuestChoice"] = {"QuestChoiceFrame"},
	["Blizzard_TalentUI"] = {"PlayerTalentFrame"},
	["Blizzard_TalkingHeadUI"] = {"TalkingHeadFrame"},
	["Blizzard_TradeSkillUI"] = {"TradeSkillFrame"},
	["Blizzard_TrainerUI"] = {"ClassTrainerFrame"},
	["Blizzard_VoidStorageUI"] = {"VoidStorageFrame"},
}

function Module:LoadPosition(frame)
	if not frame:GetPoint() then
		frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 16, -116)
	end
end

function Module:OnDragStart(frame)
	self:Unhook(frame, "OnUpdate")
	frame:StartMoving()
end

function Module:OnDragStop(frame)
	frame:StopMovingOrSizing()
	frame:SetUserPlaced(false)

	if (not self:IsHooked(frame, "OnUpdate")) then
		self:HookScript(frame, "OnUpdate", "LoadPosition")
	end
end

function Module:MakeMovable(Name)
	if not _G[Name] then
		K.Print("[MovableFrames] " .. "Frame doesn't exist: " .. Name)
		return
	end

	local Frame = _G[Name]

	if Name == "AchievementFrame" then
		AchievementFrameHeader:EnableMouse(false)
	end

	Frame:EnableMouse(true)
	Frame:SetMovable(true)
	Frame:RegisterForDrag("LeftButton")
	Frame:SetClampedToScreen(true)
	self:HookScript(Frame, "OnUpdate", "LoadPosition")
	self:HookScript(Frame, "OnDragStart", "OnDragStart")
	self:HookScript(Frame, "OnDragStop", "OnDragStop")
	self:HookScript(Frame, "OnHide", "OnDragStop")

	Frame.ignoreFramePositionManager = true
	if UIPanelWindows[Name] then
		for Key in pairs(UIPanelWindows[Name]) do
			if Key == "pushable" then
				UIPanelWindows[Name][Key] = nil
			end
		end
	end
end

function Module:ADDON_LOADED(_, addon)
	if AddOnFrames[addon] then
		for _, Frame in pairs(AddOnFrames[addon]) do
			self:MakeMovable(Frame)
		end
	end
end

function Module:OnEnable()
	if C["General"].MoveBlizzardFrames ~= true then
		return
	end

	tinsert(Frames, "LossOfControlFrame")
	sort(Frames)

	for i = 1, #Frames do
		Module:MakeMovable(Frames[i])
	end

	-- Check Forced Loaded AddOns
	for AddOn, Table in pairs(AddOnFrames) do
		if IsAddOnLoaded(AddOn) then
			for _, Frame in pairs(Table) do
				Module:MakeMovable(Frame)
			end
		end
	end

	Module:RegisterEvent("ADDON_LOADED")
end