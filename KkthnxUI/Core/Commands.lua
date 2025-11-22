local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

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
		UIErrorsFrame:AddMessage(QuestCheckComplete .. "Quest " .. "|CFFFFFF00[" .. questid .. "]|r" .. L["CheckQuestComplete"])
		PlaySound("878")
		K.Print(WoWHeadLoc .. questid)
	else
		UIErrorsFrame:AddMessage(QuestCheckIncomplete .. "Quest " .. "|CFFFFFF00[" .. questid .. "]|r" .. L["CheckQuestNotComplete"])
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
		text = string.format("Are you sure you want to disable |cff5C8BCF%d|r addon(s) except |cff5C8BCFKkthnxUI|r for debugging?|n|nYou can use '|cff5C8BCFkkdebug off|r' to restore them.", addonsToDisable),
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
		text = "You are about to re-enable all previously disabled addons.|n|nThanks for using |cff5C8BCFKkthnxUI|r |cffff0000<3|r",
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

-- Frame for displaying commands
local function CreateCommandWindow()
	if _G.KKUICommandWindow then
		_G.KKUICommandWindow:Show() -- Show the window if it already exists
		return
	end

	local frame = CreateFrame("Frame", "KKUICommandWindow", UIParent)
	frame:SetSize(650, 500) -- Width, Height
	frame:SetPoint("CENTER") -- Position at the center of the screen
	frame:CreateBorder()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

	-- Title Text
	frame.title = frame:CreateFontString(nil, "OVERLAY")
	frame.title:SetFontObject("GameFontHighlightLarge")
	frame.title:SetPoint("TOP", frame, "TOP", 0, -8)
	frame.title:SetText(K.InfoColor .. "Commands List|r") -- Blue color title

	local frameLogo = frame:CreateTexture(nil, "OVERLAY")
	frameLogo:SetSize(512, 256)
	frameLogo:SetBlendMode("ADD")
	frameLogo:SetAlpha(0.07)
	frameLogo:SetTexture(C["Media"].Textures.LogoTexture)
	frameLogo:SetPoint("CENTER", frame, "CENTER", 0, 0)

	-- Scroll Frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(594, 440)
	scrollFrame:SetPoint("CENTER")

	-- Scroll Child Frame
	local scrollChild = CreateFrame("Frame")
	scrollChild:SetSize(594, 440)
	scrollFrame:SetScrollChild(scrollChild)
	scrollFrame.ScrollBar:SkinScrollBar()

	-- List of commands and descriptions
	local commandsList = {
		{ "KkthnxUI Commands", "" }, -- Section title
		{ "/kk allquests", "Abandons all active quests." },
		{ "/kk checkqueststatus [questid]", "Checks the completion status of a quest." },
		{ "/kk clearchat [all]", "Clears the chat for the current window or all windows." },
		{ "/kk clearcombatlog", "Clears the combat log." },
		{ "/kk debug [on/off]", "Toggles debug mode for disabling/enabling addons." },
		{ "/kk deleteheirlooms", "Lists all heirloom items for manual deletion." },
		{ "/kk deletequestitems", "Lists all quest items for manual deletion." },
		{ "/kk gmticket", "Opens the GM ticket window." },
		{ "/kk gui", "Opens the KkthnxUI settings window." },
		{ "/kk keybindframe", "Opens the key binding window." },
		{ "/kk readycheck", "Initiates a ready check." },
		{ "/kk resetinstance", "Resets the current instance." },
		{ "/kk volume [value]", "Sets the master volume level (0 to 1)." },
		{ "/kk zonequests", "Abandons all quests from the current zone." },
		{ "General Commands", "" }, -- Section title
		{ "/debufftrack", "Opens the debuff tracking interface to manage and track debuffs in PvE and PvP." },
		{ "/getfont", "Prints the font name, size, and flags of a specified global font object." },
		{ "/getframe", "Gets the frame names under the mouse." },
		{ "/getinstance", "Prints the current instance name and ID." },
		{ "/getnpc", "Prints the target's NPC name and ID." },
		{ "/getspell", "Gets spell information by name or ID." },
		{ "/gettip", "Enumerates all tooltips on the screen." },
		{ "/go [x] [y]", "Create a custom waypoint with the specified coordinates." },
		{ "/install", "Installs or resets KkthnxUI and opens the installation wizard." },
		{ "/jenkins", "Starts the pull countdown for the group or raid." },
		{ "/kb", "Toggles the keybinding interface for KkthnxUI." },
		{ "/kkaw", "Opens the aurawatch frame for KkthnxUI." },
		{ "/moveui", "Allows the user to move UI elements." },
		{ "/pc", "Alternative command for pull countdown." },
		{ "/rl", "Shortcut to reload the user interface quickly." },
		{ "/way [x] [y]", "Create a custom waypoint with the specified coordinates." },
	}

	-- Start positioning for the text
	local yOffset = -10

	for _, cmd in ipairs(commandsList) do
		-- Create the font string for command text
		local commandText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		commandText:SetPoint("TOPLEFT", 0, yOffset)
		commandText:SetWidth(594)
		commandText:SetJustifyH("LEFT")

		-- Check if the current entry is a section title or a command
		if cmd[2] == "" then
			-- Section title (larger font, different color)
			commandText:SetFontObject("GameFontNormalLarge")
			commandText:SetText(K.InfoColorTint .. cmd[1] .. "|r") -- Section title color
		else
			-- Regular command with hyphen and description
			commandText:SetFontObject("GameFontHighlight")
			commandText:SetText(K.InfoColor .. cmd[1] .. "|r - " .. K.SystemColor .. cmd[2] .. "|r")
		end

		-- Adjust the yOffset for the next line
		yOffset = yOffset - 26
	end

	frame:Hide() -- Hide by default

	-- Close Button
	frame.closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	frame.closeButton:SkinCloseButton()

	-- Store the frame for future use
	_G.KKUICommandWindow = frame
