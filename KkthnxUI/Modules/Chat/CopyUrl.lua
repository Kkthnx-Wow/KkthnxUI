local K, C, L, _ = select(2, ...):unpack()

-- LUA API
local pairs = pairs
local match = string.match
local gsub = string.gsub
local sub = string.sub

-- COPY URL FROM CHAT(MODULE FROM GIBBERISH BY P3LIM)
local patterns = {
	-- X://Y url
	"^(%a[%w%.+-]+://%S+)",
	"%f[%S](%a[%w%.+-]+://%S+)",
	-- www.X.Y url
	"^(www%.[-%w_%%]+%.%S+)",
	"%f[%S](www%.[-%w_%%]+%.%S+)",
	-- X.Y.Z/WWWWW url with path
	"^([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)",
	"%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)",
	-- X.Y.Z url
	"^([-%w_%%%.]+[-%w_%%]%.(%a%a+))",
	"%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+))",
	-- X@Y.Z email
	"(%S+@[-%w_%%%.]+%.(%a%a+))",
	-- X.Y.Z:WWWW/VVVVV url with port and path
	"^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)",
	"%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)",
	-- X.Y.Z:WWWW url with port
	"^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]",
	"%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]",
	-- XXX.YYY.ZZZ.WWW:VVVV/UUUUU IPv4 address with port and path
	"^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)",
	"%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)",
	-- XXX.YYY.ZZZ.WWW:VVVV IPv4 address with port (IP of ts server for example)
	"^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]",
	"%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]",
	-- XXX.YYY.ZZZ.WWW/VVVVV IPv4 address with path
	"^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)",
	"%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)",
	-- XXX.YYY.ZZZ.WWW IPv4 address
	"^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]",
	"%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]",
}

for _, event in pairs({
	"CHAT_MSG_BN_CONVERSATION",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_DUNGEON_GUIDE",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_GUIDE",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL"
}) do
	ChatFrame_AddMessageEventFilter(event, function(self, event, str, ...)
		for _, pattern in pairs(patterns) do
			local result, match = gsub(str, pattern, "|cff00FF00|Hurl:%1|h[%1]|h|r")
			if match > 0 then
				return false, result, ...
			end
		end
	end)
end

local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
function _G.ItemRefTooltip:SetHyperlink(link, ...)
	if link and (strsub(link, 1, 3) == "url") then
		local url = strsub(link, 5)

		local editbox = ChatEdit_ChooseBoxForSend()
		ChatEdit_ActivateChat(editbox)
		editbox:Insert(sub(link, 5))
		editbox:HighlightText()

		return
	end

	SetHyperlink(self, link, ...)
end