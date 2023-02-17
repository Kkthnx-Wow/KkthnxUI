local K = KkthnxUI[1]
local Module = K:NewModule("Blizzard")

function Module:OnEnable()
	self:CreateAlertFrames()
	self:CreateAltPowerbar()
	self:CreateColorPicker()
	self:CreateMirrorBars()
	self:CreateObjectiveFrame()
	self:CreateOrderHallIcon()
	self:CreateTimerTracker()
	self:CreateUIWidgets()
end
