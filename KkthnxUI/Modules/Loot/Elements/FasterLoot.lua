local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Sourced: NDui

local GetCVarBool = GetCVarBool
local GetNumLootItems = GetNumLootItems
local GetTime = GetTime
local IsModifiedClick = IsModifiedClick
local LootSlot = LootSlot

-- Variable to store the time of the last loot action
local lootDelay = 0

-- Function to setup faster loot
function Module:SetupFasterLoot()
	-- Get the current time
	local thisTime = GetTime()

	-- Check if the difference between the current time and the last loot action is greater than or equal to 0.3
	if thisTime - lootDelay >= 0.3 then
		-- Update the loot delay with the current time
		lootDelay = thisTime

		-- Check if the default auto loot value is not equal to the value of the modified click
		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			-- Loop through the loot items from the last to the first
			for i = GetNumLootItems(), 1, -1 do
				-- Loot the current slot
				LootSlot(i)
			end
			-- Update the loot delay with the current time
			lootDelay = thisTime
		end
	end
end

-- Function to create faster loot
function Module:CreateFasterLoot()
	-- Check if fast loot is enabled in the config
	if C["Loot"].FastLoot then
		-- Register the LOOT_READY event and call the SetupFasterLoot function when it triggers
		K:RegisterEvent("LOOT_READY", Module.SetupFasterLoot)
	else
		-- Unregister the LOOT_READY event and stop calling the SetupFasterLoot function when it triggers
		K:UnregisterEvent("LOOT_READY", Module.SetupFasterLoot)
	end
end
