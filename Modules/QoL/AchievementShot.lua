--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/AchievementShot.lua
	Purpose:
		Take a screenshot a moment after an achievement is earned, once the toast
		and the sound have settled, so the moment is kept without a keypress.
		Achievements already earned on another character of the account are skipped.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local DELAY = 1.2

local queued

local function OnAchievement(_, _, _, alreadyEarned)
	if alreadyEarned or queued then
		return
	end
	queued = true
	C_Timer.After(DELAY, function()
		queued = nil
		Screenshot()
	end)
end

function Module:SetupAchievementShot()
	self:RegisterEvent("ACHIEVEMENT_EARNED", OnAchievement)
end
