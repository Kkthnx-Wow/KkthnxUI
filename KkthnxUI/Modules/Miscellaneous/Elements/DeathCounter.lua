local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local function CreateDeathCounterDB()
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounterLevel = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounterLevel or 0
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounterPlayer = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounterPlayer or 0
end

local currentLevel
local playerDeaths = 0
local levelDeaths = 0

local function UpdateDeathCounts()
	playerDeaths = tonumber(KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounterPlayer) or 0
	levelDeaths = tonumber(KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounterLevel) or 0
end

local function SaveDeathCounts()
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounterPlayer = tonumber(playerDeaths) or 0
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounterLevel = tonumber(levelDeaths) or 0
end

local function OnCombatLogEventUnfiltered(_, _, event)
	if event == "UNIT_DIED" then
		playerDeaths = playerDeaths + 1
		levelDeaths = levelDeaths + 1

		SaveDeathCounts()

		print("Total Deaths: " .. playerDeaths)
		print("Level Deaths: " .. levelDeaths)
	end
end

local function OnLevelChange()
	local newLevel = UnitLevel("player")
	if newLevel > currentLevel then
		levelDeaths = 0
		currentLevel = newLevel

		SaveDeathCounts()
		-- You can update the UI here to reflect the level change and reset the level death count
	end
end

local function PrintDeathCounts()
	print("Total Deaths: " .. playerDeaths)
	print("Level Deaths: " .. levelDeaths)
end

local function SlashCommandHandler(msg)
	if msg == "stats" then
		PrintDeathCounts()
	else
		-- Show command usage or help information
		print("Usage: /deathcounter stats")
	end
end

function Module:CreateDeathCounter()
	if C["Misc"].DeathCounter then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEventUnfiltered, "player")
		K:RegisterEvent("PLAYER_LEVEL_UP", OnLevelChange, "player")
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", OnCombatLogEventUnfiltered, "player")
		K:UnregisterEvent("PLAYER_LEVEL_UP", OnLevelChange, "player")
	end

	currentLevel = UnitLevel("player")

	CreateDeathCounterDB()
	UpdateDeathCounts()

	-- Slash command registration
	SLASH_DEATHCOUNTER1 = "/deathcounter"
	SlashCmdList["DEATHCOUNTER"] = SlashCommandHandler
end
