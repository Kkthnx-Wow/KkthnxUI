local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local string_format = _G.string.format
local table_wipe = _G.table.wipe
local table_sort = _G.table.sort

local Ambiguate = _G.Ambiguate
local C_GuildInfo_GuildRoster = _G.C_GuildInfo.GuildRoster
local GetGuildInfo = _G.GetGuildInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetGuildRosterMOTD = _G.GetGuildRosterMOTD
local GetNumGuildMembers = _G.GetNumGuildMembers
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGuild = _G.IsInGuild
local IsShiftKeyDown = _G.IsShiftKeyDown
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local hooksecurefunc = _G.hooksecurefunc

local menuFrame = CreateFrame("Frame", "KKUI_GuildDropDownMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{text = _G.OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = _G.INVITE, hasArrow = true, notCheckable = true},
	{text = _G.CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true},
}

local guildTable = {}
local function BuildGuildTable()
	table_wipe(guildTable)

	for i = 1, GetNumGuildMembers() do
		local name, rank, _, level, _, zone, note, officernote, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
		name = Ambiguate(name, "none")
		guildTable[i] = {name, rank, level, zone, note, officernote, connected, status, class, mobile}
	end

	table_sort(guildTable, function(a, b)
		if (a and b) then
			return a[1] < b[1]
		end
	end)
end

function Module:GuildOnEnter()
	if not IsInGuild() then
		GameTooltip:SetOwner(_G.GuildMicroButton, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(_G.GuildMicroButton))
		GameTooltip:ClearLines()

		GameTooltip:AddLine("|cffffffff"..LOOKINGFORGUILD.."|r".." (J)")

		GameTooltip:Show()
		return
	end

	if IsInGuild() then
		Module.GuildHovered = true
		C_GuildInfo_GuildRoster()
		local name, rank, level, zone, note, officernote, connected, status, class, isMobile, zone_r, zone_g, zone_b, classc, levelc, grouped
		local total, _, online = GetNumGuildMembers()
		local gmotd = GetGuildRosterMOTD()

		GameTooltip:SetOwner(_G.GuildMicroButton, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(_G.GuildMicroButton))
		GameTooltip:ClearLines()

		GameTooltip:AddLine("|cffffffff"..GUILD.."|r".." (J)")
		GameTooltip:AddLine(" ")

		GameTooltip:AddDoubleLine(GetGuildInfo("player"), string_format(K.InfoColor.."%s: %d/%d", GUILD_ONLINE_LABEL, online, total))
		GameTooltip:AddLine(" ")

		if gmotd ~= "" then
			GameTooltip:AddLine(string_format(K.InfoColor.."%s |cffaaaaaa- |cffffffff%s", GUILD_MOTD, gmotd))
		end

		if Module.GuildMax ~= 0 and online >= 1 then
			GameTooltip:AddLine(" ")
			for i = 1, total do
				if Module.GuildMax and i > Module.GuildMax then
					if online > 2 then
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(string_format(K.InfoColor.."%d %s (%s)", online - Module.GuildMax, "Hidden", ALT_KEY))
					end
					break
				end

				name, rank, _, level, _, zone, note, officernote, connected, status, class, _, _, isMobile = GetGuildRosterInfo(i)
				if (connected or isMobile) and level >= Module.GuildLevelThreshold then
					name = Ambiguate(name, "all")
					if GetRealZoneText() == zone then
						zone_r, zone_g, zone_b = 0.3, 1, 0.3
					else
						zone_r, zone_g, zone_b = 1, 1, 1
					end

					if isMobile then
						zone = "|cffa5a5a5"..REMOTE_CHAT.."|r"
					end

					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
					grouped = (UnitInParty(name) or UnitInRaid(name)) and (GetRealZoneText() == zone and " |cff7fff00*|r" or " |cffff7f00*|r") or ""
					if Module.GuildAltKeyDown then
						GameTooltip:AddDoubleLine(string_format("%s%s |cff999999- |cffffffff%s", grouped, name, rank), zone, classc.r, classc.g, classc.b, zone_r, zone_g, zone_b)
						if note ~= "" then
							GameTooltip:AddLine(K.InfoColor.." "..NOTE_COLON.." "..note)
						end

						if officernote ~= "" and EPGP then
							local ep, gp = EPGP:GetEPGP(name)
							if ep then
								officernote = " EP: "..ep.." GP: "..gp.." PR: "..string.format("%.3f", ep / gp)
							else
								officernote = " O."..NOTE_COLON.." "..officernote
							end
						elseif officernote ~= "" then
							officernote = " O."..NOTE_COLON.." "..officernote
						end

						if officernote ~= "" then
							GameTooltip:AddLine(officernote, 0.3, 1, 0.3, 1)
						end
					else
						if status == 1 then
							status = [[|TInterface\FriendsFrame\StatusIcon-Away:16:16:0:0|t]]
						elseif status == 2 then
							status = [[|TInterface\FriendsFrame\StatusIcon-DnD:16:16:0:0|t]]
						else
							status = ""
						end

						GameTooltip:AddDoubleLine(string_format("|cff%02x%02x%02x%d|r %s%s%s", levelc.r * 255, levelc.g * 255, levelc.b * 255, level, name, status, grouped), zone, classc.r, classc.g, classc.b, zone_r, zone_g, zone_b)
					end
				end
			end

			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(" ", string_format("%s %s", K.GreyColor.."Sorting by|r", K.InfoColor..CURRENT_GUILD_SORTING))
		end

		GameTooltip:Show()
	end
end

function Module:GuildOnLeave()
	GameTooltip:Hide()
	Module.GuildHovered = false
end

