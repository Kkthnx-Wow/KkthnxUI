local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local math_ceil = math.ceil
local math_floor = math.floor
local string_format = string.format
local string_lower = string.lower
local string_split = string.split
local string_trim = string.trim
local table_insert = table.insert

-- Wow API
local AbandonQuest = _G.AbandonQuest
local CombatLogClearEntries = _G.CombatLogClearEntries
local ConvertToParty = _G.ConvertToParty
local ConvertToRaid = _G.ConvertToRaid
local CreateFrame = _G.CreateFrame
local DisableAllAddOns = _G.DisableAllAddOns
local DoReadyCheck = _G.DoReadyCheck
local EnableAddOn = _G.EnableAddOn
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local ERR_NOT_IN_GROUP = _G.ERR_NOT_IN_GROUP
local FEATURE_BECOMES_AVAILABLE_AT_LEVEL = _G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL
local GetCurrentResolution = _G.GetCurrentResolution
local GetCVarBool = _G.GetCVarBool
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetGuildRosterLastOnline = _G.GetGuildRosterLastOnline
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetRealmName = _G.GetRealmName
local GetScreenHeight = _G.GetScreenHeight
local GetScreenResolutions = _G.GetScreenResolutions
local GetScreenWidth = _G.GetScreenWidth
local GetSpecialization = _G.GetSpecialization
local GuildControlGetNumRanks = _G.GuildControlGetNumRanks
local GuildControlGetRankName = _G.GuildControlGetRankName
local GuildUninvite = _G.GuildUninvite
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local LeaveParty = _G.LeaveParty
local LFGTeleport = _G.LFGTeleport
local MAX_PARTY_MEMBERS = _G.MAX_PARTY_MEMBERS
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySound = _G.PlaySound
local ReloadUI = _G.ReloadUI
local RepopMe = _G.RepopMe
local RestartGx = _G.RestartGx
local RetrieveCorpse = _G.RetrieveCorpse
local SelectQuestLogEntry = _G.SelectQuestLogEntry
local SendChatMessage = _G.SendChatMessage
local SetAbandonQuest = _G.SetAbandonQuest
local SetCVar = _G.SetCVar
local SetSpecialization = _G.SetSpecialization
local SHOW_TALENT_LEVEL = _G.SHOW_TALENT_LEVEL
local SlashCmdList = _G.SlashCmdList
local StaticPopup_Show = _G.StaticPopup_Show
local UIParent = _G.UIParent
local UninviteUnit = _G.UninviteUnit
local UnitExists = _G.UnitExists
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitName = _G.UnitName

-- Global variables that we don"t need to cache, list them here for mikk"s FindGlobals script
-- GLOBALS: CriteriaAlertSystem, GuildChallengeAlertSystem, InvasionAlertSystem, GarrisonShipFollowerAlertSystem
-- GLOBALS: DigsiteCompleteAlertSystem, NewRecipeLearnedAlertSystem, GridCreate, KkthnxUIConfig
-- GLOBALS: ExtraActionBarFrame, ExtraActionButton1, MoneyWonAlertSystem, StorePurchaseAlertSystem
-- GLOBALS: GarrisonBuildingAlertSystem, LegendaryItemAlertSystem, LootAlertSystem, LootUpgradeAlertSystem
-- GLOBALS: KkthnxUIConfigFrame, KkthnxUIData, KkthnxUIConfigPerAccount, KkthnxUI, KkthnxUIConfigShared
-- GLOBALS: ToggleHelpFrame, DBM, AchievementFrame, AchievementFrame_LoadUI, AchievementAlertSystem

-- TODO: Rewrite these to handle AceConsole-3.0

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

