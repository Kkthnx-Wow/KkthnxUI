local K, L = KkthnxUI[1], KkthnxUI[3]

-- Utility Functions
local print = print
local string_format = string.format
local string_lower = string.lower
local string_trim = string.trim
local tonumber = tonumber

-- WoW API Functions
local C_QuestLog_IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local CombatLogClearEntries = CombatLogClearEntries
local DoReadyCheck = DoReadyCheck
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetItemInfo = GetItemInfo
local PlaySound = PlaySound
local UIErrorsFrame = UIErrorsFrame

-- Event Trace
local EventTraceEnabled = true
local EventTrace = CreateFrame("Frame")
EventTrace:SetScript("OnEvent", function(_, event)
	if event ~= "GET_ITEM_INFO_RECEIVED" and event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
		K.Print(event)
	end
end)

-- Command Functions
local function ToggleEventTrace()
	if EventTraceEnabled then
		EventTrace:UnregisterAllEvents()
		EventTraceEnabled = false
	else
		EventTrace:RegisterAllEvents()
		EventTraceEnabled = true
	end
end

local function ToggleGUI()
	K.GUI:Toggle()
end

local function SetVolume(val)
	local new = tonumber(val)
	local old = tonumber(GetCVar("Sound_MasterVolume"))
	if new == old then
		K.Print(string_format("Volume is already set to |cffa0f6aa%s|r.", old))
	elseif new and 0 <= new and new <= 1 then
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
			return
		end
		SetCVar("Sound_MasterVolume", new)
		K.Print(string_format("Volume is now set to |cffa0f6aa%.2f|r, was |cffa0f6aa%.2f|r.", new, old))
	else
		K.Print(string_format("Volume is currently set to |cffa0f6aa%.2f|r.", old))
	end
end

local function DoReadyCheckCommand()
	DoReadyCheck()
end

-- Quest Check
local QuestCheckSubDomain = (setmetatable({
	ruRU = "ru",
	frFR = "fr",
	deDE = "de",
	esES = "es",
	esMX = "es",
	ptBR = "pt",
	ptPT = "pt",
	itIT = "it",
	koKR = "ko",
	zhTW = "cn",
	zhCN = "cn",
}, {
	__index = function()
		return "www"
	end,
}))[K.Client]

local WoWHeadLoc = QuestCheckSubDomain .. ".wowhead.com/quest="
local QuestCheckComplete = "|TInterfaceRaidFrameReadyCheck-Ready:14:14:-1:-1|t"
local QuestCheckIncomplete = "|TInterfaceRaidFrameReadyCheck-NotReady:14:14:-1:-1|t"
local function CheckQuestStatus(questid)
	questid = tonumber(questid)

	if not questid then
		print(L["CheckQuestInfo"])
		_G.StaticPopup_Show("KKUI_QUEST_CHECK_ID")
		return
	end

	if C_QuestLog_IsQuestFlaggedCompleted(questid) == true then
		UIErrorsFrame:AddMessage(
			QuestCheckComplete .. "Quest " .. "|CFFFFFF00[" .. questid .. "]|r" .. L["CheckQuestComplete"]
		)
		PlaySound("878")
		K.Print(WoWHeadLoc .. questid)
	else
		UIErrorsFrame:AddMessage(
			QuestCheckIncomplete .. "Quest " .. "|CFFFFFF00[" .. questid .. "]|r" .. L["CheckQuestNotComplete"]
		)
		PlaySound("847")
		K.Print(WoWHeadLoc .. questid)
	end
end

local function ToggleHelpFrame()
	_G.ToggleHelpFrame()
end

local function DeleteQuestItems()
	for bag = 0, 4 do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag, slot)
			if itemLink and select(12, GetItemInfo(itemLink)) == _G.LE_ITEM_CLASS_QUESTITEM then
				_G.print("Quest Item to Delete: " .. itemLink .. " in Bag: " .. bag .. " Slot: " .. slot)
			end
		end
	end
	_G.print("Please manually delete the listed quest items.")
end

local function DeleteHeirlooms()
	for bag = 0, 4 do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local item = { GetContainerItemInfo(bag, slot) }
			if item[4] == 7 then -- Heirloom items
				_G.print("Heirloom Item to Delete: " .. item[1] .. " in Bag: " .. bag .. " Slot: " .. slot)
			end
		end
	end
	_G.print("Please manually delete the listed heirloom items.")
end

local function ResetInstance()
	_G.ResetInstances()
end

