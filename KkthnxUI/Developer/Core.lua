local K, C = KkthnxUI[1], KkthnxUI[2]
-- local Module = K:GetModule("Miscellaneous")

K.Devs = {
	["Kkthnx-Area 52"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

-- Your taintLog module
local taintLogModule = K:NewModule("TaintLog")

-- Function to toggle taintLog setting
function taintLogModule.ToggleTaintLog()
	local currentSetting = GetCVar("taintLog")

	if currentSetting == "0" then
		SetCVar("taintLog", "1")
		print("Taint log is now |cFF00FF00ON.|r") -- Green color for "ON"
	else
		SetCVar("taintLog", "0")
		print("Taint log is now |cFFFF0000OFF.|r") -- Red color for "OFF"
	end
end

-- Function to check and print taintLog status on login/reload
function taintLogModule.CheckTaintLogStatus()
	local currentSetting = GetCVar("taintLog")

	if currentSetting == "0" then
		print("Taint log is currently |cFFFF0000OFF.|r") -- Red color for "OFF"
	else
		print("Taint log is currently |cFF00FF00ON.|r") -- Green color for "ON"
	end

	-- Unregister the event after checking
	K:UnregisterEvent("PLAYER_ENTERING_WORLD", taintLogModule.CheckTaintLogStatus)
end

-- Add an OnEnable function
function taintLogModule:OnEnable()
	-- Register events for taintLog
	K:RegisterEvent("PLAYER_ENTERING_WORLD", taintLogModule.CheckTaintLogStatus)
	SLASH_TOGGLETAINTLOG1 = "/ttl"
	SlashCmdList["TOGGLETAINTLOG"] = taintLogModule.ToggleTaintLog
end
