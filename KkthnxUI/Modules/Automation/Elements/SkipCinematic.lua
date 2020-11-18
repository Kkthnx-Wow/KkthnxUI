local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

--	Automatically sets your role (iSpawnAtHome)

local _G = _G

local IsControlKeyDown = _G.IsControlKeyDown

local function SetupSkipCinematic()
	if not IsControlKeyDown() then
		CinematicFrame_CancelCinematic()
	end
end

function Module:CreateSkipCinematic()
	if not C["Automation"].AutoSkipCinematic then
		return
	end

	K:RegisterEvent("CINEMATIC_START", SetupSkipCinematic)

	-- Hook movies and stop them before they get called
	local PlayMovie_hook = MovieFrame_PlayMovie
	MovieFrame_PlayMovie = function(...)
		if IsControlKeyDown() then
			PlayMovie_hook(...)
		else
			GameMovieFinished()
		end
	end
end