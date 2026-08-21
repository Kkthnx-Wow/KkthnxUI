--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Units/Target.lua
	Purpose:
		Target and focus. Both are the player frame mirrored: portrait on the
		right, name above health, debuffs above the name, buffs below, and a
		detached castbar.

		Focus is the same shape at a smaller size, so the two share one builder.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build

local function BuildMirrored(self, cfg, nameSize, style)
	Module.EnableInteraction(self, style)

	Build.Health(self, cfg.Height)
	Build.Power(self, Module.PowerHeight(cfg))
	Build.HealthText(self, nameSize + 1)
	Build.PowerText(self, 11)

	Build.Portrait(self, "right")
	Build.PortraitLevel(self)

	Build.Indicators(self)
	Build.QuestIndicator(self)
	Build.Range(self)

	-- Name first so it sits directly above health, then the aura panels on top.
	Build.Name(self, nameSize)
	Build.Auras(self, cfg)
end

Module.Styles.Target = function(self)
	local cfg = C.Unitframe.Target
	local castbar = C.Unitframe.Castbar

	BuildMirrored(self, cfg, 12, "target")

	Build.DetachedCastbar(self, "TargetCastbar", "Target Castbar", castbar.TargetWidth, castbar.TargetHeight, { "BOTTOM", UIParent, "BOTTOM", 0, 420 }, "right")
end

Module.Styles.Focus = function(self)
	local cfg = C.Unitframe.Focus
	local castbar = C.Unitframe.Castbar

	BuildMirrored(self, cfg, 11, "focus")

	Build.DetachedCastbar(self, "FocusCastbar", "Focus Castbar", castbar.FocusWidth, castbar.FocusHeight, { "BOTTOM", UIParent, "BOTTOM", 0, 520 }, "right")
end
