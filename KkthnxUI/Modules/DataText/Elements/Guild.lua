local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

local table_sort = table.sort
local string_format = string.format
local select = select

local Ambiguate = Ambiguate
local CLASS_ABBR = CLASS_ABBR
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local C_GuildInfo_GuildRoster = C_GuildInfo.GuildRoster
local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
local C_PartyInfo_RequestInviteFromUnit = C_PartyInfo.RequestInviteFromUnit
local C_Timer_After = C_Timer.After
local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatFrame_GetMobileEmbeddedTexture = ChatFrame_GetMobileEmbeddedTexture
local ChatFrame_OpenChat = ChatFrame_OpenChat
local GetGuildInfo = GetGuildInfo
local GetGuildRosterInfo = GetGuildRosterInfo
local GetNumGuildMembers = GetNumGuildMembers
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local GetTime = GetTime
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_Update = HybridScrollFrame_Update
local IsAltKeyDown = IsAltKeyDown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local LEVEL_ABBR = LEVEL_ABBR
local MailFrame = MailFrame
local MailFrameTab_OnClick = MailFrameTab_OnClick
local MouseIsOver = MouseIsOver
local NAME = NAME
local RANK = RANK
local REMOTE_CHAT = REMOTE_CHAT
local SELECTED_DOCK_FRAME = SELECTED_DOCK_FRAME
local SendMailNameEditBox = SendMailNameEditBox
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local ZONE = ZONE

local guildTable = {}
local gName
local gOnline
local gRank
local infoFrame
local prevTime
local r, g, b = K.r, K.g, K.b
local GuildDataText

local function rosterButtonOnClick(self, button)
	local index = self.index
	local _, _, name, _, _, _, _, _, guid = unpack(guildTable[index])

	-- Check if the index is valid
	if not index or not guildTable[index] then
		return
	end

	if not (name and name ~= "") then
		return
	end

	if button == "LeftButton" then
		if IsAltKeyDown() then
			if guid then
				local inviteType = GetDisplayedInviteType(guid)
				if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
					C_PartyInfo_InviteUnit(name)
				elseif inviteType == "REQUEST_INVITE" then
					C_PartyInfo_RequestInviteFromUnit(name)
				end
			else
				C_PartyInfo_InviteUnit(name)
			end
		elseif IsShiftKeyDown() then
			if MailFrame:IsShown() then
				MailFrameTab_OnClick(nil, 2)
				SendMailNameEditBox:SetText(name)
				SendMailNameEditBox:HighlightText()
			else
				local editBox = ChatEdit_ChooseBoxForSend()
				local hasText = (editBox:GetText() ~= "")
				ChatEdit_ActivateChat(editBox)
				editBox:Insert(name)
				if not hasText then
					editBox:HighlightText()
				end
			end
		end
	else
		ChatFrame_OpenChat("/w " .. name .. " ", SELECTED_DOCK_FRAME)
	end
end

local tooltipColors = {
	title = { r = 1, g = 1, b = 1 },
	subHeader = { r = 0.75, g = 0.9, b = 1 },
	officerNote = { r = 0.3, g = 1, b = 0.3 },
}

local noteLabel = "|cff999999" .. _G.LABEL_NOTE .. ":|r %s"
local officerNoteLabel = "|cff999999" .. _G.GUILD_RANK1_DESC .. ":|r %s"
local title = "|cffffffff" .. GUILD_INFORMATION .. "|r"
local noNoteText = "|cff999999" .. NOT_APPLICABLE .. "|r"
local rankLabel = "|cff999999" .. _G.RANK .. ":|r %s"

