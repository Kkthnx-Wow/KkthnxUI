---@diagnostic disable: undefined-global
--[[-----------------------------------------------------------------------------
-- GUIReloadTracker
--
-- Owns the config UI's pending-reload queue and reload prompt behavior.
--
-- REASON: GUI.lua should not carry queue state, popup formatting, and reload
-- decision rules inline with widget builders. This module keeps that subsystem
-- isolated while GUI.lua still decides which settings have live hooks.
-----------------------------------------------------------------------------]]

local format = string.format
local next = next
local pairs = pairs
local print = print
local tostring = tostring
local wipe = table.wipe

local C_Timer = C_Timer
local StaticPopupDialogs = StaticPopupDialogs
local StaticPopup_Show = StaticPopup_Show

local ReloadTracker = {
	PendingReloads = {},
	IsShowing = false,
	DebugMode = false,
}

KkthnxUI[1].GUIReloadTracker = ReloadTracker

function ReloadTracker:DebugLog(message)
	if self.DebugMode then
		print("|cff669DFFKkthnxUI ReloadDebug:|r " .. message)
	end
end

function ReloadTracker:RequiresReload(configPath, hasHook, forceReload)
	self:DebugLog("RequiresReload check for: " .. configPath .. " (hasHook: " .. tostring(hasHook) .. ", forceReload: " .. tostring(forceReload) .. ")")

	if forceReload then
		self:DebugLog("Reload required: explicitly forced")
		return true
	end

	if not hasHook then
		self:DebugLog("Reload required: no hook available")
		return true
	end

	self:DebugLog("No reload needed: hook available for real-time updates")
	return false
end

function ReloadTracker:Add(configPath, settingName)
	self:DebugLog("Adding to reload queue: " .. configPath .. " (" .. (settingName or configPath) .. ")")

	if not self.PendingReloads[configPath] then
		self.PendingReloads[configPath] = settingName or configPath
		if not self.IsShowing then
			self:DebugLog("Showing reload prompt immediately")
			self:ShowReloadPrompt()
		end
	else
		self:DebugLog("Setting already in reload queue: " .. configPath)
	end
end

function ReloadTracker:ShowReloadPrompt()
	self:DebugLog("ShowReloadPrompt called")

	if self.IsShowing then
		self:DebugLog("Reload prompt already showing, skipping")
		return
	end

	if not next(self.PendingReloads) then
		self:DebugLog("No pending reloads, skipping prompt")
		return
	end

	self.IsShowing = true

	local count = 0
	for _ in pairs(self.PendingReloads) do
		count = count + 1
	end

	local message
	if count == 1 then
		local _, settingName = next(self.PendingReloads)
		message = format("The setting '%s' requires a UI reload to take effect.\n\nReload now?", settingName)
	else
		message = format("%d settings have been changed that require a UI reload.\n\nReload now?", count)
	end

	self:DebugLog("Showing reload prompt: " .. message)
	StaticPopupDialogs["KKTHNXUI_RELOAD_UI"].text = message
	StaticPopup_Show("KKTHNXUI_RELOAD_UI")
end

function ReloadTracker:ClearQueue()
	self:DebugLog("Clearing reload queue")
	wipe(self.PendingReloads)
	self.IsShowing = false
end

function ReloadTracker:HasPendingReloads()
	local hasReloads = next(self.PendingReloads) ~= nil
	self:DebugLog("HasPendingReloads: " .. tostring(hasReloads))
	return hasReloads
end

function ReloadTracker:OnGUIClose()
	self:DebugLog("OnGUIClose called")
	if self:HasPendingReloads() and not self.IsShowing then
		self:DebugLog("Showing reload prompt on GUI close")
		C_Timer.After(0.1, function()
			self:ShowReloadPrompt()
		end)
	else
		self:DebugLog("No reload prompt needed on GUI close")
	end
end

