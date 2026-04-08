--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Auto-announces quest progress, acceptance, and completion to party/instance chat.
-- - Design: Uses pattern matching against UI_INFO_MESSAGE and debounced QUEST_LOG_UPDATE scans.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent Lua and string functions for event processing.
local math_floor = math.floor
local pairs = pairs
local find = string.find
local format = string.format
local gsub = string.gsub
local match = string.match
local wipe = table.wipe
local tonumber = tonumber

local COLLECTED = COLLECTED
local DAILY = DAILY
local ERR_ADD_FOUND_SII = ERR_QUEST_ADD_FOUND_SII
local ERR_ADD_ITEM_SII = ERR_QUEST_ADD_ITEM_SII
local ERR_ADD_KILL_SII = ERR_QUEST_ADD_KILL_SII
local ERR_ADD_PLAYER_KILL_SII = ERR_QUEST_ADD_PLAYER_KILL_SII
local ERR_COMPLETE_S = ERR_QUEST_COMPLETE_S
local ERR_FAILED_S = ERR_QUEST_FAILED_S
local ERR_OBJECTIVE_COMPLETE_S = ERR_QUEST_OBJECTIVE_COMPLETE_S
local QUEST_FREQUENCY_DAILY = Enum.QuestFrequency.Daily
local QUEST_TAG_TYPE_PROFESSION = Enum.QuestTagType.Profession

-- NOTE: Sound kit used for local quest completion feedback.
local questCompleteSoundID = 6199

local debugMode = false
local worldQuestCache = {}
local completedQuests = {}
local initialCheckComplete = false
-- NOTE: Anti-spam window (seconds) to prevent echoing the same line twice from UI glitches.
local recentInfoMsgs = {}
local recentInfoCount = 0
local INFO_MSG_TTL = 2
local INFO_MSG_MAX = 100
local _debounceQueued = false

-- ---------------------------------------------------------------------------
-- HELPERS
-- ---------------------------------------------------------------------------

local defaultIgnoredQuests = {
	[72560] = true, -- NOTE: Climbing quest (Dragonflight); highly spammy.
}

local function IsQuestIgnored(questID)
	if not questID then
		return false
	end
	local cfg = C and C["Announcements"]
	local list = cfg and cfg.IgnoredQuestIDs
	if list and list[questID] then
		return true
	end
	return defaultIgnoredQuests[questID] or false
end

-- REASON: Manage progress announcement frequency (e.g., announce every 2nd item collected).
local function GetProgressEveryNth()
	local nth = C and C["Announcements"] and C["Announcements"].QuestProgressEveryNth or 1
	nth = tonumber(nth) or 1
	if nth < 1 then
		nth = 1
	end
	return nth
end

local function ShouldAnnounceProgress()
	local nth = GetProgressEveryNth()
	if nth <= 1 then
		return true
	end
	Module._questProgressCounter = (Module._questProgressCounter or 0) + 1
	if Module._questProgressCounter >= nth then
		Module._questProgressCounter = 0
		return true
	end
	return false
end

local function GetQuestLinkOrName(questID)
	return GetQuestLink(questID) or C_QuestLog.GetTitleForQuestID(questID) or ""
end

local function GetQuestAcceptText(questID, isDaily)
	local questTitle = GetQuestLinkOrName(questID)
	if isDaily then
		return format(ERR_QUEST_ACCEPTED_S, format("[%s]%s", DAILY, questTitle))
	end
	return format(ERR_QUEST_ACCEPTED_S, questTitle)
end

local function GetQuestCompleteText(questID)
	PlaySound(questCompleteSoundID, "Master")
	return format(ERR_QUEST_COMPLETE_S, GetQuestLinkOrName(questID))
end

-- REASON: Resolves the appropriate chat channel for quest updates based on group type.
local function SendQuestMessage(message)
	if C["Announcements"].OnlyCompleteRing then
		return
	end

	if debugMode and K.isDeveloper then
		print(message)
	elseif IsPartyLFG() then
		SendChatMessage(message, "INSTANCE_CHAT")
	elseif IsInRaid() then
		SendChatMessage(message, "RAID")
	elseif IsInGroup() then
		SendChatMessage(message, "PARTY")
	end
end

-- ---------------------------------------------------------------------------
-- PATTERN MATCHING
-- ---------------------------------------------------------------------------

-- REASON: Convert Blizzard's global string formats (e.g. %s: %d/%d) into valid Lua regex patterns.
local function CreateQuestPattern(pattern)
	pattern = gsub(pattern, "%(", "%%%1")
	pattern = gsub(pattern, "%)", "%%%1")
	pattern = gsub(pattern, "%%%d?$?.", "(.+)")
	return format("^%s$", pattern)
end

local questMatchPatterns = {
	["Found"] = CreateQuestPattern(ERR_ADD_FOUND_SII),
	["Item"] = CreateQuestPattern(ERR_ADD_ITEM_SII),
	["Kill"] = CreateQuestPattern(ERR_ADD_KILL_SII),
	["PKill"] = CreateQuestPattern(ERR_ADD_PLAYER_KILL_SII),
	["ObjectiveComplete"] = CreateQuestPattern(ERR_OBJECTIVE_COMPLETE_S),
	["QuestComplete"] = CreateQuestPattern(ERR_COMPLETE_S),
	["QuestFailed"] = CreateQuestPattern(ERR_FAILED_S),
}

-- ---------------------------------------------------------------------------
-- EVENT LOGIC
-- ---------------------------------------------------------------------------

