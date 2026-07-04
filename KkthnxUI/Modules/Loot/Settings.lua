--[[-----------------------------------------------------------------------------
-- Live GUI refresh for loot automation toggles.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

local REFRESH_BY_KEY = {
	FastLoot = "CreateFasterLoot",
	AutoGreed = "CreateAutoGreed",
	AutoConfirm = "CreateAutoConfirm",
	GroupLoot = "CreateGroupLoot",
}

local function OnLootSetting(configPath)
	local key = configPath:match("^Loot%.(.+)$")
	if not key then
		return
	end

	local method = REFRESH_BY_KEY[key]
	if method and Module[method] then
		Module[method](Module)
	elseif key == "Enable" then
		Module:SetLootEnabled(C["Loot"].Enable)
	end
end

K:RegisterSettingPrefixCallback("Loot.", OnLootSetting)
