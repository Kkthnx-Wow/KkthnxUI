--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays guild information and a member roster in a custom DataText panel.
-- - Design: Uses a HybridScrollFrame for high-performance roster listing and supports sorting and interaction.
-- - Events: PLAYER_ENTERING_WORLD, GUILD_ROSTER_UPDATE, PLAYER_GUILD_UPDATE
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local Ambiguate = _G.Ambiguate
local C_ChatInfo_IsTimerunningPlayer = _G.C_ChatInfo and _G.C_ChatInfo.IsTimerunningPlayer
local C_GuildInfo_GuildRoster = _G.C_GuildInfo.GuildRoster
local C_PartyInfo_InviteUnit = _G.C_PartyInfo.InviteUnit
local C_PartyInfo_RequestInviteFromUnit = _G.C_PartyInfo.RequestInviteFromUnit
local ChatEdit_ActivateChat = _G.ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend
local ChatFrame_GetMobileEmbeddedTexture = _G.ChatFrame_GetMobileEmbeddedTexture
local ChatFrame_OpenChat = _G.ChatFrame_OpenChat
local CreateFrame = _G.CreateFrame
local GetDisplayedInviteType = _G.GetDisplayedInviteType
local GetGuildInfo = _G.GetGuildInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local GetTime = _G.GetTime
local HybridScrollFrame_GetOffset = _G.HybridScrollFrame_GetOffset
local HybridScrollFrame_Update = _G.HybridScrollFrame_Update
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local MailFrameTab_OnClick = _G.MailFrameTab_OnClick
local MouseIsOver = _G.MouseIsOver
local ToggleFrame = _G.ToggleFrame
local ToggleGuildFrame = _G.ToggleGuildFrame
local UIParent = _G.UIParent
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local ipairs = ipairs
local math_max = math.max
local math_min = math.min
local pairs = pairs
local string_format = string.format
local table_sort = table.sort
local table_wipe = table.wipe
local unpack = unpack

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local BUTTON_HEIGHT = 22
local MAX_VISIBLE_ROWS = 16
local BASE_EXTRA_HEIGHT = 175
local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS

local guildDataText
local infoFrame
local guildNameLabel
local onlineCountLabel
local rankLabel
local prevUpdateTime
local isUpdateQueued = false

local guildTable = {}
local tooltipColors = {
	title = { r = 1, g = 1, b = 1 },
	subHeader = { r = 0.75, g = 0.9, b = 1 },
	officerNote = { r = 0.3, g = 1, b = 0.3 },
}

local noteLabel = "|cff999999" .. _G.LABEL_NOTE .. ":|r %s"
local officerNoteLabel = "|cff999999" .. _G.GUILD_RANK1_DESC .. ":|r %s"
local infoTitle = "|cffffffff" .. _G.GUILD_INFORMATION .. "|r"
local noNoteText = "|cff999999" .. _G.NOT_APPLICABLE .. "|r"
local rankString = "|cff999999" .. _G.RANK .. ":|r %s"

-- ---------------------------------------------------------------------------
-- Utility Functions
-- ---------------------------------------------------------------------------
local function getStatusIcon(status, isMobile)
	-- REASON: Returns an inline icon string for AFK/DND status, including specialized mobile textures.
	if status == 1 or status == "AFK" or status == "<AFK>" then
		if isMobile then
			return "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0:16:16:0:16:0:16|t"
		end
		return "|T" .. _G.FRIENDS_TEXTURE_AFK .. ":14:14:0:0:16:16:1:15:1:15|t"
	elseif status == 2 or status == "DND" or status == "<DND>" then
		if isMobile then
			return "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-BusyMobile:14:14:0:0:16:16:0:16:0:16|t"
		end
		return "|T" .. _G.FRIENDS_TEXTURE_DND .. ":14:14:0:0:16:16:1:15:1:15|t"
	end

	if isMobile then
		return ChatFrame_GetMobileEmbeddedTexture(73 / 255, 177 / 255, 73 / 255)
	end
	return " "
end

local function sortRosters(a, b)
	-- REASON: Dynamic sorting function that uses current configuration for column and direction.
	if not a or not b then
		return false
	end
	local sortID = C["DataText"].GuildSortBy or 3 -- Name column by default
	local isAscending = C["DataText"].GuildSortOrder ~= false

	if isAscending then
		return a[sortID] < b[sortID]
	else
		return a[sortID] > b[sortID]
	end
end

