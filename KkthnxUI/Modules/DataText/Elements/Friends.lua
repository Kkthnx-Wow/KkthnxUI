local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local string_find = _G.string.find
local string_format = _G.string.format
local table_sort = _G.table.sort
local table_wipe = _G.table.wipe
local unpack = _G.unpack
local table_insert = _G.table.insert

local BNGetNumFriends = _G.BNGetNumFriends
local BNet_GetClientEmbeddedTexture = _G.BNet_GetClientEmbeddedTexture
local BNet_GetClientTexture = _G.BNet_GetClientTexture
local BNet_GetValidatedCharacterName = _G.BNet_GetValidatedCharacterName
local C_BattleNet_GetFriendAccountInfo = _G.C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = _G.C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = _G.C_BattleNet.GetFriendNumGameAccounts
local C_FriendList_GetFriendInfoByIndex = _G.C_FriendList.GetFriendInfoByIndex
local C_FriendList_GetNumFriends = _G.C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = _G.C_FriendList.GetNumOnlineFriends
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local InviteToGroup = _G.C_PartyInfo.InviteUnit
local IsAltKeyDown = _G.IsAltKeyDown
local UIParent = _G.UIParent

local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local GUILD_ONLINE_LABEL = _G.GUILD_ONLINE_LABEL
local FRIENDS_TEXTURE_ONLINE = _G.FRIENDS_TEXTURE_ONLINE
local FRIENDS_TEXTURE_AFK = _G.FRIENDS_TEXTURE_AFK
local FRIENDS_TEXTURE_DND = _G.FRIENDS_TEXTURE_DND
local RAF_RECRUIT_FRIEND = _G.RAF_RECRUIT_FRIEND
local RAF_RECRUITER_FRIEND = _G.RAF_RECRUITER_FRIEND
local WOW_PROJECT_ID = _G.WOW_PROJECT_ID or 1
local UNKNOWN = _G.UNKNOWN

local CLIENT_WOW_CLASSIC = "WoV" -- for sorting

local r, g, b = K.r, K.g, K.b
local friendsFrame, menuFrame, updateRequest
local menuList, buttons, friendTable, bnetTable = {}, {}, {}, {}
local activeZone, inactiveZone = "|cff4cff4c", K.GreyColor
local noteString = "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:16|t %s"
local broadcastString = "|TInterface\\FriendsFrame\\BroadcastIcon:16|t %s (%s)"
local onlineString = gsub(ERR_FRIEND_ONLINE_SS, ".+h", "")
local offlineString = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "")

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
			table_insert(friendTable, {info.name, info.level, class, info.area, status})
		end
	end

	table_sort(friendTable, sortFriends)
end

local function sortBNFriends(a, b)
	if a[5] and b[5] then
		return a[5] > b[5]
	end
end

local function CanCooperateWithUnit(gameAccountInfo)
	return gameAccountInfo.playerGuid and (gameAccountInfo.factionName == K.Faction) and (gameAccountInfo.realmID ~= 0)
end

local function GetOnlineInfoText(client, isMobile, rafLinkType, locationText)
	if not locationText or locationText == "" then
		return UNKNOWN
	end

	if isMobile then
		return LOCATION_MOBILE_APP
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
			local isAFK = accountInfo.isAFK
			local isDND = accountInfo.isDND
			local note = accountInfo.note
			local broadcastText = accountInfo.customMessage
			local broadcastTime = accountInfo.customMessageTime
			local rafLinkType = accountInfo.rafLinkType

			local gameAccountInfo = accountInfo.gameAccountInfo
			local isOnline = gameAccountInfo.isOnline
			local gameID = gameAccountInfo.gameAccountID

			if isOnline and gameID then
				local charName = gameAccountInfo.characterName
				local client = gameAccountInfo.clientProgram
				local class = gameAccountInfo.className or UNKNOWN
				local zoneName = gameAccountInfo.areaName or UNKNOWN
				local level = gameAccountInfo.characterLevel
				local gameText = gameAccountInfo.richPresence or ""
				local isGameAFK = gameAccountInfo.isGameAFK
				local isGameBusy = gameAccountInfo.isGameBusy
				local wowProjectID = gameAccountInfo.wowProjectID
				local isMobile = gameAccountInfo.isWowMobile
				local canCooperate = CanCooperateWithUnit(gameAccountInfo)

				charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
				class = K.ClassList[class]

				local status = FRIENDS_TEXTURE_ONLINE
				if isAFK or isGameAFK then
					status = FRIENDS_TEXTURE_AFK
				elseif isDND or isGameBusy then
					status = FRIENDS_TEXTURE_DND
				end

				local infoText = GetOnlineInfoText(client, isMobile, rafLinkType, gameText)
				if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
					infoText = GetOnlineInfoText(client, isMobile, rafLinkType, zoneName)
				end

				if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then
					client = CLIENT_WOW_CLASSIC
				end

				table_insert(bnetTable, {i, accountName, charName, canCooperate, client, status, class, level, infoText, note, broadcastText, broadcastTime})
			end
		end
	end

	table_sort(bnetTable, sortBNFriends)
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 0.1 then
		if not friendsFrame:IsMouseOver() then
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end

		self.timer = 0
	end
