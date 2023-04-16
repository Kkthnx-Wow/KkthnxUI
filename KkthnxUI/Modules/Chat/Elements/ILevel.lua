local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local pairs = pairs
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep

local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local DUNGEON_SCORE_LEADER = DUNGEON_SCORE_LEADER
local GetItemInfo = GetItemInfo
local GetItemStats = GetItemStats

local itemCache = {}

local socketWatchList = {
	["BLUE"] = true,
	["RED"] = true,
	["YELLOW"] = true,
	["COGWHEEL"] = true,
	["HYDRAULIC"] = true,
	["META"] = true,
	["PRISMATIC"] = true,
	["PUNCHCARDBLUE"] = true,
	["PUNCHCARDRED"] = true,
	["PUNCHCARDYELLOW"] = true,
	["DOMINATION"] = true,
	["PRIMORDIAL"] = true,
}

-- Show itemlevel on chat hyperlinks
local function isItemHasLevel(link)
	local name, _, rarity, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
	if name and level and rarity > 1 and (classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor) then
		local itemLevel = K.GetItemLevel(link)
		return name, itemLevel
	end
end

local function GetSocketTexture(socket, count)
	return string_rep("|TInterface\\ItemSocketingFrame\\UI-EmptySocket-" .. socket .. ":0|t", count)
end

function Module.IsItemHasGem(link)
	local text = ""
	local stats = GetItemStats(link)
	if stats then
		for stat, count in pairs(stats) do
			local socket = string_match(stat, "EMPTY_SOCKET_(%S+)")
			if socket and socketWatchList[socket] then
				if socket == "PRIMORDIAL" then -- primordial texture is missing, use meta instead, needs review
					socket = "META"
				end
				text = text .. GetSocketTexture(socket, count)
			end
		end
	end

	return text
end

local function convertItemLevel(link)
	if not link then
		return
	end

	if itemCache[link] then
		return itemCache[link]
	end

	local name, itemLevel = isItemHasLevel(link)
	if name and itemLevel then
		link = string_gsub(link, "|h%[(.-)%]|h", "|h[" .. name .. "(" .. itemLevel .. ")]|h" .. Module.IsItemHasGem(link))
		itemCache[link] = link
	end

	return link
end

local GetDungeonScoreInColor
local function formatDungeonScore(link, score)
	return score and string_gsub(link, "|h%[(.-)%]|h", "|h[" .. string_format(DUNGEON_SCORE_LEADER, GetDungeonScoreInColor(score)) .. "]|h")
end

function Module:UpdateChatItemLevel(_, msg, ...)
	msg = string_gsub(msg, "(|Hitem:%d+:.-|h.-|h)", convertItemLevel)
	msg = string_gsub(msg, "(|HdungeonScore:(%d+):.-|h.-|h)", formatDungeonScore)

	return false, msg, ...
end

function Module:CreateChatItemLevels()
	if C["Chat"].ChatItemLevel then
		GetDungeonScoreInColor = K:GetModule("Tooltip").GetDungeonScore

		ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BATTLEGROUND", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", self.UpdateChatItemLevel)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", self.UpdateChatItemLevel)
	end
end
