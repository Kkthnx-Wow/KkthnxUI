local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Tooltip")

-- Credits: ElvUI_WindTools (fang2hou)

local _G = _G
local format = _G.format
local gsub = _G.gsub
local ipairs = _G.ipairs
local pairs = _G.pairs
local select = _G.select
local strfind = _G.strfind
local tonumber = _G.tonumber

local AchievementFrame_LoadUI = _G.AchievementFrame_LoadUI
local C_CreatureInfo_GetFactionInfo = _G.C_CreatureInfo.GetFactionInfo
local CanInspect = _G.CanInspect
local ClearAchievementComparisonUnit = _G.ClearAchievementComparisonUnit
local GetAchievementComparisonInfo = _G.GetAchievementComparisonInfo
local GetAchievementInfo = _G.GetAchievementInfo
local GetComparisonStatistic = _G.GetComparisonStatistic
local GetStatistic = _G.GetStatistic
local GetTime = _G.GetTime
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local SetAchievementComparisonUnit = _G.SetAchievementComparisonUnit
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID
local UnitLevel = _G.UnitLevel
local UnitRace = _G.UnitRace

local loadedComparison
local compareGUID
local cache = {}

local tiers = {
	"Castle Nathria",
	"Sanctum of Domination"
}

local levels = {
	"Mythic",
	"Heroic",
	"Normal",
	"Raid Finder"
}

local locales = {
	["Raid Finder"] = {
		short = L["[ABBR] Raid Finder"],
		full = L["Raid Finder"]
	},
	["Normal"] = {
		short = L["[ABBR] Normal"],
		full = L["Normal"]
	},
	["Heroic"] = {
		short = L["[ABBR] Heroic"],
		full = L["Heroic"]
	},
	["Mythic"] = {
		short = L["[ABBR] Mythic"],
		full = L["Mythic"]
	},
	["Castle Nathria"] = {
		short = L["[ABBR] Castle Nathria"],
		full = L["Castle Nathria"]
	},
	["The Necrotic Wake"] = {
		short = L["[ABBR] The Necrotic Wake"],
		full = L["The Necrotic Wake"]
	},
	["Plaguefall"] = {
		short = L["[ABBR] Plaguefall"],
		full = L["Plaguefall"]
	},
	["Mists of Tirna Scithe"] = {
		short = L["[ABBR] Mists of Tirna Scithe"],
		full = L["Mists of Tirna Scithe"]
	},
	["Halls of Atonement"] = {
		short = L["[ABBR] Halls of Atonement"],
		full = L["Halls of Atonement"]
	},
	["Theater of Pain"] = {
		short = L["[ABBR] Theater of Pain"],
		full = L["Theater of Pain"]
	},
	["De Other Side"] = {
		short = L["[ABBR] De Other Side"],
		full = L["De Other Side"]
	},
	["Sanctum of Domination"] = {
		short = L["[ABBR] Sanctum of Domination"],
		full = L["Sanctum of Domination"]
	},
	["Spires of Ascension"] = {
		short = L["[ABBR] Spires of Ascension"],
		full = L["Spires of Ascension"]
	},
	["Sanguine Depths"] = {
		short = L["[ABBR] Sanguine Depths"],
		full = L["Sanguine Depths"]
	},
	["Shadowlands Keystone Master: Season One"] = {
		short = L["[ABBR] Shadowlands Keystone Master: Season One"],
		full = L["Shadowlands Keystone Master: Season One"]
	},
	["Shadowlands Keystone Master: Season Two"] = {
		short = L["[ABBR] Shadowlands Keystone Master: Season Two"],
		full = L["Shadowlands Keystone Master: Season Two"]
	},
	["Tazavesh, the Veiled Market"] = {
		short = L["[ABBR] Tazavesh, the Veiled Market"],
		full = L["Tazavesh, the Veiled Market"]
	}
}

local raidAchievements = {
	["Castle Nathria"] = {
		["Mythic"] = {
			14421,
			14425,
			14429,
			14433,
			14437,
			14441,
			14445,
			14449,
			14453,
			14457
		},
		["Heroic"] = {
			14420,
			14424,
			14428,
			14432,
			14436,
			14440,
			14444,
			14448,
			14452,
			14456
		},
		["Normal"] = {
			14419,
			14423,
			14427,
			14431,
			14435,
			14439,
			14443,
			14447,
			14451,
			14455
		},
		["Raid Finder"] = {
			14422,
			14426,
			14430,
			14434,
			14438,
			14442,
			14446,
			14450,
			14454,
			14458
		}
	},
	["Sanctum of Domination"] = {
		["Mythic"] = {
			15139,
			15143,
			15147,
			15151,
			15155,
			15159,
			15163,
			15167,
			15172,
			15176
		},
		["Heroic"] = {
			15138,
			15142,
			15146,
			15150,
			15154,
			15158,
			15162,
			15166,
			15171,
			15175
		},
		["Normal"] = {
			15137,
			15141,
			15145,
			15149,
			15153,
			15157,
			15161,
			15165,
			15170,
			15174
		},
		["Raid Finder"] = {
			15136,
			15140,
			15144,
			15148,
			15152,
			15156,
			15160,
			15164,
			15169,
			15173
		}
	}
}