-- Event handler for guild roster button hover
local function rosterButtonOnEnter(self)
	local index = self.index
	local _, _, _, _, _, note, officerNote, rank = unpack(guildTable[index])

	-- Check if the index is valid
	if not index or not guildTable[index] then
		return
	end

	GameTooltip:SetOwner(GuildDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", infoFrame, "TOPRIGHT", 6, 2)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(title, tooltipColors.title.r, tooltipColors.title.g, tooltipColors.title.b, 1)
	GameTooltip:AddLine(" ")

	if rank then
		GameTooltip:AddLine(rankLabel:format(rank), tooltipColors.subHeader.r, tooltipColors.subHeader.g, tooltipColors.subHeader.b, 1)
	end

	GameTooltip:AddLine(" ")

	if note ~= "" then
		GameTooltip:AddLine(noteLabel:format(note), tooltipColors.subHeader.r, tooltipColors.subHeader.g, tooltipColors.subHeader.b, 1)
	else
		GameTooltip:AddLine(noteLabel:format(noNoteText), tooltipColors.subHeader.r, tooltipColors.subHeader.g, tooltipColors.subHeader.b, 1)
	end

	if officerNote ~= "" then
		GameTooltip:AddLine(officerNoteLabel:format(officerNote), tooltipColors.officerNote.r, tooltipColors.officerNote.g, tooltipColors.officerNote.b, 1)
	else
		GameTooltip:AddLine(officerNoteLabel:format(noNoteText), tooltipColors.officerNote.r, tooltipColors.officerNote.g, tooltipColors.officerNote.b, 1)
	end

	GameTooltip:Show()
end

local function GuildPanel_CreateButton(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(305, 20)
	button:SetPoint("TOPLEFT", 0, -(index - 1) * 20)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, 0.2)

	button.level = K.CreateFontString(button, 12, "Level", "", false)
	button.level:SetPoint("TOP", button, "TOPLEFT", 16, -4)

	button.class = button:CreateTexture(nil, "ARTWORK")
	button.class:SetPoint("LEFT", 35, 0)
	button.class:SetSize(16, 16)
	button.class:SetTexture("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES")

	button.name = K.CreateFontString(button, 12, "Name", "", false, "LEFT", 65, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 185, 0)
	button.name:SetJustifyH("LEFT")

	button.zone = K.CreateFontString(button, 12, "Zone", "", false, "RIGHT", -2, 0)
	button.zone:SetPoint("LEFT", button, "RIGHT", -120, 0)
	button.zone:SetJustifyH("RIGHT")

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", rosterButtonOnClick)
	button:SetScript("OnEnter", rosterButtonOnEnter)
	button:SetScript("OnLeave", K.HideTooltip)

	return button
end

local function GuildPanel_UpdateButton(button)
	local index = button.index
	local level, class, name, zone, status, guid = unpack(guildTable[index])

	-- Check if the index is valid
	if not index or not guildTable[index] then
		return
	end

	local levelcolor = K.RGBToHex(GetQuestDifficultyColor(level))
	button.level:SetText(levelcolor .. level)

	local tcoords = CLASS_ICON_TCOORDS[class]
	button.class:SetTexCoord(tcoords[1] + 0.022, tcoords[2] - 0.025, tcoords[3] + 0.022, tcoords[4] - 0.025)

	local namecolor = K.RGBToHex(K.ColorClass(class))
	local isTimerunning = guid and C_ChatInfo.IsTimerunningPlayer(guid)
	local playerName = isTimerunning and TimerunningUtil.AddSmallIcon(name) or name
	button.name:SetText(namecolor .. playerName .. status)

	local zonecolor = K.GreyColor
	if UnitInRaid(name) or UnitInParty(name) then
		zonecolor = "|cff4c4cff"
	elseif GetRealZoneText() == zone then
		zonecolor = "|cff4cff4c"
	end
	button.zone:SetText(zonecolor .. zone)
end

local function GuildPanel_Update()
	local scrollFrame = KKUI_GuildDataTextScrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numMemberButtons = infoFrame.numMembers
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numMemberButtons then
			button.index = index
			GuildPanel_UpdateButton(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, numMemberButtons * height, usedHeight)
end

local function GuildPanel_OnMouseWheel(self, delta)
	local scrollBar = self.scrollBar
	local step = delta * self.buttonHeight
	if IsShiftKeyDown() then
		step = step * 15
	end
	scrollBar:SetValue(scrollBar:GetValue() - step)
	GuildPanel_Update()
end

local function sortRosters(a, b)
	if a and b then
		if C["DataText"].GuildSortOrder then
			return a[C["DataText"].GuildSortBy] < b[C["DataText"].GuildSortBy]
		else
			return a[C["DataText"].GuildSortBy] > b[C["DataText"].GuildSortBy]
		end
	end
end

local function GuildPanel_SortUpdate()
	table_sort(guildTable, sortRosters)
	GuildPanel_Update()
end

local function sortHeaderOnClick(self)
	C["DataText"].GuildSortBy = self.index
	C["DataText"].GuildSortOrder = not C["DataText"].GuildSortOrder
	GuildPanel_SortUpdate()
end

local function isPanelCanHide(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 0.1 then
		if not infoFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function GuildPanel_Init()
	if infoFrame then
		infoFrame:Show()
		return
	end

	infoFrame = CreateFrame("Frame", "KKUI_GuildInfoFrame", GuildDataText)
	infoFrame:SetSize(335, 495)
	infoFrame:SetPoint(K.GetAnchors(GuildDataText))
	infoFrame:SetClampedToScreen(true)
	infoFrame:SetFrameStrata("TOOLTIP")
	infoFrame:CreateBorder()

	infoFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", isPanelCanHide)
	end)

	gName = K.CreateFontString(infoFrame, 14, GUILD, "", true, "TOPLEFT", 15, -10)
	gOnline = K.CreateFontString(infoFrame, 12, GUILD_ONLINE_LABEL, "", false, "TOPLEFT", 15, -35)
	gRank = K.CreateFontString(infoFrame, 12, RANK, "", false, "TOPLEFT", 15, -51)

	local bu = {}
	local width = { 30, 35, 126, 126 }
	for i = 1, 4 do
		bu[i] = CreateFrame("Button", nil, infoFrame)
		bu[i]:SetSize(width[i], 22)
		bu[i]:SetFrameLevel(infoFrame:GetFrameLevel() + 3)
		if i == 1 then
			bu[i]:SetPoint("TOPLEFT", 12, -75)
		else
			bu[i]:SetPoint("LEFT", bu[i - 1], "RIGHT", -2, 0)
		end
		bu[i].HL = bu[i]:CreateTexture(nil, "HIGHLIGHT")
		bu[i].HL:SetAllPoints(bu[i])
		bu[i].HL:SetColorTexture(r, g, b, 0.2)
		bu[i].index = i
		bu[i]:SetScript("OnClick", sortHeaderOnClick)
	end
	K.CreateFontString(bu[1], 12, LEVEL_ABBR, "")
	K.CreateFontString(bu[2], 12, CLASS_ABBR, "")
	K.CreateFontString(bu[3], 12, NAME, "", false, "LEFT", 5, 0)
	K.CreateFontString(bu[4], 12, ZONE, "", false, "RIGHT", -5, 0)

	K.CreateFontString(infoFrame, 12, Module.LineString, "", false, "BOTTOMRIGHT", -12, 58)
	local whspInfo = K.InfoColor .. K.RightButton .. L["Whisper"]
	K.CreateFontString(infoFrame, 12, whspInfo, "", false, "BOTTOMRIGHT", -15, 42)
	local invtInfo = K.InfoColor .. "ALT +" .. K.LeftButton .. L["Invite"]
	K.CreateFontString(infoFrame, 12, invtInfo, "", false, "BOTTOMRIGHT", -15, 26)
	local copyInfo = K.InfoColor .. "SHIFT +" .. K.LeftButton .. L["Copy Name"]
	K.CreateFontString(infoFrame, 12, copyInfo, "", false, "BOTTOMRIGHT", -15, 10)

	local scrollFrame = CreateFrame("ScrollFrame", "KKUI_GuildDataTextScrollFrame", infoFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(305, 320)
	scrollFrame:SetPoint("TOPLEFT", 7, -100)
	infoFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	scrollBar:SkinScrollBar()
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 16 + 1
	local buttonHeight = 22
	local buttons = scrollFrame.buttons or {}
	for i = 1, numButtons do
		buttons[i] = buttons[i] or GuildPanel_CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = GuildPanel_Update
	scrollFrame:SetScript("OnMouseWheel", GuildPanel_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)
end

C_Timer_After(5, function()
	if IsInGuild() then
		C_GuildInfo_GuildRoster()
	end
end)

local function GuildPanel_Refresh()
	local thisTime = GetTime()
	if not prevTime or (thisTime - prevTime > 5) then
		C_GuildInfo_GuildRoster()
		prevTime = thisTime
	end

	wipe(guildTable)
	local count = 0
	local total, _, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")

	gName:SetText("|cff0099ff<" .. (guildName or "") .. ">")
	gOnline:SetText(string_format(K.InfoColor .. "%s:" .. " %d/%d", GUILD_ONLINE_LABEL, online, total))
	gRank:SetText(K.InfoColor .. RANK .. ": " .. (guildRank or ""))

	-- Declare status variable as string
	for i = 1, total do
		local name, rank, _, level, _, zone, note, officerNote, connected, status, class, _, _, mobile, _, _, guid = GetGuildRosterInfo(i)
		if connected or mobile then
			if mobile and not connected then
				zone = REMOTE_CHAT
				if status == 1 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t"
				elseif status == 2 then
					status = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t"
				else
					status = ChatFrame_GetMobileEmbeddedTexture(73 / 255, 177 / 255, 73 / 255)
				end
			else
				if status == 1 then
					status = "|T" .. FRIENDS_TEXTURE_AFK .. ":14:14:0:0:16:16:1:15:1:15|t"
				elseif status == 2 then
					status = "|T" .. FRIENDS_TEXTURE_DND .. ":14:14:0:0:16:16:1:15:1:15|t"
				else
					status = " "
				end
			end

			if not zone then
				zone = UNKNOWN
			end

			count = count + 1

			if not guildTable[count] then
				guildTable[count] = {}
			end
			guildTable[count][1] = level
			guildTable[count][2] = class
			guildTable[count][3] = Ambiguate(name, "none")
			guildTable[count][4] = zone
			guildTable[count][5] = status
			guildTable[count][6] = note
			guildTable[count][7] = officerNote
			guildTable[count][8] = rank
			guildTable[count][9] = guid
		end
	end

	infoFrame.numMembers = count
end

local eventList = {
	"PLAYER_ENTERING_WORLD",
	"GUILD_ROSTER_UPDATE",
	"PLAYER_GUILD_UPDATE",
}

local function OnEvent(_, event, arg1)
	if event == "GUILD_ROSTER_UPDATE" and arg1 then
		C_GuildInfo_GuildRoster()
	end

	if IsInGuild() then
		local online = select(3, GetNumGuildMembers())
		local message = C["DataText"].HideText and "" or GUILD .. ": " .. K.MyClassColor .. online
		GuildDataText.Text:SetText(message)

		if infoFrame and infoFrame:IsShown() then
			GuildPanel_Refresh()
			GuildPanel_SortUpdate()
		end
	else
		GuildDataText.Text:SetText(GUILD .. ": " .. K.MyClassColor .. NO .. " " .. GUILD)
	end
end

local function OnEnter()
	if not IsInGuild() then
		return
	end

	if _G.KKUI_FriendsInfoFrame and _G.KKUI_FriendsInfoFrame:IsShown() then
		_G.KKUI_FriendsInfoFrame:Hide()
	end

	GuildPanel_Init()
	GuildPanel_Refresh()
	GuildPanel_SortUpdate()
end

local function delayLeave()
	if MouseIsOver(infoFrame) then
		return
	end
	infoFrame:Hide()
end

local function OnLeave()
	if not infoFrame then
		return
	end
	C_Timer_After(0.1, delayLeave)
end

local function OnMouseUp(_, btn)
	if not IsInGuild() then
		return
	end

	infoFrame:Hide()

	if not CommunitiesFrame then
		LoadAddOn("Blizzard_Communities")
	end

	if btn == "LeftButton" then
		if CommunitiesFrame then
			ToggleFrame(CommunitiesFrame)
		end
	elseif btn == "RightButton" then
		ToggleGuildFrame()
	end
end

function Module:CreateGuildDataText()
	if not C["DataText"].Guild then
		return
	end

	GuildDataText = CreateFrame("Frame", nil, UIParent)
	GuildDataText:SetHitRectInsets(-16, 0, -10, -10)

	GuildDataText.Text = K.CreateFontString(GuildDataText, 12)
	GuildDataText.Text:ClearAllPoints()
	GuildDataText.Text:SetPoint("LEFT", UIParent, "LEFT", 24, -240)

	GuildDataText.Texture = GuildDataText:CreateTexture(nil, "ARTWORK")
	GuildDataText.Texture:SetPoint("RIGHT", GuildDataText.Text, "LEFT", 0, 2)
	GuildDataText.Texture:SetTexture(K.MediaFolder .. "DataText\\guild.blp")
	GuildDataText.Texture:SetSize(24, 24)
	GuildDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	GuildDataText:SetAllPoints(GuildDataText.Text)

	local function _OnEvent(...)
		OnEvent(...)
	end

	for _, event in pairs(eventList) do
		GuildDataText:RegisterEvent(event)
	end

	GuildDataText:SetScript("OnEvent", _OnEvent)
	GuildDataText:SetScript("OnEnter", OnEnter)
	GuildDataText:SetScript("OnLeave", OnLeave)
	GuildDataText:SetScript("OnMouseUp", OnMouseUp)
end
