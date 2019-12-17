local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

function Module:CreateAutoBlockMovies()
	if C["Automation"].BlockMovies == true then
		-- Allow space bar, escape key and enter key to cancel cinematic without confirmation
		CinematicFrame:HookScript("OnKeyDown", function(self, key)
			if key == "ESCAPE" then
				if CinematicFrame:IsShown() and CinematicFrame.closeDialog and CinematicFrameCloseDialogConfirmButton then
					CinematicFrameCloseDialog:Hide()
				end
			end
		end)

		CinematicFrame:HookScript("OnKeyUp", function(self, key)
			if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
				if CinematicFrame:IsShown() and CinematicFrame.closeDialog and CinematicFrameCloseDialogConfirmButton then
					CinematicFrameCloseDialogConfirmButton:Click()
				end
			end
		end)

		MovieFrame:HookScript("OnKeyUp", function(self, key)
			if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
				if MovieFrame:IsShown() and MovieFrame.CloseDialog and MovieFrame.CloseDialog.ConfirmButton then
					MovieFrame.CloseDialog.ConfirmButton:Click()
				end
			end
		end)
	end
end