local dungeonAchievements = {
	["De Other Side"] = 14389,
	["Halls of Atonement"] = 14392,
	["Mists of Tirna Scithe"] = 14395,
	["Plaguefall"] = 14398,
	["Sanguine Depths"] = 14205,
	["Spires of Ascension"] = 14401,
	["Tazavesh, the Veiled Market"] = 15168,
	["The Necrotic Wake"] = 14404,
	["Theater of Pain"] = 14407,
}

local specialAchievements = {
	["Shadowlands Keystone Master: Season One"] = 14532,
	["Shadowlands Keystone Master: Season Two"] = 15078,
}

local function GetLevelColoredString(level, short)
	local color = "ff8000"

	if level == "Mythic" then
		color = "a335ee"
	elseif level == "Heroic" then
		color = "0070dd"
	elseif level == "Normal" then
		color = "1eff00"
	end

	if short then
		return "|cff"..color..locales[level].short.."|r"
	else
		return "|cff"..color..locales[level].full.."|r"
	end
end

local function GetBossKillTimes(guid, achievementID)
	local func = guid == K.GUID and GetStatistic or GetComparisonStatistic
	return tonumber(func(achievementID), 10) or 0
end

local function GetAchievementInfoByID(guid, achievementID)
	local completed, month, day, year
	if guid == K.GUID then
		completed, month, day, year = select(4, GetAchievementInfo(achievementID))
	else
		completed, month, day, year = GetAchievementComparisonInfo(achievementID)
	end
	return completed, month, day, year
end

