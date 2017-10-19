local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("MovableFrames", "AceHook-3.0", "AceEvent-3.0")

local _G = _G

local EnableMouse = _G.EnableMouse
local RegisterForDrag = _G.RegisterForDrag
local SetClampedToScreen = _G.SetClampedToScreen
local SetMovable = _G.SetMovable
local StartMoving = _G.StartMoving
local StopMovingOrSizing = _G.StopMovingOrSizing

Module.Frames = {
	"AddonList",
	"BankFrame",
	"CharacterFrame",
	"ChatConfigFrame",
	"CinematicFrame",
	"DressUpFrame",
	"FriendsFrame",
	"GameMenuFrame",
	"GossipFrame",
	"GuildInviteFrame",
	"GuildRegistrarFrame",
	"HelpFrame",
	"InterfaceOptionsFrame",
	"ItemTextFrame",
	"LootFrame",
	"MailFrame",
	"MerchantFrame",
	"OpenMailFrame",
	"PVEFrame",
	"PetStableFrame",
	"PetitionFrame",
	"QuestFrame",
	"RaidBrowserFrame",
	"ScrollOfResurrectionSelectionFrame",
	"SpellBookFrame",
	"StackSplitFrame",
	"StaticPopup1",
	"StaticPopup2",
	"TabardFrame",
	"TaxiFrame",
	"TimeManagerFrame",
	"TradeFrame",
	"TutorialFrame",
	"VideoOptionsFrame",
	"WorldMapFrame",
}

Module.AddonsList = {
	["Blizzard_AchievementUI"] = {"AchievementFrame","AchievementFrameHeader"},
	["Blizzard_ArchaeologyUI"] = "ArchaeologyFrame",
	["Blizzard_AuctionUI"] = "AuctionFrame",
	["Blizzard_Calendar"] = "CalendarFrame",
	["Blizzard_Collections"] = "CollectionsJournal",
	["Blizzard_EncounterJournal"] = "EncounterJournal",
	["Blizzard_GarrisonUI"] = {"GarrisonLandingPage", "GarrisonMissionFrame", "GarrisonCapacitiveDisplayFrame", "GarrisonBuildingFrame", "GarrisonRecruiterFrame", "GarrisonRecruitSelectFrame", "GarrisonShipyardFrame"},
	["Blizzard_GuildBankUI"] = "GuildBankFrame",
	["Blizzard_GuildControlUI"] = "GuildControlUI",
	["Blizzard_GuildUI"] = "GuildFrame",
	["Blizzard_InspectUI"] = "InspectFrame",
	["Blizzard_ItemAlterationUI"] = "TransmogrifyFrame",
	["Blizzard_ItemSocketingUI"] = "ItemSocketingFrame",
	["Blizzard_ItemUpgradeUI"] = "ItemUpgradeFrame",
	["Blizzard_LookingForGuildUI"] = "LookingForGuildFrame",
	["Blizzard_MacroUI"] = "MacroFrame",
	["Blizzard_TalentUI"] = "PlayerTalentFrame",
	["Blizzard_TradeSkillUI"] = "TradeSkillFrame",
	["Blizzard_VoidStorageUI"] = "VoidStorageFrame",
}

function Module:MakeMovable(frame)
	if frame then
		frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:SetClampedToScreen(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
		frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		if frame.TitleMouseover then Module:MakeMovable(frame.TitleMouseover) end
	end
end

function Module:Addons(event, addon)
	local frame
	addon = Module.AddonsList[addon]
	if not addon then return end
	if type(addon) == "table" then
		for i = 1, #addon do
			frame = _G[addon[i]]
			Module:MakeMovable(frame)
		end
	else
		frame = _G[addon]
		Module:MakeMovable(frame)
	end
	Module.addonCount = Module.addonCount + 1
	if Module.addonCount == #Module.AddonsList then Module:UnregisterEvent(event) end
end

function Module:OnEnable()
	Module.addonCount = 0
	if C["General"].MoveBlizzardFrames ~= true then return end

	for i = 1, #Module.Frames do
		local frame = _G[Module.Frames[i]]
		if frame then Module:MakeMovable(frame) else K.Print("Doesn't exist: "..Module.Frames[i]) end
	end
	self:RegisterEvent("ADDON_LOADED", "Addons")
end