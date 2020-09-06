local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G
local table_concat = _G.table.concat
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe

local GetNumGroupMembers = _G.GetNumGroupMembers
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local UnitExists = _G.UnitExists
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName

local targetTable = {}
function Module:ScanTargets()
	if not C["Tooltip"].TargetBy then
		return
	end

	if not IsInGroup() then
		return
	end

	local _, unit = self:GetUnit()
	if not UnitExists(unit) then
		return
	end

	table_wipe(targetTable)

	for i = 1, GetNumGroupMembers() do
		local member = (IsInRaid() and "raid"..i or "party"..i)
		if UnitIsUnit(unit, member.."target") and not UnitIsUnit("player", member) and not UnitIsDeadOrGhost(member) then
			local color = K.RGBToHex(K.UnitColor(member))
			local name = color..UnitName(member).."|r"
			table_insert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(L["Targeted By"]..K.InfoColor.."("..#targetTable..")|r "..table_concat(targetTable, ", "), nil, nil, nil, 1)
	end
end

function Module:CreateTargetedInfo()
	GameTooltip:HookScript("OnTooltipSetUnit", Module.ScanTargets)
end