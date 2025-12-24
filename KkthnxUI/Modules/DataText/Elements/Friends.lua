local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- Lua
local gsub = string.gsub
local string_find = string.find
local string_format = string.format
local math_min = math.min
local math_max = math.max
local table_insert = table.insert
local table_sort = table.sort
local table_wipe = table.wipe
local unpack = unpack
local pairs = pairs

-- WoW API
local BNGetNumFriends = BNGetNumFriends
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local FriendsFrame_GetFormattedCharacterName = FriendsFrame_GetFormattedCharacterName
local FriendsFrame_GetLastOnline = FriendsFrame_GetLastOnline
local FriendsFrame_InviteOrRequestToJoin = _G.FriendsFrame_InviteOrRequestToJoin
local GameTooltip = GameTooltip
local GetDisplayedInviteType = GetDisplayedInviteType
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local GetTime = GetTime
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_Update = HybridScrollFrame_Update
local InviteToGroup = C_PartyInfo.InviteUnit
local IsAltKeyDown = IsAltKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local MouseIsOver = MouseIsOver
local ToggleFriendsFrame = ToggleFriendsFrame

-- UI / Frames
local CreateFrame = CreateFrame
local UIParent = UIParent
local MailFrame = MailFrame
local MailFrameTab_OnClick = MailFrameTab_OnClick
local SendMailNameEditBox = SendMailNameEditBox
local ChatEdit_ActivateChat = ChatEdit_ActivateChat
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatFrame_SendBNetTell = ChatFrame_SendBNetTell
local ChatFrame_SendTell = ChatFrame_SendTell
local SELECTED_DOCK_FRAME = SELECTED_DOCK_FRAME

-- Textures / Atlases
local BNet_GetClientAtlas = BNet_GetClientAtlas
local CreateAtlasMarkup = CreateAtlasMarkup
local C_Texture_SetTitleIconTexture = C_Texture.SetTitleIconTexture

-- Globals / Strings / Constants
local ERR_FRIEND_ONLINE_SS = ERR_FRIEND_ONLINE_SS
local ERR_FRIEND_OFFLINE_S = ERR_FRIEND_OFFLINE_S
local EXPANSION_NAME0 = EXPANSION_NAME0
local EXPANSION_NAME3 = EXPANSION_NAME3
local FRIENDS = FRIENDS
local FRIENDS_LIST = FRIENDS_LIST
local FRIENDS_TEXTURE_AFK = FRIENDS_TEXTURE_AFK
local FRIENDS_TEXTURE_DND = FRIENDS_TEXTURE_DND
local FRIENDS_TEXTURE_ONLINE = FRIENDS_TEXTURE_ONLINE
local GUILD_ONLINE_LABEL = GUILD_ONLINE_LABEL
local REQUEST_INVITE = REQUEST_INVITE
local REQUEST_INVITE_CROSS_FACTION = REQUEST_INVITE_CROSS_FACTION
local SUGGEST_INVITE = SUGGEST_INVITE
local SUGGEST_INVITE_CROSS_FACTION = SUGGEST_INVITE_CROSS_FACTION
local TRAVEL_PASS_INVITE = TRAVEL_PASS_INVITE
local TRAVEL_PASS_INVITE_CROSS_FACTION = TRAVEL_PASS_INVITE_CROSS_FACTION
local RAF_RECRUITER_FRIEND = RAF_RECRUITER_FRIEND
local RAF_RECRUIT_FRIEND = RAF_RECRUIT_FRIEND
local UNKNOWN = UNKNOWN

-- Projects
local WOW_PROJECT_CATA = WOW_PROJECT_CATACLYSM_CLASSIC or 14
local WOW_PROJECT_60 = WOW_PROJECT_CLASSIC or 2
local WOW_PROJECT_ID = WOW_PROJECT_ID or 1
local CLIENT_WOW_DIFF = "WoV" -- for sorting
local BNET_CLIENT_WOW = BNET_CLIENT_WOW

local r, g, b = K.r, K.g, K.b
local infoFrame
local updateRequest
local prevTime
local updateQueued

local BUTTON_HEIGHT = 22
local MAX_VISIBLE_ROWS = 20
local BASE_EXTRA_HEIGHT = 95 -- header + footer padding based on current layout

