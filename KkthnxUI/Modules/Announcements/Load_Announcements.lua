local K = unpack(select(2, ...))
local Module = K:NewModule("Announcements", "AceEvent-3.0")

function Module:OnEvent()
    Module:CreateArenaAnnounce()
    Module:CreateInterruptAnnounce()
    Module:CreateSaySappedAnnounce()
end

function Module:OnEnable()
    K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnEvent)
end