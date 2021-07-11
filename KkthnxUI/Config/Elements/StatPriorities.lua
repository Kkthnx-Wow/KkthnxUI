local K, C = unpack(select(2, ...))

local data = {
	-- 250 - Death Knight: Blood -- https://www.icy-veins.com/wow/blood-death-knight-pve-tank-stat-priority
	[250] = {
		{"Item Level > Versatility > Haste > Critical Strike > Mastery"},
	},

	-- 251 - Death Knight: Frost -- https://www.icy-veins.com/wow/frost-death-knight-pve-dps-stat-priority
	[251] = {
		{"Mastery > Critical Strike > Haste > Versatility"},
	},

	-- 252 - Death Knight: Unholy -- https://www.icy-veins.com/wow/unholy-death-knight-pve-dps-stat-priority
	[252] = {
		{"Mastery > Haste > Critical Strike > Versatility", "Most Common"},
		{"Mastery > Critical Strike > Haste > Versatility", "AoE"},
	},

	-- 577 - Demon Hunter: Havoc -- https://www.icy-veins.com/wow/havoc-demon-hunter-pve-dps-stat-priority
	[577] = {
		{"Agility > Haste = Versatility > Critical Strike > Mastery"},
	},

	-- 581 - Demon Hunter: Vengeance -- https://www.icy-veins.com/wow/vengeance-demon-hunter-pve-tank-stat-priority
	[581] = {
		{"Agility > Haste >= Versatility > Critical Strike > Mastery"},
	},

	-- 102 - Druid: Balance -- https://www.icy-veins.com/wow/balance-druid-pve-dps-stat-priority
	[102] = {
		{"Intellect > Mastery > Haste > Versatility > Critical Strike"}
	},

	-- 103 - Druid: Feral -- https://www.icy-veins.com/wow/feral-druid-pve-dps-stat-priority
	[103] = {
		{"Agility > Critical Strike > Mastery > Versatility > Haste"},
	},

	-- 104 - Druid: Guardian -- https://www.icy-veins.com/wow/guardian-druid-pve-tank-stat-priority
	[104] = {
		{"Item Level > Armor/Agility/Stamina > Versatility > Mastery > Haste > Critical Strike", "Survivability"},
		{"Versatility >= Haste >= Critical Strike > Mastery", "Damage Output"},
	},

	-- Druid: Restoration -- https://www.icy-veins.com/wow/restoration-druid-pve-healing-stat-priority
	[105] = {
		{"Intellect > Haste > Mastery = Critical Strike = Versatility", "Raid Healing"},
		{"Intellect > Mastery = Haste > Versatility > Critical Strike", "Dungeon Healing"},
	},

	-- 253 - Hunter: Beast Mastery -- https://www.icy-veins.com/wow/beast-mastery-hunter-pve-dps-stat-priority
	[253] = {
		{"Critical Strike > Haste > Versatility > Mastery"},
	},

	-- 254 - Hunter: Marksmanship -- https://www.icy-veins.com/wow/marksmanship-hunter-pve-dps-stat-priority
	[254] = {
		{"Mastery > Critical Strike > Versatility > Haste"},
	},

	-- 255 - Hunter: Survival -- https://www.icy-veins.com/wow/survival-hunter-pve-dps-stat-priority
	[255] = {
		{"Haste > Versatility/Critical Strike > Mastery"},
	},

	-- 62 - Mage: Arcane -- https://www.icy-veins.com/wow/arcane-mage-pve-dps-stat-priority
	[62] = {
		{"Intellect > Critical Strike > Mastery > Versatility > Haste"},
	},

	-- 63 - Mage: Fire -- https://www.icy-veins.com/wow/fire-mage-pve-dps-stat-priority
	[63] = {
		{"Intellect > Haste > Versatility > Mastery > Critical Strike"},
	},

	-- 64 - Mage: Frost -- https://www.icy-veins.com/wow/frost-mage-pve-dps-stat-priority
	[64] = {
		{"Intellect > Critical Strike (to 33.34%) > Haste > Versatility > Mastery > Critical Strike (after 33.34%)"},
	},

	-- 268 - Monk: Brewmaster -- https://www.icy-veins.com/wow/brewmaster-monk-pve-tank-stat-priority
	[268] = {
		{"Versatility = Mastery = Critical Strike > Haste", "Defensive"},
		{"Versatility = Critical Strike > Haste > Mastery", "Offensive"},
	},

	-- 269 - Monk: Windwalker -- https://www.icy-veins.com/wow/windwalker-monk-pve-dps-stat-priority
	[269] = {
		{"Weapon Damage > Agility > Versatility > Mastery > Critical Strike > Haste"},
	},

	-- 270 - Monk: Mistweaver -- https://www.icy-veins.com/wow/mistweaver-monk-pve-healing-stat-priority
	[270] = {
		{"Intellect > Critical Strike > Versatility > Haste > Mastery", "Raiding (Mistweaving)"},
		{"Intellect > Critical Strike > Versatility > Haste > Mastery", "Raiding (Fistweaving)"},
		{"Intellect > Critical Strike => Mastery = Versatility >= Haste", "Mythic +"},
	},

	-- 65 - Paladin: Holy -- https://www.icy-veins.com/wow/holy-paladin-pve-healing-stat-priority
	[65] = {
		{"Intellect > Haste > Mastery > Versatility > Critical Strike", "Raiding"},
		{"Intellect > Haste > Versatility > Critical Strike > Mastery", "Mythic +"},
	},

	-- 66 - Paladin: Protection -- https://www.icy-veins.com/wow/protection-paladin-pve-tank-stat-priority
	[66] = {
		{"Haste > Mastery > Versatility > Critical Strike"},
	},

	-- 70 - Paladin: Retribution -- https://www.icy-veins.com/wow/retribution-paladin-pve-dps-stat-priority
	[70] = {
		{"Strength > Mastery ～= Versatility ～= Critical Strike ～= Haste"},
	},

	-- 256 - Priest: Discipline -- https://www.icy-veins.com/wow/discipline-priest-pve-healing-stat-priority
	[256] = {
		{"Intellect > Haste > Critical Strike > Versatility > Mastery"},
	},

	-- 257 - Priest: Holy -- https://www.icy-veins.com/wow/holy-priest-pve-healing-stat-priority
	[257] = {
		{"Intellect > Mastery = Critical Strike > Versatility > Haste", "Raiding"},
		{"Intellect > Critical Strike > Haste > Versatility > Mastery", "Dungeons"},
	},

	-- 258 - Priest: Shadow -- https://www.icy-veins.com/wow/shadow-priest-pve-dps-stat-priority
	[258] = {
		{"Intellect > Haste = Mastery > Critical Strike > Versatility"},
	},

	-- 259 - Rogue: Assassination -- https://www.icy-veins.com/wow/assassination-rogue-pve-dps-stat-priority
	[259] = {
		{"Haste > Critical Strike > Versatility > Mastery", "Raiding"},
		{"Critical Strike > Mastery > Haste > Versatility", "Mythic +"},
	},

	-- 260 - Rogue: Outlaw -- https://www.icy-veins.com/wow/outlaw-rogue-pve-dps-stat-priority
	[260] = {
		{"Versatility > Haste > Critical Strike > Mastery", "Raiding"},
		{"Versatility > Critical Strike > Haste > Mastery", "Mythic +"},
	},

	-- 261 - Rogue: Subtlety -- https://www.icy-veins.com/wow/subtlety-rogue-pve-dps-stat-priority
	[261] = {
		{"Versatility > Critical Strike > Haste > Mastery", "Single Target"},
		{"Critical Strike > Versatility > Mastery > Haste", "Multi Target"},
	},

	-- 262 - Shaman: Elemental -- https://www.icy-veins.com/wow/elemental-shaman-pve-dps-stat-priority
	[262] = {
		{"Intellect > Versatility > Critical Strike > Haste > Mastery"},
	},

	-- 263 - Shaman: Enhancement -- https://www.icy-veins.com/wow/enhancement-shaman-pve-dps-stat-priority
	[263] = {
		{"Agility > Haste > Critical Strike = Versatility > Mastery"},
	},

	-- 264 - Shaman: Restoration -- https://www.icy-veins.com/wow/restoration-shaman-pve-healing-stat-priority
	[264] = {
		{"Item Level > Versatility = Critical Strike > Haste = Mastery", "General Healing"},
		{"Item Level > Versatility = Haste > Critical Strike > Mastery", "Solo/Low Key Speed Running"},
	},

	-- 265 - Warlock: Affliction -- https://www.icy-veins.com/wow/affliction-warlock-pve-dps-stat-priority
	[265] = {
		{"Intellect > Mastery > Haste > Critical Strike > Versatility"},
	},

	-- 266 - Warlock: Demonology -- https://www.icy-veins.com/wow/demonology-warlock-pve-dps-stat-priority
	[266] = {
		{"Intellect > Haste > Mastery > Critical Strike ≅ Versatility"},
	},

	-- 267 - Warlock: Destruction -- https://www.icy-veins.com/wow/destruction-warlock-pve-dps-stat-priority
	[267] = {
		{"Intellect > Haste ≥ Mastery > Critical Strike > Versatility"},
	},

	-- 71 - Warrior: Arms -- https://www.icy-veins.com/wow/arms-warrior-pve-dps-stat-priority
	[71] = {
		{"Strength > Critical Strike > Mastery > Versatility > Haste"},
	},

	-- 72 - Warrior: Fury -- https://www.icy-veins.com/wow/fury-warrior-pve-dps-stat-priority
	[72] = {
		{"Strength > Haste > Mastery > Critical Strike > Versatility"},
	},

	-- 73 - Warrior: Protection -- https://www.icy-veins.com/wow/protection-warrior-pve-tank-stat-priority
	[73] = {
		{"Item level > Haste > Versatility > Mastery > Critical Strike", "General"},
		{"Item level > Haste > Versatility >= Critical Strike > Mastery", "Mythic +"},
	},
}

