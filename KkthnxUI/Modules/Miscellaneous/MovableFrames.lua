local K, C = unpack(select(2, ...))
local Module = K:NewModule("MovableFrames", "AceEvent-3.0")

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
	-- "CharacterFrame",
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
	["Blizzard_AchievementUI"] = { "AchievementFrame" },
	["Blizzard_ArchaeologyUI"] = { "ArchaeologyFrame" },
	["Blizzard_AuctionUI"] = { "AuctionFrame" },
	["Blizzard_BarberShopUI"] = { "BarberShopFrame" },
	["Blizzard_BindingUI"] = { "KeyBindingFrame" },
	["Blizzard_BlackMarketUI"] = { "BlackMarketFrame" },
	["Blizzard_Calendar"] = { "CalendarCreateEventFrame", "CalendarFrame", "CalendarViewEventFrame", "CalendarViewHolidayFrame" },
	["Blizzard_ChallengesUI"] = { "ChallengesKeystoneFrame" }, -- "ChallengesLeaderboardFrame"
	["Blizzard_Collections"] = { "CollectionsJournal" },
	["Blizzard_EncounterJournal"] = { "EncounterJournal" },
	["Blizzard_GarrisonUI"] = { "GarrisonLandingPage", "GarrisonMissionFrame", "GarrisonCapacitiveDisplayFrame", "GarrisonBuildingFrame", "GarrisonRecruiterFrame", "GarrisonRecruitSelectFrame", "GarrisonShipyardFrame" },
	["Blizzard_GMChatUI"] = { "GMChatStatusFrame" },
	["Blizzard_GMSurveyUI"] = { "GMSurveyFrame" },
	["Blizzard_GuildBankUI"] = { "GuildBankFrame" },
	["Blizzard_GuildControlUI"] = { "GuildControlUI" },
	["Blizzard_GuildUI"] = { "GuildFrame", "GuildLogFrame" },
	["Blizzard_InspectUI"] = { "InspectFrame" },
	["Blizzard_ItemAlterationUI"] = { "TransmogrifyFrame" },
	["Blizzard_ItemSocketingUI"] = { "ItemSocketingFrame" },
	["Blizzard_ItemUpgradeUI"] = { "ItemUpgradeFrame" },
	["Blizzard_LookingForGuildUI"] = { "LookingForGuildFrame" },
	["Blizzard_MacroUI"] = { "MacroFrame" },
	["Blizzard_OrderHallUI"] = { "OrderHallTalentFrame" },
	["Blizzard_QuestChoice"] = { "QuestChoiceFrame" },
	["Blizzard_TalentUI"] = { "PlayerTalentFrame" },
	["Blizzard_TalkingHeadUI"] = { "TalkingHeadFrame" },
	["Blizzard_TradeSkillUI"] = { "TradeSkillFrame" },
	["Blizzard_TrainerUI"] = { "ClassTrainerFrame" },
	["Blizzard_VoidStorageUI"] = { "VoidStorageFrame" },
}

local function LoadPosition(self)
	local Name = self:GetName()

	if not self:GetPoint() then
		self:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 16, -116)
	end

	tinsert(UISpecialFrames, Name)
end

local function OnDragStart(self)
	self:StartMoving()
end

local function OnDragStop(self)
	self:StopMovingOrSizing()
	self:SetUserPlaced(false)
end

function Module:MakeMovable(Name)
	if not _G[Name] then
		K.Print("[MF] " .. "Frame doesn't exist: " .. Name)
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
	Frame:HookScript("OnShow", LoadPosition)
	Frame:HookScript("OnDragStart", OnDragStart)
	Frame:HookScript("OnDragStop", OnDragStop)
	Frame:HookScript("OnHide", OnDragStop)

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