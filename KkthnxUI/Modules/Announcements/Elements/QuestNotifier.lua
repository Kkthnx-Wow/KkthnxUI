local K, C = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local math_floor = _G.math.floor
local mod = _G.mod
local pairs = _G.pairs
local string_find = _G.string.find
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber

local C_QuestLog_GetInfo = _G.C_QuestLog.GetInfo
local C_QuestLog_GetLogIndexForQuestID = _G.C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetNumQuestLogEntries = _G.C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetQuestIDForLogIndex = _G.C_QuestLog.GetQuestIDForLogIndex
local C_QuestLog_GetQuestTagInfo = _G.C_QuestLog.GetQuestTagInfo
local C_QuestLog_GetTitleForQuestID = _G.C_QuestLog.GetTitleForQuestID
local C_QuestLog_IsComplete = _G.C_QuestLog.IsComplete
local C_QuestLog_IsWorldQuest = _G.C_QuestLog.IsWorldQuest
local GetQuestLink = _G.GetQuestLink
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsPartyLFG = _G.IsPartyLFG
local LE_QUEST_FREQUENCY_DAILY = _G.Enum.QuestFrequency.Daily
local LE_QUEST_TAG_TYPE_PROFESSION = _G.Enum.QuestTagType.Profession
local PlaySound = _G.PlaySound
local QUEST_COMPLETE = _G.QUEST_COMPLETE
local SendChatMessage = _G.SendChatMessage
local soundKitID = _G.SOUNDKIT.ALARM_CLOCK_WARNING_3

local debugMode = false
local completedQuest, initComplete = {}

local function GetQuestLinkOrName(questID)
	return GetQuestLink(questID) or C_QuestLog_GetTitleForQuestID(questID) or ""
end

local function acceptText(questID, daily)
	local title = GetQuestLinkOrName(questID)
	if daily then
		return string_format("%s [%s]%s", "Accept Quest", DAILY, title)
	else
		return string_format("%s %s", "Accept Quest", title)
	end
end

local function completeText(questID)
	PlaySound(soundKitID, "Master")
	return string_format("%s %s", GetQuestLinkOrName(questID), QUEST_COMPLETE)
end

local function sendQuestMsg(msg)
	if C["Announcements"].OnlyCompleteRing then
		return
	end

	if debugMode and K.isDeveloper then
		print(msg)
	elseif IsPartyLFG() then
		SendChatMessage(msg, "INSTANCE_CHAT")
	elseif IsInRaid() then
		SendChatMessage(msg, "RAID")
	elseif IsInGroup() then
		SendChatMessage(msg, "PARTY")
	end
end

local function getPattern(pattern)
	pattern = string_gsub(pattern, "%(", "%%%1")
	pattern = string_gsub(pattern, "%)", "%%%1")
	pattern = string_gsub(pattern, "%%%d?$?.", "(.+)")
	return string_format("^%s$", pattern)
end

local questMatches = {
	["Found"] = getPattern(ERR_QUEST_ADD_FOUND_SII),
	["Item"] = getPattern(ERR_QUEST_ADD_ITEM_SII),
	["Kill"] = getPattern(ERR_QUEST_ADD_KILL_SII),
	["PKill"] = getPattern(ERR_QUEST_ADD_PLAYER_KILL_SII),
	["ObjectiveComplete"] = getPattern(ERR_QUEST_OBJECTIVE_COMPLETE_S),
	["QuestComplete"] = getPattern(ERR_QUEST_COMPLETE_S),
	["QuestFailed"] = getPattern(ERR_QUEST_FAILED_S),
}

function Module:FindQuestProgress(_, msg)
	if not C["Announcements"].QuestProgress then
		return
	end

	if C["Announcements"].OnlyCompleteRing then
		return
	end

	for _, pattern in pairs(questMatches) do
		if string_match(msg, pattern) then
			local _, _, _, cur, max = string_find(msg, "(.*)[:：]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
			cur, max = tonumber(cur), tonumber(max)
			if cur and max and max >= 10 then
				if mod(cur, math_floor(max / 5)) == 0 then
					sendQuestMsg(msg)
				end
			else
				sendQuestMsg(msg)
			end
			break
		end
	end
end

function Module:FindQuestAccept(questID)
	local tagInfo = C_QuestLog_GetQuestTagInfo(questID)
	if tagInfo and tagInfo.worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION then
		return
	end

	local questLogIndex = C_QuestLog_GetLogIndexForQuestID(questID)
	if questLogIndex then
		local info = C_QuestLog_GetInfo(questLogIndex)
		if info then
			sendQuestMsg(acceptText(questID, info.frequency == LE_QUEST_FREQUENCY_DAILY))
		end
	end
end

function Module:FindQuestComplete()
	for i = 1, C_QuestLog_GetNumQuestLogEntries() do
		local questID = C_QuestLog_GetQuestIDForLogIndex(i)
		local isComplete = questID and C_QuestLog_IsComplete(questID)
		if isComplete and not completedQuest[questID] and not C_QuestLog_IsWorldQuest(questID) then
			if initComplete then
				sendQuestMsg(completeText(questID))
			end
			completedQuest[questID] = true
		end
	end
	initComplete = true
end

function Module:FindWorldQuestComplete(questID)
	if C_QuestLog_IsWorldQuest(questID) then
		if questID and not completedQuest[questID] then
			sendQuestMsg(completeText(questID))
			completedQuest[questID] = true
		end
	end
end

function Module:CreateQuestNotifier()
	if C["Announcements"].QuestNotifier and not IsAddOnLoaded("QuestNotifier") then
		K:RegisterEvent("QUEST_ACCEPTED", Module.FindQuestAccept)
		K:RegisterEvent("QUEST_LOG_UPDATE", Module.FindQuestComplete)
		K:RegisterEvent("QUEST_TURNED_IN", Module.FindWorldQuestComplete)
		K:RegisterEvent("UI_INFO_MESSAGE", Module.FindQuestProgress)
	else
		table_wipe(completedQuest)
		K:UnregisterEvent("QUEST_ACCEPTED", Module.FindQuestAccept)
		K:UnregisterEvent("QUEST_LOG_UPDATE", Module.FindQuestComplete)
		K:UnregisterEvent("QUEST_TURNED_IN", Module.FindWorldQuestComplete)
		K:UnregisterEvent("UI_INFO_MESSAGE", Module.FindQuestProgress)
	end
end