end

local function setupFriendsFrame()
	if friendsFrame then
		friendsFrame:Show()
		return
	end

	friendsFrame = CreateFrame("Frame", "KKUI_FriendsDataTextFrame", Module.FriendsDataTextFrame)
	friendsFrame:SetSize(400, 486)
	friendsFrame:SetPoint(K.GetAnchors(Module.FriendsDataTextFrame))
	friendsFrame:SetClampedToScreen(true)
	friendsFrame:SetFrameStrata("DIALOG")
	friendsFrame:CreateBorder()

	friendsFrame:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", OnUpdate)
	end)

	friendsFrame:SetScript("OnHide", function()
		if menuFrame and menuFrame:IsShown() then
			menuFrame:Hide()
		end
	end)

	K.CreateFontString(friendsFrame, 14, "|cff0099ff"..FRIENDS_LIST, "", nil, "TOPLEFT", 15, -10)
	friendsFrame.numFriends = K.CreateFontString(friendsFrame, 14, "-/-", "", nil, "TOPRIGHT", -15, -12)
	friendsFrame.numFriends:SetTextColor(0, .6, 1)

	local scrollFrame = CreateFrame("ScrollFrame", nil, friendsFrame, "UIPanelScrollFrameTemplate")
	scrollFrame:SetSize(380, 400)
	scrollFrame:SetPoint("TOPLEFT", 10, -35)
	Module.ReskinScrollBar(scrollFrame)

	local roster = CreateFrame("Frame", nil, scrollFrame)
	roster:SetSize(380, 1)
	scrollFrame:SetScrollChild(roster)
	friendsFrame.roster = roster

	local whspInfo = K.InfoColor.." |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:333:411|t "..L["Whisper"]
	K.CreateFontString(friendsFrame, 12, whspInfo, "", false, "BOTTOMRIGHT", -15, 26)
	local invtInfo = K.InfoColor.."ALT +".." |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:230:307|t "..L["Invite"]
	K.CreateFontString(friendsFrame, 12, invtInfo, "", false, "BOTTOMRIGHT", -15, 10)
end

local function createInviteMenu()
	if menuFrame then
		return
	end

	menuFrame = CreateFrame("Frame", "FriendsInfobarMenu", friendsFrame, "UIDropDownMenuTemplate")
	menuFrame:SetFrameStrata("TOOLTIP")
	menuList[1] = {text = L["Join or Invite"], isTitle = true, notCheckable = true}
end

local function inviteFunc(_, bnetIDGameAccount, guid)
	FriendsFrame_InviteOrRequestToJoin(guid, bnetIDGameAccount)
end

