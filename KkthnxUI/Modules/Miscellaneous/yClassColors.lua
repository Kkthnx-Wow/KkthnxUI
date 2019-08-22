local K = unpack(select(2, ...))

-- Sourced: yClassColors (yleaf)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local string_format = _G.string.format
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe

local BNGetFriendInfo = _G.BNGetFriendInfo
local BNGetGameAccountInfo = _G.BNGetGameAccountInfo
local GetCVar = _G.GetCVar
local GetFriendInfo = _G.GetFriendInfo
local GetGuildInfo = _G.GetGuildInfo
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetGuildTradeSkillInfo = _G.GetGuildTradeSkillInfo
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local GetWhoInfo = _G.GetWhoInfo
local UnitFactionGroup = _G.UnitFactionGroup
local UnitRace = _G.UnitRace
local hooksecurefunc = _G.hooksecurefunc

-- Colors
local function classColor(class, showRGB)
	local color = K.ClassColors[K.ClassList[class] or class]
	if not color then
		color = K.ClassColors["PRIEST"]
	end

	if showRGB then
		return color.r, color.g, color.b
	else
		return "|c"..color.colorStr
	end
end

local function diffColor(level)
	return K.RGBToHex(GetQuestDifficultyColor(level))
end

local rankColor = {
	1, 0, 0,
	1, 1, 0,
	0, 1, 0
}

local repColor = {
	1, 0, 0,
	1, 1, 0,
	0, 1, 0,
	0, 1, 1,
	0, 0, 1,
}

local function smoothColor(cur, max, color)
	local r, g, b = K.oUF:RGBColorGradient(cur, max, unpack(color))
	return K.RGBToHex(r, g, b)
end

-- Guild
local currentView
local function setView(view)
	currentView = view
end

local function updateGuildView()
	currentView = currentView or GetCVar("guildRosterView")

	local playerArea = GetRealZoneText()
	local buttons = _G.GuildRosterContainer.buttons

	for _, button in ipairs(buttons) do
		if button:IsShown() and button.online and button.guildIndex then
			if currentView == "tradeskill" then
				local _, _, _, headerName, _, _, _, _, _, _, _, zone = GetGuildTradeSkillInfo(button.guildIndex)
				if not headerName and zone == playerArea then
					button.string2:SetText("|cff00ff00"..zone)
				end
			else
				local _, rank, rankIndex, level, _, zone, _, _, _, _, _, _, _, _, _, repStanding = GetGuildRosterInfo(button.guildIndex)
				if currentView == "playerStatus" then
					button.string1:SetText(diffColor(level)..level)
					if zone == playerArea then
						button.string3:SetText("|cff00ff00"..zone)
					end
				elseif currentView == "guildStatus" then
					if rankIndex and rank then
						button.string2:SetText(smoothColor(rankIndex, 10, rankColor)..rank)
					end
				elseif currentView == "achievement" then
					button.string1:SetText(diffColor(level)..level)
				elseif currentView == "reputation" then
					button.string1:SetText(diffColor(level)..level)
					if repStanding then
						button.string3:SetText(smoothColor(repStanding - 4, 5, repColor).._G["FACTION_STANDING_LABEL"..repStanding])
					end
				end
			end
		end
	end
end

local function updateGuildUI(event, addon)
	if addon ~= "Blizzard_GuildUI" then
		return
	end

	hooksecurefunc("GuildRoster_SetView", setView)
	hooksecurefunc("GuildRoster_Update", updateGuildView)
	hooksecurefunc(_G.GuildRosterContainer, "update", updateGuildView)

	K:UnregisterEvent(event, updateGuildUI)
end
K:RegisterEvent("ADDON_LOADED", updateGuildUI)

-- Friends
local FRIENDS_LEVEL_TEMPLATE = _G.FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s")

local function friendsFrame()
	local scrollFrame = _G.FriendsFrameFriendsScrollFrame
	local buttons = scrollFrame.buttons
	local playerArea = GetRealZoneText()

	for i = 1, #buttons do
		local nameText, infoText
		local button = buttons[i]
		if button:IsShown() then
			if button.buttonType == _G.FRIENDS_BUTTON_TYPE_WOW then
				local name, level, class, area, connected = GetFriendInfo(button.id)
				if connected then
					nameText = classColor(class)..name.."|r, "..string_format(FRIENDS_LEVEL_TEMPLATE, diffColor(level)..level.."|r", class)
					if area == playerArea then
						infoText = string_format("|cff00ff00%s|r", area)
					end
				end
			elseif button.buttonType == _G.FRIENDS_BUTTON_TYPE_BNET then
				local _, presenceName, _, _, _, gameID, client, isOnline = BNGetFriendInfo(button.id)
				if isOnline and client == _G.BNET_CLIENT_WOW then
					local _, charName, _, _, _, faction, _, class, _, zoneName = BNGetGameAccountInfo(gameID)
					if presenceName and charName and class and faction == UnitFactionGroup("player") then
						nameText = presenceName.." ".._G.FRIENDS_WOW_NAME_COLOR_CODE.."("..classColor(class)..charName.._G.FRIENDS_WOW_NAME_COLOR_CODE..")"
						if zoneName == playerArea then
							infoText = string_format("|cff00ff00%s|r", zoneName)
						end
					end
				end
			end
		end

		if nameText then
			button.name:SetText(nameText)
		end

		if infoText then
			button.info:SetText(infoText)
		end
	end
end
hooksecurefunc(_G.FriendsFrameFriendsScrollFrame, "update", friendsFrame)
hooksecurefunc("FriendsFrame_UpdateFriends", friendsFrame)

-- Whoframe
local columnTable = {}
local function updateWhoList()
	local whoOffset = _G.FauxScrollFrame_GetOffset(_G.WhoListScrollFrame)
	local playerZone = GetRealZoneText()
	local playerGuild = GetGuildInfo("player")
	local playerRace = UnitRace("player")

	for i = 1, _G.WHOS_TO_DISPLAY, 1 do
		local index = whoOffset + i
		local nameText = _G["WhoFrameButton"..i.."Name"]
		local levelText = _G["WhoFrameButton"..i.."Level"]
		local variableText = _G["WhoFrameButton"..i.."Variable"]
		local name, guild, level, race, _, zone, class = GetWhoInfo(index)
		if name then
			if zone == playerZone then
				zone = "|cff00ff00"..zone
			end

			if guild == playerGuild then
				guild = "|cff00ff00"..guild
			end

			if race == playerRace then
				race = "|cff00ff00"..race
			end

			table_wipe(columnTable)
			table_insert(columnTable, zone)
			table_insert(columnTable, guild)
			table_insert(columnTable, race)

			nameText:SetTextColor(classColor(class, true))
			levelText:SetText(diffColor(level)..level)
			variableText:SetText(columnTable[_G.UIDropDownMenu_GetSelectedID(_G.WhoFrameDropDown)])
		end
	end
end
hooksecurefunc("WhoList_Update", updateWhoList)