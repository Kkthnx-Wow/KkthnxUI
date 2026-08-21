--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/MountSource.lua
	Purpose:
		Hold Shift over another player's mount buff and the tooltip gains the
		mount's collection status and where it drops, so you can tell at a glance
		whether the mount someone is riding is one you still need.

		Reads the aura's spell id from the structured aura data behind the tooltip
		(never the visible text) and guards every value against Midnight secrets,
		so an instanced aura tooltip cannot error here.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Tooltip")

local _G = _G
local select = select
local IsSecret = K.IsSecret

local C_MountJournal = C_MountJournal
local C_UnitAuras = C_UnitAuras
local IsShiftKeyDown = IsShiftKeyDown
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit

local COLLECTED = COLLECTED
local NOT_COLLECTED = NOT_COLLECTED
local SOURCE = SOURCE

-- spell id -> { source, index }, with false cached for non-mount spells so the
-- journal is never re-queried for the same aura.
local mountCache = {}

local function MountInfoBySpell(spell)
	if mountCache[spell] == nil then
		mountCache[spell] = false
		local index = C_MountJournal.GetMountFromSpell(spell)
		if index then
			local _, mSpell = C_MountJournal.GetMountInfoByID(index)
			if spell == mSpell then
				local _, _, source = C_MountJournal.GetMountInfoExtraByID(index)
				mountCache[spell] = { source = source, index = index }
			end
		end
	end
	return mountCache[spell] or nil
end

local function IsCollected(info)
	-- 11th return of GetMountInfoByID is isCollected.
	return select(11, C_MountJournal.GetMountInfoByID(info.index)) and true or false
end

-- Scan the tooltip's left texts for a line, so the source block is added once.
-- The secret guard comes first: string ops throw on a secret line.
local function HasLine(tt, text)
	for i = 1, tt:NumLines() do
		local line = _G[tt:GetName() .. "TextLeft" .. i]
		local str = line and line:GetText()
		if str and not IsSecret(str) and str == text then
			return true
		end
	end
	return false
end

local function AddSourceLines(tt, info)
	if HasLine(tt, SOURCE) then
		return
	end
	tt:AddLine(" ")
	tt:AddDoubleLine(SOURCE, IsCollected(info) and COLLECTED or NOT_COLLECTED)
	if info.source then
		tt:AddLine(info.source, 1, 1, 1)
	end
	tt:Show()
end

-- Annotate only while Shift is held over another player (not yourself).
local function HandleAura(tt, unit, spellID)
	if not C.Tooltip.ShowMountSource then
		return
	end
	if not spellID or IsSecret(spellID) then
		return
	end
	if not IsShiftKeyDown() or not unit then
		return
	end
	if not UnitIsPlayer(unit) or UnitIsUnit(unit, "player") then
		return
	end

	local info = MountInfoBySpell(spellID)
	if info then
		AddSourceLines(tt, info)
	end
end

function Module:SetupMountSource()
	if self.mountSourceHooked then
		return
	end
	if not (C_MountJournal and C_UnitAuras) then
		return
	end
	self.mountSourceHooked = true

	hooksecurefunc(_G.GameTooltip, "SetUnitAura", function(tt, unit, ...)
		if tt:IsForbidden() then
			return
		end
		local data = K.GetAuraData(unit, ...)
		if not data or IsSecret(data) then
			return
		end
		HandleAura(tt, unit, data.spellId)
	end)

	if _G.GameTooltip.SetUnitBuffByAuraInstanceID then
		hooksecurefunc(_G.GameTooltip, "SetUnitBuffByAuraInstanceID", function(tt, unit, auraInstanceID)
			if tt:IsForbidden() then
				return
			end
			local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
			if not data or IsSecret(data) then
				return
			end
			HandleAura(tt, unit, data.spellId)
		end)
	end
end
