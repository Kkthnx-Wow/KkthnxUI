local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Developer")

-- Buttons to enhance popup menu
function Module:MenuButton_AddFriend()
	C_FriendList.AddFriend(self.MenuButtonName)
end

function Module:MenuButton_CopyName()
	local editBox = ChatEdit_ChooseBoxForSend()
	local hasText = (editBox:GetText() ~= "")
	ChatEdit_ActivateChat(editBox)
	editBox:Insert(self.MenuButtonName)
	if not hasText then
		editBox:HighlightText()
	end
end

function Module:MenuButton_GuildInvite()
	GuildInvite(self.MenuButtonName)
end

function Module:MenuButton_Whisper()
	ChatFrame_SendTell(self.MenuButtonName)
end

function Module:OnEnable()
	local menuList = {
		{ text = ADD_FRIEND, func = "MenuButton_AddFriend", color = { 0, 0.6, 1 } },
		{ text = gsub(CHAT_GUILD_INVITE_SEND, HEADER_COLON, ""), func = "MenuButton_GuildInvite", color = { 0, 0.8, 0 } },
		{ text = COPY_NAME, func = "MenuButton_CopyName", color = { 1, 0, 0 } },
		{ text = WHISPER, func = "MenuButton_Whisper", color = { 1, 0.5, 1 } },
	}

	local frame = CreateFrame("Frame", "KKUI_MenuButtonFrame", DropDownList1)
	frame:SetSize(10, 10)
	frame:SetPoint("TOPLEFT")
	frame:Hide()

	for i, menuItem in ipairs(menuList) do
		local button = CreateFrame("Button", nil, frame)
		button:SetSize(25, 10)
		button:SetPoint("TOPLEFT", frame, i * 28, -4)
		button.Icon = button:CreateTexture(nil, "ARTWORK")
		button.Icon:SetAllPoints()
		button.Icon:SetColorTexture(unpack(menuItem.color))
		button:SetScript("OnClick", function()
			Module[menuItem.func](Module)
		end)
		K.AddTooltip(button, "ANCHOR_TOP", menuItem.text)
	end

	hooksecurefunc("ToggleDropDownMenu", function(level, _, dropdownMenu)
		if level and level > 1 then
			return
		end

		local name = dropdownMenu.name
		local unit = dropdownMenu.unit
		local isPlayer = unit and UnitIsPlayer(unit)
		local isFriendMenu = dropdownMenu == FriendsDropDown -- menus on FriendsFrame
		if not name or (not isPlayer and not dropdownMenu.chatType and not isFriendMenu) then
			frame:Hide()
			return
		end

		local gameAccountInfo = dropdownMenu.accountInfo and dropdownMenu.accountInfo.gameAccountInfo
		if gameAccountInfo and gameAccountInfo.characterName then
			Module.MenuButtonName = gameAccountInfo.characterName
		else
			Module.MenuButtonName = name
		end
		frame:Show()
	end)
end

K.Devs = {
	["Kkthnx-Valdrakken"] = true,
	["Informant-Valdrakken"] = true,
	-- Fenox Temp
	["Trittlendy-Valdrakken"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper

if not K.isDeveloper() then
	return
end
