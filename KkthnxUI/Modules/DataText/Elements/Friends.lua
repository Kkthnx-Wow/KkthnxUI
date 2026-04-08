--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays a list of online friends (WoW and Battle.net) in a custom DataText panel.
-- - Design: Uses a HybridScrollFrame for high-performance listing of large friend counts and handles cross-game info.
-- - Events: BN_FRIEND_ACCOUNT_OFFLINE, BN_FRIEND_ACCOUNT_ONLINE, BN_FRIEND_INFO_CHANGED, CHAT_MSG_SYSTEM, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local BNGetNumFriends = _G.BNGetNumFriends
local BNet_GetClientAtlas = _G.BNet_GetClientAtlas
local C_BattleNet_GetFriendAccountInfo = _G.C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = _G.C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = _G.C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_GetFriendInfoByIndex = _G.C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetNumFriends = _G.C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = _G.C_FriendList.GetNumOnlineFriends
local C_PartyInfo_InviteUnit = _G.C_PartyInfo.InviteUnit
local C_Texture_SetTitleIconTexture = _G.C_Texture.SetTitleIconTexture
local ChatEdit_ActivateChat = _G.ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend
local ChatFrame_SendBNetTell = _G.ChatFrame_SendBNetTell
local ChatFrame_SendTell = _G.ChatFrame_SendTell
local CreateAtlasMarkup = _G.CreateAtlasMarkup
local CreateFrame = _G.CreateFrame
local FriendsFrame_GetFormattedCharacterName = _G.FriendsFrame_GetFormattedCharacterName
local FriendsFrame_GetLastOnline = _G.FriendsFrame_GetLastOnline
local FriendsFrame_InviteOrRequestToJoin = _G.FriendsFrame_InviteOrRequestToJoin
local GameTooltip = _G.GameTooltip
local GetDisplayedInviteType = _G.GetDisplayedInviteType
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local GetTime = _G.GetTime
local HybridScrollFrame_GetOffset = _G.HybridScrollFrame_GetOffset
local HybridScrollFrame_Update = _G.HybridScrollFrame_Update
local IsAltKeyDown = _G.IsAltKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local MailFrameTab_OnClick = _G.MailFrameTab_OnClick
local MouseIsOver = _G.MouseIsOver
local ToggleFriendsFrame = _G.ToggleFriendsFrame
local UIParent = _G.UIParent
local ipairs = ipairs
local math_max = math.max
local math_min = math.min
local next = next
local pairs = pairs
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local table_insert = table.insert
local table_sort = table.sort
local table_wipe = table.wipe
local unpack = unpack

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local BUTTON_HEIGHT = 22
local MAX_VISIBLE_ROWS = 20
local BASE_EXTRA_HEIGHT = 95
local MIN_DT_WIDTH = 56
local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local WOW_PROJECT_ID = _G.WOW_PROJECT_ID or 1
local WOW_PROJECT_CATA = _G.WOW_PROJECT_CATACLYSM_CLASSIC or 14
local WOW_PROJECT_60 = _G.WOW_PROJECT_CLASSIC or 2

local friendsDataText
local infoFrame
local prevUpdateTime
local isUpdateQueued = false
local isFriendsDirty = true
local lastDTW, lastDTH = 0, 0

local activeZoneColor = "|cff4cff4c"
local inactiveColor = K.GreyColor
local noteIconString = "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:16|t %s"
local broadcastIconString = "|TInterface\\FriendsFrame\\BroadcastIcon:12|t %s (%s)"

local onlineMsgPattern = string_gsub(_G.ERR_FRIEND_ONLINE_SS, ".+h", "")
local offlineMsgPattern = string_gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "")

local friendTable = {}
local bnetTable = {}

local menuList = {
	[1] = {
		text = L["Join or Invite"],
		isTitle = true,
		notCheckable = true,
	},
}

-- ---------------------------------------------------------------------------
-- Utility Functions
-- ---------------------------------------------------------------------------
local function getClientLogo(client, size)
	-- REASON: Returns an inline atlas markup for the client's Battle.net icon.
	size = size or 0
	local atlas = BNet_GetClientAtlas("Battlenet-ClientIcon-", client)
	return CreateAtlasMarkup(atlas, size, size, 0, 0)
end

local function sortFriends(a, b)
	return (a and a[1] or "") < (b and b[1] or "")
end

