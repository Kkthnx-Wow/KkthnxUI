--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/Accept.lua
	Purpose:
		Accepting quests across every window the game uses: the gossip list, the
		older quest-greeting list, the single-quest detail page, area-trigger and
		auto-accept popups, and shared-quest confirmations. Optionally pushes newly
		accepted quests to the party. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Automation")

local next = next
local select = select
local IsSecret = K.IsSecret
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local C_GossipInfo = C_GossipInfo
local C_QuestLog = C_QuestLog

local GetNumActiveQuests = GetNumActiveQuests
local GetActiveTitle = GetActiveTitle
local GetActiveQuestID = GetActiveQuestID
local SelectActiveQuest = SelectActiveQuest
local GetNumAvailableQuests = GetNumAvailableQuests
local GetAvailableQuestInfo = GetAvailableQuestInfo
local SelectAvailableQuest = SelectAvailableQuest
local GetQuestID = GetQuestID
local QuestGetAutoAccept = QuestGetAutoAccept
local QuestIsFromAreaTrigger = QuestIsFromAreaTrigger
local AcknowledgeAutoAcceptQuest = AcknowledgeAutoAcceptQuest
local RemoveAutoQuestPopUp = RemoveAutoQuestPopUp
local AcceptQuest = AcceptQuest
local ConfirmAcceptQuest = ConfirmAcceptQuest
local GetNumAutoQuestPopUps = GetNumAutoQuestPopUps
local GetAutoQuestPopUp = GetAutoQuestPopUp
local ShowQuestOffer = ShowQuestOffer
local ShowQuestComplete = ShowQuestComplete
local QuestLogPushQuest = QuestLogPushQuest

-- A questID that is nil, zero, or a Midnight secret value is never safe to act on.
local function ValidQuest(questID)
	return questID and not IsSecret(questID) and questID ~= 0
end

-- Quests offered and completed through a gossip window (most modern NPCs).
function Module:HandleGossipQuests()
	if self:IsPaused() or not C.AutoQuest.Accept then
		return
	end

	for _, quest in next, C_GossipInfo.GetActiveQuests() do
		if quest.isComplete and ValidQuest(quest.questID) and self:ShouldAccept(quest.questID) then
			C_GossipInfo.SelectActiveQuest(quest.questID)
		end
	end

	for _, quest in next, C_GossipInfo.GetAvailableQuests() do
		if ValidQuest(quest.questID) and self:ShouldAccept(quest.questID) then
			C_GossipInfo.SelectAvailableQuest(quest.questID)
		end
	end
end

-- Fired for both quest gossip and plain gossip. Deal with quests first, then let
-- the gossip file decide whether to click through a lone gossip option.
function Module:OnGossipShow()
	self:HandleGossipQuests()
	if self.HandleGossipSkip then
		self:HandleGossipSkip()
	end
end

-- The older quest-greeting list, used by NPCs without full gossip.
function Module:OnQuestGreeting()
	if self:IsPaused() or not C.AutoQuest.Accept then
		return
	end

	for index = 1, GetNumActiveQuests() do
		local _, isComplete = GetActiveTitle(index)
		local questID = GetActiveQuestID(index)
		if isComplete and ValidQuest(questID) and self:ShouldAccept(questID) then
			SelectActiveQuest(index)
		end
	end

	for index = 1, GetNumAvailableQuests() do
		local questID = select(5, GetAvailableQuestInfo(index))
		if ValidQuest(questID) and self:ShouldAccept(questID) then
			SelectAvailableQuest(index)
		end
	end
end

-- The single-quest detail page shown before accepting.
function Module:OnQuestDetail()
	if self:IsPaused() or not C.AutoQuest.Accept then
		return
	end

	local questID = GetQuestID()
	if not ValidQuest(questID) then
		return
	end

	if QuestGetAutoAccept() then
		-- Already accepted by the game, the page is only a notice.
		AcknowledgeAutoAcceptQuest()
		RemoveAutoQuestPopUp(questID)
	elseif QuestIsFromAreaTrigger() then
		AcceptQuest()
	elseif self:ShouldAccept(questID) then
		AcceptQuest()
	end
end

-- Area-trigger and end-of-quest popups that live in the objective tracker.
function Module:OnQuestLogUpdate()
	if self:IsPaused() or not C.AutoQuest.Accept then
		return
	end

	for index = 1, GetNumAutoQuestPopUps() do
		local questID, popUpType = GetAutoQuestPopUp(index)
		if ValidQuest(questID) and self:ShouldAccept(questID) then
			if popUpType == "OFFER" then
				ShowQuestOffer(questID)
			elseif popUpType == "COMPLETE" then
				ShowQuestComplete(questID)
			end
		end
	end
end

-- Shared quests that need a confirmation (escorts and the like).
function Module:OnQuestAcceptConfirm()
	if not self:IsPaused() and C.AutoQuest.Accept then
		ConfirmAcceptQuest()
	end
end

-- Push a freshly accepted quest to the party when sharing is on.
function Module:OnQuestAccepted(_, questID)
	if not C.AutoQuest.Share or InCombatLockdown() or not IsInGroup() then
		return
	end
	if not ValidQuest(questID) or not C_QuestLog.IsPushableQuest(questID) then
		return
	end
	local logIndex = C_QuestLog.GetLogIndexForQuestID(questID)
	if logIndex then
		QuestLogPushQuest(logIndex)
	end
end

function Module:SetupAccept()
	self:RegisterEvent("GOSSIP_SHOW", "OnGossipShow")
	self:RegisterEvent("QUEST_GREETING", "OnQuestGreeting")
	self:RegisterEvent("QUEST_DETAIL", "OnQuestDetail")
	self:RegisterEvent("QUEST_LOG_UPDATE", "OnQuestLogUpdate")
	self:RegisterEvent("QUEST_ACCEPT_CONFIRM", "OnQuestAcceptConfirm")
	self:RegisterEvent("QUEST_ACCEPTED", "OnQuestAccepted")
end
