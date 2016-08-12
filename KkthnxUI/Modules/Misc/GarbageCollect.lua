local K, C, L, _ = select(2, ...):unpack()

local collectgarbage = collectgarbage
local UnitIsAFK = UnitIsAFK
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local eventcount = 0
local Garbage = CreateFrame("Frame")

function Garbage:OnEvent(event, unit)
	eventcount = eventcount + 1

	if (InCombatLockdown() and eventcount > 25000) or (not InCombatLockdown() and eventcount > 10000) or event == "PLAYER_ENTERING_WORLD" then
		collectgarbage("collect")
		eventcount = 0

		self:UnregisterEvent(event)
	else
		if (unit ~= "player") then
			return
		end

		if UnitIsAFK(unit) then
			collectgarbage("collect")
		end
	end
end

Garbage:SetScript("OnEvent", Garbage.OnEvent)

Garbage:RegisterEvent("PLAYER_FLAGS_CHANGED")
Garbage:RegisterEvent("PLAYER_ENTERING_WORLD")