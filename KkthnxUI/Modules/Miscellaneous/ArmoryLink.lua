local K, C, L = unpack(select(2, ...))
if C.Misc.Armory ~= true then return end

-- Add armory link in unitpopupmenus and lfg finder (it can break set focus)
local realmLocal = string.lower(GetCVar("portal"))
if realmLocal == "ru" then realmLocal = "eu" end

local function urlencode(obj)
	local currentIndex = 1
	local charArray = {}
	while currentIndex <= #obj do
		local char = string.byte(obj, currentIndex)
		charArray[currentIndex] = char
		currentIndex = currentIndex + 1
	end
	local converchar = ""
	for _, char in ipairs(charArray) do
		converchar = converchar..string.format("%%%X", char)
	end
	return converchar
end

local link
if K.Client == "ruRU" then
	link = "ru"
elseif K.Client == "frFR" then
	link = "fr"
elseif K.Client == "deDE" then
	link = "de"
elseif K.Client == "esES" or K.Client == "esMX" then
	link = "es"
elseif K.Client == "ptBR" or K.Client == "ptPT" then
	link = "pt"
elseif K.Client == "itIT" then
	link = "it"
elseif K.Client == "zhTW" then
	link = "zh"
elseif K.Client == "koKR" then
	link = "ko"
else
	link = "en"
end

StaticPopupDialogs.LINK_COPY_DIALOG = {
	text = L.Popup.Armory,
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self, ...) self.editBox:SetFocus() end,
	EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	preferredIndex = 3,
}

-- Clean up Blizzard server name for armory url
local function sanitizeRealmName(name, server)
	-- Parse Name-RealmName
	if name:match"-" then
		name, server = name:match"(.*)-(.*)"
	end

	-- Fallback on own realm if server doesn't exist
	if not server then
		server = GetRealmName()
		missing = true
	end

	if server:match"'" then
		-- Armory URLs dont need to split
		server = server:gsub("'", "")
	elseif missing == true then
		-- Do nothing (GetRealmName() uses spaces)
	else
		-- Split uppercase server names (BleedingHollow needs to be Bleeding Hollow)
		server1 = server:match"[A-Z][a-z]*"
		server2 = server:match"[A-Z][a-z]*(.*)"

		-- MAKE 'of' SERVERS PLAY NICE (SistersofElune)
		if server1:match"of" then
			server1 = server1:gsub("of", " Of")
		end

		-- Combine two parts of server name with space
		if server2 ~= "" then
			server = server1 .. ' ' .. server2
		else
			server = server1
		end
	end

	-- Format for armory URL
	server = server:gsub("-", "")
	server = server:gsub(" ", "-")

	return name, server
end

-- Show the dialog popup with armory link
local function showArmoryPopup(name, server)
	local inputBox = StaticPopup_Show("LINK_COPY_DIALOG")
	local missing = false

	name, server = sanitizeRealmName(name, server)

	if realmLocal == "us" or realmLocal == "eu" or realmLocal == "tw" or realmLocal == "kr" then
		if server then
			linkurl = "http://"..realmLocal..".battle.net/wow/"..link.."/character/"..server.."/"..name.."/advanced"
		else
			linkurl = "http://"..realmLocal..".battle.net/wow/"..link.."/search?q="..name.."&f=wowcharacter"
		end
		inputBox.editBox:SetText(linkurl)
		inputBox.editBox:HighlightText()
		return
	elseif realmLocal == "cn" then
		local n, r = name:match"(.*)-(.*)"
		n = n or name
		r = r or GetRealmName()

		linkurl = "http://www.battlenet.com.cn/wow/zh/character/"..urlencode(r).."/"..urlencode(n).."/advanced"
		inputBox.editBox:SetText(linkurl)
		inputBox.editBox:HighlightText()
		return
	else
		print("|cFFFFFF00Unsupported realm location.|r")
		StaticPopup_Hide("LINK_COPY_DIALOG")
		return
	end
end

-- Dropdown menu link
hooksecurefunc("UnitPopup_OnClick", function(self)
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
	local name = dropdownFrame.name
	local server = dropdownFrame.server

	if name and self.value == "ARMORYLINK" then
		showArmoryPopup(name, server)
	end
end)

UnitPopupButtons["ARMORYLINK"] = {text = L.Popup.Armory, dist = 0, func = UnitPopup_OnClick}
tinsert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["RAID"], #UnitPopupMenus["RAID"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"] - 1, "ARMORYLINK")

-- Delete some lines from unit dropdown menu (broke some line)
for _, menu in pairs(UnitPopupMenus) do
	for index = #menu, 1, -1 do
		if menu[index] == "SET_FOCUS" or menu[index] == "CLEAR_FOCUS" or menu[index] == "MOVE_PLAYER_FRAME" or menu[index] == "MOVE_TARGET_FRAME" or menu[index] == "LARGE_FOCUS" or menu[index] == "MOVE_FOCUS_FRAME" or (menu[index] == "PET_DISMISS" and K.Class == "HUNTER") then
			table.remove(menu, index)
		end
	end
end

