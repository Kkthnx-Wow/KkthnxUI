--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Secret-safe dispel-type icon on raid frames.
-- - Design: Multi-atlas icon driven by per-type ColorCurve alpha; no dispelName read.
-- - Events: UNIT_AURA on each raid frame.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = CreateFrame
local pairs = pairs
local next = next

local C_UnitAuras = C_UnitAuras
local GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local GetAuraDispelTypeColor = C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor

local DISPEL_ICON_ATLAS = {
	[1] = "RaidFrame-Icon-DebuffMagic",
	[2] = "RaidFrame-Icon-DebuffCurse",
	[3] = "RaidFrame-Icon-DebuffDisease",
	[4] = "RaidFrame-Icon-DebuffPoison",
	[9] = "RaidFrame-Icon-DebuffBleed",
	[11] = "RaidFrame-Icon-DebuffBleed",
}

local function hideDispelIcon(frame)
	local icon = frame.RaidDispelIcon
	local textures = frame.RaidDispelIconTextures
	if not icon then
		return
	end
	frame.RaidDispelInstanceID = nil
	if textures then
		for _, tex in pairs(textures) do
			tex:Hide()
		end
	end
	icon:Hide()
end

local function applyDispelIcon(frame, unit, instanceID)
	local icon = frame.RaidDispelIcon
	local textures = frame.RaidDispelIconTextures
	if not (icon and textures and instanceID and GetAuraDispelTypeColor) then
		hideDispelIcon(frame)
		return
	end

	local shownAny = false
	for idx, tex in pairs(textures) do
		local curve = K.GetDispelIconCurve(idx)
		local col = curve and GetAuraDispelTypeColor(unit, instanceID, curve)
		if col then
			if col.GetRGBA then
				tex:SetVertexColor(col:GetRGBA())
			elseif col.GetRGB then
				local r, g, b = col:GetRGB()
				tex:SetVertexColor(r, g, b, 1)
			elseif col.r then
				tex:SetVertexColor(col.r, col.g, col.b, col.a or 1)
			end
			tex:Show()
			shownAny = true
		else
			tex:Hide()
		end
	end

	if not shownAny and textures[1] then
		textures[1]:SetVertexColor(1, 1, 1, 1)
		textures[1]:Show()
	end

	icon:Show()
end

local function isAuraDispellableByCurve(unit, instanceID)
	if not (GetAuraDispelTypeColor and instanceID) then
		return false
	end
	for idx in pairs(DISPEL_ICON_ATLAS) do
		local curve = K.GetDispelIconCurve(idx)
		if curve and GetAuraDispelTypeColor(unit, instanceID, curve) then
			return true
		end
	end
	return false
end

local function findDispellableAura(unit, showAll)
	if not GetAuraDataByIndex then
		return nil
	end

	-- RAID_PLAYER_DISPELLABLE already scopes player-dispellable; no dispelName read.
	local filter = showAll and "HARMFUL" or "HARMFUL|RAID_PLAYER_DISPELLABLE"
	local i = 1
	while true do
		local auraData = GetAuraDataByIndex(unit, i, filter)
		if not auraData then
			break
		end
		i = i + 1
		local instanceID = auraData.auraInstanceID
		if not showAll then
			return instanceID
		end
		if isAuraDispellableByCurve(unit, instanceID) then
			return instanceID
		end
	end
end

local function updateRaidDispelIcon(frame, _, unit)
	if frame.unit ~= unit or not frame.unit then
		return
	end

	-- REASON: Section is configurable so Raid/SimpleParty (and any future clone) can
	-- each carry their own DispelIcon/DispelIconAll toggle instead of hardcoding "Raid".
	local section = frame.RaidDispelConfigSection or "Raid"
	local sectionConfig = C[section]

	if not sectionConfig or not sectionConfig.DispelIcon then
		hideDispelIcon(frame)
		return
	end

	local instanceID = findDispellableAura(unit, sectionConfig.DispelIconAll ~= false)
	if not instanceID then
		hideDispelIcon(frame)
		return
	end

	if frame.RaidDispelInstanceID == instanceID then
		return
	end

	frame.RaidDispelInstanceID = instanceID
	applyDispelIcon(frame, unit, instanceID)
end

function Module:CreateRaidDispelIcon(frame, configSection)
	configSection = configSection or "Raid"
	local sectionConfig = C[configSection]
	if not sectionConfig or not sectionConfig.DispelIcon then
		return
	end

	local health = frame.Health
	if not health then
		return
	end

	local icon = CreateFrame("Frame", nil, frame)
	icon:SetSize(14, 14)
	icon:SetPoint("TOPRIGHT", health, "TOPRIGHT", 1, 1)
	icon:SetFrameLevel(frame:GetFrameLevel() + 6)
	icon:Hide()

	local textures = {}
	for idx, atlas in pairs(DISPEL_ICON_ATLAS) do
		local tex = icon:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		tex:SetAtlas(atlas)
		tex:Hide()
		textures[idx] = tex
	end

	frame.RaidDispelIcon = icon
	frame.RaidDispelIconTextures = textures
	frame.RaidDispelInstanceID = nil
	frame.RaidDispelConfigSection = configSection

	frame:RegisterEvent("UNIT_AURA", updateRaidDispelIcon, true)
end

function Module:RefreshRaidDispelIcons()
	local oUF = K.oUF
	if not (oUF and oUF.objects) then
		return
	end

	for _, frame in next, oUF.objects do
		if frame.RaidDispelIcon and frame.unit then
			frame.RaidDispelInstanceID = nil
			updateRaidDispelIcon(frame, "UNIT_AURA", frame.unit)
		end
	end
end
