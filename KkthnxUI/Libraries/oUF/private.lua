local _, ns = ...
local oUF = ns.oUF
local Private = oUF.Private

function Private.argcheck(value, num, ...)
	assert(type(num) == 'number', "Bad argument #2 to 'argcheck' (number expected, got " .. type(num) .. ')')

	for i = 1, select('#', ...) do
		if(type(value) == select(i, ...)) then return end
	end

	local types = string.join(', ', ...)
	local name = debugstack(2,2,0):match(": in function [`<](.-)['>]")
	error(string.format("Bad argument #%d to '%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end

function Private.print(...)
	print('|cff33ff99oUF:|r', ...)
end

function Private.nierror(...)
	return geterrorhandler()(...)
end

function Private.xpcall(func, ...)
	return xpcall(func, Private.nierror, ...)
end

function Private.unitExists(unit)
	return unit and (UnitExists(unit) or UnitIsVisible(unit))
end

function Private.unitIsUnit(unit1, unit2)
	if C_Secrets and C_Secrets.CanCompareUnitTokens then
		if not C_Secrets.CanCompareUnitTokens(unit1, unit2) then
			return false
		end
	end

	local result = UnitIsUnit(unit1, unit2)
	if issecretvalue and issecretvalue(result) then
		return false
	end

	return result
end

local validator = CreateFrame('Frame')

function Private.validateEventUnit(unit)
	local isOK, _ = pcall(validator.RegisterUnitEvent, validator, 'UNIT_HEALTH', unit)
	if(isOK) then
		_, unit = validator:IsEventRegistered('UNIT_HEALTH')
		validator:UnregisterEvent('UNIT_HEALTH')

		return not not unit
	end
end

function Private.validateEvent(event)
	local isOK = xpcall(validator.RegisterEvent, Private.nierror, validator, event)
	if(isOK) then
		validator:UnregisterEvent(event)
	end

	return isOK
end

function Private.isUnitEvent(event, unit)
	local isOK = pcall(validator.RegisterUnitEvent, validator, event, unit)
	if(isOK) then
		validator:UnregisterEvent(event)
	end

	return isOK
end

local validSelectionTypes = {}
for _, selectionType in next, oUF.Enum.SelectionType do
	validSelectionTypes[selectionType] = selectionType
end

function Private.unitSelectionType(unit, considerHostile)
	if(considerHostile) then
		local threat = UnitThreatSituation('player', unit)
		if(issecretvalue(threat)) then
			return nil
		elseif(threat) then
			return 0
		end
	end

	local selection = UnitSelectionType(unit, true)
	if(issecretvalue(selection)) then
		return nil
	end

	return validSelectionTypes[selection]
end
