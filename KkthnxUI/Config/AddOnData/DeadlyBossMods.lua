local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- Wow API
local DBM_AllSavedOptions = _G.DBM_AllSavedOptions
local DBT_AllPersistentOptions = _G.DBT_AllPersistentOptions

-- GLOBALS: DBM

function K.LoadDBMProfile()
	if DBM_AllSavedOptions then
		table_wipe(DBM_AllSavedOptions)
	end

	if DBT_AllPersistentOptions then
		table_wipe(DBT_AllPersistentOptions)
	end

	DBM:CreateProfile("KkthnxUI")

	-- Warnings
	DBM_AllSavedOptions["KkthnxUI"]["WarningFont"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\Normal.ttf"
	DBM_AllSavedOptions["KkthnxUI"]["SpecialWarningFont"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\Normal.ttf"
	DBM_AllSavedOptions["KkthnxUI"]["SpecialWarningFontShadow"] = true
	DBM_AllSavedOptions["KkthnxUI"]["SpecialWarningFontStyle"] = "NONE"

	-- Bars
	DBT_AllPersistentOptions["KkthnxUI"]["DBM"]["Texture"] = "Interface\\TargetingFrame\\UI-StatusBar"
	DBT_AllPersistentOptions["KkthnxUI"]["DBM"]["Font"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\Normal.ttf"
	DBT_AllPersistentOptions["KkthnxUI"]["DBM"]["Scale"] = 1
	DBT_AllPersistentOptions["KkthnxUI"]["DBM"]["FontSize"] = 12
	DBT_AllPersistentOptions["KkthnxUI"]["DBM"]["HugeScale"] = 1
	DBT_AllPersistentOptions["KkthnxUI"]["DBM"]["BarYOffset"] = 4
	DBT_AllPersistentOptions["KkthnxUI"]["DBM"]["HugeBarYOffset"] = 4

	DBM:ApplyProfile("KkthnxUI")
end