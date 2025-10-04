local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- Localize frequently used APIs and globals for performance (Lua 5.1)
local select = select
local format = string.format
local ipairs = ipairs
local unpack = unpack
local GetGuildRosterInfo = GetGuildRosterInfo
local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW
local FRIENDS_BUTTON_TYPE_BNET = FRIENDS_BUTTON_TYPE_BNET
local BNET_CLIENT_WOW = BNET_CLIENT_WOW

-- Cache K tables
local ClassColors = K.ClassColors
local ClassList = K.ClassList

-- Cache some Blizzard API calls that may be used frequently
local getRealZoneText = GetRealZoneText
local C_FriendList_GetWhoInfo = C_FriendList.GetWhoInfo
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo

-- Returns a class-colored string or RGB values.
local function classColor(class, showRGB)
	local color = ClassColors[ClassList[class] or class]
	if not color then
		color = ClassColors["PRIEST"]
	end
	if showRGB then
		return color.r, color.g, color.b
	else
		return "|c" .. color.colorStr
	end
end

-- Returns a difficulty-colored level hex string.
local function diffColor(level)
	return K.RGBToHex(GetQuestDifficultyColor(level))
end

-- Gradually modifies color based on cur/max; used for ranks/reputations.
local function smoothColor(cur, max, color)
	local r, g, b = K.oUF:RGBColorGradient(cur, max, unpack(color))
	return K.RGBToHex(r, g, b)
end

-- Colors a zone green if it matches the player's current area.
local function applyZoneColor(text, zone, playerArea)
	return zone == playerArea and format("|cff00ff00%s|r", text) or text
end

local rankColor = { 1, 0, 0, 1, 1, 0, 0, 1, 0 }
local repColor = { 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 0, 1 }

-- Tracks the current guild view (playerStatus, guildStatus, achievement, reputation, etc.)
local currentView

-- Sets the current guild view, e.g., 'playerStatus' or 'guildStatus'.
local function setView(view)
	if not C["Misc"].YClassColors then
		return
	end
	currentView = view
end

-- Updates a single guild roster button with class colors and zone color.
local function updateGuildInfo(button, view, playerArea, rank, rankIndex, level, zone, repStanding)
	if not C["Misc"].YClassColors then
		return
	end

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

-- Called whenever the guild roster view updates to apply our custom coloring.
local function updateGuildView()
	if not C["Misc"].YClassColors then
		return
	end

	currentView = currentView or GetCVar("guildRosterView")
	local playerArea = getRealZoneText()
	if not GuildRosterContainer or not GuildRosterContainer.buttons then
		return
	end

	local buttons = GuildRosterContainer.buttons
	for _, button in ipairs(buttons) do
		if button:IsShown() and button.online and button.guildIndex then
			-- Avoid table allocation per row by reading only used fields
			local _, rank, rankIndex, level, _, zone, _, _, _, _, _, _, _, _, _, repStanding = GetGuildRosterInfo(button.guildIndex)
			updateGuildInfo(button, currentView, playerArea, rank, rankIndex, level, zone, repStanding)
		end
	end
end

-- Only call hooks for GuildRoster_* after Blizzard_GuildUI is loaded.
local function updateGuildUI(event, addon)
	if not C["Misc"].YClassColors then
		return
	end

	if addon ~= "Blizzard_GuildUI" then
		return
	end

	-- Wrap these hooks with a quick check, in case of disable
	hooksecurefunc("GuildRoster_SetView", function(view)
		if not C["Misc"].YClassColors then
			return
		end
		setView(view)
	end)

	hooksecurefunc("GuildRoster_Update", function()
		if not C["Misc"].YClassColors then
			return
		end
		updateGuildView()
	end)

	hooksecurefunc(GuildRosterContainer, "update", function()
		if not C["Misc"].YClassColors then
			return
		end
		updateGuildView()
	end)

	K:UnregisterEvent(event, updateGuildUI)
end

