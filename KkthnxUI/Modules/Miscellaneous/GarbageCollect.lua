local K, C, L = select(2, ...):unpack()

local CollectGarbage = CreateFrame("Frame")

function CollectGarbage:OnEvent(event, unit)
	if (event == "PLAYER_ENTERING_WORLD") then
		collectgarbage("collect")
		-- print(collectgarbage, event)
		self:UnregisterEvent(event)
	else
		if (unit ~= "player") then
			return
		end
		if UnitIsAFK(unit) then
			collectgarbage("collect")
			-- print(collectgarbage, UnitIsAFK)
		end
	end
end

CollectGarbage:RegisterEvent("PLAYER_FLAGS_CHANGED")
CollectGarbage:RegisterEvent("PLAYER_ENTERING_WORLD")
CollectGarbage:SetScript("OnEvent", CollectGarbage.OnEvent)