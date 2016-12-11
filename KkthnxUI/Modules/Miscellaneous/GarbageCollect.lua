local K, C, L = unpack(select(2, ...))

-- Wow API
local UnitIsAFK = UnitIsAFK
local collectgarbage = collectgarbage

local CollectGarbage = CreateFrame("Frame")

CollectGarbage:RegisterEvent("PLAYER_FLAGS_CHANGED")
CollectGarbage:RegisterEvent("PLAYER_ENTERING_WORLD")
CollectGarbage:SetScript("OnEvent", function(self, event, unit)
	if (event == "PLAYER_ENTERING_WORLD") then
		collectgarbage("collect")

		-- Just verifying that this clears the memory out :)
		local Memory = K.DataTexts:GetDataText("Memory")
		if (Memory and Memory.Enabled) then
			Memory:Update(10)
		end

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
end)