local friendTable = {}
local bnetTable = {}

local activeZone = "|cff4cff4c"
local inactiveZone = K.GreyColor
local noteString = "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:16|t %s"
local broadcastString = "|TInterface\\FriendsFrame\\BroadcastIcon:12|t %s (%s)"

local onlineString = gsub(ERR_FRIEND_ONLINE_SS, ".+h", "")
local offlineString = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")

local FriendsDataText

-- BNet_GetClientEmbeddedAtlas returns incorrect texture for some clients
local function GetClientLogo(client, size)
	size = size or 0
	local atlas = BNet_GetClientAtlas("Battlenet-ClientIcon-", client)
	return CreateAtlasMarkup(atlas, size, size, 0, 0)
end

local menuList = {
	[1] = {
		text = L["Join or Invite"],
		isTitle = true,
		notCheckable = true,
	},
}

local function sortFriends(a, b)
	-- Always return a boolean for table.sort
	return (a and a[1] or "") < (b and b[1] or "")
end

local function buildFriendTable(num)
	table_wipe(friendTable)

	for i = 1, num do
		local info = C_FriendList_GetFriendInfoByIndex(i)
		if info and info.connected then
			local status = FRIENDS_TEXTURE_ONLINE
			if info.afk then
				status = FRIENDS_TEXTURE_AFK
			elseif info.dnd then
				status = FRIENDS_TEXTURE_DND
			end

			local class = K.ClassList[info.className] or info.className
			table_insert(friendTable, { info.name, info.level, class, info.area or UNKNOWN, status, info.notes })
		end
	end

	table_sort(friendTable, sortFriends)
end

local function sortBNFriends(a, b)
	-- Sort by client first, then by faction (Alliance prefers A->Z, Horde prefers Z->A)
	if K.Faction == "Alliance" then
		return a[5] == b[5] and a[4] < b[4] or a[5] > b[5]
	else
		return a[5] == b[5] and a[4] > b[4] or a[5] > b[5]
	end
end

local function GetOnlineInfoText(client, isMobile, rafLinkType, locationText)
	if not locationText or locationText == "" then
		return UNKNOWN
	end

	if isMobile then
		return "APP"
	end

	if (client == BNET_CLIENT_WOW) and (rafLinkType ~= Enum.RafLinkType.None) then
		if rafLinkType == Enum.RafLinkType.Recruit then
			return string_format(RAF_RECRUIT_FRIEND, locationText)
		else
			return string_format(RAF_RECRUITER_FRIEND, locationText)
		end
	end

	return locationText
end

local function buildBNetTable(num)
	table_wipe(bnetTable)

	for i = 1, num do
		local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
		if accountInfo then
			local accountName = accountInfo.accountName
			local battleTag = accountInfo.battleTag
			local broadcastText = accountInfo.customMessage
			local broadcastTime = accountInfo.customMessageTime

			local gameAccountInfo = accountInfo.gameAccountInfo
			local isOnline = gameAccountInfo and gameAccountInfo.isOnline
			local gameID = gameAccountInfo and gameAccountInfo.gameAccountID

			if isOnline and gameID then
				local charName = gameAccountInfo.characterName or ""
				local className = gameAccountInfo.className or UNKNOWN
				local client = gameAccountInfo.clientProgram
				local factionName = gameAccountInfo.factionName or UNKNOWN
				local gameText = gameAccountInfo.richPresence or ""
				local isGameAFK = gameAccountInfo.isGameAFK
				local isGameBusy = gameAccountInfo.isGameBusy
				local isMobile = gameAccountInfo.isWowMobile
				local level = gameAccountInfo.characterLevel
				local timerunningSeasonID = gameAccountInfo.timerunningSeasonID
				local wowProjectID = gameAccountInfo.wowProjectID
				local zoneName = gameAccountInfo.areaName or UNKNOWN

				charName = FriendsFrame_GetFormattedCharacterName(charName, battleTag, client, timerunningSeasonID)
				local class = K.ClassList[className] or className

				local status = FRIENDS_TEXTURE_ONLINE
				if accountInfo.isAFK or isGameAFK then
					status = FRIENDS_TEXTURE_AFK
				elseif accountInfo.isDND or isGameBusy then
					status = FRIENDS_TEXTURE_DND
				end

				-- Label non-retail WoW projects for sorting/display
				if wowProjectID == WOW_PROJECT_60 then
					gameText = EXPANSION_NAME0
				elseif wowProjectID == WOW_PROJECT_CATA then
					gameText = EXPANSION_NAME3
				end

				local rafLinkType = accountInfo.rafLinkType
				local infoText = GetOnlineInfoText(client, isMobile, rafLinkType, gameText)

				-- Retail WoW: show zone instead of richPresence when available
				if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
					infoText = GetOnlineInfoText(client, isMobile, rafLinkType, zoneName ~= "" and zoneName or gameText)
				end

				-- Differentiate non-retail WoW clients during sorting
				if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then
					client = CLIENT_WOW_DIFF
				end

				table_insert(bnetTable, { i, accountName, charName, factionName, client, status, class, level, infoText, accountInfo.note, broadcastText, broadcastTime })
			end
		end
	end

	table_sort(bnetTable, sortBNFriends)
