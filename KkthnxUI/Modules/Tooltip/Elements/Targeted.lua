local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Tooltip")

local wipe, tinsert, tconcat = table.wipe, table.insert, table.concat
local IsInGroup, IsInRaid, GetNumGroupMembers = IsInGroup, IsInRaid, GetNumGroupMembers
local UnitExists, UnitIsUnit, UnitIsDeadOrGhost, UnitName = UnitExists, UnitIsUnit, UnitIsDeadOrGhost, UnitName

local targetTable = {}

function Module:ScanTargets(unit)
	if not C["Tooltip"].TargetBy then
		return
	end
	if not IsInGroup() then
		return
	end
	if not UnitExists(unit) then
		return
	end

	wipe(targetTable)

	local isInRaid = IsInRaid()
	for i = 1, GetNumGroupMembers() do
		local member = (isInRaid and "raid" .. i or "party" .. i)
		if UnitIsUnit(unit, member .. "target") and not UnitIsUnit("player", member) and not UnitIsDeadOrGhost(member) then
			local color = K.RGBToHex(K.UnitColor(member))
			local name = color .. UnitName(member) .. "|r"
			tinsert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(L["Targeted By"] .. K.InfoColor .. "(" .. #targetTable .. ")|r " .. tconcat(targetTable, ", "), nil, nil, nil, 1)
	end
end
