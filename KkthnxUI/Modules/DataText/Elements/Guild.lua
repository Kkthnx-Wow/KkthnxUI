local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("DataText")

local table_wipe = table.wipe
local table_sort = table.sort
local string_format = string.format
local select = select

local Ambiguate = Ambiguate
local CLASS_ABBR = CLASS_ABBR
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local C_GuildInfo_GuildRoster = C_GuildInfo.GuildRoster
local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
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

local function rosterButtonOnClick(self, btn)
	local name = guildTable[self.index][3]
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			C_PartyInfo_InviteUnit(name)
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

	return button
end

local function GuildPanel_UpdateButton(button)
	local index = button.index
	local level, class, name, zone, status = unpack(guildTable[index])

	local levelcolor = K.RGBToHex(GetQuestDifficultyColor(level))
	button.level:SetText(levelcolor .. level)

	local tcoords = CLASS_ICON_TCOORDS[class]
	button.class:SetTexCoord(tcoords[1] + 0.022, tcoords[2] - 0.025, tcoords[3] + 0.022, tcoords[4] - 0.025)

	local namecolor = K.RGBToHex(K.ColorClass(class))
	button.name:SetText(namecolor .. name .. status)

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
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = GuildPanel_CreateButton(scrollChild, i)
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

	table_wipe(guildTable)
	local count = 0
	local total, _, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")

	gName:SetText("|cff0099ff<" .. (guildName or "") .. ">")
	gOnline:SetText(string_format(K.InfoColor .. "%s:" .. " %d/%d", GUILD_ONLINE_LABEL, online, total))
	-- gApps:SetText(string_format(K.InfoColor..GUILDINFOTAB_APPLICANTS, GetNumGuildApplicants()))
	gRank:SetText(K.InfoColor .. RANK .. ": " .. (guildRank or ""))

	for i = 1, total do
		local name, _, _, level, _, zone, _, _, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
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
	if not IsInGuild() then
		if C["DataText"].HideText then
			GuildDataText.Text:SetText("")
		else
			GuildDataText.Text:SetText(GUILD .. ": " .. K.MyClassColor .. NONE)
		end
		return
	end

	if event == "GUILD_ROSTER_UPDATE" then
		if arg1 then
			C_GuildInfo_GuildRoster()
		end
	end

	local online = select(3, GetNumGuildMembers())
	if C["DataText"].HideText then
		GuildDataText.Text:SetText("")
	else
		GuildDataText.Text:SetText(GUILD .. ": " .. K.MyClassColor .. online)
	end

	if infoFrame and infoFrame:IsShown() then
		GuildPanel_Refresh()
		GuildPanel_SortUpdate()
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

	if not GuildFrame then
		LoadAddOn("Blizzard_GuildUI")
	end

	if btn == "LeftButton" then
		ToggleFrame(GuildFrame)
	elseif btn == "RightButton" then
		ToggleGuildFrame()
	end
end

function Module:CreateGuildDataText()
	if not C["DataText"].Guild then
		return
	end

	GuildDataText = GuildDataText or CreateFrame("Button", nil, UIParent)
	GuildDataText:SetPoint("LEFT", UIParent, "LEFT", 0, -240)
	GuildDataText:SetSize(24, 24)

	GuildDataText.Texture = GuildDataText:CreateTexture(nil, "BACKGROUND")
	GuildDataText.Texture:SetPoint("LEFT", GuildDataText, "LEFT", 0, 0)
	GuildDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\guild.blp")
	GuildDataText.Texture:SetSize(24, 24)
	GuildDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	GuildDataText.Text = GuildDataText:CreateFontString(nil, "ARTWORK")
	GuildDataText.Text:SetFontObject(K.UIFont)
	GuildDataText.Text:SetPoint("LEFT", GuildDataText.Texture, "RIGHT", 0, 0)

	for _, event in pairs(eventList) do
		GuildDataText:RegisterEvent(event)
	end

	GuildDataText:SetScript("OnEvent", OnEvent)
	GuildDataText:SetScript("OnMouseUp", OnMouseUp)
	GuildDataText:SetScript("OnEnter", OnEnter)
	GuildDataText:SetScript("OnLeave", OnLeave)

	K.Mover(GuildDataText, "GuildDataText", "GuildDataText", { "LEFT", UIParent, "LEFT", 4, -240 })
end
