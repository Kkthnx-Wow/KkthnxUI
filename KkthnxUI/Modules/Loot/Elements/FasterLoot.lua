local K, C = unpack(select(2, ...))
local Module = K:GetModule("Loot")

-- Sourced: NDui

local _G = _G

local GetCVarBool = _G.GetCVarBool
local GetNumLootItems = _G.GetNumLootItems
local GetTime = _G.GetTime
local IsModifiedClick = _G.IsModifiedClick
local LootSlot = _G.LootSlot

local lootDelay = 0
local function SetupFasterLoot()
	if GetTime() - lootDelay >= 0.3 then
		lootDelay = GetTime()
		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end

			lootDelay = GetTime()
		end
	end
end

function Module:CreateFasterLoot()
	if IsAddOnLoaded("SpeedyAutoLoot") then
		return
	end

	if C["Loot"].FastLoot then
		K:RegisterEvent("LOOT_READY", SetupFasterLoot)
	else
		K:UnregisterEvent("LOOT_READY", SetupFasterLoot)
	end
end