end

-- Open Command Window with /kkhelp
local function OpenCommandWindow()
	CreateCommandWindow()
	_G.KKUICommandWindow:Show()
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
	help = OpenCommandWindow,
	-- Add more commands as needed...
}

-- Slash Command Handler
SlashCmdList["KKUI_COMMANDS"] = function(input)
	local command, args = strsplit(" ", input, 2)
	command = string.lower(command)

	if commandMap[command] then
		commandMap[command](args)
	else
		K.Print("Unknown command: " .. command)
	end
end
_G.SLASH_KKUI_COMMANDS1 = "/kk"

SlashCmdList["KKUI_PROFILE"] = function(msg)
	if K.ProfileGUI then
		local command = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
		if command == "show" or command == "" then
			K.ProfileGUI:Show()
		elseif command == "hide" then
			K.ProfileGUI:Hide()
		elseif command == "toggle" then
			K.ProfileGUI:Toggle()
		elseif command == "import" then
			if K.ProfileGUI.Frame and K.ProfileGUI.Frame:IsShown() then
				K.ProfileGUI:ShowImportDialog()
			else
				K.ProfileGUI:Show()
				C_Timer.After(0.2, function()
					K.ProfileGUI:ShowImportDialog()
				end)
			end
		elseif command == "export" then
			if K.ProfileGUI.Frame and K.ProfileGUI.Frame:IsShown() then
				K.ProfileGUI:ShowExportDialog()
			else
				K.ProfileGUI:Show()
				C_Timer.After(0.2, function()
					K.ProfileGUI:ShowExportDialog()
				end)
			end
		elseif command == "help" then
			print("|cff669DFFKkthnxUI Profile Manager:|r")
			print("  |cffffffffUsage: /profile <command>|r")
			print("  |cff00ff00show|r - Show profile manager")
			print("  |cff00ff00hide|r - Hide profile manager")
			print("  |cff00ff00toggle|r - Toggle profile manager")
			print("  |cff00ff00import|r - Open import dialog")
			print("  |cff00ff00export|r - Open export dialog")
			print("  |cff00ff00help|r - Show this help")
		else
			print("|cff669DFFKkthnxUI Profile Manager:|r Unknown command '" .. command .. "'. Use '/profile help' for available commands.")
		end
	else
		print("|cff669DFFKkthnxUI:|r ProfileGUI system not available.")
	end
end
_G.SLASH_KKUI_PROFILE1 = "/profile"
_G.SLASH_KKUI_PROFILE2 = "/kprofile"
_G.SLASH_KKUI_PROFILE3 = "/kkthnxprofile"
