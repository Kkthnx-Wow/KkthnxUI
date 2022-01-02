local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Infobar")

local _G = _G
local string_find = _G.string.find
local string_format = _G.string.format
local table_insert = _G.table.insert
local table_sort = _G.table.sort
local table_wipe = _G.table.wipe
local unpack = _G.unpack

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
local GameTooltip = _G.GameTooltip
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local HybridScrollFrame_GetOffset = _G.HybridScrollFrame_GetOffset
local HybridScrollFrame_Update = _G.HybridScrollFrame_Update
local InviteToGroup = _G.C_PartyInfo.InviteUnit
local IsAltKeyDown = _G.IsAltKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown

local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local FRIENDS_TEXTURE_AFK = _G.FRIENDS_TEXTURE_AFK
local FRIENDS_TEXTURE_DND = _G.FRIENDS_TEXTURE_DND
local FRIENDS_TEXTURE_ONLINE = _G.FRIENDS_TEXTURE_ONLINE
local GUILD_ONLINE_LABEL = _G.GUILD_ONLINE_LABEL
local RAF_RECRUITER_FRIEND = _G.RAF_RECRUITER_FRIEND
local RAF_RECRUIT_FRIEND = _G.RAF_RECRUIT_FRIEND
local UNKNOWN = _G.UNKNOWN

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID or 1
local WOW_PROJECT_60 = WOW_PROJECT_CLASSIC or 2
local WOW_PROJECT_TBC = WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5
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
		notCheckable = true
	}
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
				local canCooperate = CanCooperateWithUnit(gameAccountInfo)
				local charName = gameAccountInfo.characterName
				local class = gameAccountInfo.className or UNKNOWN
				local client = gameAccountInfo.clientProgram
				local gameText = gameAccountInfo.richPresence or ""
				local isGameAFK = gameAccountInfo.isGameAFK
				local isGameBusy = gameAccountInfo.isGameBusy
				local isMobile = gameAccountInfo.isWowMobile
				local level = gameAccountInfo.characterLevel
				local wowProjectID = gameAccountInfo.wowProjectID
				local zoneName = gameAccountInfo.areaName or UNKNOWN

				charName = BNet_GetValidatedCharacterName(charName, battleTag, client)
				class = K.ClassList[class]

				local status = FRIENDS_TEXTURE_ONLINE
				if isAFK or isGameAFK then
					status = FRIENDS_TEXTURE_AFK
				elseif isDND or isGameBusy then
					status = FRIENDS_TEXTURE_DND
				end

				if wowProjectID == WOW_PROJECT_60 then
					gameText = EXPANSION_NAME0
				elseif wowProjectID == WOW_PROJECT_TBC then
					gameText = gsub(gameText, "%s%-.+", "")
				end

				local infoText = GetOnlineInfoText(client, isMobile, rafLinkType, gameText)
				if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID then
					infoText = GetOnlineInfoText(client, isMobile, rafLinkType, zoneName)
				end

				if client == BNET_CLIENT_WOW and wowProjectID ~= WOW_PROJECT_ID then
					client = CLIENT_WOW_DIFF
				end

				table_insert(bnetTable, {i, accountName, charName, canCooperate, client, status, class, level, infoText, note, broadcastText, broadcastTime})
			end
		end
	end

	table_sort(bnetTable, sortBNFriends)
end

local function isPanelCanHide(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > .1 then
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
		button.gameIcon:SetTexture(BNet_GetClientTexture(BNET_CLIENT_WOW))

		button.isBNet = nil
		button.data = friendTable[index]
	else
		local bnetIndex = index - onlineFriends
		local _, accountName, charName, canCooperate, client, status, class, _, infoText = unpack(bnetTable[bnetIndex])

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
		if client == CLIENT_WOW_DIFF then
			button.gameIcon:SetTexture(BNet_GetClientTexture(BNET_CLIENT_WOW))
			button.gameIcon:SetVertexColor(.3, .3, .3)
		else
			button.gameIcon:SetTexture(BNet_GetClientTexture(client))
			button.gameIcon:SetVertexColor(1, 1, 1)
		end

		button.isBNet = true
		button.data = bnetTable[bnetIndex]
	end
end

local function FriendsPanel_Update()
	local scrollFrame = _G.KKUI_FriendsInfobarScrollFrame
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
	FriendsFrame_InviteOrRequestToJoin(guid, bnetIDGameAccount)
end

local function buttonOnClick(self, btn)
	if btn == "LeftButton" then
		if IsAltKeyDown() then
			if self.isBNet then
				local index = 2
				if #menuList > 1 then
					for i = 2, #menuList do
						table_wipe(menuList[i])
					end
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
							if not menuList[index] then
								menuList[index] = {}
							end

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
					EasyMenu(menuList, K.EasyMenu, self, 0, 0, "MENU", 1)
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
	GameTooltip:SetOwner(FriendsDataText.Texture, "ANCHOR_NONE")
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
			local zoneName = gameAccountInfo.areaName or UNKNOWN
			local level = gameAccountInfo.characterLevel
			local gameText = gameAccountInfo.richPresence or ""
			local wowProjectID = gameAccountInfo.wowProjectID
			local clientString = BNet_GetClientEmbeddedTexture(client, 16)

			if client == BNET_CLIENT_WOW then
				if charName ~= "" then -- fix for weird account
					realmName = (K.Realm == realmName or realmName == "") and "" or "-"..realmName

					-- Get TBC realm name from richPresence
					if wowProjectID == WOW_PROJECT_TBC then
						local realm, count = gsub(gameText, "^.-%-%s", "")
						if count > 0 then
							realmName = "-"..realm
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
			GameTooltip:AddLine(string_format(noteString, note), 1, 0.8, 0)
		end

		if broadcastText and broadcastText ~= "" then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string_format(broadcastString, broadcastText, FriendsFrame_GetLastOnline(broadcastTime)), 0.3, 0.5, 0.7, 1)
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

