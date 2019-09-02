local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local strmatch, strfind, gsub, format = string.match, string.find, string.gsub, string.format
local mod, tonumber, pairs, floor = mod, tonumber, pairs, math.floor
local soundKitID = SOUNDKIT.ALARM_CLOCK_WARNING_3
local QUEST_COMPLETE, LE_QUEST_TAG_TYPE_PROFESSION, LE_QUEST_FREQUENCY_DAILY = QUEST_COMPLETE, LE_QUEST_TAG_TYPE_PROFESSION, LE_QUEST_FREQUENCY_DAILY
local ERR_QUEST_ADD_FOUND_SII, ERR_QUEST_ADD_ITEM_SII, ERR_QUEST_ADD_KILL_SII, ERR_QUEST_ADD_PLAYER_KILL_SII, ERR_QUEST_OBJECTIVE_COMPLETE_S, ERR_QUEST_COMPLETE_S, ERR_QUEST_FAILED_S =
ERR_QUEST_ADD_FOUND_SII, ERR_QUEST_ADD_ITEM_SII, ERR_QUEST_ADD_KILL_SII, ERR_QUEST_ADD_PLAYER_KILL_SII, ERR_QUEST_OBJECTIVE_COMPLETE_S, ERR_QUEST_COMPLETE_S, ERR_QUEST_FAILED_S

local completedQuest, initComplete = {}

local function acceptText(link, daily)
	if daily then
		return format("%s [%s]%s", "AcceptQuest", DAILY, link)
	else
		return format("%s %s", "AcceptQuest", link)
	end
end

local function completeText(link)
	PlaySound(soundKitID, "Master")
	return format("%s %s", link, QUEST_COMPLETE)
end

local function sendQuestMsg(msg)
	if C["QuestNotifier"].OnlyCompleteRing then
		return
	end

	if K.CodeDebug then
		print(msg)
	elseif IsPartyLFG() then
		SendChatMessage(msg, "PARTY")
	elseif IsInRaid() then
		SendChatMessage(msg, "RAID")
	elseif IsInGroup() and not IsInRaid() then
		SendChatMessage(msg, "PARTY")
	end
end

local function getPattern(pattern)
	pattern = gsub(pattern, "%(", "%%%1")
	pattern = gsub(pattern, "%)", "%%%1")
	pattern = gsub(pattern, "%%%d?$?.", "(.+)")
	return format("^%s$", pattern)
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

local function FindQuestProgress(_, _, msg)
	if not C["QuestNotifier"].QuestProgress then
		return
	end

	if C["QuestNotifier"].OnlyCompleteRing then
		return
	end

	for _, pattern in pairs(questMatches) do
		if strmatch(msg, pattern) then
			local _, _, _, cur, max = strfind(msg, "(.*)[:：]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
			cur, max = tonumber(cur), tonumber(max)
			if cur and max and max >= 10 then
				if mod(cur, floor(max/5)) == 0 then
					sendQuestMsg(msg)
				end
			else
				sendQuestMsg(msg)
			end
			break
		end
	end
end

local function FindQuestAccept(_, questLogIndex, questID)
	if not C["QuestNotifier"].PickupQuest then
		return
	end

	local link = GetQuestLink(questID)
	local frequency = select(7, GetQuestLogTitle(questLogIndex))
	if link then
		local tagID, _, worldQuestType = GetQuestTagInfo(questID)
		if tagID == 109 or worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION then
			return
		end
		sendQuestMsg(acceptText(link, frequency == LE_QUEST_FREQUENCY_DAILY))
	end
end

local function FindQuestComplete()
	for i = 1, GetNumQuestLogEntries() do
		local _, _, _, _, _, isComplete, _, questID = GetQuestLogTitle(i)
		local link = GetQuestLink(questID)
		local worldQuest = select(3, GetQuestTagInfo(questID))
		if link and isComplete and not completedQuest[questID] and not worldQuest then
			if initComplete then
				sendQuestMsg(completeText(link))
			else
				initComplete = true
			end
			completedQuest[questID] = true
		end
	end
end

local function FindWorldQuestComplete(_, questID)
	if QuestUtils_IsQuestWorldQuest(questID) then
		local link = GetQuestLink(questID)
		if link and not completedQuest[questID] then
			sendQuestMsg(completeText(link))
			completedQuest[questID] = true
		end
	end
end

function Module:CreateQuestNotifier()
	if not C["QuestNotifier"].Enable then
		return
	end

	if IsAddOnLoaded("QuestNotifier") then
		return
	end

	FindQuestComplete()
	K:RegisterEvent("QUEST_ACCEPTED", FindQuestAccept)
	K:RegisterEvent("QUEST_LOG_UPDATE", FindQuestComplete)
	K:RegisterEvent("QUEST_TURNED_IN", FindWorldQuestComplete)
	K:RegisterEvent("UI_INFO_MESSAGE", FindQuestProgress)
end