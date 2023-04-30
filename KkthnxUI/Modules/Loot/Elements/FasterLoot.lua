local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Local references to global functions
local GetCVarBool = GetCVarBool
local GetNumLootItems = GetNumLootItems
local GetTime = GetTime
local IsModifiedClick = IsModifiedClick
local LootSlot = LootSlot

-- Variable to store the time of the last loot action
local lootDelay = 0

-- Function to handle faster looting
local function HandleFasterLoot()
	local thisTime = GetTime()

	if thisTime - lootDelay >= 0.3 then
		lootDelay = thisTime

		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end
			lootDelay = thisTime
		end
	end
end

-- Function to enable or disable faster loot based on the configuration
function Module:CreateFasterLoot()
	if C["Loot"].FastLoot then
		K:RegisterEvent("LOOT_READY", HandleFasterLoot)
	else
		K:UnregisterEvent("LOOT_READY", HandleFasterLoot)
	end
end
