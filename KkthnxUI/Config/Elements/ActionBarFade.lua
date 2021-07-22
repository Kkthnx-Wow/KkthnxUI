local _, C = unpack(select(2, ...))

local BAR_FADER = {
	fadeInAlpha = 1,
	fadeInDuration = 0.2,
	fadeOutAlpha = 0,
	fadeOutDelay = 0,
	fadeOutDuration = 0.2,
}

C.Bars = {
	BarMargin = 6,
	BarPadding = 0,

	Bar1 = {
		size = 34,
		fader = nil
	},

	Bar2 = {
		size = 34,
		fader = nil
	},

	Bar3 = {
		size = 34,
		fader = nil
	},

	Bar4 = {
		size = 34,
		fader = BAR_FADER
	},

	Bar5 = {
		size = 34,
		fader = BAR_FADER
	},

	BarExtra = {
		size = 52,
		fader = nil
	},

	BarVehicle = {
		size = 34,
		fader = nil
	},

	BarPet = {
		size = 30,
		fader = nil
	},

	BarStance = {
		size = 30,
		fader = nil
	},
}