local K = unpack(select(2, ...))
local Module = K:NewModule("Blizzard")

local HideUIPanel = _G.HideUIPanel
local ShowUIPanel = _G.ShowUIPanel
local SpellBookFrame = _G.SpellBookFrame

function Module:OnEnable()
    -- Fix spellbook taint
    ShowUIPanel(SpellBookFrame)
    HideUIPanel(SpellBookFrame)

    self:CreateAlertFrames()
    self:CreateAltPowerbar()
    self:CreateColorPicker()
    self:CreateErrorFilter()
    self:CreateMirrorBars()
   -- self:CreateNoTutorials()
    self:CreateObjectiveFrame()
    self:CreateRaidUtility()
    self:CreateTalkingHeadFrame()
    self:CreateTimerTracker()
    self:CreateUIWidgets()
end