local function buttonOnClick(self, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			if self.isBNet then
				createInviteMenu()

				local index = 2
				if #menuList > 1 then
					for i = 2, #menuList do menuList[i] = nil end
				end

				local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(self.data[1])
				local lastGameAccountID, lastGameAccountGUID
				if numGameAccounts > 0 then
					for i = 1, numGameAccounts do
						local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(self.data[1], i)
						local charName = gameAccountInfo.characterName
						local client = gameAccountInfo.clientProgram
						local class = gameAccountInfo.className or UNKNOWN
						local bnetIDGameAccount = gameAccountInfo.gameAccountID
						local guid = gameAccountInfo.playerGuid
						local wowProjectID = gameAccountInfo.wowProjectID
						if client == BNET_CLIENT_WOW and CanCooperateWithUnit(gameAccountInfo) and wowProjectID == WOW_PROJECT_ID then
							if not menuList[index] then menuList[index] = {} end
							menuList[index].text = K.RGBToHex(K.ColorClass(K.ClassList[class]))..charName
							menuList[index].notCheckable = true
							menuList[index].arg1 = bnetIDGameAccount
							menuList[index].arg2 = guid
							menuList[index].func = inviteFunc
							lastGameAccountID = bnetIDGameAccount
							lastGameAccountGUID = guid

							index = index + 1
						end
					end
				end

				if index == 2 then
					return
				end

				if index == 3 then
					FriendsFrame_InviteOrRequestToJoin(lastGameAccountGUID, lastGameAccountID)
				else
					EasyMenu(menuList, menuFrame, self, 0, 0, "MENU", 1)
				end
			else
				InviteToGroup(self.data[1])
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
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", friendsFrame, "TOPRIGHT", 5, 2)
	GameTooltip:ClearLines()

	if self.isBNet then
		GameTooltip:AddLine(L["BN"], 0,.6,1)
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
			local zoneName = gameAccountInfo.areaName or UNKNOWN
			local level = gameAccountInfo.characterLevel
			local gameText = gameAccountInfo.richPresence or ""
			local wowProjectID = gameAccountInfo.wowProjectID
			local clientString = BNet_GetClientEmbeddedTexture(client, 16)
			if client == BNET_CLIENT_WOW then
				if charName ~= "" then -- fix for weird account
					realmName = (K.Realm == realmName or realmName == "") and "" or "-"..realmName
					class = K.ClassList[class]
					local classColor = K.RGBToHex(K.ColorClass(class))
					if faction == "Horde" then
						clientString = "|TInterface\\FriendsFrame\\PlusManz-Horde:16:|t"
					elseif faction == "Alliance" then
						clientString = "|TInterface\\FriendsFrame\\PlusManz-Alliance:16:|t"
					end
					GameTooltip:AddLine(string_format("%s%s %s%s%s", clientString, level, classColor, charName, realmName))

					if wowProjectID ~= WOW_PROJECT_ID then
						zoneName = "*"..zoneName
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
			GameTooltip:AddLine(string_format(noteString, note), 1,.8,0)
		end

		if broadcastText and broadcastText ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string_format(broadcastString, broadcastText, FriendsFrame_GetLastOnline(broadcastTime)), 0.3, 0.6, 0.8, 1)
		end
	else
		GameTooltip:AddLine(L["WoW"], 1, 0.8, 0)
		GameTooltip:AddLine(" ")

		local name, level, class, area = unpack(self.data)
		local classColor = K.RGBToHex(K.ColorClass(class))
		GameTooltip:AddLine(string_format("%s %s%s", level, classColor, name))
		GameTooltip:AddLine(string_format("%s%s", inactiveZone, area))
	end
	GameTooltip:Show()
end

local function createRoster(parent, i)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(380, 20)
	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, .2)
	button.index = i

	button.status = button:CreateTexture(nil, "ARTWORK")
	button.status:SetPoint("LEFT", button, 5, 0)
	button.status:SetSize(16, 16)

	button.name = K.CreateFontString(button, 12, "Tag (name)", "", false, "LEFT", 25, 0)
	button.name:SetPoint("RIGHT", button, "LEFT", 230, 0)
	button.name:SetJustifyH("LEFT")
	button.name:SetTextColor(.5, .7, 1)

	button.zone = K.CreateFontString(button, 12, "Zone", "", false, "RIGHT", -28, 0)
	button.zone:SetPoint("LEFT", button, "RIGHT", -130, 0)
	button.zone:SetJustifyH("RIGHT")

	button.gameIcon = button:CreateTexture(nil, "ARTWORK")
	button.gameIcon:SetPoint("RIGHT", button, -8, 0)
	button.gameIcon:SetSize(16, 16)
	button.gameIcon:SetTexCoord(0.17, 0.83, 0.17, 0.83)

	if not button.gameIcon.Border then
		button.gameIcon.Border = CreateFrame("Frame", nil, button)
		button.gameIcon.Border:SetFrameLevel(button:GetFrameLevel())
		button.gameIcon.Border:SetAllPoints(button.gameIcon)
		button.gameIcon.Border:CreateBorder(nil, nil, 10)
		button.gameIcon.Border = true
	end

	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", buttonOnClick)
	button:SetScript("OnEnter", buttonOnEnter)
	button:SetScript("OnLeave", K.HideTooltip)

	return button
