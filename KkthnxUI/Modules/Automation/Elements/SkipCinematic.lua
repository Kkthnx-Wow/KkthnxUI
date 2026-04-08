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
local function skipOnKeyDown(self, key)
	if not C["Automation"].ConfirmCinematicSkip then
		return
	end

	-- REASON: Hides the confirmation dialog when ESCAPE is pressed to allow standard behavior if desired.
	if key == "ESCAPE" then
		if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
			self.closeDialog:Hide()
		end
	end
end

local function skipOnKeyUp(self, key)
	if not C["Automation"].ConfirmCinematicSkip then
		return
	end

	-- REASON: Automatically clicks the 'Confirm' button when common skip keys are pressed.
	if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
		if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
			self.closeDialog.confirmButton:Click()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateSkipCinematic()
	-- REASON: Feature entry point; hooks Blizzard's cinematic frames to streamline skipping.
	local movieFrame = _G.MovieFrame
	local cinematicFrame = _G.CinematicFrame
	local cinematicFrameCloseDialogConfirmButton = _G.CinematicFrameCloseDialogConfirmButton

	if movieFrame then
		movieFrame.closeDialog = movieFrame.CloseDialog
		if movieFrame.closeDialog then
			movieFrame.closeDialog.confirmButton = movieFrame.closeDialog.ConfirmButton
		end

		movieFrame:HookScript("OnKeyDown", skipOnKeyDown)
		movieFrame:HookScript("OnKeyUp", skipOnKeyUp)
	end

	if cinematicFrame then
		if not cinematicFrame.closeDialog then
			cinematicFrame.closeDialog = {}
		end
		cinematicFrame.closeDialog.confirmButton = cinematicFrameCloseDialogConfirmButton

		cinematicFrame:HookScript("OnKeyDown", skipOnKeyDown)
		cinematicFrame:HookScript("OnKeyUp", skipOnKeyUp)
	end
end