-- Profiles data/listings
function K.UIProfiles(msg)
	if not KkthnxUIData then return end

	if KkthnxUIConfigPerAccount then
		K.Print(L["Commands"].ConfigPerAccount)
		return
	end

	if not msg or msg == "" then
		K.Print("/profile list")
		K.Print("/profile #")
		print("")
	else
		if msg == "list" or msg == "l" then
			KkthnxUI.Profiles = {}
			KkthnxUI.Profiles.Data = {}
			KkthnxUI.Profiles.Options = {}

			for Server, Table in pairs(KkthnxUIData) do
				if not Server then return end
				for Character, Table in pairs(KkthnxUIData[Server]) do
					table_insert(KkthnxUI.Profiles.Data, KkthnxUIData[Server][Character])
					table_insert(KkthnxUI.Profiles.Options, KkthnxUIConfigShared[Server][Character])
					print("Profile "..#KkthnxUI.Profiles.Data..": ["..Server.."] - ["..Character.."]")
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
			KkthnxUIConfigShared[CurrentServer][CurrentCharacter] = KkthnxUI.Profiles.Options[Profile]

			ReloadUI()
		end
	end
end
K:RegisterChatCommand("profile", K.UIProfiles)
K:RegisterChatCommand("profiles", K.UIProfiles)

function K.MoveUI()
	if InCombatLockdown() then
		print(ERR_NOT_IN_COMBAT)
		return
	end

	K["Movers"]:StartOrStopMoving()
end
K:RegisterChatCommand("moveui", K.MoveUI)
K:RegisterChatCommand("movers", K.MoveUI)

function K.CleanupGuild(msg)
	local minLevel, minDays, minRankIndex = string_split(",", msg)
	minRankIndex = tonumber(minRankIndex)
	minLevel = tonumber(minLevel)
	minDays = tonumber(minDays)

	if not minLevel or not minDays then
		K.Print("Usage: /cleanguild <minLevel>, <minDays>, [<minRankIndex>]")
		return
	end

	if minDays > 31 then
		K.Print("Maximum days value must be below 32.")
		return
	end

	if not minRankIndex then minRankIndex = GuildControlGetNumRanks() - 1 end

	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex, level, _, _, note, officerNote, connected, _, classFileName = GetGuildRosterInfo(i)
		local minLevelx = minLevel

		if classFileName == "DEATHKNIGHT" then
			minLevelx = minLevelx + 55
		end

		if not connected then
			local years, months, days = GetGuildRosterLastOnline(i)
			if days ~= nil and ((years > 0 or months > 0 or days >= minDays) and rankIndex >= minRankIndex) and note ~= nil and officerNote ~= nil and (level <= minLevelx) then
				GuildUninvite(name)
			end
		end
	end

	SendChatMessage("Guild Cleanup Results: Removed all guild members below rank "..GuildControlGetRankName(minRankIndex)..", that have a minimal level of "..minLevel..", and have not been online for at least: "..minDays.." days.", "GUILD")
end
K:RegisterChatCommand("cleanguild", K.CleanupGuild)

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
	print(" ")
	print("|cff4488ff".."If you are still stuck in party, try the following".."|r")
	print(" ")
	print("|cff00ff001.|r Invite someone to a group and have them accept.")
	print("|cff00ff002.|r Convert your group to a raid.")
	print("|cff00ff003.|r Use the previous leave party command again.")
	print("|cff00ff004.|r Invite your friend back to a group.")
	print(" ")
end
K:RegisterChatCommand("killparty", K.FixParty)
K:RegisterChatCommand("leaveparty", K.FixParty)

-- Ready check
function K.ReadyCheck()
	DoReadyCheck()
end
K:RegisterChatCommand("rc", K.ReadyCheck)

-- Help frame.
function K.GMTicket()
	ToggleHelpFrame()
end
K:RegisterChatCommand("gm", K.GMTicket)

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
	RestartGx()
	StaticPopup_Show("CHANGES_RL")
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
	print("All quests have been abandoned!")
end
K:RegisterChatCommand("killquests", K.AbandonQuests)
K:RegisterChatCommand("clearquests", K.AbandonQuests)

-- KkthnxUI help commands
function K.UICommandsHelp()
	print(" ")
	print("|cff4488ff"..L["Commands"].Title.."|r")
	print(L["Commands"].Install)
	print(L["Commands"].Config)
	print(L["Commands"].Move)
	print(L["Commands"].Test)
	print(L["Commands"].Profile)
	print(" ")
end
K:RegisterChatCommand("helpui", K.UICommandsHelp)

function K.SetUIScale()
	if InCombatLockdown() or C["General"].AutoScale then
		print("KkthnxUI is already controlling the Auto UI Scale feature!")
		return
	end

	local SetUIScale = GetCVarBool("uiScale")
	if not SetUIScale then
		SetCVar("uiScale", 768 / string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
		print("Successfully set UI scale to "..768 / string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
		StaticPopup_Show("CHANGES_RL")
	end
end

SlashCmdList["SETUISCALE"] = function()
	StaticPopup_Show("SET_UISCALE")
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
	StaticPopup_Show("DISBAND_RAID")
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
		K.Print("|cffff0000Lua errors off.|r")
	else
		K.Print("|cffff0000/luaerror on - /luaerror off|r")
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

-- Test blizzard alert frames
SlashCmdList.TEST_ACHIEVEMENT = function()
	PlaySound(PlaySoundKitID and "lfg_rewards" or SOUNDKIT.LFG_REWARDS)
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

-- Grid on screen
local Grid
local BoxSize = 32

local function Grid_Show()
	if not Grid then
		GridCreate()
	elseif Grid.BoxSize ~= BoxSize then
		Grid:Hide()
		GridCreate()
	else
		Grid:Show()
	end
end

local function GridHide()
	if Grid then
		Grid:Hide()
	end
end

local isAligning = false
_G.SLASH_TOGGLE_GRID1 = "/align"
SlashCmdList.TOGGLE_GRID = function(arg)
	if isAligning then
		GridHide()
		isAligning = false
	else
		BoxSize = (math_ceil((tonumber(arg) or BoxSize) / 32) * 32)
		if BoxSize > 256 then BoxSize = 256 end
		Grid_Show()
		isAligning = true
	end
end

function GridCreate()
	Grid = CreateFrame("Frame", nil, UIParent)
	Grid.BoxSize = BoxSize
	Grid:SetAllPoints(UIParent)

	local Size = 2
	local Width = GetScreenWidth()
	local Ratio = Width / GetScreenHeight()
	local Height = GetScreenHeight() * Ratio

	local WStep = Width / BoxSize
	local HStep = Height / BoxSize

	for i = 0, BoxSize do
		local Tx = Grid:CreateTexture(nil, "BACKGROUND")
		if i == BoxSize / 2 then
			Tx:SetColorTexture(1, 0, 0, 0.5)
		else
			Tx:SetColorTexture(0, 0, 0, 0.5)
		end
		Tx:SetPoint("TOPLEFT", Grid, "TOPLEFT", i * WStep - (Size / 2), 0)
		Tx:SetPoint("BOTTOMRIGHT", Grid, "BOTTOMLEFT", i * WStep + (Size / 2), 0)
	end
	Height = GetScreenHeight()

	do
		local Tx = Grid:CreateTexture(nil, "BACKGROUND")
		Tx:SetColorTexture(1, 0, 0, 0.5)
		Tx:SetPoint("TOPLEFT", Grid, "TOPLEFT", 0, - (Height / 2) + (Size / 2))
		Tx:SetPoint("BOTTOMRIGHT", Grid, "TOPRIGHT", 0, - (Height / 2 + Size / 2))
	end

	for i = 1, math_floor((Height / 2) / HStep) do
		local Tx = Grid:CreateTexture(nil, "BACKGROUND")
		Tx:SetColorTexture(0, 0, 0, 0.5)

		Tx:SetPoint("TOPLEFT", Grid, "TOPLEFT", 0, - (Height / 2 + i * HStep) + (Size / 2))
		Tx:SetPoint("BOTTOMRIGHT", Grid, "TOPRIGHT", 0, - (Height / 2 + i * HStep + Size / 2))

		Tx = Grid:CreateTexture(nil, "BACKGROUND")
		Tx:SetColorTexture(0, 0, 0, 0.5)

		Tx:SetPoint("TOPLEFT", Grid, "TOPLEFT", 0, - (Height / 2 - i * HStep) + (Size / 2))
		Tx:SetPoint("BOTTOMRIGHT", Grid, "TOPRIGHT", 0, - (Height / 2 - i * HStep + Size / 2))
	end
end

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
	StaticPopup_Show("BOOST_UI")
	StaticPopup_Show("CHANGES_RL")
end

_G.SLASH_BOOSTUI1 = "/boostfps"
_G.SLASH_BOOSTUI2 = "/boostui"
SlashCmdList.BOOSTUI = function()
	StaticPopup_Show("BOOST_UI")
	StaticPopup_Show("CHANGES_RL")
end