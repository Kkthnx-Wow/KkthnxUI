local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local select = _G.select
local string_format = _G.string.format
local table_sort = _G.table.sort
local table_wipe = _G.table.wipe

local Ambiguate = _G.Ambiguate
local CLASS_ABBR = _G.CLASS_ABBR
local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local COMBAT_FACTION_CHANGE = _G.COMBAT_FACTION_CHANGE
local C_GuildInfo_GuildRoster = _G.C_GuildInfo.GuildRoster
local C_Timer_After = _G.C_Timer.After
local ChatEdit_ActivateChat = _G.ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend
local ChatFrame_GetMobileEmbeddedTexture = _G.ChatFrame_GetMobileEmbeddedTexture
local ChatFrame_OpenChat = _G.ChatFrame_OpenChat
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local FRIENDS_TEXTURE_AFK = _G.FRIENDS_TEXTURE_AFK
local FRIENDS_TEXTURE_DND = _G.FRIENDS_TEXTURE_DND
local GUILDINFOTAB_APPLICANTS = _G.GUILDINFOTAB_APPLICANTS
local GUILD_ONLINE_LABEL = _G.GUILD_ONLINE_LABEL
local GetGuildFactionInfo = _G.GetGuildFactionInfo
local GetGuildInfo = _G.GetGuildInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetNumGuildApplicants = _G.GetNumGuildApplicants
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local InviteToGroup = _G.C_PartyInfo.InviteUnit
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local LEVEL_ABBR = _G.LEVEL_ABBR
local MailFrame = _G.MailFrame
local MailFrameTab_OnClick = _G.MailFrameTab_OnClick
local MouseIsOver = _G.MouseIsOver
local NAME = _G.NAME
local RANK = _G.RANK
local REMOTE_CHAT = _G.REMOTE_CHAT
local SELECTED_DOCK_FRAME = _G.SELECTED_DOCK_FRAME
local SendMailNameEditBox = _G.SendMailNameEditBox
local UIErrorsFrame = _G.UIErrorsFrame
local UNKNOWN = _G.UNKNOWN
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local ZONE = _G.ZONE

local r, g, b = K.r, K.g, K.b
local infoFrame, gName, gOnline, gApps, gRank, gRep, applyData, prevTime

local function scrollBarHook(self, delta)
	local scrollBar = self.ScrollBar
	scrollBar:SetValue(scrollBar:GetValue() - delta*50)
end

function Module:ReskinScrollBar()
	local scrollBar = self.ScrollBar
	scrollBar.ScrollUpButton:Kill()
	scrollBar.ScrollDownButton:Kill()
	scrollBar.ThumbTexture:SetColorTexture(0.3, 0.3, 0.3)
	scrollBar.ThumbTexture:SetSize(3, 10)
	scrollBar.ThumbTexture:SetPoint("LEFT", -5, 0)
	self:SetScript("OnMouseWheel", scrollBarHook)
end

