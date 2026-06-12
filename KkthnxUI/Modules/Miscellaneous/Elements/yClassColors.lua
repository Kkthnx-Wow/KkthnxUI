--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Colors player names by class and levels by difficulty in guild, friends, and WHO lists.
-- - Design: Hooks Blizzard's social list update functions to inject class-colored strings and formatted zone text.
-- - Events: ADDON_LOADED (Blizzard_GuildUI), Social list updates.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local ipairs = _G.ipairs
local select = _G.select
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local _G = _G
local C_BattleNet_GetFriendAccountInfo = _G.C_BattleNet.GetFriendAccountInfo
local C_FriendList_GetFriendInfoByIndex = _G.C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetWhoInfo = _G.C_FriendList.GetWhoInfo
local GetCVar = _G.GetCVar
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local hooksecurefunc = _G.hooksecurefunc

-- SG: Constants
local FRIENDS_BUTTON_TYPE_WOW = _G.FRIENDS_BUTTON_TYPE_WOW
local FRIENDS_BUTTON_TYPE_BNET = _G.FRIENDS_BUTTON_TYPE_BNET
local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW

-- REASON: Cache K tables for performance in high-frequency list updates.
local ClassColors = K.ClassColors
local ClassList = K.ClassList

-- SG: Returns a class-colored string or RGB values based on class filename.
local function getClassColoredString(classIdentifier, returnRGBValues)
	local colorData = ClassColors[ClassList[classIdentifier] or classIdentifier]
	if not colorData then
		colorData = ClassColors["PRIEST"]
	end

	if returnRGBValues then
		return colorData.r, colorData.g, colorData.b
	else
		return "|c" .. colorData.colorStr
	end
end

-- SG: Returns a difficulty-colored level hex string.
local function getLevelDifficultyColorHex(levelValue)
	return K.RGBToHex(GetQuestDifficultyColor(levelValue))
end

-- SG: Gradually modifies color based on current/max progression.
local function getSmoothGradientColorHex(currentProgress, maxProgress, colorTable)
	local r, g, b = K.oUF:RGBColorGradient(currentProgress, maxProgress, unpack(colorTable))
	return K.RGBToHex(r, g, b)
end

-- SG: Colors zone text green if it matches the player's current area.
local function applyZoneColoring(zoneText, targetZone, currentPlayerZone)
	return targetZone == currentPlayerZone and string_format("|cff00ff00%s|r", zoneText) or zoneText
end

local GUILD_RANK_COLOR_GRADIENT = { 1, 0, 0, 1, 1, 0, 0, 1, 0 }
local GUILD_REPUTATION_COLOR_GRADIENT = { 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1 }

local currentRosterViewType
local rowScratch = {}

local function getScrollBoxRows(scrollBox)
	if not scrollBox then
		return
	end
	if scrollBox.GetFrames then
		return scrollBox:GetFrames()
	end

	local target = scrollBox.ScrollTarget
	if not target then
		return
	end

	table_wipe(rowScratch)
	for i = 1, target:GetNumChildren() do
		rowScratch[i] = select(i, target:GetChildren())
	end
	return rowScratch
end

local function setGuildRosterView(rosterViewType)
	if not C["Misc"].YClassColors then
		return
	end
	currentRosterViewType = rosterViewType
end

-- REASON: Updates individual guild roster rows with colored level, rank, and zone information.
local function updateGuildRosterButton(rosterButton, rosterViewType, currentPlayerZone, rankName, rankIndex, levelValue, zoneName, reputationStandingID)
	if not C["Misc"].YClassColors then
		return
	end

	if rosterViewType == "playerStatus" then
		rosterButton.string1:SetText(getLevelDifficultyColorHex(levelValue) .. levelValue)
		rosterButton.string3:SetText(applyZoneColoring(zoneName, zoneName, currentPlayerZone))
	elseif rosterViewType == "guildStatus" and rankIndex and rankName then
		rosterButton.string2:SetText(getSmoothGradientColorHex(rankIndex, 10, GUILD_RANK_COLOR_GRADIENT) .. rankName)
	elseif rosterViewType == "achievement" then
		rosterButton.string1:SetText(getLevelDifficultyColorHex(levelValue) .. levelValue)
	elseif rosterViewType == "reputation" and reputationStandingID then
		rosterButton.string1:SetText(getLevelDifficultyColorHex(levelValue) .. levelValue)
		rosterButton.string3:SetText(getSmoothGradientColorHex(reputationStandingID - 4, 5, GUILD_REPUTATION_COLOR_GRADIENT) .. _G["FACTION_STANDING_LABEL" .. reputationStandingID])
	end
