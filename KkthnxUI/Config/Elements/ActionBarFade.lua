local _, C = unpack(select(2, ...))

local ACTIONBAR_FADER = {
	fadeInAlpha = 1, -- Transparency when displayed
	fadeInDuration = 0.2, -- Display time-consuming
	fadeOutAlpha = 0.1, -- Transparency after fade
	fadeOutDelay = 0.2, -- Delay fade
	fadeOutDuration = 0.2, -- Fading time-consuming
}

C.ActionBars = {
	margin = 2, -- Key spacing
	padding = 2, -- Edge spacing

	actionBar1 = {size = 34, fader = ACTIONBAR_FADER}, -- BAR1 Main action bar (below)
	actionBar2 = {size = 34, fader = ACTIONBAR_FADER}, -- BAR2 Main action bar (top)
	actionBar3 = {size = 32, fader = ACTIONBAR_FADER}, -- BAR3 Both sides of the main action bar
	actionBar4 = {size = 32, fader = ACTIONBAR_FADER}, -- BAR4 Right action bar 1
	actionBar5 = {size = 32, fader = ACTIONBAR_FADER}, -- BAR5 Right action bar 2
	actionBarCustom = {size = 34, fader = ACTIONBAR_FADER}, -- BARCUSTOM

	extraBar = {size = 52, fader = nil}, -- EXTRABAR Extra action bar
	leaveVehicle = {size = 32, fader = nil}, -- VEHICLE EXIT Leave vehicle button
	petBar = {size = 26, fader = ACTIONBAR_FADER}, -- PETBAR Pet action bar
	stanceBar = {size = 30, fader = ACTIONBAR_FADER}, -- STANCE + POSSESSBAR Posture bar
}