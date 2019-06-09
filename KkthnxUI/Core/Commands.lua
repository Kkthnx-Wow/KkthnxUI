local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_lower = string.lower
local string_split = string.split
local string_trim = string.trim
local table_insert = table.insert
local table_remove = table.remove

-- Wow API
local AbandonQuest = _G.AbandonQuest
local CombatLogClearEntries = _G.CombatLogClearEntries
local ConvertToParty = _G.ConvertToParty
local ConvertToRaid = _G.ConvertToRaid
local DisableAllAddOns = _G.DisableAllAddOns
local DoReadyCheck = _G.DoReadyCheck
local EnableAddOn = _G.EnableAddOn
local ERR_NOT_IN_GROUP = _G.ERR_NOT_IN_GROUP
local FEATURE_BECOMES_AVAILABLE_AT_LEVEL = _G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL
local GetCurrentResolution = _G.GetCurrentResolution
local GetCVarBool = _G.GetCVarBool
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetRealmName = _G.GetRealmName
local GetScreenResolutions = _G.GetScreenResolutions
local GetSpecialization = _G.GetSpecialization
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local LeaveParty = _G.LeaveParty
local LFGTeleport = _G.LFGTeleport
local MAX_PARTY_MEMBERS = _G.MAX_PARTY_MEMBERS
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySound = _G.PlaySound
local ReloadUI = _G.ReloadUI
local RepopMe = _G.RepopMe
local RetrieveCorpse = _G.RetrieveCorpse
local SelectQuestLogEntry = _G.SelectQuestLogEntry
local SendChatMessage = _G.SendChatMessage
local SetAbandonQuest = _G.SetAbandonQuest
local SetCVar = _G.SetCVar
local SetSpecialization = _G.SetSpecialization
local SHOW_TALENT_LEVEL = _G.SHOW_TALENT_LEVEL
local SlashCmdList = _G.SlashCmdList
local UninviteUnit = _G.UninviteUnit
local UnitExists = _G.UnitExists
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitName = _G.UnitName

local function parseArguments(msg)
	-- Remove spaces at the start and end
	msg = string_gsub(msg, "^%s+", "")
	msg = string_gsub(msg, "%s+$", "")

	-- Replace all space characters with single spaces
	msg = string_gsub(msg, "%s+", " ")

	-- If multiple arguments exist, split them into separate return values
	if string_find(msg, "%s") then
		return string_split(" ", msg)
	else
		return msg
	end
end

-- ConfigFrame
function K.ConfigUI()
	if (not KkthnxUIConfig) then
		print("KkthnxUI config not found!")
		return
	end

	if (not KkthnxUIConfigFrame) then
		KkthnxUIConfig:CreateConfigWindow()
	end

	if KkthnxUIConfigFrame:IsVisible() then
		KkthnxUIConfigFrame:Hide()
	else
		KkthnxUIConfigFrame:Show()
	end
end
K:RegisterChatCommand("cfg", K.ConfigUI)
K:RegisterChatCommand("configui", K.ConfigUI)

function K.ResetNameplatesVars()
	K:GetModule("Unitframes"):NameplatesVarsReset()
end
K:RegisterChatCommand("fixplates", K.ResetNameplatesVars)
K:RegisterChatCommand("resetnameplates", K.ResetNameplatesVars)
K:RegisterChatCommand("resetplates", K.ResetNameplatesVars)
K:RegisterChatCommand("rnp", K.ResetNameplatesVars)

