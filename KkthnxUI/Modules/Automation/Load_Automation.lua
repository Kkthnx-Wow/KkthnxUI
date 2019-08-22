local _G = _G
local K = _G.unpack(_G.select(2, ...))
local Module = K:NewModule("Automation", "AceEvent-3.0")

if not Module then
    return
end

function Module:OnEnable()
    self:CreateAutoBlockMovies()
    self:CreateAutoDeclineDuels()
    self:CreateAutoInvite()
    self:CreateAutoRelease()
    self:CreateAutoResurrect()
    self:CreateAutoReward()
    self:CreateAutoWhisperInvite()
    self:CreateAutoScreenshot()
end