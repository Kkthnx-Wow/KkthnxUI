local K, C, L = select(2, ...):unpack()

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local format = string.format
local join = string.join
local gsub = string.gsub

local tthead, ttsubh, ttoff = {r = 0.4, g = 0.78, b = 1}, {r = 0.75, g = 0.9, b = 1}, {r = 0.3, g = 1, b = 0.3}
local activezone, inactivezone = {r = 0.3, g = 1.0, b = 0.3}, {r = 0.65, g = 0.65, b = 0.65}
local displayString = join("", "%s: ", "%d")
local guildInfoString = "%s [%d]"
local guildInfoString2 = "%s: %d/%d"
local guildMotDString = " %s |cffaaaaaa- |cffffffff%s"
local levelNameString = "|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s"
local levelNameStatusString = "|cff%02x%02x%02x%d|r %s %s"
local nameRankString = "%s |cff999999-|cffffffff %s"
local noteString = " %s"
local officerNoteString = " o: %s"

local guildTable, guildXP, guildMotD = {}, {}, ""
local totalOnline = 0

local function BuildGuildTable()
	totalOnline = 0
	wipe(guildTable)

	local _, name, rank, level, zone, note, officernote, connected, status, class, isMobile
	for i = 1, GetNumGuildMembers() do
		name, rank, _, level, _, zone, note, officernote, connected, status, class, _, _, isMobile = GetGuildRosterInfo(i)
		name = gsub(name, "-.*", "")

		if(status == 1) then
			status = "|cffff0000[" .. AFK .. "]|r"
		elseif(status == 2) then
			status = "|cffff0000[" .. DND .. "]|r"
		else
			status = ""
		end

		guildTable[i] = {name, rank, level, zone, note, officernote, connected, status, class, isMobile}
		if(connected) then
			totalOnline = totalOnline + 1
		end
	end

	table.sort(guildTable, function(a, b)
		if(a and b) then
			return a[1] < b[1]
		end
	end)
end

local function UpdateGuildXP()
	local currentXP, remainingXP = UnitGetGuildXP("player")
	local nextLevelXP = currentXP + remainingXP

	if(nextLevelXP == 0 or maxDailyXP == 0) then
		return
	end

	local percentTotal = tostring(math.ceil((currentXP / nextLevelXP) * 100))

	guildXP[0] = {currentXP, nextLevelXP, percentTotal}
end

local function UpdateGuildMessage()
	guildMotD = GetGuildRosterMOTD()
end

local menuFrame = CreateFrame("Frame", "_GuildRightClickMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{text = OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = INVITE, hasArrow = true, notCheckable = true,},
	{text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true,}
}

local function inviteClick(self, arg1, arg2, checked)
	menuFrame:Hide()
	InviteUnit(arg1)
end

