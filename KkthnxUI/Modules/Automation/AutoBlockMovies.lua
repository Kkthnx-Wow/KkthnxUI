local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("BlockMovies", "AceEvent-3.0")

local playerName = UnitName("player")
local playerRealm = GetRealmName()

-- Movie blocking
local knownMovies = {
	[16] = true, -- Lich King death
	[73] = true, -- Ultraxion death
	[74] = true, -- DeathwingSpine engage
	[75] = true, -- DeathwingSpine death
	[76] = true, -- DeathwingMadness death
	[152] = true, -- Garrosh defeat
	[294] = true, -- Archimonde portal
	[295] = true, -- Archimonde kill
	[549] = true, -- Gul'dan kill
	[656] = true, -- Kil'jaeden kill
	[682] = true, -- L'uras death
	[686] = true, -- Argus portal
	[688] = true, -- Argus kill
}

-- Cinematic blocking
local cinematicZones = {
	["800:1"] = true, -- Firelands bridge lowering
	["875:1"] = true, -- Gate of the Setting Sun gate breach
	["930:3"] = true, -- Tortos cave entry -- Doesn't work, apparently Blizzard don't want us to skip this..?
	["930:7"] = true, -- Ra-Den room opening
	["953:2"] = true, -- After Immerseus, entry to Fallen Protectors
	["953:8"] = true, -- Blackfuse room opening, just outside the door
	["953:9"] = true, -- Blackfuse room opening, in Thok area
	["953:12"] = true, -- Mythic Garrosh Phase 4
	["964:1"] = true, -- Bloodmaul Slag Mines, activating bridge to Roltall
	["969:2"] = true, -- Shadowmoon Burial Grounds, final boss introduction
	["984:1"] = {false, -1, true}, -- Auchindoun has 2 cinematics. One before the 1st boss (false) and one after the 3rd boss (true), 2nd arg is garbage for the iterator to work.
	["993:2"] = true, -- Grimrail Depot, boarding the train
	["993:4"] = true, -- Grimrail Depot, destroying the train
	["994:3"] = true, -- Highmaul, Kargath Death
	["1042:1"] = true, -- Maw of Souls, after Ymiron
	["1147:6"] = true, -- Tomb of Sargeras, portal to Kil'jaeden
	["1188:1"] = true, -- Antorus, teleportation to "The exhaust"
	["1188:6"] = true, -- Antorus, teleportation to "The burning throne"
	["1188:9"] = true, -- Antorus, magni portal to argus room
}

function Module:PLAY_MOVIE(_, id)
	if knownMovies[id] and C["Automation"].BlockMovies then
		if KkthnxUIData[playerRealm][playerName].WatchedMovies[id] then
			K.Print(L["Automation"].MovieBlocked)
			MovieFrame:Hide()
		else
			KkthnxUIData[playerRealm][playerName].WatchedMovies[id] = true
		end
	end
end

-- Cinematic skipping hack to workaround an item (Vision of Time) that creates cinematics in Siege of Orgrimmar.
function Module:SiegeOfOrgrimmarCinematics()
	local hasItem
	for i = 105930, 105935 do -- Vision of Time items
		local _, _, cd = GetItemCooldown(i)
		if cd > 0 then hasItem = true end -- Item is found in our inventory
	end
	if hasItem and not self.SiegeOfOrgrimmarCinematicsFrame then
		local tbl = {[149370] = true, [149371] = true, [149372] = true, [149373] = true, [149374] = true, [149375] = true}
		self.SiegeOfOrgrimmarCinematicsFrame = CreateFrame("Frame")
		self.SiegeOfOrgrimmarCinematicsFrame:SetScript("OnEvent", function(_, _, _, _, _, _, spellId)
			if tbl[spellId] then
				Module:UnregisterEvent("CINEMATIC_START")
				Module:ScheduleTimer("RegisterEvent", 10, "CINEMATIC_START")
			end
		end)
		self.SiegeOfOrgrimmarCinematicsFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
	end
end

function Module:CINEMATIC_START()
	if C["Automation"].BlockMovies then
		SetMapToCurrentZone()
		local areaId = GetCurrentMapAreaID() or 0
		local areaLevel = GetCurrentMapDungeonLevel() or 0
		local id = ("%d:%d"):format(areaId, areaLevel)

		if cinematicZones[id] then
			if type(cinematicZones[id]) == "table" then -- For zones with more than 1 cinematic per floor
				if type(KkthnxUIData[playerRealm][playerName].WatchedMovies[id]) ~= "table" then KkthnxUIData[playerRealm][playerName].WatchedMovies[id] = {} end
				for i=#cinematicZones[id], 1, -1 do -- In reverse so for example: we don't trigger off the first boss when at the third boss
					local _, _, done = C_Scenario.GetCriteriaInfoByStep(1,i)
					if done == cinematicZones[id][i] then
						if KkthnxUIData[playerRealm][playerName].WatchedMovies[id][i] then
							K.Print(L["Automation"].MovieBlocked)
							CinematicFrame_CancelCinematic()
						else
							KkthnxUIData[playerRealm][playerName].WatchedMovies[id][i] = true
						end
						return
					end
				end
			else
				if KkthnxUIData[playerRealm][playerName].WatchedMovies[id] then
					K.Print(L["Automation"].MovieBlocked)
					CinematicFrame_CancelCinematic()
				else
					KkthnxUIData[playerRealm][playerName].WatchedMovies[id] = true
				end
			end
		end
	end
end

function Module:OnEnable()
	if C["Automation"].BlockMovies ~= true then return end

	self:RegisterEvent("CINEMATIC_START")
	self:RegisterEvent("PLAY_MOVIE")
	self:SiegeOfOrgrimmarCinematics() -- Sexy hack until cinematics have an id system (never)
end

function Module:OnDisable()
	self:UnregisterEvent("CINEMATIC_START")
	self:UnregisterEvent("PLAY_MOVIE")
end