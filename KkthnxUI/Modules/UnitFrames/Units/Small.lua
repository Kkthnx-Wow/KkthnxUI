--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Units/Small.lua
	Purpose:
		The companion frames: pet, target of target, focus target. All three are
		the same shape, so one style covers them and looks up its own config by
		unit token.

		They carry a portrait and a name on the bar. No numbers at this size, the
		bar itself reads them. The pet reads left-to-right like the player it
		belongs to, so its portrait sits on the left; the others sit on the right.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build

local BY_UNIT = {
	pet = "Pet",
	targettarget = "TargetOfTarget",
	focustarget = "FocusTarget",
}

Module.Styles.Small = function(self, unit)
	local cfg = C.Unitframe[BY_UNIT[unit] or "Pet"]

	Module.EnableInteraction(self, unit)

	Build.Health(self, cfg.Height)
	Build.Power(self, Module.PowerHeight(cfg))
	Build.Portrait(self, unit == "pet" and "left" or "right")
	Build.NameCenter(self, 10)
	Build.Indicators(self, 12)
	Build.Range(self)

	-- Debuffs on a pet matter (they are yours to dispel), on a target of target
	-- they are noise, so this stays off unless the config asks for it.
	if cfg.Debuffs then
		Build.GroupDebuffs(self, 3, cfg.Height)
	end
end
