local K, C, L = unpack(select(2, ...))
if C["Chat"].Enable ~= true then return end
local Dialog = LibStub("LibDialog-1.0")

-- Lua API
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match
local string_sub = string.sub

local unpack = _G.unpack

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat

Dialog:Register("URLCopy", {
	text = "URL Copy",
	width = 340,
	editboxes = {
		{width = 318,
			on_escape_pressed = function(self, data)
				self:GetParent():Hide()
			end,
		},
	},
	on_show = function(self, data)
		self.editboxes[1]:SetText(data.url)
		self.editboxes[1]:HighlightText()
		self.editboxes[1]:SetFocus()
	end,
	buttons = {
		{text = CLOSE,},
	},
	show_while_dead = true,
	hide_on_escape = true,
})

local function PrintURL(url)
	if C["Chat"].LinkBrackets then
		url = K.RGBToHex(unpack(C["Chat"].LinkColor or {0.08, 1, 0.36})).."|Hurl:"..url.."|h["..url.."]|h|r "
	else
		url = K.RGBToHex(unpack(C["Chat"].LinkColor or {0.08, 1, 0.36})).."|Hurl:"..url.."|h"..url.."|h|r "
	end

	return url
end

local function FindURL(self, event, msg, ...)
	local text, tag = msg, string_match(msg, "{(.-)}")
	if tag and _G.ICON_TAG_LIST[string_lower(tag)] then
		text = string_gsub(string_gsub(text, "(%S)({.-})", '%1 %2'), "({.-})(%S)", "%1 %2")
	end

	text = string_gsub(string_gsub(text, "(%S)(|c.-|H.-|h.-|h|r)", '%1 %2'), "(|c.-|H.-|h.-|h|r)(%S)", "%1 %2")

	local NewMsg, Found = string_gsub(text, "(%a+)://(%S+)%s?", PrintURL("%1://%2"))

	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = string_gsub(text, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", PrintURL("www.%1.%2"))

	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = string_gsub(text, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", PrintURL("%1@%2%3%4"))

	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = string_gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)(:%d+)%s?", PrintURL("%1.%2.%3.%4%5"))

	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = string_gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", PrintURL("%1.%2.%3.%4"))

	if (Found > 0) then
		return false, NewMsg, ...
	end
end

ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_BROADCAST", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD_ACHIEVEMENT", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", FindURL)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", FindURL)

local CurrentLink = nil
local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip.SetHyperlink(self, data, ...)
	if (string_sub(data, 1, 3) == "url") then
		CurrentLink = (data):sub(5)

		if Dialog:ActiveDialog("URLCopy") then
			Dialog:Dismiss("URLCopy")
		end
		Dialog:Spawn("URLCopy", {url = CurrentLink})

		CurrentLink = nil
	elseif (string_sub(data, 1, 3) == "squ") then
		if not QuickJoinFrame:IsShown() then
			ToggleQuickJoinPanel()
		end

		local guid = (data):sub(5)
		if guid and guid ~= "" then
			QuickJoinFrame:SelectGroup(guid)
			QuickJoinFrame:ScrollToGroup(guid)
		end
	else
		SetHyperlink(self, data, ...)
	end
end