local K = unpack(select(2, ...))
local Module = K:NewModule("Blizzard")

local _G = _G

function Module:OnEnable()
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