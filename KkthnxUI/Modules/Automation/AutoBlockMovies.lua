local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local IsEncounterInProgress = _G.IsEncounterInProgress
local IsInInstance = _G.IsInInstance
local C_Map_GetBestMapForUnit = _G.C_Map.GetBestMapForUnit

local neverFilter = {
	[486] = true, -- Tomb of Sarg Intro
	[487] = true, -- Alliance Broken Shore cut-scene
	[488] = true, -- Horde Broken Shore cut-scene
	[489] = true, -- Unknown, currently encrypted
	[490] = true, -- Unknown, currently encrypted
}

function Module:PLAY_MOVIE(id)
	if id and not neverFilter[id] then
		--K.Print("PLAY_MOVIE fired for ID: "..id)

		local isInstance, instanceType = IsInInstance()
		if not isInstance or C_Garrison:IsOnGarrisonMap() or instanceType == "scenario" and not IsEncounterInProgress() then
			return
		end

		if C["Automation"].BlockMovies and _G.KkthnxUIData[K.Realm][K.Name].MoviesSeen[id] then
			MovieFrame:Hide() -- Can only just hide movie frame safely now, which means can't stop audio anymore :\
			K.Print("has attempted to skip a cut scene automatically.")
		else
			_G.KkthnxUIData[K.Realm][K.Name].MoviesSeen[id] = true
		end
	end
end

function Module:CINEMATIC_START()
	-- K.Print("CINEMATIC_START fired")
	local isInstance, instanceType = IsInInstance()
	if not isInstance or C_Garrison:IsOnGarrisonMap() or instanceType == "scenario" and not IsEncounterInProgress() then
		return
	end

	local currentMapID = C_Map_GetBestMapForUnit("player")
	if not currentMapID then -- Protection from map failures in zones that have no maps yet
		return
	end

	if C["Automation"].BlockMovies and _G.KkthnxUIData[K.Realm][K.Name].MoviesSeen[currentMapID] then
		CinematicFrame_CancelCinematic()
		K.Print("has attempted to skip a cut scene automatically.")
	else
		_G.KkthnxUIData[K.Realm][K.Name].MoviesSeen[currentMapID] = true
	end
end

function Module:CreateAutoMovieBlock()
	if C["Automation"].BlockMovies then
		K:RegisterEvent("PLAY_MOVIE", self.PLAY_MOVIE)
		K:RegisterEvent("CINEMATIC_START", self.CINEMATIC_START)
	else
		K:UnregisterEvent("PLAY_MOVIE", self.PLAY_MOVIE)
		K:UnregisterEvent("CINEMATIC_START", self.CINEMATIC_START)
	end
end