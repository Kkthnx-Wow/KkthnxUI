local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("CopyURL", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")
if C["Chat"].Enable ~= true then return end

local msgList, msgCount, msgTime = {}, {}, {}
local PLAYER_REALM = gsub(K.Realm, "[%s%-]", "")
local PLAYER_NAME = K.Name.."-"..PLAYER_REALM

local hyperlinkTypes = {
	["item"] = true,
	["spell"] = true,
	["unit"] = true,
	["quest"] = true,
	["enchant"] = true,
	["achievement"] = true,
	["instancelock"] = true,
	["talent"] = true,
	["glyph"] = true,
	["currency"] = true,
}

function Module:ThrottleSound()
	self.SoundPlayed = nil
end

function Module:PrintURL(url)
	return "|cFFFFFFFF[|Hurl:"..url.."|h"..url.."|h]|r "
end

function Module:FindURL(event, msg, ...)
	local text, tag = msg, strmatch(msg, "{(.-)}")
	if tag and ICON_TAG_LIST[strlower(tag)] then
		text = gsub(gsub(text, "(%S)({.-})", "%1 %2"), "({.-})(%S)", "%1 %2")
	end

	text = gsub(gsub(text, "(%S)(|c.-|H.-|h.-|h|r)", "%1 %2"), "(|c.-|H.-|h.-|h|r)(%S)", "%1 %2")
	-- http://example.com
	local newMsg, found = gsub(text, "(%a+)://(%S+)%s?", Module:PrintURL("%1://%2"))
	if found > 0 then return false, newMsg, ... end
	-- www.example.com
	newMsg, found = gsub(text, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", Module:PrintURL("www.%1.%2"))
	if found > 0 then return false, newMsg, ... end
	-- example@example.com
	newMsg, found = gsub(text, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", Module:PrintURL("%1@%2%3%4"))
	if found > 0 then return false, newMsg, ... end
	-- IP address with port 1.1.1.1:1
	newMsg, found = gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)(:%d+)%s?", Module:PrintURL("%1.%2.%3.%4%5"))
	if found > 0 then return false, newMsg, ... end
	-- IP address 1.1.1.1
	newMsg, found = gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", Module:PrintURL("%1.%2.%3.%4"))
	if found > 0 then return false, newMsg, ... end

	return false, msg, ...
end

local function SetChatEditBoxMessage(message)
	local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
	local editBoxShown = ChatFrameEditBox:IsShown()
	local editBoxText = ChatFrameEditBox:GetText()
	if not editBoxShown then
		ChatEdit_ActivateChat(ChatFrameEditBox)
	end
	if editBoxText and editBoxText ~= "" then
		ChatFrameEditBox:SetText("")
	end
	ChatFrameEditBox:Insert(message)
	ChatFrameEditBox:HighlightText()
end

local function HyperLinkedCPL(data)
	if strsub(data, 1, 3) == "cpl" then
		local chatID = strsub(data, 5)
		local chat = _G[format("ChatFrame%d", chatID)]
		if not chat then return end
		local scale = chat:GetEffectiveScale() --blizzard does this with `scale = UIParent:GetScale()`
		local cursorX, cursorY = GetCursorPosition()
		cursorX, cursorY = (cursorX / scale), (cursorY / scale)
		local _, lineIndex = chat:FindCharacterAndLineIndexAtCoordinate(cursorX, cursorY)
		if lineIndex then
			local visibleLine = chat.visibleLines and chat.visibleLines[lineIndex]
			local message = visibleLine and visibleLine.messageInfo and visibleLine.messageInfo.message
			if message and message ~= "" then
				message = gsub(message, "|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
				message = strtrim(removeIconFromLine(message))
				SetChatEditBoxMessage(message)
			end
		end
		return
	end
end

local function HyperLinkedSQU(data)
	if strsub(data, 1, 3) == "squ" then
		if not QuickJoinFrame:IsShown() then
			ToggleQuickJoinPanel()
		end
		local guid = strsub(data, 5)
		if guid and guid ~= "" then
			QuickJoinFrame:SelectGroup(guid)
			QuickJoinFrame:ScrollToGroup(guid)
		end
		return
	end
end

local function HyperLinkedURL(data)
	if strsub(data, 1, 3) == "url" then
		local currentLink = strsub(data, 5)
		if currentLink and currentLink ~= "" then
			SetChatEditBoxMessage(currentLink)
		end
		return
	end
end

local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(data, ...)
	if strsub(data, 1, 3) == "cpl" then
		HyperLinkedCPL(data)
	elseif strsub(data, 1, 3) == "squ" then
		HyperLinkedSQU(data)
	elseif strsub(data, 1, 3) == "url" then
		HyperLinkedURL(data)
	else
		SetHyperlink(self, data, ...)
	end
end

local hyperLinkEntered
function Module:OnHyperlinkEnter(frame, refString)
	if InCombatLockdown() then return end
	local linkToken = strmatch(refString, "^([^:]+)")
	if hyperlinkTypes[linkToken] then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(frame, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(refString)
		hyperLinkEntered = frame
		GameTooltip:Show()
	end
end

function Module:OnHyperlinkLeave(frame, refString)
	if hyperLinkEntered then
		HideUIPanel(GameTooltip)
		hyperLinkEntered = nil
	end
end

function Module:EnableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if (not self.hooks or not self.hooks[frame] or not self.hooks[frame].OnHyperlinkEnter) then
			self:HookScript(frame, "OnHyperlinkEnter")
			self:HookScript(frame, "OnHyperlinkLeave")
		end
	end
end

function Module:DisableHyperlink()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if self.hooks and self.hooks[frame] and self.hooks[frame].OnHyperlinkEnter then
			self:Unhook(frame, "OnHyperlinkEnter")
			self:Unhook(frame, "OnHyperlinkLeave")
		end
	end
end

local function PrepareMessage(author, message)
	return format("%s%s", strupper(author), message)
end

function Module:CHAT_MSG_CHANNEL(event, message, author, ...)
	local blockFlag = false
	local msg = PrepareMessage(author, message)

	-- ignore player messages
	if author == PLAYER_NAME then return Module.FindURL(self, event, message, author, ...) end
	if msgList[msg] and 45 ~= 0 then
		if difftime(time(), msgTime[msg]) <= 45 then
			blockFlag = true
		end
	end

	if blockFlag then
		return true;
	else
		if 45 ~= 0 then
			msgTime[msg] = time()
		end

		return Module.FindURL(self, event, message, author, ...)
	end
end

function Module:CHAT_MSG_YELL(event, message, author, ...)
	local blockFlag = false
	local msg = PrepareMessage(author, message)

	if msg == nil then return Module.FindURL(self, event, message, author, ...) end

	-- ignore player messages
	if author == PLAYER_NAME then return Module.FindURL(self, event, message, author, ...) end
	if msgList[msg] and msgCount[msg] > 1 and 45 ~= 0 then
		if difftime(time(), msgTime[msg]) <= 45 then
			blockFlag = true
		end
	end

	if blockFlag then
		return true;
	else
		if 45 ~= 0 then
			msgTime[msg] = time()
		end

		return Module.FindURL(self, event, message, author, ...)
	end
end

function Module:CHAT_MSG_SAY(event, message, author, ...)
	return Module.FindURL(self, event, message, author, ...)
end

local FindURL_Events = {
	"CHAT_MSG_AFK",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_DND",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
}

function Module:OnInitialize()
	self:EnableHyperlink()

	if WIM then
		WIM.RegisterWidgetTrigger("chat_display", "whisper, chat, w2w, demo", "OnHyperlinkClick", function(self) Module.clickedframe = self end);
		WIM.RegisterItemRefHandler("url", HyperLinkedURL)
		WIM.RegisterItemRefHandler("squ", HyperLinkedSQU)
		WIM.RegisterItemRefHandler("cpl", HyperLinkedCPL)
	end

	for _, event in pairs(FindURL_Events) do
		ChatFrame_AddMessageEventFilter(event, Module[event] or Module.FindURL)
	end
end