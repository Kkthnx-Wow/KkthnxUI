local K, C, L, _ = select(2, ...):unpack()

local collectgarbage = collectgarbage
local UnitIsAFK = UnitIsAFK
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local CollectGarbage = CreateFrame("Frame")

local eventcount = 0
function CollectGarbage:OnEvent(event, unit)
	eventcount = eventcount + 1

	if (InCombatLockdown() and eventcount > 25000) or (not InCombatLockdown() and eventcount > 10000) or event == "PLAYER_LOGIN" then
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

CollectGarbage:RegisterEvent("PLAYER_FLAGS_CHANGED")
CollectGarbage:RegisterEvent("PLAYER_LOGIN")
CollectGarbage:SetScript("OnEvent", CollectGarbage.OnEvent)