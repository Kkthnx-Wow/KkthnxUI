local _, ns = ...
ns.oUF = {}
ns.oUF.Private = {}

-- Compatibility shims for older flavours (TBC Anniversary and friends). This core
-- was updated from a Midnight/retail source and calls a handful of globals as bare
-- functions that simply do not exist there, which would throw the moment an element
-- updates. Define harmless fallbacks so those flavours degrade gracefully instead.
-- On retail every one of these already exists, so none of the branches run.
if not issecretvalue then
	_G.issecretvalue = function()
		return false
	end
end
if not UnitInPartyIsAI then
	_G.UnitInPartyIsAI = function()
		return false
	end
end
if not UnitPhaseReason then
	_G.UnitPhaseReason = function()
		return nil
	end
end
if not UnitIsQuestBoss then
	_G.UnitIsQuestBoss = function()
		return nil
	end
end
