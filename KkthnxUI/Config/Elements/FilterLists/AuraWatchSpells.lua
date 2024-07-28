local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("AurasTable")

local string_format = string.format
local table_wipe = table.wipe

local GetSpellInfo = GetSpellInfo
local UIParent = UIParent

local AuraWatchList = {}
local groups = {
	-- ["Player Aura"] = { "LEFT", 6, "ICON", 30, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 432 } },
	-- ["Target Aura"] = { "RIGHT", 6, "ICON", 36, { "BOTTOMLEFT", UIParent, "BOTTOM", 160, 468 } },
	-- ["Special Aura"] = { "LEFT", 6, "ICON", 36, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 468 } },
	-- ["Focus Aura"] = { "RIGHT", 6, "ICON", 35, { "BOTTOMLEFT", UIParent, "LEFT", 5, -230 } },
	-- ["Spell Cooldown"] = { "UP", 6, "BAR", 20, { "BOTTOMRIGHT", UIParent, "BOTTOM", -380, 140 }, 150 },
	-- ["Enchant Aura"] = { "LEFT", 6, "ICON", 36, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 510 } },
	-- ["Raid Buff"] = { "LEFT", 6, "ICON", 42, { "CENTER", UIParent, "CENTER", -220, 300 } },
	-- ["Raid Debuff"] = { "RIGHT", 6, "ICON", 42, { "CENTER", UIParent, "CENTER", 220, 300 } },
	-- ["Warning"] = { "RIGHT", 6, "ICON", 42, { "BOTTOMLEFT", UIParent, "BOTTOM", 160, 510 } },
	-- ["InternalCD"] = { "UP", 6, "BAR", 20, { "BOTTOMRIGHT", UIParent, "BOTTOM", -425, 600 }, 150 },

	["Special Aura"] = { "LEFT", 6, "ICON", 30, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 432 } },
	["Focus Aura"] = { "RIGHT", 6, "ICON", 35, { "BOTTOMLEFT", UIParent, "LEFT", 5, -230 } },
	["Spell Cooldown"] = { "UP", 6, "BAR", 20, { "BOTTOMRIGHT", UIParent, "BOTTOM", -380, 140 }, 150 },
	["Enchant Aura"] = { "LEFT", 6, "ICON", 36, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 468 } },
	["Raid Buff"] = { "LEFT", 6, "ICON", 42, { "CENTER", UIParent, "CENTER", -220, 300 } },
	["Raid Debuff"] = { "RIGHT", 6, "ICON", 42, { "CENTER", UIParent, "CENTER", 220, 300 } },
	["Warning"] = { "RIGHT", 6, "ICON", 36, { "BOTTOMLEFT", UIParent, "BOTTOM", 160, 468 } },
	["InternalCD"] = { "UP", 6, "BAR", 20, { "BOTTOMRIGHT", UIParent, "BOTTOM", -425, 600 }, 150 },
}

local function newAuraFormat(value)
	local newTable = {}
	for _, v in pairs(value) do
		local id = v.AuraID or v.SpellID or v.ItemID or v.SlotID or v.TotemID or v.IntID
		if id then
			newTable[id] = v
		end
	end
	return newTable
end

function Module:AddNewAuraWatch(class, list)
	for _, k in pairs(list) do
		for _, v in pairs(k) do
			local spellID = v.AuraID or v.SpellID
			if spellID then
				local name = GetSpellInfo(spellID)
				if not name then
					table_wipe(v)
					if K.isDeveloper then
						K.Print(string_format("|cffFF0000Invalid spellID:|r '%s' %s", class, spellID))
					end
				end
			end
		end
	end

	if class ~= "ALL" and class ~= K.Class then
		return
	end

	if not AuraWatchList[class] then
		AuraWatchList[class] = {}
	end

	for name, v in pairs(list) do
		local direction, interval, mode, size, pos, width = unpack(groups[name])
		table.insert(AuraWatchList[class], {
			Name = name,
			Direction = direction,
			Interval = interval,
			Mode = mode,
			IconSize = size,
			Pos = pos,
			BarWidth = width,
			List = newAuraFormat(v),
		})
	end
end

function Module:AddDeprecatedGroup()
	for name, value in pairs(C.DeprecatedAuras) do
		for _, list in pairs(AuraWatchList["ALL"]) do
			if list.Name == name then
				local newTable = newAuraFormat(value)
				for spellID, v in pairs(newTable) do
					list.List[spellID] = v
				end
			end
		end
	end

	table_wipe(C.DeprecatedAuras)
end

function Module:OnEnable()
	local loadAuraWatchModules = {
		"AddDeprecatedGroup",
	}

	for _, funcName in ipairs(loadAuraWatchModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	C.AuraWatchList = AuraWatchList
end
