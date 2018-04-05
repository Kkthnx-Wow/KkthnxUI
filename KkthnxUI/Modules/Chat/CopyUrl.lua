local K, C, L = unpack(select(2, ...))
if C["Chat"].Enable ~= true then return end
local Module = K:NewModule("ChatURLCopy", "AceHook-3.0")
local Dialog = LibStub("LibDialog-1.0")

-- Lua API
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match
local string_sub = string.sub
local unpack = unpack

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ChatEdit_ChooseBoxForSend, ChatEdit_ActivateChat

local FindURL_Events = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_EMOTE",
}

function Module:PrintURL(url)
	if C["Chat"].LinkBrackets then
		url = K.RGBToHex(unpack(C["Chat"].LinkColor or {0.08, 1, 0.36})).."|Hurl:"..url.."|h["..url.."]|h|r "
	else
		url = K.RGBToHex(unpack(C["Chat"].LinkColor or {0.08, 1, 0.36})).."|Hurl:"..url.."|h"..url.."|h|r "
	end

	return url
end

function Module:FindURL(event, msg, ...)
	local text, tag = msg, string_match(msg, "{(.-)}")
	if tag and _G.ICON_TAG_LIST[string_lower(tag)] then
		text = string_gsub(string_gsub(text, "(%S)({.-})", '%1 %2'), "({.-})(%S)", "%1 %2")
	end

	text = string_gsub(string_gsub(text, "(%S)(|c.-|H.-|h.-|h|r)", '%1 %2'), "(|c.-|H.-|h.-|h|r)(%S)", "%1 %2")

	local NewMsg, Found = string_gsub(text, "(%a+)://(%S+)%s?", Module:PrintURL("%1://%2"))
	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = string_gsub(text, "www%.([_A-Za-z0-9-]+)%.(%S+)%s?", Module:PrintURL("www.%1.%2"))
	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = string_gsub(text, "([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", Module:PrintURL("%1@%2%3%4"))
	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = string_gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)(:%d+)%s?", Module:PrintURL("%1.%2.%3.%4%5"))
	if (Found > 0) then
		return false, NewMsg, ...
	end

	NewMsg, Found = string_gsub(text, "(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", Module:PrintURL("%1.%2.%3.%4"))
	if (Found > 0) then
		return false, NewMsg, ...
	end
end

local function HyperLinkedSQU(data)
	if string_sub(data, 1, 3) == "squ" then
		if not QuickJoinFrame:IsShown() then
			ToggleQuickJoinPanel()
		end
		local guid = string_sub(data, 5)
		if guid and guid ~= "" then
			QuickJoinFrame:SelectGroup(guid)
			QuickJoinFrame:ScrollToGroup(guid)
		end
		return
	end
end

local function HyperLinkedURL(data)
	if string_sub(data, 1, 3) == "url" then
		local CurrentLink = string_sub(data, 5)
		if CurrentLink and CurrentLink ~= "" then
			if Dialog:ActiveDialog("URLCopy") then
				Dialog:Dismiss("URLCopy")
			end
			Dialog:Spawn("URLCopy", {url = CurrentLink})
		end
		return
	end
end

local SetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(data, ...)
	if string_sub(data, 1, 3) == "squ" then
		HyperLinkedSQU(data)
	elseif string_sub(data, 1, 3) == "url" then
		HyperLinkedURL(data)
	else
		SetHyperlink(self, data, ...)
	end
end

function Module:OnInitialize()
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
			{text = _G.CLOSE,},
		},
		show_while_dead = true,
		hide_on_escape = true,
	})

	if WIM then
		WIM.RegisterWidgetTrigger("chat_display", "whisper, chat, w2w, demo", "OnHyperlinkClick", function(self)
			Module.clickedframe = self
		end)
		WIM.RegisterItemRefHandler("url", HyperLinkedURL)
		WIM.RegisterItemRefHandler("squ", HyperLinkedSQU)
	end
end

function Module:OnEnable()
	for _, event in pairs(FindURL_Events) do
		ChatFrame_AddMessageEventFilter(event, Module[event] or Module.FindURL)
	end
end