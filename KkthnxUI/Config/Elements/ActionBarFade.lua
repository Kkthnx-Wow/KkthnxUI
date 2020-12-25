local _, C = unpack(select(2, ...))

local ACTIONBAR_FADER = {
	fadeInAlpha = 1, -- Transparency when displayed
	fadeInDuration = 0.2, -- Display time-consuming
	fadeOutAlpha = 0, -- Transparency after fade
	fadeOutDelay = 0, -- Delay fade
	fadeOutDuration = 0.2, -- Fading time-consuming
}

C.ActionBars = {
	margin = 2, -- Key spacing
	padding = 2, -- Edge spacing

	actionBar1 = { -- Main action bar (below)
		size = 34,
		fader = nil
	},

	actionBar2 = { -- Main action bar (top)
		size = 34,
		fader = nil
	},

	actionBar3 = { -- Both sides of the main action bar
		size = 32,
		fader = ACTIONBAR_FADER
	},

	actionBar4 = { -- Right action bar 1
		size = 32,
		fader = ACTIONBAR_FADER
	},

	actionBar5 = { -- Right action bar 2
		size = 32,
		fader = ACTIONBAR_FADER
	},

	actionBarCustom = { -- Custom action bar
		size = 34,
		fader = ACTIONBAR_FADER
	},

	extraBar = { -- Extra action bar
		size = 52,
		fader = nil
	},

	leaveVehicle = {
		size = 32,
		fader = nil
	},

	petBar = {
		size = 26,
		fader = ACTIONBAR_FADER
	},

	stanceBar = {
		size = 30,
		fader = ACTIONBAR_FADER
	},
}