-- Profiles data/listings
function K.UIProfiles(msg)
	if not KkthnxUIData then
		return
	end

	if KkthnxUIConfigPerAccount then
		K.Print(L["Commands"].ConfigPerAccount)
		return
	end

	if not msg or msg == "" then
		print(L["Commands"].ProfileInfo)
	else
		local IsConfigLoaded = IsAddOnLoaded("KkthnxUI_Config")
		-- Split the msg into multiple arguments.
		-- This function will return any number of arguments.
		local command, arg1 = parseArguments(msg)

		if msg == "list" or msg == "l" then
			KkthnxUI.Profiles = {}
			KkthnxUI.Profiles.Data = {}
			KkthnxUI.Profiles.Options = {}

			for Server, Table in pairs(KkthnxUIData) do
				if not Server then
					return
				end

				if Server ~= "Gold" or Server ~= "gold" or Server ~= "Class" or Server ~= "class" then
					if type(KkthnxUIData[Server]) == "table" then
						for Character, Table in pairs(KkthnxUIData[Server]) do
							table_insert(KkthnxUI.Profiles.Data, KkthnxUIData[Server][Character])

							if IsConfigLoaded then
								if KkthnxUIConfigShared and KkthnxUIConfigShared[Server] and KkthnxUIConfigShared[Server][Character] then
									table_insert(KkthnxUI.Profiles.Options, KkthnxUIConfigShared[Server][Character])
								else
									if not KkthnxUIConfigShared then
										KkthnxUIConfigShared = {}
									end

									if not KkthnxUIConfigShared[Server] then
										KkthnxUIConfigShared[Server] = {}
									end

									if not KkthnxUIConfigShared[Server][Character] then
										KkthnxUIConfigShared[Server][Character] = {}
									end

									table_insert(KkthnxUI.Profiles.Options, KkthnxUIConfigShared[Server][Character])
								end
							end

							K.Print(L["Commands"].Profile .. #KkthnxUI.Profiles.Data..": ["..Server.."] - ["..Character.."]")
						end
					end
				end
			end
		elseif command == "delete" or command == "del" then
			-- Only do this if the user previously has done a /profile list,
			-- and an indexed listing of the profiles is actually available.
			if KkthnxUI.Profiles and KkthnxUI.Profiles.Data then

				-- Retrieve the profile ID
				local Profile = tonumber(arg1)

				-- Retrieve the profile table
				local Data = KkthnxUI.Profiles.Data[Profile]

				-- Return an error if the user entered a non existing profile
				if not Data then
					K.Print(L["Commands"].ProfileNotFound)
					return
				else

					-- Deleting the current profile requires a reload
					local CurrentServer = GetRealmName()
					local CurrentCharacter = UnitName("player")

					if Data == KkthnxUIData[CurrentServer][CurrentCharacter] then
						return K["Install"]:ResetData()
					end

					local CharacterName, ServerName
					local found

					-- Search through the stored data for the matching table
					for Server, Table in pairs(KkthnxUIData) do
						if Server ~= "Gold" or Server ~= "gold" or Server ~= "Class" or Server ~= "class" then
							if type(KkthnxUIData[Server]) == "table" then
								for Character, Table in pairs(KkthnxUIData[Server]) do
									if Table == Data then
										CharacterName = Character
										ServerName = Server
										KkthnxUIData[Server][Character] = nil
										KkthnxUIConfigShared[Server][Character] = nil
										found = true
										break
									end
								end

								if found then
									break
								end
							end
						end
					end

					-- Delete the profile listing entries too.
					table_remove(KkthnxUI.Profiles.Data, Profile)
					table_remove(KkthnxUI.Profiles.Options, Profile)

					-- Tell the user about the deletion
					K.Print(L["Commands"].Profile .. #KkthnxUI.Profiles.Data .. L["Commands"].ProfileDel .. "["..ServerName.."] - ["..CharacterName.."]")

					-- Do a new listing to show the users the order now,
					-- in case they wish to delete more profiles.

					-- First iterate through the indexed profile table
					for Profile = 1, #KkthnxUI.Profiles.Data do
						local Data = KkthnxUI.Profiles.Data[Profile]

						-- Search through the saved data for the matching table,
						-- so we can get the character and server names.
						local found
						for Server, Table in pairs(KkthnxUIData) do
							if Server ~= "Gold" or Server ~= "gold" or Server ~= "Class" or Server ~= "class" then
								for Character, Table in pairs(KkthnxUIData[Server]) do

									-- We found the matching table so we break and exit this loop,
									-- to allow the outer iteration loop to continue faster.
									if Table == Data then
										K.Print(L["Commands"].Profile ..Profile..": ["..Server.."] - ["..Character.."]")
										found = true
										break
									end
								end

								if found then
									break
								end
							end
						end
					end
				end
			end
		else
			local CurrentServer = GetRealmName()
			local CurrentCharacter = UnitName("player")
			local Profile = tonumber(msg)

			if not KkthnxUI.Profiles or not KkthnxUI.Profiles.Data[Profile] then
				K.Print(L["Commands"].ProfileNotFound)
				return
			end

			KkthnxUIData[CurrentServer][CurrentCharacter] = KkthnxUI.Profiles.Data[Profile]
			if IsConfigLoaded then
				KkthnxUIConfigShared[CurrentServer][CurrentCharacter] = KkthnxUI.Profiles.Options[Profile]
			end

			ReloadUI()
		end
	end
end
K:RegisterChatCommand("profile", K.UIProfiles)
K:RegisterChatCommand("profiles", K.UIProfiles)

--[[function K.MoveUI()
if InCombatLockdown() then
	print(ERR_NOT_IN_COMBAT)
	return
end

K["Movers"]:StartOrStopMoving()
end
K:RegisterChatCommand("moveui", K.MoveUI)
K:RegisterChatCommand("movers", K.MoveUI)--]]

-- Fixes the issue when the dialog to release spirit does not come up.
function K.FixRelease()
	RetrieveCorpse()
	RepopMe()
end
K:RegisterChatCommand("release", K.FixRelease)
K:RegisterChatCommand("repop", K.FixRelease)

-- Fixes the issue when players get stuck in party on felsong.
function K.FixParty()
	LeaveParty()
	print(L["Commands"].FixParty)
end
K:RegisterChatCommand("killparty", K.FixParty)
K:RegisterChatCommand("leaveparty", K.FixParty)

-- Ready check
function K.ReadyCheck()
	DoReadyCheck()
end
K:RegisterChatCommand("rc", K.ReadyCheck)

local QuestCheckSubDomain = (setmetatable({
	ruRU = "ru",
	frFR = "fr", deDE = "de",
	esES = "es", esMX = "es",
	ptBR = "pt", ptPT = "pt", itIT = "it",
	koKR = "ko", zhTW = "cn", zhCN = "cn"
}, { __index = function() return "www" end }))[GetLocale()]

local WoWHeadLoc = QuestCheckSubDomain..".wowhead.com/quest="
local QuestCheckComplete = [[|TInterface\RaidFrame\ReadyCheck-Ready:14:14:-1:-1|t]]
local QuestCheckIncomplete = [[|TInterface\RaidFrame\ReadyCheck-NotReady:14:14:-1:-1|t]]
function K.CheckQuestStatus(questid)
	questid = tonumber(questid)

	if not questid then
		print(L["Commands"].CheckQuestInfo)
		--print("Enter questID found in Wowhead URL")
		--print("http://wowhead.com/quest=ID")
		--print("Example: /checkquest 12045")

		K.StaticPopup_Show("QUEST_CHECK_ID")
		return
	end

	if (IsQuestFlaggedCompleted(questid) == true) then
		UIErrorsFrame:AddMessage(QuestCheckComplete.."Quest ".. "|CFFFFFF00[" .. questid .. "]|r" .. L["Commands"].CheckQuestComplete)
		PlaySoundFile("sound\\interface\\iquestcomplete.ogg")
		K.Print(WoWHeadLoc .. questid)
	else
		UIErrorsFrame:AddMessage(QuestCheckIncomplete.."Quest ".. "|CFFFFFF00[" .. questid .. "]|r" .. L["Commands"].CheckQuestNotComplete)
		PlaySoundFile("sound\\interface\\igquestfailed.ogg")
		K.Print(WoWHeadLoc .. questid)
	end
end
K:RegisterChatCommand("checkquest", K.CheckQuestStatus)
K:RegisterChatCommand("questcheck", K.CheckQuestStatus)
K:RegisterChatCommand("cq", K.CheckQuestStatus)
K:RegisterChatCommand("qc", K.CheckQuestStatus)

-- Help frame.
function K.GMTicket()
	ToggleHelpFrame()
end
K:RegisterChatCommand("gm", K.GMTicket)

function K.DeleteQuestItems()
	for bag = 0, 4 do
		for slot = 1, _G.GetContainerNumSlots(bag) do
			local itemLink = _G.GetContainerItemLink(bag, slot)
			if itemLink and _G.select(12, _G.GetItemInfo(itemLink)) == _G.LE_ITEM_CLASS_QUESTITEM then
				_G.print(itemLink)
				PickupContainerItem(bag, slot) DeleteCursorItem()
			end
		end
	end
end
K:RegisterChatCommand("deletequestitems", K.DeleteQuestItems)

function K.DeleteHeirlooms()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local name = GetContainerItemLink(bag,slot)
			if name and string.find(name,"00ccff") then
				print(name)
				PickupContainerItem(bag,slot)
				DeleteCursorItem()
			end
		end
	end
end
K:RegisterChatCommand("deleteheirlooms", K.DeleteHeirlooms)
K:RegisterChatCommand("deletelooms", K.DeleteHeirlooms)

function K.ResetInstances()
	ResetInstances()
end
K:RegisterChatCommand("ri", K.ResetInstances)
K:RegisterChatCommand("instancereset", K.ResetInstances)
K:RegisterChatCommand("resetinstance", K.ResetInstances)

-- Toggle the binding frame incase we unbind esc.
function K.KeyBindFrame()
	if not KeyBindingFrame then
		KeyBindingFrame_LoadUI()
	end

	ShowUIPanel(KeyBindingFrame)
end
K:RegisterChatCommand("binds", K.KeyBindFrame)

-- Fix The CombatLog.
function K.ClearCombatLog()
	CombatLogClearEntries()
end
K:RegisterChatCommand("clearcombat", K.ClearCombatLog)
K:RegisterChatCommand("clfix", K.ClearCombatLog)

-- Here we can restart wow's engine. could be use for sound issues and more.
function K.FixGFXEngine()
	K.StaticPopup_Show("RESTART_GFX")
end
K:RegisterChatCommand("restartgfx", K.FixGFXEngine)
K:RegisterChatCommand("fixgfx", K.FixGFXEngine)

-- Clear all quests in questlog
function K.AbandonQuests()
	local numEntries, numQuests = GetNumQuestLogEntries()
	for questLogIndex = 1, numEntries do
		local questTitle, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questLogIndex)

		if (not isHeader) then
			SelectQuestLogEntry(questLogIndex)
			SetAbandonQuest()
			AbandonQuest()
		end
	end

	--print(L["Commands"].AbandonQuests)
end
if not K.CheckAddOnState("Felsong_Companion") then
	K:RegisterChatCommand("killquests", K.AbandonQuests)
end
K:RegisterChatCommand("clearquests", K.AbandonQuests)

-- KkthnxUI help commands
function K.UICommandsHelp()
	print(L["Commands"].UIHelp)
end
K:RegisterChatCommand("helpui", K.UICommandsHelp)

function K.SetUIScale()
	if InCombatLockdown() or C["General"].AutoScale then
		print(L["Commands"].SetUIScale)
		return
	end

	local SetUIScale = GetCVarBool("uiScale")
	if not SetUIScale then
		SetCVar("uiScale", 768 / string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
		print(L["Commands"].SetUIScaleSucc ..768 / string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
		K.StaticPopup_Show("CHANGES_RL")
	end
end

SlashCmdList["SETUISCALE"] = function()
	K.StaticPopup_Show("SET_UISCALE")
end
_G.SLASH_SETUISCALE1 = "/uiscale"
_G.SLASH_SETUISCALE2 = "/setscale"

-- Disband party or raid (by Monolit)
function K.DisbandRaidGroup()
	if InCombatLockdown() then return end

	if UnitInRaid("player") then
		SendChatMessage(L["StaticPopups"].Disband_Group, "RAID")
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= K.Name then
				UninviteUnit(name)
			end
		end
	else
		SendChatMessage(L["StaticPopups"].Disband_Group, "PARTY")
		for i = MAX_PARTY_MEMBERS, 1, - 1 do
			if UnitExists("party"..i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end

SlashCmdList["GROUPDISBAND"] = function()
	K.StaticPopup_Show("DISBAND_RAID")
end
_G.SLASH_GROUPDISBAND1 = "/rd"

-- Enable lua error by command
function SlashCmdList.LUAERROR(msg)
	msg = string_lower(msg)
	if (msg == "on") then
		DisableAllAddOns()
		EnableAddOn("KkthnxUI")
		EnableAddOn("KkthnxUI_Config")
		SetCVar("scriptErrors", 1)
		ReloadUI()
	elseif (msg == "off") then
		SetCVar("scriptErrors", 0)
		K.Print(L["Commands"].LuaErrorOff)
	else
		K.Print(L["Commands"].LuaErrorInfo)
	end
end
_G.SLASH_LUAERROR1 = "/luaerror"

-- Convert party to raid
SlashCmdList.PARTYTORAID = function()
	if GetNumGroupMembers() > 0 then
		if UnitInRaid("player") and (UnitIsGroupLeader("player")) then
			ConvertToParty()
		elseif UnitInParty("player") and (UnitIsGroupLeader("player")) then
			ConvertToRaid()
		end
	else
		print("|cffff0000"..ERR_NOT_IN_GROUP.."|r")
	end
end
_G.SLASH_PARTYTORAID1 = "/toraid"
_G.SLASH_PARTYTORAID2 = "/toparty"
_G.SLASH_PARTYTORAID3 = "/convert"

-- Instance teleport
SlashCmdList.INSTTELEPORT = function()
	local inInstance = IsInInstance()
	if inInstance then
		LFGTeleport(true)
	else
		LFGTeleport()
	end
end
_G.SLASH_INSTTELEPORT1 = "/teleport"

-- Spec switching(by Monolit)
SlashCmdList.SPEC = function(spec)
	if K.Level >= SHOW_TALENT_LEVEL then
		if GetSpecialization() ~= tonumber(spec) then
			SetSpecialization(spec)
		end
	else
		print("|cffff0000"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_TALENT_LEVEL).."|r")
	end
end
_G.SLASH_SPEC1 = "/ss"
_G.SLASH_SPEC2 = "/spec"

SlashCmdList.VOLUME = function(value)
	local numValue = tonumber(value)
	if numValue and 0 <= numValue and numValue <= 1 then
		SetCVar("Sound_MasterVolume", numValue)
	end
end
_G.SLASH_VOLUME1 = "/vol"

SlashCmdList.FPS = function(value)
	local numValue = tonumber(value)
	if numValue and 0 <= numValue then
		SetCVar("maxFPS", numValue)
	end
end
_G.SLASH_FPS1 = "/fps"

-- Deadly boss mods testing.
SlashCmdList.DBMTEST = function()
	if K.CheckAddOnState("DBM-Core") then
		DBM:DemoMode()
	end
end
_G.SLASH_DBMTEST1 = "/dbmtest"

-- Clear chat
SlashCmdList.CLEARCHAT = function(cmd)
	cmd = cmd and string_trim(string_lower(cmd))
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame"..i]
		if f:IsVisible() or cmd == "all" then
			f:Clear()
		end
	end
end
_G.SLASH_CLEARCHAT1 = "/clearchat"
_G.SLASH_CLEARCHAT2 = "/chatclear"

local BLIZZARD_ADDONS = {
	"Blizzard_AchievementUI",
	"Blizzard_AdventureMap",
	"Blizzard_ArchaeologyUI",
	"Blizzard_ArenaUI",
	"Blizzard_ArtifactUI",
	"Blizzard_AuctionUI",
	"Blizzard_AuthChallengeUI",
	"Blizzard_BarbershopUI",
	"Blizzard_BattlefieldMinimap",
	"Blizzard_BindingUI",
	"Blizzard_BlackMarketUI",
	"Blizzard_BoostTutorial",
	"Blizzard_Calendar",
	"Blizzard_ChallengesUI",
	"Blizzard_ClassTrial",
	"Blizzard_ClientSavedVariables",
	"Blizzard_Collections",
	"Blizzard_CombatLog",
	"Blizzard_CombatText",
	"Blizzard_CompactRaidFrames",
	"Blizzard_CUFProfiles",
	"Blizzard_DeathRecap",
	"Blizzard_DebugTools",
	"Blizzard_EncounterJournal",
	"Blizzard_FlightMap",
	"Blizzard_GarrisonTemplates",
	"Blizzard_GarrisonUI",
	"Blizzard_GlyphUI",
	"Blizzard_GMChatUI",
	"Blizzard_GMSurveyUI",
	"Blizzard_GuildBankUI",
	"Blizzard_GuildControlUI",
	"Blizzard_GuildUI",
	"Blizzard_InspectUI",
	"Blizzard_ItemSocketingUI",
	"Blizzard_ItemUpgradeUI",
	"Blizzard_LookingForGuildUI",
	"Blizzard_MacroUI",
	"Blizzard_MapCanvas",
	"Blizzard_MovePad",
	"Blizzard_NamePlates",
	"Blizzard_ObjectiveTracker",
	"Blizzard_ObliterumUI",
	"Blizzard_OrderHallUI",
	"Blizzard_PetBattleUI",
	"Blizzard_PVPUI",
	"Blizzard_QuestChoice",
	"Blizzard_RaidUI",
	"Blizzard_SecureTransferUI",
	"Blizzard_SharedMapDataProviders",
	"Blizzard_SocialUI",
	"Blizzard_StoreUI",
	"Blizzard_TalentUI",
	"Blizzard_TalkingHeadUI",
	"Blizzard_TimeManager",
	"Blizzard_TokenUI",
	"Blizzard_TradeSkillUI",
	"Blizzard_TrainerUI",
	"Blizzard_Tutorial",
	"Blizzard_TutorialTemplates",
	"Blizzard_VoidStorageUI",
	"Blizzard_WowTokenUI",
}

function K.EnableBlizzardAddOns()
	for _, addon in pairs(BLIZZARD_ADDONS) do
		local reason = select(5, GetAddOnInfo(addon))
		if reason == "DISABLED" then
			EnableAddOn(addon)
			K.Print(L["Commands"].BlizzardAddOnsOn, addon)
		end
	end
end
K:RegisterChatCommand("enableblizz", K.EnableBlizzardAddOns)
K:RegisterChatCommand("fixblizz", K.EnableBlizzardAddOns)

-- Test blizzard alert frames
SlashCmdList.TEST_ACHIEVEMENT = function()
	PlaySound(SOUNDKIT.LFG_REWARDS)
	if not AchievementFrame then
		AchievementFrame_LoadUI()
	end
	AchievementAlertSystem:AddAlert(112)
	CriteriaAlertSystem:AddAlert(9023, "Doing great!")
	GuildChallengeAlertSystem:AddAlert(3, 2, 5)
	InvasionAlertSystem:AddAlert(678, "Legion", true, 1, 1)
	GarrisonShipFollowerAlertSystem:AddAlert(592, "Ship", "Transport", "GarrBuilding_Barracks_1_H", 3, 2, 1)
	GarrisonBuildingAlertSystem:AddAlert("Barracks")
	LegendaryItemAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832:0:0:0:0:0:0:0:0:0:0\124h[Brutality Blade]\124h\124r")
	LootAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 100, 2, false, false, 0, false, false)
	LootUpgradeAlertSystem:AddAlert("\124cffa335ee\124Hitem:18832::::::::::\124h[Brutality Blade]\124h\124r", 1, 1, 1, nil, nil, false)
	MoneyWonAlertSystem:AddAlert(815)
	StorePurchaseAlertSystem:AddAlert("\124cffa335ee\124Hitem:180545::::::::::\124h[Mystic Runesaber]\124h\124r", "", "", 214)
	DigsiteCompleteAlertSystem:AddAlert(1)
	NewRecipeLearnedAlertSystem:AddAlert(204)
end
_G.SLASH_TEST_ACHIEVEMENT1 = "/testa"

-- Test Blizzard Extra Action Button
SlashCmdList.TEST_EXTRABUTTON = function()
	if ExtraActionBarFrame:IsShown() then
		ExtraActionBarFrame:Hide()
	else
		ExtraActionBarFrame:Show()
		ExtraActionBarFrame:SetAlpha(1)
		ExtraActionButton1:Show()
		ExtraActionButton1:SetAlpha(1)
		ExtraActionButton1.icon:SetTexture("Interface\\Icons\\spell_deathknight_breathofsindragosa")
		ExtraActionButton1.icon:Show()
		ExtraActionButton1.icon:SetAlpha(1)
	end
end
_G.SLASH_TEST_EXTRABUTTON1 = "/teb"

-- Reduce video settings to optimize performance
function K.BoostUI()
	SetCVar("SSAO", 0)
	SetCVar("ShadowTextureSize", 1024)
	SetCVar("environmentDetail", 60)
	SetCVar("farclip", 500)
	SetCVar("groundeffectdensity", 16)
	SetCVar("groundeffectdist", 1)
	SetCVar("hwPCF", 1)
	SetCVar("reflectionMode", 0)
	SetCVar("shadowMode", 0)
	SetCVar("showfootprintparticles", 0)
	SetCVar("skycloudlod", 1)
	SetCVar("timingmethod", 1)
	SetCVar("waterDetail", 0)
	SetCVar("weatherDensity", 0)
	K.StaticPopup_Show("BOOST_UI")
	K.StaticPopup_Show("CHANGES_RL")
end

_G.SLASH_BOOSTUI1 = "/boostfps"
_G.SLASH_BOOSTUI2 = "/boostui"
SlashCmdList.BOOSTUI = function()
	K.StaticPopup_Show("BOOST_UI")
end