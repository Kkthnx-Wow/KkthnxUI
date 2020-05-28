local K = unpack(select(2, ...))

local ACTIONBAR_FADER = {
	fadeInAlpha = 1,
	fadeInDuration = .3,
	fadeOutAlpha = .1,
	fadeOutDuration = .8,
	fadeOutDelay = .5,
}

K.ActionBars = {
	userPlaced = true,

	actionBar1 = {fader = nil},
	actionBar2 = {fader = nil},
	actionBar3 = {fader = nil},
	actionBar4 = {fader = ACTIONBAR_FADER},
	actionBar5 = {fader = ACTIONBAR_FADER},

	petBar = {fader = nil},
	stanceBar = {fader = nil},
	extraBar = {size = 56, fader = nil},
	leaveVehicle = {fader = nil},
}