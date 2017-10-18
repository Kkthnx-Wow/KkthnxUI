local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- GLOBALS: PawnCommon

function K.LoadPawnProfile()
	if PawnCommon then
		table_wipe(PawnCommon)
	end

	PawnCommon = {
		["AlignNumbersRight"] = false,
		["ButtonPosition"] = 2,
		["ColorTooltipBorder"] = false,
		["Debug"] = false,
		["Digits"] = 1,
		["IgnoreGemsWhileLeveling"] = true,
		["LastVersion"] = 2.02,
		["ShowBagUpgradeAdvisor"] = true,
		["ShowItemID"] = false,
		["ShowLootUpgradeAdvisor"] = true,
		["ShownGettingStarted"] = true,
		["ShowQuestUpgradeAdvisor"] = true,
		["ShowRelicUpgrades"] = true,
		["ShowSocketingAdvisor"] = true,
		["ShowSpecIcons"] = true,
		["ShowTooltipIcons"] = false,
		["ShowUpgradesOnTooltips"] = true,
		["ShowValuesForUpgradesOnly"] = true,
	}
end