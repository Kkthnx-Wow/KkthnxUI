--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/Quest.lua
	Purpose:
		Hands-off questing, part of the Automation module. This file owns the shared
		quest helpers (pause key, quest-data caching, the accept test) and the event
		wiring. The per-stage handlers live in sibling files so each stays readable:
			Accept.lua  gossip quests, quest lists, detail, and auto-popups
			TurnIn.lua  progress, completion, and reward selection
			Gossip.lua  clicking through a single-option gossip
		The whole thing pauses while a modifier is held, so nothing runs away from
		you when you actually want to read a quest. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Automation")

local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown
local C_QuestLog = C_QuestLog
local C_Timer = C_Timer
local Item = Item

-- Automation stops while the pause key is held, so you can read or decline a
-- quest by hand. NONE turns the pause off entirely.
function Module:IsPaused()
	local key = C.AutoQuest.PauseKey
	if key == "SHIFT" then
		return IsShiftKeyDown()
	elseif key == "CTRL" then
		return IsControlKeyDown()
	elseif key == "ALT" then
		return IsAltKeyDown()
	end
	return false
end

-- Repeatable quests (world quests, recurring turn-ins) are left alone by the
-- accept test below, since they are usually material deliveries you may not want.
function Module:IsRepeatable(questID)
	return C_QuestLog.IsWorldQuest(questID) or C_QuestLog.IsRepeatableQuest(questID)
end

-- Should we act on this quest at all? Respects the accept toggle, skips world
-- quests, and optionally skips trivial (grey) quests.
function Module:ShouldAccept(questID)
	if not questID or questID == 0 then
		return false
	end
	if C_QuestLog.IsWorldQuest(questID) then
		return false
	end
	if C.AutoQuest.IgnoreTrivial and C_QuestLog.IsQuestTrivial(questID) then
		return false
	end
	return true
end

-- Some quest data is not cached the first time an NPC window opens. Ask the
-- client to load it and re-run the handler once it arrives.
Module.questQueue = {}
function Module:WaitForQuestData(questID, callback)
	self.questQueue[questID] = callback
	C_QuestLog.RequestLoadQuestByID(questID)
end

function Module:OnQuestDataLoad(_, questID)
	local callback = self.questQueue[questID]
	if callback then
		self.questQueue[questID] = nil
		callback()
	end
end

-- Item values are needed to pick the best quest reward, and may also be cold.
function Module:WaitForItemData(itemID, callback)
	local item = Item:CreateFromItemID(itemID)
	item:ContinueOnItemLoad(callback)
end

-- Wired from the Automation module's OnEnable. Gated on its own toggle so the
-- rest of the module still runs when auto-quest is off.
function Module:SetupQuests()
	if not C.AutoQuest.Enable then
		return
	end

	-- A short delay after login lets the quest APIs settle before we hook in.
	C_Timer.After(1, function()
		self:RegisterEvent("QUEST_DATA_LOAD_RESULT", "OnQuestDataLoad")

		if self.SetupAccept then
			self:SetupAccept()
		end
		if self.SetupTurnIn then
			self:SetupTurnIn()
		end
		if self.SetupGossip then
			self:SetupGossip()
		end
	end)
end
