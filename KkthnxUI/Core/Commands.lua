local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local string_find = _G.string.find
local string_gsub = _G.string.gsub
local string_lower = _G.string.lower
local string_split = _G.string.split
local string_trim = _G.string.trim
local table_insert = _G.table.insert
local table_remove = _G.table.remove

-- Wow API
local AbandonQuest = _G.AbandonQuest
local CombatLogClearEntries = _G.CombatLogClearEntries
local ConvertToParty = _G.ConvertToParty
local ConvertToRaid = _G.ConvertToRaid
local DisableAllAddOns = _G.DisableAllAddOns
local DoReadyCheck = _G.DoReadyCheck
local EnableAddOn = _G.EnableAddOn
local ERR_NOT_IN_GROUP = _G.ERR_NOT_IN_GROUP
-- local GetCurrentResolution = _G.GetCurrentResolution
-- local GetCVarBool = _G.GetCVarBool
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
-- local GetRaidRosterInfo = _G.GetRaidRosterInfo
local GetRealmName = _G.GetRealmName
-- local GetScreenResolutions = _G.GetScreenResolutions
-- local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local LeaveParty = _G.LeaveParty
local LFGTeleport = _G.LFGTeleport
-- local MAX_PARTY_MEMBERS = _G.MAX_PARTY_MEMBERS
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
-- local PlaySound = _G.PlaySound
local ReloadUI = _G.ReloadUI
local RepopMe = _G.RepopMe
local RetrieveCorpse = _G.RetrieveCorpse
local SelectQuestLogEntry = _G.SelectQuestLogEntry
-- local SendChatMessage = _G.SendChatMessage
local SetAbandonQuest = _G.SetAbandonQuest
local SetCVar = _G.SetCVar
local SlashCmdList = _G.SlashCmdList
-- local UninviteUnit = _G.UninviteUnit
-- local UnitExists = _G.UnitExists
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
SlashCmdList["KKUI_CONFIGUI"] = function()
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
SLASH_KKUI_CONFIGUI1 = "/config"
SLASH_KKUI_CONFIGUI2 = "/configui"
SLASH_KKUI_CONFIGUI3 = "/cfg"

SlashCmdList["KKUI_RESETNAMEPLATESVARS"] = function()
	K:GetModule("Unitframes"):NameplatesVarsReset()
end
SLASH_KKUI_RESETNAMEPLATESVARS1 = "/fixplates"
SLASH_KKUI_RESETNAMEPLATESVARS2 = "/resetnameplates"
SLASH_KKUI_RESETNAMEPLATESVARS3 = "/resetplates"
SLASH_KKUI_RESETNAMEPLATESVARS4 = "/rnp"

