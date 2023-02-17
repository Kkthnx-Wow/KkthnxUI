local K = KkthnxUI[1]
local Module = K:NewModule("Announcements")

function Module:OnEnable()
	Module:CreateHealthAnnounce()
	Module:CreateInterruptAnnounce()
	Module:CreateItemAnnounce()
	Module:CreateKeystoneAnnounce()
	Module:CreateKillingBlow()
	Module:CreatePullCountdown()
	Module:CreateQuestNotifier()
	Module:CreateRareAnnounce()
	Module:CreateResetInstance()
	Module:CreateSaySappedAnnounce()
end