local function setupInfoFrame()
	if infoFrame then
		infoFrame:Show()
		return
	end

	infoFrame = CreateFrame("Frame", "KKUI_GuildDataTextFrame", Module.GuildDataTextFrame)
	infoFrame:SetSize(335, 495)
	infoFrame:SetPoint("BOTTOMRIGHT", Module.GuildDataTextFrame, "TOPLEFT", -6, 10)
	infoFrame:SetClampedToScreen(true)
	infoFrame:SetFrameStrata("TOOLTIP")
	infoFrame:CreateBorder()

	local function OnUpdate(self, elapsed)
		self.timer = (self.timer or 0) + elapsed
		if self.timer > 0.1 then
			if not infoFrame:IsMouseOver() then
				self:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.timer = 0
		end
	end

	infoFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)

	gName = K.CreateFontString(infoFrame, 16, "Guild", "", true, "TOP", 0, -8)
	gOnline = K.CreateFontString(infoFrame, 12, "Online", "", false, "TOPLEFT", 14, -35)
	gApps = K.CreateFontString(infoFrame, 12, "Applications", "", false, "TOPRIGHT", -15, -35)
	gRank = K.CreateFontString(infoFrame, 12, "Rank", "", false, "TOPLEFT", 15, -51)
	gRep = K.CreateFontString(infoFrame, 12, "Reputation", "", false, "TOPLEFT", 15, -67)

	local bu = {}
	local width = {30, 35, 126, 126}
	for i = 1, 4 do
		bu[i] = CreateFrame("Button", nil, infoFrame)
		bu[i]:SetSize(width[i], 22)
		bu[i]:SetFrameLevel(infoFrame:GetFrameLevel() + 3)
		if i == 1 then
			bu[i]:SetPoint("TOPLEFT", 8, -88)
		else
			bu[i]:SetPoint("LEFT", bu[i - 1], "RIGHT", -2, 0)
		end
		bu[i].HL = bu[i]:CreateTexture(nil, "HIGHLIGHT")
		bu[i].HL:SetAllPoints(bu[i])
		bu[i].HL:SetColorTexture(r, g, b, .2)
	end
	K.CreateFontString(bu[1], 12, LEVEL_ABBR, "")
	K.CreateFontString(bu[2], 12, CLASS_ABBR, "")
	K.CreateFontString(bu[3], 12, NAME, "", false, "LEFT", 5, 0)
	K.CreateFontString(bu[4], 12, ZONE, "", false, "RIGHT", 0, 0)

	for i = 1, 4 do
		K.CheckSavedVariables()
		KkthnxUIData[K.Realm][K.Name]["GuildSortBy"] = KkthnxUIData[K.Realm][K.Name]["GuildSortBy"] or 1
		KkthnxUIData[K.Realm][K.Name]["GuildSortOrder"] = KkthnxUIData[K.Realm][K.Name]["GuildSortOrder"] or true

		bu[i]:SetScript("OnClick", function()
			KkthnxUIData[K.Realm][K.Name]["GuildSortBy"] = i
			KkthnxUIData[K.Realm][K.Name]["GuildSortOrder"] = not KkthnxUIData[K.Realm][K.Name]["GuildSortOrder"]
			applyData()
		end)
	end

	local whspInfo = K.InfoColorTint.." |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:333:411|t "..L["Whisper"]
	K.CreateFontString(infoFrame, 12, whspInfo, "", false, "BOTTOMRIGHT", -15, 42)
	local invtInfo = K.InfoColorTint.."ALT +".." |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:230:307|t "..L["Invite"]
	K.CreateFontString(infoFrame, 12, invtInfo, "", false, "BOTTOMRIGHT", -15, 26)
	local copyInfo = K.InfoColorTint.."SHIFT +".." |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:230:307|t "..L["Copy Name"]
	K.CreateFontString(infoFrame, 12, copyInfo, "", false, "BOTTOMRIGHT", -15, 10)

	local scrollFrame = CreateFrame("ScrollFrame", nil, infoFrame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(315, 320)
	scrollFrame:SetPoint("TOPLEFT", 10, -112)
	Module.ReskinScrollBar(scrollFrame)

	local roster = CreateFrame("Frame", nil, scrollFrame)
	roster:SetSize(315, 1)
	scrollFrame:SetScrollChild(roster)
	infoFrame.roster = roster
end

local guildTable, frames, previous = {}, {}, 0

local function buttonOnClick(self, btn)
	local name = guildTable[self.index][3]
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			InviteToGroup(name)
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
		ChatFrame_OpenChat("/w "..name.." ", SELECTED_DOCK_FRAME)
	end
end

local function createRoster(parent, i)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(312, 20)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, .2)

	button.index = i

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
	button:SetScript("OnClick", buttonOnClick)

	return button
end

C_Timer_After(5, function()
	if IsInGuild() then
		C_GuildInfo_GuildRoster()
	end
end)

local function setPosition()
	for i = 1, previous do
		if i == 1 then
			frames[i]:SetPoint("TOPLEFT")
		else
			frames[i]:SetPoint("TOP", frames[i-1], "BOTTOM")
		end
		frames[i]:Show()
	end
end

local function refreshData()
	if not prevTime or (GetTime() - prevTime > 5) then
		C_GuildInfo_GuildRoster()
		prevTime = GetTime()
	end

	table_wipe(guildTable)
	local count = 0
	local total, _, online = GetNumGuildMembers()
	local guildName, guildRank = GetGuildInfo("player")
	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()

	gName:SetText(K.InfoColor.."<"..(guildName or "")..">")
	gOnline:SetText(string_format(K.InfoColorTint.."%s:".." %d/%d", GUILD_ONLINE_LABEL, online, total))
	gApps:SetText(string_format(K.InfoColorTint..GUILDINFOTAB_APPLICANTS, GetNumGuildApplicants()))
	gRank:SetText(K.InfoColorTint..RANK..": "..(guildRank or ""))
	if standingID ~= 8 then -- Not Max Rep
		barMax = barMax - barMin
		barValue = barValue - barMin
		gRep:SetText(string_format(K.InfoColorTint..COMBAT_FACTION_CHANGE..": %s/%s (%s%%) [%s]", K.ShortValue(barValue), K.ShortValue(barMax), ceil((barValue / barMax) * 100), _G["FACTION_STANDING_LABEL"..standingID]))
	elseif standingID == 8 then
		gRep:SetText(string_format(K.InfoColorTint..COMBAT_FACTION_CHANGE..": %s", "Exalted"))
	end

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
					status = ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)
				end
			else
				if status == 1 then
					status = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
				elseif status == 2 then
					status = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"
				else
					status = " "
				end
			end

			if not zone then
				zone = UNKNOWN
			end

			count = count + 1
			guildTable[count] = {level, class, Ambiguate(name, "none"), zone, status}
		end
	end

	if count ~= previous then
		if count > previous then
			for i = previous+1, count do
				if not frames[i] then
					frames[i] = createRoster(infoFrame.roster, i)
				end
			end
		elseif count < previous then
			for i = count+1, previous do
				frames[i]:Hide()
			end
		end
		previous = count

		setPosition()
	end
