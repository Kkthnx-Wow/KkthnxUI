local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

-- Cache Lua functions and constants
local floor = math.floor
local pairs = pairs
local find = string.find
local format = string.format
local gsub = string.gsub
local match = string.match
local wipe = K.ClearTable
local tonumber = tonumber

-- Cache WoW API functions and constants
local COLLECTED = COLLECTED
local GetQuestInfo = C_QuestLog.GetInfo
local GetQuestLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local IsQuestComplete = C_QuestLog.IsComplete
local IsWorldQuest = C_QuestLog.IsWorldQuest
local DAILY = DAILY
local ERR_ADD_FOUND_SII = ERR_QUEST_ADD_FOUND_SII
local ERR_ADD_ITEM_SII = ERR_QUEST_ADD_ITEM_SII
local ERR_ADD_KILL_SII = ERR_QUEST_ADD_KILL_SII
local ERR_ADD_PLAYER_KILL_SII = ERR_QUEST_ADD_PLAYER_KILL_SII
local ERR_COMPLETE_S = ERR_QUEST_COMPLETE_S
local ERR_FAILED_S = ERR_QUEST_FAILED_S
local ERR_OBJECTIVE_COMPLETE_S = ERR_QUEST_OBJECTIVE_COMPLETE_S
local GetQuestLink = GetQuestLink
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local QUEST_FREQUENCY_DAILY = Enum.QuestFrequency.Daily
local QUEST_TAG_TYPE_PROFESSION = Enum.QuestTagType.Profession
local PlaySound = PlaySound
local SendChatMessage = SendChatMessage

-- Sound Kit ID
local questCompleteSoundID = 6199 -- https://wowhead.com/sound=6199/b-peonbuildingcomplete1

-- Flags and caches
local debugMode = false -- Indicates if debug mode is enabled
local worldQuestCache = {} -- Cache for world quest IDs
local completedQuests = {} -- Cache for completed quest IDs
local initialCheckComplete = false -- Indicates if initial quest check is complete

-- Throttle: announce every Nth progress (1 = every)
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

-- Get the quest link or the quest name
local function GetQuestLinkOrName(questID)
	return GetQuestLink(questID) or GetTitleForQuestID(questID) or ""
end

-- Get the text for the quest acceptance message
local function GetQuestAcceptText(questID, isDaily)
	local questTitle = GetQuestLinkOrName(questID)
	if isDaily then
		return format("%s [%s]%s", "Accepted", DAILY, questTitle)
	else
		return format("%s %s", "Accepted", questTitle)
	end
end

-- Get the text for the quest completion message
local function GetQuestCompleteText(questID)
	PlaySound(questCompleteSoundID, "Master")
	return format("%s %s", "Completed", GetQuestLinkOrName(questID))
end

-- Send message to the appropriate channel
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

-- Get the pattern for a given quest match
local function CreateQuestPattern(pattern)
	pattern = gsub(pattern, "%(", "%%%1")
	pattern = gsub(pattern, "%)", "%%%1")
	pattern = gsub(pattern, "%%%d?$?.", "(.+)")
	return format("^%s$", pattern)
end

-- Table of quest match patterns
local questMatchPatterns = {
	["Found"] = CreateQuestPattern(ERR_ADD_FOUND_SII),
	["Item"] = CreateQuestPattern(ERR_ADD_ITEM_SII),
	["Kill"] = CreateQuestPattern(ERR_ADD_KILL_SII),
	["PKill"] = CreateQuestPattern(ERR_ADD_PLAYER_KILL_SII),
	["ObjectiveComplete"] = CreateQuestPattern(ERR_OBJECTIVE_COMPLETE_S),
	["QuestComplete"] = CreateQuestPattern(ERR_COMPLETE_S),
	["QuestFailed"] = CreateQuestPattern(ERR_FAILED_S),
}

-- Find quest progress based on UI message
function Module:FindQuestProgress(_, message)
	-- Validate configurations and input
	if not message then
		return
	end

	if not C["Announcements"].QuestProgress or C["Announcements"].OnlyCompleteRing then
		return
	end

	for _, pattern in pairs(questMatchPatterns) do
		if match(message, pattern) then
			local _, _, _, current, maximum = find(message, "(.*)[:]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
			current, maximum = tonumber(current), tonumber(maximum)
			if current and maximum then
				if maximum >= 10 then
					local step = floor(maximum / 5)
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

			break
		end
	end
end

-- Handle quest acceptance
function Module:HandleQuestAccept(questID)
	if not questID then
		return
	end
	if IsWorldQuest(questID) and worldQuestCache[questID] then
		return
	end

	worldQuestCache[questID] = true
	local questTagInfo = GetQuestTagInfo(questID)
	if questTagInfo and questTagInfo.worldQuestType == QUEST_TAG_TYPE_PROFESSION then
		return
	end

	local questLogIndex = GetQuestLogIndexForQuestID(questID)
	if questLogIndex then
		local questInfo = GetQuestInfo(questLogIndex)
		if questInfo then
			local isWQ = IsWorldQuest(questID)
			if not isWQ or (isWQ and (C["Announcements"].AnnounceWorldQuests ~= false)) then
				SendQuestMessage(GetQuestAcceptText(questID, questInfo.frequency == QUEST_FREQUENCY_DAILY))
			end
		end
	end
end

-- Handle quest completion
function Module:HandleQuestCompletion()
	for i = 1, GetNumQuestLogEntries() do
		local questID = GetQuestIDForLogIndex(i)
		local isQuestComplete = questID and IsQuestComplete(questID)
		if isQuestComplete and not completedQuests[questID] and not IsWorldQuest(questID) then
			if initialCheckComplete then
				SendQuestMessage(GetQuestCompleteText(questID))
			end
			completedQuests[questID] = true
		end
	end
	initialCheckComplete = true
end

-- Handle world quest completion
function Module:HandleWorldQuestCompletion(questID)
	if IsWorldQuest(questID) and questID and not completedQuests[questID] then
		if C["Announcements"].AnnounceWorldQuests ~= false then
			SendQuestMessage(GetQuestCompleteText(questID))
		end
		completedQuests[questID] = true
	end
end

-- Dragon glyph notification
local dragonGlyphAchievements = {
	[16575] = true, -- Awakened Coast
	[16576] = true, -- Ounhara Plains
	[16577] = true, -- Blueridge Woods
	[16578] = true, -- Sodra Sulcus
}

function Module:HandleDragonGlyph(achievementID, criteriaString)
	if dragonGlyphAchievements[achievementID] then
		SendQuestMessage(criteriaString .. " " .. COLLECTED)
	end
end

-- Create or destroy quest notifier based on settings
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
