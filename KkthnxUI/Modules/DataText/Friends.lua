local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local table_wipe = _G.table.wipe
local table_sort = _G.table.sort
local string_format = _G.string.format

local AVAILABLE = _G.AVAILABLE
local BNET_CLIENT_COD = _G.BNET_CLIENT_COD
local BNET_CLIENT_D3 = _G.BNET_CLIENT_D3
local BNET_CLIENT_DESTINY2 = _G.BNET_CLIENT_DESTINY2
local BNET_CLIENT_HEROES = _G.BNET_CLIENT_HEROES
local BNET_CLIENT_OVERWATCH = _G.BNET_CLIENT_OVERWATCH
local BNET_CLIENT_SC = _G.BNET_CLIENT_SC
local BNET_CLIENT_SC2 = _G.BNET_CLIENT_SC2
local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW
local BNET_CLIENT_WTCG = _G.BNET_CLIENT_WTCG
local BNGetNumFriends = _G.BNGetNumFriends
local BN_BROADCAST_TOOLTIP = _G.BN_BROADCAST_TOOLTIP
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local C_BattleNet_GetFriendAccountInfo = _G.C_BattleNet.GetFriendAccountInfo
local GameTooltip = _G.GameTooltip
local GetFriendInfo = _G.GetFriendInfo
local GetLocale = _G.GetLocale
local GetNumFriends = _G.GetNumFriends
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetRealZoneText = _G.GetRealZoneText
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsChatAFK = _G.IsChatAFK
local IsChatDND = _G.IsChatDND
local LOCALIZED_CLASS_NAMES_FEMALE = _G.LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local SendChatMessage = _G.SendChatMessage
local UIErrorsFrame = _G.UIErrorsFrame
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid

-- Social Datatext MODULE TEST
local totalFriendsOnline = 0
local totalBattleNetOnline = 0
local BNTable = {}
local friendTable = {}
local BNTableEnter = {}

local menuFrame = CreateFrame("Frame", "ContactDropDownMenu", UIParent, "UIDropDownMenuTemplate")
local menuList = {
	{text = _G.OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = _G.INVITE, hasArrow = true, notCheckable = true},
	{text = _G.CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true},
	{text = _G.PLAYER_STATUS, hasArrow = true, notCheckable = true,
		menuList = {
			{text = "|cff2BC226"..AVAILABLE.."|r", notCheckable = true, func = function()
					if IsChatAFK() then
						SendChatMessage("", "AFK")
					elseif IsChatDND() then
						SendChatMessage("", "DND")
					end
			end},

			{text = "|cffE7E716".._G.DND.."|r", notCheckable = true, func = function()
					if not IsChatDND() then
						SendChatMessage("", "DND")
					end
			end},

			{text = "|cffFF0000".._G.AFK.."|r", notCheckable=true, func = function()
					if not IsChatAFK() then
						SendChatMessage("", "AFK")
					end
			end},
		},
	},
	{text = BN_BROADCAST_TOOLTIP, notCheckable = true, func = function()
			K.StaticPopup_Show("SET_BN_BROADCAST")
	end},
}
local function BuildFriendTable(total)
	totalFriendsOnline = 0
	table_wipe(friendTable)

	for i = 1, total do
		local name, level, class, area, connected, status, note = GetFriendInfo(i)
		for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			if class == v then
				class = k
			end
		end

		if GetLocale() ~= "enUS" then
			for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
				if class == v then
					class = k
				end
			end
		end

		friendTable[i] = {name, level, class, area, connected, status, note}
		if connected then
			totalFriendsOnline = totalFriendsOnline + 1
		end
	end

	table_sort(friendTable, function(a, b)
		if a[1] and b[1] then
			return a[1] < b[1]
		end
	end)
end

local function BuildBNTable(total)
	totalBattleNetOnline = 0
	table_wipe(BNTable)

	for i = 1, total do
		local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
		local class = accountInfo.gameAccountInfo.className
		for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			if class == v then
				class = k
			end
		end

		if GetLocale() ~= "enUS" then
			for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
				if class == v then
					class = k
				end
			end
		end

		BNTable[i] = {accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.gameAccountID, accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isOnline, accountInfo.isAFK, accountInfo.isDND, accountInfo.note, accountInfo.gameAccountInfo.realmName, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.raceName, class, accountInfo.gameAccountInfo.areaName, accountInfo.gameAccountInfo.characterLevel}
		if accountInfo.gameAccountInfo.isOnline then
			totalBattleNetOnline = totalBattleNetOnline + 1
		end
	end
end

