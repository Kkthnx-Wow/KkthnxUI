local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local _G = _G

local CinematicFrame = _G.CinematicFrame
local CinematicFrameCloseDialogConfirmButton = _G.CinematicFrameCloseDialogConfirmButton
local MovieFrame = _G.MovieFrame

local function skipOnKeyDown(self, key)
	if not C["Automation"].AutoSkipCinematic then
		return
	end

	if key == "ESCAPE" then
		if self:IsShown() and self.closeDialog and self.closeDialog.confirmButton then
			self.closeDialog:Hide()
		end
	end
end

local function skipOnKeyUp(self, key)
	if not C["Automation"].AutoSkipCinematic then
		return
	end

	if key == "SPACE" or key == "ESCAPE" or key == "ENTER" then
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