end

local function isPanelCanHide(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 0.2 then
		local over = false
		if FriendsDataText and MouseIsOver(FriendsDataText) then
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
			if FriendsDataText then
				FriendsDataText:SetScript("OnUpdate", nil)
			end
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function FriendsPanel_Resize(rowCount)
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
		scrollBar:SetValue(0)
		scrollBar:SetMinMaxValues(0, 0)
	end

	-- Make scrollChild tall enough for HybridScrollFrame math
	infoFrame.scrollFrame.scrollChild:SetSize(infoFrame.scrollFrame:GetWidth(), math_max(rowCount, 1) * BUTTON_HEIGHT)
	infoFrame.scrollFrame:UpdateScrollChildRect()
end

local function FriendsPanel_UpdateButton(button)
	local index = button.index
	local onlineFriends = Module.onlineFriends or 0
	local currentZone = GetRealZoneText()

	if index <= onlineFriends then
		local entry = friendTable[index]
		if not entry then
			return
		end

		local name, level, class, area, status = unpack(entry)
		button.status:SetTexture(status)

		local zoneColor = (currentZone == area) and activeZone or inactiveZone
		local levelColor = K.RGBToHex(GetQuestDifficultyColor(level))
		local classColor = K.ClassColors[class] or levelColor

		button.name:SetText(string_format("%s%s|r %s%s", levelColor, level, K.RGBToHex(classColor), name))
		button.zone:SetText(string_format("%s%s", zoneColor, area or UNKNOWN))

		C_Texture_SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)

		button.isBNet = nil
		button.data = entry
	else
		local bnetIndex = index - onlineFriends
		local entry = bnetTable[bnetIndex]
		if not entry then
			return
		end

		local _, accountName, charName, factionName, client, status, class, _, infoText = unpack(entry)
		button.status:SetTexture(status)

		local zoneColor = inactiveZone
		local coloredChar = inactiveZone .. (charName or UNKNOWN)

		if client == BNET_CLIENT_WOW then
			local color = K.ClassColors[class] or GetQuestDifficultyColor(1)
			coloredChar = K.RGBToHex(color) .. (charName or UNKNOWN)
			zoneColor = (currentZone == infoText) and activeZone or inactiveZone
		end

		button.name:SetText(string_format("%s%s|r (%s|r)", K.InfoColor, accountName or UNKNOWN, coloredChar))
		button.zone:SetText(string_format("%s%s", zoneColor, infoText or UNKNOWN))

		if client == CLIENT_WOW_DIFF then
			C_Texture_SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)
		elseif client == BNET_CLIENT_WOW then
			if factionName == "Horde" or factionName == "Alliance" then
				button.gameIcon:SetTexture("Interface\\FriendsFrame\\PlusManz-" .. factionName)
			else
				C_Texture_SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)
			end
		else
			C_Texture_SetTitleIconTexture(button.gameIcon, client, Enum.TitleIconVersion.Medium)
		end

		button.isBNet = true
		button.data = entry
	end
end

