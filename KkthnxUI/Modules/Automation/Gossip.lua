--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/Gossip.lua
	Purpose:
		Click through a lone gossip option so single-step NPCs (flight masters
		aside) do not need a second click. Skipped when the NPC is a quest giver,
		a taxi node, or inside a raid, to avoid clicking past something that
		matters. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Automation")

local IsSecret = K.IsSecret
local C_GossipInfo = C_GossipInfo
local C_PlayerInteractionManager = C_PlayerInteractionManager
local Enum = Enum
local GetInstanceInfo = GetInstanceInfo

-- Called from the gossip accept handler, after any quests have been dealt with.
function Module:HandleGossipSkip()
	if self:IsPaused() or not C.AutoQuest.SkipGossip then
		return
	end

	-- Leave taxi nodes to the flight-map, never auto-click those.
	if C_PlayerInteractionManager and C_PlayerInteractionManager.IsInteractingWithNpcOfType and Enum.PlayerInteractionType then
		if C_PlayerInteractionManager.IsInteractingWithNpcOfType(Enum.PlayerInteractionType.TaxiNode) then
			return
		end
	end

	-- A quest giver: the quest handler already ran, do not skip its gossip.
	if (C_GossipInfo.GetNumActiveQuests() + C_GossipInfo.GetNumAvailableQuests()) > 0 then
		return
	end

	local options = C_GossipInfo.GetOptions()
	if not options or #options ~= 1 then
		return
	end

	local optionID = options[1].gossipOptionID
	if not optionID or IsSecret(optionID) then
		return
	end

	-- Inside a raid a lone option is often a story or pull trigger, so leave it.
	local _, instanceType = GetInstanceInfo()
	if instanceType == "raid" then
		return
	end

	C_GossipInfo.SelectOption(optionID)
end

function Module:SetupGossip()
	-- No event of its own: HandleGossipSkip runs from the gossip accept handler.
end