-- ---------------------------------------------------------------------------
-- Panel Layout Logic
-- ---------------------------------------------------------------------------
local function guildPanel_Resize(rowCount)
	-- REASON: Adjusts the custom roster panel dimensions to tightly fit the current online member count.
	if not infoFrame or not infoFrame.scrollFrame then
		return
	end

	local visibleRows = math_min(rowCount or 0, MAX_VISIBLE_ROWS)
	local scrollHeight = math_max(visibleRows * BUTTON_HEIGHT, BUTTON_HEIGHT)

	infoFrame.scrollFrame:SetHeight(scrollHeight)
	infoFrame:SetHeight(BASE_EXTRA_HEIGHT + scrollHeight)

	local scrollBar = infoFrame.scrollFrame.scrollBar
	local maxScroll = math_max(0, ((rowCount or 0) - MAX_VISIBLE_ROWS) * BUTTON_HEIGHT)

	if maxScroll > 0 then
		scrollBar:Show()
		scrollBar:SetMinMaxValues(0, maxScroll)
	else
		scrollBar:Hide()
		scrollBar:SetValue(0)
		scrollBar:SetMinMaxValues(0, 0)
	end

	infoFrame.scrollFrame.scrollChild:SetSize(infoFrame.scrollFrame:GetWidth(), math_max(rowCount or 1, 1) * BUTTON_HEIGHT)
	infoFrame.scrollFrame:UpdateScrollChildRect()
end

local function isPanelCanHide(self, elapsed)
	-- REASON: Gracefully hides the roster panel when the mouse leaves both the DT and the panel focus areas.
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 0.2 then
		local isOver = false
		if guildDataText and MouseIsOver(guildDataText) then
			isOver = true
		elseif infoFrame and MouseIsOver(infoFrame) then
			isOver = true
		elseif infoFrame and infoFrame.scrollFrame and infoFrame.scrollFrame.buttons then
			for i = 1, #infoFrame.scrollFrame.buttons do
				local btn = infoFrame.scrollFrame.buttons[i]
				if btn and btn:IsShown() and MouseIsOver(btn) then
					isOver = true
					break
				end
			end
		end

		if not isOver then
			GameTooltip:Hide()
			if infoFrame then
				infoFrame:Hide()
				infoFrame:SetScript("OnUpdate", nil)
			end
			if guildDataText then
				guildDataText:SetScript("OnUpdate", nil)
			end
			self:SetScript("OnUpdate", nil)
		end
		self.timer = 0
	end
end

-- ---------------------------------------------------------------------------
-- Interaction Handlers
-- ---------------------------------------------------------------------------
local function rosterButtonOnClick(self, button)
	-- REASON: Handles Left-click (Group invite/Shift-insert name) and Right-click (Whisper) for roster entries.
	local entry = self.index and guildTable[self.index]
	if not entry then
		return
	end

	local name = entry[3]
	local guid = entry[9]
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
			if _G.MailFrame and _G.MailFrame:IsShown() then
				MailFrameTab_OnClick(nil, 2)
				_G.SendMailNameEditBox:SetText(name)
				_G.SendMailNameEditBox:HighlightText()
			else
				local eb = ChatEdit_ChooseBoxForSend()
				local hasInitialText = eb:GetText() ~= ""
				ChatEdit_ActivateChat(eb)
				eb:Insert(name)
				if not hasInitialText then
					eb:HighlightText()
				end
			end
		end
	else
		ChatFrame_OpenChat("/w " .. name .. " ", _G.SELECTED_DOCK_FRAME)
	end
end