local function KeybindFrame()
	if not _G.KeyBindingFrame then
		_G.KeyBindingFrame_LoadUI()
	end

	_G.ShowUIPanel(_G.KeyBindingFrame)
end

local function ClearCombatLog()
	CombatLogClearEntries()
end

local function ClearChat(cmd)
	cmd = cmd and string_trim(string_lower(cmd))
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		if f:IsVisible() or cmd == "all" then
			f:Clear()
		end
	end
end

local function AbandonAllQuests()
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		C_QuestLog.SetSelectedQuest(C_QuestLog.GetInfo(i).questID)
		C_QuestLog.SetAbandonQuest()
		C_QuestLog.AbandonQuest()
	end
	print("All quests have been abandoned.")
end

local function AbandonZoneQuests()
	local zoneName = GetZoneText()
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(i)
		if info and not info.isHeader and info.zoneOrSort == zoneName then
			C_QuestLog.SetSelectedQuest(C_QuestLog.GetInfo(i).questID)
			C_QuestLog.SetAbandonQuest()
			C_QuestLog.AbandonQuest()
		end
	end
	print("All quests in " .. zoneName .. " have been abandoned.")
end

local function StoreAndDisableAddons()
	if next(KkthnxUIDB.DisabledAddOns) then
		print("Debug mode is already active. Use '/kkdebug off' to restore addons.")
		return
	end

	local addonCount = C_AddOns.GetNumAddOns()
	local addonsToDisable = 0

	for i = 1, addonCount do
		local name = C_AddOns.GetAddOnInfo(i)
		if name ~= "KkthnxUI" and C_AddOns.IsAddOnLoaded(name) then
			addonsToDisable = addonsToDisable + 1
		end
	end

	if addonsToDisable == 0 then
		print("All addons except KkthnxUI are already disabled.")
		return
	end

	StaticPopupDialogs["CONFIRM_DISABLE_ADDONS"] = {
		text = string.format(
			"Are you sure you want to disable |cff669DFF%d|r addon(s) except |cff669DFFKkthnxUI|r for debugging?|n|nYou can use '|cff669DFFkkdebug off|r' to restore them.",
			addonsToDisable
		),
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			for i = 1, addonCount do
				local name = C_AddOns.GetAddOnInfo(i)
				if name ~= "KkthnxUI" and C_AddOns.IsAddOnLoaded(name) then
					KkthnxUIDB.DisabledAddOns[name] = true
					C_AddOns.DisableAddOn(name)
				end
			end
			-- print(string.format("Disabled %d addon(s) for debugging. Reloading UI...", addonsToDisable)) -- Pointless
			ReloadUI()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3, -- Avoids taint
	}
	StaticPopup_Show("CONFIRM_DISABLE_ADDONS")
end

local function RestoreAddons()
	StaticPopupDialogs["CONFIRM_RESTORE_ADDONS"] = {
		text = "You are about to re-enable all previously disabled addons.|n|nThanks for using |cff669DFFKkthnxUI|r |cffff0000<3|r",
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			for name in pairs(KkthnxUIDB.DisabledAddOns) do
				C_AddOns.EnableAddOn(name)
			end

			wipe(KkthnxUIDB.DisabledAddOns)
			-- print("Addons have been restored to their previous states. Reloading UI...") -- Pointless
			ReloadUI()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3, -- Avoids taint
	}
	StaticPopup_Show("CONFIRM_RESTORE_ADDONS")
end
local function DebugMode(msg)
	if msg == "on" then
		StoreAndDisableAddons()
	elseif msg == "off" then
		RestoreAddons()
	end
end

-- Command Mapping Table
local commandMap = {
	eventtrace = ToggleEventTrace,
	gui = ToggleGUI,
	volume = SetVolume,
	readycheck = DoReadyCheckCommand,
	checkqueststatus = CheckQuestStatus,
	gmticket = ToggleHelpFrame,
	deletequestitems = DeleteQuestItems,
	deleteheirlooms = DeleteHeirlooms,
	resetinstance = ResetInstance,
	keybindframe = KeybindFrame,
	clearcombatlog = ClearCombatLog,
	clearchat = ClearChat,
	debug = DebugMode,
	allquests = AbandonAllQuests,
	zonequests = AbandonZoneQuests,
	-- Add more commands as needed...
}

-- Slash Command Handler
SlashCmdList["KKUI"] = function(input)
	local command, args = strsplit(" ", input, 2)
	command = string.lower(command)

	if commandMap[command] then
		commandMap[command](args)
	else
		K.Print("Unknown command: " .. command)
	end
end
_G.SLASH_KKUI1 = "/kk"