function Module:GuildOnEvent()
	if Module.GuildHovered then
		Module.GuildFrame:GetScript("OnEnter")(Module.GuildOnEnter)
	end

	if IsInGuild() then
		BuildGuildTable()
		local _, _, guildOnline = GetNumGuildMembers()
		Module.GuildFont:SetFormattedText("%d", guildOnline)
	else
		Module.GuildFont:SetText(" ")
	end
end

function Module:GuildOnUpdate(elapsed)
	if IsInGuild() then
		if not Module.GuildHovered then
			return
		end

		if IsAltKeyDown() and not Module.GuildAltKeyDown then
			Module.GuildAltKeyDown = true
			Module.GuildFrame:GetScript("OnEnter")(Module.GuildOnEnter)
		elseif not IsAltKeyDown() and Module.GuildAltKeyDown then
			Module.GuildAltKeyDown = false
			Module.GuildFrame:GetScript("OnEnter")(Module.GuildOnEnter)
		end

		if not Module.GuildMOTD then
			Module.GuildElapsed = (Module.GuildElapsed or 0) + elapsed
			if Module.GuildElapsed > 1 then
				C_GuildInfo_GuildRoster()
				Module.GuildElapsed = 0
			end

			if GetGuildRosterMOTD() ~= "" then
				Module.GuildMOTD = true
				if Module.GuildHovered then
					Module.GuildFrame:GetScript("OnEnter")(Module.GuildOnEnter)
				end
			end
		end
	end
end

function Module:GuildOnMouseUp(btn)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
		return
	end

	if btn == "LeftButton" then
		ToggleGuildFrame()
	elseif btn == "MiddleButton" and IsInGuild() then
		local s = CURRENT_GUILD_SORTING
		SortGuildRoster(IsShiftKeyDown() and s or (IsAltKeyDown() and (s == "rank" and "note" or "rank") or s == "class" and "name" or s == "name" and "level" or s == "level" and "zone" or "class"))
		Module:GuildOnEnter()
	elseif btn == "RightButton" and IsInGuild() then
		GameTooltip:Hide()
		Module.GuildHovered = false

		local grouped
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		for i = 1, #guildTable do
			if (guildTable[i][7] or guildTable[i][10]) and guildTable[i][1] ~= K.Name then
				local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[guildTable[i][9]], GetQuestDifficultyColor(guildTable[i][3])
				if UnitInParty(guildTable[i][1]) or UnitInRaid(guildTable[i][1]) then
					grouped = "|cffaaaaaa*|r"
				else
					grouped = ""
					if not guildTable[i][10] then
						menuCountInvites = menuCountInvites + 1
						menuList[2].menuList[menuCountInvites] = {
							text = string.format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s", levelc.r * 255, levelc.g * 255, levelc.b * 255, guildTable[i][3], classc.r * 255, classc.g * 255, classc.b * 255, Ambiguate(guildTable[i][1], "all"), ""),
							arg1 = guildTable[i][1],
							notCheckable = true,
							func = function(_, arg1)
								menuFrame:Hide()
								InviteUnit(arg1)
							end
						}
					end
				end
				menuCountWhispers = menuCountWhispers + 1
				menuList[3].menuList[menuCountWhispers] = {
					text = string.format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s", levelc.r * 255, levelc.g * 255, levelc.b * 255, guildTable[i][3], classc.r * 255, classc.g * 255, classc.b * 255, Ambiguate(guildTable[i][1], "all"), grouped),
					arg1 = guildTable[i][1],
					notCheckable = true,
					func = function(_, arg1)
						menuFrame:Hide()
						SetItemRef("player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton")
					end
				}
			end
		end

		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	end
end

function Module:CreateGuildDataText()
	if not C["DataText"].Guild then
		return
	end

	if not GuildMicroButton then
		return
	end

	Module.GuildMax = nil -- Set max members listed, nil means no limit. Alt-key reveals hidden members
	Module.GuildLevelThreshold = 1 -- Minimum level displayed (1 - 90)
	Module.GuildSorting = "class" -- Default roster sorting: name, level, class, zone, rank, note

	hooksecurefunc("SortGuildRoster", function(type)
		CURRENT_GUILD_SORTING = type
	end)

	Module.GuildFrame = CreateFrame("Button", "KKUI_GuildDataText", UIParent)
	Module.GuildFrame:SetAllPoints(GuildMicroButton)
	Module.GuildFrame:SetSize(GuildMicroButton:GetWidth(), GuildMicroButton:GetHeight())
	Module.GuildFrame:SetFrameLevel(GuildMicroButton:GetFrameLevel() + 2)

	Module.GuildFont = Module.GuildFrame:CreateFontString("OVERLAY")
	Module.GuildFont:FontTemplate(nil, nil, "OUTLINE")
	Module.GuildFont:SetPoint("CENTER", Module.GuildFrame, "CENTER", 1, -6)

	C_GuildInfo_GuildRoster()
	SortGuildRoster(Module.GuildSorting == "note" and "rank" or "note")
	SortGuildRoster(Module.GuildSorting)

	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.GuildOnEvent)
	K:RegisterEvent("GUILD_ROSTER_UPDATE", Module.GuildOnEvent)
	K:RegisterEvent("PLAYER_GUILD_UPDATE", Module.GuildOnEvent)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.GuildOnEvent)

	Module.GuildFrame:SetScript("OnUpdate", Module.GuildOnUpdate)
	Module.GuildFrame:SetScript("OnEvent", Module.GuildOnEvent)
	Module.GuildFrame:SetScript("OnMouseUp", Module.GuildOnMouseUp)
	Module.GuildFrame:SetScript("OnEnter", Module.GuildOnEnter)
	Module.GuildFrame:SetScript("OnLeave", Module.GuildOnLeave)

	Module:GuildOnUpdate()
end