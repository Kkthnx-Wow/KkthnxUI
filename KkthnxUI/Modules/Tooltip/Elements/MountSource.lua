--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays mount source information in aura tooltips.
-- - Design: Hooks aura tooltips to append collection status and source info.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Tooltip")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local select = _G.select
local hooksecurefunc = _G.hooksecurefunc

local AuraUtil = _G.AuraUtil
local C_AddOns = _G.C_AddOns
local C_MountJournal = _G.C_MountJournal
local C_UnitAuras = _G.C_UnitAuras
local GameTooltip = _G.GameTooltip
local IsShiftKeyDown = _G.IsShiftKeyDown
local UnitIsPlayer = _G.UnitIsPlayer
local UnitName = _G.UnitName

local COLLECTED = _G.COLLECTED
local NOT_COLLECTED = _G.NOT_COLLECTED
local SOURCE = _G.SOURCE

local MountTable = {}

-- Function to check if a mount is collected
-- REASON: Logic to check if a mount is already collected by the player.
local function IsCollected(spell)
	local mountInfo = MountTable[spell]
	if mountInfo then
		return select(11, C_MountJournal.GetMountInfoByID(mountInfo.index))
	end
	return false
end

local function GetMountInfoBySpell(spell)
	if not MountTable[spell] then
		local index = C_MountJournal.GetMountFromSpell(spell)
		if index then
			local _, mSpell = C_MountJournal.GetMountInfoByID(index)
			if spell == mSpell then
				local _, _, source = C_MountJournal.GetMountInfoExtraByID(index)
				MountTable[spell] = { source = source, index = index }
			end
		end
	end
	return MountTable[spell]
end

-- REASON: Appends mount information to the tooltip.
local function AddLine(self, source, isCollectedText, type, noadd)
	for i = 1, self:NumLines() do
		local line = _G[self:GetName() .. "TextLeft" .. i]
		if line then
			local text = line:GetText()
			if text == type then
				return
			end
		end
	end

	if not noadd then
		self:AddLine(" ")
	end

	self:AddDoubleLine(type, isCollectedText)
	self:AddLine(source, 1, 1, 1)
	self:Show()
end

local function HandleAura(self, id)
	if IsShiftKeyDown() and UnitIsPlayer("target") and UnitName("target") ~= K.Name then
		local mountInfo = id and GetMountInfoBySpell(id)
		if mountInfo then
			AddLine(self, mountInfo.source, IsCollected(id) and COLLECTED or NOT_COLLECTED, SOURCE)
		end
	end
end

function Module:CreateMountSource()
	if C_AddOns.IsAddOnLoaded("MountsSource") then
		return
	end

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
		local spellID = select(10, AuraUtil.UnpackAuraData(C_UnitAuras.GetAuraDataByIndex(...)))
		local table = spellID and GetMountInfoBySpell(spellID)
		if table then
			HandleAura(self, spellID)
		end
	end)

	hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", function(self, unit, auraInstanceID)
		local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
		if not data then
			return
		end

		local table = data.spellId and GetMountInfoBySpell(data.spellId)
		if table then
			HandleAura(self, data.spellId)
		end
	end)
end