local function buildFriendTable(num)
	-- REASON: Populates a local cache of online WoW friends to avoid repetitive API queries during scroll.
	table_wipe(friendTable)
	for i = 1, num do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info and info.connected then
			local status = _G.FRIENDS_TEXTURE_ONLINE
			if info.afk then
				status = _G.FRIENDS_TEXTURE_AFK
			elseif info.dnd then
				status = _G.FRIENDS_TEXTURE_DND
			end

			local className = K.ClassList[info.className] or info.className
			table_insert(friendTable, { info.name, info.level, className, info.area or _G.UNKNOWN, status, info.notes })
		end
	end
	table_sort(friendTable, sortFriends)
end

local function sortBNFriends(a, b)
	-- REASON: Prioritizes Battle.net friends based on client and faction for easier scanning.
	if K.Faction == "Alliance" then
		return a[5] == b[5] and a[4] < b[4] or a[5] > b[5]
	else
		return a[5] == b[5] and a[4] > b[4] or a[5] > b[5]
	end
end

local function getOnlineInfoText(client, isMobile, rafLinkType, locationText)
	-- REASON: Logic to determine the best descriptive text for a friend's current location/status.
	if not locationText or locationText == "" then
		return _G.UNKNOWN
	end

	if isMobile then
		return "APP"
	end

	if (client == BNET_CLIENT_WOW) and (rafLinkType ~= _G.Enum.RafLinkType.None) then
		if rafLinkType == _G.Enum.RafLinkType.Recruit then
			return string_format(_G.RAF_RECRUIT_FRIEND, locationText)
		else
			return string_format(_G.RAF_RECRUITER_FRIEND, locationText)
		end
	end

	return locationText
end

local function buildBNetTable(num)
	-- REASON: Populates a local cache of online Battle.net friends, processing diverse metadata (client, faction, rich presence).
	table_wipe(bnetTable)
	for i = 1, num do
		local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
		if accountInfo then
			local gameAccountInfo = accountInfo.gameAccountInfo
			local isOnline = gameAccountInfo and gameAccountInfo.isOnline
			local gameID = gameAccountInfo and gameAccountInfo.gameAccountID

			if isOnline and gameID then
				local charName = gameAccountInfo.characterName or ""
				local className = gameAccountInfo.className or _G.UNKNOWN
				local client = gameAccountInfo.clientProgram
				local factionName = gameAccountInfo.factionName or _G.UNKNOWN
				local presenceText = gameAccountInfo.richPresence or ""
				local isGameAFK = gameAccountInfo.isGameAFK
				local isGameBusy = gameAccountInfo.isGameBusy
				local isMobile = gameAccountInfo.isWowMobile
				local level = gameAccountInfo.characterLevel
				local timerunningSeasonID = gameAccountInfo.timerunningSeasonID
				local wowProjectID = gameAccountInfo.wowProjectID
				local zoneName = gameAccountInfo.areaName or _G.UNKNOWN

				charName = FriendsFrame_GetFormattedCharacterName(charName, accountInfo.battleTag, client, timerunningSeasonID)
				local class = K.ClassList[className] or className

				local status = _G.FRIENDS_TEXTURE_ONLINE
				if accountInfo.isAFK or isGameAFK then
					status = _G.FRIENDS_TEXTURE_AFK
				elseif accountInfo.isDND or isGameBusy then
					status = _G.FRIENDS_TEXTURE_DND
				end

				if wowProjectID == WOW_PROJECT_60 then
					presenceText = _G.EXPANSION_NAME0
				elseif wowProjectID == WOW_PROJECT_CATA then
					presenceText = _G.EXPANSION_NAME3
				end

				local infoText = getOnlineInfoText(client, isMobile, accountInfo.rafLinkType, presenceText)
				if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
					infoText = getOnlineInfoText(client, isMobile, accountInfo.rafLinkType, zoneName ~= "" and zoneName or presenceText)
				end

				-- REASON: Use a temporary client tag 'WoV' for non-Retail WoW for sorting priority.
				if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then
					client = "WoV"
				end

				table_insert(bnetTable, { i, accountInfo.accountName, charName, factionName, client, status, class, level, infoText, accountInfo.note, accountInfo.customMessage, accountInfo.customMessageTime })
			end
		end
	end
	table_sort(bnetTable, sortBNFriends)
end

