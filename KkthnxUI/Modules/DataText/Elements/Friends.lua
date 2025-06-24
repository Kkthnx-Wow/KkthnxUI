local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

local string_find = string.find
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local table_wipe = table.wipe
local unpack = unpack

local BNGetNumFriends = BNGetNumFriends
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_GetFriendInfoByIndex = C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local FriendsFrame_GetFormattedCharacterName = FriendsFrame_GetFormattedCharacterName
local EXPANSION_NAME0 = EXPANSION_NAME0
local EXPANSION_NAME3 = EXPANSION_NAME3
local GameTooltip = GameTooltip
local GetDisplayedInviteType = GetDisplayedInviteType
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local HybridScrollFrame_GetOffset = HybridScrollFrame_GetOffset
local HybridScrollFrame_Update = HybridScrollFrame_Update
local InviteToGroup = C_PartyInfo.InviteUnit
local IsAltKeyDown = IsAltKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local MouseIsOver = MouseIsOver
local WOW_PROJECT_CATA = WOW_PROJECT_CATACLYSM_CLASSIC or 14

local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local FRIENDS_TEXTURE_AFK = FRIENDS_TEXTURE_AFK
local FRIENDS_TEXTURE_DND = FRIENDS_TEXTURE_DND
local FRIENDS_TEXTURE_ONLINE = FRIENDS_TEXTURE_ONLINE
local GUILD_ONLINE_LABEL = GUILD_ONLINE_LABEL
local RAF_RECRUITER_FRIEND = RAF_RECRUITER_FRIEND
local RAF_RECRUIT_FRIEND = RAF_RECRUIT_FRIEND
local UNKNOWN = UNKNOWN

local WOW_PROJECT_60 = WOW_PROJECT_CLASSIC or 2
local WOW_PROJECT_ID = WOW_PROJECT_ID or 1
local CLIENT_WOW_DIFF = "WoV" -- for sorting

local r, g, b = K.r, K.g, K.b
local infoFrame
local updateRequest
local prevTime
local friendTable = {}
local bnetTable = {}
local activeZone = "|cff4cff4c"
local inactiveZone = K.GreyColor
local noteString = "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:16|t %s"
local broadcastString = "|TInterface\\FriendsFrame\\BroadcastIcon:12|t %s (%s)"
local onlineString = gsub(ERR_FRIEND_ONLINE_SS, ".+h", "")
local offlineString = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")
local FriendsDataText

local menuList = {
	[1] = {
		text = L["Join or Invite"],
		isTitle = true,
		notCheckable = true,
	},
}

local function sortFriends(a, b)
	if a[1] and b[1] then
		return a[1] < b[1]
	end
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

			local class = K.ClassList[info.className]
			table_insert(friendTable, { info.name, info.level, class, info.area, status, info.notes })
		end
	end

	table_sort(friendTable, sortFriends)
end

local function sortBNFriends(a, b)
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

	if (client == BNET_CLIENT_WOW) and (rafLinkType ~= Enum.RafLinkType.None) and not isMobile then
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
			local gameID = gameAccountInfo.gameAccountID
			local isAFK = accountInfo.isAFK
			local isDND = accountInfo.isDND
			local isOnline = gameAccountInfo.isOnline
			local note = accountInfo.note
			local rafLinkType = accountInfo.rafLinkType

			if isOnline and gameID then
				local charName = gameAccountInfo.characterName
				local class = gameAccountInfo.className or UNKNOWN
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
				class = K.ClassList[class]

				local status = FRIENDS_TEXTURE_ONLINE
				if isAFK or isGameAFK then
					status = FRIENDS_TEXTURE_AFK
				elseif isDND or isGameBusy then
					status = FRIENDS_TEXTURE_DND
				end

				if wowProjectID == WOW_PROJECT_60 then
					gameText = EXPANSION_NAME0
				elseif wowProjectID == WOW_PROJECT_CATA then
					gameText = EXPANSION_NAME3
				end

				local infoText = GetOnlineInfoText(client, isMobile, rafLinkType, gameText)
				if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
					infoText = GetOnlineInfoText(client, isMobile, rafLinkType, zoneName or gameText)
				end

				if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then
					client = CLIENT_WOW_DIFF
				end

				table_insert(bnetTable, { i, accountName, charName, factionName, client, status, class, level, infoText, note, broadcastText, broadcastTime })
			end
		end
	end

	table_sort(bnetTable, sortBNFriends)
end