local function whisperClick(self, arg1, arg2, checked)
	menuFrame:Hide()
	SetItemRef("player:" .. arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton")
end

local function ToggleGuildFrame()
	if(IsInGuild()) then
		if(not GuildFrame) then
			GuildFrame_LoadUI()
		end

		GuildFrame_Toggle()
		GuildFrame_TabClicked(GuildFrameTab2)
	else
		if(not LookingForGuildFrame) then
			LookingForGuildFrame_LoadUI()
		end

		if(LookingForGuildFrame) then
			LookingForGuildFrame_Toggle()
		end
	end
end

local function OnMouseUp(self, btn)
	if(btn ~= "RightButton" or not IsInGuild()) then
		return
	end

	GameTooltip:Hide()

	local classc, levelc, grouped
	local menuCountWhispers = 0
	local menuCountInvites = 0

	menuList[2].menuList = {}
	menuList[3].menuList = {}

	for i = 1, #guildTable do
		if(guildTable[i][7] and (guildTable[i][1] ~= K.Name and guildTable[i][1] ~= K.Name .. "-" .. GetRealmName())) then
			local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[guildTable[i][9]], GetQuestDifficultyColor(guildTable[i][3])

			if(UnitInParty(guildTable[i][1]) or UnitInRaid(guildTable[i][1])) then
				grouped = "|cffaaaaaa*|r"
			else
				grouped = ""
				if(not guildTable[i][10]) then
					menuCountInvites = menuCountInvites + 1
					menuList[2].menuList[menuCountInvites] = {
						text = format(levelNameString, levelc.r * 255, levelc.g * 255, levelc.b * 255, guildTable[i][3], classc.r * 255, classc.g * 255, classc.b * 255, guildTable[i][1], ""),
						arg1 = guildTable[i][1],
						notCheckable = true,
						func = inviteClick
					}
				end
			end
			menuCountWhispers = menuCountWhispers + 1
			menuList[3].menuList[menuCountWhispers] = {
				text = format(levelNameString, levelc.r * 255, levelc.g * 255, levelc.b * 255, guildTable[i][3], classc.r * 255, classc.g * 255, classc.b * 255, guildTable[i][1], grouped),
				arg1 = guildTable[i][1],
				notCheckable = true,
				func = whisperClick
			}
		end
	end

	Lib_EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
end

local function OnEnter(self)
	if(InCombatLockdown() or not IsInGuild()) then
		return
	end

	GuildRoster()
	UpdateGuildMessage()
	BuildGuildTable()

	local name, rank, level, zone, note, officernote, connected, status, class, isMobile
	local zonec, classc, levelc
	local online = totalOnline
	local GuildInfo = GetGuildInfo("player")
	--local GuildLevel = GetGuildLevel()

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()

	--if(GuildInfo and GuildLevel) then
	if(GuildInfo) then
		GameTooltip:AddDoubleLine(format(guildInfoString, GuildInfo, ""), format(guildInfoString2, GUILD, online, #guildTable), tthead.r, tthead.g, tthead.b, tthead.r, tthead.g, tthead.b)
	end

	if(guildMotD ~= "") then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(format(guildMotDString, GUILD_MOTD, guildMotD), ttsubh.r, ttsubh.g, ttsubh.b, 1)
	end

	local col = K.RGBToHex(ttsubh.r, ttsubh.g, ttsubh.b)
	GameTooltip:AddLine(" ")
	if(GuildLevel and GuildLevel ~= 25) then
		--UpdateGuildXP()

		if(guildXP[0]) then
			local currentXP, nextLevelXP, percentTotal = unpack(guildXP[0])

			GameTooltip:AddLine(format(col .. GUILD_EXPERIENCE_CURRENT, "|r |cffffffff" .. K.ShortValue(currentXP), K.ShortValue(nextLevelXP), percentTotal))
		end
	end

	local _, _, standingID, barMin, barMax, barValue = GetGuildFactionInfo()
	if(standingID ~= 8) then
		barMax = barMax - barMin
		barValue = barValue - barMin
		barMin = 0
		GameTooltip:AddLine(format("%s:|r |cffffffff%s/%s (%s%%)", col .. COMBAT_FACTION_CHANGE, K.ShortValue(barValue), K.ShortValue(barMax), math.ceil((barValue / barMax) * 100)))
	end

	if(online > 1) then
		GameTooltip:AddLine(" ")
		for i = 1, #guildTable do
			if(online <= 1) then
				if(online > 1) then
					GameTooltip:AddLine(format("+ %d More...", online - modules.Guild.maxguild), ttsubh.r, ttsubh.g, ttsubh.b)
				end

				break
			end

			name, rank, level, zone, note, officernote, connected, status, class, isMobile = unpack(guildTable[i])
			if(connected and name ~= K.Name) then
				if(GetRealZoneText() == zone) then
					zonec = activezone
				else
					zonec = inactivezone
				end
				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)

				if(isMobile) then
					zone = ""
				end

				if(IsShiftKeyDown()) then
					GameTooltip:AddDoubleLine(format(nameRankString, name, rank), zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)

					if(note ~= "") then
						GameTooltip:AddLine(format(noteString, note), ttsubh.r, ttsubh.g, ttsubh.b, 1)
					end

					if(officernote ~= "") then
						GameTooltip:AddLine(format(officerNoteString, officernote), ttoff.r, ttoff.g, ttoff.b ,1)
					end
				else
					GameTooltip:AddDoubleLine(format(levelNameStatusString, levelc.r * 255, levelc.g * 255, levelc.b * 255, level, name, status), zone, classc.r, classc.g, classc.b, zonec.r, zonec.g, zonec.b)
				end
			end
		end
	end

	GameTooltip:Show()
end

local function OnMouseDown(self, btn)
	if(btn ~= "LeftButton") then
		return
	end

	ToggleGuildFrame()
end

local function Update(self)
	if(not IsInGuild()) then
		self.Text:SetText(NameColor .. L_DATATEXT_GUILDNOGUILD .. "|r")

		return
	end

	GuildRoster()
	totalOnline = select(3, GetNumGuildMembers())

	self.Text:SetFormattedText("%s: %s", NameColor .. GUILD .. "|r", ValueColor .. totalOnline .. "|r")
end

local function Enable(self)
	if(not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("GUILD_ROSTER_SHOW")
	self:RegisterEvent("GUILD_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnEvent", Update)
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnEvent", nil)
end

DataText:Register(GUILD, Enable, Disable, Update)
