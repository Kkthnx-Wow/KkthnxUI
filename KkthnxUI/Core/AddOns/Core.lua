local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("AddOns", true)

function Module:CreateAddOnProfiles()
	if not K.isDeveloper then
		return
	end

	-- Add Elements
	local loadAddOnModules = {
		"CreateDeadlyBossModsProfile",
		"CreateHekiliProfile",
	}

	for _, funcName in ipairs(loadAddOnModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
