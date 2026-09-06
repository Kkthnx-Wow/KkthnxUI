--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/MovieSkip.lua
	Purpose:
		Skip cinematics and pre-rendered movies for players who have seen them.
		Off by default so a first playthrough keeps its story. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Automation")

local CinematicFrame_CancelCinematic = CinematicFrame_CancelCinematic
local MovieFrame = MovieFrame

-- In-game cinematics (the scripted camera scenes).
function Module:CINEMATIC_START()
	if C.Automation.SkipCinematics and CinematicFrame_CancelCinematic then
		CinematicFrame_CancelCinematic()
	end
end

-- Pre-rendered movies (expansion intros and the like).
function Module:PLAY_MOVIE()
	if C.Automation.SkipCinematics and MovieFrame and MovieFrame.FinishMovie then
		MovieFrame:FinishMovie()
	end
end

function Module:SetupMovieSkip()
	self:RegisterEvent("CINEMATIC_START", "CINEMATIC_START")
	self:RegisterEvent("PLAY_MOVIE", "PLAY_MOVIE")
end