end

local previous = 0
local function updateAnchor()
	for i = 1, previous do
		if i == 1 then
			buttons[i]:SetPoint("TOPLEFT")
		else
			buttons[i]:SetPoint("TOP", buttons[i-1], "BOTTOM")
		end
		buttons[i]:Show()
	end
end

local function updateFriendsFrame()
	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, onlineBNet = BNGetNumFriends()
	local totalOnline = onlineFriends + onlineBNet
	if totalOnline ~= previous then
		if totalOnline > previous then
			for i = previous+1, totalOnline do
				if not buttons[i] then
					buttons[i] = createRoster(friendsFrame.roster, i)
				end
			end
		elseif totalOnline < previous then
			for i = totalOnline+1, previous do
				buttons[i]:Hide()
			end
		end
		previous = totalOnline

		updateAnchor()
	end

	for i = 1, #friendTable do
		local button = buttons[i]
		local name, level, class, area, status = unpack(friendTable[i])
		button.status:SetTexture(status)
		local zoneColor = GetRealZoneText() == area and activeZone or inactiveZone
		local levelColor = K.RGBToHex(GetQuestDifficultyColor(level))
		local classColor = K.ClassColors[class] or levelColor
		button.name:SetText(string_format("%s%s|r %s%s", levelColor, level, K.RGBToHex(classColor), name))
		button.zone:SetText(string_format("%s%s", zoneColor, area))
		button.gameIcon:SetTexture(BNet_GetClientTexture(BNET_CLIENT_WOW))

		button.isBNet = nil
		button.data = friendTable[i]
	end

	for i = 1, #bnetTable do
		local button = buttons[i+onlineFriends]
		local _, accountName, charName, canCooperate, client, status, class, _, infoText = unpack(bnetTable[i])

		button.status:SetTexture(status)
		local zoneColor = inactiveZone
		local name = inactiveZone..charName
		if client == BNET_CLIENT_WOW then
			if canCooperate then
				local color = K.ClassColors[class] or GetQuestDifficultyColor(1)
				name = K.RGBToHex(color)..charName
			end
			zoneColor = GetRealZoneText() == infoText and activeZone or inactiveZone
		end
		button.name:SetText(string_format("%s%s|r (%s|r)", K.InfoColor, accountName, name))
		button.zone:SetText(string_format("%s%s", zoneColor, infoText))
		if client == CLIENT_WOW_CLASSIC then
			button.gameIcon:SetTexture(BNet_GetClientTexture(BNET_CLIENT_WOW))
			button.gameIcon:SetVertexColor(0.3, 0.3, 0.3)
		else
			button.gameIcon:SetTexture(BNet_GetClientTexture(client))
			button.gameIcon:SetVertexColor(1, 1, 1)
		end

		button.isBNet = true
		button.data = bnetTable[i]
	end
end

local function OnEnter()
	local numFriends, onlineFriends = C_FriendList_GetNumFriends(), C_FriendList_GetNumOnlineFriends()
	local numBNet, onlineBNet = BNGetNumFriends()
	local totalOnline = onlineFriends + onlineBNet
	local totalFriends = numFriends + numBNet

	if totalOnline == 0 then
		GameTooltip:SetOwner(Module.FriendsDataTextFrame, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOMLEFT", Module.FriendsDataTextFrame, "TOPRIGHT", 6, 10)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(FRIENDS_LIST, string_format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends), 0, 0.6, 1, 0, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("No Online", 1, 1, 1)
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

	if KKUI_GuildDataTextFrame and KKUI_GuildDataTextFrame:IsShown() then
		KKUI_GuildDataTextFrame:Hide()
	end

	setupFriendsFrame()
	friendsFrame.numFriends:SetText(string_format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends))
	updateFriendsFrame()
