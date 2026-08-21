--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Units/Boss.lua
	Purpose:
		Boss and arena style frames. Narrow bars stacked down the right side of
		the screen with the name on the bar, debuffs fanning out to the left, and
		an attached castbar so you can tell which of five casters is the problem.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build

Module.Styles.Boss = function(self)
	local cfg = C.Unitframe.Boss

	Module.EnableInteraction(self, "boss")

	Build.Health(self, cfg.Height)
	Build.Power(self, Module.PowerHeight(cfg))

	-- Name on the gradient strip above health, numbers on the power bar. Five of
	-- these stacked up is already busy, so nothing shares a bar with anything else.
	Build.Name(self, 11)
	Build.PowerText(self, 9)

	Build.AlternativePower(self)
	Build.Indicators(self, 14)
	Build.Range(self)

	if cfg.Debuffs then
		Build.GroupDebuffs(self, 4, cfg.Height - 2)
	end

	if cfg.Castbar then
		Build.Castbar(self, 14, "right")
	end
end
