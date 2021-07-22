local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

function Module:CreateSkipCinematic()
	if not C["Automation"].AutoSkipCinematic then
		return
	end

	-- Allow space bar, escape key and enter key to cancel cinematic without confirmation
	if CinematicFrame.closeDialog and not CinematicFrame.closeDialog.confirmButton then
		CinematicFrame.closeDialog.confirmButton = CinematicFrameCloseDialogConfirmButton
	end

	CinematicFrame:HookScript("OnKeyDown", function(self, key)
		if key == "ESCAPE" then
			if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
				self.closeDialog:Hide()
			end
		end
	end)

	CinematicFrame:HookScript("OnKeyUp", function(self, key)
		if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
			if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
				self.closeDialog.confirmButton:Click()
			end
		end
	end)

	MovieFrame:HookScript("OnKeyUp", function(self, key)
		if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
			if self:IsShown() and self.CloseDialog and self.CloseDialog.ConfirmButton then
				self.CloseDialog.ConfirmButton:Click()
			end
		end
	end)
end