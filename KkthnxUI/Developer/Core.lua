-- Create a new module for the death counter
local K, C, L = unpack(KkthnxUI)

K.Devs = {
	["Kkthnx-Area 52"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

local Module = K:NewModule("DeathCounter")

local SessionDeathCount = 0 -- variable to keep track of number of deaths in the current session
local function SetupDeathCounter()
	-- increment the total death count in the database
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCount = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCount + 1
	local DeathCountText = "[" .. KkthnxUIDB.Variables[K.Realm][K.Name].DeathCount .. "]"

	-- increment the session death count
	SessionDeathCount = SessionDeathCount + 1

	-- display a message indicating the number of deaths in the current session
	if SessionDeathCount == 1 then
		print(CreateAtlasMarkup("Navigation-Tombstone-Icon") .. "You have died " .. SessionDeathCount .. " time this session")
	else
		print(CreateAtlasMarkup("Navigation-Tombstone-Icon") .. "You have died " .. SessionDeathCount .. " times this session")
	end

	-- display a message indicating the total number of deaths
	if KkthnxUIDB.Variables[K.Realm][K.Name].DeathCount == 1 then
		K.Print("You have died a total of " .. DeathCountText .. " time")
	else
		K.Print("You have died a total of " .. DeathCountText .. " times")
	end
end

function Module:OnEnable()
	if not C["Announcements"].DeathCounter then
		return
	end

	K:RegisterEvent("PLAYER_DEAD", SetupDeathCounter)
	K:RegisterEvent("PLAYER_LOGOUT", function()
		SessionDeathCount = 0
	end)
end
