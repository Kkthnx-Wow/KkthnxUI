--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/SocialColors.lua
	Purpose:
		Class-colour player names and difficulty-colour levels across the social
		panels: the Friends list (WoW and Battle.net friends), the /who results
		window, and the legacy guild roster (when Blizzard_GuildUI is present).

		Colours come from KkthnxUI's own harmonised class palette (K.ClassColors),
		so a name in the Friends list reads the same shade as the same class on the
		unit frames and nameplates, rather than Blizzard's brighter defaults.

		Every hook target is existence-guarded so the module stays quiet on layouts
		where a frame or API is missing (for example the modern Communities guild
		UI, which has none of the legacy roster hooks). Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("SocialColors")

local _G = _G
local pairs = pairs
local select = select
local wipe = wipe
local floor = math.floor
local format = string.format

local RGBToHex = K.RGBToHex
local CLASS_COLORS = K.ClassColors
local Colors = K.Colors

local GetAreaText = GetAreaText
local GetGuildInfo = GetGuildInfo
local UnitRace = UnitRace
local GetGuildRosterInfo = GetGuildRosterInfo
local GetGuildTradeSkillInfo = GetGuildTradeSkillInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local C_FriendList = C_FriendList
local C_BattleNet = C_BattleNet

local WHITE = "|cffffffff"
-- Our success green, used to flag a friend or guildmate sharing your zone/guild.
local JADE = RGBToHex(Colors.jade[1], Colors.jade[2], Colors.jade[3])
local ONLINE_JADE = JADE .. "%s|r"

local function ShouldShow()
	return C.Skins and C.Skins.SocialColors
end

-- ---------------------------------------------------------------------------
-- Colour helpers
-- ---------------------------------------------------------------------------

-- Localised class name -> class token (e.g. "Death Knight" -> "DEATHKNIGHT"),
-- built once so the per-row scroll hooks stay a single table lookup.
local classToken = {}
do
	local male = _G.LOCALIZED_CLASS_NAMES_MALE
	local female = _G.LOCALIZED_CLASS_NAMES_FEMALE
	if male then
		for token, localized in pairs(male) do
			classToken[localized] = token
		end
	end
	if female then
		for token, localized in pairs(female) do
			classToken[localized] = token
		end
	end
end

-- A colour escape ("|cffRRGGBB") for a class token or localised class name.
local function ClassColorStr(class)
	local token = class and (classToken[class] or class)
	local color = token and CLASS_COLORS[token]
	if not color then
		return WHITE
	end
	return RGBToHex(color[1], color[2], color[3])
end

-- Class colour as an r, g, b triplet, for SetTextColor. Falls back to white.
local function ClassColorRGB(class)
	local token = class and (classToken[class] or class)
	local color = token and CLASS_COLORS[token]
	if not color then
		return 1, 1, 1
	end
	return color[1], color[2], color[3]
end

-- Difficulty colour escape for a level.
local function DiffColor(level)
	local color = GetQuestDifficultyColor(level)
	return RGBToHex(color.r, color.g, color.b)
end

