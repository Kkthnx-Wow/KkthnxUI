local K, C, L = unpack(select(2, ...))
if C.Misc.MoveBlizzard ~= true then return end

-- Lua API
local _G = _G
local type = type

-- Global variables that we don"t cache, list them here for the mikk"s Find Globals script
-- GLOBALS: TradeSkillFrame, AchievementFrameHeader

local MovableFrame = CreateFrame("Frame")

-- Move some Blizzard frames
K.Frames = {
	"AddonList",
	"AudioOptionsFrame",
	"BankFrame",
	"BonusRollFrame",
	"BonusRollLootWonFrame",
	"BonusRollMoneyWonFrame",
	"CharacterFrame",
	"DressUpFrame",
	"FriendsFrame",
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
	"LossOfControlFrame",
	"MailFrame",
	"MerchantFrame",
	"OpenMailFrame",
	"PetitionFrame",
	"PetStableFrame",
	"PVEFrame",
	"PVPReadyDialog",
	"QuestFrame",
	"QuestLogPopupDetailFrame",
	"RaidBrowserFrame",
	"RaidParentFrame",
	"ReadyCheckFrame",
	"ReportCheatingDialog",
	"ReportPlayerNameDialog",
	"RolePollPopup",
	"ScrollOfResurrectionSelectionFrame",
	"SpellBookFrame",
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
	"WorldStateScoreFrame",
}

K.AddonsList = {
	["Blizzard_AchievementUI"] = {"AchievementFrame"},
	["Blizzard_ArchaeologyUI"] = {"ArchaeologyFrame"},
	["Blizzard_AuctionUI"] = {"AuctionFrame"},
	["Blizzard_BarberShopUI"] = {"BarberShopFrame"},
	["Blizzard_BindingUI"] = {"KeyBindingFrame"},
	["Blizzard_BlackMarketUI"] = {"BlackMarketFrame"},
	["Blizzard_Calendar"] = {"CalendarCreateEventFrame", "CalendarFrame", "CalendarViewEventFrame", "CalendarViewHolidayFrame"},
	["Blizzard_Collections"] = {"CollectionsJournal"},
	["Blizzard_EncounterJournal"] = {"EncounterJournal"},
	["Blizzard_GarrisonUI"] = {"GarrisonMissionFrame", "GarrisonCapacitiveDisplayFrame", "GarrisonLandingPage"},
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
	["Blizzard_QuestChoice"] = {"QuestChoiceFrame"},
	["Blizzard_TalentUI"] = {"PlayerTalentFrame"},
	["Blizzard_TradeSkillUI"] = {"TradeSkillFrame"},
	["Blizzard_TrainerUI"] = {"ClassTrainerFrame"},
	["Blizzard_VoidStorageUI"] = {"VoidStorageFrame"},
}

function MovableFrame:MakeMovable(frame)
	local name = frame:GetName()
	-- if K.CheckAddOn("KkthnxUI") and name == "LossOfControlFrame" then
	-- 	return
	-- end

	if name == "AchievementFrame" then
		AchievementFrameHeader:EnableMouse(false)
	end

	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
	frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
end

MovableFrame:RegisterEvent("PLAYER_LOGIN")
MovableFrame:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_LOGIN" then
		self:RegisterEvent("ADDON_LOADED")

		for _, Frame in pairs(K.Frames) do
			if _G[Frame] then
				self:MakeMovable(_G[Frame])
			end
		end

		-- Check Forced Loaded AddOns
		for AddOn, Table in pairs(K.AddonsList) do
			if IsAddOnLoaded(AddOn) then
				for _, Frame in pairs(Table) do
					self:MakeMovable(_G[Frame])
				end
			end
		end
	end

	if event == "ADDON_LOADED" then
		if K.AddonsList[addon] then
			for _, Frame in pairs(K.AddonsList[addon]) do
				self:MakeMovable(_G[Frame])
			end
		end
	end
end)