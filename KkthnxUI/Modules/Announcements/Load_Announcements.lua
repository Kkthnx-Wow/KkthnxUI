local K = unpack(select(2, ...))
local Module = K:NewModule("Announcements")

function Module:OnEnable()
    -- Module:CreateDispellAnnounce()
    Module:CreateInterruptAnnounce()
    Module:CreateItemAnnounce()
    Module:CreateRareAnnounce()
    Module:CreateSaySappedAnnounce()
end