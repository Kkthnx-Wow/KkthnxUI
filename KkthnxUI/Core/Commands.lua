local K, _, L = unpack(select(2, ...))

local _G = _G
local print = _G.print
local string_lower = _G.string.lower
local string_trim = _G.string.trim
local tonumber = _G.tonumber

local C_QuestLog_AbandonQuest = _G.C_QuestLog.AbandonQuest
local C_QuestLog_GetInfo = _G.C_QuestLog.GetInfo
local C_QuestLog_GetNumQuestLogEntries = _G.C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_IsQuestFlaggedCompleted = _G.C_QuestLog.IsQuestFlaggedCompleted
local C_QuestLog_SetAbandonQuest = _G.C_QuestLog.SetAbandonQuest
local C_QuestLog_SetSelectedQuest = _G.C_QuestLog.SetSelectedQuest
local CombatLogClearEntries = _G.CombatLogClearEntries
local ConvertToParty = _G.ConvertToParty
local ConvertToRaid = _G.ConvertToRaid
local DoReadyCheck = _G.DoReadyCheck
local ERR_NOT_IN_GROUP = _G.ERR_NOT_IN_GROUP
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetItemInfo = _G.GetItemInfo
local GetLocale = _G.GetLocale
local GetNumGroupMembers = _G.GetNumGroupMembers
local LeaveParty = _G.LeaveParty
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySound = _G.PlaySound
local RepopMe = _G.RepopMe
local RetrieveCorpse = _G.RetrieveCorpse
local SetCVar = _G.SetCVar
local SlashCmdList = _G.SlashCmdList
local UIErrorsFrame = _G.UIErrorsFrame
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsGroupLeader = _G.UnitIsGroupLeader

-- Profiles data/listings
SlashCmdList["KKUI_UIPROFILES"] = function(msg)
	if msg == "" or msg == "list" or msg == "l" then
		K.Print("This command no longer has purpose. Please open KkthnxUI GUI and go to General and use the profile dropdown to pick the profile you want!")
	end
end
_G.SLASH_KKUI_UIPROFILES1 = "/profile"
_G.SLASH_KKUI_UIPROFILES2 = "/profiles"

-- Fixes the issue when the dialog to release spirit does not come up.
SlashCmdList["KKUI_FIXRELEASE"] = function()
	RetrieveCorpse()
	RepopMe()
end
_G.SLASH_KKUI_FIXRELEASE1 = "/release"
_G.SLASH_KKUI_FIXRELEASE2 = "/repop"

-- Fixes the issue when players get stuck in party on felsong.
SlashCmdList["KKUI_FIXPARTY"] = function()
	LeaveParty()
	print(L["FixParty"])
end
_G.SLASH_KKUI_FIXPARTY1 = "/killparty"
_G.SLASH_KKUI_FIXPARTY2 = "/leaveparty"

-- Ready check
SlashCmdList["KKUI_READYCHECK"] = function()
	DoReadyCheck()
end
_G.SLASH_KKUI_READYCHECK1 = "/rc"

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
SlashCmdList["KKUI_CHECKQUESTSTATUS"] = function(questid)
	questid = tonumber(questid)

	if not questid then
		print(L["CheckQuestInfo"])
		-- print("Enter questID found in Wowhead URL")
		-- print("http://wowhead.com/quest=ID")
		-- print("Example: /checkquest 12045")

		K.StaticPopup_Show("QUEST_CHECK_ID")
		return
	end

	if (C_QuestLog_IsQuestFlaggedCompleted(questid) == true) then
		UIErrorsFrame:AddMessage(QuestCheckComplete.."Quest ".. "|CFFFFFF00["..questid.."]|r"..L["CheckQuestComplete"])
		PlaySound("878")
		K.Print(WoWHeadLoc..questid)
	else
		UIErrorsFrame:AddMessage(QuestCheckIncomplete.."Quest ".. "|CFFFFFF00["..questid.."]|r"..L["CheckQuestNotComplete"])
		PlaySound("847")
		K.Print(WoWHeadLoc..questid)
	end
end
_G.SLASH_KKUI_CHECKQUESTSTATUS1 = "/checkquest"
_G.SLASH_KKUI_CHECKQUESTSTATUS2 = "/questcheck"

-- Help frame.
SlashCmdList["KKUI_GMTICKET"] = function()
	_G.ToggleHelpFrame()
end
_G.SLASH_KKUI_GMTICKET1 = "/gm"
_G.SLASH_KKUI_GMTICKET2 = "/ticket"

