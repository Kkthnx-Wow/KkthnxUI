local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local CreateFrame = _G.CreateFrame
local playerName = _G.UnitName("player")
local playerRealm = _G.GetRealmName()

do
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
		[875] = true, -- Killing King Rastakhan
		[876] = true, -- Entering Battle of Dazar'alor
	}

	function Module:PLAY_MOVIE(_, id)
		if knownMovies[id] and C["Automation"].BlockMovies then
			if KkthnxUIData[playerRealm][playerName].WatchedMovies[id] then
				K.Print(L["Move Blocked"])
				MovieFrame:Hide()
			else
				KkthnxUIData[playerRealm][playerName].WatchedMovies[id] = true
			end
		end
	end
end

-- Cinematic skipping hack to workaround an item (Vision of Time) that creates cinematics in Siege of Orgrimmar.
do
	-- Cinematic blocking
	local cinematicZones = {
		[-323] = true, -- Throne of the Tides, zapping the squid after Lazy Naz'jar
		[-367] = true, -- Firelands bridge lowering
		[-437] = true, -- Gate of the Setting Sun gate breach
		[-510] = true, -- Tortos cave entry -- Doesn't work, apparently Blizzard don't want us to skip this..?
		[-514] = true, -- Ra-Den room opening
		[-557] = true, -- After Immerseus, entry to Fallen Protectors
		[-563] = true, -- Blackfuse room opening, just outside the door
		[-564] = true, -- Blackfuse room opening, in Thok area
		[-567] = true, -- Mythic Garrosh Phase 4
		[-573] = true, -- Bloodmaul Slag Mines, activating bridge to Roltall
		[-575] = true, -- Shadowmoon Burial Grounds, final boss introduction
		[-593] = { -- Auchindoun
			"", -- "": Before the 1st boss, the tunnel doesn't have a sub zone
			L["Subzone Eastern Transept"], -- Eastern Transept: After the 3rd boss, Teren'gor porting in
		},
		[-607] = true, -- Grimrail Depot, boarding the train
		[-609] = true, -- Grimrail Depot, destroying the train
		[-612] = true, -- Highmaul, Kargath Death
		[-706] = true, -- Maw of Souls, after Ymiron
		[-855] = true, -- Tomb of Sargeras, portal to Kil'jaeden
		[-909] = true, -- Antorus, teleportation to "The exhaust"
		[-914] = true, -- Antorus, teleportation to "The burning throne"
		[-917] = true, -- Antorus, magni portal to argus room
		[-1004] = true, -- Kings' Rest, before the last boss "Dazar"
		[-1151] = true, -- Uldir, raising stairs for Zul (Zek'voz)
		[-1152] = true, -- Uldir, raising stairs for Zul (Vectis)
		[-1153] = true, -- Uldir, raising stairs for Zul (Fetid Devourer)
		[-1345] = true, -- Crucible of Storms, after killing first boss
		[-1352] = { -- Battle of Dazar'alor
			L["Subzone Grand Bazaar"], -- Grand Bazaar: After killing 2nd boss, Bwonsamdi (Alliance side only)
			L["Subzone Port of Zandalar"], -- Port of Zandalar: After killing blockade, boat arriving
		},
		[-1358] = true, -- Battle of Dazar'alor, after killing 1st boss, Bwonsamdi (Horde side only)
		--[-1364] = true, -- Battle of Dazar'alor, Jaina stage 1 intermission (unskippable)
	}

	function Module:SiegeOfOrgrimmarCinematics()
		local hasItem
		for i = 105930, 105935 do -- Vision of Time items
			local count = GetItemCount(i)
			if count > 0 then
				hasItem = true break
			end -- Item is found in our inventory
		end
		if hasItem and not self.SiegeOfOrgrimmarCinematicsFrame then
			local tbl = {[149370] = true, [149371] = true, [149372] = true, [149373] = true, [149374] = true, [149375] = true}
			self.SiegeOfOrgrimmarCinematicsFrame = CreateFrame("Frame")
			self.SiegeOfOrgrimmarCinematicsFrame:SetScript("OnEvent", function(_, _, _, _, spellId)
				if tbl[spellId] then
					Module:UnregisterEvent("CINEMATIC_START")
					Module:ScheduleTimer("RegisterEvent", 10, "CINEMATIC_START")
				end
			end)
			self.SiegeOfOrgrimmarCinematicsFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
		end
	end

	-- Cinematic skipping hack to workaround specific toys that create cinematics.
	function Module:ToyCheck()
		local toys = { -- Classed as items not toys
			133542, -- Tosselwrench's Mega-Accurate Simulation Viewfinder
		}
		for i = 1, #toys do
			if PlayerHasToy(toys[i]) and not self.toysFrame then
				local tbl = {
					[201179] = true -- Deathwing Simulator
				}
				self.toysFrame = CreateFrame("Frame")
				self.toysFrame:SetScript("OnEvent", function(_, _, _, _, spellId)
					if tbl[spellId] then
						K:UnregisterEvent("CINEMATIC_START", self.CINEMATIC_START)
						Module:ScheduleTimer("RegisterEvent", 5, "CINEMATIC_START")
					end
				end)
				self.toysFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
			end
		end
	end

	function Module:CINEMATIC_START()
		if C["Automation"].BlockMovies then
			local id = -(C_Map_GetBestMapForUnit("player") or 0)

			if cinematicZones[id] then
				if type(cinematicZones[id]) == "table" then -- For zones with more than 1 cinematic per map id
					if type(KkthnxUIData[playerRealm][playerName].WatchedMovies[id]) ~= "table" then
						KkthnxUIData[playerRealm][playerName].WatchedMovies[id] = {}
					end
					for i = 1, #cinematicZones[id] do
						local subZone = cinematicZones[id][i]
						if subZone == GetSubZoneText() then
							if KkthnxUIData[playerRealm][playerName].WatchedMovies[id][i] then
								K.Print(L["Move Blocked"])
								CinematicFrame_CancelCinematic()
							else
								KkthnxUIData[playerRealm][playerName].WatchedMovies[id][i] = true
							end
							return
						end
					end
				else
					if KkthnxUIData[playerRealm][playerName].WatchedMovies[id] then
						K.Print(L["Move Blocked"])
						CinematicFrame_CancelCinematic()
					else
						KkthnxUIData[playerRealm][playerName].WatchedMovies[id] = true
					end
				end
			end
		end
	end
end

function Module:CreateAutoBlockMovies()
	if C["Automation"].BlockMovies == true then
		K:RegisterEvent("CINEMATIC_START", self.CINEMATIC_START)
	    K:RegisterEvent("PLAY_MOVIE", self.PLAY_MOVIE)
	    self:SiegeOfOrgrimmarCinematics() -- Sexy hack until cinematics have an id system (never)
	    self:ToyCheck() -- Sexy hack until cinematics have an id system (never)

	    -- XXX temp 8.1.5
	    for id in next, KkthnxUIData[K.Realm][K.Name].WatchedMovies do
		    if type(id) == "string" then
			    KkthnxUIData[K.Realm][K.Name].WatchedMovies[id] = nil
		    end
        end

	    KkthnxUIData[K.Realm][K.Name].WatchedMovies[-593] = nil -- Auchindoun temp reset
	end
end