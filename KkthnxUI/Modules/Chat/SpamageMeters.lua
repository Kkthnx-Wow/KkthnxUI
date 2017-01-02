local K, C, L = unpack(select(2, ...))
if C.Chat.Enable ~= true or C.Chat.DamageMeterSpam ~= true then return end

-- Lua API
local ipairs = ipairs
local match = string.match
local time = time
local format = string.format
local tonumber = tonumber

-- Wow API
local strsplit = strsplit
local UIParent = UIParent

-- MERGE DAMAGE METER SPAM(SPAMAGEMETERS BY WRUG AND CYBEY)
local firstLines = {
	"^Recount - (.*)$", 									-- Recount
	"^Skada: (.*) for (.*):$",								-- Skada enUS
	"^Skada: (.*) für (.*):$",								-- Skada deDE
	"^Skada: (.*) pour (.*):$",								-- Skada frFR
	"^Отчёт Skada: (.*), с (.*):$",							-- Skada ruRU
	"^Skada: (.*) por (.*):$",								-- Skada esES/ptBR
	"^Skada: (.*) per (.*):$",								-- Skada itIT
	"^(.*) 의 Skada 보고 (.*):$",							-- Skada koKR
	"^Skada报告(.*)的(.*):$",								-- Skada zhCN
	"^Skada:(.*)來自(.*):$",								-- Skada zhTW
	"^(.*) Done for (.*)$",									-- TinyDPS enUS
	"^(.*) für (.*)$",										-- TinyDPS deDE
	"데미지량 -(.*)$",										-- TinyDPS koKR
	"힐량 -(.*)$",											-- TinyDPS koKR
	"Урон:(.*)$",											-- TinyDPS ruRU
	"Исцеление:(.*)$",										-- TinyDPS ruRU
	"^Numeration: (.*) - (.*)$",							-- Numeration
	"alDamageMeter : (.*)$",								-- alDamageMeter
	"^Details! Report for (.*)$"							-- Details!
}

local nextLines = {
	"^(%d+)\. (.*)$",										-- Recount, Details! and Skada
	"^(.*) (.*)$",										-- Additional Skada
	"^[+-]%d+.%d",											-- Numeration deathlog details
	"^(%d+). (.*):(.*)(%d+)(.*)(%d+)%%(.*)%((%d+)%)$"		-- TinyDPS
}

local meters = {}

local events = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL"
}

local function FilterLine(event, source, message, ...)
	local spam = false
	for k, v in ipairs(nextLines) do
		if message:match(v) then
			local curTime = time()
			for i, j in ipairs(meters) do
				local elapsed = curTime - j.time
				if j.source == source and j.event == event and elapsed < 1 then
					local toInsert = true
					for a, b in ipairs(j.data) do
						if b == message then
							toInsert = false
						end
					end

					if toInsert then
						table.insert(j.data, message)
					end
					return true, false, nil
				end
			end
		end
	end

	for k, v in ipairs(firstLines) do
		local newID = 0
		if message:match(v) then
			local curTime = time()

			for i, j in ipairs(meters) do
				local elapsed = curTime - j.time
				if j.source == source and j.event == event and elapsed < 1 then
					newID = i
					return true, true, format("|HMergeSpamMeter:%1$d|h|cffffff00[%2$s]|r|h", newID or 0, message or "nil")
				end
			end

			table.insert(meters, {source = source, event = event, time = curTime, data = {}, title = message})

			for i, j in ipairs(meters) do
				if j.source == source and j.event == event and j.time == curTime then
					newID = i
				end
			end

			return true, true, format("|HMergeSpamMeter:%1$d|h|cffffff00[%2$s]|r|h", newID or 0, message or "nil")
		end
	end
	return false, false, nil
end

local orig2 = SetItemRef
function SetItemRef(link, text, button, frame)
	local linkType, id = strsplit(":", link)
	if linkType == "MergeSpamMeter" then
		local meterID = tonumber(id)
		ShowUIPanel(ItemRefTooltip)
		if not ItemRefTooltip:IsShown() then
			ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
		end
		ItemRefTooltip:ClearLines()
		ItemRefTooltip:AddLine(meters[meterID].title)
		ItemRefTooltip:AddLine(format(BY_SOURCE..": %s", meters[meterID].source))
		for k, v in ipairs(meters[meterID].data) do
			local left, right = v:match("^(.*) (.*)$")
			if left and right then
				ItemRefTooltip:AddDoubleLine(left, right, 1, 1, 1, 1, 1, 1)
			else
				ItemRefTooltip:AddLine(v, 1, 1, 1)
			end
		end
		ItemRefTooltip:Show()
	else
		return orig2(link, text, button, frame)
	end
end

local function ParseChatEvent(self, event, message, sender, ...)
	for _, value in ipairs(events) do
		if event == value then
			local isRecount, isFirstLine, newMessage = FilterLine(event, sender, message)
			if isRecount then
				if isFirstLine then
					return false, newMessage, sender, ...
				else
					return true
				end
			end
		end
	end
end

for _, event in pairs(events) do
	ChatFrame_AddMessageEventFilter(event, ParseChatEvent)
end