local function rebuildTablesIfDirty()
	-- REASON: Lazy rebuild of local caches only when the 'dirty' flag is set via events.
	if not isFriendsDirty then
		return
	end

	local numWoW = Module.numFriends or 0
	local numBN = Module.numBNet or 0

	if numWoW > 0 then
		buildFriendTable(numWoW)
	else
		table_wipe(friendTable)
	end
	if numBN > 0 then
		buildBNetTable(numBN)
	else
		table_wipe(bnetTable)
	end

	isFriendsDirty = false
end

-- ---------------------------------------------------------------------------
-- Panel Auto-Hide Logic
-- ---------------------------------------------------------------------------
local function isPanelCanHide(self, elapsed)
	-- REASON: Facilitates a clean fade-out of the custom info panel when the mouse leaves both the DT and the panel itself.
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 0.2 then
		local over = false
		if friendsDataText and MouseIsOver(friendsDataText) then
			over = true
		elseif infoFrame and MouseIsOver(infoFrame) then
			over = true
		elseif infoFrame and infoFrame.scrollFrame and infoFrame.scrollFrame.buttons then
			for i = 1, #infoFrame.scrollFrame.buttons do
				local btn = infoFrame.scrollFrame.buttons[i]
				if btn and btn:IsShown() and MouseIsOver(btn) then
					over = true
					break
				end
			end
		end

		if not over then
			GameTooltip:Hide()
			if infoFrame then
				infoFrame:Hide()
				infoFrame:SetScript("OnUpdate", nil)
			end
			if friendsDataText then
				friendsDataText:SetScript("OnUpdate", nil)
			end
			self:SetScript("OnUpdate", nil)
		end
		self.timer = 0
	end
end

-- ---------------------------------------------------------------------------
-- Scroll Frame Management
-- ---------------------------------------------------------------------------
local function friendsPanel_Resize(rowCount)
	-- REASON: Dynamically adjusts the height of the hybrid scroll frame based on the number of online friends.
	if not infoFrame or not infoFrame.scrollFrame then
		return
	end

	rowCount = rowCount or 0
	local visibleRows = math_min(rowCount, MAX_VISIBLE_ROWS)
	local scrollHeight = math_max(visibleRows * BUTTON_HEIGHT, BUTTON_HEIGHT)

	infoFrame.scrollFrame:SetHeight(scrollHeight)
	infoFrame:SetHeight(BASE_EXTRA_HEIGHT + scrollHeight)

	local scrollBar = infoFrame.scrollFrame.scrollBar
	local maxScroll = math_max(0, (rowCount - MAX_VISIBLE_ROWS) * BUTTON_HEIGHT)

	if maxScroll > 0 then
		scrollBar:Show()
		scrollBar:SetMinMaxValues(0, maxScroll)
	else
		scrollBar:Hide()
		scrollBar:SetMinMaxValues(0, 0)
	end

	local curScroll = scrollBar:GetValue() or 0
	if curScroll < 0 then
		scrollBar:SetValue(0)
	elseif curScroll > maxScroll then
		scrollBar:SetValue(maxScroll)
	end

	infoFrame.scrollFrame.scrollChild:SetSize(infoFrame.scrollFrame:GetWidth(), math_max(rowCount, 1) * BUTTON_HEIGHT)
	infoFrame.scrollFrame:UpdateScrollChildRect()
end

