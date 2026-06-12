--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Central hub for managing and loading announcement sub-modules.
-- - Design: Uses a safe pcall loop to initialize localized features like interrupts and health alerts.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:NewModule("Announcements")

-- ---------------------------------------------------------------------------
-- MODULE INITIALIZATION
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	-- NOTE: List of sub-modules to be instantiated.
	-- Each corresponding function must be registered to the Module object.
	local loadAnnouncementModules = {
		"CreateHealthAnnounce",
		"CreateInterruptAnnounce",
		"CreateItemAnnounce",
		"CreateKeystoneAnnounce",
		"CreateKillingBlow",
		"CreatePullCountdown",
		"CreateQuestNotifier",
		"CreateRareAnnounce",
		"CreateResetInstance",
		"CreateSaySappedAnnounce",
	}

	-- REASON: Use pcall to ensure that a failure in one announcement element
	-- does not prevent others from loading.
	for _, funcName in ipairs(loadAnnouncementModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
