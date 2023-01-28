local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Loot")

-- Sourced: NDui

local GetCVarBool = _G.GetCVarBool
local GetNumLootItems = _G.GetNumLootItems
local GetTime = _G.GetTime
local IsModifiedClick = _G.IsModifiedClick
local LootSlot = _G.LootSlot

local lootDelay = 0
function Module:SetupFasterLoot()
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

function Module:CreateFasterLoot()
	if C["Loot"].FastLoot then
		K:RegisterEvent("LOOT_READY", Module.SetupFasterLoot)
	else
		K:UnregisterEvent("LOOT_READY", Module.SetupFasterLoot)
	end
end
