--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/QuestAnnounce.lua
	Purpose:
		Tell the group when you accept or finish a quest, with a clickable quest
		link, so a party working through the same story stays in step. Nothing is
		said while solo, and world quests and profession quests are left out.

		Accepting is told from the accept event. Finishing is told when a quest in
		the log turns complete, found by checking the log when it changes and
		remembering which quests have already been announced. The first look after
		logging in only records, so quests that were already done are not repeated.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local format = string.format
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local C_QuestLog = C_QuestLog
local SendChatMessage = C_ChatInfo.SendChatMessage

local done = {} -- quest id -> true once announced as complete
local primed

local function Channel()
	if IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	end
end

local function Say(text)
	local channel = Channel()
	if channel then
		SendChatMessage(text, channel)
	end
end

local function Title(questID)
	return _G.GetQuestLink(questID) or C_QuestLog.GetTitleForQuestID(questID) or ""
end

local function OnAccepted(_, _, questID)
	if not questID or C_QuestLog.IsWorldQuest(questID) then
		return
	end
	Say(format(L["Accepted: %s"], Title(questID)))
end

local queued

local function Scan()
	queued = nil
	for index = 1, C_QuestLog.GetNumQuestLogEntries() do
		local info = C_QuestLog.GetInfo(index)
		local questID = info and not info.isHeader and info.questID
		if questID and not done[questID] and C_QuestLog.IsComplete(questID) and not C_QuestLog.IsWorldQuest(questID) then
			done[questID] = true
			if primed then
				Say(format(L["Completed: %s"], Title(questID)))
			end
		end
	end
	primed = true
end

-- The log event comes in bursts, so one look a moment after it settles is enough.
local function OnLogChanged()
	if not queued then
		queued = true
		C_Timer.After(0.5, Scan)
	end
end

function Module:SetupQuestAnnounce()
	self:RegisterEvent("QUEST_ACCEPTED", OnAccepted)
	self:RegisterEvent("QUEST_LOG_UPDATE", OnLogChanged)
	self:RegisterEvent("QUEST_REMOVED", function(_, _, questID)
		done[questID] = nil
	end)
end