-- LFG list applicants
local LFG_LIST_APPLICANT_MEMBER_MENU = {
	{
		text = nil, -- Player name goes here
		isTitle = true,
		notCheckable = true,
	},
	{
		text = WHISPER,
		func = function(_, name) ChatFrame_SendTell(name) end,
		notCheckable = true,
		arg1 = nil, -- Player name goes here
		disabled = nil, -- Disabled if we don't have a name yet
	},
	{
		text = L.Popup.Armory,
		func = function(_, name) showArmoryPopup(name) end,
		notCheckable = true,
		arg1 = nil, -- Player name goes here
		disabled = nil, -- Disabled if we don't have a name yet
	},
	{
		text = LFG_LIST_REPORT_FOR,
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = LFG_LIST_BAD_PLAYER_NAME,
				notCheckable = true,
				func = function(_, id, memberIdx) C_LFGList.ReportApplicant(id, "badplayername", memberIdx) end,
				arg1 = nil, -- Applicant ID goes here
				arg2 = nil, -- Applicant Member index goes here
			},
			{
				text = LFG_LIST_BAD_DESCRIPTION,
				notCheckable = true,
				func = function(_, id) C_LFGList.ReportApplicant(id, "lfglistappcomment") end,
				arg1 = nil, -- Applicant ID goes here
			},
		},
	},
	{
		text = IGNORE_PLAYER,
		notCheckable = true,
		func = function(_, name, applicantID) AddIgnore(name) C_LFGList.DeclineApplicant(applicantID) end,
		arg1 = nil, -- Player name goes here
		arg2 = nil, -- Applicant ID goes here
		disabled = nil, -- Disabled if we don't have a name yet
	},
	{
		text = CANCEL,
		notCheckable = true,
	},
}

function LFGListUtil_GetApplicantMemberMenu(applicantID, memberIdx)
	local name, class, localizedClass, level, itemLevel, tank, healer, damage, assignedRole = C_LFGList.GetApplicantMemberInfo(applicantID, memberIdx)
	local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(applicantID)
	LFG_LIST_APPLICANT_MEMBER_MENU[1].text = name or " "
	LFG_LIST_APPLICANT_MEMBER_MENU[2].arg1 = name
	LFG_LIST_APPLICANT_MEMBER_MENU[2].disabled = not name or (status ~= "applied" and status ~= "invited")
	LFG_LIST_APPLICANT_MEMBER_MENU[3].arg1 = name
	LFG_LIST_APPLICANT_MEMBER_MENU[3].disabled = not name or (status ~= "applied" and status ~= "invited")
	LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[1].arg1 = applicantID
	LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[1].arg2 = memberIdx
	LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[2].arg1 = applicantID
	LFG_LIST_APPLICANT_MEMBER_MENU[4].menuList[2].disabled = (comment == "")
	LFG_LIST_APPLICANT_MEMBER_MENU[5].arg1 = name
	LFG_LIST_APPLICANT_MEMBER_MENU[5].arg2 = applicantID
	LFG_LIST_APPLICANT_MEMBER_MENU[5].disabled = not name
	return LFG_LIST_APPLICANT_MEMBER_MENU
end

-- LFG list search entries
local LFG_LIST_SEARCH_ENTRY_MENU = {
	{
		text = nil, -- Group name goes here
		isTitle = true,
		notCheckable = true,
	},
	{
		text = WHISPER_LEADER,
		func = function(_, name) ChatFrame_SendTell(name) end,
		notCheckable = true,
		arg1 = nil, -- Leader name goes here
		disabled = nil, -- Disabled if we don't have a leader name yet or you haven't applied
		tooltipWhileDisabled = 1,
		tooltipOnButton = 1,
		tooltipTitle = nil, -- The title to display on mouseover
		tooltipText = nil, -- The text to display on mouseover
	},
	{
		text = L.Popup.Armory,
		func = function(_, name) showArmoryPopup(name) end,
		notCheckable = true,
		arg1 = nil, -- Player name goes here
		disabled = nil, -- Disabled if we don't have a name yet
	},
	{
		text = LFG_LIST_REPORT_GROUP_FOR,
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = LFG_LIST_BAD_NAME,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistname") end,
				arg1 = nil, -- Search result ID goes here
				notCheckable = true,
			},
			{
				text = LFG_LIST_BAD_DESCRIPTION,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistcomment") end,
				arg1 = nil, -- Search reuslt ID goes here
				notCheckable = true,
				disabled = nil, -- Disabled if the description is just an empty string
			},
			{
				text = LFG_LIST_BAD_VOICE_CHAT_COMMENT,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "lfglistvoicechat") end,
				arg1 = nil, -- Search reuslt ID goes here
				notCheckable = true,
				disabled = nil, -- Disabled if the description is just an empty string
			},
			{
				text = LFG_LIST_BAD_LEADER_NAME,
				func = function(_, id) C_LFGList.ReportSearchResult(id, "badplayername") end,
				arg1 = nil, -- Search reuslt ID goes here
				notCheckable = true,
				disabled = nil, -- Disabled if we don't have a name for the leader
			},
		},
	},
	{
		text = CANCEL,
		notCheckable = true,
	},
}

function LFGListUtil_GetSearchEntryMenu(resultID)
	local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted, leaderName, numMembers = C_LFGList.GetSearchResultInfo(resultID)
	local _, appStatus, pendingStatus, appDuration = C_LFGList.GetApplicationInfo(resultID)
	LFG_LIST_SEARCH_ENTRY_MENU[1].text = name
	LFG_LIST_SEARCH_ENTRY_MENU[2].arg1 = leaderName
	LFG_LIST_SEARCH_ENTRY_MENU[2].disabled = not leaderName
	LFG_LIST_SEARCH_ENTRY_MENU[3].arg1 = leaderName
	LFG_LIST_SEARCH_ENTRY_MENU[3].disabled = not leaderName
	LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[1].arg1 = resultID
	LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[2].arg1 = resultID
	LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[2].disabled = (comment == "")
	LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[3].arg1 = resultID
	LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[3].disabled = (voiceChat == "")
	LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[4].arg1 = resultID
	LFG_LIST_SEARCH_ENTRY_MENU[4].menuList[4].disabled = not leaderName
	return LFG_LIST_SEARCH_ENTRY_MENU
end