local function friendsPanel_UpdateButton(button, currentZone)
	-- REASON: Hydrates an individual scroll list button with relevant friend data.
	local index = button.index
	local onlineFriendsWoW = Module.onlineFriends or 0

	if index <= onlineFriendsWoW then
		local entry = friendTable[index]
		if not entry then
			return
		end

		local name, level, class, area, status = unpack(entry)
		button.status:SetTexture(status)

		local zoneColor = (currentZone == area) and activeZoneColor or inactiveColor
		local levelDifficulty = GetQuestDifficultyColor(level)
		local levelColor = K.RGBToHex(levelDifficulty.r, levelDifficulty.g, levelDifficulty.b)
		local classColor = K.ClassColors[class] or levelDifficulty

		button.name:SetText(string_format("%s%s|r %s%s", levelColor, level, K.RGBToHex(classColor.r, classColor.g, classColor.b), name))
		button.zone:SetText(string_format("%s%s", zoneColor, area or _G.UNKNOWN))

		C_Texture_SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, _G.Enum.TitleIconVersion.Medium)
		button.isBNet = nil
		button.data = entry
	else
		local bnetIndex = index - onlineFriendsWoW
		local entry = bnetTable[bnetIndex]
		if not entry then
			return
		end

		local _, accountName, charName, factionName, client, status, class, _, infoText = unpack(entry)
		button.status:SetTexture(status)

		local coloredChar = inactiveColor .. (charName or _G.UNKNOWN)
		local zoneColor = inactiveColor

		if client == BNET_CLIENT_WOW then
			local color = K.ClassColors[class] or GetQuestDifficultyColor(1)
			coloredChar = K.RGBToHex(color.r, color.g, color.b) .. (charName or _G.UNKNOWN)
			zoneColor = (currentZone == infoText) and activeZoneColor or inactiveColor
		end

		button.name:SetText(string_format("%s%s|r (%s|r)", K.InfoColor, accountName or _G.UNKNOWN, coloredChar))
		button.zone:SetText(string_format("%s%s", zoneColor, infoText or _G.UNKNOWN))

		if client == "WoV" then
			C_Texture_SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, _G.Enum.TitleIconVersion.Medium)
		elseif client == BNET_CLIENT_WOW then
			if factionName == "Horde" or factionName == "Alliance" then
				button.gameIcon:SetTexture("Interface\\FriendsFrame\\PlusManz-" .. factionName)
			else
				C_Texture_SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, _G.Enum.TitleIconVersion.Medium)
			end
		else
			C_Texture_SetTitleIconTexture(button.gameIcon, client, _G.Enum.TitleIconVersion.Medium)
		end

		button.isBNet = true
		button.data = entry
	end
end

local function friendsPanel_Update()
	-- REASON: Triggers the rendering logic for the hybrid scroll frame's visible portion.
	local scrollFrame = infoFrame and infoFrame.scrollFrame
	if not scrollFrame then
		return
	end

	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numTotalOnline = Module.totalOnline or 0
	local scrollOffset = HybridScrollFrame_GetOffset(scrollFrame)
	local currentZone = GetRealZoneText()

	for i = 1, #buttons do
		local btn = buttons[i]
		local idx = scrollOffset + i
		if idx <= numTotalOnline then
			btn.index = idx
			friendsPanel_UpdateButton(btn, currentZone)
			usedHeight = usedHeight + height
			btn:Show()
		else
			btn.index = nil
			btn:Hide()
		end
	end
	HybridScrollFrame_Update(scrollFrame, numTotalOnline * height, usedHeight)
end

local function friendsPanel_OnMouseWheel(self, delta)
	local scrollBar = self.scrollBar
	local step = delta * self.buttonHeight
	if IsShiftKeyDown() then
		step = step * 19
	end

	scrollBar:SetValue(scrollBar:GetValue() - step)
	friendsPanel_Update()
end

-- ---------------------------------------------------------------------------
-- Interaction Handlers
-- ---------------------------------------------------------------------------
local function inviteFunc(_, bnetIDGameAccount, guid)
	FriendsFrame_InviteOrRequestToJoin(guid, bnetIDGameAccount)
end

local inviteTypeToButtonText = {
	["INVITE"] = _G.TRAVEL_PASS_INVITE,
	["SUGGEST_INVITE"] = _G.SUGGEST_INVITE,
	["REQUEST_INVITE"] = _G.REQUEST_INVITE,
	["INVITE_CROSS_FACTION"] = _G.TRAVEL_PASS_INVITE_CROSS_FACTION,
	["SUGGEST_INVITE_CROSS_FACTION"] = _G.SUGGEST_INVITE_CROSS_FACTION,
	["REQUEST_INVITE_CROSS_FACTION"] = _G.REQUEST_INVITE_CROSS_FACTION,
}

local function getInviteText(guid, factionName)
	local inviteType = guid and GetDisplayedInviteType(guid)
	if not inviteType then
		return ""
	end

	if factionName and factionName ~= K.Faction then
		inviteType = inviteType .. "_CROSS_FACTION"
	end
	return inviteTypeToButtonText[inviteType] or ""
end

