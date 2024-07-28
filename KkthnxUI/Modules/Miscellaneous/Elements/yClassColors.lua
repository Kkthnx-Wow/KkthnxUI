local K = KkthnxUI[1]

local format, ipairs, tinsert, unpack = string.format, ipairs, table.insert, unpack
local C_FriendList_GetWhoInfo = C_FriendList.GetWhoInfo
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo

-- Helper Functions
local function classColor(class, showRGB)
	local color = K.ClassColors[K.ClassList[class] or class]
	if not color then
		color = K.ClassColors["PRIEST"]
	end

	if showRGB then
		return color.r, color.g, color.b
	else
		return "|c" .. color.colorStr
	end
end

local function diffColor(level)
	return K.RGBToHex(GetQuestDifficultyColor(level))
end

local function smoothColor(cur, max, color)
	local r, g, b = K.oUF:RGBColorGradient(cur, max, unpack(color))
	return K.RGBToHex(r, g, b)
end

local function applyZoneColor(text, zone, playerArea)
	return zone == playerArea and format("|cff00ff00%s|r", text) or text
end

-- Color Data
local rankColor = { 1, 0, 0, 1, 1, 0, 0, 1, 0 }
local repColor = { 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1 }

-- Guild View Handlers
local currentView
local function setView(view)
	currentView = view
end

local function updateGuildInfo(button, view, playerArea, rank, rankIndex, level, zone, repStanding)
	if view == "playerStatus" then
		button.string1:SetText(diffColor(level) .. level)
		button.string3:SetText(applyZoneColor(zone, zone, playerArea))
	elseif view == "guildStatus" and rankIndex and rank then
		button.string2:SetText(smoothColor(rankIndex, 10, rankColor) .. rank)
	elseif view == "achievement" then
		button.string1:SetText(diffColor(level) .. level)
	elseif view == "reputation" and repStanding then
		button.string1:SetText(diffColor(level) .. level)
		button.string3:SetText(smoothColor(repStanding - 4, 5, repColor) .. _G["FACTION_STANDING_LABEL" .. repStanding])
	end
end

local function updateGuildView()
	currentView = currentView or GetCVar("guildRosterView")
	local playerArea = GetRealZoneText()
	local buttons = GuildRosterContainer.buttons

	for _, button in ipairs(buttons) do
		if button:IsShown() and button.online and button.guildIndex then
			local guildInfo = { GetGuildRosterInfo(button.guildIndex) }
			updateGuildInfo(button, currentView, playerArea, unpack(guildInfo))
		end
	end
end

local function updateGuildUI(event, addon)
	if addon ~= "Blizzard_GuildUI" then
		return
	end
	hooksecurefunc("GuildRoster_SetView", setView)
	hooksecurefunc("GuildRoster_Update", updateGuildView)
	hooksecurefunc(GuildRosterContainer, "update", updateGuildView)
	K:UnregisterEvent(event, updateGuildUI)
end
K:RegisterEvent("ADDON_LOADED", updateGuildUI)

-- Friends List Update
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s")

local function updateFriendButton(button, playerArea)
	local nameText, infoText
	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList_GetFriendInfoByIndex(button.id)
		if info and info.connected then
			nameText = classColor(info.className) .. info.name .. "|r, " .. format(FRIENDS_LEVEL_TEMPLATE, diffColor(info.level) .. info.level .. "|r", info.className)
			infoText = applyZoneColor(info.area, info.area, playerArea)
		end
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet_GetFriendAccountInfo(button.id)
		if accountInfo and accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
			local gameAccountInfo = accountInfo.gameAccountInfo
			local charName, class, zoneName = gameAccountInfo.characterName, gameAccountInfo.className or UNKNOWN, gameAccountInfo.areaName or UNKNOWN
			if charName and class then
				nameText = accountInfo.accountName .. " " .. FRIENDS_WOW_NAME_COLOR_CODE .. "(" .. classColor(class) .. charName .. FRIENDS_WOW_NAME_COLOR_CODE .. ")"
				infoText = applyZoneColor(zoneName, zoneName, playerArea)
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

--- Updates the friends list with the current player's area.
-- @param none
-- @return none
local function UpdateFriendsList()
	local playerArea = GetRealZoneText()
	if playerArea then
		local numChildren = FriendsListFrame.ScrollBox.ScrollTarget:GetNumChildren()
		if numChildren then
			for friendIndex = 1, numChildren do
				local button = select(friendIndex, FriendsListFrame.ScrollBox.ScrollTarget:GetChildren())
				if button and button:IsShown() then
					updateFriendButton(button, playerArea)
				end
			end
		else
			print("Error: Unable to get the number of children.")
		end
	else
		print("Error: Unable to get the real zone text.")
	end
end
hooksecurefunc(FriendsListFrame.ScrollBox, "Update", UpdateFriendsList)

-- WhoFrame Update
local columnTable = {}
--- Updates the WhoFrame with the current player's zone, guild, and race.
hooksecurefunc(WhoFrame.ScrollBox, "Update", function(self)
	local playerZone, playerGuild, playerRace = GetRealZoneText(), GetGuildInfo("player"), UnitRace("player")
	local numChildren = self.ScrollTarget:GetNumChildren()
	if numChildren then
		for whoIndex = 1, numChildren do
			local button = select(whoIndex, self.ScrollTarget:GetChildren())
			local info = C_FriendList_GetWhoInfo(button.index)
			if info then
				local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
				wipe(columnTable)
				tinsert(columnTable, applyZoneColor(zone, zone, playerZone))
				tinsert(columnTable, applyZoneColor(guild, guild, playerGuild))
				tinsert(columnTable, applyZoneColor(race, race, playerRace))
				button.Name:SetTextColor(classColor(class, true))
				button.Level:SetText(diffColor(level) .. level)
				button.Variable:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)])
			end
		end
	else
		print("Error: Unable to get the number of children.")
	end
end)