local function rosterButtonOnEnter(self)
	-- REASON: Displays an detailed secondary tooltip containing guild rank and notes for the hovered member.
	local entry = self.index and guildTable[self.index]
	if not entry then
		return
	end

	local _, _, _, _, _, note, officerNote, rank = unpack(entry)
	GameTooltip:SetOwner(guildDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", infoFrame, "TOPRIGHT", 6, 2)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(infoTitle, tooltipColors.title.r, tooltipColors.title.g, tooltipColors.title.b, 1)
	GameTooltip:AddLine(" ")

	if rank then
		GameTooltip:AddLine(rankString:format(rank), tooltipColors.subHeader.r, tooltipColors.subHeader.g, tooltipColors.subHeader.b, 1)
	end
	GameTooltip:AddLine(" ")

	GameTooltip:AddLine(noteLabel:format(note ~= "" and note or noNoteText), tooltipColors.subHeader.r, tooltipColors.subHeader.g, tooltipColors.subHeader.b, 1)
	GameTooltip:AddLine(officerNoteLabel:format(officerNote ~= "" and officerNote or noNoteText), tooltipColors.officerNote.r, tooltipColors.officerNote.g, tooltipColors.officerNote.b, 1)

	GameTooltip:Show()
end

-- ---------------------------------------------------------------------------
-- Roster Processing
-- ---------------------------------------------------------------------------
local function guildPanel_UpdateButton(button)
	-- REASON: Hydrates an individual roster button with relevant character data (level, class, zone, etc.).
	local entry = button.index and guildTable[button.index]
	if not entry then
		return
	end

	local level, class, name, zone, status, _, _, _, guid = unpack(entry)
	local difficulty = GetQuestDifficultyColor(level)
	button.level:SetText(K.RGBToHex(difficulty.r, difficulty.g, difficulty.b) .. level)

	local coords = CLASS_ICON_TCOORDS[class]
	if coords then
		button.class:SetTexCoord(coords[1] + 0.022, coords[2] - 0.025, coords[3] + 0.022, coords[4] - 0.025)
	else
		button.class:SetTexCoord(0, 1, 0, 1)
	end

	local classColor = K.ColorClass(class)
	local isTimerunning = guid and C_ChatInfo_IsTimerunningPlayer and C_ChatInfo_IsTimerunningPlayer(guid)
	local formattedName = (isTimerunning and _G.TimerunningUtil and _G.TimerunningUtil.AddSmallIcon) and _G.TimerunningUtil.AddSmallIcon(name) or name
	button.name:SetText(K.RGBToHex(classColor.r, classColor.g, classColor.b) .. formattedName .. (status or ""))

	local zoneColor = inactiveColor
	if UnitInRaid(name) or UnitInParty(name) then
		zoneColor = "|cff4c4cff"
	elseif GetRealZoneText() == zone then
		zoneColor = "|cff4cff4c"
	end
	button.zone:SetText(zoneColor .. (zone or _G.UNKNOWN))
end

local function guildPanel_Update()
	-- REASON: Core refresh logic for the hybrid scroll frame's visible items.
	local scrollFrame = _G.KKUI_GuildDataTextScrollFrame
	local buttons = scrollFrame.buttons
	local usedHeight = 0
	local numMembersOnline = infoFrame.numMembers
	local scrollOffset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local btn = buttons[i]
		local idx = scrollOffset + i
		if idx <= numMembersOnline then
			btn.index = idx
			guildPanel_UpdateButton(btn)
			usedHeight = usedHeight + scrollFrame.buttonHeight
			btn:Show()
		else
			btn.index = nil
			btn:Hide()
		end
	end
	HybridScrollFrame_Update(scrollFrame, numMembersOnline * scrollFrame.buttonHeight, usedHeight)
end

function Module:GuildPanel_SortUpdate()
	-- REASON: Sorts the cached roster data based on user configuration and refreshes the scroll view.
	table_sort(guildTable, sortRosters)
	guildPanel_Update()
end

local function sortHeaderOnClick(self)
	C["DataText"].GuildSortBy = self.index
	C["DataText"].GuildSortOrder = not C["DataText"].GuildSortOrder
	Module:GuildPanel_SortUpdate()
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
local function guildPanel_Init()
	-- REASON: Constructive logic for the roster panel; creates frames, fonts, and scroll components on first call.
	if infoFrame then
		infoFrame:Show()
		return
	end

	infoFrame = CreateFrame("Frame", "KKUI_GuildInfoFrame", guildDataText)
	infoFrame:SetSize(335, 495)
	infoFrame:SetPoint(K.GetAnchors(guildDataText))
	infoFrame:SetClampedToScreen(true)
	infoFrame:SetFrameStrata("TOOLTIP")
	infoFrame:CreateBorder()

	infoFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", isPanelCanHide)
	end)
	infoFrame:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", isPanelCanHide)
	end)
	infoFrame:SetScript("OnHide", function(self)
		GameTooltip:Hide()
		self:SetScript("OnUpdate", nil)
		if guildDataText then
			guildDataText:SetScript("OnUpdate", nil)
		end
	end)

	guildNameLabel = K.CreateFontString(infoFrame, 14, _G.GUILD, "", true, "TOPLEFT", 15, -10)
	onlineCountLabel = K.CreateFontString(infoFrame, 12, _G.GUILD_ONLINE_LABEL, "", false, "TOPLEFT", 15, -35)
	rankLabel = K.CreateFontString(infoFrame, 12, _G.RANK, "", false, "TOPLEFT", 15, -51)

	local widths = { 30, 35, 126, 126 }
	local buList = {}
	for i = 1, 4 do
		buList[i] = CreateFrame("Button", nil, infoFrame)
		buList[i]:SetSize(widths[i], 22)
		buList[i]:SetFrameLevel(infoFrame:GetFrameLevel() + 3)
		if i == 1 then
			buList[i]:SetPoint("TOPLEFT", 12, -75)
		else
			buList[i]:SetPoint("LEFT", buList[i - 1], "RIGHT", -2, 0)
		end
		buList[i].HL = buList[i]:CreateTexture(nil, "HIGHLIGHT")
		buList[i].HL:SetAllPoints()
		buList[i].HL:SetColorTexture(K.r, K.g, K.b, 0.2)
		buList[i].index = i
		buList[i]:SetScript("OnClick", sortHeaderOnClick)
	end
	K.CreateFontString(buList[1], 12, _G.LEVEL_ABBR, "")
	K.CreateFontString(buList[2], 12, _G.CLASS_ABBR, "")
	K.CreateFontString(buList[3], 12, _G.NAME, "", false, "LEFT", 5, 0)
	K.CreateFontString(buList[4], 12, _G.ZONE, "", false, "RIGHT", -5, 0)

	K.CreateFontString(infoFrame, 12, Module.LineString, "", false, "BOTTOMRIGHT", -12, 58)
	K.CreateFontString(infoFrame, 12, K.InfoColor .. K.RightButton .. L["Whisper"], "", false, "BOTTOMRIGHT", -15, 42)
	K.CreateFontString(infoFrame, 12, K.InfoColor .. "ALT +" .. K.LeftButton .. L["Invite"], "", false, "BOTTOMRIGHT", -15, 26)
	K.CreateFontString(infoFrame, 12, K.InfoColor .. "SHIFT +" .. K.LeftButton .. L["Copy Name"], "", false, "BOTTOMRIGHT", -15, 10)

	local scrollFrame = CreateFrame("ScrollFrame", "KKUI_GuildDataTextScrollFrame", infoFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(305, MAX_VISIBLE_ROWS * BUTTON_HEIGHT)
	scrollFrame:SetPoint("TOPLEFT", 7, -100)
	infoFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = false
	scrollBar:SkinScrollBar()
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = MAX_VISIBLE_ROWS + 1
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = GuildPanel_CreateButton(scrollChild, i)
	end
	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = BUTTON_HEIGHT
	scrollFrame.update = guildPanel_Update
	scrollFrame:SetScript("OnMouseWheel", GuildPanel_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * BUTTON_HEIGHT)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, 0)
	scrollBar:SetValue(0)

	guildPanel_Resize(0)
