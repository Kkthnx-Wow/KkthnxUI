local K, C = unpack(select(2, ...))
if C["Misc"].EnhancedFriends ~= true then
	return
end

local Module = K:NewModule("FriendsListPlus", "AceEvent-3.0", "AceHook-3.0")

-- Sourced: ProjectAzilroka (Azilroka)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local format = format
local pairs = pairs
local tonumber = tonumber
local unpack = unpack

local BNConnected = _G.BNConnected
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNGetGameAccountInfo = _G.BNGetGameAccountInfo
local CanCooperateWithGameAccount = _G.CanCooperateWithGameAccount
local GetFriendInfo = _G.GetFriendInfo
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor

Module.Classes = {}

for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	Module.Classes[v] = k
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	Module.Classes[v] = k
end

local function ClassColorCode(class)
	local classColors = class and (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[Module.Classes[class]] or RAID_CLASS_COLORS[Module.Classes[class]]) or {r = 1, g = 1, b = 1}
	return format("|cFF%02x%02x%02x", classColors.r * 255, classColors.g * 255, classColors.b * 255)
end

local MediaIconPath = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\GameIcons\\"

Module.GameIcons = {
	Alliance = MediaIconPath .. "Alliance",
	App = MediaIconPath .. "BattleNet",
	BSAp = MediaIconPath .. "BattleNet",
	D3 = MediaIconPath .. "D3",
	DST2 = MediaIconPath .. "Destiny2",
	Hero = MediaIconPath .. "Heroes",
	Horde = MediaIconPath .. "Horde",
	Neutral = MediaIconPath .. "WoW",
	Pro = MediaIconPath .. "Overwatch",
	S1 = MediaIconPath .. "SC",
	S2 = MediaIconPath .. "SC2",
	WTCG = MediaIconPath .. "Hearthstone"
}

Module.StatusIcons = {
	AFK = FRIENDS_TEXTURE_AFK,
	DND = FRIENDS_TEXTURE_DND,
	Offline = FRIENDS_TEXTURE_OFFLINE,
	Online = FRIENDS_TEXTURE_ONLINE
}

Module.ClientColor = {
	App = "82C5FF",
	BSAp = "82C5FF",
	D3 = "C41F3B",
	Hero = "00CCFF",
	Pro = "FFFFFF",
	S1 = "C495DD",
	S2 = "C495DD",
	WTCG = "FFB100"
}

function Module:UpdateFriends(button)
	local nameText, nameColor, infoText, broadcastText, _, Cooperate
	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local name, level, class, area, connected, status = GetFriendInfo(button.id)
		broadcastText = nil
		if connected then
			button.status:SetTexture(Module.StatusIcons[(status == CHAT_FLAG_DND and "DND" or status == CHAT_FLAG_AFK and "AFK" or "Online")])
			nameText = format("%s%s - (%s - %s %s)", ClassColorCode(class), name, class, LEVEL, level)
			nameColor = FRIENDS_WOW_NAME_COLOR
			Cooperate = true
		else
			button.status:SetTexture(Module.StatusIcons.Offline)
			nameText = name
			nameColor = FRIENDS_GRAY_COLOR
		end
		infoText = area
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET and BNConnected() then
		local _, presenceName, battleTag, _, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText = BNGetFriendInfo(button.id)
		local realmName, _, faction, _, class, zoneName, level, gameText
		broadcastText = messageText
		local characterName = toonName
		if presenceName then
			nameText = presenceName
			if isOnline then
				characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client)
			end
		else
			nameText = UNKNOWN
		end

		if characterName then
			_, _, _, realmName, realmID, faction, race, class, _, zoneName, level, gameText = BNGetGameAccountInfo(toonID)
			if client == BNET_CLIENT_WOW then
				if (level == nil or tonumber(level) == nil) then
					level = 0
				end

				local classcolor = ClassColorCode(class)
				local diff =
				level ~= 0 and format("|cFF%02x%02x%02x", GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255 ) or "|cFFFFFFFF"
				nameText = format("%s |cFFFFFFFF(|r%s%s|r - %s %s%s|r|cFFFFFFFF)|r", nameText, classcolor, characterName, LEVEL, diff, level)
				Cooperate = CanCooperateWithGameAccount(toonID)
			else
				nameText = format("|cFF%s%s|r", Module.ClientColor[client] or "FFFFFF", nameText)
			end
		end

		if isOnline then
			button.status:SetTexture(Module.StatusIcons[(isDND and "DND" or isAFK and "AFK" or "Online")])
			if client == BNET_CLIENT_WOW then
				if not zoneName or zoneName == "" then
					infoText = UNKNOWN
				else
					if realmName == K.Realm then
						infoText = zoneName
					else
						infoText = format("%s - %s", zoneName, realmName)
					end
				end

				button.gameIcon:SetTexture(Module.GameIcons[faction])
			else
				infoText = gameText
				button.gameIcon:SetTexture(Module.GameIcons[client])
			end

			nameColor = FRIENDS_BNET_NAME_COLOR
		else
			button.status:SetTexture(Module.StatusIcons.Offline)
			nameColor = FRIENDS_GRAY_COLOR
			infoText =
			lastOnline == 0 and FRIENDS_LIST_OFFLINE or format(BNET_LAST_ONLINE_TIME, FriendsFrame_GetLastOnline(lastOnline))
		end
	end

	if button.summonButton:IsShown() then
		button.gameIcon:SetPoint("TOPRIGHT", -50, -2)
	else
		button.gameIcon:SetPoint("TOPRIGHT", -21, -2)
	end

	if nameText then
		button.name:SetText(nameText)
		button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b)
		button.info:SetText(infoText)
		button.info:SetTextColor(unpack(Cooperate and {1, .96, .45} or {.49, .52, .54}))
		button.name:SetFont(C["Media"].Font, C["Media"].FontSize, "")
		button.info:SetFont(C["Media"].Font, 11, "")
	end
end

function Module:OnInitialize()
	if C["Misc"].EnhancedFriends ~= true then
		return
	end

	self:SecureHook("FriendsFrame_UpdateFriendButton", "UpdateFriends")
end