end

-- SG: Iterates through visible guild roster buttons to apply custom colors.
local function refreshGuildRosterView()
	if not C["Misc"].YClassColors then
		return
	end

	currentRosterViewType = currentRosterViewType or GetCVar("guildRosterView")
	local currentPlayerZone = GetRealZoneText()
	local rosterContainer = _G.GuildRosterContainer
	if not rosterContainer or not rosterContainer.buttons then
		return
	end

	for _, rosterButton in ipairs(rosterContainer.buttons) do
		if rosterButton:IsShown() and rosterButton.online and rosterButton.guildIndex then
			local _, rankName, rankIndex, levelValue, _, zoneName, _, _, _, _, _, _, _, _, _, reputationStandingID = GetGuildRosterInfo(rosterButton.guildIndex)
			updateGuildRosterButton(rosterButton, currentRosterViewType, currentPlayerZone, rankName, rankIndex, levelValue, zoneName, reputationStandingID)
		end
	end
end

local function onGuildUIAddonLoaded(eventName, addonName)
	if not C["Misc"].YClassColors or addonName ~= "Blizzard_GuildUI" then
		return
	end

	hooksecurefunc("GuildRoster_SetView", function(rosterViewType)
		if not C["Misc"].YClassColors then
			return
		end
		setGuildRosterView(rosterViewType)
	end)

	hooksecurefunc("GuildRoster_Update", function()
		if not C["Misc"].YClassColors then
			return
		end
		refreshGuildRosterView()
	end)

	hooksecurefunc(_G.GuildRosterContainer, "update", function()
		if not C["Misc"].YClassColors then
			return
		end
		refreshGuildRosterView()
	end)

	K:UnregisterEvent(eventName, onGuildUIAddonLoaded)
end

-- REASON: Local localized version of the friends level template to avoid modifying Blizzard's global string.
local FRIENDS_LEVEL_TEMPLATE_LOCAL = string_gsub(string_gsub(_G.FRIENDS_LEVEL_TEMPLATE, "%%d", "%%s"), "%$d", "%$s")

local function updateFriendListButton(friendButton, currentPlayerZone)
	if not C["Misc"].YClassColors or not friendButton or not currentPlayerZone then
		return
	end

	local nameTextContent, infoTextContent
	if friendButton.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local friendInfo = C_FriendList_GetFriendInfoByIndex(friendButton.id)
		if friendInfo and friendInfo.connected then
			nameTextContent = getClassColoredString(friendInfo.className) .. friendInfo.name .. "|r, " .. string_format(FRIENDS_LEVEL_TEMPLATE_LOCAL, getLevelDifficultyColorHex(friendInfo.level) .. friendInfo.level .. "|r", friendInfo.className)
			infoTextContent = applyZoneColoring(friendInfo.area, friendInfo.area, currentPlayerZone)
		end
	elseif friendButton.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local bnetAccountInfo = C_BattleNet_GetFriendAccountInfo(friendButton.id)
		if bnetAccountInfo and bnetAccountInfo.gameAccountInfo then
			local bnetGameAccountInfo = bnetAccountInfo.gameAccountInfo
			if bnetGameAccountInfo.isOnline and bnetGameAccountInfo.clientProgram == BNET_CLIENT_WOW then
				local characterNameStr = bnetGameAccountInfo.characterName
				local classIdentifier = bnetGameAccountInfo.className or _G.UNKNOWN
				local zoneNameStr = bnetGameAccountInfo.areaName or _G.UNKNOWN
				if characterNameStr and classIdentifier then
					nameTextContent = bnetAccountInfo.accountName .. " " .. _G.FRIENDS_WOW_NAME_COLOR_CODE .. "(" .. getClassColoredString(classIdentifier) .. characterNameStr .. _G.FRIENDS_WOW_NAME_COLOR_CODE .. ")"
					infoTextContent = applyZoneColoring(zoneNameStr, zoneNameStr, currentPlayerZone)
				end
			end
		end
	end

	if nameTextContent then
		friendButton.name:SetText(nameTextContent)
	end
	if infoTextContent then
		friendButton.info:SetText(infoTextContent)
	end