local function FriendsPanel_CreateButton(parent, index)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(370, 20)
	button:SetPoint("TOPLEFT", 0, - (index - 1) * 20)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetAllPoints()
	button.HL:SetColorTexture(r, g, b, 0.2)

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
	button.gameIcon:SetTexCoord(.17, .83, .17, .83)

	local gameIconBorder = CreateFrame("Frame", nil, button)
	gameIconBorder:SetFrameLevel(button:GetFrameLevel())
	gameIconBorder:SetAllPoints(button.gameIcon)
	gameIconBorder:CreateBorder()

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

	infoFrame:SetScript("OnHide", function()
		if K.EasyMenu:IsShown() then
			K.EasyMenu:Hide()
		end
	end)

	K.CreateFontString(infoFrame, 14, "|cff0099ff"..FRIENDS_LIST, "", nil, "TOPLEFT", 15, -10)
	infoFrame.friendCountText = K.CreateFontString(infoFrame, 13, "-/-", "", nil, "TOPRIGHT", -15, -12)
	infoFrame.friendCountText:SetTextColor(0, .6, 1)

	local scrollFrame = CreateFrame("ScrollFrame", "KKUI_FriendsInfobarScrollFrame", infoFrame, "HybridScrollFrameTemplate")
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
	local whspInfo = K.InfoColor..K.RightButton..L["Whisper"]
	K.CreateFontString(infoFrame, 12, whspInfo, "", false, "BOTTOMRIGHT", -15, 26)
	local invtInfo = K.InfoColor.."ALT +"..K.LeftButton..L["Invite"]
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

local function OnEnter(self)
	local thisTime = GetTime()
	if not prevTime or (thisTime-prevTime > 5) then
		FriendsPanel_Refresh()
		prevTime = thisTime
	end

	local numFriends = Module.numFriends
	local numBNet = Module.numBNet
	local totalOnline = Module.totalOnline
	local totalFriends = Module.totalFriends

	if totalOnline == 0 then
		GameTooltip:SetOwner(FriendsDataText.Texture, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(FriendsDataText.Texture))
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(FRIENDS_LIST, string_format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends), 0.4, 0.6, 1, 0.4, 0.6, 1)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["No Online"], 1, 1, 1)
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

	if _G.KKUI_GuildInfoFrame and _G.KKUI_GuildInfoFrame:IsShown() then
		_G.KKUI_GuildInfoFrame:Hide()
	end

	FriendsPanel_Init()
	FriendsPanel_Update()
	infoFrame.friendCountText:SetText(string_format("%s: %s/%s", GUILD_ONLINE_LABEL, totalOnline, totalFriends))
end

local eventList = {
	"BN_FRIEND_ACCOUNT_ONLINE",
	"BN_FRIEND_ACCOUNT_OFFLINE",
	"BN_FRIEND_INFO_CHANGED",
	"FRIENDLIST_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"CHAT_MSG_SYSTEM",
}

local function OnEvent(_, event, arg1)
	if event == "CHAT_MSG_SYSTEM" then
		if not string_find(arg1, onlineString) and not string_find(arg1, offlineString) then
			return
		end
	end

	FriendsPanel_Refresh()

	if C["DataText"].HideText then
		FriendsDataText.Text:SetText("")
	else
		FriendsDataText.Text:SetText(string_format("%s: "..K.MyClassColor.."%d", FRIENDS, Module.totalOnline))
	end

	updateRequest = false
	if infoFrame and infoFrame:IsShown() then
		OnEnter()
	end
end

local function delayLeave()
	if MouseIsOver(infoFrame) then
		return
	end

	infoFrame:Hide()
end

local function OnLeave()
	GameTooltip:Hide()

	if not infoFrame then
		return
	end

	C_Timer_After(0.1, delayLeave)
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

	FriendsDataText = FriendsDataText or CreateFrame("Button", nil, UIParent)
	FriendsDataText:SetPoint("LEFT", UIParent, "LEFT", 0, -270)
	FriendsDataText:SetSize(24, 24)

	FriendsDataText.Texture = FriendsDataText:CreateTexture(nil, "BACKGROUND")
	FriendsDataText.Texture:SetPoint("LEFT", FriendsDataText, "LEFT", 0, 0)
	FriendsDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\player.blp")
	FriendsDataText.Texture:SetSize(24, 24)
	FriendsDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	FriendsDataText.Text = FriendsDataText:CreateFontString(nil, "ARTWORK")
	FriendsDataText.Text:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	FriendsDataText.Text:SetPoint("LEFT", FriendsDataText.Texture, "RIGHT", 0, 0)

	for _, event in pairs(eventList) do
		FriendsDataText:RegisterEvent(event)
	end

	FriendsDataText:SetScript("OnEvent", OnEvent)
	FriendsDataText:SetScript("OnMouseUp", OnMouseUp)
	FriendsDataText:SetScript("OnEnter", OnEnter)
	FriendsDataText:SetScript("OnLeave", OnLeave)

	K.Mover(FriendsDataText, "FriendsDataText", "FriendsDataText", {"LEFT", UIParent, "LEFT", 4, -270})
end