local function FriendsPanel_Update()
	local scrollFrame = infoFrame and infoFrame.scrollFrame
	if not scrollFrame then
		return
	end

	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numFriendButtons = Module.totalOnline or 0
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local idx = offset + i
		if idx <= numFriendButtons then
			button.index = idx
			FriendsPanel_UpdateButton(button)
			usedHeight = usedHeight + height
			button:Show()
		else
			button.index = nil
			button:Hide()
		end
	end

	HybridScrollFrame_Update(scrollFrame, numFriendButtons * height, usedHeight)
end

local function FriendsPanel_OnMouseWheel(self, delta)
	local scrollBar = self.scrollBar
	local step = delta * self.buttonHeight
	if IsShiftKeyDown() then
		step = step * 19
	end

	scrollBar:SetValue(scrollBar:GetValue() - step)
	FriendsPanel_Update()
end

local function inviteFunc(_, bnetIDGameAccount, guid)
	FriendsFrame_InviteOrRequestToJoin(guid, bnetIDGameAccount)
end

local inviteTypeToButtonText = {
	["INVITE"] = TRAVEL_PASS_INVITE,
	["SUGGEST_INVITE"] = SUGGEST_INVITE,
	["REQUEST_INVITE"] = REQUEST_INVITE,
	["INVITE_CROSS_FACTION"] = TRAVEL_PASS_INVITE_CROSS_FACTION,
	["SUGGEST_INVITE_CROSS_FACTION"] = SUGGEST_INVITE_CROSS_FACTION,
	["REQUEST_INVITE_CROSS_FACTION"] = REQUEST_INVITE_CROSS_FACTION,
}

local function GetButtonTexFromInviteType(guid, factionName)
	local inviteType = guid and GetDisplayedInviteType(guid)
	if not inviteType then
		return ""
	end

	if factionName and factionName ~= K.Faction then
		inviteType = inviteType .. "_CROSS_FACTION"
	end

	return inviteTypeToButtonText[inviteType] or ""
end

local function GetNameAndInviteType(className, charName, guid, factionName)
	local class = K.ClassList[className] or className
	return string_format("%s%s|r %s", K.RGBToHex(K.ColorClass(class)), charName, GetButtonTexFromInviteType(guid, factionName))
end

local function buttonOnClick(self, button)
	local data = self.data
	if not data then
		return
	end

	if button == "LeftButton" then
		if IsAltKeyDown() then
			if self.isBNet then
				local index = 2

				if #menuList > 1 then
					for i = 2, #menuList do
						table_wipe(menuList[i])
					end
				end

				menuList[1].text = K.InfoColor .. (data[2] or UNKNOWN)

				local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(data[1])
				if numGameAccounts and numGameAccounts > 0 then
					for i = 1, numGameAccounts do
						local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(data[1], i)
						if gameAccountInfo then
							local client = gameAccountInfo.clientProgram
							local wowProjectID = gameAccountInfo.wowProjectID
							local guid = gameAccountInfo.playerGuid
							if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID and guid then
								if not menuList[index] then
									menuList[index] = {}
								end

								menuList[index].text = GetNameAndInviteType(gameAccountInfo.className or UNKNOWN, gameAccountInfo.characterName or UNKNOWN, guid, gameAccountInfo.factionName or UNKNOWN)
								menuList[index].notCheckable = true
								menuList[index].arg1 = gameAccountInfo.gameAccountID
								menuList[index].arg2 = guid
								menuList[index].func = inviteFunc

								index = index + 1
							end
						end
					end
				end

				if index == 2 then
					return
				end

				K.LibEasyMenu.Create(menuList, K.EasyMenu, self, 0, 0, "MENU", 1)
			else
				InviteToGroup(data[1])
			end
		elseif IsShiftKeyDown() then
			local name = self.isBNet and data[3] or data[1]
			if name then
				if MailFrame and MailFrame:IsShown() then
					MailFrameTab_OnClick(nil, 2)
					SendMailNameEditBox:SetText(name)
					SendMailNameEditBox:HighlightText()
				else
					local editBox = ChatEdit_ChooseBoxForSend()
					local hasText = (editBox:GetText() ~= "")
					ChatEdit_ActivateChat(editBox)
					editBox:Insert(name)
					if not hasText then
						editBox:HighlightText()
					end
				end
			end
		end
	else
		if self.isBNet then
			ChatFrame_SendBNetTell(data[2])
		else
			ChatFrame_SendTell(data[1], SELECTED_DOCK_FRAME)
		end
	end
