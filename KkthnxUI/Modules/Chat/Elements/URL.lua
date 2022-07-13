local K = unpack(KkthnxUI)
local Module = K:GetModule("Chat")

local _G = _G
local string_find = _G.string.find
local string_gsub = _G.string.gsub
local string_len = _G.string.len
local string_match = _G.string.match
local string_split = _G.string.split
local string_sub = _G.string.sub
local tostring = _G.tostring

local BNInviteFriend = _G.BNInviteFriend
local C_BattleNet_GetAccountInfoByID = _G.C_BattleNet.GetAccountInfoByID
local CanCooperateWithGameAccount = _G.CanCooperateWithGameAccount
local ChatEdit_ClearChat = _G.ChatEdit_ClearChat
local InviteToGroup = _G.InviteToGroup
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsModifiedClick = _G.IsModifiedClick
local IsModifierKeyDown = _G.IsModifierKeyDown
local LAST_ACTIVE_CHAT_EDIT_BOX = _G.LAST_ACTIVE_CHAT_EDIT_BOX
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local StaticPopup_Visible = _G.StaticPopup_Visible
local hooksecurefunc = _G.hooksecurefunc

local foundurl = false
local function convertLink(text, value)
	return "|Hurl:" .. tostring(value) .. "|h" .. K.InfoColor .. text .. "|r|h"
end

local function highlightURL(_, url)
	foundurl = true

	return " " .. convertLink("[" .. url .. "]", url) .. " "
end

function Module:SearchForURL(text, ...)
	foundurl = false

	if string_find(text, "%pTInterface%p+") or string_find(text, "%pTINTERFACE%p+") then
		foundurl = true
	end

	if not foundurl then
		-- 192.168.1.1:1234
		text = string_gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", highlightURL)
	end

	if not foundurl then
		-- 192.168.1.1
		text = string_gsub(text, "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", highlightURL)
	end

	if not foundurl then
		-- www.teamspeak.com:3333
		text = string_gsub(text, "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", highlightURL)
	end

	if not foundurl then
		-- http://www.google.com
		text = string_gsub(text, "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end

	if not foundurl then
		-- www.google.com
		text = string_gsub(text, "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", highlightURL)
	end

	if not foundurl then
		-- lol@lol.com
		text = string_gsub(text, "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", highlightURL)
	end

	self.am(self, text, ...)
end

function Module:HyperlinkShowHook(link, _, button)
	local type, value = string_match(link, "(%a+):(.+)")
	local hide
	if button == "LeftButton" and IsModifierKeyDown() then
		if type == "player" then
			local unit = string_match(value, "([^:]+)")
			if IsAltKeyDown() then
				InviteToGroup(unit)
				hide = true
			elseif IsControlKeyDown() then
				GuildInvite(unit)
				hide = true
			end
		elseif type == "BNplayer" then
			local _, bnID = string_match(value, "([^:]*):([^:]*):")
			if not bnID then
				return
			end

			local accountInfo = C_BattleNet_GetAccountInfoByID(bnID)
			if not accountInfo then
				return
			end

			local gameAccountInfo = accountInfo.gameAccountInfo
			local gameID = gameAccountInfo.gameAccountID
			if gameID and CanCooperateWithGameAccount(accountInfo) then
				if IsAltKeyDown() then
					BNInviteFriend(gameID)
					hide = true
				elseif IsControlKeyDown() then
					local charName = gameAccountInfo.characterName
					local realmName = gameAccountInfo.realmName
					GuildInvite(charName .. "-" .. realmName)
					hide = true
				end
			end
		end
	elseif type == "url" then
		local eb = LAST_ACTIVE_CHAT_EDIT_BOX or _G[self:GetName() .. "EditBox"]
		if eb then
			eb:Show()
			eb:SetText(value)
			eb:SetFocus()
			eb:HighlightText()
		end
	end

	if hide then
		ChatEdit_ClearChat(ChatFrame1.editBox)
	end
end

function Module.SetItemRefHook(link, _, button)
	if string_sub(link, 1, 6) == "player" and button == "LeftButton" and IsModifiedClick("CHATLINK") then
		if not StaticPopup_Visible("ADD_IGNORE") and not StaticPopup_Visible("ADD_FRIEND") and not StaticPopup_Visible("ADD_GUILDMEMBER") and not StaticPopup_Visible("ADD_RAIDMEMBER") and not StaticPopup_Visible("CHANNEL_INVITE") and not ChatEdit_GetActiveWindow() then
			local namelink, fullname
			if string_sub(link, 7, 8) == "GM" then
				namelink = string_sub(link, 10)
			elseif string_sub(link, 7, 15) == "Community" then
				namelink = string_sub(link, 17)
			else
				namelink = string_sub(link, 8)
			end

			if namelink then
				fullname = string_split(":", namelink)
			end

			if fullname and string_len(fullname) > 0 then
				local name, server = string_split("-", fullname)
				if server and server ~= K.Realm then
					name = fullname
				end

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
	end
end

function Module:CreateCopyURL()
	for i = 1, NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame" .. i]
			chatFrame.am = chatFrame.AddMessage
			chatFrame.AddMessage = self.SearchForURL
		end
	end

	local orig = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(link, ...)
		if link and string_sub(link, 0, 3) == "url" then
			return
		end

		return orig(self, link, ...)
	end

	hooksecurefunc("ChatFrame_OnHyperlinkShow", self.HyperlinkShowHook)
	hooksecurefunc("SetItemRef", self.SetItemRefHook)
end
