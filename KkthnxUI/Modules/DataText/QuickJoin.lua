local K = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local table_wipe = _G.table.wipe

local BNGetNumFriends = _G.BNGetNumFriends
local C_BattleNet_GetFriendAccountInfo = _G.C_BattleNet.GetFriendAccountInfo
local C_BattleNet_GetFriendGameAccountInfo = _G.C_BattleNet.GetFriendGameAccountInfo
local C_BattleNet_GetFriendNumGameAccounts = _G.C_BattleNet.GetFriendNumGameAccounts
local C_LFGList_GetSearchResultInfo = _G.C_LFGList.GetSearchResultInfo
local C_SocialQueue_GetAllGroups = _G.C_SocialQueue.GetAllGroups
local C_SocialQueue_GetGroupMembers = _G.C_SocialQueue.GetGroupMembers
local C_SocialQueue_GetGroupQueues = _G.C_SocialQueue.GetGroupQueues
local QUICK_JOIN = _G.QUICK_JOIN
local SocialQueueUtil_GetQueueName = _G.SocialQueueUtil_GetQueueName
local SocialQueueUtil_GetRelationshipInfo = _G.SocialQueueUtil_GetRelationshipInfo
local UNKNOWN = _G.UNKNOWN
local BNET_CLIENT_WOW = _G.BNET_CLIENT_WOW

local quickJoin = {}

local function SocialQueueIsLeader(playerName, leaderName)
	if leaderName == playerName then
		return true
	end

	for i = 1, BNGetNumFriends() do
		local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
		if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline then
			local numGameAccounts = C_BattleNet_GetFriendNumGameAccounts(i)
			if numGameAccounts then
				for y = 1, numGameAccounts do
					local gameAccountInfo = C_BattleNet_GetFriendGameAccountInfo(i, y)
					if gameAccountInfo and (gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (accountInfo.accountName == playerName) then
						playerName = gameAccountInfo.characterName
						if gameAccountInfo.realmName and gameAccountInfo.realmName ~= K.Realm then
							playerName = string_format("%s-%s", playerName, string_gsub(gameAccountInfo.realmName,"[%s%-]", ""))
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

local function OnEnter()
	GameTooltip:SetOwner(LFDMicroButton, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(LFDMicroButton))
	GameTooltip:ClearLines()

	if not next(quickJoin) then
		GameTooltip:AddLine("|cffffffff"..DUNGEONS_BUTTON.."|r".." (I)")
		GameTooltip:Show()
		return
	end

	GameTooltip:AddLine("|cffffffff"..DUNGEONS_BUTTON.."|r".." (I)")
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.InfoColor..QUICK_JOIN, nil, nil, nil, true)
	GameTooltip:AddLine(" ")
	for name, activity in pairs(quickJoin) do
		GameTooltip:AddDoubleLine(name, activity, nil, nil, nil, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function OnUpdate()
	table_wipe(quickJoin)

	local quickJoinGroups = C_SocialQueue_GetAllGroups()
	for _, guid in pairs(quickJoinGroups) do
		local players = C_SocialQueue_GetGroupMembers(guid)
		if players then
			local firstMember, numMembers, extraCount = players[1], #players, ""
			local playerName, nameColor = SocialQueueUtil_GetRelationshipInfo(firstMember.guid, nil, firstMember.clubId)
			if numMembers > 1 then
				extraCount = string_format(" +%s", numMembers - 1)
			end

			local queues = C_SocialQueue_GetGroupQueues(guid)
			local firstQueue, numQueues = queues and queues[1], queues and #queues or 0
			local isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == "lfglist"
			local coloredName = (playerName and string_format("%s%s|r%s", nameColor, playerName, extraCount)) or string_format("{%s%s}", UNKNOWN, extraCount)

			local activity
			if isLFGList and firstQueue and firstQueue.eligible then
				local activityName, isLeader, leaderName
				if firstQueue.queueData.lfgListID then
					local searchResultInfo = C_LFGList_GetSearchResultInfo(firstQueue.queueData.lfgListID)
					if searchResultInfo then
						activityName, leaderName = searchResultInfo.name, searchResultInfo.leaderName
						isLeader = SocialQueueIsLeader(playerName, leaderName)
					end
				end

				if isLeader then
					coloredName = string_format("|TInterface\\GroupFrame\\UI-Group-LeaderIcon:16:16|t%s", coloredName)
				end

				activity = activityName or UNKNOWN
				if numQueues > 1 then
					activity = string_format("[+%s]%s", numQueues - 1, activity)
				end
			elseif firstQueue then
				local output, queueCount = "", 0
				for _, queue in pairs(queues) do
					if type(queue) == "table" and queue.eligible then
						local queueName = (queue.queueData and SocialQueueUtil_GetQueueName(queue.queueData)) or ""
						if queueName ~= "" then
							if output == "" then
								output = string_gsub(queueName,"\n.+", "") -- grab only the first queue name
								queueCount = queueCount + select(2, string_gsub(queueName,"\n", "")) -- collect additional on single queue
							else
								queueCount = queueCount + 1 + select(2, string_gsub(queueName,"\n", "")) -- collect additional on additional queues
							end
						end
					end
				end

				if output ~= "" then
					if queueCount > 0 then
						activity = string_format("%s[+%s]", output, queueCount)
					else
						activity = output
					end
				end
			end

			quickJoin[coloredName] = activity
		end
	end

	Module.LFDFont:SetFormattedText("%s", #quickJoinGroups)
end

local function OnMouseUp(_, button)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
		return
	end

	if button == "LeftButton" then
		ToggleLFDParentFrame()
	elseif button == "RightButton" then
		ToggleQuickJoinPanel()
	end
end

function Module:CreateQuickJoinDataText()
	if not LFDMicroButton then
		return
	end

	Module.LFDFrame = CreateFrame("Button", "KKUI_QuickJoinDataText", UIParent)
	Module.LFDFrame:SetAllPoints(LFDMicroButton)
	Module.LFDFrame:SetSize(LFDMicroButton:GetWidth(), LFDMicroButton:GetHeight())
	Module.LFDFrame:SetFrameLevel(LFDMicroButton:GetFrameLevel() + 2)

	Module.LFDFont = Module.LFDFrame:CreateFontString("OVERLAY")
	Module.LFDFont:FontTemplate(nil, nil, "OUTLINE")
	Module.LFDFont:SetPoint("CENTER", Module.LFDFrame, "CENTER", 1, -6)

	K:RegisterEvent("PLAYER_ENTERING_WORLD", OnUpdate)
	K:RegisterEvent("SOCIAL_QUEUE_UPDATE", OnUpdate)

	Module.LFDFrame:SetScript("OnUpdate", OnUpdate)
	Module.LFDFrame:SetScript("OnMouseUp", OnMouseUp)
	Module.LFDFrame:SetScript("OnEnter", OnEnter)
	Module.LFDFrame:SetScript("OnLeave", OnLeave)
end