--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Locales.lua
	Purpose:
		Tiny locale engine. L is a table whose missing keys fall back to the key
		itself, so enUS strings need no file and untranslated keys still read
		sensibly. Locale files under Locales/ only fill in translations for the
		active client language, keeping memory and load time low.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

-- Missing key returns the key text itself (English source string).
setmetatable(L, {
	__index = function(_, key)
		return key
	end,
})

-- Only build entries for the active locale. Locale files call K:RegisterLocale.
K.GameLocale = GetLocale()

function K:RegisterLocale(locale, entries)
	if locale ~= K.GameLocale then
		return
	end
	for key, value in pairs(entries) do
		if value == true then
			-- true means "same as the key", skip so the fallback handles it.
			value = key
		end
		rawset(L, key, value)
	end
end
