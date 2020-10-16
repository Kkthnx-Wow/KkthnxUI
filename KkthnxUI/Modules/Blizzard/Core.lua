local K = unpack(select(2, ...))
local Module = K:NewModule("Blizzard")

local _G = _G

local HideUIPanel = _G.HideUIPanel
local ShowUIPanel = _G.ShowUIPanel

function Module:OnEnable()
    -- Fix spellbook taint
    ShowUIPanel(SpellBookFrame)
    HideUIPanel(SpellBookFrame)

    self:CreateAlertFrames()
    self:CreateAltPowerbar()
    self:CreateColorPicker()
    self:CreateMirrorBars()
    self:CreateObjectiveFrame()
    self:CreateOrderHallIcon()
    self:CreateRaidUtility()
    self:CreateTalkingHeadFrame()
    self:CreateTimerTracker()
    self:CreateUIWidgets()
end