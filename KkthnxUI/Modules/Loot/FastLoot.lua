local K, C, L = unpack(select(2, ...))
if C["Loot"].FastLoot ~= true then
	return
end

local Module = K:NewModule("FastLoot", "AceEvent-3.0")

-- Sourced: LeatrixPlus (Leatrix)

local _G = _G

local GetCVarBool = _G.GetCVarBool
local GetNumLootItems = _G.GetNumLootItems
local GetTime = _G.GetTime

-- Time delay
local tDelay = 0
function Module:OnEvent()
	if GetTime() - tDelay >= 0.3 then
		tDelay = GetTime()
		if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end

			tDelay = GetTime()
		end
	end
end

function Module:OnEnable()
	if C["Loot"].FastLoot ~= true then
		return
	end

	self:RegisterEvent("LOOT_READY", "OnEvent")
end