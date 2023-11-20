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

-- EventTrace
local EventTraceEnabled = true
local EventTrace = CreateFrame("Frame")
EventTrace:SetScript("OnEvent", function(_, event)
	if event ~= "GET_ITEM_INFO_RECEIVED" and event ~= "COMBAT_LOG_EVENT_UNFILTERED" then
		K.Print(event)
	end
end)

-- Slash Commands
SlashCmdList["KKUI_EVENTTRACE"] = function()
	if EventTraceEnabled then
		EventTrace:UnregisterAllEvents()
		EventTraceEnabled = false
	else
		EventTrace:RegisterAllEvents()
		EventTraceEnabled = true
	end
end
_G.SLASH_KKUI_EVENTTRACE1 = "/kkevent"
_G.SLASH_KKUI_EVENTTRACE2 = "/kkevents"

SlashCmdList["KKUI_GUI"] = function()
	K.GUI:Toggle()
end
_G.SLASH_KKUI_GUI1 = "/kkgui"
_G.SLASH_KKUI_GUI2 = "/kkconfig"

-- Volume Command
SlashCmdList["KKUI_VOLUME"] = function(val)
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
_G.SLASH_KKUI_VOLUME1 = "/kkvol"
_G.SLASH_KKUI_VOLUME2 = "/kkvolume"
_G.SLASH_KKUI_VOLUME3 = "/vol"
_G.SLASH_KKUI_VOLUME4 = "/volume"

-- Ready check
SlashCmdList["KKUI_READYCHECK"] = function()
	DoReadyCheck()
end
_G.SLASH_KKUI_READYCHECK1 = "/kkrc"

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
SlashCmdList["KKUI_CHECKQUESTSTATUS"] = function(questid)
	questid = tonumber(questid)

	if not questid then
		print(L["CheckQuestInfo"])
		_G.StaticPopup_Show("KKUI_QUEST_CHECK_ID")
		return
	end

	if C_QuestLog_IsQuestFlaggedCompleted(questid) == true then
		UIErrorsFrame:AddMessage(QuestCheckComplete .. "Quest " .. "|CFFFFFF00[" .. questid .. "]|r" .. L["CheckQuestComplete"])
		PlaySound("878")
		K.Print(WoWHeadLoc .. questid)
	else
		UIErrorsFrame:AddMessage(QuestCheckIncomplete .. "Quest " .. "|CFFFFFF00[" .. questid .. "]|r" .. L["CheckQuestNotComplete"])
		PlaySound("847")
		K.Print(WoWHeadLoc .. questid)
	end
end
_G.SLASH_KKUI_CHECKQUESTSTATUS1 = "/kkqc"
_G.SLASH_KKUI_CHECKQUESTSTATUS2 = "/kkcq"
_G.SLASH_KKUI_CHECKQUESTSTATUS3 = "/kkcheckquest"
_G.SLASH_KKUI_CHECKQUESTSTATUS4 = "/kkquestcheck"

-- Help frame.
SlashCmdList["KKUI_GMTICKET"] = function()
	_G.ToggleHelpFrame()
end
_G.SLASH_KKUI_GMTICKET1 = "/gm"
_G.SLASH_KKUI_GMTICKET2 = "/ticket"

-- Delete Quest Items
SlashCmdList["KKUI_DELETEQUESTITEMS"] = function()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local itemLink = GetContainerItemLink(bag, slot)
			if itemLink and select(12, GetItemInfo(itemLink)) == _G.LE_ITEM_CLASS_QUESTITEM then
				_G.print(itemLink)
				_G.PickupContainerItem(bag, slot)
				_G.DeleteCursorItem()
			end
		end
	end
end
_G.SLASH_KKUI_DELETEQUESTITEMS1 = "/deletequestitems"
_G.SLASH_KKUI_DELETEQUESTITEMS2 = "/dqi"

-- Delete Heirlooms
SlashCmdList["KKUI_DELETEHEIRLOOMS"] = function()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local item = { GetContainerItemInfo(bag, slot) }
			if item[4] == 7 then
				_G.PickupContainerItem(bag, slot)
				_G.DeleteCursorItem()
			end
		end
	end
end
_G.SLASH_KKUI_DELETEHEIRLOOMS1 = "/deleteheirlooms"
_G.SLASH_KKUI_DELETEHEIRLOOMS2 = "/deletelooms"

-- Reset Instance
SlashCmdList["KKUI_RESETINSTANCE"] = function()
	_G.ResetInstances()
end
_G.SLASH_KKUI_RESETINSTANCE1 = "/ri"
_G.SLASH_KKUI_RESETINSTANCE2 = "/instancereset"
_G.SLASH_KKUI_RESETINSTANCE3 = "/resetinstance"

-- Keybind Frame
SlashCmdList["KKUI_KEYBINDFRAME"] = function()
	if not _G.KeyBindingFrame then
		_G.KeyBindingFrame_LoadUI()
	end

	_G.ShowUIPanel(_G.KeyBindingFrame)
end
_G.SLASH_KKUI_KEYBINDFRAME1 = "/binds"

-- Clear CombatLog
SlashCmdList["KKUI_CLEARCOMBATLOG"] = function()
	CombatLogClearEntries()
end
_G.SLASH_KKUI_CLEARCOMBATLOG1 = "/clearcombat"
_G.SLASH_KKUI_CLEARCOMBATLOG2 = "/clfix"

-- Clear Chat
SlashCmdList["CLEARCHAT"] = function(cmd)
	cmd = cmd and string_trim(string_lower(cmd))
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		if f:IsVisible() or cmd == "all" then
			f:Clear()
		end
	end
end
_G.SLASH_CLEARCHAT1 = "/clearchat"
_G.SLASH_CLEARCHAT2 = "/chatclear"