local clientTags = {
	[BNET_CLIENT_D3] = "Diablo 3",
	[BNET_CLIENT_WTCG] = "Hearthstone",
	[BNET_CLIENT_HEROES] = "Heroes of the Storm",
	[BNET_CLIENT_OVERWATCH] = "Overwatch",
	[BNET_CLIENT_SC] = "StarCraft",
	[BNET_CLIENT_SC2] = "StarCraft 2",
	[BNET_CLIENT_DESTINY2] = "Destiny 2",
	[BNET_CLIENT_COD] = "Call of Duty: Black Ops 4",
	["BSAp"] = "|TInterface\\CHATFRAME\\UI-ChatIcon-Battlenet:16:16:0:-1|t"
}

local function OnEvent(_, event)
	if event ~= "GROUP_ROSTER_UPDATE" then
		local _, numBNetOnline = BNGetNumFriends()
		local online, total = 0, GetNumFriends()
		for i = 0, total do
			if select(5, GetFriendInfo(i)) then
				online = online + 1
			end
		end
		online = online + numBNetOnline
		Module.SocialFont:SetText(string_format("%d", online))
	end

	if Module.isHovered then
		Module.SocialFrame:GetScript("OnEnter")(Module.SocialFrame)
	end
end

local function OnUpdate()
	if not Module.isHovered then
		return
	end

	if IsAltKeyDown() and not Module.IsAltKeyDown then
		Module.IsAltKeyDown = true
		Module.SocialFrame:GetScript("OnEnter")(Module.SocialFrame)
	elseif not IsAltKeyDown() and Module.IsAltKeyDown then
		Module.IsAltKeyDown = false
		Module.SocialFrame:GetScript("OnEnter")(Module.SocialFrame)
	end
end

