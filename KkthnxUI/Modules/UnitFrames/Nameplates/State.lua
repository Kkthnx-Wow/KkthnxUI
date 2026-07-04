--[[-----------------------------------------------------------------------------
-- Shared nameplate module state (tables, caches). Loaded before Nameplates.lua.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

Module.NP = Module.NP or {
	mdtCacheData = {},
	customUnits = {},
	groupRoles = {},
	showPowerList = {},
	isInGroup = false,
	isInInstance = false,
	targetTokenCache = {},
	executedCurve = nil,
	platesList = {},
}

Module.NP.ShowTargetNPCs = C.NameplateTargetNPCs

Module.NP.NPClassifies = {
	elite = { atlas = "VignetteKillElite", color = { 1, 1, 1 } },
	rare = { atlas = "VignetteKill", color = { 1, 1, 1 }, desaturate = true },
	rareelite = { atlas = "VignetteKillElite", color = { 1, 0.1, 0.1 } },
	worldboss = { atlas = "VignetteKillElite", color = { 0, 1, 0 } },
}
