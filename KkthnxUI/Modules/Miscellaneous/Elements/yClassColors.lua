--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Module: yClassColors (social list class colors)
-- ----
-- Friends list: friend cache + deferred ScrollBox paint.
-- WoW friends use SetTextColor; BNet only colors the (character) segment.
-- Who frame: lean ScrollBox class/difficulty colors (unchanged surface).
-- Legacy GuildUI roster hooks removed — Communities owns that UI now.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local select = select
local string_format = string.format
local string_gsub = string.gsub
local table_wipe = table.wipe

local _G = _G
local BNGetNumFriends = _G.BNGetNumFriends
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetWhoInfo = C_FriendList.GetWhoInfo
local CreateFrame = CreateFrame
local GetClassInfo = GetClassInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local hooksecurefunc = hooksecurefunc

local FRIENDS_BUTTON_TYPE_WOW = FRIENDS_BUTTON_TYPE_WOW
local FRIENDS_BUTTON_TYPE_BNET = FRIENDS_BUTTON_TYPE_BNET
local FRIENDS_BUTTON_TYPE_DIVIDER = FRIENDS_BUTTON_TYPE_DIVIDER
local FRIENDS_BUTTON_TYPE_INVITE = FRIENDS_BUTTON_TYPE_INVITE
local FRIENDS_BUTTON_TYPE_INVITE_HEADER = FRIENDS_BUTTON_TYPE_INVITE_HEADER
local BNET_CLIENT_WOW = BNET_CLIENT_WOW

local ClassColors = K.ClassColors
local ClassList = K.ClassList

-- Weak per-button stamp state — never write flags onto Blizzard button fields.
local buttonState = setmetatable({}, { __mode = "k" })
local function GetButtonState(button)
	local state = buttonState[button]
	if not state then
		state = {}
		buttonState[button] = state
	end
	return state
end

-- BNet keyed by id; WoW keyed by id + offset.
local friendCache = {}
local FC_WOW_OFFSET = 10000

local isHooksInstalled = false
local friendsEventsRegistered = false
local paintDirty = false

local paintDriver = CreateFrame("Frame")
paintDriver:Hide()

local friendsEventFrame = CreateFrame("Frame")

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

local function IsEnabled()
	return C["Misc"].YClassColors
end

local function GetLevelDifficultyColorHex(levelValue)
	return K.RGBToHex(GetQuestDifficultyColor(levelValue))
end

local function ApplyZoneColoring(zoneText, currentPlayerZone)
	if zoneText and zoneText == currentPlayerZone then
		return string_format("|cff00ff00%s|r", zoneText)
	end
	return zoneText
end

local function GetClassColor(classFile)
	return ClassColors[classFile] or ClassColors["PRIEST"]
end

local function GetClassColorCode(classFile)
	local color = GetClassColor(classFile)
	if color and color.colorStr then
		return "|c" .. color.colorStr
	end
	if color then
		return string_format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
	end
end

local function GetFriendClassFile(bnetInfo, wowInfo)
	if bnetInfo and bnetInfo.gameAccountInfo then
		local gi = bnetInfo.gameAccountInfo
		if gi.classID and gi.classID > 0 then
			local _, classFile = GetClassInfo(gi.classID)
			if classFile then
				return classFile
			end
		end
		if gi.className then
			return ClassList[gi.className]
		end
	elseif wowInfo and wowInfo.className then
		return ClassList[wowInfo.className]
	end
end

-- ---------------------------------------------------------------------------
-- Friend cache
-- ---------------------------------------------------------------------------

local function RefreshFriendCache()
	table_wipe(friendCache)

	local numBNet = BNGetNumFriends and BNGetNumFriends() or 0
	for i = 1, numBNet do
		local info = C_BattleNet_GetFriendAccountInfo(i)
		if info then
			friendCache[i] = info
		end
	end

	local numWoW = C_FriendList_GetNumFriends and C_FriendList_GetNumFriends() or 0
	for i = 1, numWoW do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info then
			friendCache[i + FC_WOW_OFFSET] = info
		end
	end
end

local function GetCachedFriendInfo(button)
	if not (button and button.buttonType and button.id) then
		return nil, nil
	end

	if button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local cached = friendCache[button.id]
		if cached then
			return cached, nil
		end
		local info = C_BattleNet_GetFriendAccountInfo(button.id)
		if info then
			friendCache[button.id] = info
		end
		return info, nil
	end

	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local key = button.id + FC_WOW_OFFSET
		local cached = friendCache[key]
		if cached then
			return nil, cached
		end
		local info = C_FriendList_GetFriendInfoByIndex(button.id)
		if info then
			friendCache[key] = info
		end
		return nil, info
	end

	return nil, nil
end

