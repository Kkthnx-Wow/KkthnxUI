local K, C = unpack(select(2, ...))
local Module = K:NewModule("MovableFrames", "AceEvent-3.0", "AceHook-3.0")

-- Sourced: ElvUI Shadow and Light

local _G = _G
local pairs = pairs
local type = type

local GetRealmName = _G.GetRealmName
local IsAddOnLoaded = _G.IsAddOnLoaded
local UnitName = _G.UnitName

Module.Frames = {
	"AddonList",
	"AudioOptionsFrame",
	"BankFrame",
	"BonusRollFrame",
	"BonusRollLootWonFrame",
	"BonusRollMoneyWonFrame",
	"CharacterFrame",
	"ChatConfigFrame",
	"DressUpFrame",
	"FriendsFrame",
	"FriendsFriendsFrame",
	"GameMenuFrame",
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
	"PVEFrame",
	"PetStableFrame",
	"PetitionFrame",
	"PVPReadyDialog",
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
	"TimeManagerFrame",
	"TradeFrame",
	"TutorialFrame",
	"VideoOptionsFrame",
	"WorldMapFrame",
}

Module.AddonsList = {
	["Blizzard_AchievementUI"] = {"AchievementFrame"},
	["Blizzard_AlliedRacesUI"] = {"AlliedRacesFrame"},
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
	-- ["Blizzard_TalkingHeadUI"] = {"TalkingHeadFrame"},
	["Blizzard_TradeSkillUI"] = {"TradeSkillFrame"},
	["Blizzard_TrainerUI"] = {"ClassTrainerFrame"},
	["Blizzard_VoidStorageUI"] = {"VoidStorageFrame"},
}

local function OnDragStart(self)
	self.IsMoving = true
	self:StartMoving()
end

local function OnDragStop(self)
	self:StopMovingOrSizing()
	self.IsMoving = false
	self:SetUserPlaced(false)
end

local function LoadPosition(self)
	if self.IsMoving == true then return end
	local Name = self:GetName()
	if not self:GetPoint() then
		self:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 16, -116, true)
		OnDragStop(self)
	end

	if Name == "QuestFrame" then
		_G["GossipFrame"]:Hide()
	elseif Name == "GossipFrame" then
		_G["QuestFrame"]:Hide()
	end
end

function Module:MakeMovable(Name)
	local frame = _G[Name]

	if not frame then
		K.Print("Frame to move doesn't exist: "..(frameName or UNKNOWN))
		return
	end

	if Name == "AchievementFrame" then
		AchievementFrameHeader:EnableMouse(false)
	end

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:HookScript("OnShow", LoadPosition)
	frame:HookScript("OnDragStart", OnDragStart)
	frame:HookScript("OnDragStop", OnDragStop)
	frame:HookScript("OnHide", OnDragStop)
end

function Module:Addons(event, addon)
	addon = Module.AddonsList[addon]

	if not addon then
		return
	end

	if type(addon) == "table" then
		for i = 1, #addon do
			Module:MakeMovable(addon[i])
		end
	else
		Module:MakeMovable(addon)
	end

	Module.addonCount = Module.addonCount + 1

	if Module.addonCount == #Module.AddonsList then
		Module:UnregisterEvent(event)
	end
end

function Module:OnEnable()
	Module.addonCount = 0

	KkthnxUIData[GetRealmName()][UnitName("player")].PvPReadyDialogReset = nil

	if not KkthnxUIData[GetRealmName()][UnitName("player")].PvPReadyDialogReset then
		KkthnxUIData[GetRealmName()][UnitName("player")].PvPReadyDialogReset = true
	end

	PVPReadyDialog:Hide()

	if C["General"].MoveBlizzardFrames == true then
		for i = 1, #Module.Frames do
			Module:MakeMovable(Module.Frames[i])
		end
		self:RegisterEvent("ADDON_LOADED", "Addons")

		-- Check Forced Loaded AddOns
		for AddOn, Table in pairs(Module.AddonsList) do
			if IsAddOnLoaded(AddOn) then
				for _, frame in pairs(Table) do
					Module:MakeMovable(frame)
				end
			end
		end
	end
end