local function isPanelCanHide(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 0.5 then -- Increased delay to 0.5 seconds
		if not infoFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function FriendsPanel_UpdateButton(button)
	local index = button.index
	local onlineFriends = Module.onlineFriends

	if index <= onlineFriends then
		local name, level, class, area, status = unpack(friendTable[index])
		button.status:SetTexture(status)
		local zoneColor = GetRealZoneText() == area and activeZone or inactiveZone
		local levelColor = K.RGBToHex(GetQuestDifficultyColor(level))
		local classColor = K.ClassColors[class] or levelColor
		button.name:SetText(string_format("%s%s|r %s%s", levelColor, level, K.RGBToHex(classColor), name))
		button.zone:SetText(string_format("%s%s", zoneColor, area))
		C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)
		-- button.gameIcon:SetAtlas(BNet_GetBattlenetClientAtlas(BNET_CLIENT_WOW))

		button.isBNet = nil
		button.data = friendTable[index]
	else
		local bnetIndex = index - onlineFriends
		local _, accountName, charName, factionName, client, status, class, _, infoText = unpack(bnetTable[bnetIndex])

		button.status:SetTexture(status)
		local zoneColor = inactiveZone
		local name = inactiveZone .. charName
		if client == BNET_CLIENT_WOW then
			local color = K.ClassColors[class] or GetQuestDifficultyColor(1)
			name = K.RGBToHex(color) .. charName
			zoneColor = GetRealZoneText() == infoText and activeZone or inactiveZone
		end
		button.name:SetText(string_format("%s%s|r (%s|r)", K.InfoColor, accountName, name))
		button.zone:SetText(string_format("%s%s", zoneColor, infoText))
		if client == CLIENT_WOW_DIFF then
			C_Texture.SetTitleIconTexture(button.gameIcon, BNET_CLIENT_WOW, Enum.TitleIconVersion.Medium)
			-- button.gameIcon:SetAtlas(BNet_GetBattlenetClientAtlas(BNET_CLIENT_WOW))
		elseif client == BNET_CLIENT_WOW then
			button.gameIcon:SetTexture("Interface\\FriendsFrame\\PlusManz-" .. factionName)
		else
			C_Texture.SetTitleIconTexture(button.gameIcon, client, Enum.TitleIconVersion.Medium)
			-- button.gameIcon:SetAtlas(BNet_GetBattlenetClientAtlas(client))
		end

		button.isBNet = true
		button.data = bnetTable[bnetIndex]
	end
end

local function FriendsPanel_Update()
	local scrollFrame = KKUI_FriendsDataTextScrollFrame
	local usedHeight = 0
	local buttons = scrollFrame.buttons
	local height = scrollFrame.buttonHeight
	local numFriendButtons = Module.totalOnline
	local offset = HybridScrollFrame_GetOffset(scrollFrame)

	for i = 1, #buttons do
		local button = buttons[i]
		local index = offset + i
		if index <= numFriendButtons then
			button.index = index
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
	_G.FriendsFrame_InviteOrRequestToJoin(guid, bnetIDGameAccount)
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
	local inviteType = GetDisplayedInviteType(guid)
	if factionName and factionName ~= K.Faction then
		inviteType = inviteType .. "_CROSS_FACTION"
	end
	return inviteTypeToButtonText[inviteType]
end

local function GetNameAndInviteType(class, charName, guid, factionName)
	return format("%s%s|r %s", K.RGBToHex(K.ColorClass(K.ClassList[class])), charName, GetButtonTexFromInviteType(guid, factionName))
end

local function buttonOnClick(self, button)
	if button == "LeftButton" then
		if IsAltKeyDown() then
			if self.isBNet then
				local index = 2
				if #menuList > 1 then
					for i = 2, #menuList do
						table_wipe(menuList[i])
					end
				end
				menuList[1].text = K.InfoColor .. self.data[2]

				local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(self.data[1])
				if numGameAccounts > 0 then
					for i = 1, numGameAccounts do
						local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(self.data[1], i)
						local charName = gameAccountInfo.characterName
						local client = gameAccountInfo.clientProgram
						local class = gameAccountInfo.className or UNKNOWN
						local factionName = gameAccountInfo.factionName or UNKNOWN
						local bnetIDGameAccount = gameAccountInfo.gameAccountID
						local guid = gameAccountInfo.playerGuid
						local wowProjectID = gameAccountInfo.wowProjectID
						if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID and guid then
							if not menuList[index] then
								menuList[index] = {}
							end

							menuList[index].text = GetNameAndInviteType(class, charName, guid, factionName)
							menuList[index].notCheckable = true
							menuList[index].arg1 = bnetIDGameAccount
							menuList[index].arg2 = guid
							menuList[index].func = inviteFunc

							index = index + 1
						end
					end
				end

				if index == 2 then
					return
				end

				K.LibEasyMenu.Create(menuList, K.EasyMenu, self, 0, 0, "MENU", 1)
			else
				InviteToGroup(self.data[1])
			end
		elseif IsShiftKeyDown() then
			local name = self.isBNet and self.data[3] or self.data[1]
			if name then
				if MailFrame:IsShown() then
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
			ChatFrame_SendBNetTell(self.data[2])
		else
			ChatFrame_SendTell(self.data[1], SELECTED_DOCK_FRAME)
		end
	end
