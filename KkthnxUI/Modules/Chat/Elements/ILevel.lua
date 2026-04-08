--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Appends item level and gem information to item hyperlinks in chat.
-- - Design: Hooks various chat message events to scan for item/dungeon score links and inject metadata.
-- - Events: CHAT_MSG_LOOT, CHAT_MSG_CHANNEL, CHAT_MSG_SAY, etc.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter
local DUNGEON_SCORE_LEADER = _G.DUNGEON_SCORE_LEADER
local Enum = _G.Enum
local GetItemInfo = _G.C_Item.GetItemInfo
local GetItemStats = _G.C_Item.GetItemStats
local pairs = pairs
local string_format = string.format
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local itemCache = {}
local getDungeonScoreInColor

local SOCKET_WATCH_LIST = {
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

-- ---------------------------------------------------------------------------
-- Information Retrieval logic
-- ---------------------------------------------------------------------------
local function isItemWithLevel(link)
	-- REASON: Verifies if a hyperlink corresponds to an item that typically has a meaningful level (equipment).
	local name, _, rarity, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
	if name and level and rarity > 1 and (classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor) then
		local itemLevel = K.GetItemLevel(link)
		return name, itemLevel
	end
end

local function getSocketTexture(socket, count)
	-- REASON: Generates a string of inline textures representing the sockets available on an item.
	return string_rep("|TInterface\\ItemSocketingFrame\\UI-EmptySocket-" .. socket .. ":0|t", count)
end

function Module:GetItemGemInfo(link)
	-- REASON: Scans item stats for empty sockets and prepares a texture-string representation.
	local text = ""
	local stats = GetItemStats(link)
	if stats then
		for stat, count in pairs(stats) do
			local socket = string_match(stat, "EMPTY_SOCKET_(%S+)")
			if socket and SOCKET_WATCH_LIST[socket] then
				-- REASON: Fallback for primordial sockets which occasionally lack dedicated textures.
				if socket == "PRIMORDIAL" then
					socket = "META"
				end
				text = text .. getSocketTexture(socket, count)
			end
		end
	end
	return text
end

-- ---------------------------------------------------------------------------
-- Chat String Processing
-- ---------------------------------------------------------------------------
local function convertItemLevel(link)
	-- REASON: Transforms a standard item link into one that includes Item Level and socket icons.
	if not link then
		return
	end

	if itemCache[link] then
		return itemCache[link]
	end

	local name, itemLevel = isItemWithLevel(link)
	if name and itemLevel then
		link = string_gsub(link, "|h%[(.-)%]|h", "|h[" .. name .. "(" .. itemLevel .. ")]|h" .. Module:GetItemGemInfo(link))
		itemCache[link] = link
	end

	return link
end

local function formatDungeonScore(link, score)
	-- REASON: Injects the Mythic+ score color/rating directly into the score hyperlink.
	if not score or not getDungeonScoreInColor then
		return link
	end
	return string_gsub(link, "|h%[(.-)%]|h", "|h[" .. string_format(DUNGEON_SCORE_LEADER, getDungeonScoreInColor(score)) .. "]|h")
end

function Module:UpdateChatItemLevel(_, msg, ...)
	-- REASON: Main message filter; dispatches replacement logic for items and dungeon scores.
	msg = string_gsub(msg, "(|Hitem:%d+:.-|h.-|h)", convertItemLevel)
	msg = string_gsub(msg, "(|HdungeonScore:(%d+):.-|h.-|h)", formatDungeonScore)

	return false, msg, ...
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateChatItemLevels()
	-- REASON: Entry point for chat link enhancements; registers filters across all text-heavy chat channels.
	if C["Chat"].ChatItemLevel then
		local tooltipModule = K:GetModule("Tooltip")
		if tooltipModule then
			getDungeonScoreInColor = tooltipModule.GetDungeonScore
		end

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
