local K, C = unpack(select(2, ...))
local Module = K:NewModule("SocialQueue", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")
if C["Chat"].Enable ~= true or C["Chat"].QuickJoin ~= true then return end

-- Sourced: ElvUI (Simpy and Merathilis)

local _G = _G
local difftime = difftime
local string_format = string.format

local BNGetFriendGameAccountInfo = _G.BNGetFriendGameAccountInfo
local BNGetFriendInfo = _G.BNGetFriendInfo
local BNGetNumFriendGameAccounts = _G.BNGetNumFriendGameAccounts
local BNGetNumFriends = _G.BNGetNumFriends
local C_LFGList_GetActivityInfo = _G.C_LFGList.GetActivityInfo
local C_LFGList_GetSearchResultInfo = _G.C_LFGList.GetSearchResultInfo
local C_SocialQueue_GetGroupMembers = _G.C_SocialQueue.GetGroupMembers
local C_SocialQueue_GetGroupQueues = _G.C_SocialQueue.GetGroupQueues
local LFG_LIST_AND_MORE = _G.LFG_LIST_AND_MORE
local SOCIAL_QUEUE_QUEUED_FOR = _G.SOCIAL_QUEUE_QUEUED_FOR:gsub(":%s?$","") -- some language have `:` on end
local SocialQueueUtil_GetRelationshipInfo = _G.SocialQueueUtil_GetRelationshipInfo
local SocialQueueUtil_GetQueueName = _G.SocialQueueUtil_GetQueueName
local UNKNOWN = _G.UNKNOWN

function Module:SocialQueueIsLeader(playerName, leaderName)
	if leaderName == playerName then
		return true
	end

	local numGameAccounts, accountName, isOnline, gameCharacterName, gameClient, realmName, _
	for i = 1, BNGetNumFriends() do
		_, accountName, _, _, _, _, _, isOnline = BNGetFriendInfo(i);
		if isOnline then
			numGameAccounts = BNGetNumFriendGameAccounts(i);
			if numGameAccounts > 0 then
				for y = 1, numGameAccounts do
					_, gameCharacterName, gameClient, realmName = BNGetFriendGameAccountInfo(i, y);
					if (gameClient == BNET_CLIENT_WOW) and (accountName == playerName) then
						playerName = gameCharacterName
						if realmName ~= K.Realm then
							playerName = string_format("%s-%s", playerName, gsub(realmName,"[%s%-]",""))
						end
						if leaderName == playerName then
							return true
						end
					end
				end
			end
		end
	end
end

local socialQueueCache = {}
local function RecentSocialQueue(TIME, MSG)
	local previousMessage = false
	if next(socialQueueCache) then
		for guid, tbl in pairs(socialQueueCache) do
			-- !dont break this loop! its used to keep the cache updated
			if TIME and (difftime(TIME, tbl[1]) >= 300) then
				socialQueueCache[guid] = nil --remove any older than 5m
			elseif MSG and (MSG == tbl[2]) then
				previousMessage = true --dont show any of the same message within 5m
				-- see note for `message` in `SocialQueueMessage` about `MSG` content
			end
		end
	end
	return previousMessage
end

function Module:SocialQueueMessage(guid, message)
	if not (guid and message) then return end
	-- `guid` is something like `Party-1147-000011202574` and appears to update each time for solo requeue, otherwise on new group creation.
	-- `message` is something like `|cff82c5ff|Kf58|k000000000000|k|r queued for: |cff00CCFFRandom Legion Heroic|r `

	-- prevent duplicate messages within 5 minutes
	local TIME = time()
	if RecentSocialQueue(TIME, message) then return end
	socialQueueCache[guid] = {TIME, message}

	--UI_71_SOCIAL_QUEUEING_TOAST = 79739; appears to have no sound?
	PlaySound(7355) --TUTORIAL_POPUP

	K.Print(string_format("|Hsqu:%s|h%s|h", guid, strtrim(message)))
end

function Module:SocialQueueEvent(event, guid, numAddedItems)
	if not C["Chat"].QuickJoin == true then
		return
	end

	if numAddedItems == 0 or not guid then
		return
	end

	local players = C_SocialQueue_GetGroupMembers(guid)
	if not players then return end

	local firstMember, numMembers, extraCount, coloredName = players[1], #players, ""
	local playerName, nameColor = SocialQueueUtil_GetRelationshipInfo(firstMember.guid, nil, firstMember.clubId)
	if numMembers > 1 then
		extraCount = string_format(" +%s", numMembers - 1)
	end
	if playerName then
		coloredName = string_format("%s%s|r%s", nameColor, playerName, extraCount)
	else
		coloredName = string_format("{%s%s}", UNKNOWN, extraCount)
	end

	local queues = C_SocialQueue_GetGroupQueues(guid)
	local firstQueue = queues and queues[1]
	local isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == "lfglist"

	if isLFGList and firstQueue and firstQueue.eligible then
		local searchResultInfo, activityID, name, comment, leaderName, fullName, isLeader

		if firstQueue.queueData.lfgListID then
			searchResultInfo = C_LFGList_GetSearchResultInfo(firstQueue.queueData.lfgListID)
			if searchResultInfo then
				activityID, name, comment, leaderName = searchResultInfo.activityID, searchResultInfo.name, searchResultInfo.comment, searchResultInfo.leaderName
				isLeader = self:SocialQueueIsLeader(playerName, leaderName)
			end
		end

		if activityID or firstQueue.queueData.activityID then
			fullName = C_LFGList_GetActivityInfo(activityID or firstQueue.queueData.activityID)
		end

		if name then
			self:SocialQueueMessage(guid, string_format("%s %s: [%s] |cff00CCFF%s|r", coloredName, (isLeader and "is looking for members") or "joined a group", fullName or UNKNOWN, name))
		else
			self:SocialQueueMessage(guid, string_format("%s %s: |cff00CCFF%s|r", coloredName, (isLeader and "is looking for members") or "joined a group", fullName or UNKNOWN))
		end
	elseif firstQueue then
		local output, outputCount, queueCount, queueName = "", "", 0
		for _, queue in pairs(queues) do
			if type(queue) == "table" and queue.eligible then
				queueName = (queue.queueData and SocialQueueUtil_GetQueueName(queue.queueData)) or ""
				if queueName ~= "" then
					if output == "" then
						output = gsub(queueName, "\n.+", "") -- grab only the first queue name
						queueCount = queueCount + select(2, gsub(queueName, "\n","")) -- collect additional on single queue
					else
						queueCount = queueCount + 1 + select(2, gsub(queueName, "\n","")) -- collect additional on additional queues
					end
				end
			end
		end
		if output ~= "" then
			if queueCount > 0 then
				outputCount = string_format(LFG_LIST_AND_MORE, queueCount)
			end
			self:SocialQueueMessage(guid, string_format("%s %s: |cff00CCFF%s|r %s", coloredName, SOCIAL_QUEUE_QUEUED_FOR, output, outputCount))
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("SOCIAL_QUEUE_UPDATE", "SocialQueueEvent")
end

function Module:OnDisable()
	self:UnregisterEvent("SOCIAL_QUEUE_UPDATE")
end