end

local function buttonOnEnter(self)
	GameTooltip:SetOwner(FriendsDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", infoFrame, "TOPRIGHT", 5, 0)
	GameTooltip:ClearLines()

	if self.isBNet then
		GameTooltip:AddLine(L["BN"], 0.4, 0.6, 1)
		GameTooltip:AddLine(" ")

		local index, accountName, _, _, _, _, _, _, _, note, broadcastText, broadcastTime = unpack(self.data)
		local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(index)
		for i = 1, numGameAccounts do
			local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(index, i)
			local charName = gameAccountInfo.characterName
			local client = gameAccountInfo.clientProgram
			local realmName = gameAccountInfo.realmName or ""
			local faction = gameAccountInfo.factionName
			local class = gameAccountInfo.className or UNKNOWN
			local zoneName = gameAccountInfo.areaName
			local level = gameAccountInfo.characterLevel
			local gameText = gameAccountInfo.richPresence or ""
			local wowProjectID = gameAccountInfo.wowProjectID
			local clientString = BNet_GetClientEmbeddedAtlas(client, 16) or BNet_GetClientEmbeddedTexture(client, 16)
			local timerunningSeasonID = gameAccountInfo.timerunningSeasonID

			if client == BNET_CLIENT_WOW then
				if charName ~= "" then -- fix for weird account
					if timerunningSeasonID then
						charName = TimerunningUtil.AddSmallIcon(charName) -- add timerunning tag on name
					end
					realmName = (K.Realm == realmName or realmName == "") and "" or "-" .. realmName

					-- Get TBC realm name from richPresence
					if wowProjectID == WOW_PROJECT_CATA then
						local realm, count = gsub(gameText, "^.-%-%s", "")
						if count > 0 then
							realmName = "-" .. realm
						end
					end

					class = K.ClassList[class]
					local classColor = K.RGBToHex(K.ColorClass(class))
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
				GameTooltip:AddLine(string_format("|cffffffff%s%s", clientString, accountName))
				if gameText ~= "" then
					GameTooltip:AddLine(string_format("%s%s", inactiveZone, gameText))
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

		local name, level, class, area, _, note = unpack(self.data)
		local classColor = K.RGBToHex(K.ColorClass(class))
		GameTooltip:AddLine(string_format("%s %s%s", level, classColor, name))
		GameTooltip:AddLine(string_format("%s%s", inactiveZone, area))
		if note and note ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format(noteString, note), 1, 0.8, 0)
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
	-- button.gameIcon:SetTexCoord(0.17, 0.83, 0.17, 0.83)

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

	K.CreateFontString(infoFrame, 14, "|cff0099ff" .. FRIENDS_LIST, "", nil, "TOPLEFT", 15, -10)
	infoFrame.friendCountText = K.CreateFontString(infoFrame, 13, "-/-", "", nil, "TOPRIGHT", -15, -12)
	infoFrame.friendCountText:SetTextColor(0, 0.6, 1)

	local scrollFrame = CreateFrame("ScrollFrame", "KKUI_FriendsDataTextScrollFrame", infoFrame, "HybridScrollFrameTemplate")
	scrollFrame:SetSize(370, 400)
	scrollFrame:SetPoint("TOPLEFT", 7, -35)
	infoFrame.scrollFrame = scrollFrame

	local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
	scrollBar.doNotHide = true
	scrollBar:SkinScrollBar()
	scrollFrame.scrollBar = scrollBar

	local scrollChild = scrollFrame.scrollChild
	local numButtons = 20 + 1
	local buttonHeight = 22
	local buttons = {}
	for i = 1, numButtons do
		buttons[i] = FriendsPanel_CreateButton(scrollChild, i)
	end

	scrollFrame.buttons = buttons
	scrollFrame.buttonHeight = buttonHeight
	scrollFrame.update = FriendsPanel_Update
	scrollFrame:SetScript("OnMouseWheel", FriendsPanel_OnMouseWheel)
	scrollChild:SetSize(scrollFrame:GetWidth(), numButtons * buttonHeight)
	scrollFrame:SetVerticalScroll(0)
	scrollFrame:UpdateScrollChildRect()
	scrollBar:SetMinMaxValues(0, numButtons * buttonHeight)
	scrollBar:SetValue(0)

	K.CreateFontString(infoFrame, 12, Module.LineString, "", false, "BOTTOMRIGHT", -12, 42)
	local whspInfo = K.InfoColor .. K.RightButton .. L["Whisper"]
	K.CreateFontString(infoFrame, 12, whspInfo, "", false, "BOTTOMRIGHT", -15, 26)
	local invtInfo = K.InfoColor .. "ALT +" .. K.LeftButton .. L["Invite"]
	K.CreateFontString(infoFrame, 12, invtInfo, "", false, "BOTTOMRIGHT", -15, 10)
