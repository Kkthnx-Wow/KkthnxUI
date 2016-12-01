local K, C, L = select(2, ...):unpack()

local UnitIsAFK = UnitIsAFK
local collectgarbage = collectgarbage

local CollectGarbage = CreateFrame("Frame")

function CollectGarbage:OnEvent(event, unit)
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
end

CollectGarbage:RegisterEvent("PLAYER_FLAGS_CHANGED")
CollectGarbage:RegisterEvent("PLAYER_ENTERING_WORLD")
CollectGarbage:SetScript("OnEvent", CollectGarbage.OnEvent)
