local K, C = unpack(select(2, ...))
if C["Loot"].FastLoot ~= true then
	return
end

local Module = K:NewModule("FastLoot", "AceEvent-3.0")

-- Sourced: ProjectAzilroka

local _G = _G

local GetNumLootItems = _G.GetNumLootItems
local CloseLoot = _G.CloseLoot
local LootSlot = _G.LootSlot
local GetCVar = _G.GetCVar
local IsModifiedClick = _G.IsModifiedClick

-- Time delay
function Module:LOOT_READY()
	local NumLootItems = GetNumLootItems()

	if NumLootItems == 0 then
		CloseLoot()
		return
	end

	if self.isLooting then
		return
	end

	if (GetCVar("autoLootDefault") == "1" and not IsModifiedClick("AUTOLOOTTOGGLE")) or (GetCVar("autoLootDefault") ~= "1" and IsModifiedClick("AUTOLOOTTOGGLE")) then
		for i = NumLootItems, 1, -1 do
			LootSlot(i)
		end

		Module.isLooting = true

		C_Timer.After(.3, function()
			Module.isLooting = false
		end)
	end
end

function Module:OnEnable()
	if C["Loot"].FastLoot ~= true then
		return
	end

	self:RegisterEvent("LOOT_READY")
end