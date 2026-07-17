--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Identify player HELPFUL auras when spellId is secret under aura restrictions.
-- - Design: Ellesmere BM_IdentifySecretAura — plain filter fingerprint → curated spellID.
--   IsAuraFilteredOutByInstanceID returns a normal bool (SecretArguments only).
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local IsAuraFilteredOutByInstanceID = C_UnitAuras and C_UnitAuras.IsAuraFilteredOutByInstanceID
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo

-- Spec ID → { [signature] = spellID }. Signature bits:
-- RAID : RAID_IN_COMBAT : EXTERNAL_DEFENSIVE : RAID_PLAYER_DISPELLABLE
-- Curated spell IDs for AuraTrack (secret-safe lookup table).
local SPEC_SECRET_SIGS = {
	[105] = { ["1:1:1:0"] = 102342 }, -- Resto Druid — Ironbark
	[256] = { ["1:1:1:0"] = 33206, ["1:0:0:1"] = 10060 }, -- Disc — PS / PI
	[257] = { ["1:1:1:0"] = 47788, ["1:0:0:1"] = 10060 }, -- Holy — GS / PI
	[270] = { ["1:1:1:0"] = 116849, ["0:1:0:1"] = 443113 }, -- MW — Cocoon / SotBO
	[65] = { -- Holy Pala
		["1:1:1:1"] = 1022,
		["1:1:1:0"] = 6940,
		["1:0:0:1"] = 1044,
		["0:1:0:0"] = 432502,
	},
	[66] = { ["1:0:0:0"] = 1044 }, -- Prot Freedom fingerprint
	[70] = { ["1:0:0:0"] = 1044 }, -- Ret Freedom fingerprint
	[1468] = { ["1:1:1:0"] = 357170, ["1:1:0:0"] = 363534 }, -- Pres — Dil / Rewind
	[1473] = { ["0:1:0:0"] = 361022 }, -- Aug — Sense Power
}

-- Ellesmere: plain `not IsAuraFilteredOut…` — return is not SecretReturns.
local function AuraPassesFilter(unit, instanceID, filter)
	return not IsAuraFilteredOutByInstanceID(unit, instanceID, filter)
end

local function MakeSignature(unit, instanceID)
	local r = AuraPassesFilter(unit, instanceID, "PLAYER|HELPFUL|RAID")
	local ric = AuraPassesFilter(unit, instanceID, "PLAYER|HELPFUL|RAID_IN_COMBAT")
	if not r and not ric then
		return nil
	end
	local ext = AuraPassesFilter(unit, instanceID, "PLAYER|HELPFUL|EXTERNAL_DEFENSIVE")
	local disp = AuraPassesFilter(unit, instanceID, "PLAYER|HELPFUL|RAID_PLAYER_DISPELLABLE")
	return (r and "1" or "0") .. ":" .. (ric and "1" or "0") .. ":" .. (ext and "1" or "0") .. ":" .. (disp and "1" or "0")
end

function K.IdentifySecretPlayerAura(unit, auraInstanceID)
	if not (unit and auraInstanceID and IsAuraFilteredOutByInstanceID) then
		return nil
	end

	local specIndex = GetSpecialization and GetSpecialization()
	local specID = specIndex and GetSpecializationInfo and GetSpecializationInfo(specIndex)
	local sigs = specID and SPEC_SECRET_SIGS[specID]
	if not sigs then
		return nil
	end

	local sig = MakeSignature(unit, auraInstanceID)
	return sig and sigs[sig]
end
