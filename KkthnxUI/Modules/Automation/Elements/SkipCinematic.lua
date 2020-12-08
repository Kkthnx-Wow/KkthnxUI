local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

-- Sourced: ElvUI_WindTools

local _G = _G
local string_format = _G.string.format
local string_match = _G.string.match
local string_sub = _G.string.sub

local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit
local C_Timer_After = _G.C_Timer.After
local CinematicFrame_CancelCinematic = _G.CinematicFrame_CancelCinematic
local GameMovieFinished = _G.GameMovieFinished
local IsModifierKeyDown = _G.IsModifierKeyDown

do
	local alreadySkipped = false
	local function TrySkippingCinematic()
		if alreadySkipped then
			return
		end

		CinematicFrame_CancelCinematic()
		C_Timer_After(0.1, function()
			if not _G.CinematicFrame:IsShown() then
				K.Print(L["Skipped The Cutscene"])
				alreadySkipped = true
			end
		end)
	end

	function Module:SetupSkipCinematic()
		if C["Automation"].AutoSkipCinematic and not IsModifierKeyDown() then
			C_Timer_After(0.1, TrySkippingCinematic)
			C_Timer_After(1, TrySkippingCinematic)
			C_Timer_After(3, TrySkippingCinematic)
			C_Timer_After(3.5, function()
				if not alreadySkipped then
					if not (C_Map_GetBestMapForUnit("player") == 1670 and K.Level == 60) then
						K.Print(L["This Cutscene Can Not Be Skipped"])
					end
				else
					alreadySkipped = false
				end
			end)
		end
	end
end

do
	local initialized = false
	function Module:CreateSkipCinematic()
		if not C["Automation"].AutoSkipCinematic or initialized then
			return
		end

		local PlayMovie = _G.MovieFrame_PlayMovie

		_G.MovieFrame_PlayMovie = function(frame, movieID, override)
			if C["Automation"].AutoSkipCinematic and not override then
				if not IsModifierKeyDown() then
					GameMovieFinished()
					K.Print(string_format("%s |cff71d5ff|Hwtcutscene:%s|h[%s]|h|r", L["Skipped The Cutscene"], movieID, L["Replay"]))
					return
				end
			end

			PlayMovie(frame, movieID)
		end

		local SetHyperlink = _G.ItemRefTooltip.SetHyperlink
		function _G.ItemRefTooltip:SetHyperlink(data, ...)
			if string_sub(data, 1, 10) == "wtcutscene" then
				local movieID = string_match(data, "wtcutscene:(%d+)")
				if movieID then
					_G.MovieFrame_PlayMovie(_G.MovieFrame, movieID, true)
					return
				end
			end
			SetHyperlink(self, data, ...)
		end

		K:RegisterEvent("CINEMATIC_START", Module.SetupSkipCinematic)

		initialized = true
	end
end