end

local function buttonOnEnter(self)
	local data = self.data
	if not data then
		return
	end

	GameTooltip:SetOwner(FriendsDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", infoFrame, "TOPRIGHT", 5, 0)
	GameTooltip:ClearLines()

	if self.isBNet then
		GameTooltip:AddLine(L["BN"], 0.4, 0.6, 1)
		GameTooltip:AddLine(" ")

		local index, accountName, _, _, _, _, _, _, _, note, broadcastText, broadcastTime = unpack(data)
		local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(index) or 0

		for i = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(index, i)
			if gameAccountInfo then
				local charName = gameAccountInfo.characterName or ""
				local client = gameAccountInfo.clientProgram
				local realmName = gameAccountInfo.realmName or ""
				local faction = gameAccountInfo.factionName
				local className = gameAccountInfo.className or UNKNOWN
				local zoneName = gameAccountInfo.areaName or UNKNOWN
				local level = gameAccountInfo.characterLevel or 0
				local gameText = gameAccountInfo.richPresence or ""
				local wowProjectID = gameAccountInfo.wowProjectID
				local timerunningSeasonID = gameAccountInfo.timerunningSeasonID

				if client == BNET_CLIENT_WOW then
					if charName ~= "" then -- fix for weird account
						if timerunningSeasonID and TimerunningUtil and TimerunningUtil.AddSmallIcon then
							charName = TimerunningUtil.AddSmallIcon(charName)
						end

						realmName = (K.Realm == realmName or realmName == "") and "" or "-" .. realmName

						-- Get Cata realm name from richPresence
						if wowProjectID == WOW_PROJECT_CATA then
							local realm, count = gsub(gameText, "^.-%-%s", "")
							if count and count > 0 then
								realmName = "-" .. realm
							end
						end

						local class = K.ClassList[className] or className
						local classColor = K.RGBToHex(K.ColorClass(class))

						local clientString = ""
						if faction == "Horde" then
							clientString = "|TInterface\\FriendsFrame\\PlusManz-Horde:16:|t"
						elseif faction == "Alliance" then
							clientString = "|TInterface\\FriendsFrame\\PlusManz-Alliance:16:|t"
						end

						GameTooltip:AddLine(string_format("%s%s %s%s%s", clientString, level, classColor, charName, realmName))

						if wowProjectID ~= WOW_PROJECT_ID then
							zoneName = "*" .. zoneName
						end
						GameTooltip:AddLine(string_format("%s%s", inactiveZone, zoneName))
					end
				else
					local clientString = GetClientLogo(client, 16)
					GameTooltip:AddLine(string_format("|cffffffff%s%s", clientString, accountName or UNKNOWN))
					if gameText ~= "" then
						GameTooltip:AddLine(string_format("%s%s", inactiveZone, gameText))
					end
				end
			end
		end

		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string_format(noteString, note), 1, 0.8, 0)
		end

		if broadcastText and broadcastText ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string_format(broadcastString, broadcastText, FriendsFrame_GetLastOnline(broadcastTime)), 0.3, 0.5, 0.7, 1)
		end
	else
		GameTooltip:AddLine(L["WoW"], 1, 0.8, 0)
		GameTooltip:AddLine(" ")

		local name, level, class, area, _, note = unpack(data)
		local classColor = K.RGBToHex(K.ColorClass(class))
		GameTooltip:AddLine(string_format("%s %s%s", level, classColor, name))
		GameTooltip:AddLine(string_format("%s%s", inactiveZone, area))
		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string_format(noteString, note), 1, 0.8, 0)
		end
	end

	GameTooltip:Show()
end