local function buttonOnClick(self, button)
	-- REASON: Handles Left-click (Group invite/Shift-insert name) and Right-click (Whisper) for friends list entries.
	local data = self.data
	if not data then
		return
	end

	if button == "LeftButton" then
		if IsAltKeyDown() then
			if self.isBNet then
				-- REASON: For Battle.net friends, build a submenu if they have multiple viable game accounts.
				local mIndex = 2
				if #menuList > 1 then
					for i = 2, #menuList do
						table_wipe(menuList[i])
					end
				end

				menuList[1].text = K.InfoColor .. (data[2] or _G.UNKNOWN)
				local numAccounts = C_BattleNet_GetFriendNumGameAccounts(data[1])
				if numAccounts and numAccounts > 0 then
					for i = 1, numAccounts do
						local info = C_BattleNet_GetFriendGameAccountInfo(data[1], i)
						if info and info.clientProgram == BNET_CLIENT_WOW and info.wowProjectID == WOW_PROJECT_ID and info.playerGuid then
							menuList[mIndex] = menuList[mIndex] or {}
							local entry = menuList[mIndex]
							local color = K.ColorClass(K.ClassList[info.className] or info.className)
							entry.text = string_format("%s%s|r %s", K.RGBToHex(color.r, color.g, color.b), info.characterName or _G.UNKNOWN, getInviteText(info.playerGuid, info.factionName))
							entry.notCheckable = true
							entry.arg1 = info.gameAccountID
							entry.arg2 = info.playerGuid
							entry.func = inviteFunc
							mIndex = mIndex + 1
						end
					end
				end

				if mIndex > 2 then
					_G.K.LibEasyMenu.Create(menuList, _G.K.EasyMenu, self, 0, 0, "MENU", 1)
				end
			else
				C_PartyInfo_InviteUnit(data[1])
			end
		elseif IsShiftKeyDown() then
			local targetName = self.isBNet and data[3] or data[1]
			if targetName then
				if _G.MailFrame and _G.MailFrame:IsShown() then
					MailFrameTab_OnClick(nil, 2)
					_G.SendMailNameEditBox:SetText(targetName)
					_G.SendMailNameEditBox:HighlightText()
				else
					local eb = ChatEdit_ChooseBoxForSend()
					local hasInitialText = eb:GetText() ~= ""
					ChatEdit_ActivateChat(eb)
					eb:Insert(targetName)
					if not hasInitialText then
						eb:HighlightText()
					end
				end
			end
		end
	else
		if self.isBNet then
			ChatFrame_SendBNetTell(data[2])
		else
			ChatFrame_SendTell(data[1], _G.SELECTED_DOCK_FRAME)
		end
	end
end

local function buttonOnEnter(self)
	-- REASON: Displays a secondary tooltip containing detailed character and game account information for the hovered friend.
	local data = self.data
	if not data then
		return
	end

	GameTooltip:SetOwner(friendsDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", infoFrame, "TOPRIGHT", 5, 0)
	GameTooltip:ClearLines()

	if self.isBNet then
		GameTooltip:AddLine(L["BN"], 0.4, 0.6, 1)
		GameTooltip:AddLine(" ")

		local qIndex, accountName, _, _, _, _, _, _, _, note, bCastText, bCastTime = unpack(data)
		local numAcc = C_BattleNet_GetFriendNumGameAccounts(qIndex) or 0

		for i = 1, numAcc do
			local info = C_BattleNet_GetFriendGameAccountInfo(qIndex, i)
			if info then
				local charName = info.characterName or ""
				local client = info.clientProgram
				if client == BNET_CLIENT_WOW then
					if charName ~= "" then
						if info.timerunningSeasonID and _G.TimerunningUtil and _G.TimerunningUtil.AddSmallIcon then
							charName = _G.TimerunningUtil.AddSmallIcon(charName)
						end

						local rName = (K.Realm == info.realmName or info.realmName == "") and "" or "-" .. info.realmName
						if info.wowProjectID == WOW_PROJECT_CATA then
							local r, count = string_gsub(info.richPresence or "", "^.-%-%s", "")
							if count and count > 0 then
								rName = "-" .. r
							end
						end

						local color = K.ColorClass(K.ClassList[info.className] or info.className)
						local classHex = K.RGBToHex(color.r, color.g, color.b)
						local factionIconString = (info.factionName == "Horde" or info.factionName == "Alliance") and ("|TInterface\\FriendsFrame\\PlusManz-" .. info.factionName .. ":16:|t") or ""

						GameTooltip:AddLine(string_format("%s%s %s%s%s", factionIconString, info.characterLevel or 0, classHex, charName, rName))
						local areaLabel = info.areaName or _G.UNKNOWN
						if info.wowProjectID ~= WOW_PROJECT_ID then
							areaLabel = "*" .. areaLabel
						end
						GameTooltip:AddLine(string_format("%s%s", inactiveColor, areaLabel))
					end
				else
					GameTooltip:AddLine(string_format("|cffffffff%s%s", getClientLogo(client, 16), accountName or _G.UNKNOWN))
					if info.richPresence ~= "" then
						GameTooltip:AddLine(string_format("%s%s", inactiveColor, info.richPresence or ""))
					end
				end
			end
		end

		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string_format(noteIconString, note), 1, 0.8, 0)
		end
		if bCastText and bCastText ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string_format(broadcastIconString, bCastText, FriendsFrame_GetLastOnline(bCastTime)), 0.3, 0.5, 0.7, 1)
		end
	else
		GameTooltip:AddLine(L["WoW"], 1, 0.8, 0)
		GameTooltip:AddLine(" ")
		local name, level, class, area, _, note = unpack(data)
		local color = K.ColorClass(class)
		GameTooltip:AddLine(string_format("%s %s%s", level, K.RGBToHex(color.r, color.g, color.b), name))
		GameTooltip:AddLine(string_format("%s%s", inactiveColor, area))
		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string_format(noteIconString, note), 1, 0.8, 0)
		end
	end
	GameTooltip:Show()