SlashCmdList["KKUI_DELETEQUESTITEMS"] = function()
	for bag = 0, 4 do
		for slot = 1, _G.GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag, slot)
			if itemLink and select(12, GetItemInfo(itemLink)) == _G.LE_ITEM_CLASS_QUESTITEM then
				_G.print(itemLink)
				_G.PickupContainerItem(bag, slot) _G.DeleteCursorItem()
			end
		end
	end
end
_G.SLASH_KKUI_DELETEQUESTITEMS1 = "/deletequestitems"
_G.SLASH_KKUI_DELETEQUESTITEMS2 = "/dqi"

SlashCmdList["KKUI_DELETEHEIRLOOMS"] = function()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local name = GetContainerItemLink(bag,slot)
			if name and string.find(name,"00ccff") then
				print(name)
				_G.PickupContainerItem(bag,slot)
				_G.DeleteCursorItem()
			end
		end
	end
end
_G.SLASH_KKUI_DELETEHEIRLOOMS1 = "/deleteheirlooms"
_G.SLASH_KKUI_DELETEHEIRLOOMS2 = "/deletelooms"

SlashCmdList["KKUI_RESETINSTANCE"] = function()
	_G.ResetInstances()
end
_G.SLASH_KKUI_RESETINSTANCE1 = "/ri"
_G.SLASH_KKUI_RESETINSTANCE2 = "/instancereset"
_G.SLASH_KKUI_RESETINSTANCE3 = "/resetinstance"

-- Toggle the binding frame incase we unbind esc.
SlashCmdList["KKUI_KEYBINDFRAME"] = function()
	if not _G.KeyBindingFrame then
		_G.KeyBindingFrame_LoadUI()
	end

	_G.ShowUIPanel(_G.KeyBindingFrame)
end
_G.SLASH_KKUI_KEYBINDFRAME1 = "/binds"

-- Fix The CombatLog.
SlashCmdList["KKUI_CLEARCOMBATLOG"] = function()
	CombatLogClearEntries()
end
_G.SLASH_KKUI_CLEARCOMBATLOG1 = "/clearcombat"
_G.SLASH_KKUI_CLEARCOMBATLOG2 = "/clfix"

-- Here we can restart wow"s engine. could be use for sound issues and more.
SlashCmdList["KKUI_FIXGFXENGINE"] = function()
	K.StaticPopup_Show("RESTART_GFX")
end
_G.SLASH_KKUI_FIXGFXENGINE1 = "/restartgfx"
_G.SLASH_KKUI_FIXGFXENGINE2 = "/fixgfx"

-- Clear all quests in questlog
SlashCmdList["KKUI_ABANDONQUESTS"] = function()
	local numShownEntries = C_QuestLog_GetNumQuestLogEntries()
	for questLogIndex = 1, numShownEntries do
		local info = C_QuestLog_GetInfo(questLogIndex)
		local questID = info.questID
		local isHeader = info.isHeader

		if (not isHeader) then
			C_QuestLog_SetSelectedQuest(questID)
			C_QuestLog_SetAbandonQuest()
			C_QuestLog_AbandonQuest()
			PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST)
		end
	end
end
_G.SLASH_KKUI_ABANDONQUESTS1 = "/killquests"
_G.SLASH_KKUI_ABANDONQUESTS2 = "/clearquests"

-- KkthnxUI help commands
SlashCmdList["KKUI_COMMANDSHELPS"] = function()
	print(L["Commands"].UIHelp)
end
_G.SLASH_KKUI_COMMANDSHELPS1 = "/helpui"

-- Convert party to raid
SlashCmdList["PARTYTORAID"] = function()
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

SlashCmdList["VOLUME"] = function(value)
	local numValue = tonumber(value)
	if numValue and 0 <= numValue and numValue <= 1 then
		SetCVar("Sound_MasterVolume", numValue)
	end
end
_G.SLASH_VOLUME1 = "/vol"

SlashCmdList["FPS"] = function(value)
	local numValue = tonumber(value)
	if numValue and 0 <= numValue then
		SetCVar("maxFPS", numValue)
	end
end
_G.SLASH_FPS1 = "/fps"

-- Deadly boss mods testing.
SlashCmdList["DBMTEST"] = function()
	if K.CheckAddOnState("DBM-Core") then
		_G.DBM:DemoMode()
	end
end
_G.SLASH_DBMTEST1 = "/dbmtest"

-- Clear chat
SlashCmdList["CLEARCHAT"] = function(cmd)
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