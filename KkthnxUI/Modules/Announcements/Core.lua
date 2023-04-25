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
		pcall(self[funcName], self)
	end
end