end

-- ---------------------------------------------------------------------------
-- Panel Housekeeping
-- ---------------------------------------------------------------------------
local function friendsPanel_CreateButton(parent, index)
	-- REASON: Helper for scroll frame initialization; creates and anchors the reusable friend entry buttons.
	local btn = CreateFrame("Button", nil, parent)
	btn:SetSize(370, 20)
	btn:SetPoint("TOPLEFT", 0, -(index - 1) * 22)

	btn.HL = btn:CreateTexture(nil, "HIGHLIGHT")
	btn.HL:SetAllPoints()
	btn.HL:SetColorTexture(K.r, K.g, K.b, 0.2)

	btn.status = btn:CreateTexture(nil, "ARTWORK")
	btn.status:SetPoint("LEFT", btn, 5, 0)
	btn.status:SetSize(16, 16)

	btn.name = K.CreateFontString(btn, 12, "Tag (name)", "", false, "LEFT", 25, 0)
	btn.name:SetPoint("RIGHT", btn, "LEFT", 230, 0)
	btn.name:SetJustifyH("LEFT")
	btn.name:SetTextColor(0.5, 0.7, 1)

	btn.zone = K.CreateFontString(btn, 12, "Zone", "", false, "RIGHT", -28, 0)
	btn.zone:SetPoint("LEFT", btn, "RIGHT", -130, 0)
	btn.zone:SetJustifyH("RIGHT")

	btn.gameIcon = btn:CreateTexture(nil, "ARTWORK")
	btn.gameIcon:SetPoint("RIGHT", btn, -8, 0)
	btn.gameIcon:SetSize(16, 16)

	btn.gameIcon.border = CreateFrame("Frame", nil, btn)
	btn.gameIcon.border:SetFrameLevel(btn:GetFrameLevel())
	btn.gameIcon.border:SetAllPoints(btn.gameIcon)
	btn.gameIcon.border:CreateBorder()

	btn:RegisterForClicks("AnyUp")
	btn:SetScript("OnClick", buttonOnClick)
	btn:SetScript("OnEnter", buttonOnEnter)
	btn:SetScript("OnLeave", K.HideTooltip)

	return btn
end