function Module:FindQuestProgress(_, message)
	if not message then
		return
	end

	if not C["Announcements"].QuestProgress or C["Announcements"].OnlyCompleteRing then
		return
	end

	-- PERF: Use a lightweight TTL check to discard UI_INFO_MESSAGE duplicates.
	local now = GetTime()
	local last = recentInfoMsgs[message]
	if last and (now - last) < INFO_MSG_TTL then
		return
	end

	for _, pattern in pairs(questMatchPatterns) do
		if match(message, pattern) then
			-- REASON: Extract progress numbers to apply nth-increment filtering if configured.
			local _, _, _, current, maximum = find(message, "(.*)[:]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
			current, maximum = tonumber(current), tonumber(maximum)
			if current and maximum then
				if maximum >= 10 then
					local step = math_floor(maximum / 5)
					if step > 0 and (current % step) == 0 then
						if ShouldAnnounceProgress() then
							SendQuestMessage(message)
						end
					end
				else
					if ShouldAnnounceProgress() then
						SendQuestMessage(message)
					end
				end
			end

			recentInfoMsgs[message] = now
			recentInfoCount = recentInfoCount + 1
			if recentInfoCount > INFO_MSG_MAX then
				wipe(recentInfoMsgs)
				recentInfoCount = 0
			end
			break
		end
	end
end

function Module:HandleQuestAccept(questID)
	if not questID then
		return
	end
	if IsQuestIgnored(questID) then
		return
	end
	if C_QuestLog.IsWorldQuest(questID) and worldQuestCache[questID] then
		return
	end

	worldQuestCache[questID] = true
	local questTagInfo = C_QuestLog.GetQuestTagInfo(questID)
	-- REASON: Profession world quests are usually trivial/repetitive; ignored by default.
	if questTagInfo and questTagInfo.worldQuestType == QUEST_TAG_TYPE_PROFESSION then
		return
	end

	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID)
	if questLogIndex then
		local questInfo = C_QuestLog.GetInfo(questLogIndex)
		if questInfo then
			local isWQ = C_QuestLog.IsWorldQuest(questID)
			if not isWQ or (isWQ and (C["Announcements"].AnnounceWorldQuests ~= false)) then
				SendQuestMessage(GetQuestAcceptText(questID, questInfo.frequency == QUEST_FREQUENCY_DAILY))
			end
		end
	end
end

-- REASON: Full scan of the quest log to detect completion states.
-- Compared against 'completedQuests' cache to find just-finished objectives.
local function ScanQuestCompletion()
	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		local questID = C_QuestLog.GetQuestIDForLogIndex(i)
		if questID and not IsQuestIgnored(questID) then
			local isQuestComplete = C_QuestLog.IsComplete(questID)
			if isQuestComplete and not completedQuests[questID] and not C_QuestLog.IsWorldQuest(questID) then
				if initialCheckComplete then
					SendQuestMessage(GetQuestCompleteText(questID))
				end
				completedQuests[questID] = true
			end
		end
	end
	initialCheckComplete = true
end

function Module:HandleQuestCompletion()
	-- PERF: QUEST_LOG_UPDATE fires excessively; debounce the scan to once per 300ms.
	if _debounceQueued then
		return
	end
	_debounceQueued = true
	C_Timer.After(0.3, function()
		_debounceQueued = false
		ScanQuestCompletion()
	end)
end

function Module:HandleWorldQuestCompletion(questID)
	-- REASON: World quest completion triggers separately via QUEST_TURNED_IN.
	if C_QuestLog.IsWorldQuest(questID) and questID and not completedQuests[questID] then
		if IsQuestIgnored(questID) then
			return
		end
		local questTagInfo = C_QuestLog.GetQuestTagInfo(questID)
		if questTagInfo and questTagInfo.worldQuestType == QUEST_TAG_TYPE_PROFESSION then
			return
		end
		if C["Announcements"].AnnounceWorldQuests ~= false then
			SendQuestMessage(GetQuestCompleteText(questID))
		end
		completedQuests[questID] = true
	end
end

-- ---------------------------------------------------------------------------
-- EXTRA NOTIFICATIONS
-- ---------------------------------------------------------------------------

local dragonGlyphAchievements = {
	[16575] = true, -- Awakened Coast
	[16576] = true, -- Ounhara Plains
	[16577] = true, -- Blueridge Woods
	[16578] = true, -- Sodra Sulcus
}

function Module:HandleDragonGlyph(achievementID, criteriaString)
	-- REASON: Special handling for Dragonriding glyph collection prompts.
	if dragonGlyphAchievements[achievementID] then
		SendQuestMessage(criteriaString .. " " .. COLLECTED)
	end
end

-- ---------------------------------------------------------------------------
-- REGISTRATION
-- ---------------------------------------------------------------------------

function Module:CreateQuestNotifier()
	if C["Announcements"].QuestNotifier and not K.CheckAddOnState("QuestNotifier") then
		K:RegisterEvent("QUEST_ACCEPTED", Module.HandleQuestAccept)
		K:RegisterEvent("QUEST_LOG_UPDATE", Module.HandleQuestCompletion)
		K:RegisterEvent("QUEST_TURNED_IN", Module.HandleWorldQuestCompletion)
		K:RegisterEvent("UI_INFO_MESSAGE", Module.FindQuestProgress)
		K:RegisterEvent("CRITERIA_EARNED", Module.HandleDragonGlyph)
	else
		wipe(completedQuests)
		K:UnregisterEvent("QUEST_ACCEPTED", Module.HandleQuestAccept)
		K:UnregisterEvent("QUEST_LOG_UPDATE", Module.HandleQuestCompletion)
		K:UnregisterEvent("QUEST_TURNED_IN", Module.HandleWorldQuestCompletion)
		K:UnregisterEvent("UI_INFO_MESSAGE", Module.FindQuestProgress)
		K:UnregisterEvent("CRITERIA_EARNED", Module.HandleDragonGlyph)
	end
end
