--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/Core.lua
	Purpose:
		Small quality of life features, one per file, all off until switched on.
		This file owns the module, starts each feature whose toggle is set, and
		provides the one piece they share: a centre screen alert text.

			CombatAlert.lua      +Combat and -Combat text on entering or leaving combat
			Durability.lua       a pulsing warning when gear is badly worn
			GroupDeath.lua       "name DIED" text when a group member dies
			HideErrors.lua       quiet the red error spam, keep the useful ones
			HideTips.lua         turn off tutorial pop ups and help tips
			BossBanner.lua       hide the boss kill banner
			SecondaryStats.lua   crit, haste, mastery and versatility readout
			RareAlert.lua        announce rares that appear on the minimap
			BlockInvites.lua     turn away group invites from strangers
			CopyName.lua         "Copy Name" on player right click menus
			Lockout.lua          the Bloodlust lockout as an icon with a countdown
			TeleportPrompt.lua   one click dungeon teleport after joining a group
			GuildBest.lua        guild best Mythic Plus runs on the dungeons window
			TradeTabs.lua        profession icons down the side of the professions window
			Crosshair.lua        a small crosshair in the middle of the screen
			QuestAnnounce.lua    tell the group about accepted and finished quests
			AchievementShot.lua  take a screenshot when an achievement is earned
			AutoLog.lua          turn combat logging on in raids and Mythic dungeons

		A feature only registers its events when its toggle is on, so a switched
		off feature costs nothing. Toggles apply on reload. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("QoL")

local CreateFrame = CreateFrame
local UIParent = UIParent

-- ---------------------------------------------------------------------------
-- Shared alert text
-- ---------------------------------------------------------------------------
-- Module:NewAlert(key, label, point, yOffset) returns a small object that owns
-- one frame and one mover. Only features that are switched on register an alert,
-- so a feature that is off never builds one.
--
--   alert:Flash(text, r, g, b)   fade in, hold, fade out
--   alert:Pulse(text, r, g, b)   stay up and pulse until Clear
--   alert:Clear()                hide it
--   alert:Restyle()              re-read the size setting
local alertMixin = {}
alertMixin.__index = alertMixin

local HOLD_SECONDS = 1.6

function alertMixin:Build()
	if self.frame then
		return self.frame
	end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("HIGH")
	frame:EnableMouse(false)
	frame:Hide()

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER")
	frame.Text = text

	-- One group for a single flash, one looping group for a pulse.
	local flash = frame:CreateAnimationGroup()
	local fadeIn = flash:CreateAnimation("Alpha")
	fadeIn:SetFromAlpha(0)
	fadeIn:SetToAlpha(1)
	fadeIn:SetDuration(0.15)
	fadeIn:SetOrder(1)
	local hold = flash:CreateAnimation("Alpha")
	hold:SetFromAlpha(1)
	hold:SetToAlpha(1)
	hold:SetDuration(HOLD_SECONDS)
	hold:SetOrder(2)
	local fadeOut = flash:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(1)
	fadeOut:SetToAlpha(0)
	fadeOut:SetDuration(0.6)
	fadeOut:SetOrder(3)
	flash:SetScript("OnFinished", function()
		frame:Hide()
	end)

	local pulse = text:CreateAnimationGroup()
	local dim = pulse:CreateAnimation("Alpha")
	dim:SetFromAlpha(1)
	dim:SetToAlpha(0.3)
	dim:SetDuration(0.5)
	dim:SetOrder(1)
	local lift = pulse:CreateAnimation("Alpha")
	lift:SetFromAlpha(0.3)
	lift:SetToAlpha(1)
	lift:SetDuration(0.5)
	lift:SetOrder(2)
	pulse:SetLooping("REPEAT")

	frame:SetScript("OnHide", function()
		flash:Stop()
		pulse:Stop()
	end)

	frame.flash, frame.pulse = flash, pulse
	self.frame = frame
	self:Restyle()

	K.CreateMover(frame, self.key, self.label, { self.point, UIParent, self.point, 0, self.yOffset })
	return frame
end

function alertMixin:Restyle()
	local frame = self.frame
	if not frame then
		return
	end
	local size = C.QoL.AlertSize or 24
	K.SetFont(frame.Text, size, "OUTLINE")
	frame:SetSize(size * 8, size + 14)
end

function alertMixin:Show(text, r, g, b)
	local frame = self:Build()
	frame.flash:Stop()
	frame.pulse:Stop()
	frame.Text:SetText(text)
	frame.Text:SetTextColor(r or 1, g or 1, b or 1)
	frame:SetAlpha(1)
	frame:Show()
	return frame
end

function alertMixin:Flash(text, r, g, b)
	self:Show(text, r, g, b).flash:Play()
end

function alertMixin:Pulse(text, r, g, b)
	self:Show(text, r, g, b).pulse:Play()
end

function alertMixin:Clear()
	if self.frame then
		self.frame:Hide()
	end
end

function Module:NewAlert(key, label, point, yOffset)
	return setmetatable({ key = key, label = label, point = point or "CENTER", yOffset = yOffset or 0 }, alertMixin)
end

-- ---------------------------------------------------------------------------
-- Lifecycle
-- ---------------------------------------------------------------------------
-- Each feature file attaches a Setup function. They are started in this order.
local FEATURES = {
	{ "CombatAlert", "SetupCombatAlert" },
	{ "LowDurability", "SetupDurability" },
	{ "GroupDeath", "SetupGroupDeath" },
	{ "HideErrors", "SetupHideErrors" },
	{ "HideTips", "SetupHideTips" },
	{ "HideBossBanner", "SetupBossBanner" },
	{ "SecondaryStats", "SetupSecondaryStats" },
	{ "RareAlert", "SetupRareAlert" },
	{ "BlockInvites", "SetupBlockInvites" },
	{ "CopyName", "SetupCopyName" },
	{ "LustLockout", "SetupLockout" },
	{ "TeleportPrompt", "SetupTeleportPrompt" },
	{ "GuildBest", "SetupGuildBest" },
	{ "TradeTabs", "SetupTradeTabs" },
	{ "Crosshair", "SetupCrosshair" },
	{ "QuestAnnounce", "SetupQuestAnnounce" },
	{ "AchievementShot", "SetupAchievementShot" },
	{ "AutoLog", "SetupAutoLog" },
}

function Module:OnEnable()
	for _, feature in ipairs(FEATURES) do
		local setup = self[feature[2]]
		if C.QoL[feature[1]] and setup then
			setup(self)
		end
	end
end

-- Re-read the alert size on every alert that has been built, for the slider.
function Module:Refresh()
	for _, alert in pairs(self.alerts or {}) do
		alert:Restyle()
	end
end

-- Features create their alerts through here so Refresh can reach them.
function Module:RegisterAlert(key, label, point, yOffset)
	self.alerts = self.alerts or {}
	local alert = self:NewAlert(key, label, point, yOffset)
	self.alerts[key] = alert
	-- Built now, hidden, so its mover is there in Move UI before the first alert.
	alert:Build()
	return alert
end
