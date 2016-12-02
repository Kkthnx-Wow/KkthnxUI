local K, C, L = select(2, ...):unpack()
if C.Automation.LoggingCombat ~= true then return end

-- Wow API
local IsInInstance = IsInInstance
local CreateFrame = CreateFrame

-- AUTO ENABLES COMBAT LOG TEXT FILE IN RAID INSTANCES(EASYLOGGER BY SILDOR)
local EasyLog = CreateFrame("Frame")
EasyLog:RegisterEvent("PLAYER_ENTERING_WORLD")
EasyLog:SetScript("OnEvent", function()
	local _, instanceType = IsInInstance()
	if instanceType == "raid" and IsInRaid(LE_PARTY_CATEGORY_HOME) then
		if not LoggingCombat() then
			LoggingCombat(1)
			K.Print("|cffffff00"..COMBATLOGENABLED.."|r")
		end
	else
		if LoggingCombat() then
			LoggingCombat(0)
			K.Print("|cffffff00"..COMBATLOGDISABLED.."|r")
		end
	end
end)