-- Linear gradient across a flat { r,g,b, r,g,b, ... } stop list, used for the
-- guild rank and reputation columns. cur in [0, max] picks the position.
local function GradientHex(cur, max, stops)
	if max <= 0 then
		max = 1
	end
	local percent = cur / max
	if percent < 0 then
		percent = 0
	elseif percent > 1 then
		percent = 1
	end

	local segments = (#stops / 3) - 1
	local segment = percent * segments
	local index = floor(segment)
	if index >= segments then
		index = segments - 1
	end
	local relative = segment - index

	local i = index * 3
	local r = stops[i + 1] + (stops[i + 4] - stops[i + 1]) * relative
	local g = stops[i + 2] + (stops[i + 5] - stops[i + 2]) * relative
	local b = stops[i + 3] + (stops[i + 6] - stops[i + 3]) * relative
	return RGBToHex(r, g, b)
end

-- Gradient stops from the UI palette so the guild rank and reputation columns run
-- through the same crimson, gold, and jade the rest of the addon uses. Rank goes
-- low to high, reputation runs hated to exalted and finishes on the accent blue.
local cr, gd, jd, ac = Colors.crimson, Colors.gold, Colors.jade, Colors.accent
local rankColor = { cr[1], cr[2], cr[3], gd[1], gd[2], gd[3], jd[1], jd[2], jd[3] }
local repColor = { cr[1], cr[2], cr[3], gd[1], gd[2], gd[3], jd[1], jd[2], jd[3], ac[1], ac[2], ac[3], ac[1], ac[2], ac[3] }

-- Friends level line uses %d, swap to %s so a coloured level string fits.
local levelTemplate
local function GetLevelTemplate()
	if not levelTemplate then
		local raw = _G.FRIENDS_LEVEL_TEMPLATE or "Level %d %s"
		levelTemplate = raw:gsub("%%d", "%%s"):gsub("%$d", "%$s")
	end
	return levelTemplate
end

-- ---------------------------------------------------------------------------
-- Row enumeration
--   Modern ScrollBoxes expose GetFrames(), which hands back the active-frame
--   array directly with no allocation. Fall back to the legacy child walk (into
--   a reused scratch table) only when that API is missing.
-- ---------------------------------------------------------------------------
local enumScratch = {}
local function GetRowFrames(scrollBox)
	if scrollBox.GetFrames then
		return scrollBox:GetFrames()
	end
	local target = scrollBox.ScrollTarget
	if not target then
		return nil
	end
	wipe(enumScratch)
	for i = 1, target:GetNumChildren() do
		enumScratch[i] = select(i, target:GetChildren())
	end
	return enumScratch
end

-- ---------------------------------------------------------------------------
-- Friends list (WoW + Battle.net)
-- ---------------------------------------------------------------------------
local function UpdateFriendsList(self)
	if not ShouldShow() then
		return
	end
	local buttons = GetRowFrames(self)
	if not buttons then
		return
	end
	local playerArea = GetAreaText()

	for i = 1, #buttons do
		local button = buttons[i]
		if button and button:IsShown() then
			local nameText, infoText

			if button.buttonType == _G.FRIENDS_BUTTON_TYPE_WOW then
				local info = C_FriendList.GetFriendInfoByIndex(button.id)
				if info and info.connected then
					nameText = ClassColorStr(info.className) .. info.name .. "|r, " .. format(GetLevelTemplate(), DiffColor(info.level) .. info.level .. "|r", info.className)
					if info.area == playerArea then
						infoText = format(ONLINE_JADE, info.area)
					end
				end
			elseif button.buttonType == _G.FRIENDS_BUTTON_TYPE_BNET then
				local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
				local gameAccountInfo = accountInfo and accountInfo.gameAccountInfo
				if gameAccountInfo and gameAccountInfo.isOnline and gameAccountInfo.clientProgram == _G.BNET_CLIENT_WOW then
					local charName = gameAccountInfo.characterName
					local class = gameAccountInfo.className or UNKNOWN
					local zoneName = gameAccountInfo.areaName or UNKNOWN
					local accountName = accountInfo.accountName
					if accountName and charName and class then
						local wow = _G.FRIENDS_WOW_NAME_COLOR_CODE or WHITE
						nameText = accountName .. " " .. wow .. "(" .. ClassColorStr(class) .. charName .. wow .. ")"
						if zoneName == playerArea then
							infoText = format(ONLINE_JADE, zoneName)
						end
					end
				end
			end

			if nameText and button.name then
				button.name:SetText(nameText)
			end
			if infoText and button.info then
				button.info:SetText(infoText)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- /who results
-- ---------------------------------------------------------------------------
local whoColumns = { zone = "", guild = "", race = "" }
local whoSortType = "zone"

local function UpdateWhoList(self)
	if not ShouldShow() then
		return
	end
	local buttons = GetRowFrames(self)
	if not buttons then
		return
	end
	local playerZone = GetAreaText()
	local playerGuild = GetGuildInfo("player")
	local playerRace = UnitRace("player")

	for i = 1, #buttons do
		local button = buttons[i]
		if button and button.index then
			local info = C_FriendList.GetWhoInfo(button.index)
			if info then
				local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
				if zone and zone == playerZone then
					zone = JADE .. zone
				end
				if guild and guild == playerGuild then
					guild = JADE .. guild
				end
				if race and race == playerRace then
					race = JADE .. race
				end

				whoColumns.zone = zone or ""
				whoColumns.guild = guild or ""
				whoColumns.race = race or ""

				if button.Name then
					button.Name:SetTextColor(ClassColorRGB(class))
				end
				if button.Level then
					button.Level:SetText(DiffColor(level) .. level)
				end
				if button.Variable then
					button.Variable:SetText(whoColumns[whoSortType] or "")
				end
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Guild roster (legacy Blizzard_GuildUI only)
-- ---------------------------------------------------------------------------
local guildView
local function SetGuildView(view)
	guildView = view
end

local function UpdateGuildView()
	if not ShouldShow() then
		return
	end
	local container = _G.GuildRosterContainer
	if not container or not container.buttons then
		return
	end

	guildView = guildView or (GetCVar and GetCVar("guildRosterView")) or "playerStatus"
	local playerArea = GetAreaText()

	for _, button in pairs(container.buttons) do
		if button:IsShown() and button.online and button.guildIndex then
			if guildView == "tradeskill" then
				local _, _, _, headerName, _, _, _, _, _, _, _, zone = GetGuildTradeSkillInfo(button.guildIndex)
				if not headerName and zone == playerArea and button.string2 then
					button.string2:SetText(JADE .. zone)
				end
			else
				local _, rank, rankIndex, level, _, zone, _, _, _, _, _, _, _, _, _, repStanding = GetGuildRosterInfo(button.guildIndex)
				if guildView == "playerStatus" then
					if button.string1 then
						button.string1:SetText(DiffColor(level) .. level)
					end
					if zone == playerArea and button.string3 then
						button.string3:SetText(JADE .. zone)
					end
				elseif guildView == "guildStatus" then
					if rankIndex and rank and button.string2 then
						button.string2:SetText(GradientHex(rankIndex, 10, rankColor) .. rank)
					end
				elseif guildView == "achievement" then
					if button.string1 then
						button.string1:SetText(DiffColor(level) .. level)
					end
				elseif guildView == "reputation" then
					if button.string1 then
						button.string1:SetText(DiffColor(level) .. level)
					end
					if repStanding and button.string3 then
						local label = _G["FACTION_STANDING_LABEL" .. repStanding]
						button.string3:SetText(GradientHex(repStanding - 4, 5, repColor) .. (label or ""))
					end
				end
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Hook installation
-- ---------------------------------------------------------------------------
local function HookFriends()
	local frame = _G.FriendsListFrame
	if frame and frame.ScrollBox then
		hooksecurefunc(frame.ScrollBox, "Update", UpdateFriendsList)
	end
end

local function HookWho()
	local frame = _G.WhoFrame
	if frame and frame.ScrollBox then
		hooksecurefunc(frame.ScrollBox, "Update", UpdateWhoList)
		if C_FriendList and C_FriendList.SortWho then
			hooksecurefunc(C_FriendList, "SortWho", function(sortType)
				whoSortType = sortType
			end)
		end
	end
end

function Module:HookGuild()
	if self.guildHooked then
		return
	end
	self.guildHooked = true
	-- Legacy guild roster only, the modern Communities UI lacks these.
	if _G.GuildRoster_SetView then
		hooksecurefunc("GuildRoster_SetView", SetGuildView)
	end
	if _G.GuildRoster_Update then
		hooksecurefunc("GuildRoster_Update", UpdateGuildView)
	end
	local container = _G.GuildRosterContainer
	if container and container.update then
		hooksecurefunc(container, "update", UpdateGuildView)
	end
end

function Module:ADDON_LOADED(_, addon)
	if addon == "Blizzard_GuildUI" then
		self:HookGuild()
	end
end

function Module:OnEnable()
	if not ShouldShow() or self.hooksInstalled then
		return
	end
	self.hooksInstalled = true

	HookFriends()
	HookWho()

	-- The guild UI is load-on-demand: hook now if it is already up, else wait.
	if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_GuildUI") then
		self:HookGuild()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end
