local K, C, L = unpack(select(2, ...))

-- Wow API
local UnitIsAFK = UnitIsAFK
local collectgarbage = collectgarbage

local EventCount = 0
local CollectGarbage = CreateFrame("Frame")
CollectGarbage:RegisterEvent("PLAYER_FLAGS_CHANGED")
CollectGarbage:RegisterEvent("PLAYER_ENTERING_WORLD")
CollectGarbage:SetScript("OnEvent", function(self, event, unit)
	EventCount = EventCount + 1

	if (InCombatLockdown() and EventCount > 25000) or (not InCombatLockdown() and EventCount > 10000) or event == "PLAYER_ENTERING_WORLD" then
		collectgarbage("collect")
		EventCount = 0

		-- print(collectgarbage, event)
		if event == "PLAYER_ENTERING_WORLD" then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		else
			self:UnregisterEvent(event)
		end
	else
		if (unit ~= "player") then
			return
		end
		if UnitIsAFK(unit) then
			collectgarbage("collect")
			-- print(collectgarbage, UnitIsAFK)
		end
	end
end)