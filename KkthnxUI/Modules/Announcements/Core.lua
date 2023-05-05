local K = KkthnxUI[1]
local Module = K:NewModule("Announcements")

function Module:OnEnable()
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
