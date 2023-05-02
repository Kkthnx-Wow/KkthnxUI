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
local cvars = { "taintLog", "scriptProfile" }

-- Set the reminder duration in seconds
local reminderDuration = 300 -- 5 minutes

-- Function to check the cvars and show a reminder message if they are on for too long
local function CheckCvars()
	local found = false

	-- Loop over the cvars
	for _, cvar in ipairs(cvars) do
		-- Check if the cvar is on
		if GetCVarBool(cvar) then
			found = true

			-- Show the reminder message
			print(format("%s is still on. Please turn it off using the following command:", cvar))
			print(format("/console %s 0", cvar))
		end
	end

	-- Schedule the next check if needed
	if found then
		C_Timer.After(reminderDuration, CheckCvars)
	end
end

-- Schedule the first check
C_Timer.After(reminderDuration, CheckCvars)