-- Profiles data/listings
SlashCmdList["KKUI_UIPROFILES"] = function(msg)
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

				if Server ~= "Gold" and Server ~= "Class" then
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

							K.Print(L["Profile"] .. #KkthnxUI.Profiles.Data..": ["..Server.."] - ["..Character.."]")
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
					K.Print(L["ProfileNotFound"])
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
						if Server ~= "Gold" and Server ~= "Class" then
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
					K.Print(L["Profile"] .. #KkthnxUI.Profiles.Data .. L["ProfileDel"] .. "["..ServerName.."] - ["..CharacterName.."]")

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
										K.Print(L["Profile"] ..Profile..": ["..Server.."] - ["..Character.."]")
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
				K.Print(L["ProfileNotFound"])
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
SLASH_KKUI_UIPROFILES1 = "/profile"
SLASH_KKUI_UIPROFILES2 = "/profiles"

-- Fixes the issue when the dialog to release spirit does not come up.
SlashCmdList["KKUI_FIXRELEASE"] = function()
	RetrieveCorpse()
	RepopMe()
end
SLASH_KKUI_FIXRELEASE1 = "/release"
SLASH_KKUI_FIXRELEASE2 = "/repop"

-- Fixes the issue when players get stuck in party on felsong.
SlashCmdList["KKUI_FIXPARTY"] = function()
	LeaveParty()
	print(L["FixParty"])
end
SLASH_KKUI_FIXPARTY1 = "/killparty"
SLASH_KKUI_FIXPARTY2 = "/leaveparty"

-- Ready check
SlashCmdList["KKUI_READYCHECK"] = function()
	DoReadyCheck()
end
SLASH_KKUI_READYCHECK1 = "/rc"

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
SLASH_KKUI_CHECKQUESTSTATUS1 = "/checkquest"
SLASH_KKUI_CHECKQUESTSTATUS2 = "/questcheck"

-- Help frame.
SlashCmdList["KKUI_GMTICKET"] = function()
	ToggleHelpFrame()
end
SLASH_KKUI_GMTICKET1 = "/gm"
SLASH_KKUI_GMTICKET2 = "/ticket"

SlashCmdList["KKUI_DELETEQUESTITEMS"] = function()
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
SLASH_KKUI_DELETEQUESTITEMS1 = "/deletequestitems"
SLASH_KKUI_DELETEQUESTITEMS2 = "/dqi"

SlashCmdList["KKUI_DELETEHEIRLOOMS"] = function()
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
SLASH_KKUI_DELETEHEIRLOOMS1 = "/deleteheirlooms"
SLASH_KKUI_DELETEHEIRLOOMS2 = "/deletelooms"

SlashCmdList["KKUI_RESETINSTANCE"] = function()
	ResetInstances()
end
SLASH_KKUI_RESETINSTANCE1 = "/ri"
SLASH_KKUI_RESETINSTANCE2 = "/instancereset"
SLASH_KKUI_RESETINSTANCE3 = "/resetinstance"

-- Toggle the binding frame incase we unbind esc.
SlashCmdList["KKUI_KEYBINDFRAME"] = function()
	if not KeyBindingFrame then
		KeyBindingFrame_LoadUI()
	end

	ShowUIPanel(KeyBindingFrame)
end
SLASH_KKUI_KEYBINDFRAME1 = "/binds"

-- Fix The CombatLog.
SlashCmdList["KKUI_CLEARCOMBATLOG"] = function()
	CombatLogClearEntries()
end
SLASH_KKUI_CLEARCOMBATLOG1 = "/clearcombat"
SLASH_KKUI_CLEARCOMBATLOG2 = "/clfix"

-- Here we can restart wow's engine. could be use for sound issues and more.
SlashCmdList["KKUI_FIXGFXENGINE"] = function()
	K.StaticPopup_Show("RESTART_GFX")
end
SLASH_KKUI_FIXGFXENGINE1 = "/restartgfx"
SLASH_KKUI_FIXGFXENGINE2 = "/fixgfx"

-- Clear all quests in questlog
SlashCmdList["KKUI_ABANDONQUESTS"] = function()
	local numEntries, numQuests = GetNumQuestLogEntries()
	for questLogIndex = 1, numEntries do
		local questTitle, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questLogIndex)

		if (not isHeader) then
			SelectQuestLogEntry(questLogIndex)
			SetAbandonQuest()
			AbandonQuest()
		end
	end
end
SLASH_KKUI_ABANDONQUESTS1 = "/killquests"
SLASH_KKUI_ABANDONQUESTS2 = "/clearquests"

-- KkthnxUI help commands
SlashCmdList["KKUI_COMMANDSHELPS"] = function()
	print(L["Commands"].UIHelp)
end
SLASH_KKUI_COMMANDSHELPS1 = "/helpui"

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

-- Instance teleport
SlashCmdList["INSTTELEPORT"] = function()
	local inInstance = IsInInstance()
	if inInstance then
		LFGTeleport(true)
	else
		LFGTeleport()
	end
end
_G.SLASH_INSTTELEPORT1 = "/teleport"

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
		DBM:DemoMode()
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