function K:GetSPText(specID, k)
	if not data[specID] then
		return
	end

	local selected = KkthnxUIDB.StatPriority["selected"][specID] or 1
	local text

	if selected > #data[specID] then -- isCustom
		if KkthnxUIDB.StatPriority.Custom[specID] and KkthnxUIDB.StatPriority.Custom[specID][selected - #data[specID]] then
			text = KkthnxUIDB.StatPriority.Custom[specID][selected - #data[specID]][1]
		else -- data not exists
			KkthnxUIDB.StatPriority["selected"][specID] = 1
			selected = 1
		end
	else
		text = data[specID][selected][1]
	end

	-- localize
	text = string.gsub(text, "Agility", SPEC_FRAME_PRIMARY_STAT_AGILITY)
	text = string.gsub(text, "Armor", STAT_ARMOR)
	text = string.gsub(text, "Critical Strike", STAT_CRITICAL_STRIKE)
	text = string.gsub(text, "Haste", STAT_HASTE)
	text = string.gsub(text, "Intellect", SPEC_FRAME_PRIMARY_STAT_INTELLECT)
	text = string.gsub(text, "Item Level", STAT_AVERAGE_ITEM_LEVEL)
	text = string.gsub(text, "Mastery", STAT_MASTERY)
	text = string.gsub(text, "Stamina", ITEM_MOD_STAMINA_SHORT)
	text = string.gsub(text, "Strength", SPEC_FRAME_PRIMARY_STAT_STRENGTH)
	text = string.gsub(text, "Versatility", STAT_VERSATILITY)
	text = string.gsub(text, "Weapon Damage", DAMAGE_TOOLTIP)

	return text
end

function K:GetSPDesc(specID)
	if data[specID] and (#data[specID] ~= 1 or (KkthnxUIDB.StatPriority.Custom[specID] and #KkthnxUIDB.StatPriority.Custom[specID] ~= 0)) then
		local desc = {}
		for _, t in pairs(data[specID]) do
			table.insert(desc, {t[2] or "General"})
		end

		-- load custom
		if KkthnxUIDB.StatPriority.Custom[specID] then
			for k, t in pairs(KkthnxUIDB.StatPriority.Custom[specID]) do
				table.insert(desc, {t[2], k})
			end
		end

		return desc
	end
end