local function FriendsPanel_CreateButton(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(370, 20)
	button:SetPoint("TOPLEFT", 0, -(index - 1) * 22)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, 0.2)

	button.status = button:CreateTexture(nil, "ARTWORK")
	button.status:SetPoint("LEFT", button, 5, 0)
	button.status:SetSize(16, 16)

	button.name = K.CreateFontString(button, 12, "Tag (name)", "", false, "LEFT", 25, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 230, 0)
	button.name:SetJustifyH("LEFT")
	button.name:SetTextColor(0.5, 0.7, 1)

	button.zone = K.CreateFontString(button, 12, "Zone", "", false, "RIGHT", -28, 0)
	button.zone:SetPoint("LEFT", button, "RIGHT", -130, 0)
	button.zone:SetJustifyH("RIGHT")

	button.gameIcon = button:CreateTexture(nil, "ARTWORK")
	button.gameIcon:SetPoint("RIGHT", button, -8, 0)
	button.gameIcon:SetSize(16, 16)

	button.gameIcon.border = CreateFrame("Frame", nil, button)
	button.gameIcon.border:SetFrameLevel(button:GetFrameLevel())
	button.gameIcon.border:SetAllPoints(button.gameIcon)
	button.gameIcon.border:CreateBorder()

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", buttonOnClick)
	button:SetScript("OnEnter", buttonOnEnter)
	button:SetScript("OnLeave", K.HideTooltip)

	return button
end

local function FriendsPanel_Init()
	if infoFrame then
		infoFrame:Show()
		return
	end

	infoFrame = CreateFrame("Frame", "KKUI_FriendsInfoFrame", FriendsDataText)
	infoFrame:SetSize(400, 495)
	infoFrame:SetPoint(K.GetAnchors(FriendsDataText))
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
		if FriendsDataText then
			FriendsDataText:SetScript("OnUpdate", nil)
		end
	end)

	K.CreateFontString(infoFrame, 14, "|cff0099ff" .. FRIENDS_LIST, "", nil, "TOPLEFT", 15, -10)
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
		buttons[i] = FriendsPanel_CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = BUTTON_HEIGHT
	scrollFrame.update = FriendsPanel_Update
	scrollFrame:SetScript("OnMouseWheel", FriendsPanel_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * BUTTON_HEIGHT)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, 0)
	scrollBar:SetValue(0)

	K.CreateFontString(infoFrame, 12, Module.LineString, "", false, "BOTTOMRIGHT", -12, 42)
	local whspInfo = K.InfoColor .. K.RightButton .. L["Whisper"]
	K.CreateFontString(infoFrame, 12, whspInfo, "", false, "BOTTOMRIGHT", -15, 26)
	local invtInfo = K.InfoColor .. "ALT +" .. K.LeftButton .. L["Invite"]
	K.CreateFontString(infoFrame, 12, invtInfo, "", false, "BOTTOMRIGHT", -15, 10)

	FriendsPanel_Resize(0)
end

local function FriendsPanel_Refresh()
	local numFriends = C_FriendList_GetNumFriends() or 0
	local onlineFriends = C_FriendList_GetNumOnlineFriends() or 0
	local numBNet, onlineBNet = BNGetNumFriends()

	numBNet = numBNet or 0
	onlineBNet = onlineBNet or 0

	local totalOnline = onlineFriends + onlineBNet
	local totalFriends = numFriends + numBNet

	Module.numFriends = numFriends
	Module.onlineFriends = onlineFriends
	Module.numBNet = numBNet
	Module.onlineBNet = onlineBNet
	Module.totalOnline = totalOnline
	Module.totalFriends = totalFriends

	if infoFrame and infoFrame.scrollFrame then
		FriendsPanel_Resize(totalOnline)
	end
end

local function OnEnter()
	local thisTime = GetTime()
	if not prevTime or (thisTime - prevTime > 5) then
		FriendsPanel_Refresh()
		prevTime = thisTime
	end

	local numFriends = Module.numFriends or 0
	local numBNet = Module.numBNet or 0
	local totalOnline = Module.totalOnline or 0
	local totalFriends = Module.totalFriends or 0

	if totalOnline == 0 then
		GameTooltip:SetOwner(FriendsDataText, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(FriendsDataText))
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(FRIENDS_LIST, string_format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends), 0.4, 0.6, 1, 0.4, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Guess it's time to talk to the voices in my head.", 1, 1, 1)
		GameTooltip:Show()
		return
	end

	if not updateRequest then
		if numFriends > 0 then
			buildFriendTable(numFriends)
		end
		if numBNet > 0 then
			buildBNetTable(numBNet)
		end
		updateRequest = true
	end

	FriendsPanel_Init()
	FriendsPanel_Update()
	infoFrame.friendCountText:SetText(string_format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends))
