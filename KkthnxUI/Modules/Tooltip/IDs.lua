--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/IDs.lua
	Purpose:
		Append the spell, item, currency, mount, and aura id to the bottom of a
		tooltip. Uses the modern TooltipDataProcessor post calls plus a SetUnitAura
		hook for auras, so it stays flavor safe. Ids that arrive as secret values in
		Midnight are skipped rather than shown.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Tooltip")

local _G = _G
local IsSecret = K.IsSecret

local ID_COLOR = { K.Colors.info[1], K.Colors.info[2], K.Colors.info[3] }

-- Append "<label>: <id>" once. AddDoubleLine puts the id on the right, coloured.
local function AddID(tt, label, id)
	if not id or IsSecret(id) then
		return
	end
	tt:AddDoubleLine(label, tostring(id), 0.7, 0.7, 0.7, ID_COLOR[1], ID_COLOR[2], ID_COLOR[3])
	tt:Show()
end

function Module:SetupIDs()
	if not C.Tooltip.ShowIDs then
		return
	end
	if not (TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType) then
		return
	end

	local DT = Enum.TooltipDataType

	local function onSpell(tt, data)
		if not tt:IsForbidden() and data and data.id then
			AddID(tt, "Spell ID", data.id)
		end
	end
	if DT.Spell then
		TooltipDataProcessor.AddTooltipPostCall(DT.Spell, onSpell)
	end

	local function onItem(tt, data)
		if not tt:IsForbidden() and data and data.id then
			AddID(tt, "Item ID", data.id)
		end
	end
	if DT.Item then
		TooltipDataProcessor.AddTooltipPostCall(DT.Item, onItem)
	end
	if DT.Toy then
		TooltipDataProcessor.AddTooltipPostCall(DT.Toy, onItem)
	end

	if DT.Currency then
		TooltipDataProcessor.AddTooltipPostCall(DT.Currency, function(tt, data)
			if not tt:IsForbidden() and data and data.id then
				AddID(tt, "Currency ID", data.id)
			end
		end)
	end

	if DT.Mount then
		TooltipDataProcessor.AddTooltipPostCall(DT.Mount, function(tt, data)
			if not tt:IsForbidden() and data and data.id then
				AddID(tt, "Mount ID", data.id)
			end
		end)
	end

	-- Aura spell id, read from the structured aura data behind the tooltip.
	if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
		hooksecurefunc(_G.GameTooltip, "SetUnitAura", function(tt, unit, index, filter)
			if tt:IsForbidden() then
				return
			end
			local aura = K.GetAuraData(unit, index, filter)
			if aura and aura.spellId then
				AddID(tt, "Spell ID", aura.spellId)
			end
		end)
	end
end
