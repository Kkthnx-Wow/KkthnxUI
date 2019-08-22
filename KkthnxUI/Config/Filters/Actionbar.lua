local K, C = unpack(select(2, ...))

local ACTIONBAR_FADER = {
	fadeInAlpha = 1,
	fadeInDuration = .3,
	fadeOutAlpha = .1,
	fadeOutDuration = .8,
	fadeOutDelay = .5,
}

K.ActionBars = {
	userPlaced = true,

	actionBar1 = {size = C["ActionBar"].DefaultButtonSize, fader = nil},
	actionBar2 = {size = C["ActionBar"].DefaultButtonSize, fader = nil},
	actionBar3 = {size = C["ActionBar"].DefaultButtonSize, fader = nil},
	actionBar4 = {size = C["ActionBar"].RightButtonSize, fader = ACTIONBAR_FADER},
	actionBar5 = {size = C["ActionBar"].RightButtonSize, fader = ACTIONBAR_FADER},

	petBar = {size = C["ActionBar"].StancePetSize, fader = nil},
	stanceBar = {size = C["ActionBar"].StancePetSize, fader = nil},
	extraBar = {size = 56, fader = nil},
	leaveVehicle = {size = C["ActionBar"].DefaultButtonSize,	fader = nil},
}