end

local eventList = {
	"BN_FRIEND_ACCOUNT_OFFLINE",
	"BN_FRIEND_ACCOUNT_ONLINE",
	"BN_FRIEND_INFO_CHANGED",
	"CHAT_MSG_SYSTEM",
	"FRIENDLIST_UPDATE",
	"PLAYER_ENTERING_WORLD",
}

local function OnEvent(_, event, arg1)
	if event == "CHAT_MSG_SYSTEM" then
		local msg = arg1 or ""
		if not string_find(msg, onlineString) and not string_find(msg, offlineString) then
			return
		end
	end

	FriendsPanel_Refresh()

	if C["DataText"].HideText then
		FriendsDataText.Text:SetText("")
	else
		FriendsDataText.Text:SetText(string_format("%s: " .. K.MyClassColor .. "%d", FRIENDS, Module.totalOnline or 0))
	end

	-- Keep frame and mover size in sync with icon + text
	local textW = FriendsDataText.Text:GetStringWidth() or 0
	local iconW = (FriendsDataText.Texture and FriendsDataText.Texture:GetWidth()) or 0
	local totalW = textW + iconW
	local textH = FriendsDataText.Text:GetLineHeight() or 12
	local iconH = (FriendsDataText.Texture and FriendsDataText.Texture:GetHeight()) or 12
	local totalH = math_max(textH, iconH)

	FriendsDataText:SetSize(math_max(totalW, 56), totalH)
	if FriendsDataText.mover then
		FriendsDataText.mover:SetWidth(math_max(totalW, 56))
		FriendsDataText.mover:SetHeight(totalH)
	end

	updateRequest = false
	if infoFrame and infoFrame:IsShown() then
		if not updateQueued then
			updateQueued = true
			K.Delay(0.05, function()
				if infoFrame and infoFrame:IsShown() then
					OnEnter()
				end
				updateQueued = false
			end)
		end
	end
end

local function OnLeave()
	GameTooltip:Hide()

	if not infoFrame then
		return
	end

	if FriendsDataText then
		FriendsDataText:SetScript("OnUpdate", isPanelCanHide)
	end
	infoFrame:SetScript("OnUpdate", isPanelCanHide)
end

local function OnMouseUp(_, btn)
	if btn ~= "LeftButton" then
		return
	end

	if infoFrame then
		infoFrame:Hide()
	end

	ToggleFriendsFrame()
end

function Module:CreateSocialDataText()
	if not C["DataText"].Friends then
		return
	end

	FriendsDataText = CreateFrame("Frame", nil, UIParent)

	FriendsDataText.Text = K.CreateFontString(FriendsDataText, 12)
	FriendsDataText.Text:ClearAllPoints()
	FriendsDataText.Text:SetPoint("LEFT", FriendsDataText, "LEFT", 24, 0)

	FriendsDataText.Texture = FriendsDataText:CreateTexture(nil, "ARTWORK")
	FriendsDataText.Texture:SetPoint("LEFT", FriendsDataText, "LEFT", 0, 2)
	FriendsDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\player.blp")
	FriendsDataText.Texture:SetSize(24, 24)
	FriendsDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	for _, event in pairs(eventList) do
		FriendsDataText:RegisterEvent(event)
	end

	FriendsDataText:SetScript("OnEvent", OnEvent)
	FriendsDataText:SetScript("OnEnter", OnEnter)
	FriendsDataText:SetScript("OnLeave", OnLeave)
	FriendsDataText:SetScript("OnMouseUp", OnMouseUp)

	-- Make the whole block (icon + text) movable
	FriendsDataText.mover = K.Mover(FriendsDataText, "FriendsDT", "FriendsDT", { "LEFT", UIParent, "LEFT", 0, -270 }, 56, 12)
end
