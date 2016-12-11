local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local _, ns = ...

-- Default Aura Filter
ns.defaultAuras = {
	["general"] = {},
	["boss"] = {},
	["arena"] = {},
}

do
	local l = K.AuraList
	for _, list in pairs({l.Immunity, l.CCImmunity, l.Defensive, l.Offensive, l.Helpful, l.Misc}) do
		for i = 1, #list do
			ns.defaultAuras.arena[list[i]] = true
		end
	end
end

-- Default Settings
ns.config = {
	playerstyle = "normal",
	customPlayerTexture = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\CUSTOMPLAYER-FRAME",

	castbarticks = true,
	useAuraTimer = false,

	classBar = {},

	-- class stuff
	DEATHKNIGHT = {
		showRunes = true,
		showTotems = true,
	},
	DEMONHUNTER = {
	},
	DRUID = {
		showTotems = true,
		showAdditionalPower = true,
	},
	HUNTER = {
		showTotems = true,
	},
	MAGE = {
		showArcaneStacks = true,
		showTotems = true,
	},
	MONK = {
		showStagger = true,
		showChi = true,
		showTotems = true,
		showAdditionalPower = true,
	},
	PALADIN = {
		showHolyPower = true,
		showTotems = true,
		showAdditionalPower = true,
	},
	PRIEST = {
		showInsanity = true,
		showAdditionalPower = true,
	},
	ROGUE = {
	},
	SHAMAN = {
		showTotems = true,
		showAdditionalPower = true,
	},
	WARLOCK = {
		showShards = true,
		showTotems = true,
	},
	WARRIOR = {
		showTotems = true,
	},

	showComboPoints = true,

	player = {
		HealthTag = "NUMERIC",
		PowerTag = "PERCENT",
		cbshow = true,
		cbwidth = 200,
		cbheight = 18,
		cbicon = C.Unitframe.IconPlayer, --"LEFT"
	},

	pet = {
		HealthTag = "MINIMAL",
		PowerTag = "DISABLE",
		cbshow = true,
		cbwidth = 200,
		cbheight = 18,
		cbicon = "NONE",
	},

	target = {
		HealthTag = "BOTH",
		PowerTag = "PERCENT",
		buffPos = "BOTTOM",
		debuffPos = "TOP",
		cbshow = true,
		cbwidth = 200,
		cbheight = 18,
		cbicon = C.Unitframe.IconTarget,
	},

	targettarget = {
		enable = true,
		enableAura = false,
		HealthTag = "DISABLE",
	},

	focus = {
		HealthTag = "BOTH",
		PowerTag = "PERCENT",
		buffPos = "NONE",
		debuffPos = "BOTTOM",
		cbshow = true,
		cbwidth = 180,
		cbheight = 20,
		cbicon = "NONE",
	},

	focustarget = {
		enable = true,
		enableAura = false,
		HealthTag = "DISABLE",
	},

	party = {
		HealthTag = "MINIMAL",
		PowerTag = "DISABLE",
	},

	boss = {
		HealthTag = "PERCENT",
		PowerTag = "PERCENT",
		cbshow = true,
		cboffset = {0, 0},
		cbwidth = 150,
		cbheight = 18,
		cbicon = "NONE",
	},

	arena = {
		HealthTag = "BOTH",
		PowerTag = "PERCENT",
		cboffset = {0, 0},
		cbshow = true,
		cbwidth = 150,
		cbheight = 22,
		cbicon = "NONE",
	},
}