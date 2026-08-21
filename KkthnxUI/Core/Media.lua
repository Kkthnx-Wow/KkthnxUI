--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Media.lua
	Purpose:
		Central media registry. Stored on C.Media (never a saved profile) so it
		survives config rebuilds. Accessors fall back to LibSharedMedia when a
		requested name is not one of ours.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local pairs = pairs
local media = K.MediaFolder

-- Our embedded copy registers under a KkthnxUI suffixed name.
K.LibSharedMedia = LibStub and LibStub("LibSharedMedia-3.0-KkthnxUI", true)

C.Media = {
	Fonts = {
		Normal = STANDARD_TEXT_FONT,
		Combat = _G.DAMAGE_TEXT_FONT or STANDARD_TEXT_FONT,
		Blank = media .. "Fonts\\Invisible.ttf",
	},
	Borders = {
		KkthnxUI = media .. "Border\\KkthnxUI\\Border.tga",
		KkthnxUI_Pixel = media .. "Border\\KkthnxUI_Pixel\\Border.tga",
		KkthnxUI_Blank = media .. "Border\\KkthnxUI_Blank\\Border.tga",
		AzeriteUI = media .. "Border\\AzeriteUI\\Border.tga",
	},
	Statusbars = {
		KkthnxUI = media .. "Statusbars\\Statusbar",
		Flat = media .. "Statusbars\\Flat.tga",
		Clean = media .. "Statusbars\\Clean.tga",
		AzeriteUI = media .. "Statusbars\\AzeriteUI.tga",
	},
	Textures = {
		White8x8 = "Interface\\BUTTONS\\WHITE8X8",
		Glow = media .. "Textures\\GlowTex.tga",
		Spark = media .. "Textures\\Spark_128.tga",
	},
	Sounds = {},
}

local statusbars = C.Media.Statusbars
local fonts = C.Media.Fonts

-- Resolve a statusbar texture by name, falling back to LSM then our default.
function K.GetTexture(name)
	if statusbars[name] then
		return statusbars[name]
	end
	if K.LibSharedMedia then
		local hit = K.LibSharedMedia:Fetch("statusbar", name, true)
		if hit then
			return hit
		end
	end
	return statusbars.KkthnxUI
end

-- Resolve a font by name, falling back to LSM then the game font.
function K.GetFont(name)
	if not name then
		return fonts.Normal
	end
	if fonts[name] then
		return fonts[name]
	end
	if K.LibSharedMedia then
		local hit = K.LibSharedMedia:Fetch("font", name, true)
		if hit then
			return hit
		end
	end
	return fonts.Normal
end

-- Register our media with LibSharedMedia so other addons can use it.
if K.LibSharedMedia then
	local LSM = K.LibSharedMedia
	for name, path in pairs(statusbars) do
		LSM:Register("statusbar", name, path)
	end
end
