local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local _, ns = ...

-- Default Aura Filter
K.DefaultAuras = {
	Arena = {},
	Boss = {},
	General = {},
}

for _, list in pairs({K.AuraList.Stun, K.AuraList.CC, K.AuraList.Silence, K.AuraList.Taunt}) do
	for i = 1, #list do
		K.DefaultAuras.Arena[list[i]] = true
	end
end

-- Default Settings
ns.config = {
	player = {
		HealthTag = "NUMERIC",
		PowerTag = "PERCENT",
	},

	pet = {
		HealthTag = "MINIMAL",
		PowerTag = "DISABLE",
	},

	target = {
		HealthTag = "BOTH",
		PowerTag = "PERCENT",
		buffPos = "BOTTOM",
		debuffPos = "TOP",
	},

	targettarget = {
		enableAura = false,
		HealthTag = "DISABLE",
	},

	focus = {
		HealthTag = "BOTH",
		PowerTag = "PERCENT",
		buffPos = "NONE",
		debuffPos = "BOTTOM",
	},

	focustarget = {
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
	},

	arena = {
		HealthTag = "BOTH",
		PowerTag = "PERCENT",
	},
}