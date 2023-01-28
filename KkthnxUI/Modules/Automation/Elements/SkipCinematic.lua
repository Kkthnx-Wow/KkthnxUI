local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local autoSkipCinematic = C["Automation"].AutoSkipCinematic

local function skipOnKeyDown(self, key)
	if key == "ESCAPE" and autoSkipCinematic then
		if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
			self.closeDialog:Hide()
		end
	end
end

local function skipOnKeyUp(self, key)
	if (key == "SPACE" or key == "ESCAPE" or key == "ENTER") and autoSkipCinematic then
		if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
			self.closeDialog.confirmButton:Click()
		end
	end
end

function Module:CreateSkipCinematic()
	MovieFrame.closeDialog = MovieFrame.CloseDialog
	MovieFrame.closeDialog.confirmButton = MovieFrame.CloseDialog.ConfirmButton
	CinematicFrame.closeDialog.confirmButton = CinematicFrameCloseDialogConfirmButton

	MovieFrame:HookScript("OnKeyDown", skipOnKeyDown)
	MovieFrame:HookScript("OnKeyUp", skipOnKeyUp)
	CinematicFrame:HookScript("OnKeyDown", skipOnKeyDown)
	CinematicFrame:HookScript("OnKeyUp", skipOnKeyUp)
end
