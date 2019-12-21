local K = unpack(select(2, ...))
local Module = K:NewModule("Announcements")

function Module:OnEvent()
    Module:CreateInterruptAnnounce()
    Module:CreateItemAnnounce()
    Module:CreateRareAnnounce()
    Module:CreateSaySappedAnnounce()
end

function Module:OnEnable()
    K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnEvent)
end