local function friendsPanel_Init(rowCount)
	-- REASON: Constructive logic for the main info panel; only runs once to establish the UI structure.
	rowCount = rowCount or (Module.totalOnline or 0)
	if infoFrame then
		infoFrame:Show()
		friendsPanel_Resize(rowCount)
		return
	end

	infoFrame = CreateFrame("Frame", "KKUI_FriendsInfoFrame", friendsDataText)
	infoFrame:SetSize(400, 495)
	infoFrame:SetPoint(K.GetAnchors(friendsDataText))
	infoFrame:SetClampedToScreen(true)
	infoFrame:SetFrameStrata("DIALOG")
	infoFrame:CreateBorder()

	infoFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", isPanelCanHide)
	end)
	infoFrame:SetScript("OnShow", function(self)
		self:SetScript("OnUpdate", isPanelCanHide)
	end)
	infoFrame:SetScript("OnHide", function(self)
		GameTooltip:Hide()
		self:SetScript("OnUpdate", nil)
		if friendsDataText then
			friendsDataText:SetScript("OnUpdate", nil)
		end
	end)

	K.CreateFontString(infoFrame, 14, "|cff0099ff" .. _G.FRIENDS_LIST, "", nil, "TOPLEFT", 15, -10)
	infoFrame.friendCountText = K.CreateFontString(infoFrame, 13, "-/-", "", nil, "TOPRIGHT", -15, -12)
	infoFrame.friendCountText:SetTextColor(0, 0.6, 1)

	local scrollFrame = CreateFrame("ScrollFrame", "KKUI_FriendsDataTextScrollFrame", infoFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(370, MAX_VISIBLE_ROWS * BUTTON_HEIGHT)
	scrollFrame:SetPoint("TOPLEFT", 7, -35)
	infoFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = false
	scrollBar:SkinScrollBar()
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = MAX_VISIBLE_ROWS + 1
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = friendsPanel_CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = BUTTON_HEIGHT
	scrollFrame.update = friendsPanel_Update
	scrollFrame:SetScript("OnMouseWheel", friendsPanel_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * BUTTON_HEIGHT)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, 0)
	scrollBar:SetValue(0)

	K.CreateFontString(infoFrame, 12, Module.LineString, "", false, "BOTTOMRIGHT", -12, 42)
	K.CreateFontString(infoFrame, 12, K.InfoColor .. K.RightButton .. L["Whisper"], "", false, "BOTTOMRIGHT", -15, 26)
	K.CreateFontString(infoFrame, 12, K.InfoColor .. "ALT +" .. K.LeftButton .. L["Invite"], "", false, "BOTTOMRIGHT", -15, 10)

	friendsPanel_Resize(rowCount)
end

local function friendsPanel_RefreshDataCounts()
	-- REASON: Polls the game engine for basic friend counts and stores them in the module namespace for cross-reference.
	local numWoW = C_FriendList_GetNumFriends() or 0
	local onlineWoW = C_FriendList_GetNumOnlineFriends() or 0
	local numBN, onlineBN = BNGetNumFriends()
	numBN, onlineBN = numBN or 0, onlineBN or 0

	Module.numFriends = numWoW
	Module.onlineFriends = onlineWoW
	Module.numBNet = numBN
	Module.onlineBNet = onlineBN
	Module.totalOnline = onlineWoW + onlineBN
	Module.totalFriends = numWoW + numBN

	if infoFrame and infoFrame:IsShown() and infoFrame.scrollFrame then
		friendsPanel_Resize(Module.totalOnline)
	end
end

local function friendsPanel_FullUpdate()
	-- REASON: Complete state sync: refreshes counts, rebuilds caches, and updates the visible UI panel.
	friendsPanel_RefreshDataCounts()
	rebuildTablesIfDirty()

	if infoFrame and infoFrame:IsShown() then
		friendsPanel_Resize(Module.totalOnline or 0)
		friendsPanel_Update()
		if infoFrame.friendCountText then
			infoFrame.friendCountText:SetText(string_format("%s: %s/%s", _G.GUILD_ONLINE_LABEL, Module.totalOnline or 0, Module.totalFriends or 0))
		end
	end
end

