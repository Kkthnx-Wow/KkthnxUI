--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Units/Player.lua
	Purpose:
		The player frame. Portrait on the left, health and power stacked, class
		resource above, debuffs above that, and a free floating castbar down by
		the action bars the way the original KkthnxUI had it.

		No name text here on purpose. You know who you are.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build

Module.Styles.Player = function(self)
	local cfg = C.Unitframe.Player
	local castbar = C.Unitframe.Castbar

	Module.EnableInteraction(self, "player")

	Build.Health(self, cfg.Height)
	Build.Power(self, Module.PowerHeight(cfg))
	Build.HealthText(self, 13)
	Build.PowerText(self, 11)

	Build.Portrait(self, "left")
	Build.PortraitLevel(self)

	if cfg.ShowName then
		Build.Name(self, 12)
	end

	if cfg.AdditionalPower then
		Build.AdditionalPower(self)
	end

	Build.Indicators(self)
	Build.PlayerIndicators(self)

	-- Upward stack, in the order they leave the health bar. Only one of the three
	-- resource builders does anything for a given class.
	if cfg.ClassPower then
		Build.Runes(self)
		Build.ClassPower(self)
		Build.Stagger(self)
	end
	Build.Auras(self, cfg)

	Build.DetachedCastbar(self, "PlayerCastbar", "Player Castbar", castbar.PlayerWidth, castbar.PlayerHeight, { "BOTTOM", UIParent, "BOTTOM", 0, 240 }, "left")
end