end

local function guildPanel_Refresh()
	-- REASON: Polls the guild roster from the server and hydrates the localized roster table for the UI.
	local curTime = GetTime()
	if not prevUpdateTime or (curTime - prevUpdateTime > 5) then
		C_GuildInfo_GuildRoster()
		prevUpdateTime = curTime
	end

	table_wipe(guildTable)
	local totalMembers, _, numOnline = GetNumGuildMembers()
	local gName, gRankName = GetGuildInfo("player")

	guildNameLabel:SetText("|cff0099ff<" .. (gName or "") .. ">")
	onlineCountLabel:SetText(string_format(K.InfoColor .. "%s:" .. " %d/%d", _G.GUILD_ONLINE_LABEL, numOnline or 0, totalMembers or 0))
	rankLabel:SetText(K.InfoColor .. _G.RANK .. ": " .. (gRankName or ""))

	local count = 0
	for i = 1, totalMembers do
		local name, rank, _, level, _, zone, note, officerNote, connected, status, class, _, _, isMobile, _, _, guid = GetGuildRosterInfo(i)
		if connected or isMobile then
			count = count + 1
			guildTable[count] = guildTable[count] or {}
			guildTable[count][1] = level
			guildTable[count][2] = class
			guildTable[count][3] = Ambiguate(name, "none")
			guildTable[count][4] = isMobile and _G.REMOTE_CHAT or (zone or _G.UNKNOWN)
			guildTable[count][5] = getStatusIcon(status, isMobile and not connected)
			guildTable[count][6] = note
			guildTable[count][7] = officerNote
			guildTable[count][8] = rank
			guildTable[count][9] = guid
		end
	end

	infoFrame.numMembers = count
	guildPanel_Resize(count)
end

-- ---------------------------------------------------------------------------
-- Base Module Hooks
-- ---------------------------------------------------------------------------
local function onEnter()
	-- REASON: Displays a simple "No Guild Online" tooltip or initializes the full guild panel.
	if not IsInGuild() then
		return
	end

	local totalMembers, _, numOnline = GetNumGuildMembers()
	if (numOnline or 0) == 0 then
		GameTooltip:SetOwner(guildDataText, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(guildDataText))
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(_G.GUILD, string_format("%s: %d/%s", _G.GUILD_ONLINE_LABEL, 0, totalMembers or 0), 0.4, 0.6, 1, 0.4, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["No Guild Online"], 1, 1, 1)
		GameTooltip:Show()
		return
	end

	guildPanel_Init()
	guildPanel_Refresh()
	Module:GuildPanel_SortUpdate()
