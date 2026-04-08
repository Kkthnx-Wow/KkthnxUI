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
local unpack = _G.unpack

local _G = _G
local C_BattleNet_GetFriendAccountInfo = _G.C_BattleNet.GetFriendAccountInfo
local C_FriendList_GetFriendInfoByIndex = _G.C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetWhoInfo = _G.C_FriendList.GetWhoInfo
local GetCVar = _G.GetCVar
local GetGuildRosterInfo = _G.GetGuildRosterInfo
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local HookSecureFunc = _G.hooksecurefunc

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

	HookSecureFunc("GuildRoster_SetView", function(rosterViewType)
		if not C["Misc"].YClassColors then
			return
		end
		setGuildRosterView(rosterViewType)
	end)

	HookSecureFunc("GuildRoster_Update", function()
		if not C["Misc"].YClassColors then
			return
		end
		refreshGuildRosterView()
	end)

	HookSecureFunc(_G.GuildRosterContainer, "update", function()
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
	local friendScrollTarget = _G.FriendsListFrame.ScrollBox and _G.FriendsListFrame.ScrollBox.ScrollTarget
	if not friendScrollTarget or not currentPlayerZone then
		return
	end

	local childCount = friendScrollTarget:GetNumChildren()
	for friendIndex = 1, childCount do
		local friendButton = select(friendIndex, friendScrollTarget:GetChildren())
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

		HookSecureFunc(_G.FriendsListFrame.ScrollBox, "Update", function()
			if C["Misc"].YClassColors then
				refreshFriendsList()
			end
		end)

		HookSecureFunc(_G.C_FriendList, "SortWho", function(sortType)
			currentWhoSortType = sortType
		end)

		HookSecureFunc(_G.WhoFrame.ScrollBox, "Update", function(whoScrollBox)
			if not C["Misc"].YClassColors then
				return
			end

			local scrollChildCount = whoScrollBox.ScrollTarget:GetNumChildren()
			if not scrollChildCount then
				return
			end

			for whoIndex = 1, scrollChildCount do
				local whoRosterButton = select(whoIndex, whoScrollBox.ScrollTarget:GetChildren())
				local whoInfoData = C_FriendList_GetWhoInfo(whoRosterButton.index)
				if whoInfoData then
					local guildName, levelValue, raceStr, areaName, classIdentifier = whoInfoData.fullGuildName, whoInfoData.level, whoInfoData.raceStr, whoInfoData.area, whoInfoData.filename
					WHO_COLUMN_DATA_MAP.zone = areaName or ""
					WHO_COLUMN_DATA_MAP.guild = guildName or ""
					WHO_COLUMN_DATA_MAP.race = raceStr or ""

					whoRosterButton.Name:SetTextColor(getClassColoredString(classIdentifier, true))
					whoRosterButton.Level:SetText(getLevelDifficultyColorHex(levelValue) .. levelValue)
					whoRosterButton.Variable:SetText(WHO_COLUMN_DATA_MAP[currentWhoSortType])
				end
			end
		end)
	end
end

Module:RegisterMisc("yClassColors", Module.createYClassColorsInfrastructure)
