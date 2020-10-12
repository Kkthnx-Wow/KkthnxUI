local K, C, L = unpack(select(2, ...))

local _G = _G
local pairs = _G.pairs
local print = _G.print
local string_find = _G.string.find
local string_gsub = _G.string.gsub
local string_lower = _G.string.lower
local string_split = _G.string.split
local string_trim = _G.string.trim
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local type = _G.type
local tonumber = _G.tonumber

local ACCEPT = _G.ACCEPT
local C_QuestLog_GetNumQuestLogEntries = _G.C_QuestLog.GetNumQuestLogEntries
local CANCEL = _G.CANCEL
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
local C_QuestLog_GetTitleForLogIndex = _G.C_QuestLog.GetTitleForLogIndex
local C_QuestLog_SetSelectedQuest = _G.C_QuestLog.SetSelectedQuest
local C_QuestLog_IsQuestFlaggedCompleted = _G.C_QuestLog.IsQuestFlaggedCompleted
local LeaveParty = _G.LeaveParty
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySound = _G.PlaySound
local ReloadUI = _G.ReloadUI
local RepopMe = _G.RepopMe
local RetrieveCorpse = _G.RetrieveCorpse
local C_QuestLog_SetAbandonQuest = _G.C_QuestLog.SetAbandonQuest
local C_QuestLog_AbandonQuest = _G.C_QuestLog.AbandonQuest
local SetCVar = _G.SetCVar
local SlashCmdList = _G.SlashCmdList
local UIErrorsFrame = _G.UIErrorsFrame
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitIsGroupLeader = _G.UnitIsGroupLeader

local SelectedProfile = 0

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

-- Profiles data/listings
SlashCmdList["KKUI_UIPROFILES"] = function(msg)
	if not KkthnxUIData then
		return
	end

	if not msg or msg == "" then
		print(" ")
		K.Print("/profile list")
		print(" List current profiles available")
		K.Print("/profile #")
		print(" Apply a profile, replace '#' with a profile number")
		K.Print("/profile delete #")
		print(" Delete a profile, replace '#' with a profile number")
		print(" ")
	else
		-- Split the msg into multiple arguments.
		-- This function will return any number of arguments.
		local command, arg1 = parseArguments(msg)
		if msg == "list" or msg == "l" then
			KkthnxUI.Profiles = {}
			KkthnxUI.Profiles.Data = {}
			KkthnxUI.Profiles.Options = {}

			local EmptyTable = {}
			for Server, Table in pairs(KkthnxUIData) do
				if not Server then
					return
				end

				if type(KkthnxUIData[Server]) == "table" then
					for Character, Table in pairs(KkthnxUIData[Server]) do
						table_insert(KkthnxUI.Profiles.Data, KkthnxUIData[Server][Character])

						-- GUI options, it can be not found if you didn't log at least once since version 1.10 on that toon.
						if KkthnxUISettingsPerCharacter and KkthnxUISettingsPerCharacter[Server] and KkthnxUISettingsPerCharacter[Server][Character] then
							table_insert(KkthnxUI.Profiles.Options, KkthnxUISettingsPerCharacter[Server][Character])
						else
							table_insert(KkthnxUI.Profiles.Options, EmptyTable)
						end

						K.Print(L["Profile"]..#KkthnxUI.Profiles.Data..": ["..Server.."] - ["..Character.."]")
					end
				end
			end
		elseif command == "delete" or command == "del" then
			-- Only do this if the user previously has done a /profile list,
			-- and an indexed listing of the profiles is actually available.
			if KkthnxUI.Profiles and KkthnxUI.Profiles.Data then
				-- Retrieve the profile ID
				SelectedProfile = tonumber(arg1)
				-- Retrieve the profile table
				local Data = KkthnxUI.Profiles.Data[SelectedProfile]
				-- Return an error if the user entered a non existing profile
				if not Data then
					K.Print(L["ProfileNotFound"])
					return
				else
					if Data == KkthnxUIData[K.Realm][K.Name] then
						local Installer = K:GetModule("Installer")
						Installer:ResetSettings()
						Installer:ResetData()
					end

					local CharacterName, ServerName
					local found

					-- Search through the stored data for the matching table
					for Server, Table in pairs(KkthnxUIData) do
						if type(KkthnxUIData[Server]) == "table" then
							for Character, Table in pairs(KkthnxUIData[Server]) do
								if Table == Data then
									CharacterName = Character
									ServerName = Server
									KkthnxUIData[Server][Character] = nil
									KkthnxUISettingsPerCharacter[Server][Character] = nil
									found = true
									break
								end
							end
						end

						if found then
							break
						end
					end

					-- Delete the profile listing entries too.
					table_remove(KkthnxUI.Profiles.Data, SelectedProfile)
					table_remove(KkthnxUI.Profiles.Options, SelectedProfile)

					-- Tell the user about the deletion
					K.Print(L["Profile"]..#KkthnxUI.Profiles.Data..L["ProfileDel"].."["..ServerName.."] - ["..CharacterName.."]")

					-- Do a new listing to show the users the order now,
					-- in case they wish to delete more profiles.
					-- First iterate through the indexed profile table
					for SelectedProfile = 1, #KkthnxUI.Profiles.Data do
						local Data = KkthnxUI.Profiles.Data[SelectedProfile]

						-- Search through the saved data for the matching table,
						-- so we can get the character and server names.
						local found
						for Server, Table in pairs(KkthnxUIData) do
							for Character, Table in pairs(KkthnxUIData[Server]) do
								-- We found the matching table so we break and exit this loop,
								-- to allow the outer iteration loop to continue faster.
								if Table == Data then
									K.Print(L["Profile"] ..SelectedProfile..": ["..Server.."] - ["..Character.."]")
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
		else
			SelectedProfile = tonumber(msg)
			if not KkthnxUI.Profiles or not KkthnxUI.Profiles.Data[SelectedProfile] then
				K.Print(L["ProfileNotFound"])
				return
			end

			K.StaticPopup_Show("KKUI_IMPORT_PROFILE")
		end
	end
end
_G.SLASH_KKUI_UIPROFILES1 = "/profile"
_G.SLASH_KKUI_UIPROFILES2 = "/profiles"

-- Create a KkthnxUI popup for profiles
K.PopupDialogs["KKUI_IMPORT_PROFILE"] = {
	text = "Are you sure you want to import this profile? Continue?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		KkthnxUIData[K.Realm][K.Name] = KkthnxUI.Profiles.Data[SelectedProfile]

		if KkthnxUISettingsPerCharacter[K.Realm][K.Name].General and KkthnxUISettingsPerCharacter[K.Realm][K.Name].General.UseGlobal then
			-- Look like we use globals for gui, don't import gui settings, keep globals
		else
			KkthnxUISettingsPerCharacter[K.Realm][K.Name] = KkthnxUI.Profiles.Options[SelectedProfile]
		end

		ReloadUI()
	end,
}

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
	local numShownEntries, numQuests = C_QuestLog_GetNumQuestLogEntries()
	for questLogIndex = 1, numShownEntries do
		local _, _, _, title = C_QuestLog_GetTitleForLogIndex(questLogIndex)

		if (not title) then
			C_QuestLog_SetSelectedQuest(questLogIndex)
			C_QuestLog_SetAbandonQuest()
			C_QuestLog_AbandonQuest()
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