end

local function refreshFriendsList()
	if not C["Misc"].YClassColors then
		return
	end

	local currentPlayerZone = GetRealZoneText()
	local friendsListFrame = _G.FriendsListFrame
	local rows = friendsListFrame and getScrollBoxRows(friendsListFrame.ScrollBox)
	if not rows or not currentPlayerZone then
		return
	end

	for friendIndex = 1, #rows do
		local friendButton = rows[friendIndex]
		if friendButton and friendButton:IsShown() then
			updateFriendListButton(friendButton, currentPlayerZone)
		end
	end
end

local WHO_COLUMN_DATA_MAP = {
	["zone"] = "",
	["guild"] = "",
	["race"] = "",
}
local currentWhoSortType = "zone"
local isSocialHookInstalled = false

function Module:createYClassColorsInfrastructure()
	if not C["Misc"].YClassColors then
		K:UnregisterEvent("ADDON_LOADED", onGuildUIAddonLoaded)
		return
	end

	if not isSocialHookInstalled then
		isSocialHookInstalled = true

		K:RegisterEvent("ADDON_LOADED", onGuildUIAddonLoaded)

		local friendsListFrame = _G.FriendsListFrame
		if friendsListFrame and friendsListFrame.ScrollBox then
			hooksecurefunc(friendsListFrame.ScrollBox, "Update", function()
				if C["Misc"].YClassColors then
					refreshFriendsList()
				end
			end)
		end

		if _G.C_FriendList and _G.C_FriendList.SortWho then
			hooksecurefunc(_G.C_FriendList, "SortWho", function(sortType)
				currentWhoSortType = sortType
			end)
		end

		local whoFrame = _G.WhoFrame
		if whoFrame and whoFrame.ScrollBox then
			hooksecurefunc(whoFrame.ScrollBox, "Update", function(whoScrollBox)
				if not C["Misc"].YClassColors then
					return
				end

				local rows = getScrollBoxRows(whoScrollBox)
				if not rows then
					return
				end

				for whoIndex = 1, #rows do
					local whoRosterButton = rows[whoIndex]
					local whoInfoData = whoRosterButton and C_FriendList_GetWhoInfo(whoRosterButton.index)
					if whoInfoData then
						local guildName, levelValue, raceStr, areaName, classIdentifier = whoInfoData.fullGuildName, whoInfoData.level, whoInfoData.raceStr, whoInfoData.area, whoInfoData.filename
						WHO_COLUMN_DATA_MAP.zone = areaName or ""
						WHO_COLUMN_DATA_MAP.guild = guildName or ""
						WHO_COLUMN_DATA_MAP.race = raceStr or ""

						if whoRosterButton.Name then
							whoRosterButton.Name:SetTextColor(getClassColoredString(classIdentifier, true))
						end
						if whoRosterButton.Level then
							whoRosterButton.Level:SetText(getLevelDifficultyColorHex(levelValue) .. levelValue)
						end
						if whoRosterButton.Variable then
							whoRosterButton.Variable:SetText(WHO_COLUMN_DATA_MAP[currentWhoSortType])
						end
					end
				end
			end)
		end
	end

	refreshFriendsList()
	refreshGuildRosterView()
end

function Module:UpdateYClassColors()
	if C["Misc"].YClassColors then
		Module:createYClassColorsInfrastructure()
	else
		refreshFriendsList()
		refreshGuildRosterView()
	end
end

Module:RegisterMisc("yClassColors", Module.createYClassColorsInfrastructure)
