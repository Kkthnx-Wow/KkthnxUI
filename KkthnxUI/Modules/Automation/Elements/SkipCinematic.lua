--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically skips cinematics and movies with a single keypress.
-- - Design: Hooks MovieFrame and CinematicFrame to automatically click the confirm button on key down/up.
-- - Events: OnKeyDown, OnKeyUp for MovieFrame and CinematicFrame
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals to reduce lookup overhead.
local _G = _G

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function getSkipParts(self)
	local movieFrame = _G["MovieFrame"]
	if self == movieFrame then
		local dialog = movieFrame.CloseDialog
		return dialog, dialog and dialog.ConfirmButton
	end

	return _G["CinematicFrameCloseDialog"], _G["CinematicFrameCloseDialogConfirmButton"]
end

local function skipOnKeyDown(self, key)
	if not C["Automation"].ConfirmCinematicSkip then
		return
	end

	-- REASON: Hides the confirmation dialog when ESCAPE is pressed to allow standard behavior if desired.
	if key == "ESCAPE" then
		local dialog = getSkipParts(self)
		if self:IsShown() and dialog then
			dialog:Hide()
		end
	end
end

local function skipOnKeyUp(self, key)
	if not C["Automation"].ConfirmCinematicSkip then
		return
	end

	-- REASON: Automatically clicks the 'Confirm' button when common skip keys are pressed.
	if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
		local _, confirmButton = getSkipParts(self)
		if self:IsShown() and confirmButton then
			confirmButton:Click()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
-- REASON: Install the key hooks at most once. The per-key handlers already gate on
-- C["Automation"].ConfirmCinematicSkip, so hooking is harmless while the feature is off,
-- and HookScript cannot be undone anyway. Without this guard, a live re-toggle that
-- re-runs CreateSkipCinematic would stack duplicate hooks on each frame.
local hooksInstalled = false

function Module:CreateSkipCinematic()
	-- REASON: Feature entry point; hooks Blizzard's cinematic frames to streamline skipping.
	if hooksInstalled then
		return
	end
	hooksInstalled = true

	local movieFrame = _G["MovieFrame"]
	local cinematicFrame = _G["CinematicFrame"]

	if movieFrame then
		movieFrame:HookScript("OnKeyDown", skipOnKeyDown)
		movieFrame:HookScript("OnKeyUp", skipOnKeyUp)
	end

	if cinematicFrame then
		cinematicFrame:HookScript("OnKeyDown", skipOnKeyDown)
		cinematicFrame:HookScript("OnKeyUp", skipOnKeyUp)
	end
end
