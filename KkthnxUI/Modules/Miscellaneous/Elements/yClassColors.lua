local K, C = KkthnxUI[1], KkthnxUI[2]

-- Sourced: yClassColors (yleaf)
-- Edited: KkthnxUI (Kkthnx)

local format, ipairs, tinsert = string.format, ipairs, table.insert
local C_FriendList_GetWhoInfo = C_FriendList.GetWhoInfo
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo

-- Colors
local function classColor(class, showRGB)
	local color = K.ClassColors[K.ClassList[class] or class] or K.ClassColors["PRIEST"]

	if showRGB then
		return color.r, color.g, color.b
	else
		return "|c" .. color.colorStr
	end
end

local function diffColor(level)
	return K.RGBToHex(GetQuestDifficultyColor(level))
end

local rankColor = {
	1,
	0,
	0,
	1,
	1,
	0,
	0,
	1,
	0,
}

local repColor = {
	1,
	0,
	0,
	1,
	1,
	0,
	0,
	1,
	0,
	0,
	1,
	1,
	0,
	0,
	1,
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
	local buttons = GuildRosterContainer.buttons

	for _, button in ipairs(buttons) do
		if button:IsShown() and button.online and button.guildIndex then
			if currentView == "tradeskill" then
				local _, _, _, headerName, _, _, _, _, _, _, _, zone = GetGuildTradeSkillInfo(button.guildIndex)
				if not headerName and zone == playerArea then
					button.string2:SetText("|cff00ff00" .. zone)
				end
			else
				local _, rank, rankIndex, level, _, zone, _, _, _, _, _, _, _, _, _, repStanding = GetGuildRosterInfo(button.guildIndex)
				if currentView == "playerStatus" then
					button.string1:SetText(diffColor(level) .. level)
					if zone == playerArea then
						button.string3:SetText("|cff00ff00" .. zone)
					end
				elseif currentView == "guildStatus" then
					if rankIndex and rank then
						button.string2:SetText(smoothColor(rankIndex, 10, rankColor) .. rank)
					end
				elseif currentView == "achievement" then
					button.string1:SetText(diffColor(level) .. level)
				elseif currentView == "reputation" then
					button.string1:SetText(diffColor(level) .. level)
					if repStanding then
						button.string3:SetText(smoothColor(repStanding - 4, 5, repColor) .. _G["FACTION_STANDING_LABEL" .. repStanding])
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
	hooksecurefunc(GuildRosterContainer, "update", updateGuildView)

	K:UnregisterEvent(event, updateGuildUI)
end
K:RegisterEvent("ADDON_LOADED", updateGuildUI)

-- Friends
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s")

local function UpdateFriendsList()
	local playerArea = GetRealZoneText()

	for i = 1, FriendsListFrame.ScrollBox.ScrollTarget:GetNumChildren() do
		local button = select(i, FriendsListFrame.ScrollBox.ScrollTarget:GetChildren())
		local nameText, infoText

		if button:IsShown() then
			if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
				local info = C_FriendList_GetFriendInfoByIndex(button.id)
				if info and info.connected then
					nameText = classColor(info.className) .. info.name .. "|r, " .. format(FRIENDS_LEVEL_TEMPLATE, diffColor(info.level) .. info.level .. "|r", info.className)
					if info.area == playerArea then
						infoText = format("|cff00ff00%s|r", info.area)
					end
				end
			elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
				local accountInfo = C_BattleNet_GetFriendAccountInfo(button.id)
				if accountInfo then
					local accountName = accountInfo.accountName
					local gameAccountInfo = accountInfo.gameAccountInfo
					if gameAccountInfo.isOnline and gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
						local charName = gameAccountInfo.characterName
						local class = gameAccountInfo.className or UNKNOWN
						local zoneName = gameAccountInfo.areaName or UNKNOWN
						if accountName and charName and class then
							nameText = accountName .. " " .. FRIENDS_WOW_NAME_COLOR_CODE .. "(" .. classColor(class) .. charName .. FRIENDS_WOW_NAME_COLOR_CODE .. ")"
							if zoneName == playerArea then
								infoText = format("|cff00ff00%s|r", zoneName)
							end
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
hooksecurefunc(FriendsListFrame.ScrollBox, "Update", UpdateFriendsList)

-- Whoframe
local columnTable = {}

hooksecurefunc(WhoFrame.ScrollBox, "Update", function(self)
	local playerZone = GetRealZoneText()
	local playerGuild = GetGuildInfo("player")
	local playerRace = UnitRace("player")

	for i = 1, self.ScrollTarget:GetNumChildren() do
		local button = select(i, self.ScrollTarget:GetChildren())

		local nameText = button.Name
		local levelText = button.Level
		local variableText = button.Variable

		local info = C_FriendList_GetWhoInfo(button.index)
		if info then
			local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
			if zone == playerZone then
				zone = "|cff00ff00" .. zone
			end
			if guild == playerGuild then
				guild = "|cff00ff00" .. guild
			end
			if race == playerRace then
				race = "|cff00ff00" .. race
			end

			wipe(columnTable)
			tinsert(columnTable, zone)
			tinsert(columnTable, guild)
			tinsert(columnTable, race)

			nameText:SetTextColor(classColor(class, true))
			levelText:SetText(diffColor(level) .. level)
			variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(WhoFrameDropDown)])
		end
	end
end)
