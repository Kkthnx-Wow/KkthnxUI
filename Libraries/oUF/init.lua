local _, ns = ...
ns.oUF = {}
ns.oUF.Private = {}

local oUF = ns.oUF

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
if not issecrettable then
	_G.issecrettable = function()
		return false
	end
end
if not canaccessvalue then
	_G.canaccessvalue = function()
		return true
	end
end

-- Midnight secrets API. On 12.x the client returns secret values and hides some
-- unit identities from tainted code. These helpers wrap the client probes so the
-- elements can ask "is this safe to read or compare" in one place, degrading to
-- "not secret / accessible" on flavours that predate the system.
local issecretvalue = issecretvalue
local issecrettable = issecrettable
local canaccessvalue = canaccessvalue
local ShouldUnitIdentityBeSecret = C_Secrets and C_Secrets.ShouldUnitIdentityBeSecret

function oUF:IsSecretUnit(unit)
	return ShouldUnitIdentityBeSecret and ShouldUnitIdentityBeSecret(unit) or false
end

function oUF:NotSecretUnit(unit)
	return not oUF:IsSecretUnit(unit)
end

function oUF:IsSecretValue(value)
	return issecretvalue and issecretvalue(value) or false
end

function oUF:NotSecretValue(value)
	return not oUF:IsSecretValue(value)
end

function oUF:IsSecretTable(object)
	return issecrettable and issecrettable(object) or false
end

function oUF:NotSecretTable(object)
	return not oUF:IsSecretTable(object)
end

function oUF:CanAccessValue(value)
	return not canaccessvalue or canaccessvalue(value)
end

function oUF:CanNotAccessValue(value)
	return not oUF:CanAccessValue(value)
end