end

local function OnEvent(_, event, arg1)
	if event == "CHAT_MSG_SYSTEM" then
		if not string_find(arg1, onlineString) and not string_find(arg1, offlineString) then
			return
		end
	end

	local onlineFriends = C_FriendList_GetNumOnlineFriends()
	local _, onlineBNet = BNGetNumFriends()
	Module.FriendsDataTextFrame.Text:SetText(string_format("%s", onlineFriends + onlineBNet))

	updateRequest = false
	if friendsFrame and friendsFrame:IsShown() then
		OnEnter()
	end
end

local function delayLeave()
	if MouseIsOver(friendsFrame) then
		return
	end

	friendsFrame:Hide()
end

local function OnLeave()
	GameTooltip:Hide()

	if not friendsFrame then
		return
	end

	C_Timer_After(0.1, delayLeave)
end

local function OnMouseUp(_, button)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
		return
	end

	if button ~= "LeftButton" then
		return
	end

	if friendsFrame then
		friendsFrame:Hide()
	end

	ToggleFriendsFrame(1)
end

function Module:CreateSocialDataText()
	if not C["DataText"].Friends or not C["ActionBar"].MicroBar then
		return
	end

	if not StoreMicroButton or not StoreMicroButton:IsShown() then
		return
	end

	StoreMicroButton:Kill()
	QuickJoinToastButton:Kill()

	Module.FriendsDataTextFrame = CreateFrame("Button", nil, UIParent)
	Module.FriendsDataTextFrame:SetAllPoints(StoreMicroButton)
	Module.FriendsDataTextFrame:SetSize(StoreMicroButton:GetWidth(), StoreMicroButton:GetHeight())
	Module.FriendsDataTextFrame:SetFrameLevel(StoreMicroButton:GetFrameLevel() + 2)
	Module.FriendsDataTextFrame:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.11, 0.11, 0.11, 1, nil, true)

	Module.FriendsDataTextFrame.Texture = Module.FriendsDataTextFrame:CreateTexture(nil, "BACKGROUND")
	Module.FriendsDataTextFrame.Texture:SetTexture("Interface\\CHATFRAME\\UI-ChatIcon-Battlenet")
	Module.FriendsDataTextFrame.Texture:SetPoint("CENTER", Module.FriendsDataTextFrame, "CENTER")
	Module.FriendsDataTextFrame.Texture:SetSize(StoreMicroButton:GetWidth() + 10, StoreMicroButton:GetHeight() + 4)

	Module.FriendsDataTextFrame.Text = Module.FriendsDataTextFrame:CreateFontString("OVERLAY")
	Module.FriendsDataTextFrame.Text:FontTemplate(nil, nil, "OUTLINE")
	Module.FriendsDataTextFrame.Text:SetPoint("CENTER", Module.FriendsDataTextFrame, "CENTER", 1, -6)

	Module.FriendsDataTextFrame:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE", OnEvent)
	Module.FriendsDataTextFrame:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE", OnEvent)
	Module.FriendsDataTextFrame:RegisterEvent("BN_FRIEND_INFO_CHANGED", OnEvent)
	Module.FriendsDataTextFrame:RegisterEvent("FRIENDLIST_UPDATE", OnEvent)
	Module.FriendsDataTextFrame:RegisterEvent("PLAYER_ENTERING_WORLD", OnEvent)
	Module.FriendsDataTextFrame:RegisterEvent("CHAT_MSG_SYSTEM", OnEvent)

	Module.FriendsDataTextFrame:SetScript("OnMouseUp", OnMouseUp)
	Module.FriendsDataTextFrame:SetScript("OnEnter", OnEnter)
	Module.FriendsDataTextFrame:SetScript("OnLeave", OnLeave)
	Module.FriendsDataTextFrame:SetScript("OnEvent", OnEvent)
end