--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Registers KkthnxUI's oUF frames with BigDebuffs for full unit-frame support.
-- - Design: Injects a "KkthnxUI" anchor entry into BigDebuffs.anchors after the addon
--           loads, mirroring the same pattern used by NDui. Uses GUID lookup for party
--           and arena frames (same as NDuiFrames resolver) since they are header children.
-- - Events: N/A (uses Module:RegisterSkin deferred load via ADDON_LOADED)
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

-- PERF: Localize frequently used globals.
local _G = _G
local pairs = pairs
local UnitGUID = _G.UnitGUID

-- ---------------------------------------------------------------------------
-- Anchor Resolver
-- ---------------------------------------------------------------------------

-- REASON: BigDebuffs calls this function with the raw anchor string from the units
-- table and expects either a single frame (the anchor point for the debuff icon) or
-- (anchorFrame, parentFrame, noPortrait) to be returned.
-- For single frames like oUF_Player, oUF_Target etc. we return the frame directly.
-- For party / arena children we must look up by GUID because the header children are
-- not individually named by unit in oUF (they carry their unit at runtime).
local function GetKKUIAnchor(anchor)
	local anchors = BigDebuffs.anchors
	if not anchors or not anchors.KkthnxUI then
		return
	end

	local units = anchors.KkthnxUI.units
	local unit

	-- REASON: Reverse-lookup the unit token for this anchor string so we know
	-- which GUID to compare against header children.
	for u, configAnchor in pairs(units) do
		if anchor == configAnchor then
			unit = u
			break
		end
	end

	if not unit then
		-- REASON: Fallback for simple single-frame globals (player, target, etc.).
		return _G[anchor]
	end

	-- REASON: Party frames are spawned under a SecureGroupHeader — children are NOT
	-- individually named by unit, so we resolve by matching the unit's GUID against
	-- each visible child button, exactly as NDui's GetAnchor.NDuiFrames does it.
	if unit:match("^party") or unit:match("^player") then
		local unitGUID = UnitGUID(unit)
		if not unitGUID then
			return
		end

		for i = 1, 5 do
			local oUFFrame = _G["oUF_PartyUnitButton" .. i]
			if oUFFrame and oUFFrame:IsVisible() and oUFFrame.unit then
				if unitGUID == UnitGUID(oUFFrame.unit) then
					return oUFFrame, oUFFrame, true
				end
			end
		end
		return
	end

	-- REASON: Arena frames are individually spawned with names oUF_Arena1..5, so
	-- a GUID match is still the safest approach (visibility / unit may shift mid-game).
	if unit:match("^arena") then
		local unitGUID = UnitGUID(unit)
		if not unitGUID then
			return
		end

		for i = 1, 5 do
			local oUFFrame = _G["oUF_Arena" .. i]
			if oUFFrame and oUFFrame:IsVisible() and oUFFrame.unit then
				if unitGUID == UnitGUID(oUFFrame.unit) then
					return oUFFrame, oUFFrame, true
				end
			end
		end
		return
	end

	-- REASON: All remaining units (player, target, pet, focus) have stable global names.
	return _G[anchor]
end

-- ---------------------------------------------------------------------------
-- Integration
-- ---------------------------------------------------------------------------

local function RegisterBigDebuffs()
	if not C["Skins"].BigDebuffs then
		return
	end

	-- WARNING: BigDebuffs must be fully initialized before we touch anchors.
	-- RegisterSkin defers until ADDON_LOADED fires for "BigDebuffs", so by the
	-- time this runs BigDebuffs.anchors is guaranteed to exist.
	if not _G.BigDebuffs or not BigDebuffs.anchors then
		return
	end

	-- REASON: Inject our anchor block. noPortrait = true because oUF frames don't
	-- use a separate portrait sub-frame — BigDebuffs places the icon directly on the
	-- health bar region of the returned frame. alignLeft = false (default) so the icon
	-- anchors to the right side of the frame, matching the NDui layout.
	BigDebuffs.anchors["KkthnxUI"] = {
		func = GetKKUIAnchor,
		noPortait = true, -- REASON: Matches NDui's noPortait flag — no separate portrait frame.
		units = {
			-- Single-frame units: anchor string IS the global name.
			player = "oUF_Player",
			pet = "oUF_Pet",
			target = "oUF_Target",
			focus = "oUF_Focus",
			-- Party: anchor strings are used as keys into GetKKUIAnchor's reverse-lookup.
			-- Children of oUF_Party header are resolved by GUID at runtime.
			party1 = "oUF_PartyUnitButton2",
			party2 = "oUF_PartyUnitButton3",
			party3 = "oUF_PartyUnitButton4",
			party4 = "oUF_PartyUnitButton5",
			-- Arena: individually spawned globals, resolved by GUID.
			arena1 = "oUF_Arena1",
			arena2 = "oUF_Arena2",
			arena3 = "oUF_Arena3",
			arena4 = "oUF_Arena4",
			arena5 = "oUF_Arena5",
		},
	}
end

-- REASON: Use the standard RegisterSkin deferred mechanism so this only runs
-- after BigDebuffs has fully loaded and initialized its anchors table.
Module:RegisterSkin("BigDebuffs", RegisterBigDebuffs)
