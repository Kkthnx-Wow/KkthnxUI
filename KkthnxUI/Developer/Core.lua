-- Create a new module for the death counter
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

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

-- Set variables for the cvars we want to monitor
local taintlog = "taintLog"
local profiling = "scriptProfile"

-- Set the reminder duration in seconds
local reminderDuration = 300 -- 5 minutes

-- Function to check the cvars and show a reminder message if they are on for too long
local function CheckCvars()
	-- Check if the cvars are on
	if GetCVarBool(taintlog) or GetCVarBool(profiling) then
		-- Show the reminder message
		print("Taintlog and/or profiling are still on. Please turn them off using the following commands:")
		print(format("/console %s 0", taintlog))
		print(format("/console %s 0", profiling))

		-- Schedule the next check
		C_Timer.After(reminderDuration, CheckCvars)
	end
end

-- Schedule the first check
C_Timer.After(reminderDuration, CheckCvars)
