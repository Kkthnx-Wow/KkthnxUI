--[[-----------------------------------------------------------------------------
-- Live GUI refresh for DataText icon color and hide-text toggles.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("DataText")

local APPEARANCE_KEYS = {
	IconColor = true,
	HideText = true,
}

local PANEL_KEYS = {
	System = true,
	Latency = true,
	Gold = true,
	Guild = true,
	Friends = true,
	Location = true,
	Time = true,
	Coords = true,
	Spec = true,
}

local function OnDataTextSetting(configPath)
	local key = configPath:match("^DataText%.(.+)$")
	if not key then
		return
	end

	if PANEL_KEYS[key] and Module.RefreshDataTextPanel then
		Module:RefreshDataTextPanel(key)
	end

	if key == "Location" and Module.UpdateLocationTextVisibility then
		Module:UpdateLocationTextVisibility()
	end

	if not APPEARANCE_KEYS[key] then
		return
	end

	if Module.RefreshAppearance then
		Module:RefreshAppearance()
	end
end

K:RegisterSettingPrefixCallback("DataText.", OnDataTextSetting)
