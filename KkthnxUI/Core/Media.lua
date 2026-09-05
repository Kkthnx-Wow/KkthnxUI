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

-- Two copies of the library can be in play. Ours is embedded under a suffixed
-- name so it can never fight another addon's, but a private copy shares nothing:
-- every other addon publishes into and reads from the real LibSharedMedia-3.0. So
-- prefer the real one whenever some addon has brought it along, and fall back to
-- our own when we are running alone, which at least keeps Fetch working.
K.LibSharedMedia = LibStub and (LibStub("LibSharedMedia-3.0", true) or LibStub("LibSharedMedia-3.0-KkthnxUI", true))

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
	-- Every bar texture we actually ship. Most of these sat in Media/Statusbars
	-- unlisted, so they were on disk but could never be picked.
	Statusbars = {
		KkthnxUI = media .. "Statusbars\\Statusbar",
		AltzUI = media .. "Statusbars\\AltzUI.tga",
		AsphyxiaUI = media .. "Statusbars\\AsphyxiaUI.tga",
		AzeriteUI = media .. "Statusbars\\AzeriteUI.tga",
		Blank = media .. "Statusbars\\Blank.tga",
		Clean = media .. "Statusbars\\Clean.tga",
		Flat = media .. "Statusbars\\Flat.tga",
		Glamour7 = media .. "Statusbars\\Glamour7.tga",
		GoldpawUI = media .. "Statusbars\\GoldpawUI.tga",
		Kui = media .. "Statusbars\\KuiStatusbar.tga",
		KuiBright = media .. "Statusbars\\KuiStatusbarBright.tga",
		Ohi_Dragon = media .. "Statusbars\\Ohi_Dragon.tga",
		Palooza = media .. "Statusbars\\Palooza.tga",
		PinkGradient = media .. "Statusbars\\PinkGradient.tga",
		Rain = media .. "Statusbars\\Rain.tga",
		SkullFlowerUI = media .. "Statusbars\\SkullFlowerUI.tga",
		Tukui = media .. "Statusbars\\ElvTukui.tga",
		Water = media .. "Statusbars\\Water.tga",
		Wglass = media .. "Statusbars\\Wglass.tga",
		ZorkUI = media .. "Statusbars\\ZorkUI.tga",
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

-- Borders are deliberately absent from both directions below. Ours are a single
-- strip holding all eight edge pieces, cropped by K.CreateBorder, not the edgeFile
-- a shared border is. Publishing ours would hand other addons a texture they would
-- draw wrong, and pulling theirs in would fill our border dropdown with entries
-- that cannot render in our frames.
local SHARED_TYPES = {
	{ "statusbar", statusbars },
	{ "font", fonts },
	{ "sound", C.Media.Sounds },
}

-- Publish our media so other addons can pick it, then pull in everything they have
-- registered so it shows up in our own dropdowns. Ours win a name clash, since a
-- name in C.Media is what our defaults refer to.
function K.SyncSharedMedia()
	local LSM = K.LibSharedMedia
	if not LSM then
		return
	end

	for _, entry in pairs(SHARED_TYPES) do
		local mediatype, tbl = entry[1], entry[2]
		for name, path in pairs(tbl) do
			LSM:Register(mediatype, name, path)
		end
	end

	for _, entry in pairs(SHARED_TYPES) do
		local mediatype, tbl = entry[1], entry[2]
		local shared = LSM:HashTable(mediatype)
		if shared then
			for name, path in pairs(shared) do
				if tbl[name] == nil then
					tbl[name] = path
				end
			end
		end
	end
end

K.SyncSharedMedia()

-- Addons that load after us register their media later, so pick those up as they
-- arrive rather than only taking a snapshot at login.
if K.LibSharedMedia and K.LibSharedMedia.RegisterCallback then
	K.LibSharedMedia.RegisterCallback(K, "LibSharedMedia_Registered", function()
		K.SyncSharedMedia()
	end)
end