-- ---------------------------------------------------------------------------
-- Base Module Hooks
-- ---------------------------------------------------------------------------
local function onEnter()
	-- REASON: Logic for the DataText hover; either shows a simple empty-state tooltip or initializes the full friend list panel.
	local thisTime = GetTime()
	local isOpeningNow = (not infoFrame) or (not infoFrame:IsShown())

	if isOpeningNow or isFriendsDirty or not prevUpdateTime or (thisTime - prevUpdateTime > 5) then
		friendsPanel_RefreshDataCounts()
		prevUpdateTime = thisTime
	end

	local onlineCount = Module.totalOnline or 0
	local totalCount = Module.totalFriends or 0

	if onlineCount == 0 then
		GameTooltip:SetOwner(friendsDataText, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(friendsDataText))
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(_G.FRIENDS_LIST, string_format("%s: %s/%s", _G.GUILD_ONLINE_LABEL, onlineCount, totalCount), 0.4, 0.6, 1, 0.4, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Guess it's time to talk to the voices in my head.", 1, 1, 1)
		GameTooltip:Show()
		return
	end

	rebuildTablesIfDirty()
	friendsPanel_Init(onlineCount)
	friendsPanel_Update()
	if infoFrame and infoFrame.friendCountText then
		infoFrame.friendCountText:SetText(string_format("%s: %s/%s", _G.GUILD_ONLINE_LABEL, onlineCount, totalCount))
	end
end

local function onEvent(_, event, arg1)
	if event == "CHAT_MSG_SYSTEM" then
		local msg = arg1 or ""
		if not string_find(msg, onlineMsgPattern) and not string_find(msg, offlineMsgPattern) then
			return
		end
	end

	isFriendsDirty = true
	friendsPanel_RefreshDataCounts()

	if C["DataText"].HideText then
		friendsDataText.Text:SetText("")
	else
		friendsDataText.Text:SetText(string_format("%s: " .. K.MyClassColor .. "%d", _G.FRIENDS, Module.totalOnline or 0))
	end

	-- REASON: Dynamically resize the DataText frame and mover to fit the changing friend count text.
	local textW = friendsDataText.Text:GetStringWidth() or 0
	local iconW = (friendsDataText.Texture and friendsDataText.Texture:GetWidth()) or 0
	local newW = math_max(textW + iconW, MIN_DT_WIDTH)
	local newH = math_max(friendsDataText.Text:GetLineHeight() or 12, (friendsDataText.Texture and friendsDataText.Texture:GetHeight()) or 12)

	if newW ~= lastDTW or newH ~= lastDTH then
		lastDTW, lastDTH = newW, newH
		friendsDataText:SetSize(newW, newH)
		if friendsDataText.mover then
			friendsDataText.mover:SetSize(newW, newH)
		end
	end

	if infoFrame and infoFrame:IsShown() then
		if not isUpdateQueued then
			isUpdateQueued = true
			K.Delay(0.05, function()
				isUpdateQueued = false
				if infoFrame and infoFrame:IsShown() then
					friendsPanel_FullUpdate()
				end
			end)
		end
	end
end

local function onLeave()
	GameTooltip:Hide()
	if not infoFrame then
		return
	end
	if friendsDataText then
		friendsDataText:SetScript("OnUpdate", isPanelCanHide)
	end
	infoFrame:SetScript("OnUpdate", isPanelCanHide)
end

local function onMouseUp(_, btn)
	-- REASON: Left-click toggles the default Blizzard friends frame.
	if btn ~= "LeftButton" then
		return
	end
	if infoFrame then
		infoFrame:Hide()
	end
	ToggleFriendsFrame()
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateSocialDataText()
	-- REASON: Entry point for the Social/Friends DataText; sets up textures, fonts, and event registration.
	if not C["DataText"].Friends then
		return
	end

	friendsDataText = CreateFrame("Frame", nil, UIParent)

	friendsDataText.Text = K.CreateFontString(friendsDataText, 12)
	friendsDataText.Text:ClearAllPoints()
	friendsDataText.Text:SetPoint("LEFT", friendsDataText, "LEFT", 24, 0)

	friendsDataText.Texture = friendsDataText:CreateTexture(nil, "ARTWORK")
	friendsDataText.Texture:SetPoint("LEFT", friendsDataText, "LEFT", 0, 2)
	friendsDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\FriendsIcon")
	friendsDataText.Texture:SetSize(24, 24)
	friendsDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	local events = {
		"BN_FRIEND_ACCOUNT_OFFLINE",
		"BN_FRIEND_ACCOUNT_ONLINE",
		"BN_FRIEND_INFO_CHANGED",
		"CHAT_MSG_SYSTEM",
		"FRIENDLIST_UPDATE",
		"PLAYER_ENTERING_WORLD",
	}

	for _, eventName in ipairs(events) do
		friendsDataText:RegisterEvent(eventName)
	end

	friendsDataText:SetScript("OnEvent", onEvent)
	friendsDataText:SetScript("OnEnter", onEnter)
	friendsDataText:SetScript("OnLeave", onLeave)
	friendsDataText:SetScript("OnMouseUp", onMouseUp)

	friendsDataText.mover = K.Mover(friendsDataText, "FriendsDT", "FriendsDT", { "LEFT", UIParent, "LEFT", 0, -270 }, MIN_DT_WIDTH, 12)
end