-- Build a local friends level template; avoid mutating Blizzard globals
local FRIENDS_LEVEL_TEMPLATE_L = (FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s"):gsub("%$d", "%$s"))

-- Updates a single friend-list button with class and zone colors.
local function updateFriendButton(button, playerArea)
	if not C["Misc"].YClassColors or not button or not playerArea then
		return
	end

	local nameText, infoText
	-- WoW friend
	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList_GetFriendInfoByIndex(button.id)
		if info and info.connected then
			nameText = classColor(info.className) .. info.name .. "|r, " .. format(FRIENDS_LEVEL_TEMPLATE_L, diffColor(info.level) .. info.level .. "|r", info.className)
			infoText = applyZoneColor(info.area, info.area, playerArea)
		end
	-- BNET friend
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet_GetFriendAccountInfo(button.id)
		if accountInfo and accountInfo.gameAccountInfo then
			local gameAccountInfo = accountInfo.gameAccountInfo
			if gameAccountInfo.isOnline and gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
				local charName = gameAccountInfo.characterName
				local class = gameAccountInfo.className or UNKNOWN
				local zoneName = gameAccountInfo.areaName or UNKNOWN
				if charName and class then
					nameText = accountInfo.accountName .. " " .. FRIENDS_WOW_NAME_COLOR_CODE .. "(" .. classColor(class) .. charName .. FRIENDS_WOW_NAME_COLOR_CODE .. ")"
					infoText = applyZoneColor(zoneName, zoneName, playerArea)
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

-- Called whenever the friends list updates (including BNet friends).
local function UpdateFriendsList()
	if not C["Misc"].YClassColors then
		return
	end

	local playerArea = getRealZoneText()
	if not playerArea then
		return
	end

	local scrollTarget = FriendsListFrame.ScrollBox and FriendsListFrame.ScrollBox.ScrollTarget
	if not scrollTarget then
		return
	end

	local numChildren = scrollTarget:GetNumChildren()
	for friendIndex = 1, numChildren do
		local button = select(friendIndex, scrollTarget:GetChildren())
		if button and button:IsShown() then
			updateFriendButton(button, playerArea)
		end
	end
end

local columnTable = {
	["zone"] = "",
	["guild"] = "",
	["race"] = "",
}
local currentType = "zone"

local hooksInstalled = false

function Module:UpdateYClassColors()
	if not C["Misc"].YClassColors then
		-- Remove event registrations
		K:UnregisterEvent("ADDON_LOADED", updateGuildUI)

		-- print("yClassColors: Disabled.")
	else
		if not hooksInstalled then
			hooksInstalled = true

			-- Listen for Blizzard_GuildUI
			K:RegisterEvent("ADDON_LOADED", updateGuildUI)

			-- Friends list
			hooksecurefunc(FriendsListFrame.ScrollBox, "Update", function()
				if C["Misc"].YClassColors then
					UpdateFriendsList()
				end
			end)

			-- SortWho (used in the WhoFrame)
			hooksecurefunc(C_FriendList, "SortWho", function(sortType)
				currentType = sortType
			end)

			-- WhoFrame updates
			hooksecurefunc(WhoFrame.ScrollBox, "Update", function(self)
				if not C["Misc"].YClassColors then
					return
				end

				local numChildren = self.ScrollTarget:GetNumChildren()
				if not numChildren then
					return
				end
				for whoIndex = 1, numChildren do
					local button = select(whoIndex, self.ScrollTarget:GetChildren())
					local info = C_FriendList_GetWhoInfo(button.index)
					if info then
						local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
						columnTable.zone = zone or ""
						columnTable.guild = guild or ""
						columnTable.race = race or ""
						button.Name:SetTextColor(classColor(class, true))
						button.Level:SetText(diffColor(level) .. level)
						button.Variable:SetText(columnTable[currentType])
					end
				end
			end)
		end

		-- print("yClassColors: Enabled.")
	end
end