local function OnClick(self, b)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
		return
	end

	if b == "MiddleButton" then
		ToggleIgnorePanel()
	elseif b == "LeftButton" then
		ToggleFriendsFrame(1)
	elseif b == "RightButton" then
		GameTooltip:Hide()
		Module.isHovered = false

		local BNTotal = BNGetNumFriends()
		local total = GetNumFriends()
		BuildBNTable(BNTotal)
		BuildFriendTable(total)

		local classc, levelc, grouped
		local menuCountWhispers = 0
		local menuCountInvites = 0

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		if totalFriendsOnline > 0 then
			for i = 1, #friendTable do
				if friendTable[i][5] then
					if UnitInParty(friendTable[i][1]) or UnitInRaid(friendTable[i][1]) then
						grouped = " |cffaaaaaa*|r"
					else
						grouped = ""
					end

					classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[friendTable[i][3]], GetQuestDifficultyColor(friendTable[i][2])
					if classc == nil then
						classc = GetQuestDifficultyColor(friendTable[i][2])
					end

					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {
						text = string_format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r%s", levelc.r * 255, levelc.g * 255, levelc.b * 255, friendTable[i][2], classc.r * 255, classc.g * 255, classc.b * 255, friendTable[i][1], grouped),
						arg1 = friendTable[i][1],
						notCheckable = true,
						func = function(_, arg1)
							menuFrame:Hide()
							SetItemRef("player:"..arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton")
						end
					}

					if not (UnitInParty(friendTable[i][1]) or UnitInRaid(friendTable[i][1])) then
						menuCountInvites = menuCountInvites + 1
						menuList[2].menuList[menuCountInvites] = {
							text = string_format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r", levelc.r * 255, levelc.g * 255, levelc.b * 255, friendTable[i][2], classc.r * 255, classc.g * 255, classc.b * 255, friendTable[i][1]),
							arg1 = friendTable[i][1],
							notCheckable = true,
							func = function(_, arg1)
								menuFrame:Hide()
								InviteUnit(arg1)
							end
						}
					end
				end
			end
		end

		if totalBattleNetOnline > 0 then
			for i = 1, #BNTable do
				if BNTable[i][7] then
					if UnitInParty(BNTable[i][4]) or UnitInRaid(BNTable[i][4]) then
						grouped = " |cffaaaaaa*|r"
					else
						grouped = ""
					end

					menuCountWhispers = menuCountWhispers + 1
					menuList[3].menuList[menuCountWhispers] = {
						text = BNTable[i][2]..grouped,
						arg1 = BNTable[i][2],
						notCheckable = true,
						func = function(_, arg1)
							menuFrame:Hide()
							ChatFrame_SendBNetTell(arg1)
						end
					}

					if BNTable[i][6] == BNET_CLIENT_WOW and K.Faction == BNTable[i][12] then
						if not (UnitInParty(BNTable[i][4]) or UnitInRaid(BNTable[i][4])) then
							classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[BNTable[i][14]], GetQuestDifficultyColor(BNTable[i][16])
							if classc == nil then
								classc = GetQuestDifficultyColor(BNTable[i][16])
							end

							menuCountInvites = menuCountInvites + 1
							menuList[2].menuList[menuCountInvites] = {
								text = string_format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r", levelc.r * 255, levelc.g * 255, levelc.b * 255, BNTable[i][16], classc.r * 255, classc.g * 255, classc.b * 255, BNTable[i][4]),
								arg1 = BNTable[i][5],
								notCheckable = true,
								func = function(_, arg1)
									menuFrame:Hide()
									BNInviteFriend(arg1)
								end
							}
						end
					end
				end
			end
		end

		EasyMenu(menuList, menuFrame, self, 0, 0, "MENU")
	end
end

local function OnEnter()
	ShowFriends()
	Module.isHovered = true

	local online, total = 0, GetNumFriends()
	local name, level, class, zone, connected, status, note, classc, levelc, zone_r, zone_g, zone_b, grouped, realm_r, realm_g, realm_b
	for i = 0, total do
		if select(5, GetFriendInfo(i)) then
			online = online + 1
		end
	end

	local BNonline, BNtotal = 0, BNGetNumFriends()
	table_wipe(BNTableEnter)
	if BNtotal > 0 then
		for i = 1, BNtotal do
			local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
			BNTableEnter[i] = {accountInfo, accountInfo.gameAccountInfo.clientProgram}
			if accountInfo.gameAccountInfo.isOnline then
				BNonline = BNonline + 1
			end
		end
	end

	local totalonline = online + BNonline
	local totalfriends = total + BNtotal
	if online > 0 or BNonline > 0 then
		GameTooltip:SetOwner(Module.SocialFrame, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(Module.SocialFrame))
		GameTooltip:ClearLines()

		GameTooltip:AddLine("|cffffffff".."Social".."|r".." (O)")
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(K.InfoColor..FRIENDS_LIST, string_format("%s: %s/%s", K.InfoColor..GUILD_ONLINE_LABEL, totalonline, totalfriends))
		if online > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(WOW_FRIEND)
			for i = 1, total do
				name, level, class, zone, connected, status, note = GetFriendInfo(i)
				if not connected then
					break
				end

				if GetRealZoneText() == zone then
					zone_r, zone_g, zone_b = 0.3, 1.0, 0.3
				else
					zone_r, zone_g, zone_b = 0.65, 0.65, 0.65
				end

				for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
					if class == v then
						class = k
					end
				end

				if GetLocale() ~= "enUS" then
					for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
				end

				classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
				if not classc then
					classc = {r = 1, g = 1, b = 1}
				end

				grouped = (UnitInParty(name) or UnitInRaid(name)) and (GetRealZoneText() == zone and " |cff7fff00*|r" or " |cffff7f00*|r") or ""
				GameTooltip:AddDoubleLine(string_format("|cff%02x%02x%02x%d|r %s%s%s", levelc.r * 255, levelc.g * 255, levelc.b * 255, level, name, grouped, " "..status), zone, classc.r, classc.g, classc.b, zone_r, zone_g, zone_b)
				if Module.IsAltKeyDown and note then
					GameTooltip:AddLine(K.InfoColor.." "..note)
				end
			end
		end

		if BNonline > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(BATTLENET_FRIEND)
			for i = 1, #BNTableEnter do
				local accountInfo = BNTableEnter[i][1]
				local isOnline = accountInfo.gameAccountInfo.isOnline
				local client = accountInfo.gameAccountInfo.clientProgram
				if isOnline then
					if client == BNET_CLIENT_WOW then
						if accountInfo.isAFK then
							status = "|TInterface\\FriendsFrame\\StatusIcon-Away:16:16:0:-1|t"
						else
							if accountInfo.isDND then
								status = "|TInterface\\FriendsFrame\\StatusIcon-DnD:16:16:0:-1|t"
							else
								status = ""
							end
						end

						local characterName = accountInfo.gameAccountInfo.characterName
						local realmName = accountInfo.gameAccountInfo.realmName
						local class = accountInfo.gameAccountInfo.className
						local areaName = accountInfo.gameAccountInfo.areaName
						local level = accountInfo.gameAccountInfo.characterLevel

						for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
							if class == v then
								class = k
							end
						end

						if GetLocale() ~= "enUS" then
							for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
								if class == v then
									class = k
								end
							end
						end

						classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
						if not classc then
							classc = {r = 1, g = 1, b = 1}
						end

						if UnitInParty(characterName) or UnitInRaid(characterName) then
							grouped = " |cffaaaaaa*|r"
						else
							grouped = ""
						end

						if accountInfo.gameAccountInfo.factionName ~= K.Faction then
							grouped = " |cffff0000*|r"
						end
						GameTooltip:AddDoubleLine(string_format("%s (|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r%s) |cff%02x%02x%02x%s|r", client, levelc.r * 255, levelc.g * 255, levelc.b * 255, level, classc.r * 255, classc.g * 255, classc.b * 255, characterName, grouped, 255, 0, 0, status), accountInfo.accountName, 238, 238, 238, 238, 238, 238)
						if Module.IsAltKeyDown then
							if GetRealZoneText() == zone then
								zone_r, zone_g, zone_b = 0.3, 1.0, 0.3
							else
								zone_r, zone_g, zone_b = 0.65, 0.65, 0.65
							end

							if K.Realm == realmName then
								realm_r, realm_g, realm_b = 0.3, 1.0, 0.3
							else
								realm_r, realm_g, realm_b = 0.65, 0.65, 0.65
							end
							GameTooltip:AddDoubleLine(" "..areaName, realmName, zone_r, zone_g, zone_b, realm_r, realm_g, realm_b)
						end
					else
						if client == "App" then
							client = "|TInterface\\CHATFRAME\\UI-ChatIcon-Battlenet:16:16:0:-1|t" or accountInfo.gameAccountInfo.richPresence
						else
							client = clientTags[client] or ""
						end

						if accountInfo.gameAccountInfo.isGameAFK then
							status = "|TInterface\\FriendsFrame\\StatusIcon-Away:16:16:0:-1|t"
						else
							if accountInfo.gameAccountInfo.isGameBusy then
								status = "|TInterface\\FriendsFrame\\StatusIcon-DnD:16:16:0:-1|t"
							else
								status = ""
							end
						end
						GameTooltip:AddDoubleLine("|cffeeeeee"..accountInfo.accountName.."|r".." "..status, "|cffeeeeee"..client.."|r")
					end
				end
			end
		end
		GameTooltip:Show()
	else
		GameTooltip:Hide()
		Module.isHovered = false
	end
end

local function OnLeave()
	GameTooltip:Hide()
	Module.isHovered = false
end

function Module:CreateSocialDataText()
	if not C["DataText"].Friends then
		return
	end

	local SocialFramePos
	if C["Chat"].Background then
		SocialFramePos = {"BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", -4, 20}
	else
		SocialFramePos = {"BOTTOMLEFT", ChatFrame1Tab, "TOPLEFT", 2, 20}
	end

	Module.SocialFrame = CreateFrame("Button", nil, UIParent)
	Module.SocialFrame:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
	Module.SocialFrame:SetPoint(unpack(SocialFramePos))
	Module.SocialFrame:SetSize(20, 20)
	if C["Chat"].Background then
		Module.SocialFrame:CreateBorder()
		Module.SocialFrame:CreateInnerShadow()
		Module.SocialFrame:StyleButton()
	end

	Module.SocialTexture = Module.SocialFrame:CreateTexture(nil, "BACKGROUND")
	Module.SocialTexture:SetTexture("Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon")
	Module.SocialTexture:SetVertexColor(255/255, 211/255, 0/255)
	Module.SocialTexture:SetPoint("CENTER", Module.SocialFrame, "CENTER")
	Module.SocialTexture:SetSize(32, 32)

	Module.SocialFont = Module.SocialFrame:CreateFontString('OVERLAY')
	Module.SocialFont:FontTemplate(nil, 11, "OUTLINE")
	Module.SocialFont:SetPoint("CENTER", Module.SocialFrame, "CENTER", 0, -3)

	K:RegisterEvent("PLAYER_ENTERING_WORLD", OnEvent)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", OnEvent)
	K:RegisterEvent("FRIENDLIST_UPDATE", OnEvent)
	K:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE", OnEvent)
	K:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE", OnEvent)
	K:RegisterEvent("BN_FRIEND_INFO_CHANGED", OnEvent)

	Module.SocialFrame:SetScript("OnClick", OnClick)
	Module.SocialFrame:SetScript("OnEvent", OnEvent)
	Module.SocialFrame:SetScript("OnUpdate", OnUpdate)
	Module.SocialFrame:SetScript("OnEnter", OnEnter)
	Module.SocialFrame:SetScript("OnLeave", OnLeave)
end