local function ClearVisibleStamps()
	local scrollBox = _G.FriendsListFrame and _G.FriendsListFrame.ScrollBox
	if not scrollBox then
		return
	end

	if scrollBox.EnumerateFrames then
		for _, button in scrollBox:EnumerateFrames() do
			local state = buttonState[button]
			if state then
				state.stampType = nil
				state.stampId = nil
			end
		end
		return
	end

	local frames = scrollBox.GetFrames and scrollBox:GetFrames()
	if not frames then
		return
	end
	for i = 1, #frames do
		local state = buttonState[frames[i]]
		if state then
			state.stampType = nil
			state.stampId = nil
		end
	end
end

-- ---------------------------------------------------------------------------
-- Paint (reads cache only — no friend API in ScrollBox hot path)
-- ---------------------------------------------------------------------------

local function UpdateNameColor(button, bnetInfo, wowInfo)
	local nameText = button.name or button.Name
	if not nameText then
		return
	end

	local classFile = GetFriendClassFile(bnetInfo, wowInfo)
	if not classFile then
		return
	end

	if wowInfo then
		local color = GetClassColor(classFile)
		if color then
			nameText:SetTextColor(color.r, color.g, color.b)
		end
		return
	end

	if bnetInfo then
		local text = nameText:GetText()
		if not text then
			return
		end
		local colorCode = GetClassColorCode(classFile)
		if not colorCode then
			return
		end
		local colored = string_gsub(text, "%((.-)%)", "(" .. colorCode .. "%1|r)")
		if colored ~= text then
			nameText:SetText(colored)
		end
	end
end

local function UpdateZoneInfo(button, bnetInfo, wowInfo, currentPlayerZone)
	local infoText = button.info or button.Info
	if not (infoText and currentPlayerZone) then
		return
	end

	local zoneName
	if wowInfo and wowInfo.connected then
		zoneName = wowInfo.area
	elseif bnetInfo and bnetInfo.gameAccountInfo then
		local gi = bnetInfo.gameAccountInfo
		if gi.isOnline and gi.clientProgram == BNET_CLIENT_WOW then
			zoneName = gi.areaName
		end
	end

	if zoneName then
		infoText:SetText(ApplyZoneColoring(zoneName, currentPlayerZone))
	end
end

local function ShouldPaintFriendButton(button)
	if not (button and button.buttonType) then
		return false
	end
	if button.buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then
		return false
	end
	if button.buttonType == FRIENDS_BUTTON_TYPE_INVITE then
		return false
	end
	if button.buttonType == FRIENDS_BUTTON_TYPE_INVITE_HEADER then
		return false
	end
	return true
end

local function PostUpdateFriendButton(button)
	if not IsEnabled() then
		return
	end
	if not (_G.FriendsFrame and _G.FriendsFrame:IsShown()) then
		return
	end
	if not ShouldPaintFriendButton(button) then
		return
	end

	local state = GetButtonState(button)
	local curType = button.buttonType
	local curId = button.id or 0
	if state.stampType == curType and state.stampId == curId then
		return
	end
	state.stampType = curType
	state.stampId = curId

	local bnetInfo, wowInfo = GetCachedFriendInfo(button)
	UpdateNameColor(button, bnetInfo, wowInfo)
	UpdateZoneInfo(button, bnetInfo, wowInfo, GetRealZoneText())
end

local function ProcessFriendButtons()
	if not IsEnabled() then
		return
	end

	local scrollBox = _G.FriendsListFrame and _G.FriendsListFrame.ScrollBox
	if not scrollBox then
		return
	end

	local function paint(button)
		if ShouldPaintFriendButton(button) then
			local state = buttonState[button]
			if state then
				state.stampType = nil
				state.stampId = nil
			end
			PostUpdateFriendButton(button)
		end
	end

	if scrollBox.EnumerateFrames then
		for _, button in scrollBox:EnumerateFrames() do
			paint(button)
		end
		return
	end

	local frames = scrollBox.GetFrames and scrollBox:GetFrames()
	if frames then
		for i = 1, #frames do
			paint(frames[i])
		end
	end
end

local function MarkFriendsDirty()
	if not IsEnabled() then
		return
	end
	if paintDirty then
		return
	end
	paintDirty = true
	paintDriver:Show()
end

paintDriver:SetScript("OnUpdate", function(self)
	self:Hide()
	paintDirty = false
	if _G.FriendsFrame and _G.FriendsFrame:IsShown() then
		ProcessFriendButtons()
	end
end)

-- ---------------------------------------------------------------------------
-- Friend list events (only while FriendsFrame is shown)
-- ---------------------------------------------------------------------------

friendsEventFrame:SetScript("OnEvent", function()
	if not IsEnabled() then
		return
	end
	RefreshFriendCache()
	ClearVisibleStamps()
	MarkFriendsDirty()
end)

local function RegisterFriendsEvents()
	if friendsEventsRegistered then
		return
	end
	friendsEventsRegistered = true
	friendsEventFrame:RegisterEvent("FRIENDLIST_UPDATE")
	friendsEventFrame:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	friendsEventFrame:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	friendsEventFrame:RegisterEvent("BN_FRIEND_INVITE_ADDED")
	friendsEventFrame:RegisterEvent("BN_FRIEND_INVITE_REMOVED")