end

local function sortGuild(a, b)
	if a and b then
		if KkthnxUIData[K.Realm][K.Name]["GuildSortOrder"] then
			return a[KkthnxUIData[K.Realm][K.Name]["GuildSortBy"]] < b[KkthnxUIData[K.Realm][K.Name]["GuildSortBy"]]
		else
			return a[KkthnxUIData[K.Realm][K.Name]["GuildSortBy"]] > b[KkthnxUIData[K.Realm][K.Name]["GuildSortBy"]]
		end
	end
end

function applyData()
	table_sort(guildTable, sortGuild)

	for i = 1, previous do
		local level, class, name, zone, status = unpack(guildTable[i])

		local levelcolor = K.RGBToHex(GetQuestDifficultyColor(level))
		frames[i].level:SetText(levelcolor..level)

		local tcoords = CLASS_ICON_TCOORDS[class]
		frames[i].class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)

		local namecolor = K.RGBToHex(K.ColorClass(class))
		frames[i].name:SetText(namecolor..name..status)

		local zonecolor = K.GreyColor
		if UnitInRaid(name) or UnitInParty(name) then
			zonecolor = "|cff4c4cff"
		elseif GetRealZoneText() == zone then
			zonecolor = "|cff4cff4c"
		end
		frames[i].zone:SetText(zonecolor..zone)
	end
end

local function OnEvent(_, event, ...)
	if not IsInGuild() then
		Module.GuildDataTextFrame.Text:SetText("")
		return
	end

	if event == "GUILD_ROSTER_UPDATE" then
		local canRequestRosterUpdate = ...
		if canRequestRosterUpdate then
			C_GuildInfo_GuildRoster()
		end
	end

	local online = select(3, GetNumGuildMembers())
	Module.GuildDataTextFrame.Text:SetText(online)

	if infoFrame and infoFrame:IsShown() then
		refreshData()
		applyData()
	end
end

local function OnEnter()
	if not IsInGuild() then
		K.AddTooltip(Module.GuildDataTextFrame, "ANCHOR_RIGHT", "Guild and Communities |CFFFFFF00(J)|r")
		return
	end

	if KKUI_FriendsDataTextFrame and KKUI_FriendsDataTextFrame:IsShown() then
		KKUI_FriendsDataTextFrame:Hide()
	end

	setupInfoFrame()
	refreshData()
	applyData()
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

	C_Timer_After(.1, delayLeave)
end

local function OnMouseUp(_, btn)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
		return
	end

	if not IsInGuild() then
		if not LookingForGuildFrame then
			LoadAddOn("Blizzard_LookingForGuildUI")
		end
		ToggleFrame(LookingForGuildFrame)
		return
	end

	infoFrame:Hide()

	if not GuildFrame then
		LoadAddOn("Blizzard_GuildUI")
	end

	if btn == "LeftButton" then
		ToggleCommunitiesFrame()
	elseif btn == "RightButton" then
		ToggleFrame(GuildFrame)
	end
end

function Module:CreateGuildDataText()
	if not C["DataText"].Guild or not C["ActionBar"].MicroBar then
		return
	end

	if not GuildMicroButton or not GuildMicroButton:IsShown() then
		return
	end

	Module.GuildDataTextFrame = CreateFrame("Button", nil, UIParent)
	Module.GuildDataTextFrame:SetAllPoints(GuildMicroButton)
	Module.GuildDataTextFrame:SetSize(GuildMicroButton:GetWidth(), GuildMicroButton:GetHeight())
	Module.GuildDataTextFrame:SetFrameLevel(GuildMicroButton:GetFrameLevel() + 2)

	Module.GuildDataTextFrame.Text = Module.GuildDataTextFrame:CreateFontString("OVERLAY")
	Module.GuildDataTextFrame.Text:FontTemplate(nil, nil, "OUTLINE")
	Module.GuildDataTextFrame.Text:SetPoint("CENTER", Module.GuildDataTextFrame, "CENTER", 1, -6)

	Module.GuildDataTextFrame:RegisterEvent("PLAYER_ENTERING_WORLD", OnEvent)
	Module.GuildDataTextFrame:RegisterEvent("GUILD_ROSTER_UPDATE", OnEvent)
	Module.GuildDataTextFrame:RegisterEvent("PLAYER_GUILD_UPDATE", OnEvent)

	Module.GuildDataTextFrame:SetScript('OnMouseUp', OnMouseUp)
	Module.GuildDataTextFrame:SetScript('OnLeave', OnLeave)
	Module.GuildDataTextFrame:SetScript('OnEnter', OnEnter)
	Module.GuildDataTextFrame:SetScript('OnEvent', OnEvent)
end