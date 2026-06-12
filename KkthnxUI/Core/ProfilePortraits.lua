local K, C = KkthnxUI[1], KkthnxUI[2]

--[[-----------------------------------------------------------------------------
-- ProfilePortraits
--
-- Portrait / race-icon helpers for ProfileGUI.
--
-- REASON: ProfileGUI list rendering needs portraits, but atlas probing and fallback
-- selection are a separate visual concern. Keep the lookup ladder here so the
-- main ProfileGUI file reads like UI composition, not icon archaeology.
-----------------------------------------------------------------------------]]

local pcall = pcall
local tonumber = tonumber
local SetPortraitTexture = SetPortraitTexture

local ProfilePortraits = {}
K.ProfilePortraits = ProfilePortraits

local raceAtlasByName = {
	["Human"] = "human",
	["Dwarf"] = "dwarf",
	["Night Elf"] = "nightelf",
	["Gnome"] = "gnome",
	["Draenei"] = "draenei",
	["Worgen"] = "worgen",
	["Void Elf"] = "voidelf",
	["Lightforged Draenei"] = "lightforged",
	["Dark Iron Dwarf"] = "darkirondwarf",
	["KulTiran"] = "kultiran",
	["Mechagnome"] = "mechagnome",
	["Orc"] = "orc",
	["Undead"] = "undead",
	["Tauren"] = "tauren",
	["Troll"] = "troll",
	["Blood Elf"] = "bloodelf",
	["Goblin"] = "goblin",
	["Nightborne"] = "nightborne",
	["Highmountain Tauren"] = "highmountain",
	["Maghar Orc"] = "magharorc",
	["Zandalari Troll"] = "zandalari",
	["Vulpera"] = "vulpera",
	["Pandaren"] = "pandaren",
	["Dracthyr"] = "dracthyr",
	["Earthen"] = "earthen",
}

function ProfilePortraits:GetRaceAtlasName(race, gender)
	if not race or not gender then
		return nil
	end

	local genderNum = tonumber(gender)
	if not genderNum or (genderNum ~= 2 and genderNum ~= 3) then
		return nil
	end

	local atlasRace = raceAtlasByName[race]
	if not atlasRace then
		return nil
	end

	return "raceicon-" .. atlasRace .. "-" .. ((genderNum == 3) and "female" or "male")
end

function ProfilePortraits:SetupPortrait(portrait, name, realm)
	if realm == K.Realm and name == K.Name then
		SetPortraitTexture(portrait, "player")
		portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		return
	end

	local profileService = K.ProfileService
	local race = profileService:GetRaceFromPortraitData(name, realm)
	local gender = profileService:GetGenderFromPortraitData(name, realm)
	local class = profileService:GetClassFromGoldInfo(name, realm)

	local raceAtlas = self:GetRaceAtlasName(race, gender)
	if raceAtlas then
		local success = pcall(function()
			portrait:SetAtlas(raceAtlas)
		end)
		if success then
			portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			return
		end
	end

	if class and class ~= "NONE" then
		local success = pcall(function()
			portrait:SetAtlas("classicon-" .. class:lower())
		end)
		if success then
			portrait:SetTexCoord(0, 1, 0, 1)
			return
		end
	end

	if race then
		local fallbackAtlas = self:GetRaceAtlasName(race, 2)
		if fallbackAtlas then
			local success = pcall(function()
				portrait:SetAtlas(fallbackAtlas)
			end)
			if success then
				portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				return
			end
		end
	end

	local success = pcall(function()
		portrait:SetAtlas("raceicon-human-male")
	end)
	if success then
		portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	else
		portrait:SetTexture(C["Media"].Textures.White8x8Texture)
		portrait:SetVertexColor(0.3, 0.3, 0.3, 1)
		portrait:SetTexCoord(0, 1, 0, 1)
	end
end