end

local function UnregisterFriendsEvents()
	if not friendsEventsRegistered then
		return
	end
	friendsEventsRegistered = false
	friendsEventFrame:UnregisterAllEvents()
end

local function OnFriendsFrameShow()
	if not IsEnabled() then
		return
	end
	RefreshFriendCache()
	RegisterFriendsEvents()
	MarkFriendsDirty()
end

local function OnFriendsFrameHide()
	UnregisterFriendsEvents()
	paintDirty = false
	paintDriver:Hide()
end

-- ---------------------------------------------------------------------------
-- Who frame (lean path — not friend cache)
-- ---------------------------------------------------------------------------

local WHO_COLUMN_DATA_MAP = {
	zone = "",
	guild = "",
	race = "",
}
local currentWhoSortType = "zone"
local whoRowScratch = {}

local function getScrollBoxRows(scrollBox)
	if not scrollBox then
		return
	end
	if scrollBox.GetFrames then
		return scrollBox:GetFrames()
	end
	if scrollBox.EnumerateFrames then
		table_wipe(whoRowScratch)
		local i = 0
		for _, frame in scrollBox:EnumerateFrames() do
			i = i + 1
			whoRowScratch[i] = frame
		end
		return whoRowScratch
	end

	local target = scrollBox.ScrollTarget
	if not target then
		return
	end
	table_wipe(whoRowScratch)
	for i = 1, target:GetNumChildren() do
		whoRowScratch[i] = select(i, target:GetChildren())
	end
	return whoRowScratch
end

local function RefreshWhoList(whoScrollBox)
	if not IsEnabled() then
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
			local guildName = whoInfoData.fullGuildName
			local levelValue = whoInfoData.level
			local raceStr = whoInfoData.raceStr
			local areaName = whoInfoData.area
			local classIdentifier = whoInfoData.filename

			WHO_COLUMN_DATA_MAP.zone = areaName or ""
			WHO_COLUMN_DATA_MAP.guild = guildName or ""
			WHO_COLUMN_DATA_MAP.race = raceStr or ""

			local classFile = classIdentifier or ClassList[whoInfoData.classStr]
			local color = classFile and GetClassColor(classFile)
			if whoRosterButton.Name and color then
				whoRosterButton.Name:SetTextColor(color.r, color.g, color.b)
			end
			if whoRosterButton.Level and levelValue then
				whoRosterButton.Level:SetText(GetLevelDifficultyColorHex(levelValue) .. levelValue)
			end
			if whoRosterButton.Variable then
				whoRosterButton.Variable:SetText(WHO_COLUMN_DATA_MAP[currentWhoSortType] or "")
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Infrastructure
-- ---------------------------------------------------------------------------

function Module:createYClassColorsInfrastructure()
	if not isHooksInstalled then
		isHooksInstalled = true

		if _G.FriendsFrame_UpdateFriendButton then
			hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
				if not ShouldPaintFriendButton(button) then
					return
				end
				local state = buttonState[button]
				if state then
					state.stampType = nil
					state.stampId = nil
				end
				-- Blizzard just reset the row text/colors — restyle next frame.
				MarkFriendsDirty()
			end)
		end

		local friendsListFrame = _G.FriendsListFrame
		if friendsListFrame and friendsListFrame.ScrollBox then
			hooksecurefunc(friendsListFrame.ScrollBox, "Update", function()
				MarkFriendsDirty()
			end)
			friendsListFrame.ScrollBox:HookScript("OnMouseWheel", function()
				MarkFriendsDirty()
			end)
		end

		local friendsFrame = _G.FriendsFrame
		if friendsFrame then
			friendsFrame:HookScript("OnShow", OnFriendsFrameShow)
			friendsFrame:HookScript("OnHide", OnFriendsFrameHide)
			if friendsFrame:IsShown() then
				OnFriendsFrameShow()
			end
		end

		if C_FriendList and C_FriendList.SortWho then
			hooksecurefunc(C_FriendList, "SortWho", function(sortType)
				currentWhoSortType = sortType
			end)
		end

		local whoFrame = _G.WhoFrame
		if whoFrame and whoFrame.ScrollBox then
			hooksecurefunc(whoFrame.ScrollBox, "Update", function(whoScrollBox)
				RefreshWhoList(whoScrollBox)
			end)
		end
	end

	if IsEnabled() then
		if _G.FriendsFrame and _G.FriendsFrame:IsShown() then
			OnFriendsFrameShow()
		end
		MarkFriendsDirty()
	else
		UnregisterFriendsEvents()
		paintDirty = false
		paintDriver:Hide()
	end
end

function Module:UpdateYClassColors()
	Module:createYClassColorsInfrastructure()
end

Module:RegisterMisc("yClassColors", Module.createYClassColorsInfrastructure)