end

local function onEvent(_, event, arg1)
	-- REASON: Manages events related to guild roster changes and triggers UI updates for the DataText and panel.
	if event == "GUILD_ROSTER_UPDATE" and arg1 then
		C_GuildInfo_GuildRoster()
	end

	if IsInGuild() then
		local _, _, numOnline = GetNumGuildMembers()
		local message = C["DataText"].HideText and "" or _G.GUILD .. ": " .. K.MyClassColor .. (numOnline or 0)
		guildDataText.Text:SetText(message)

		if infoFrame and infoFrame:IsShown() then
			if not isUpdateQueued then
				isUpdateQueued = true
				K.Delay(0.05, function()
					if infoFrame and infoFrame:IsShown() then
						guildPanel_Refresh()
						Module:GuildPanel_SortUpdate()
					end
					isUpdateQueued = false
				end)
			end
		end
	else
		guildDataText.Text:SetText(_G.GUILD .. ": " .. K.MyClassColor .. _G.NO .. " " .. _G.GUILD)
	end

	-- REASON: Dynamically scales the DataText dimensions to fit the current online count text.
	local textW = guildDataText.Text:GetStringWidth() or 0
	local iconW = (guildDataText.Texture and guildDataText.Texture:GetWidth()) or 0
	local totalW = textW + iconW
	local totalH = math_max(guildDataText.Text:GetLineHeight() or 12, (guildDataText.Texture and guildDataText.Texture:GetHeight()) or 12)
	guildDataText:SetSize(math_max(totalW, 56), totalH)
	if guildDataText.mover then
		guildDataText.mover:SetSize(math_max(totalW, 56), totalH)
	end
end

local function onLeave()
	GameTooltip:Hide()
	if not infoFrame then
		return
	end
	if guildDataText then
		guildDataText:SetScript("OnUpdate", isPanelCanHide)
	end
	infoFrame:SetScript("OnUpdate", isPanelCanHide)
end

local function onMouseUp(_, btn)
	-- REASON: Handles interaction: Left-click for Communities (modern guild UI), Right-click for legacy Guild frame.
	if not IsInGuild() then
		return
	end
	if infoFrame then
		infoFrame:Hide()
	end

	if not _G.CommunitiesFrame then
		_G.C_AddOns.LoadAddOn("Blizzard_Communities")
	end
	if btn == "LeftButton" then
		if _G.CommunitiesFrame then
			ToggleFrame(_G.CommunitiesFrame)
		end
	elseif btn == "RightButton" then
		_G.ToggleGuildFrame()
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateGuildDataText()
	-- REASON: Main entry point for Guild DataText; registers events and sets up frame visuals.
	if not C["DataText"].Guild then
		return
	end

	guildDataText = CreateFrame("Frame", nil, UIParent)
	guildDataText.Text = K.CreateFontString(guildDataText, 12)
	guildDataText.Text:ClearAllPoints()
	guildDataText.Text:SetPoint("LEFT", guildDataText, "LEFT", 24, 0)

	guildDataText.Texture = guildDataText:CreateTexture(nil, "ARTWORK")
	guildDataText.Texture:SetPoint("LEFT", guildDataText, "LEFT", 0, 2)
	guildDataText.Texture:SetTexture(K.MediaFolder .. "DataText\\GuildIcon")
	guildDataText.Texture:SetSize(24, 24)
	guildDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	local events = { "PLAYER_ENTERING_WORLD", "GUILD_ROSTER_UPDATE", "PLAYER_GUILD_UPDATE" }
	for _, eventName in ipairs(events) do
		guildDataText:RegisterEvent(eventName)
	end

	guildDataText:SetScript("OnEvent", onEvent)
	guildDataText:SetScript("OnEnter", onEnter)
	guildDataText:SetScript("OnLeave", onLeave)
	guildDataText:SetScript("OnMouseUp", onMouseUp)

	guildDataText.mover = K.Mover(guildDataText, "GuildDT", "GuildDT", { "LEFT", UIParent, "LEFT", 0, -240 }, 56, 12)
end

K.Delay(5, function()
	-- REASON: Delayed initial roster query to reduce logon stutter.
	if IsInGuild() then
		C_GuildInfo_GuildRoster()
	end
end)
