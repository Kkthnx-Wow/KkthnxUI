--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Cooldown/Core.lua
	Purpose:
		Cooldown countdown numbers.

		Midnight note: on 12.1 the cooldown start/duration is a secret value for
		most cooldowns (action bars especially), so an addon can no longer read it
		to draw its own countdown text - our old OmniCC-style counter simply had
		nothing to read and showed nothing. Blizzard renders its own countdown
		numbers untainted, so we turn those on, and the button skins keep their
		SetHideCountdownNumbers in step with the cvar. These are the only cooldown
		numbers that can read the secret duration on Midnight.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("Cooldown")

local SetCVar = SetCVar

function Module:OnEnable()
	if not C.Cooldown.Enable then
		return
	end

	-- Blizzard's own countdown numbers, the only ones that can read the (secret)
	-- cooldown duration on Midnight.
	SetCVar("countdownForCooldowns", 1)
end