local function UpdateProgression(guid, faction)
	cache[guid] = cache[guid] or {}
	cache[guid].info = cache[guid].info or {}
	cache[guid].timer = GetTime()

	-- Achievement
	if C["Tooltip"].Special then
		cache[guid].info.special = {}
		for name, achievementID in pairs(specialAchievements) do
			if C["Tooltip"][name] then
				local completed, month, day, year = GetAchievementInfoByID(guid, achievementID)
				local completedString = "|cff888888"..L["Not Completed"].."|r"
				if completed then
					completedString = gsub(L["%month%-%day%-%year%"], "%%month%%", month)
					completedString = gsub(completedString, "%%day%%", day)
					completedString = gsub(completedString, "%%year%%", 2000 + year)
				end
				cache[guid].info.special[name] = completedString
			end
		end
	end

	-- Team
	if C["Tooltip"].Raids then
		cache[guid].info.raids = {}
		for _, tier in ipairs(tiers) do
			if C["Tooltip"][tier] then
				cache[guid].info.raids[tier] = {}
				local bosses = raidAchievements[tier]
				if bosses.separated then
					bosses = bosses[faction]
				end

				for _, level in ipairs(levels) do
					local alreadyKilled = 0
					for _, achievementID in pairs(bosses[level]) do
						if GetBossKillTimes(guid, achievementID) > 0 then
							alreadyKilled = alreadyKilled + 1
						end
					end

					if alreadyKilled > 0 then
						cache[guid].info.raids[tier][level] = format("%d/%d", alreadyKilled, #bosses[level])
						if alreadyKilled == #bosses[level] then
							break -- There is no need to scan the lower difficulty progress after all pass the difficulty
						end
					end
				end
			end
		end
	end

	-- Legendary dungeon
	if C["Tooltip"].Mythics then
		cache[guid].info.mythicDungeons = {}

		-- Challenge mode times
		cache[guid].info.mythicDungeons.times = GetBossKillTimes(guid, 7399)

		-- Legendary Dungeon Tail King Kills
		for name, achievementID in pairs(dungeonAchievements) do
			if C["Tooltip"][name] then
				cache[guid].info.mythicDungeons[name] = GetBossKillTimes(guid, achievementID)
			end
		end
	end
end

function Module:ResetProgressionUnit(btn)
	if btn == "LALT" and UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end
K:RegisterEvent("MODIFIER_STATE_CHANGED", Module.ResetProgressionUnit)

local function SetProgressionInfo(guid)
	if not cache[guid] then
		return
	end

	local updated = false
	for i = 1, GameTooltip:NumLines() do
		local leftTip = _G["GameTooltipTextLeft"..i]
		local leftTipText = leftTip:GetText()
		local found = false

		if leftTipText then
			if C["Tooltip"].Special then -- Achievement
				for name in pairs(specialAchievements) do
					if C["Tooltip"][name] then
						if strfind(leftTipText, locales[name].short) then
							local rightTip = _G["GameTooltipTextRight"..i]
							leftTip:SetText(locales[name].short..":")
							rightTip:SetText(cache[guid].info.special[name])
							updated = true
							found = true
							break
						end
					end
				end
			end
			found = false

			if C["Tooltip"].Raids then -- Group progress
				for _, tier in ipairs(tiers) do
					if C["Tooltip"][tier] then
						for _, level in ipairs(levels) do
							if strfind(leftTipText, locales[tier].short) and strfind(leftTipText, locales[level].full) then
								local rightTip = _G["GameTooltipTextRight"..i]
								leftTip:SetText(format("%s %s:", locales[tier].short, GetLevelColoredString(level, false)))
								rightTip:SetText(cache[guid].info.raids[tier][level])
								updated = true
								found = true
								break
							end
						end

						if found then
							break
						end
					end
				end
			end
			found = false

			if C["Tooltip"].Mythics then -- Dungeon progress
				for name in pairs(dungeonAchievements) do
					if C["Tooltip"][name] then
						if strfind(leftTipText, locales[name].short) then
							local rightTip = _G["GameTooltipTextRight"..i]
							leftTip:SetText(locales[name].short..":")
							rightTip:SetText(cache[guid].info.mythicDungeons[name])
							updated = true
							found = true
							break
						end
					end
				end
			end
		end
	end

	if updated then
		return
	end

	if C["Tooltip"].Special then -- Achievement
		GameTooltip:AddLine(" ")
		for name in pairs(specialAchievements) do
			if C["Tooltip"][name] then
				local left = format("%s: |cffffffff%s|r", locales[name].short, cache[guid].info.special[name])
				GameTooltip:AddLine(left)
			end
		end
	end

	if C["Tooltip"].Raids then -- Group progress
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Raids"])

		for _, tier in ipairs(tiers) do
			if C["Tooltip"][tier] then
				for _, level in ipairs(levels) do
					if (cache[guid].info.raids[tier][level]) then
						local text = format("%s %s: |cffffffff%s|r", locales[tier].short, GetLevelColoredString(level, false), GetLevelColoredString(level, true).." "..cache[guid].info.raids[tier][level])
						GameTooltip:AddLine(text)
					end
				end
			end
		end
	end

	if C["Tooltip"].Mythics then -- Dungeon progress
		GameTooltip:AddLine(" ")
		local titleLeft = L["Mythic Dungeons"]..": |cffffffff"..cache[guid].info.mythicDungeons.times.."|r"
		GameTooltip:AddLine(titleLeft)
		for name in pairs(dungeonAchievements) do
			if C["Tooltip"][name] then
				local text = format("%s: |cffffffff%s|r", locales[name].short, cache[guid].info.mythicDungeons[name])
				GameTooltip:AddDoubleLine(text)
			end
		end
	end
end

function Module:AddProgression(unit)
	if K.CheckAddOnState("RaiderIO") then
		return
	end

    if (not C["Tooltip"].Raids and not C["Tooltip"].Mythics and not C["Tooltip"].Special) then
        return
    end

	if InCombatLockdown() then
		return
	end

	if not IsAltKeyDown() then
		return
	end

	if not (unit and CanInspect(unit)) then
		return
	end

	local level = UnitLevel(unit)
	if not (level and level == MAX_PLAYER_LEVEL) then
		return
	end

	local guid = UnitGUID(unit)

	if not IsAddOnLoaded("Blizzard_AchievementUI") then
		AchievementFrame_LoadUI()
	end

	if not cache[guid] or (GetTime() - cache[guid].timer) > 600 then
		if guid == K.GUID then
			UpdateProgression(guid, K.Faction)
		else
			ClearAchievementComparisonUnit()

			if not loadedComparison and select(2, IsAddOnLoaded("Blizzard_AchievementUI")) then
				_G.AchievementFrame_DisplayComparison(unit)
				HideUIPanel(_G.AchievementFrame)
				ClearAchievementComparisonUnit()
				loadedComparison = true
			end

			compareGUID = guid

			if SetAchievementComparisonUnit(unit) then
				K:RegisterEvent("INSPECT_ACHIEVEMENT_READY", Module.INSPECT_ACHIEVEMENT_READY)
			end

			return
		end
	end

	SetProgressionInfo(guid)
end

function Module:INSPECT_ACHIEVEMENT_READY(GUID)
	if (compareGUID ~= GUID) then
		return
	end

	local unit = "mouseover"

	if UnitExists(unit) then
		local race = select(3, UnitRace(unit))
		local faction = race and C_CreatureInfo_GetFactionInfo(race).groupTag
		if faction then
			UpdateProgression(GUID, faction)
			_G.GameTooltip:SetUnit(unit)
		end
	end

	ClearAchievementComparisonUnit()

	K:UnregisterEvent("INSPECT_ACHIEVEMENT_READY", Module.INSPECT_ACHIEVEMENT_READY)
end