end

local function FriendsPanel_Refresh()
	local numFriends = C_FriendList_GetNumFriends()
	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local numBNet, onlineBNet = BNGetNumFriends()
	local totalOnline = onlineFriends + onlineBNet
	local totalFriends = numFriends + numBNet

	Module.numFriends = numFriends
	Module.onlineFriends = onlineFriends
	Module.numBNet = numBNet
	Module.onlineBNet = onlineBNet
	Module.totalOnline = totalOnline
	Module.totalFriends = totalFriends
end

local function OnEnter()
	local thisTime = GetTime()
	if not prevTime or (thisTime - prevTime > 5) then
		FriendsPanel_Refresh()
		prevTime = thisTime
	end

	local numFriends = Module.numFriends
	local numBNet = Module.numBNet
	local totalOnline = Module.totalOnline
	local totalFriends = Module.totalFriends

	if totalOnline == 0 then
		GameTooltip:SetOwner(FriendsDataText, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(FriendsDataText.Text))
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(FRIENDS_LIST, string_format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends), 0.4, 0.6, 1, 0.4, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Guess it's time to talk to the voices in my head.", 1, 1, 1) -- Display the random funny quote about having no friends online
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

local function OnEvent(event, arg1)
	if event == "CHAT_MSG_SYSTEM" then
		if not string_find(arg1, onlineString) and not string_find(arg1, offlineString) then
			return
		end
	end

	FriendsPanel_Refresh()

	if C["DataText"].HideText then
		FriendsDataText.Text:SetText("")
	else
		FriendsDataText.Text:SetText(string_format("%s: " .. K.MyClassColor .. "%d", FRIENDS, Module.totalOnline))
	end

	updateRequest = false
	if infoFrame and infoFrame:IsShown() then
		OnEnter()
	end
end

local function OnLeave()
	GameTooltip:Hide()

	if not infoFrame then
		return
	end

	-- Check if mouse is over the infoFrame or any of its buttons
	local mouseOverFrame = MouseIsOver(infoFrame)
	if not mouseOverFrame then
		for i, button in ipairs(infoFrame.scrollFrame.buttons) do
			if MouseIsOver(button) then
				mouseOverFrame = true
				break
			end
		end
	end
	if not mouseOverFrame then
		infoFrame:Hide()
	end
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
	FriendsDataText.Text:SetPoint("LEFT", UIParent, "LEFT", 24, -270)

	FriendsDataText.Texture = FriendsDataText:CreateTexture(nil, "ARTWORK")
	FriendsDataText.Texture:SetPoint("RIGHT", FriendsDataText.Text, "LEFT", 0, 2)
	FriendsDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\player.blp")
	FriendsDataText.Texture:SetSize(24, 24)
	FriendsDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	FriendsDataText:SetAllPoints(FriendsDataText.Text)

	local function _OnEvent(...)
		OnEvent(...)
	end

	for _, event in pairs(eventList) do
		FriendsDataText:RegisterEvent(event)
	end

	FriendsDataText:SetScript("OnEvent", _OnEvent)
	FriendsDataText:SetScript("OnEnter", OnEnter)
	FriendsDataText:SetScript("OnLeave", OnLeave)
	FriendsDataText:SetScript("OnMouseUp", OnMouseUp)

	K.Mover(FriendsDataText.Text, "FriendsDT", "FriendsDT", { "LEFT", UIParent, "LEFT", 24, -270 }, 56, 12)
end
