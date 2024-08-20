local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Skip cinematic on key press
local function handleKey(self, key, isKeyUp)
	if not C["Automation"].AutoSkipCinematic then
		return
	end

	-- Handle ESC, SPACE, or ENTER key
	if key == "ESCAPE" or key == "SPACE" or key == "ENTER" then
		local closeDialog = self.closeDialog
		if self:IsShown() and closeDialog and closeDialog.confirmButton then
			if isKeyUp then
				closeDialog.confirmButton:Click() -- Confirm the action when key is released
			else
				closeDialog:Hide() -- Hide the dialog when ESC is pressed
			end
		end
	end
end

-- Setup the skipping of cinematics
function Module:CreateSkipCinematic()
	-- Assign the confirmButton reference for Movie and Cinematic frames
	MovieFrame.closeDialog = MovieFrame.CloseDialog
	MovieFrame.closeDialog.confirmButton = MovieFrame.CloseDialog.ConfirmButton

	CinematicFrame.closeDialog.confirmButton = CinematicFrameCloseDialogConfirmButton

	-- Hook both key down and key up events
	MovieFrame:HookScript("OnKeyDown", function(self, key)
		handleKey(self, key, false)
	end)
	MovieFrame:HookScript("OnKeyUp", function(self, key)
		handleKey(self, key, true)
	end)

	CinematicFrame:HookScript("OnKeyDown", function(self, key)
		handleKey(self, key, false)
	end)
	CinematicFrame:HookScript("OnKeyUp", function(self, key)
		handleKey(self, key, true)
	end)
end
