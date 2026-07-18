--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Highlights unit frames based on dispellable debuffs.
-- - Design: Prefer Blizzard RAID_PLAYER_DISPELLABLE when filtering; color via
--   GetAuraDispelTypeColor / name table (DebuffTypeColor is gone in Midnight).
-- - Events: UNIT_AURA, PLAYER_TALENT_UPDATE.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local oUF = K.oUF

local _G = _G
local ipairs = _G.ipairs
local UnitCanAssist = _G.UnitCanAssist
local GetSpecialization = _G.GetSpecialization
local C_UnitAuras_GetAuraDataByIndex = _G.C_UnitAuras.GetAuraDataByIndex

local CanDispel = {
	["DRUID"] = {
		["Magic"] = false,
		["Curse"] = true,
		["Poison"] = true,
	},
	["MONK"] = {
		["Magic"] = true,
		["Poison"] = true,
		["Disease"] = true,
	},
	["PALADIN"] = {
		["Magic"] = false,
		["Poison"] = true,
		["Disease"] = true,
	},
	["PRIEST"] = {
		["Magic"] = true,
		["Disease"] = true,
	},
	["SHAMAN"] = {
		["Magic"] = false,
		["Curse"] = true,
	},
	["MAGE"] = {
		["Curse"] = true,
	},
	["EVOKER"] = {
		["Magic"] = false,
		["Poison"] = true,
	},
}

local dispellist = CanDispel[K.Class] or {}
local origColors = {}

local NotSecret = K.NotSecret

-- Clear state matches CreateDebuffHighlight (invisible ADD overlay).
local CLEAR_R, CLEAR_G, CLEAR_B, CLEAR_A = 0, 0, 0, 0

local function GetDebuffType(unitToken, filter)
	if not UnitCanAssist("player", unitToken) then
		return nil
	end

	-- Filtered: Blizzard scopes to what we can dispel (no false Magic from undispellables).
	local auraFilter = filter and "HARMFUL|RAID_PLAYER_DISPELLABLE" or "HARMFUL"

	local i = 1
	while true do
		local aura = C_UnitAuras_GetAuraDataByIndex(unitToken, i, auraFilter)
		if not aura then
			break
		end

		local dispelName = aura.dispelName
		if NotSecret(dispelName) and dispelName then
			-- Unfiltered: only typed auras. Filtered: Blizzard already gated capability.
			if filter or dispellist[dispelName] then
				return dispelName, aura.icon, aura.auraInstanceID
			end
		elseif aura.auraInstanceID then
			local resolved = K.GetAuraDispelTypeName(unitToken, aura.auraInstanceID, oUF)
			if filter then
				-- Dispellable per Blizzard; type name only needed for color.
				return resolved or "Magic", aura.icon, aura.auraInstanceID
			elseif resolved then
				return resolved, aura.icon, aura.auraInstanceID
			end
		end

		i = i + 1
	end
end

local function CheckSpec()
	if K.Class == "DRUID" then
		dispellist.Magic = GetSpecialization() == 4
	elseif K.Class == "MONK" then
		dispellist.Magic = GetSpecialization() == 2
	elseif K.Class == "PALADIN" then
		dispellist.Magic = GetSpecialization() == 1
	elseif K.Class == "SHAMAN" then
		dispellist.Magic = GetSpecialization() == 3
	elseif K.Class == "EVOKER" then
		dispellist.Magic = GetSpecialization() == 2
	end
end

local function ClearHighlight(object)
	if object.DebuffHighlightUseTexture then
		object.DebuffHighlight:SetTexture(nil)
		return
	end
	local color = origColors[object]
	if color then
		object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
	else
		object.DebuffHighlight:SetVertexColor(CLEAR_R, CLEAR_G, CLEAR_B, CLEAR_A)
	end
end

local function Update(object, _, unit)
	if object.unit ~= unit then
		return
	end

	local debuffType, texture, auraInstanceID = GetDebuffType(unit, object.DebuffHighlightFilter)
	if debuffType then
		if object.DebuffHighlightUseTexture then
			object.DebuffHighlight:SetTexture(texture)
		else
			local r, g, b = K.GetAuraDispelBorderRGB(unit, auraInstanceID, oUF)
			if not r then
				local typeColors = K.GetDebuffTypeColorTable(oUF)
				local color = typeColors[debuffType] or typeColors.none
				r, g, b = color.r, color.g, color.b
			end
			object.DebuffHighlight:SetVertexColor(r, g, b, object.DebuffHighlightAlpha or 0.5)
		end
	else
		ClearHighlight(object)
	end
end

local function Enable(object)
	if not object.DebuffHighlight then
		return
	end

	if object.DebuffHighlightFilter and not CanDispel[K.Class] then
		return
	end

	object:RegisterEvent("UNIT_AURA", Update)
	object:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec, true)
	CheckSpec()

	if not object.DebuffHighlightUseTexture then
		-- Always store the invisible baseline — never capture a live highlight tint.
		origColors[object] = { r = CLEAR_R, g = CLEAR_G, b = CLEAR_B, a = CLEAR_A }
		object.DebuffHighlight:SetVertexColor(CLEAR_R, CLEAR_G, CLEAR_B, CLEAR_A)
	end

	return true
end

local function Disable(object)
	if object.DebuffHighlight then
		object:UnregisterEvent("UNIT_AURA", Update)
		object:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
		ClearHighlight(object)
	end
end

oUF:AddElement("DebuffHighlight", Update, Enable, Disable)

for _, frame in ipairs(oUF.objects) do
	Enable(frame)
end
